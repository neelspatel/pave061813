//
//  PersonalFeedController
//  Pave
//
//  Created by Neel Patel on 6/18/13.
//  Copyright (c) 2013 Pave. All rights reserved.
//

#import "PersonalFeedController.h"
#import <QuartzCore/QuartzCore.h>
#import "PaveAPIClient.h"
#import "UIImageView+WebCache.h"
#import "SDImageCache.h"
#import "AnswersCell.h"
#import "UGQuestionsCell.h"
#import "RecsCell.h"
#import "ProfileViewCell.h"
#import "MBProgressHUD.h"
#import <FacebookSDK/FacebookSDK.h>
#import "AppDelegate.h"
#import "LoginViewController.h"
#import "AboutUGQuestion.h"
#import "MKNumberBadgeView.h"

@interface PersonalFeedController ()

@end

@implementation PersonalFeedController


- (void)viewDidLoad
{    
    [super viewDidLoad];
    
    //sets the active table
    self.currentTable = @"answers";
    self.answers.hidden = NO;
    self.recs.hidden = YES;
    self.ugQuestions.hidden = YES;
    
    //loads the popup
    NSDictionary *data = [NSDictionary dictionaryWithObjectsAndKeys: @"test", @"question", nil];
    self.popup = [[AboutUGQuestion alloc] initWithData:data];
    
    
    //loads up the picture in the top bar
    [[UINavigationBar appearance] setBackgroundImage:[UIImage imageNamed:@"top_bar.png"] forBarMetrics:UIBarMetricsDefault];    
    
    //loads image cache
    self.myImageCache = [SDImageCache.alloc initWithNamespace:@"FeedObjects"];
    
    //self.tableView.layer.cornerRadius=5;
    //self.tableViewBackground.layer.cornerRadius=5;
    
    self.feedObjects = [NSArray array];
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    self.answerReadStatus = [[NSMutableDictionary alloc] init];
    if([defaults objectForKey:@"answerReadStatus"])
    {
        self.answerReadStatus = [defaults objectForKey:@"answerReadStatus"];
    }
    
    self.recReadStatus = [[NSMutableDictionary alloc] init];
    
    self.imageRequests = [[NSMutableDictionary alloc] init];
    self.reloadingFeedObject = NO;
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(switchToInsights:)
                                                 name:@"newRecommendation"
                                               object:nil];

    //sets up the pull to refresh controller
    UIRefreshControl *answersRefreshControl = [[UIRefreshControl alloc] init];
    [answersRefreshControl addTarget:self action:@selector(refreshWithPull:) forControlEvents:UIControlEventValueChanged];
    [self.answers addSubview:answersRefreshControl];
    
    UIRefreshControl *recsRefreshControl = [[UIRefreshControl alloc] init];
    [recsRefreshControl addTarget:self action:@selector(refreshWithPull:) forControlEvents:UIControlEventValueChanged];
    [self.recs addSubview:recsRefreshControl];
    
    UIRefreshControl *ugRefreshControl = [[UIRefreshControl alloc] init];
    [ugRefreshControl addTarget:self action:@selector(refreshWithPull:) forControlEvents:UIControlEventValueChanged];
    [self.ugQuestions addSubview:ugRefreshControl];
    
    //sets the handler to listen for taps    
    [self updateProfileStats];
    
    NSLog(@"Feed objects are %@", self.feedObjects);
    [self getFeedObjects];
    
    self.badge_answers = [[MKNumberBadgeView alloc] initWithFrame:CGRectMake(60, -25, 40, 40)];
    [self.badge_answers setValue:[self getAnswerCount]];
    self.badge_answers.hideWhenZero = YES;
    [self.answersButton addSubview: self.badge_answers];
    
    self.badge_recs= [[MKNumberBadgeView alloc] initWithFrame:CGRectMake(60, -25, 40, 40)];
    [self.badge_recs setValue:[self getRecCount]];
    self.badge_recs.hideWhenZero = YES;
    [self.insightsButton addSubview: self.badge_recs];
    
    self.badge_ug_answers = [[MKNumberBadgeView alloc] initWithFrame:CGRectMake(60, -25, 40, 40)];
    [self.badge_ug_answers  setValue:[self getUGCount]];
    self.badge_ug_answers.hideWhenZero = YES;
    [self.questionsButton addSubview: self.badge_ug_answers];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateBadgeCounts) name:@"updateProfileBadgeCounts" object:nil];
}
- (void)viewWillDisappear:(BOOL)animated
{
    [[self.tabBarController.tabBar.items objectAtIndex:0] setBadgeValue:nil];
}

