//
//  GroupGameController.m
//  Pave
//
//  Created by Nithin Tumma on 7/13/13.
//  Copyright (c) 2013 Pave. All rights reserved.
//

#import "GroupGameController.h"
#import <QuartzCore/QuartzCore.h>
#import "PaveAPIClient.h"
#import "JSONAPIClient.h"
#import "UIImageView+WebCache.h"
#import "SDImageCache.h"
#import "FeedObjectCell.h"
#import <FacebookSDK/FacebookSDK.h>
#import "AppDelegate.h"
#import "LoginViewController.h"
#import "MBProgressHUD.h"
#import <MessageUI/MessageUI.h>

@interface GroupGameController ()

@end

@implementation GroupGameController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    
    NSLog(@"View loaded. group is: %@", self.group);
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    //loads up the picture in the top bar
    [[UINavigationBar appearance] setBackgroundImage:[UIImage imageNamed:@"top_bar.png"] forBarMetrics:UIBarMetricsDefault];
    
    
    //loads image cache
    self.myImageCache = [SDImageCache.alloc initWithNamespace:@"FeedObjects"];
    self.tableView.layer.cornerRadius=5;
    
    self.feedObjects = [NSMutableArray array];
    self.readStatus = [[NSMutableDictionary alloc] init];
    
    self.imageRequests = [[NSMutableDictionary alloc] init];
    self.reloadingFeedObject = NO;
    
    UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTap:)];
    singleTap.delegate = self;
    singleTap.numberOfTapsRequired = 1;
    singleTap.numberOfTouchesRequired = 1;
    [self.tableView addGestureRecognizer:singleTap];

    [self getFeedObjects];

    
    //ability to call load from somewhere else
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(getFeedObjects) name:@"getFeedObjects" object:nil];
    
    
}
- (void)viewDidAppear:(BOOL)animated
{
    //first reload the data
    [self.tableView reloadData];
}

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer
{
    UITableView *tableView = (UITableView *)gestureRecognizer.view;
    CGPoint p = [gestureRecognizer locationInView:gestureRecognizer.view];
    if ([tableView indexPathForRowAtPoint:p]) {
        return YES;
    }
    return NO;
}

- (void) displayAsRead:(FeedObjectCell *) cell: (BOOL) left
{
    
    [cell.facebookButton setHidden:FALSE];
    
    if(left == TRUE)
    {
        
        //shows the labels
        cell.leftNum.text = [NSString stringWithFormat:@"%d", [cell.leftNum.text integerValue] + 1];
        cell.leftLabel.text = @"agree";
        cell.rightLabel.text = @"disagree";
        
        [cell.leftLabel setHidden:FALSE];
        [cell.rightLabel setHidden:FALSE];
        [cell.leftNum setHidden:FALSE];
        [cell.rightNum setHidden:FALSE];
        
        //hides things if need be
        if([cell.leftNum.text isEqual: @"1"])
        {
            [cell.leftLabel setHidden:TRUE];
            [cell.leftNum setHidden:TRUE];
        }
        if([cell.rightNum.text isEqual: @"0"])
        {
            [cell.rightLabel setHidden:TRUE];
            [cell.rightNum setHidden:TRUE];
        }
        
        
    }
    else
    {
        //shows the labels
        cell.rightNum.text = [NSString stringWithFormat:@"%d", [cell.rightNum.text integerValue] + 1];
        cell.leftLabel.text = @"disagree";
        cell.rightLabel.text = @"agree";
        
        [cell.leftLabel setHidden:FALSE];
        [cell.rightLabel setHidden:FALSE];
        [cell.leftNum setHidden:FALSE];
        [cell.rightNum setHidden:FALSE];
        
        //hides things if need be
        if([cell.leftNum.text isEqual: @"0"])
        {
            [cell.leftLabel setHidden:TRUE];
            [cell.leftNum setHidden:TRUE];
        }
        if([cell.rightNum.text isEqual: @"1"])
        {
            [cell.rightLabel setHidden:TRUE];
            [cell.rightNum setHidden:TRUE];
        }
        
    }
    
    
    
    int total = [cell.leftNum.text integerValue] + [cell.rightNum.text integerValue];
    if(total == 1)
    {
        cell.responseCount.text = @"1 response";
    }
    else
    {
        cell.responseCount.text = [NSString stringWithFormat:@"%d responses", total];
    }
    
}

