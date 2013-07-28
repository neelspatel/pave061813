//
//  TrendingController.m
//  Pave
//
//  Created by Neel Patel on 6/20/13.
//  Copyright (c) 2013 Pave. All rights reserved.
//

#import "TrendingController.h"
#import <QuartzCore/QuartzCore.h>
#import "PaveAPIClient.h"
#import "UIImageView+WebCache.h"
#import "SDImageCache.h"
#import "TrendingObjectCell.h"
#import <FacebookSDK/FacebookSDK.h>
#import "AppDelegate.h"

@interface TrendingController ()

@end

@implementation TrendingController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

-(void) viewDidAppear:(BOOL)animated
{
    //NSLog(@"Dictionary is %@", self.typeDictionary);
    NSString *key = [[self.typeDictionary allKeys] objectAtIndex:0];
    //NSLog(@"Key is %@", key);
    self.header.text = key;
    
    //NSLog(@"Loaded the view ");
    [super viewDidAppear:animated];
}

- (void)viewDidLoad
{
    //NSLog(@"Hello loaded");
    [super viewDidLoad];
    
    //NSLog(@"Dictionary is %@", self.typeDictionary);
    
    
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
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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

- (void) displayAsRead:(TrendingObjectCell *) cell: (BOOL) left
{    
    UIColor *ourblue = [UIColor colorWithRed:(80/255.0) green:(133/255.0) blue:(232/255.0) alpha:1];
    
    cell.leftLabel.textColor = ourblue;
    cell.rightLabel.textColor = ourblue;
    cell.leftNum.textColor = ourblue;
    cell.rightNum.textColor = ourblue;
    cell.responseCount.textColor = [UIColor colorWithRed:(136/255.0) green:(136/255.0) blue:(143/255.0) alpha:1];
    
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
        CGRect frame = cell.leftBackground.frame;
        frame.origin.x = 27;
        frame.origin.y = 99;
        frame.size.width = 116;
        frame.size.height = 115;
        cell.leftBackground.frame = frame;
        cell.leftBackground.backgroundColor = ourblue;
        [cell.leftFacebookButton setHidden:FALSE];

        
    }
    else
    {
        cell.rightNum.text = [NSString stringWithFormat:@"%d", [cell.rightNum.text integerValue] + 1];
        cell.leftLabel.text = @"disagree";
        cell.rightLabel.text = @"agree";
        
        [cell.leftLabel setHidden:FALSE];
        [cell.rightLabel setHidden:FALSE];
        [cell.leftNum setHidden:FALSE];
        [cell.rightNum setHidden:FALSE];
        
        CGRect frame = cell.rightBackground.frame;
        frame.origin.x = 160;
        frame.origin.y = 99;
        frame.size.width = 116;
        frame.size.height = 115;
        cell.rightBackground.frame = frame;
        cell.rightBackground.backgroundColor = ourblue;
        [cell.rightFacebookButton setHidden:FALSE];

        
    }
    
    //hides things if need be
    if([cell.leftNum.text isEqual: @"0"])
    {
        [cell.leftLabel setHidden:TRUE];
        [cell.leftNum setHidden:TRUE];
    }
    if([cell.rightNum.text isEqual: @"0"])
    {
        [cell.rightLabel setHidden:TRUE];
        [cell.rightNum setHidden:TRUE];
    }
    
    int total = [cell.leftNum.text integerValue] + [cell.rightNum.text integerValue];
    if(total == 1)
    {
        cell.responseCount.text = @"1 response so far";
    }
    else
    {
        cell.responseCount.text = [NSString stringWithFormat:@"%d responses so far", total];
    }
}

- (void) displayAsUnread:(TrendingObjectCell *) cell: (BOOL) left
{
    UIColor *ourblue = [UIColor colorWithRed:(159/255.0) green:(184/255.0) blue:(233/255.0) alpha:1];
    
    cell.leftBackground.backgroundColor = ourblue;
    cell.rightBackground.backgroundColor = ourblue;
    
    CGRect frame = cell.leftBackground.frame;
    frame.origin.x = 32;
    frame.origin.y = 104;
    frame.size.width = 106;
    frame.size.height = 105;
    cell.leftBackground.frame = frame;
    
    frame = cell.rightBackground.frame;
    frame.origin.x = 165;
    frame.origin.y = 104;
    frame.size.width = 106;
    frame.size.height = 105;
    cell.rightBackground.frame = frame;
}