-(void) updateBadgeCounts
{
    [self setBadgeForIndex:0 withCount:[self getAnswerCount]];
    [self setBadgeForIndex:1 withCount:[self getRecCount]];
    [self setBadgeForIndex:2 withCount:[self getUGCount]];

}
-(NSInteger) getUGCount
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSInteger num_answers = [defaults integerForKey:@"num_ug_answers"];
    if (num_answers)
        return num_answers;
    else
        return 0;
}

-(NSInteger) getAnswerCount
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSInteger num_answers = [defaults integerForKey:@"num_answers"];
    if (num_answers)
        return num_answers;
    else
        return 0;
}

-(NSInteger) getRecCount
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSInteger num_answers = [defaults integerForKey:@"num_recs"];
    if (num_answers)
        return num_answers;
    else
        return 0;
}

- (void) setBadgeForIndex: (NSInteger)index  withCount:(NSInteger) count
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    switch (index) {
        case 1:
            [defaults setInteger:count forKey:@"num_answers"];
            [self.badge_answers setValue: count];
            break;
        case 2:
            [defaults setInteger:count forKey:@"num_recs"];
            [self.badge_recs setValue: count];
            break;
        case 3:
            [defaults setInteger:count forKey:@"num_ug_answers"];
            [self.badge_ug_answers setValue: count];
            break;
        default:
            break;
    }
    [defaults synchronize];
}


-(void)switchToInsights:(NSNotification *) notification
{
    NSLog(@"Getting called after notif");
    [self viewInsights:self];
}

- (void)handleTap:(id)sender event:(id)event
{
    NSLog(@"Tapped");
    if ([self.currentTable isEqualToString:@"answers"]) {
        UITableView *tableView = self.answers;
        
        NSSet *touches = [event allTouches];
        UITouch *touch = [touches anyObject];
        
        CGPoint currentTouchPosition = [touch locationInView:self.answers];        
        
        NSIndexPath *indexPath = [self.answers indexPathForRowAtPoint: currentTouchPosition];
        [tableView deselectRowAtIndexPath:indexPath animated:NO];
        
        AnswersCell *cell = [tableView cellForRowAtIndexPath:indexPath];
        
        CGPoint pointInCell = [touch locationInView:cell];
        
        NSMutableDictionary *currentObject = [self.feedObjects objectAtIndex:indexPath.row];
        NSLog(@"Current object is at %d: %@", indexPath.row, currentObject);
        
        NSString *key = [NSString stringWithFormat:@"%@%@%@%@", [NSString stringWithFormat:@"%@", currentObject[@"friend"]], currentObject[@"question"], currentObject[@"chosenProduct"], currentObject[@"otherProduct"], nil];
        
        if (CGRectContainsPoint(cell.agree.frame, pointInCell)) {
            NSLog(@"In the left image!");
            //checks if this one has been answered yet
            if([self.answerReadStatus valueForKey:key]  == nil)
            {
                //saves it as read - true means left
                [self.answerReadStatus setObject:@"Left" forKey:key];
                
                [self displayAnswerAsRead:cell side:@"Left"];
                
                //now saves the cell in the database
                //[self saveAnswer:cell :TRUE];
            }
            else
            {
                NSLog(@"Already answered but changing anyway");
                //saves it as read - true means left
                [self.answerReadStatus setObject:@"Left" forKey:key];
                
                [self displayAnswerAsRead:cell side:@"Left"];                                
            }
            
        } else if (CGRectContainsPoint(cell.disagree.frame, pointInCell)) {
            NSLog(@"In the right image!");
            if([self.answerReadStatus valueForKey:key]  == nil)
            {
                //saves it as read - true means left
                [self.answerReadStatus setObject:@"Right" forKey:key];
                
                [self displayAnswerAsRead:cell side:@"Right"];
                
                //now saves the cell in the database
                //[self saveAnswer:cell :TRUE];
            }
            else
            {
                NSLog(@"Already answered but changing anyway");
                //saves it as read - true means left
                [self.answerReadStatus setObject:@"Right" forKey:key];
                
                [self displayAnswerAsRead:cell side:@"Right"];
            }
            
        }
        else {
            NSLog(@"Not in the image...");
        }
    }
}