-(void)showFBRequest: (NSString*) currentId
{
    NSMutableDictionary* paramsForFB =   [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                          // 2. Optionally provide a 'to' param to direct the request at
                                          currentId, @"to", @"true", @"new_style_message", @"Hey, get Pave!", @"message", @"apprequests", @"method", // Ali
                                          nil];
    //NSMutableDictionary* paramsForFB =   [NSMutableDictionary dictionaryWithObjectsAndKeys:nil];
    
    AppDelegate* delegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    FBSession* session = delegate.session;
    
    NSLog(@"Session in post to fb is %@", session);
    
    
    [FBWebDialogs presentRequestsDialogModallyWithSession:session
                                                  message:@"Ever wondered what people think about you? I'll tell you if you download Pave!" title:nil parameters:paramsForFB handler:^(FBWebDialogResult result, NSURL *resultURL, NSError *error) {
                                                      if (error) {
                                                          NSLog(@"Error");
                                                          // Case A: Error launching the dialog or sending request.
                                                      } else {
                                                          if (result == FBWebDialogResultDialogNotCompleted) {
                                                              //Case B: User clicked the "x" icon
                                                              NSLog(@"closed");
                                                          } else {
                                                              NSLog(@"Sent");
                                                              //Case C: Dialog shown and the user clicks Cancel or Send
                                                          }
                                                      }
                                                  }];
}

-(void)saveAnswer:(FeedObjectCell *) cell: (BOOL) left
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSLog(@"cur id: %@", cell.currentId);
    NSLog(@"left id: %d", cell.leftProductId);
    NSLog(@"right id: %d", cell.rightProductId);
    NSLog(@"question id: %d", cell.questionId);
    
    if(left == true)
    {
        
        
        
        
        NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys: [defaults objectForKey:@"id"], @"id_facebookID", cell.currentId, @"id_forFacebookID", [NSString stringWithFormat:@"%d", cell.leftProductId], @"id_chosenProduct", [NSString stringWithFormat:@"%d", cell.rightProductId], @"id_wrongProduct", [NSString stringWithFormat:@"%d", cell.questionId], @"id_question", nil];
        
        [[PaveAPIClient sharedClient] postPath:@"/data/newanswer"
                                    parameters:params success:^(AFHTTPRequestOperation *operation, id JSON) {
                                        NSLog(@"successfully saved answer");
                                    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                        NSLog(@"error saving answer %@", error);
                                    }];
        
    }
    else
    {
        NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys: [defaults objectForKey:@"id"], @"id_facebookID", cell.currentId, @"id_forFacebookID", [NSString stringWithFormat:@"%d", cell.rightProductId], @"id_chosenProduct", [NSString stringWithFormat:@"%d", cell.leftProductId], @"id_wrongProduct", [NSString stringWithFormat:@"%d", cell.questionId], @"id_question", nil];
        
        
        [[PaveAPIClient sharedClient] postPath:@"/data/newanswer"
                                    parameters:params success:^(AFHTTPRequestOperation *operation, id JSON) {
                                        NSLog(@"successfully saved answer");
                                    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                        NSLog(@"error saving answer %@", error);
                                    }];
        
    }
    
    
}

- (void)handleTap:(UITapGestureRecognizer *)tap
{
    if (UIGestureRecognizerStateEnded == tap.state) {
        UITableView *tableView = (UITableView *)tap.view;
        CGPoint p = [tap locationInView:tap.view];
        NSIndexPath* indexPath = [tableView indexPathForRowAtPoint:p];
        [tableView deselectRowAtIndexPath:indexPath animated:NO];
        FeedObjectCell *cell = [tableView cellForRowAtIndexPath:indexPath];
        CGPoint pointInCell = [tap locationInView:cell];
        
        NSMutableDictionary *currentObject = [self.feedObjects objectAtIndex:indexPath.row];
        NSLog(@"Current object is (old): %@", currentObject);
        
        if (CGRectContainsPoint(cell.leftProduct.frame, pointInCell)) {
            NSLog(@"In the left image!");
            //checks if this one has been answered yet
            if([self.readStatus valueForKey:[NSString stringWithFormat:@"%d", indexPath.row]]  == nil)
            {
                //saves it as read - true means left
                [self.readStatus setObject:[NSNumber numberWithBool:TRUE] forKey:[NSString stringWithFormat:@"%d", indexPath.row]];
                
                [self displayAsRead:cell :TRUE];
                
                //now saves the cell in the database
                [self saveAnswer:cell :TRUE];
                
                //shows the option to post a notification
                [cell.facebookButton setHidden:FALSE];
            }
            else
            {
                NSLog(@"Already answered...");
            }
            
        } else if (CGRectContainsPoint(cell.rightProduct.frame, pointInCell)) {
            NSLog(@"In the right image!");
            if([self.readStatus valueForKey:[NSString stringWithFormat:@"%d", indexPath.row]]  == nil)
            {
                //saves it as read - false means right
                [self.readStatus setObject:[NSNumber numberWithBool:FALSE] forKey:[NSString stringWithFormat:@"%d", indexPath.row]];
                
                [self displayAsRead:cell :FALSE];
                
                //now saves the cell in the database
                [self saveAnswer:cell :FALSE];
                
                //shows the option to post a notification
                [cell.facebookButton setHidden:FALSE];
            }
            else
            {
                NSLog(@"Already answered...");
            }
            
        }
        else {
            NSLog(@"Not in the image...");
        }
    }
}