-(void)saveAnswer:(TrendingObjectCell *) cell: (BOOL) left
{
    //NSLog(@"Saving!");
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    //NSLog(@"cur id: %@", cell.currentId);
    //NSLog(@"left id: %d", cell.leftProductId);
    //NSLog(@"right id: %d", cell.rightProductId);
    //NSLog(@"question id: %d", cell.questionId);
    
    if(left == true)
    {
        NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys: [defaults objectForKey:@"id"], @"id_facebookID", cell.currentId, @"id_forFacebookID", [NSString stringWithFormat:@"%d", cell.leftProductId], @"id_chosenProduct", [NSString stringWithFormat:@"%d", cell.rightProductId], @"id_wrongProduct", [NSString stringWithFormat:@"%d", cell.questionId], @"id_question", nil];
        
        
        [[PaveAPIClient sharedClient] postPath:@"/data/newanswer"
                                    parameters:params success:^(AFHTTPRequestOperation *operation, id JSON) {
                                        //NSLog(@"successfully saved answer");
                                    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                        //NSLog(@"error saving answer %@", error);
                                    }];
        
    }
    else
    {
        NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys: [defaults objectForKey:@"id"], @"id_facebookID", cell.currentId, @"id_forFacebookID", [NSString stringWithFormat:@"%d", cell.rightProductId], @"id_chosenProduct", [NSString stringWithFormat:@"%d", cell.leftProductId], @"id_wrongProduct", [NSString stringWithFormat:@"%d", cell.questionId], @"id_question", nil];
        
        
        [[PaveAPIClient sharedClient] postPath:@"/data/newanswer"
                                    parameters:params success:^(AFHTTPRequestOperation *operation, id JSON) {
                                        //NSLog(@"successfully saved answer");
                                    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                        //NSLog(@"error saving answer %@", error);
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
        TrendingObjectCell *cell = (TrendingObjectCell*)[tableView cellForRowAtIndexPath:indexPath];
        CGPoint pointInCell = [tap locationInView:cell];
        
        NSMutableDictionary *currentObject = [[[self.typeDictionary allValues] objectAtIndex:0] objectAtIndex:indexPath.row];
        //NSLog(@"Current object is (old): %@", currentObject);
        
        if (CGRectContainsPoint(cell.leftProduct.frame, pointInCell)) {
            //NSLog(@"In the left image!");
            //checks if this one has been answered yet
            if([self.readStatus valueForKey:[NSString stringWithFormat:@"%d", indexPath.row]]  == nil)
            {
                //saves it as read - true means left
                [self.readStatus setObject:[NSNumber numberWithBool:TRUE] forKey:[NSString stringWithFormat:@"%d", indexPath.row]];
                
                [self displayAsRead:cell :TRUE];
                
                //now saves the cell in the database
                [self saveAnswer:cell :TRUE];
                [cell.leftFacebookButton setHidden:FALSE];
            }
            else
            {
                //NSLog(@"Already answered...");
            }
            
        } else if (CGRectContainsPoint(cell.rightProduct.frame, pointInCell)) {
            //NSLog(@"In the right image!");
            if([self.readStatus valueForKey:[NSString stringWithFormat:@"%d", indexPath.row]]  == nil)
            {
                //saves it as read - false means right
                [self.readStatus setObject:[NSNumber numberWithBool:FALSE] forKey:[NSString stringWithFormat:@"%d", indexPath.row]];
                
                [self displayAsRead:cell :FALSE];
                
                //now saves the cell in the database
                [self saveAnswer:cell :FALSE];
                [cell.rightFacebookButton setHidden:FALSE];
            }
            else
            {
                //NSLog(@"Already answered...");
            }
            
        }
        else {
            //NSLog(@"Not in the image...");
        }
    }
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
    return [[[self.typeDictionary allValues] objectAtIndex:0] count];
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    //NSLog(@"***REQUESTED %d ***", indexPath.row);
    
    static NSString *CellIdentifier = @"Cell";
    TrendingObjectCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    NSDictionary *currentObject = [[[self.typeDictionary allValues] objectAtIndex:0] objectAtIndex:indexPath.row];
    
    // Configure the cell...
    [cell.leftNum setHidden:TRUE];
    [cell.rightNum setHidden:TRUE];
    [cell.leftLabel setHidden:TRUE];
    [cell.rightLabel setHidden:TRUE];
    [cell.leftFacebookButton setHidden:TRUE];
    [cell.rightFacebookButton setHidden:TRUE];
    
    cell.leftBackground.layer.cornerRadius = 2;
    cell.leftBackground.clipsToBounds = YES;
    cell.rightBackground.layer.cornerRadius = 2;
    cell.rightBackground.clipsToBounds = YES;
    cell.profilePictureBackground.layer.cornerRadius = 2;
    cell.profilePictureBackground.clipsToBounds = YES;
    
    cell.question.text = currentObject[@"question_text"];
    cell.leftNum.text = [NSString stringWithFormat:@"%@", currentObject[@"product1_count"]];
    //NSLog(@"about to get rightNum");
    cell.rightNum.text = [NSString stringWithFormat:@"%@",currentObject[@"product2_count"]];
    
    //shows the number of responses so far
    int total = [cell.leftNum.text integerValue] + [cell.rightNum.text integerValue];
    if(total == 1)
    {
        cell.responseCount.text = @"1 response so far";
    }
    else
    {
        cell.responseCount.text = [NSString stringWithFormat:@"%d responses so far", total];
    }
    
    UIColor *ourblue = [UIColor colorWithRed:(159/255.0) green:(184/255.0) blue:(233/255.0) alpha:1];
    
    cell.leftBackground.backgroundColor = ourblue;
    cell.rightBackground.backgroundColor = ourblue;
    
    CGRect frame = cell.leftBackground.frame;
    frame.origin.x = 32;
    frame.origin.y = 104;
    frame.size.width = 106;
    frame.size.height = 105;
    cell.leftBackground.frame = frame;
    
    frame = cell.rightBackground.frame;
    frame.origin.x = 165;
    frame.origin.y = 104;
    frame.size.width = 106;
    frame.size.height = 105;
    cell.rightBackground.frame = frame;
    
    @try
    {
        //NSLog(@"leftFriendId");
        cell.leftFriendId = [(currentObject[@"fbFriend1"][0]) integerValue];
    }
    @catch (NSException *e)
    {
        cell.leftFriendId = 0;
    }
    
    @try
    {
        //NSLog(@"rightFriendId");
        //cell.rightFriendId = (int) [NSString stringWithFormat:@"%@", (currentObject[@"fbFriend2"][0])];
        cell.rightFriendId = [(currentObject[@"fbFriend2"][0]) integerValue];
    }
    @catch (NSException *e)
    {
        cell.rightFriendId = 0;
    }
    
    cell.leftProductId = [(currentObject[@"product1_id"]) integerValue];
    cell.rightProductId = [(currentObject[@"product2_id"]) integerValue];
    cell.questionId = [(currentObject[@"question"]) integerValue];
        
    cell.currentId = (currentObject[@"forUser"]) ;
    
    SDImageCache *imageCache = [SDImageCache sharedImageCache];
    
    //for profile picture
    NSString *profileURL = @"https://graph.facebook.com/";
    //profileURL = [profileURL stringByAppendingString:[NSString stringWithFormat:@"%d",cell.currentId] ];
    profileURL = [profileURL stringByAppendingString:cell.currentId];
    profileURL = [profileURL stringByAppendingString:@"/picture"];
    //NSLog(@"Before loading profile picture");
    [cell.profilePicture setImageWithURL:[NSURL URLWithString:profileURL]
                        placeholderImage:[UIImage imageNamed:@"profile_icon.png"]];
            
    //for left product picture
    // instantiate them
    
    //cell.leftProduct.image = [UIImage imageNamed:@"profile_icon.png"];
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
    
    //NSLog(@"Read status is %@", [self.readStatus valueForKey:[NSString stringWithFormat:@"%d", indexPath.row]]);
    //sets it as read if not set yet
    if([self.readStatus valueForKey:[NSString stringWithFormat:@"%d", indexPath.row]]  != nil)
    {
        [self displayAsRead:cell :[[self.readStatus valueForKey:[NSString stringWithFormat:@"%d", indexPath.row]] boolValue]];
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didEndDisplayingCell:(TrendingObjectCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    //NSLog(@"About to cancel cell");
    // free up the requests for each ImageView
    [cell.profilePicture cancelCurrentImageLoad];
    [cell.rightProduct cancelCurrentImageLoad];
    [cell.leftProduct cancelCurrentImageLoad];
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



- (IBAction)back:(id)sender {
    //NSLog(@"Clicked");
    [self performSegueWithIdentifier:@"trendingItemBackToList" sender:nil];
}
@end