//logic for switching in the buttons and tables
- (IBAction)viewAnswers:(id)sender
{
    [self setBadgeForIndex:1 withCount:0];

    //change the button
    [self.answersButton setImage:[UIImage imageNamed:@"selected_answers_about_me@2x.png"] forState:UIControlStateNormal];
    [self.insightsButton setImage:[UIImage imageNamed:@"unselected_insights_for_me@2x.png"] forState:UIControlStateNormal];
    [self.questionsButton setImage:[UIImage imageNamed:@"unselected_questions_by_me.png"] forState:UIControlStateNormal];

    
    self.currentTable = @"answers";
    [self changeTable];
}

- (IBAction)viewInsights:(id)sender
{
    [self setBadgeForIndex:2 withCount:0];

    //change the button
    [self.answersButton setImage:[UIImage imageNamed:@"unselected_answers_about_me@2x.png"] forState:UIControlStateNormal];
    [self.insightsButton setImage:[UIImage imageNamed:@"selected_insights_for_me@2x.png"] forState:UIControlStateNormal];
    [self.questionsButton setImage:[UIImage imageNamed:@"unselected_questions_by_me.png"] forState:UIControlStateNormal];
    
    self.currentTable = @"recs";
    [self changeTable];
}

- (IBAction)viewQuestions:(id)sender
{
    [self setBadgeForIndex:3 withCount:0];

    //change the button
    [self.answersButton setImage:[UIImage imageNamed:@"unselected_answers_about_me@2x.png"] forState:UIControlStateNormal];
    [self.insightsButton setImage:[UIImage imageNamed:@"unselected_insights_for_me@2x.png"] forState:UIControlStateNormal];
    [self.questionsButton setImage:[UIImage imageNamed:@"selected_questions_by_me.png"] forState:UIControlStateNormal];
    
    self.currentTable = @"ugQuestions";
    [self changeTable];    
}

//changes the table
- (void) changeTable
//- (IBAction)changeTable:(id)sender
{
    if([self.currentTable isEqualToString:@"answers"])
    {        
        //self.currentTable = @"ugQuestions";
        self.answers.hidden = NO;
        self.ugQuestions.hidden = YES;
        self.recs.hidden = YES;

        //now reloads the data
        self.feedObjects = [NSArray array];
        [self getFeedObjects];
    }
    else if([self.currentTable isEqualToString:@"ugQuestions"])
    {        
        //self.currentTable = @"recs";
        self.answers.hidden = YES;
        self.ugQuestions.hidden = NO;
        self.recs.hidden = YES;
        
        //now reloads the data
        self.feedObjects = [NSArray array];
        [self getFeedObjects];
    }
    else //if recs
    {
        //self.currentTable = @"answers";
        self.answers.hidden = YES;
        self.ugQuestions.hidden = YES;
        self.recs.hidden = NO;

        //now reloads the data        
        self.feedObjects = [NSArray array];
        [self getFeedObjects];
    }
}

- (void)refresh
{
    NSLog(@"reloading personal datapre");
    self.feedObjects = [NSArray array];
    NSLog(@"reloading personal data");
    [self getFeedObjects];
        
}

- (void)refreshWithPull:(UIRefreshControl *)refreshControl
{
    self.reloadingFeedObject = YES;

    NSLog(@"reloading personal datapre");
    self.feedObjects = [NSArray array];
    NSLog(@"reloading personal data");
    [self getFeedObjects];
    
    [refreshControl endRefreshing];
    
}

- (IBAction)inviteFriends:(id)sender {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSArray *topFriends = [[defaults objectForKey:@"friends"]subarrayWithRange:NSMakeRange(0, 10)];
    
    NSMutableDictionary* params =   [NSMutableDictionary dictionaryWithObjectsAndKeys:
     [topFriends componentsJoinedByString:@","], @"suggestions", nil];
    
    [FBWebDialogs presentRequestsDialogModallyWithSession:nil
      message:[NSString stringWithFormat:@"Get Side, the hottest new social discovery app!"]
        title:nil
   parameters:params
      handler:^(FBWebDialogResult result, NSURL *resultURL, NSError *error) {
          if (error) {
              // Case A: Error launching the dialog or sending request.
              NSLog(@"Error sending request.");
          } else {
              if (result == FBWebDialogResultDialogNotCompleted) {
                  // Case B: User clicked the "x" icon
                  NSLog(@"User canceled request.");
              } else {
                  NSLog(@"Request Sent.");
              }
          }}];

}