- (void) getFeedObjects
{
    NSLog(@"Getting feed objects now");
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, 0.01 * NSEC_PER_SEC);
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        // Do something...
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        AppDelegate* delegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
        FBSession* session = delegate.session;
        
        if (session.state == FBSessionStateCreatedTokenLoaded || session.state == FBSessionStateOpen) {
            NSLog(@"About to get feed objects");
            
            NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
            NSString *path = @"/data/groupgetlistquestions/";
            path = [path stringByAppendingString:[defaults objectForKey:@"id"]];
            //path = [path stringByAppendingString:@"1"];
            path = [path stringByAppendingString:@"/"];
            NSLog(@"Path is %@", path);
            NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys: [self.group objectForKey:@"friend_ids"], @"group", nil];
            NSLog(@"Params are %@", params);
            
            NSData *jsonData2 = [NSJSONSerialization dataWithJSONObject:[self.group objectForKey:@"friend_ids"] options:NSJSONWritingPrettyPrinted error:nil];
            NSString *jsonString = [[NSString alloc] initWithData:jsonData2 encoding:NSUTF8StringEncoding];
            NSDictionary *params2 = [NSDictionary dictionaryWithObjectsAndKeys: jsonString, @"group", nil];

                        
            [[PaveAPIClient sharedClient] postPath:path parameters:params2 success:^(AFHTTPRequestOperation *operation, id results) {
                if (results) {
                    //NSMutableArray *ids = [[NSMutableArray alloc] init];
                    //for(NSDictionary *current in results)
                    //{
                    //    [ids addObject:current[@"id"]];
                    //}
                    NSLog(@"Just finished getting group results: %@", results);
                    self.feedObjects = [self.feedObjects arrayByAddingObjectsFromArray:results];
                    NSLog(@"Just finished getting group feed ids: %@", self.feedObjects);
                    self.reloadingFeedObject = NO;
                    [self.tableView performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:NO];
                    [self.tableView reloadData];
                    
                } }
                                           failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                               NSLog(@"error getting feed objects from database %@", error);
                                           }];
        }
    });
}

