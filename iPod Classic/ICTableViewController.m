//
//  ICTableViewController.m
//  iPod Classic
//
//  Created by Julian Shutzberg on 4/30/12.
//  Copyright (c) 2012 Stanford University. All rights reserved.
//

#import "ICTableViewController.h"
#import "Colors.h"

#import <MediaPlayer/MediaPlayer.h>

#import "ICSongsTableViewController.h"

@interface ICTableViewController ()

@end

@implementation ICTableViewController
@synthesize delegate = _delegate;

- (void)selectCurrentRow
{
    [self tableView:self.tableView didSelectRowAtIndexPath:self.tableView.indexPathForSelectedRow];
}

#pragma mark - Screen View Controller Protocol

#pragma mark Scroll wheel delegate

- (void)scrollWheel:(ICScrollWheelView *)scrollWheel pressedButtonAtLocation:(ICScrollWheelButtonLocation)location
{
    MPMusicPlayerController *musicPlayer = [MPMusicPlayerController iPodMusicPlayer];
    
    switch (location) {
        case ICScrollWheelButtonLocationTop:
            //self.tableViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"mainTV"];
            if([self.navigationController.viewControllers count] > 1){
                [self.navigationController popViewControllerAnimated:YES];
            }
            break;
        case ICScrollWheelButtonLocationBottom:
            [musicPlayer playbackState] == MPMusicPlaybackStatePlaying ? [musicPlayer pause] : [musicPlayer play];
            break;
        case ICScrollWheelButtonLocationLeft:
            (musicPlayer.currentPlaybackTime > 2) ? [musicPlayer skipToBeginning] : [musicPlayer skipToPreviousItem];
            [musicPlayer play];
            break;
        case ICScrollWheelButtonLocationRight:
            [musicPlayer skipToNextItem];
            [musicPlayer play];
            break;
        case ICScrollWheelButtonLocationCenter:
            [self selectCurrentRow];
            break;
        default:
            break;
    }
}


- (void)scrollWheel:(ICScrollWheelView *)scrollWheel didRotate:(CGFloat)degrees
{
    int up  = -1;
    int down = 1;
    
    int direction = (degrees > 0) ? 1 : -1;
    
    NSIndexPath *currentIndexPath = [self.tableView indexPathForSelectedRow];
    UITableViewCell *currentCell = [self.tableView cellForRowAtIndexPath:currentIndexPath];
    NSArray *visibleCells = [self.tableView visibleCells];
    
    // Next will be the index path above or below, but it is not guarenteed to be within the bounds of the tableview
    
    NSIndexPath *next = [NSIndexPath indexPathForRow:currentIndexPath.row + direction inSection:currentIndexPath.section];
    
    // If we are going to eventually select the next cell, go ahead and deselect this one
    
    if([self.tableView cellForRowAtIndexPath:next]){
        [self.tableView deselectRowAtIndexPath:currentIndexPath animated:NO];
    }
    
    ///////////////////////////////////////
    
    UITableViewScrollPosition position = UITableViewScrollPositionNone;
    BOOL shouldSelectNextCell = NO;
    
    // Case 1: selected cell is at the top
    
    if(currentCell == [visibleCells objectAtIndex:0])
    {
        // If we are moving up, select the cell above it, if there is one
        
        if (currentIndexPath.row > 0 && direction == up){
            //[self.tableView selectRowAtIndexPath:next animated:NO scrollPosition:UITableViewScrollPositionTop];
            position = UITableViewScrollPositionTop;
            shouldSelectNextCell = YES;
        }
        
        // If we are moving down, select the cell below, if there is one
        else if([visibleCells count] > 1 && direction == down){
            //[self.tableView selectRowAtIndexPath:next animated:NO scrollPosition:UITableViewScrollPositionNone];
            position = UITableViewScrollPositionNone;
            shouldSelectNextCell = YES;
        }
    }
    
    // Case 2: selected cell is at the bottom
    
    else if(currentCell == [visibleCells lastObject])
    {
        // If we are moving up, select the cell above it, if there is one
        
        if ([visibleCells count] > 1 && direction == up){
            //[self.tableView selectRowAtIndexPath:next animated:NO scrollPosition:UITableViewScrollPositionNone];
            position = UITableViewScrollPositionNone;
            shouldSelectNextCell = YES;
        }
        
        // If we are moving down, select the cell below, if there is one
        else if(currentIndexPath.row < [self.tableView numberOfRowsInSection:0] - 1 && direction == down){
            //[self.tableView selectRowAtIndexPath:next animated:NO scrollPosition:UITableViewScrollPositionBottom];
            position = UITableViewScrollPositionBottom;
            shouldSelectNextCell = YES;
        }
    }
    
    // Case 3: we are in the middle of the screen

    else {
        //UITableViewScrollPosition position = UITableViewScrollPositionNone;
        if([self.tableView cellForRowAtIndexPath:next] == [visibleCells objectAtIndex:0])
            position = UITableViewScrollPositionTop;
        if([self.tableView cellForRowAtIndexPath:next] == [visibleCells lastObject])
            position = UITableViewScrollPositionBottom;
        
        //[self.tableView selectRowAtIndexPath:next animated:NO scrollPosition:position];
        shouldSelectNextCell = YES;
    }
    
    if(shouldSelectNextCell){
        [self.tableView selectRowAtIndexPath:next animated:NO scrollPosition:position];
        UITableViewCell *nextCell = [self.tableView cellForRowAtIndexPath:next];
        
        nextCell.contentView.backgroundColor = TABLE_COLOR_SELECTED;
        nextCell.backgroundColor = TABLE_COLOR_SELECTED;
        
        currentCell.contentView.backgroundColor = TABLE_COLOR;
        currentCell.backgroundColor = TABLE_COLOR;
    }
}

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}


// Automatically select the first cell when the view appears

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    if([[self.tableView visibleCells] count]){
        UITableViewCell *topCell = [self.tableView.visibleCells objectAtIndex:0];
        [self.tableView selectRowAtIndexPath:[self.tableView indexPathForCell:topCell] animated:NO scrollPosition:UITableViewRowAnimationTop];
        topCell.contentView.backgroundColor = TABLE_COLOR_SELECTED;
        topCell.backgroundColor = TABLE_COLOR_SELECTED;
    }
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - Table view data source

//- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
//{
//#warning Potentially incomplete method implementation.
//    // Return the number of sections.
//    return 0;
//}
//
//- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
//{
//#warning Incomplete method implementation.
//    // Return the number of rows in the section.
//    return 0;
//}
//
//- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
//{
//    static NSString *CellIdentifier = @"Cell";
//    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
//    
//    // Configure the cell...
//    
//    return cell;
//}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Navigation logic may go here. Create and push another view controller.
    /*
     <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
     // ...
     // Pass the selected object to the new view controller.
     [self.navigationController pushViewController:detailViewController animated:YES];
     [detailViewController release];
     */
    
    ICSongsTableViewController *songsTVC = [self.storyboard instantiateViewControllerWithIdentifier:@"SongsTVC"];
    songsTVC.songs = [MPMediaQuery songsQuery];
    
    [self.navigationController pushViewController:songsTVC animated:YES];

}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    
#warning This needs to be moved into ICTableView.h
    
    cell.contentView.backgroundColor = TABLE_COLOR;
    cell.backgroundColor = TABLE_COLOR;
    
    cell.accessoryView.backgroundColor = [UIColor clearColor];
    cell.textLabel.backgroundColor = [UIColor clearColor];
    cell.detailTextLabel.backgroundColor = [UIColor clearColor];
}

@end