// this code doesn't work yet
/**
- (void)tableView:(UITableView *)tableView didEndDisplayingCell:(ProfileObjectCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"At row %d with feed objects %d", indexPath.row, [self.feedObjects count]);
    if(indexPath.row != 0 && indexPath.row != ([self.feedObjects count] + 1))
    {
        NSLog(@"About to cancel cell");
        // free up the requests for each ImageView
        [cell.profilePicture cancelCurrentImageLoad];
        [cell.rightProduct cancelCurrentImageLoad];
        [cell.leftProduct cancelCurrentImageLoad];
    }
     
}
 */

- (IBAction)logout:(id)sender;
{
    NSLog(@"in logout");
    
    AppDelegate* delegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    FBSession* session = delegate.session;
    
    [session closeAndClearTokenInformation];
    [session close];
    
    //[FBSession setActiveSession:nil];
    //[FBSession.activeSession close];
    //[FBSession.activeSession  closeAndClearTokenInformation];
    
    [self performSegueWithIdentifier:@"profileToLoginScreen" sender:self];
}


- (void) getFeedObjects
{
    
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, 0.01 * NSEC_PER_SEC);
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        // Do something...
        [MBProgressHUD hideHUDForView:self.view animated:YES];
    
        if([self.currentTable isEqualToString:@"answers"])
        {
            NSLog(@"About to get feed objects for answers");
            
            NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
            NSString *path = @"/data/getallfeedobjects/";
            path = [path stringByAppendingString:[defaults objectForKey:@"profile"][@"facebookId"]];
            //path = [path stringByAppendingString:@"1"];
            path = [path stringByAppendingString:@"/"];
            
            [[PaveAPIClient sharedClient] postPath:path parameters:nil success:^(AFHTTPRequestOperation *operation, id results) {
                if (results) {
                    //NSMutableArray *ids = [[NSMutableArray alloc] init];
                    //for(NSDictionary *current in results)
                    //{
                    //    [ids addObject:current[@"id"]];
                    //}
                    NSLog(@"Just finished getting results: %@", results);
                    self.feedObjects = [self.feedObjects arrayByAddingObjectsFromArray:results];
                    NSLog(@"Just finished getting feed ids: %@", self.feedObjects);
                    self.doneLoadingFeed = YES;
                    
                    self.reloadingFeedObject = NO;

                    
                    [self.answers performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:NO];
                    
                } }
                                           failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                               NSLog(@"error logging in user to Django %@", error);
                                           }];
        }
        else if([self.currentTable isEqualToString:@"recs"])
        {
            NSLog(@"About to get feed objects for recs");
            
            NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
            NSString *path = @"/data/getallfeedobjects/";
            path = [path stringByAppendingString:[defaults objectForKey:@"profile"][@"facebookId"]];
            //path = [path stringByAppendingString:@"1"];
            path = [path stringByAppendingString:@"/"];
            
            [[PaveAPIClient sharedClient] postPath:path parameters:nil success:^(AFHTTPRequestOperation *operation, id results) {
                if (results) {
                    //NSMutableArray *ids = [[NSMutableArray alloc] init];
                    //for(NSDictionary *current in results)
                    //{
                    //    [ids addObject:current[@"id"]];
                    //}
                    //NSLog(@"Just finished getting results: %@", results);
                    self.feedObjects = [self.feedObjects arrayByAddingObjectsFromArray:results];
                    //NSLog(@"Just finished getting feed ids: %@", self.feedObjects);
                    self.doneLoadingFeed = YES;
                    
                    self.reloadingFeedObject = NO;
                    
                    [self.recs performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:NO];
                    
                } }
                                           failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                               NSLog(@"error logging in user to Django %@", error);
                                           }];
        }
        else
        {
        
            NSLog(@"About to get feed objects for ugquestions");
            
            NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
            NSString *path = @"/data/getugquestionslist/";
            path = [path stringByAppendingString:[defaults objectForKey:@"profile"][@"facebookId"]];
            //path = [path stringByAppendingString:@"1"];
            path = [path stringByAppendingString:@"/"];
            
            [[PaveAPIClient sharedClient] postPath:path parameters:nil success:^(AFHTTPRequestOperation *operation, id results) {
                if (results) {
                    //NSMutableArray *ids = [[NSMutableArray alloc] init];
                    //for(NSDictionary *current in results)
                    //{
                    //    [ids addObject:current[@"id"]];
                    //}
                    NSLog(@"Just finished getting results: %@ for path %@", results, path);
                    self.feedObjects = [self.feedObjects arrayByAddingObjectsFromArray:results];
                    //NSLog(@"Just finished getting feed ids: %@", self.feedObjects);
                    self.doneLoadingFeed = YES;
                    
                    self.reloadingFeedObject = NO;
                    
                    [self.ugQuestions performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:NO];
                    
                } }
                                           failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                               NSLog(@"error logging in user to Django %@", error);
                                           }];
        }
        
        });
}