#pragma mark - Table view data source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return self.feedObjects.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"***REQUESTED GROUP %d ***", indexPath.row);
    static NSString *CellIdentifier = @"Cell";
    FeedObjectCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    NSMutableDictionary *currentObject = [self.feedObjects objectAtIndex:indexPath.row];
    
    NSLog(@"***REQUESTED GROUP %@ ***", currentObject);
    
    // Configure the cell...
    cell.profilePicture.clipsToBounds = YES;
    [cell.leftNum setHidden:TRUE];
    [cell.rightNum setHidden:TRUE];
    [cell.leftLabel setHidden:TRUE];
    [cell.rightLabel setHidden:TRUE];
    //shows the option to post a notification
    [cell.facebookButton setHidden:TRUE];
    
    
    cell.question.text = currentObject[@"questionText"];
    cell.leftNum.text = [NSString stringWithFormat:@"%@", currentObject[@"product1Count"]];
    NSLog(@"about to get rightNum");
    cell.rightNum.text = [NSString stringWithFormat:@"%@",currentObject[@"product2Count"]];
    
    //shows the number of responses so far
    int total = [cell.leftNum.text integerValue] + [cell.rightNum.text integerValue];
    if(total == 1)
    {
        cell.responseCount.text = @"1 response";
    }
    else if(total ==0)
    {
        NSLog(@"Total was 0");
        cell.responseCount.text = @"Be the first to answer!";
    }
    else
    {
        NSLog(@"Total was %d", total);
        cell.responseCount.text = [NSString stringWithFormat:@"%d responses", total];
    }
    
    //if unread
    if([self.readStatus valueForKey:[NSString stringWithFormat:@"%d", indexPath.row]]  == nil)
    {
        
    }
    
    @try
    {
        NSLog(@"leftFriendId");
        cell.leftFriendId = [(currentObject[@"fbFriend1"][0]) integerValue];
    }
    @catch (NSException *e)
    {
        cell.leftFriendId = 0;
    }
    
    @try
    {
        NSLog(@"rightFriendId");        
        cell.rightFriendId = [(currentObject[@"fbFriend2"][0]) integerValue];
    }
    @catch (NSException *e)
    {
        cell.rightFriendId = 0;
    }
    
    cell.leftProductId = [(currentObject[@"product1"]) integerValue];
    cell.rightProductId = [(currentObject[@"product2"]) integerValue];
    cell.questionId = [(currentObject[@"currentQuestion"]) integerValue];
        
    cell.currentId = (currentObject[@"friend"]) ;
    
    SDImageCache *imageCache = [SDImageCache sharedImageCache];
    
    //for profile picture
    NSString *profileURL = @"https://graph.facebook.com/";
    //profileURL = [profileURL stringByAppendingString:[NSString stringWithFormat:@"%d",cell.currentId] ];
    profileURL = [profileURL stringByAppendingString:cell.currentId];
    profileURL = [profileURL stringByAppendingString:@"/picture?type=normal"];
    NSLog(@"Before loading profile picture");
    [cell.profilePicture setImageWithURL:[NSURL URLWithString:profileURL]
                        placeholderImage:[UIImage imageNamed:@"profile_icon.png"]];
        
    NSString *leftImageURL = @"https://s3.amazonaws.com/pave_product_images/";
    leftImageURL = [leftImageURL stringByAppendingString:currentObject[@"image1"]];
    leftImageURL = [leftImageURL stringByReplacingOccurrencesOfString:@"+" withString:@"%2b"];
    leftImageURL = [leftImageURL stringByReplacingOccurrencesOfString:@" " withString:@"+"];
    
    // change the default background
    [cell.leftProduct setImageWithURL:[NSURL URLWithString:leftImageURL]
                     placeholderImage:[UIImage imageNamed:@"profile_icon.png"]];
            
    //for right product picture
    
    NSString *rightImageURL = @"https://s3.amazonaws.com/pave_product_images/";
    rightImageURL = [rightImageURL stringByAppendingString:currentObject[@"image2"]];
    rightImageURL = [rightImageURL stringByReplacingOccurrencesOfString:@"+" withString:@"%2b"];
    rightImageURL = [rightImageURL stringByReplacingOccurrencesOfString:@" " withString:@"+"];
    
    // change the default background
    [cell.rightProduct setImageWithURL:[NSURL URLWithString:rightImageURL]
                      placeholderImage:[UIImage imageNamed:@"profile_icon.png"]];
    cell.profilePicture.layer.cornerRadius = 2;
    cell.profilePicture.clipsToBounds = YES;
    cell.leftProduct.layer.cornerRadius = 2;
    cell.leftProduct.clipsToBounds = YES;
    cell.rightProduct.layer.cornerRadius = 2;
    cell.rightProduct.clipsToBounds = YES;
    
    //sets it as read if not set yet
    if([self.readStatus valueForKey:[NSString stringWithFormat:@"%d", indexPath.row]]  != nil)
    {
        [self displayAsRead:cell :[[self.readStatus valueForKey:[NSString stringWithFormat:@"%d", indexPath.row]] boolValue]];
    }
    
    return cell;
    
}

- (void)tableView:(UITableView *)tableView didEndDisplayingCell:(FeedObjectCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"About to cancel group cell");
    // free up the requests for each ImageView
    [cell.profilePicture cancelCurrentImageLoad];
    [cell.rightProduct cancelCurrentImageLoad];
    [cell.leftProduct cancelCurrentImageLoad];
}

// make the feed objects only return once
- (void)scrollViewDidEndDecelerating:(UITableView *)tableView {
    float bottomEdge = self.tableView.contentOffset.y + self.tableView.frame.size.height;
    if (bottomEdge >= self.tableView.contentSize.height - 50)  {
        NSLog(@"at the very end");
        // what to do here
        NSLog(@"Getting new feed objects: ");
        if (!self.reloadingFeedObject) {
            self.reloadingFeedObject = YES;
            [self getFeedObjects];
        }
    }
}

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
 [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
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
     */
}

- (IBAction)refresh:(id)sender {
    NSLog(@"In refresh!");
    self.feedObjects = [NSMutableArray array];
    self.readStatus = [[NSMutableDictionary alloc] init];
    [self getFeedObjects];
    [self.tableView reloadData];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