- (void)viewDidAppear:(BOOL)animated
{
    //removes the badge
    UITabBar *tabBar = (UITabBar *)self.tabBarController.tabBar;
    
    [[tabBar.items objectAtIndex:0] setBadgeValue:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
#warning Potentially incomplete method implementation.
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
#warning Incomplete method implementation.
    // Return the number of rows in the section.
    //extra for profile and invite cells
    return self.feedObjects.count + 1;
}

- (AnswersCell *) displayAnswerAsRead:(AnswersCell *) cell side:(NSString *) side
{
    if([side isEqualToString:@"Left"])
    {
        [cell.agree setImage:[UIImage imageNamed:@"SELECTED_BIG_AGREE_BUTTON.png"] forState:UIControlStateNormal];
        [cell.disagree setImage:[UIImage imageNamed:@"BIG_DISAGREE_BUTTON.png"] forState:UIControlStateNormal];
    }
    else
    {
        [cell.agree setImage:[UIImage imageNamed:@"BIG_AGREE_BUTTON.png"] forState:UIControlStateNormal];
        [cell.disagree setImage:[UIImage imageNamed:@"SELECTED_BIG_DISAGREE_BUTTON.png"] forState:UIControlStateNormal];
    }
    return cell;
}

-(void) updateProfileStats
{
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    if ([defaults valueForKey:@"profile_answer_count"]!= nil)
    {
        self.votesTextField.text = [defaults objectForKey:@"profile_vote_count"];
        self.answersTextField.text = [defaults objectForKey:@"profile_answer_count"];
        self.questionsTextField.text = [defaults objectForKey:@"profile_question_count"];
        self.levelTextField.text = [@"Level " stringByAppendingString:[defaults objectForKey:@"level"]];
    }
    

    NSString *path = @"/data/getprofilestats/";
    path = [path stringByAppendingString:[defaults objectForKey:@"profile"][@"facebookId"]];
    path = [path stringByAppendingString:@"/"];
    NSLog(@"updateProfileStats");
    [[PaveAPIClient sharedClient] postPath:path parameters:nil
                                   success:^(AFHTTPRequestOperation *operation, id results) {
        if (results) {
            NSString *answer_count = [[results objectForKey:@"answer_count"] stringValue];
            NSString *ug_question_count = [[results objectForKey:@"ug_question_count"] stringValue];
            NSString *vote_count = [[results objectForKey:@"vote_count"] stringValue];
            NSString *level = [[results objectForKey: @"level" ]  stringValue];
            self.votesTextField.text = vote_count;
            self.answersTextField.text = answer_count;
            self.questionsTextField.text = ug_question_count;
            self.levelTextField.text = [@"Level " stringByAppendingString:level];
            
            [defaults setObject:answer_count forKey:@"profile_answer_count"];
            [defaults setObject:ug_question_count forKey:@"profile_ug_answer_count"];
            [defaults setObject:vote_count forKey:@"profile_vote_count"];
            [defaults setObject:level forKey:@"level"];
            [defaults synchronize];
            NSLog(@"Profile Stats: %d, %d, %d", answer_count, ug_question_count, vote_count);
            
        }
    }
     
        failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                       NSLog(@"error while updating profile stats: %@", error);
                                   }];
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(self.reloadingFeedObject)
    {
        NSLog(@"Still reloading");
        UITableView *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"InviteFriends"];
        return cell;
    }
    else
    {
        //otherwise if it's a footer
        if(indexPath.row == self.feedObjects.count)
        {
            static NSString *CellIdentifier = @"InviteFriends";
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
            if (!cell) {
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
                // More initializations if needed.
            }
                    
            return cell;
        }
        else
        {
            if(tableView == self.answers)
            {        
                static NSString *CellIdentifier = @"AnswersCell";
                AnswersCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];            
                NSLog(@"IndexPath is %d", indexPath.row);
                NSDictionary *currentObject = [self.feedObjects objectAtIndex:(indexPath.row)];
                    
                NSString *newtext = currentObject[@"question"];
                
                cell.question.text = newtext;
                
                //now downloads and saves the images
                NSString *currentID = [NSString stringWithFormat:@"%@", currentObject[@"friend"]];
                //NSString *currentID = @"4";

                SDImageCache *imageCache = [SDImageCache sharedImageCache];
                
                //for profile picture
                cell.profilePicture.image = [UIImage imageNamed:@"profile_icon.png"];
                NSString *profileURL = @"https://graph.facebook.com/";
                profileURL = [profileURL stringByAppendingString:currentID ];
                profileURL = [profileURL stringByAppendingString:@"/picture?type=normal"];
                
                [imageCache queryDiskCacheForKey:profileURL done:^(UIImage *image, SDImageCacheType cacheType)
                 {
                     //if it's not there
                     if(image==nil)
                     {
                         [SDWebImageDownloader.sharedDownloader downloadImageWithURL:[NSURL URLWithString:profileURL] options:0 progress:^(NSUInteger receivedSize, long long expectedSize)
                          {
                              // progression tracking code
                              //NSLog(@"At progress point %u out of %lld", receivedSize, expectedSize);
                          }
                                                                           completed:^(UIImage *image, NSData *data, NSError *error, BOOL finished)
                          {
                              if (image && finished)
                              {
                                  // do something with image
                                  cell.profilePicture.image = image;
                                  
                                  //and now save it
                                  [imageCache storeImage:image forKey:profileURL];
                                  
                              }
                          }];
                     }
                     //otherwise just set it
                     else
                     {
                         cell.profilePicture.image = image;
                     }
                     
                 }];
                cell.profilePicture.clipsToBounds = YES;
                
                //for left product picture
                // instantiate them
                cell.leftProduct.image = [UIImage imageNamed:@"profile_icon.png"];
                NSString *leftImageURL = @"https://s3.amazonaws.com/pave_product_images/";
                leftImageURL = [leftImageURL stringByAppendingString:currentObject[@"chosenProduct"]];
                leftImageURL = [leftImageURL stringByReplacingOccurrencesOfString:@"+" withString:@"%2b"];
                leftImageURL = [leftImageURL stringByReplacingOccurrencesOfString:@" " withString:@"+"];
                
                [imageCache queryDiskCacheForKey:leftImageURL done:^(UIImage *image, SDImageCacheType cacheType)
                 {
                     //if it's not there
                     if(image==nil)
                     {
                         [SDWebImageDownloader.sharedDownloader downloadImageWithURL:[NSURL URLWithString:leftImageURL] options:0 progress:^(NSUInteger receivedSize, long long expectedSize)
                          {
                              // progression tracking code
                              // NSLog(@"At progress point %u out of %lld", receivedSize, expectedSize);
                          }
                                                                           completed:^(UIImage *image, NSData *data, NSError *error, BOOL finished)
                          {
                              if (image && finished)
                              {
                                  // do something with image
                                  NSLog(@"Finished getting left product image");
                                  cell.leftProduct.image = image;
                                  
                                  //and now save it
                                  [imageCache storeImage:image forKey:leftImageURL];
                                  
                              }
                          }];
                     }
                     //otherwise just set it
                     else
                     {
                         cell.leftProduct.image = image;
                     }
                     
                 }];
                cell.leftProduct.clipsToBounds = YES;
                
                //for right product picture
                cell.rightProduct.image = [UIImage imageNamed:@"profile_icon.png"];
                
                NSString *rightImageURL = @"https://s3.amazonaws.com/pave_product_images/";
                rightImageURL = [rightImageURL stringByAppendingString:currentObject[@"otherProduct"]];
                rightImageURL = [rightImageURL stringByReplacingOccurrencesOfString:@"+" withString:@"%2b"];
                rightImageURL = [rightImageURL stringByReplacingOccurrencesOfString:@" " withString:@"+"];
                
                [imageCache queryDiskCacheForKey:rightImageURL done:^(UIImage *image, SDImageCacheType cacheType)
                 {
                     //if it's not there
                     if(image==nil)
                     {
                         [SDWebImageDownloader.sharedDownloader downloadImageWithURL:[NSURL URLWithString:rightImageURL] options:0 progress:^(NSUInteger receivedSize, long long expectedSize)
                          {
                              // progression tracking code
                              //NSLog(@"At progress point %u out of %lld", receivedSize, expectedSize);
                          }
                                                                           completed:^(UIImage *image, NSData *data, NSError *error, BOOL finished)
                          {
                              if (image && finished)
                              {
                                  // do something with image
                                  NSLog(@"Finished getting image");
                                  cell.rightProduct.image = image;
                                  
                                  //and now save it
                                  [imageCache storeImage:image forKey:rightImageURL];
                                  
                              }
                          }];
                     }
                     //otherwise just set it
                     else
                     {
                         cell.rightProduct.image = image;
                     }
                 }];
                cell.rightProduct.clipsToBounds = YES;
                
                //checks if we've agreed or disagreed with this product before
                //key is in the format of friend, question, answer1, answer2
                NSString *key = [NSString stringWithFormat:@"%@%@%@%@", currentID, newtext, currentObject[@"chosenProduct"], currentObject[@"otherProduct"], nil];
                
                //adds tap listener
                [cell.agree addTarget:self action:@selector(handleTap:event:) forControlEvents:UIControlEventTouchUpInside];
                
                [cell.disagree addTarget:self action:@selector(handleTap:event:) forControlEvents:UIControlEventTouchUpInside];
                
                //resets the buttons
                [cell.agree setImage:[UIImage imageNamed:@"BIG_AGREE_BUTTON.png"] forState:UIControlStateNormal];
                [cell.disagree setImage:[UIImage imageNamed:@"BIG_DISAGREE_BUTTON.png"] forState:UIControlStateNormal];
                
                if([self.answerReadStatus objectForKey:key])
                {
                    NSLog(@"Was read at position %d", indexPath.row);
                    return [ self displayAnswerAsRead:cell side:[self.answerReadStatus objectForKey:key]];
                }
                else
                {
                    return cell;
                }
                
                

            }
            else if(tableView == self.recs) //if it's a rec
            {
                static NSString *CellIdentifier = @"RecsCell";
                //static NSString *CellIdentifier = @"UGQuestionsCell";
                RecsCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
                
                NSLog(@"IndexPath is %d", indexPath.row);
                NSDictionary *currentObject = [self.feedObjects objectAtIndex:(indexPath.row)];
                
                NSString *newtext = currentObject[@"question"];
                
                cell.text.text = newtext;
                
                //now downloads and saves the images
                
                SDImageCache *imageCache = [SDImageCache sharedImageCache];
                
                //for image
                // instantiate them
                cell.image.image = [UIImage imageNamed:@"profile_icon.png"];
                NSString *leftImageURL = @"https://s3.amazonaws.com/pave_product_images/";
                leftImageURL = [leftImageURL stringByAppendingString:currentObject[@"chosenProduct"]];
                leftImageURL = [leftImageURL stringByReplacingOccurrencesOfString:@"+" withString:@"%2b"];
                leftImageURL = [leftImageURL stringByReplacingOccurrencesOfString:@" " withString:@"+"];
                
                [imageCache queryDiskCacheForKey:leftImageURL done:^(UIImage *image, SDImageCacheType cacheType)
                 {
                     //if it's not there
                     if(image==nil)
                     {
                         [SDWebImageDownloader.sharedDownloader downloadImageWithURL:[NSURL URLWithString:leftImageURL] options:0 progress:^(NSUInteger receivedSize, long long expectedSize)
                          {
                              // progression tracking code
                              // NSLog(@"At progress point %u out of %lld", receivedSize, expectedSize);
                          }
                                                                           completed:^(UIImage *image, NSData *data, NSError *error, BOOL finished)
                          {
                              if (image && finished)
                              {
                                  // do something with image
                                  NSLog(@"Finished getting left product image");
                                  cell.image.image = image;
                                  
                                  //and now save it
                                  [imageCache storeImage:image forKey:leftImageURL];
                                  
                              }
                          }];
                     }
                     //otherwise just set it
                     else
                     {
                         cell.image.image = image;
                     }
                     
                 }];
                cell.image.clipsToBounds = YES;
                                        
                return cell;
            }
            else //if it's a UGAnswer
            {
                static NSString *CellIdentifier = @"UGQuestionsCell";
                UGQuestionsCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
                NSLog(@"IndexPath is %d", indexPath.row);
                NSDictionary *currentObject = [self.feedObjects objectAtIndex:(indexPath.row)];
                
                NSString *newtext = currentObject[@"question_text"];
                
                cell.question.text = newtext;
                
                SDImageCache *imageCache = [SDImageCache sharedImageCache];                        
                
                //for left product picture
                // instantiate them
                cell.leftProduct.image = [UIImage imageNamed:@"profile_icon.png"];
                NSString *leftImageURL = currentObject[@"product_1_url"];
                
                [imageCache queryDiskCacheForKey:leftImageURL done:^(UIImage *image, SDImageCacheType cacheType)
                 {
                     //if it's not there
                     if(image==nil)
                     {
                         [SDWebImageDownloader.sharedDownloader downloadImageWithURL:[NSURL URLWithString:leftImageURL] options:0 progress:^(NSUInteger receivedSize, long long expectedSize)
                          {
                              // progression tracking code
                              // NSLog(@"At progress point %u out of %lld", receivedSize, expectedSize);
                          }
                                                                           completed:^(UIImage *image, NSData *data, NSError *error, BOOL finished)
                          {
                              if (image && finished)
                              {
                                  // do something with image
                                  NSLog(@"Finished getting left product image");
                                  cell.leftProduct.image = image;
                                  
                                  //and now save it
                                  [imageCache storeImage:image forKey:leftImageURL];
                                  
                              }
                          }];
                     }
                     //otherwise just set it
                     else
                     {
                         cell.leftProduct.image = image;
                     }
                     
                 }];
                cell.leftProduct.clipsToBounds = YES;
                
                //for right product picture
                cell.rightProduct.image = [UIImage imageNamed:@"profile_icon.png"];
                
                NSString *rightImageURL = currentObject[@"product_2_url"];
                
                [imageCache queryDiskCacheForKey:rightImageURL done:^(UIImage *image, SDImageCacheType cacheType)
                 {
                     //if it's not there
                     if(image==nil)
                     {
                         [SDWebImageDownloader.sharedDownloader downloadImageWithURL:[NSURL URLWithString:rightImageURL] options:0 progress:^(NSUInteger receivedSize, long long expectedSize)
                          {
                              // progression tracking code
                              //NSLog(@"At progress point %u out of %lld", receivedSize, expectedSize);
                          }
                                                                           completed:^(UIImage *image, NSData *data, NSError *error, BOOL finished)
                          {
                              if (image && finished)
                              {
                                  // do something with image
                                  NSLog(@"Finished getting image");
                                  cell.rightProduct.image = image;
                                  
                                  //and now save it
                                  [imageCache storeImage:image forKey:rightImageURL];
                                  
                              }
                          }];
                     }
                     //otherwise just set it
                     else
                     {
                         cell.rightProduct.image = image;
                     }
                 }];
                cell.rightProduct.clipsToBounds = YES;
                return cell;
            }
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
    NSLog(@"Clicked");
    if([self.currentTable isEqualToString:@"ugQuestions"]) //if it's a rec
    {
        NSDictionary *currentObject = [self.feedObjects objectAtIndex:(indexPath.row)];
        NSLog(@"Current object before sending is %@", currentObject);
        self.popup = [[AboutUGQuestion alloc] initWithData:currentObject];
        [self.view addSubview:[self.popup view]];
    }
}

@end