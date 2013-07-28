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
#import "StatusBar.h"
#import "NotificationPopupView.h"
#import "Flurry.h"

#import <objc/runtime.h>


@interface PersonalFeedController ()

@end

@implementation PersonalFeedController


- (void)viewDidLoad
{    
    [super viewDidLoad];
    
    // setup status bar
    [self setUpStatusBar];

    //NSLog(@"VIEW DID LOAD");
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
    self.answerObjects = [NSArray array];
    self.insightObjects = [NSArray array];
    self.questionObjects = [NSArray array];
    self.reloadingAnswers = YES;
    self.reloadingUGAnswerObjects = YES;
    self.reloadingInsights = YES;
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    //sets your name and profile picture
    self.name.text = [[defaults objectForKey:@"profile"] objectForKey:@"name"];
    [self.profile setImageWithURL:[NSURL URLWithString:[[defaults objectForKey:@"profile"] objectForKey:@"pictureURL"]]
                        placeholderImage:[UIImage imageNamed:@"profile_icon.png"]];
    self.profile.clipsToBounds = YES;
    
    //allocates the list of ids as strings
    self.idStrings = [[NSMutableArray alloc] init];
    //perform no matter what
    //if([[NSUserDefaults standardUserDefaults] objectForKey:@"friendsStrings"] == nil)

    NSArray *ids = [defaults objectForKey:@"friends"];
    for(int i = 0; i < ids.count; i++)
    {
        [self.idStrings addObject:[[ids objectAtIndex: i] stringValue]];
    }
    //NSLog(@"ID strings is now %@", self.idStrings);

    //saves in nsuserdefaults
    [[NSUserDefaults standardUserDefaults] setObject:self.idStrings forKey:@"friendsStrings"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
        
    self.answerReadStatus = [[NSMutableDictionary alloc] init];
    if([defaults objectForKey:@"answerReadStatus"])
    {
        self.answerReadStatus = [defaults objectForKey:@"answerReadStatus"];
    }
    
    self.recReadStatus = [[NSMutableDictionary alloc] init];
    if([defaults objectForKey:@"recReadStatus"])
    {
        self.recReadStatus = [defaults objectForKey:@"recReadStatus"];
    }
    
    self.imageRequests = [[NSMutableDictionary alloc] init];
    self.reloadingFeedObject = YES;
    
    //sets up the pull to refresh controller
    self.answersRefreshControl = [[UIRefreshControl alloc] init];
    [self.answersRefreshControl addTarget:self action:@selector(refreshWithPull:) forControlEvents:UIControlEventValueChanged];
    [self.answers addSubview:self.answersRefreshControl];
    
    self.recsRefreshControl = [[UIRefreshControl alloc] init];
    [self.recsRefreshControl addTarget:self action:@selector(refreshWithPull:) forControlEvents:UIControlEventValueChanged];
    [self.recs addSubview:self.recsRefreshControl];
    
    self.ugRefreshControl = [[UIRefreshControl alloc] init];
    [self.ugRefreshControl addTarget:self action:@selector(refreshWithPull:) forControlEvents:UIControlEventValueChanged];
    [self.ugQuestions addSubview:self.ugRefreshControl];
    
    //sets the handler to listen for taps    
    [self updateProfileStats];
    
    [self getFeedObjects];
    //NSLog(@"Answer objects are %@", self.answerObjects);

    self.badge_answers = [[MKNumberBadgeView alloc] initWithFrame:CGRectMake(-5, -15, 40, 40)];
    [self.badge_answers setValue:[self getAnswerCount]];
    self.badge_answers.hideWhenZero = YES;
    [self.answersButton addSubview: self.badge_answers];
    
    self.badge_recs= [[MKNumberBadgeView alloc] initWithFrame:CGRectMake(-5, -15, 40, 40)];
    [self.badge_recs setValue:[self getRecCount]];
    self.badge_recs.hideWhenZero = YES;
    [self.insightsButton addSubview: self.badge_recs];
    
    self.badge_ug_answers = [[MKNumberBadgeView alloc] initWithFrame:CGRectMake(-5, -15, 40, 40)];
    [self.badge_ug_answers  setValue:[self getUGCount]];
    self.badge_ug_answers.hideWhenZero = YES;
    [self.questionsButton addSubview: self.badge_ug_answers];
    
    //sets up the loading indicators
    /**
    self.answersLoading = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
    self.answersLoading.center = CGPointMake(91, 159);
    [self.view addSubview:self.answersLoading];
    self.answersLoading.hidden = TRUE;
    
    self.insightsLoading = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
    self.insightsLoading.center = CGPointMake(198, 159);
    [self.view addSubview:self.insightsLoading];
    self.insightsLoading.hidden = TRUE;
    
    self.questionsLoading = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
    self.questionsLoading.center = CGPointMake(91, 159);
    [self.view addSubview:self.questionsLoading];
    self.questionsLoading.hidden = TRUE;
    */
    
    self.answersLoading.hidden = TRUE;
    self.insightsLoading.hidden = TRUE;
    self.questionsLoading.hidden = TRUE;        

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateBadgeCounts) name:@"updateProfileBadgeCounts" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(switchToInsights:)
                                                 name:@"newRecommendation"
                                               object:nil];
}

- (void) setUpStatusBar
{
    self.sbar = [StatusBar statusBarCreate];
    self.sbar.frame = CGRectMake(0, 37, self.sbar.frame.size.width, self.sbar.frame.size.height);
    [self.sbar redrawBar];
    [self.view addSubview:self.sbar];
}

-(void)viewWillAppear:(BOOL) animated
{
    [self.sbar redrawBar];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(requestInsight:) name:@"insightReady" object:nil];
    [super viewWillAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [[self.tabBarController.tabBar.items objectAtIndex:0] setBadgeValue:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"insightReady" object:nil];
    
    //saves stufff
    [[NSUserDefaults standardUserDefaults] setObject:self.answerReadStatus forKey:@"answerReadStatus"];
    [[NSUserDefaults standardUserDefaults] setObject:self.recReadStatus forKey:@"recReadStatus"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    [super viewWillDisappear:animated];
    [Flurry endTimedEvent:@"Profile Time" withParameters:nil];
}

-(void) requestInsight:(NSNotification *) notification
{
    //NSLog(@"Getting called request insight in personal feed");
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    // hit the endpoint
    NSString *path = @"/data/getnewrec/";
    path = [path stringByAppendingString:[defaults objectForKey:@"id"]];
    path = [path stringByAppendingString:@"/"];
    
    [[PaveAPIClient sharedClient] postPath:path parameters:nil success:^(AFHTTPRequestOperation *operation, id results) {
        if (results)
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self createNotificationPopup:[NSDictionary dictionaryWithObjectsAndKeys:[results objectForKey:@"text"] , @"rec_text", [results objectForKey:@"url"], @"url", nil]];
            });
        }
    }
                                   failure: ^(AFHTTPRequestOperation *operation, NSError *error) {
                                       //NSLog(@"Failure while getting rec");
                                   }
     ];
    
}

-(void)createNotificationPopup:(NSDictionary *) data
{
    NotificationPopupView *notificationPopup = [NotificationPopupView notificationPopupCreateWithData:data];
    [self.view addSubview:notificationPopup];
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
        case 0:
            [defaults setInteger:count forKey:@"num_answers"];
            [self.badge_answers setValue: count];
            break;
        case 1:
            [defaults setInteger:count forKey:@"num_recs"];
            [self.badge_recs setValue: count];
            break;
        case 2:
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
    //NSLog(@"Getting called after notif");
    [self viewInsights:self];
}

//to future nithin and neel - sorry for how convulted this code is. tryna submit in an hour, yknow?
- (void)handleTap:(id)sender event:(id)event
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSDictionary *params;
    
    //NSLog(@"Tapped");
    if ([self.currentTable isEqualToString:@"answers"]) {
        UITableView *tableView = self.answers;
        
        NSSet *touches = [event allTouches];
        UITouch *touch = [touches anyObject];
        
        CGPoint currentTouchPosition = [touch locationInView:self.answers];        
        
        NSIndexPath *indexPath = [self.answers indexPathForRowAtPoint: currentTouchPosition];
        [tableView deselectRowAtIndexPath:indexPath animated:NO];
        
        AnswersCell *cell = [tableView cellForRowAtIndexPath:indexPath];
        
        CGPoint pointInCell = [touch locationInView:cell];
        
        NSMutableDictionary *currentObject = [self.answerObjects objectAtIndex:indexPath.row];
        //NSLog(@"Current object is at %d: %@", indexPath.row, currentObject);
        
        NSString *key = [NSString stringWithFormat:@"%@%@%@%@", [NSString stringWithFormat:@"%@", currentObject[@"friend"]], currentObject[@"question"], currentObject[@"chosenProduct"], currentObject[@"otherProduct"], nil];
        
        if (CGRectContainsPoint(cell.agree.frame, pointInCell)) {
            //NSLog(@"In the left image!");
            //checks if this one has been answered yet
            if(![[self.answerReadStatus valueForKey:key] isEqualToString:@"Left"]) //if we haven't given this answer yet
            {
                //saves it as read - true means left
                [self.answerReadStatus setObject:@"Left" forKey:key];
                
                [self displayAnswerAsRead:cell side:@"Left"];
                
                //now saves the cell in the database
                params = [NSDictionary dictionaryWithObjectsAndKeys: [defaults objectForKey:@"id"], @"id_facebookID", [defaults objectForKey:@"id"], @"id_forFacebookId", currentObject[@"chosenProductID"], @"id_chosenProduct", currentObject[@"otherProductID"], @"id_wrongProduct", currentObject[@"questionID"], @"id_question", currentObject[@"friend"], @"in_response_to", nil];
                
                NSString *url = [@"/data/agreewithanswer/" stringByAppendingString:[defaults objectForKey:@"id"]];
                url = [url stringByAppendingString:@"/"];
                
                
                [[PaveAPIClient sharedClient] postPath:url
                                            parameters:params success:^(AFHTTPRequestOperation *operation, id JSON) {
                                                //NSLog(@"successfully agreed with answer");
                                            } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                                //NSLog(@"error agreeing with answer %@", error);
                                            }];

            }            
            else //otherwise, remove the answer
            {
                [self.answerReadStatus removeObjectForKey:key];

                //NSLog(@"Removing the answer");
                [self displayAnswerAsRead:cell side:@""];

                //now saves the cell in the database
                params = [NSDictionary dictionaryWithObjectsAndKeys: [defaults objectForKey:@"id"], @"id_facebookID", [defaults objectForKey:@"id"], @"id_forFacebookId", currentObject[@"chosenProductID"], @"id_chosenProduct", currentObject[@"otherProductID"], @"id_wrongProduct", currentObject[@"questionID"], @"id_question", currentObject[@"friend"], @"in_response_to", @"true", @"removing", nil];
                
                NSString *url = [@"/data/agreewithanswer/" stringByAppendingString:[defaults objectForKey:@"id"]];
                url = [url stringByAppendingString:@"/"];
                
                [[PaveAPIClient sharedClient] postPath:url
                                            parameters:params success:^(AFHTTPRequestOperation *operation, id JSON) {
                                                //NSLog(@"successfully agreed with answer");
                                            } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                                //NSLog(@"error agreeing with answer %@", error);
                                            }];
                
            }
            
        } else if (CGRectContainsPoint(cell.disagree.frame, pointInCell)) {
            //NSLog(@"In the right image!");
            //checks if this one has been answered yet
            if(![[self.answerReadStatus valueForKey:key] isEqualToString:@"Right"]) //if we haven't given this answer yet
            {
                //saves it as read - true means left
                [self.answerReadStatus setObject:@"Right" forKey:key];
                
                [self displayAnswerAsRead:cell side:@"Right"];
                
                //now saves the cell in the database
                params = [NSDictionary dictionaryWithObjectsAndKeys: [defaults objectForKey:@"id"], @"id_facebookID", [defaults objectForKey:@"id"], @"id_forFacebookId", currentObject[@"otherProductID"], @"id_chosenProduct", currentObject[@"chosenProductID"], @"id_wrongProduct", currentObject[@"questionID"], @"id_question", currentObject[@"friend"], @"in_response_to", nil];                                
                
                NSString *url = [@"/data/agreewithanswer/" stringByAppendingString:[defaults objectForKey:@"id"]];
                url = [url stringByAppendingString:@"/"];
                
                
                [[PaveAPIClient sharedClient] postPath:url
                                            parameters:params success:^(AFHTTPRequestOperation *operation, id JSON) {
                                                //NSLog(@"successfully agreed with answer");
                                            } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                                //NSLog(@"error agreeing with answer %@", error);
                                            }];
                
            }
            else //otherwise, remove the answer
            {
                [self.answerReadStatus removeObjectForKey:key];
                
                //NSLog(@"Removing the answer");
                [self displayAnswerAsRead:cell side:@""];
                
                //now saves the cell in the database
                params = [NSDictionary dictionaryWithObjectsAndKeys: [defaults objectForKey:@"id"], @"id_facebookID", [defaults objectForKey:@"id"], @"id_forFacebookId", currentObject[@"otherProductID"], @"id_chosenProduct", currentObject[@"chosenProductID"], @"id_wrongProduct", currentObject[@"questionID"], @"id_question", currentObject[@"friend"], @"in_response_to", @"true", @"removing", nil];
                
                NSString *url = [@"/data/agreewithanswer/" stringByAppendingString:[defaults objectForKey:@"id"]];
                url = [url stringByAppendingString:@"/"];
                
                [[PaveAPIClient sharedClient] postPath:url
                                            parameters:params success:^(AFHTTPRequestOperation *operation, id JSON) {
                                                //NSLog(@"successfully agreed with answer");
                                            } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                                //NSLog(@"error agreeing with answer %@", error);
                                            }];
                
            }
            
        }
        else {
            //NSLog(@"Not in the image...");
        }
    }
    else if ([self.currentTable isEqualToString:@"recs"]) {
        UITableView *tableView = self.recs;
        
        NSSet *touches = [event allTouches];
        UITouch *touch = [touches anyObject];
        
        CGPoint currentTouchPosition = [touch locationInView:self.recs];
        
        NSIndexPath *indexPath = [self.recs indexPathForRowAtPoint: currentTouchPosition];
        [tableView deselectRowAtIndexPath:indexPath animated:NO];
        
        RecsCell *cell = [tableView cellForRowAtIndexPath:indexPath];
        
        CGPoint pointInCell = [touch locationInView:cell];
        
        NSMutableDictionary *currentObject = [self.insightObjects objectAtIndex:indexPath.row];
        //NSLog(@"Current object is at %d: %@", indexPath.row, currentObject);
        
        NSString *key = [NSString stringWithFormat:@"%@", currentObject[@"id"], nil];
        
        if (CGRectContainsPoint(cell.agree.frame, pointInCell)) {
            //NSLog(@"In the left image!");            
            
            if(![[self.recReadStatus valueForKey:key] isEqualToString:@"Left"]) //if we haven't given this answer yet
            {
                //saves it as read - true means left
                [self.recReadStatus setObject:@"Left" forKey:key];
                //NSLog(@"Setting %@ for rec for %d", [self.recReadStatus valueForKey:key], indexPath.row );
                
                [self displayRecAsRead:cell side:@"Left"];
                
                //now saves the cell in the database
                params = [NSDictionary dictionaryWithObjectsAndKeys: currentObject[@"id"], @"rec_id", @"true", @"agree", nil];
                
                NSString *url = [@"/data/agreewithrec/" stringByAppendingString:[defaults objectForKey:@"id"]];
                url = [url stringByAppendingString:@"/"];
                
                
                [[PaveAPIClient sharedClient] postPath:url
                                            parameters:params success:^(AFHTTPRequestOperation *operation, id JSON) {
                                                //NSLog(@"successfully agreed with rec");
                                            } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                                //NSLog(@"error agreeing with rec %@", error);
                                            }];
                
            }
            else //otherwise, remove the answer
            {
                [self.recReadStatus removeObjectForKey:key];
                
                //NSLog(@"Removing the rec");
                //NSLog(@"Setting %@ for rec for %d", [self.recReadStatus valueForKey:key], indexPath.row );
                [self displayRecAsRead:cell side:@""];
                
                //now saves the cell in the database
                params = [NSDictionary dictionaryWithObjectsAndKeys: currentObject[@"id"], @"rec_id", @"true", @"remove", nil];
                
                NSString *url = [@"/data/agreewithrec/" stringByAppendingString:[defaults objectForKey:@"id"]];
                url = [url stringByAppendingString:@"/"];
                
                
                [[PaveAPIClient sharedClient] postPath:url
                                            parameters:params success:^(AFHTTPRequestOperation *operation, id JSON) {
                                                //NSLog(@"successfully removed agree with rec");
                                            } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                                //NSLog(@"error removing agreeing with rec %@", error);
                                            }];
                
            }
            
            
        } else if (CGRectContainsPoint(cell.disagree.frame, pointInCell)) {
            //NSLog(@"In the right image!");
            
            if(![[self.recReadStatus valueForKey:key] isEqualToString:@"Right"]) //if we haven't given this answer yet
            {
                //saves it as read - true means left
                [self.recReadStatus setObject:@"Right" forKey:key];
                
                [self displayRecAsRead:cell side:@"Right"];
                
                //now saves the cell in the database
                params = [NSDictionary dictionaryWithObjectsAndKeys: currentObject[@"id"], @"rec_id", nil];
                
                NSString *url = [@"/data/agreewithrec/" stringByAppendingString:[defaults objectForKey:@"id"]];
                url = [url stringByAppendingString:@"/"];
                
                
                [[PaveAPIClient sharedClient] postPath:url
                                            parameters:params success:^(AFHTTPRequestOperation *operation, id JSON) {
                                                //NSLog(@"successfully agreed with rec");
                                            } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                                //NSLog(@"error agreeing with rec %@", error);
                                            }];
                
            }
            else //otherwise, remove the answer
            {
                [self.recReadStatus removeObjectForKey:key];
                
                //NSLog(@"Removing the rec");
                [self displayRecAsRead:cell side:@""];
                
                //now saves the cell in the database
                params = [NSDictionary dictionaryWithObjectsAndKeys: currentObject[@"id"], @"rec_id", @"true", @"remove", nil];
                
                NSString *url = [@"/data/agreewithrec/" stringByAppendingString:[defaults objectForKey:@"id"]];
                url = [url stringByAppendingString:@"/"];
                
                
                [[PaveAPIClient sharedClient] postPath:url
                                            parameters:params success:^(AFHTTPRequestOperation *operation, id JSON) {
                                                //NSLog(@"successfully removed agree with rec");
                                            } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                                //NSLog(@"error removing agreeing with rec %@", error);
                                            }];
                
            }
        }
        else {
            //NSLog(@"Not in the image...");
        }
    }        
    else if([self.currentTable isEqualToString:@"ugQuestions"]) {
        UITableView *tableView = self.ugQuestions;
       
        //NSLog(@"CLicked in ugquestions");
        
        NSSet *touches = [event allTouches];
        UITouch *touch = [touches anyObject];
        
        CGPoint currentTouchPosition = [touch locationInView:self.ugQuestions];
        
        NSIndexPath *indexPath = [self.ugQuestions indexPathForRowAtPoint: currentTouchPosition];
        [tableView deselectRowAtIndexPath:indexPath animated:NO];
        
        UGQuestionsCell *cell = [tableView cellForRowAtIndexPath:indexPath];
        
        CGPoint pointInCell = [touch locationInView:cell];
        
        NSDictionary *currentObject = [self.questionObjects objectAtIndex:indexPath.row];
        //NSLog(@"Current object is at %d: %@", indexPath.row, currentObject);
        
        if (CGRectContainsPoint(cell.detail.frame, pointInCell)) {
            self.popup = [[AboutUGQuestion alloc] initWithData:currentObject];
            [self.view addSubview:[self.popup view]];            
        }
        else if (CGRectContainsPoint(cell.share.frame, pointInCell)) {
            //share on timeline
           
            AppDelegate* delegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
            FBSession* session = delegate.session;
            
            //NSLog(@"Session in post to fb is %@", session);
            
            // Prepare the native share dialog parameters
            FBShareDialogParams *shareParams = [[FBShareDialogParams alloc] init];
            shareParams.link = [NSURL URLWithString:@"https://itunes.apple.com/us/app/side/id665955920?ls=1&mt=8"];
            shareParams.name = @"Side";
            shareParams.caption= @"Friend-powered recommendations.";
            shareParams.picture= [NSURL URLWithString:@"http://getsideapp.com/icon.png"];
            shareParams.description = [NSString stringWithFormat:@"I just asked \"%@\" on Side. What do you think?", currentObject[@"question_text"]];
            
            /**
            if ([FBDialogs canPresentShareDialogWithParams:shareParams]){
                
                [FBDialogs presentShareDialogWithParams:shareParams
                                            clientState:nil
                                                handler:^(FBAppCall *call, NSDictionary *results, NSError *error) {
                                                    if(error) {
                                                        //NSLog(@"Error publishing story.");
                                                    } else if (results[@"completionGesture"] && [results[@"completionGesture"] isEqualToString:@"cancel"]) {
                                                        //NSLog(@"User canceled story publishing.");
                                                    } else {
                                                        //NSLog(@"Story published.");
                                                    }
                                                }];
                
            }else {
                
                // Prepare the web dialog parameters
                NSDictionary *params = @{
                                         @"name" : shareParams.name,
                                         @"caption" : shareParams.caption,
                                         @"description" : shareParams.description,
                                         @"picture" : @"https://getsideapp.com/icon.png",
                                         @"link" : @"https://itunes.apple.com/us/app/side/id665955920?ls=1&mt=8"
                                         };
                
                // Invoke the dialog
                [FBWebDialogs presentFeedDialogModallyWithSession:nil
                                                       parameters:params
                                                          handler:
                 ^(FBWebDialogResult result, NSURL *resultURL, NSError *error) {
                     if (error) {
                         //NSLog(@"Error publishing story.");
                     } else {
                         if (result == FBWebDialogResultDialogNotCompleted) {
                             //NSLog(@"User canceled story publishing.");
                         } else {
                             //NSLog(@"Story published.");
                         }
                     }}];
            }
             */
            
            // Prepare the web dialog parameters
            NSDictionary *params = @{
                                     @"name" : shareParams.name,
                                     @"caption" : shareParams.caption,
                                     @"description" : shareParams.description,
                                     @"picture" : @"https://getsideapp.com/icon.png",
                                     @"link" : @"https://itunes.apple.com/us/app/side/id665955920?ls=1&mt=8"
                                     };
            
            // Invoke the dialog
            //NSLog(@"Forcing web dialog");
            
            [FBWebDialogs presentFeedDialogModallyWithSession:session
                                                   parameters:params
                                                      handler:
             ^(FBWebDialogResult result, NSURL *resultURL, NSError *error) {
                 if (error) {
                     //NSLog(@"Error publishing story.");
                 } else {
                     if (result == FBWebDialogResultDialogNotCompleted) {
                         //NSLog(@"User canceled story publishing.");
                     } else {
                         //NSLog(@"Story published.");
                     }
                 }}];

            
        }
        
    }
}

- (void) clearOldRequests
{
    
    if([self.currentTable isEqualToString:@"answers"])
    {
        NSString *path = @"/data/getallfeedobjects/";
        path = [path stringByAppendingString:[[NSUserDefaults standardUserDefaults] objectForKey:@"id"]];
        path = [path stringByAppendingString:@"/"];
        
        [[PaveAPIClient sharedClient] cancelAllHTTPOperationsWithMethod:@"POST" path:path];
    }
    else if([self.currentTable isEqualToString:@"ugQuestions"])
    {
        NSString *path = @"/data/getugquestionslist/";
        path = [path stringByAppendingString:[[NSUserDefaults standardUserDefaults] objectForKey:@"id"]];
        path = [path stringByAppendingString:@"/"];
        
        [[PaveAPIClient sharedClient] cancelAllHTTPOperationsWithMethod:@"POST" path:path];
    }
    else if([self.currentTable isEqualToString:@"recs"])
    {
        NSString *path = @"/data/getreclist/";
        path = [path stringByAppendingString:[[NSUserDefaults standardUserDefaults] objectForKey:@"id"]];
        path = [path stringByAppendingString:@"/"];
        
        [[PaveAPIClient sharedClient] cancelAllHTTPOperationsWithMethod:@"POST" path:path];
    }
     
    
}

//logic for switching in the buttons and tables
- (IBAction)viewAnswers:(id)sender
{    
    
    NSString *current_time = [NSString stringWithFormat:@"%.0f",  [[NSDate date] timeIntervalSince1970] * 1000];
    [Flurry logEvent: @"Profile Answers View" withParameters:[NSDictionary dictionaryWithObject:current_time forKey:@"time"]];
    
    self.reloadingFeedObject = YES;
    self.reloadingAnswers = YES;
    [self setBadgeForIndex:0 withCount:0];

    //change the button
    [self.answersButton setImage:[UIImage imageNamed:@"selected_answers_about_me.png"] forState:UIControlStateNormal];
    [self.insightsButton setImage:[UIImage imageNamed:@"1.01_insights_for_me2.png"] forState:UIControlStateNormal];
    [self.questionsButton setImage:[UIImage imageNamed:@"unselected_questions_by_me.png"] forState:UIControlStateNormal];

    [self clearOldRequests];
    
    self.currentTable = @"answers";
    [self changeTable];
}

- (IBAction)viewInsights:(id)sender
{
    NSString *current_time = [NSString stringWithFormat:@"%.0f",  [[NSDate date] timeIntervalSince1970] * 1000];
    [Flurry logEvent: @"Profile Insights View" withParameters:[NSDictionary dictionaryWithObject:current_time forKey:@"time"]];

    self.reloadingFeedObject = YES;
    self.reloadingInsights = YES;
    [self setBadgeForIndex:1 withCount:0];

    //change the button
    [self.answersButton setImage:[UIImage imageNamed:@"unselected_answers_about_me.png"] forState:UIControlStateNormal];
    [self.insightsButton setImage:[UIImage imageNamed:@"selected_insights_for_me.png"] forState:UIControlStateNormal];
    [self.questionsButton setImage:[UIImage imageNamed:@"unselected_questions_by_me.png"] forState:UIControlStateNormal];

    [self clearOldRequests];    
    
    self.currentTable = @"recs";
    //NSLog(@"About to change table");
    [self changeTable];
    //NSLog(@"Changed table");
}

- (IBAction)viewQuestions:(id)sender
{
    NSString *current_time = [NSString stringWithFormat:@"%.0f",  [[NSDate date] timeIntervalSince1970] * 1000];
    [Flurry logEvent: @"Profile Questions View" withParameters:[NSDictionary dictionaryWithObject:current_time forKey:@"time"]];

    self.reloadingFeedObject = YES;
    self.reloadingUGAnswerObjects = YES;
    [self setBadgeForIndex:2 withCount:0];

    //change the button
    [self.answersButton setImage:[UIImage imageNamed:@"unselected_answers_about_me.png"] forState:UIControlStateNormal];
    [self.insightsButton setImage:[UIImage imageNamed:@"1.01_insights_for_me2.png"] forState:UIControlStateNormal];
    [self.questionsButton setImage:[UIImage imageNamed:@"selected_questions_by_me.png"] forState:UIControlStateNormal];
    
    [self clearOldRequests];    
    
    self.currentTable = @"ugQuestions";
    
    //scrolls to the top
    //[self.ugQuestions scrollRectToVisible:CGRectMake(0, 0, 1, 1) animated:YES];
    
    [self changeTable];    
}

//changes the table
- (void) changeTable
//- (IBAction)changeTable:(id)sender
{
    self.reloadingFeedObject = YES;
    if([self.currentTable isEqualToString:@"answers"])
    {        
        //self.currentTable = @"ugQuestions";
        self.answers.hidden = NO;
        self.ugQuestions.hidden = YES;
        self.recs.hidden = YES;
        
        //now reloads the data
        self.feedObjects = [NSArray array];
        self.answerObjects = [NSArray array];
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
        self.questionObjects = [NSArray array];

        [self getFeedObjects];
    }
    else //if recs
    {
        //self.currentTable = @"answers";
        
        self.feedObjects = [NSArray array];
        self.insightObjects = [NSArray array];
        

        self.answers.hidden = YES;
        self.ugQuestions.hidden = YES;
        self.recs.hidden = NO;                

        //now reloads the data        
        [self getFeedObjects];

    }
}

- (void)refresh
{
    self.reloadingFeedObject = YES;
    //NSLog(@"reloading personal datapre");
    //self.feedObjects = [NSArray array];
    //NSLog(@"reloading personal data");
    [self getFeedObjects];
}

- (void)refreshWithPull:(UIRefreshControl *)refreshControl
{
    self.feedObjects = [NSArray array];
    if ([self.currentTable isEqualToString: @"answers"])
    {
        self.reloadingAnswers = YES;
        self.answerObjects =[NSArray array];
    }
    else if ([self.currentTable isEqualToString: @"recs"])
    {
        self.insightObjects = [NSArray array];
        self.reloadingInsights = YES;
    }
    else
    {
        self.questionObjects = [NSArray array];
        self.reloadingUGAnswerObjects = YES;
    }
    //self.reloadingFeedObject = YES;
    
    //NSLog(@"reloading personal datapre");
    
    //NSLog(@"reloading personal data");
    [self getFeedObjectsFromPull];
    
    //[refreshControl endRefreshing];
    
}

- (IBAction)inviteFriends:(id)sender {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSArray *topFriends = [[defaults objectForKey:@"friends"]subarrayWithRange:NSMakeRange(0, 10)];
    
    NSMutableDictionary* params =   [NSMutableDictionary dictionaryWithObjectsAndKeys:
     [topFriends componentsJoinedByString:@","], @"suggestions", nil];
    
    [Flurry logEvent:@"Profile Invite Friends" withParameters:nil timed:YES];
    
    [FBWebDialogs presentRequestsDialogModallyWithSession:nil
      message:[NSString stringWithFormat:@"Download Side to see personal recommendations based on questions your friends are answering about you!"]
        title:nil
   parameters:params
      handler:^(FBWebDialogResult result, NSURL *resultURL, NSError *error) {
          if (error) {
              // Case A: Error launching the dialog or sending request.
              [Flurry endTimedEvent:@"Profile Invite Friends" withParameters:[NSDictionary dictionaryWithObject:@"true" forKey:@"Error"]];
              //NSLog(@"Error sending request.");
          } else {
              if (result == FBWebDialogResultDialogNotCompleted) {
                  // Case B: User clicked the "x" icon
                  [Flurry endTimedEvent:@"Profile Invite Friends" withParameters:[NSDictionary dictionaryWithObject:@"true" forKey:@"Cancelled"]];

                  //NSLog(@"User canceled request.");
              } else {
                  [Flurry endTimedEvent:@"Profile Invite Friends" withParameters:[NSDictionary dictionaryWithObject:@"true" forKey:@"Completed"]];

                  //NSLog(@"Request Sent.");
              }
          }}];

}

// this code doesn't work yet
/**
- (void)tableView:(UITableView *)tableView didEndDisplayingCell:(ProfileObjectCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    //NSLog(@"At row %d with feed objects %d", indexPath.row, [self.feedObjects count]);
    if(indexPath.row != 0 && indexPath.row != ([self.feedObjects count] + 1))
    {
        //NSLog(@"About to cancel cell");
        // free up the requests for each ImageView
        [cell.profilePicture cancelCurrentImageLoad];
        [cell.rightProduct cancelCurrentImageLoad];
        [cell.leftProduct cancelCurrentImageLoad];
    }
     
}
 */

- (IBAction)logout:(id)sender;
{
    //NSLog(@"in logout");
    
    AppDelegate* delegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    FBSession* session = delegate.session;
    
    [session closeAndClearTokenInformation];
    [session close];
    
    //[FBSession setActiveSession:nil];
    //[FBSession.activeSession close];
    //[FBSession.activeSession  closeAndClearTokenInformation];
    
    [self performSegueWithIdentifier:@"profileToLoginScreen" sender:self];
}

-(void) hideLoadingBar
{
    //NSLog(@"Getting called");
    [MBProgressHUD hideHUDForView:self.view animated:YES];
}

- (void) getFeedObjects
{
    [self updateProfileStats];

    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, 0.01 * NSEC_PER_SEC);
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){        
        //starts by hiding and stopping everything
        self.answersLoading.hidden = TRUE;
        [self.answersLoading stopAnimating];
        self.insightsLoading.hidden = TRUE;
        [self.insightsLoading stopAnimating];
        self.questionsLoading.hidden = TRUE;
        [self.questionsLoading stopAnimating];

        if([self.currentTable isEqualToString:@"answers"])
        {
            self.answersLoading.hidden = FALSE;
            [self.answersLoading startAnimating];
            
            //self.answerObjects = [NSMutableArray array];
            //NSLog(@"About to get feed objects for answers");
            
            NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
            NSString *path = @"/data/getallfeedobjects/";
            path = [path stringByAppendingString:[defaults objectForKey:@"profile"][@"facebookId"]];
            //path = [path stringByAppendingString:@"1"];
            path = [path stringByAppendingString:@"/"];
            
            [[PaveAPIClient sharedClient] postPath:path parameters:nil success:^(AFHTTPRequestOperation *operation, id results) {
                if (results) {
                    
                    [self hideLoadingBar];
                    //NSMutableArray *ids = [[NSMutableArray alloc] init];
                    //for(NSDictionary *current in results)
                    //{
                    //    [ids addObject:current[@"id"]];
                    //}
                    //NSLog(@"Just finished getting results: %@", results);
                    //self.answerObjects = [self.answerObjects arrayByAddingObjectsFromArray:results];
                    
                    self.answerObjects = [NSArray arrayWithArray:results];
                    
                    //NSLog(@"Just finished getting feed ids: %@", self.answerObjects);
                    self.doneLoadingFeed = YES;
                    
                    self.reloadingFeedObject = NO;
                    self.reloadingAnswers = NO;
                    
                    [self.answers performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:NO];
                    
                    [self.answersLoading stopAnimating];
                    self.answersLoading.hidden = TRUE;                    
                    
                } }
                                           failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                               [self hideLoadingBar];
                                               if(error.code != -999)
                                               {
                                                   //NSLog(@"error logging in user to Django %@", error);
                                                   self.reloadingFeedObject = NO;
                                                   //shows the alert
                                                   UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error getting feed" message:@"Sorry, there was an error getting your current answers." delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Try Again", nil];
                                                   [alert show];
                                               }
                                           }];
        }
        else if([self.currentTable isEqualToString:@"recs"])
        {
            self.insightObjects = [NSMutableArray array];
            //NSLog(@"About to get feed objects for recs");
            
            NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
            NSString *path = @"/data/getreclist/";
            path = [path stringByAppendingString:[defaults objectForKey:@"profile"][@"facebookId"]];
            //path = [path stringByAppendingString:@"1"];
            path = [path stringByAppendingString:@"/"];
            
            self.insightsLoading.hidden = FALSE;
            [self.insightsLoading startAnimating];
            
            [[PaveAPIClient sharedClient] postPath:path parameters:nil success:^(AFHTTPRequestOperation *operation, id results) {
                if (results) {
                    [self hideLoadingBar];
                    
                    
                    //NSMutableArray *ids = [[NSMutableArray alloc] init];
                    //for(NSDictionary *current in results)
                    //{
                    //    [ids addObject:current[@"id"]];
                    //}
                    ////NSLog(@"Just finished getting results: %@", results);
                    //NSLog(@"Insight Results: %@", results);
                   // self.feedObjects = [self.feedObjects arrayByAddingObjectsFromArray:results];
                    self.insightObjects = [NSArray arrayWithArray: results];
                    //NSLog(@"Just finished getting recs ids: %@", self.insightObjects);
                    
                    self.doneLoadingFeed = YES;
                    
                    self.reloadingFeedObject = NO;
                    self.reloadingInsights = NO;
                    
                    [self.recs performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:NO];
                    
                    self.insightsLoading.hidden = TRUE;
                    [self.insightsLoading stopAnimating];
                    
                } }
                                           failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                               [self hideLoadingBar];
                                               
                                               if(error.code != -999)
                                               {
                                                   //NSLog(@"error logging in user to Django %@", error);
                                                   self.reloadingFeedObject = NO;
                                                   //shows the alert
                                                   UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error getting feed" message:@"Sorry, there was an error getting your current recommendations." delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Try Again", nil];
                                                   [alert show];
                                               }
                                           }];
        }
        else
        {
            //self.questionObjects = [NSMutableArray array];
            //NSLog(@"About to get feed objects for ugquestions");
            
            NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
            NSString *path = @"/data/getugquestionslist/";
            path = [path stringByAppendingString:[defaults objectForKey:@"profile"][@"facebookId"]];
            //path = [path stringByAppendingString:@"1"];
            path = [path stringByAppendingString:@"/"];
            
            self.questionsLoading.hidden = FALSE;
            [self.questionsLoading startAnimating];
            
            [[PaveAPIClient sharedClient] postPath:path parameters:nil success:^(AFHTTPRequestOperation *operation, id results) {
                if (results) {
                    //NSLog(@"Question Results: %@", results);
                    self.questionObjects = [NSArray arrayWithArray:results];
                    self.doneLoadingFeed = YES;
                    
                    self.reloadingFeedObject = NO;
                    self.reloadingUGAnswerObjects = NO;
                    [self.ugQuestions performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:NO];

                    [self hideLoadingBar];

                    //NSMutableArray *ids = [[NSMutableArray alloc] init];
                    //for(NSDictionary *current in results)
                    //{
                    //    [ids addObject:current[@"id"]];
                    //}
                    //NSLog(@"Just finished getting results: %@ for path %@", results, path);
                    //self.feedObjects = [self.feedObjects arrayByAddingObjectsFromArray:results];
                    ////NSLog(@"Just finished getting feed ids: %@", self.feedObjects);
                    
                    self.questionsLoading.hidden = TRUE;
                    [self.questionsLoading stopAnimating];
                    
                } }
                                           failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                               [self hideLoadingBar];

                                               if(error.code != -999)
                                               {
                                                   //NSLog(@"error logging in user to Django %@", error);
                                                   self.reloadingFeedObject = NO;
                                                   //shows the alert
                                                   UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error getting feed" message:@"Sorry, there was an error getting your current questions." delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Try Again", nil];
                                                   [alert show];
                                               }
                                           }];
        }
        
        });
}

- (void) getFeedObjectsFromPull
{
    //turns off feed object
    self.answersLoading.hidden = TRUE;
    [self.answersLoading stopAnimating];
    self.insightsLoading.hidden = TRUE;
    [self.insightsLoading stopAnimating];
    self.questionsLoading.hidden = TRUE;
    [self.questionsLoading stopAnimating];
    
    [self updateProfileStats];
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, 0.01 * NSEC_PER_SEC);
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        
        
        if([self.currentTable isEqualToString:@"answers"])
        {
            //self.answerObjects = [NSMutableArray array];
            //NSLog(@"About to get feed objects for answers via pull");
            
            NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
            NSString *path = @"/data/getallfeedobjects/";
            path = [path stringByAppendingString:[defaults objectForKey:@"profile"][@"facebookId"]];
            //path = [path stringByAppendingString:@"1"];
            path = [path stringByAppendingString:@"/"];
            
            [[PaveAPIClient sharedClient] postPath:path parameters:nil success:^(AFHTTPRequestOperation *operation, id results) {
                if (results) {
                    
                    [self hideLoadingBar];
                    //NSMutableArray *ids = [[NSMutableArray alloc] init];
                    //for(NSDictionary *current in results)
                    //{
                    //    [ids addObject:current[@"id"]];
                    //}
                    //NSLog(@"Just finished getting results: %@", results);
                    //self.answerObjects = [self.answerObjects arrayByAddingObjectsFromArray:results];
                    
                    self.answerObjects = [NSArray arrayWithArray:results];
                    
                    //NSLog(@"Just finished getting feed ids: %@", self.answerObjects);
                    self.doneLoadingFeed = YES;
                    
                    self.reloadingFeedObject = NO;
                    self.reloadingAnswers = NO;
                    
                    
                    [self.answers performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:NO];
                    
                    [self.answersRefreshControl endRefreshing];
                    
                } }
                                           failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                               [self hideLoadingBar];
                                               //NSLog(@"error getting feed objects %@", error);
                                               
                                               if(error.code != -999)
                                               {
                                                   self.reloadingFeedObject = NO;
                                                   //shows the alert
                                                   UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error getting feed" message:@"Sorry, there was an error getting your current answers." delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Try Again", nil];
                                                   [alert show];
                                               }
                                           }];
        }
        else if([self.currentTable isEqualToString:@"recs"])
        {
            self.insightObjects = [NSMutableArray array];
            //NSLog(@"About to get feed objects for recs");
            
            NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
            NSString *path = @"/data/getreclist/";
            path = [path stringByAppendingString:[defaults objectForKey:@"profile"][@"facebookId"]];
            //path = [path stringByAppendingString:@"1"];
            path = [path stringByAppendingString:@"/"];
            
            [[PaveAPIClient sharedClient] postPath:path parameters:nil success:^(AFHTTPRequestOperation *operation, id results) {
                if (results) {
                    [self hideLoadingBar];
                    
                    
                    //NSMutableArray *ids = [[NSMutableArray alloc] init];
                    //for(NSDictionary *current in results)
                    //{
                    //    [ids addObject:current[@"id"]];
                    //}
                    ////NSLog(@"Just finished getting results: %@", results);
                    //NSLog(@"Insight Results: %@", results);
                    // self.feedObjects = [self.feedObjects arrayByAddingObjectsFromArray:results];
                    self.insightObjects = [NSArray arrayWithArray: results];
                    //NSLog(@"Just finished getting recs ids: %@", self.insightObjects);
                    
                    self.doneLoadingFeed = YES;
                    
                    self.reloadingFeedObject = NO;
                    self.reloadingInsights = NO;
                    
                    [self.recs performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:NO];
                    
                    [self.recsRefreshControl endRefreshing];
                    
                } }
                                           failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                               
                                               [self hideLoadingBar];
                                               
                                               if(error.code != -999)
                                               {
                                                   //NSLog(@"error logging in user to Django %@", error);
                                                   self.reloadingFeedObject = NO;
                                                   //shows the alert
                                                   UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error getting feed" message:@"Sorry, there was an error getting your recs." delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Try Again", nil];
                                                   [alert show];
                                               }
                                           }];
        }
        else
        {
            self.questionObjects = [NSMutableArray array];
            //self.questionObjects = [NSMutableArray array];
            //NSLog(@"About to get feed objects for ugquestions");
            
            NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
            NSString *path = @"/data/getugquestionslist/";
            path = [path stringByAppendingString:[defaults objectForKey:@"profile"][@"facebookId"]];
            //path = [path stringByAppendingString:@"1"];
            path = [path stringByAppendingString:@"/"];
            
            [[PaveAPIClient sharedClient] postPath:path parameters:nil success:^(AFHTTPRequestOperation *operation, id results) {
                if (results) {
                    //NSLog(@"Question Results: %@", results);
                    self.questionObjects = [NSArray arrayWithArray:results];
                    self.doneLoadingFeed = YES;
                    
                    self.reloadingFeedObject = NO;
                    self.reloadingUGAnswerObjects = NO;
                    [self.ugQuestions performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:NO];
                    
                    [self hideLoadingBar];
                    
                    //NSMutableArray *ids = [[NSMutableArray alloc] init];
                    //for(NSDictionary *current in results)
                    //{
                    //    [ids addObject:current[@"id"]];
                    //}
                    //NSLog(@"Just finished getting results: %@ for path %@", results, path);
                    //self.feedObjects = [self.feedObjects arrayByAddingObjectsFromArray:results];
                    ////NSLog(@"Just finished getting feed ids: %@", self.feedObjects);
                    [self.ugRefreshControl endRefreshing];
                    
                } }
                                           failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                               [self hideLoadingBar];
                                               
                                               if(error.code != -999)
                                               {
                                                   //NSLog(@"error logging in user to Django %@", error);
                                                   self.reloadingFeedObject = NO;
                                                   //shows the alert
                                                   UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error getting feed" message:@"Sorry, there was an error getting your questions." delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Try Again", nil];
                                                   [alert show];
                                               }
                                           }];
        }
        
    });
}

//alert messages
//This medthod Controls the actions that the UIAlertView's buttons carry out
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if(buttonIndex == 0) {
        [self.refreshControl endRefreshing];
        
        self.insightsLoading.hidden = TRUE;
        [self.insightsLoading stopAnimating];
        self.answersLoading.hidden = TRUE;
        [self.answersLoading stopAnimating];
        self.questionsLoading.hidden = TRUE;
        [self.questionsLoading stopAnimating];
    }
    if (buttonIndex == 1){
        [self.refreshControl beginRefreshing];
        [self getFeedObjectsFromPull];
    }
}

- (void)viewDidAppear:(BOOL)animated
{
    //removes the badge
    UITabBar *tabBar = (UITabBar *)self.tabBarController.tabBar;
    
    [[tabBar.items objectAtIndex:0] setBadgeValue:nil];
    
    [self changeTable];
    
    [super viewDidAppear:animated];
    [Flurry logEvent:@"Profile Time" withParameters:nil timed:YES];
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
    NSInteger num;
    if(tableView == self.answers)
    {
        num =  self.answerObjects.count + 1;
    }
    else if(tableView == self.recs)
    {
        num =  self.insightObjects.count + 1;
    }
    else
    {
        num = self.questionObjects.count + 1;
    }
    //NSLog(@"Number of cells: %d", num);

    return num;
}

- (AnswersCell *) displayAnswerAsRead:(AnswersCell *) cell side:(NSString *) side
{
    if([side isEqualToString:@"Left"])
    {
        [cell.agree setImage:[UIImage imageNamed:@"SELECTED_BIG_AGREE_BUTTON.png"] forState:UIControlStateNormal];
        [cell.disagree setImage:[UIImage imageNamed:@"aboutyouBIG_DISAGREE_BUTTON.png"] forState:UIControlStateNormal];
    }
    else if([side isEqualToString:@"Right"])
    {
        [cell.agree setImage:[UIImage imageNamed:@"aboutyouBIG_AGREE_BUTTON.png"] forState:UIControlStateNormal];
        [cell.disagree setImage:[UIImage imageNamed:@"SELECTED_BIG_DISAGREE_BUTTON.png"] forState:UIControlStateNormal];
    }
    else 
    {
        [cell.agree setImage:[UIImage imageNamed:@"aboutyouBIG_AGREE_BUTTON.png"] forState:UIControlStateNormal];
        [cell.disagree setImage:[UIImage imageNamed:@"aboutyouBIG_DISAGREE_BUTTON.png"] forState:UIControlStateNormal];
    }
    return cell;
}

- (RecsCell *) displayRecAsRead:(RecsCell *) cell side:(NSString *) side
{
    if([side isEqualToString:@"Left"])
    {
        [cell.agree setImage:[UIImage imageNamed:@"SELECTED_BIG_AGREE_BUTTON.png"] forState:UIControlStateNormal];
        [cell.disagree setImage:[UIImage imageNamed:@"aboutyouBIG_DISAGREE_BUTTON.png"] forState:UIControlStateNormal];
    }
    else if([side isEqualToString:@"Right"])
    {
        [cell.agree setImage:[UIImage imageNamed:@"aboutyouBIG_AGREE_BUTTON.png"] forState:UIControlStateNormal];
        [cell.disagree setImage:[UIImage imageNamed:@"SELECTED_BIG_DISAGREE_BUTTON.png"] forState:UIControlStateNormal];
    }
    else
    {
        [cell.agree setImage:[UIImage imageNamed:@"aboutyouBIG_AGREE_BUTTON.png"] forState:UIControlStateNormal];
        [cell.disagree setImage:[UIImage imageNamed:@"aboutyouBIG_DISAGREE_BUTTON.png"] forState:UIControlStateNormal];
    }
    return cell;
}


-(void) updateProfileStats
{
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    if ([defaults valueForKey:@"profile_answer_count"]!= nil)
    {
        if (self.votesTextField.text != [defaults objectForKey:@"profile_vote_count"])
            self.votesTextField.text = [defaults objectForKey:@"profile_vote_count"];
        
        if (self.answersTextField.text != [defaults objectForKey:@"profile_answer_count"])
            self.answersTextField.text = [defaults objectForKey:@"profile_answer_count"];
        
        if (self.questionsTextField.text != [defaults objectForKey:@"profile_question_count"])
            self.questionsTextField.text = [defaults objectForKey:@"profile_question_count"];
        
        if (self.levelTextField.text != [@"level " stringByAppendingString:[defaults objectForKey:@"level"]])
            self.levelTextField.text = [@"level " stringByAppendingString:[defaults objectForKey:@"level"]];
    }
    

    NSString *path = @"/data/getprofilestats/";
    path = [path stringByAppendingString:[defaults objectForKey:@"profile"][@"facebookId"]];
    path = [path stringByAppendingString:@"/"];
    //NSLog(@"updateProfileStats");
    [[PaveAPIClient sharedClient] postPath:path parameters:nil
                                   success:^(AFHTTPRequestOperation *operation, id results) {
        if (results) {
            NSString *answer_count = [[results objectForKey:@"answer_count"] stringValue];
            NSString *ug_question_count = [[results objectForKey:@"ug_question_count"] stringValue];
            NSString *vote_count = [[results objectForKey:@"vote_count"] stringValue];
            NSString *level = [[results objectForKey: @"level" ]  stringValue];
            if (self.votesTextField.text != vote_count)
                self.votesTextField.text = vote_count;
            
            if(self.answersTextField.text != answer_count)
                self.answersTextField.text = answer_count;
            
            if (self.questionsTextField.text != ug_question_count)
                self.questionsTextField.text = ug_question_count;
            
            NSString *levelText =[@"level " stringByAppendingString:level];
            if (self.levelTextField.text != levelText)
                self.levelTextField.text = [@"level " stringByAppendingString:level];
            
            [defaults setObject:answer_count forKey:@"profile_answer_count"];
            [defaults setObject:ug_question_count forKey:@"profile_ug_answer_count"];
            [defaults setObject:vote_count forKey:@"profile_vote_count"];
            [defaults setObject:level forKey:@"level"];
            [defaults synchronize];            
        }
    }
     
        failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                       //NSLog(@"error while updating profile stats: %@", error);
        }];
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(self.reloadingFeedObject)
    {
        //NSLog(@"Still reloading WHAT'S UP");
        /*UITableView *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"InviteFriends"];
        return cell; */
        
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
        //otherwise if it's a footer
        if(indexPath.row == 14142) //self.feedObjects.count
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
                if (self.reloadingAnswers || indexPath.row == self.answerObjects.count)
                {
                    //NSLog(@"Putting something in for bototm cell");
                    
                    static NSString *CellIdentifier = @"AnswersCell";
                    AnswersCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
                    if (!cell) {
                        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
                        // More initializations if needed.
                    }
                    
                    
                    
                    cell.question.hidden = NO;                                                          
                    
                    cell.question.text = @"OH hey, at bottom";
                    return cell;
                }
                                

                static NSString *CellIdentifier = @"AnswersCell";
                AnswersCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
                
                //unhides everything
                for (UIView *view in [cell subviews]) {
                    view.hidden = NO;
                }
                
                //NSLog(@"IndexPath is %d", indexPath.row);
                //NSDictionary *currentObject = [self.feedObjects objectAtIndex:(indexPath.row)];
                NSDictionary *currentObject = [self.answerObjects objectAtIndex:(indexPath.row)];
                NSString *newtext = currentObject[@"question"];                
                
                //sets the background
                cell.backgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"about_you_background.png"]];
                
                cell.question.text = newtext;
                
                if(currentObject[@"name"])
                {
                    cell.name.text = [NSString stringWithFormat:@"%@ answered:", currentObject[@"name"]];
                }
                else
                {
                    cell.name.text = [NSString stringWithFormat:@"%@ answered:", @"Your friend"];
                }
                
                //now downloads and saves the images
                NSString *currentID = [NSString stringWithFormat:@"%@", currentObject[@"friend"]];
                //NSString *currentID = @"4";

                SDImageCache *imageCache = [SDImageCache sharedImageCache];
                
                //clears the old downloads first
                [cell.profilePicture cancelCurrentImageLoad];
                [cell.leftProduct cancelCurrentImageLoad];
                [cell.rightProduct cancelCurrentImageLoad];
                
                //for profile picture
                cell.profilePicture.image = [UIImage imageNamed:@"profile_icon.png"];
                NSString *profileURL = @"https://graph.facebook.com/";
                profileURL = [profileURL stringByAppendingString:currentID ];
                profileURL = [profileURL stringByAppendingString:@"/picture?type=normal"];
                
                /**
                [imageCache queryDiskCacheForKey:profileURL done:^(UIImage *image, SDImageCacheType cacheType)
                {
                     //if it's not there
                     if(image==nil)
                     {
                         [SDWebImageDownloader.sharedDownloader downloadImageWithURL:[NSURL URLWithString:profileURL] options:0 progress:^(NSUInteger receivedSize, long long expectedSize)
                          {
                              // progression tracking code
                              ////NSLog(@"At progress point %u out of %lld", receivedSize, expectedSize);
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
                 */
                [cell.profilePicture setImageWithURL:[NSURL URLWithString:profileURL]
                                 placeholderImage:[UIImage imageNamed:@"profile_icon.png"]];

                cell.profilePicture.clipsToBounds = YES;
                
                //for left product picture
                // instantiate them
                cell.leftProduct.image = [UIImage imageNamed:@"profile_icon.png"];
                
                NSString *leftImageURL = currentObject[@"chosenProduct"];
                /**NSString *leftImageURL = @"https://s3.amazonaws.com/pave_product_images/";
                leftImageURL = [leftImageURL stringByAppendingString:currentObject[@"chosenProduct"]];
                leftImageURL = [leftImageURL stringByReplacingOccurrencesOfString:@"+" withString:@"%2b"];
                leftImageURL = [leftImageURL stringByReplacingOccurrencesOfString:@" " withString:@"+"];
                 */
                
                /**
                [imageCache queryDiskCacheForKey:leftImageURL done:^(UIImage *image, SDImageCacheType cacheType)
                 {
                     //if it's not there
                     if(image==nil)
                     {
                         [SDWebImageDownloader.sharedDownloader downloadImageWithURL:[NSURL URLWithString:leftImageURL] options:0 progress:^(NSUInteger receivedSize, long long expectedSize)
                          {
                              // progression tracking code
                              // //NSLog(@"At progress point %u out of %lld", receivedSize, expectedSize);
                          }
                                                                           completed:^(UIImage *image, NSData *data, NSError *error, BOOL finished)
                          {
                              if (image && finished)
                              {
                                  // do something with image
                                  //NSLog(@"Finished getting left product image");
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
                 */
                
                [cell.leftProduct setImageWithURL:[NSURL URLWithString:leftImageURL]
                                 placeholderImage:[UIImage imageNamed:@"profile_icon.png"]];
                
                cell.leftProduct.clipsToBounds = YES;
                
                //for right product picture
                cell.rightProduct.image = [UIImage imageNamed:@"profile_icon.png"];
                
                NSString *rightImageURL = currentObject[@"otherProduct"];
                /**
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
                              ////NSLog(@"At progress point %u out of %lld", receivedSize, expectedSize);
                          }
                                                                           completed:^(UIImage *image, NSData *data, NSError *error, BOOL finished)
                          {
                              if (image && finished)
                              {
                                  // do something with image
                                  //NSLog(@"Finished getting image");
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
                 */
                
                [cell.rightProduct setImageWithURL:[NSURL URLWithString:rightImageURL]
                                 placeholderImage:[UIImage imageNamed:@"profile_icon.png"]];
                
                cell.rightProduct.clipsToBounds = YES;
                
                //checks if we've agreed or disagreed with this product before
                //key is in the format of friend, question, answer1, answer2
                NSString *key = [NSString stringWithFormat:@"%@%@%@%@", currentID, newtext, currentObject[@"chosenProduct"], currentObject[@"otherProduct"], nil];
                
                //adds tap listener
                [cell.agree addTarget:self action:@selector(handleTap:event:) forControlEvents:UIControlEventTouchUpInside];
                
                [cell.disagree addTarget:self action:@selector(handleTap:event:) forControlEvents:UIControlEventTouchUpInside];
                
                //resets the buttons
                [cell.agree setImage:[UIImage imageNamed:@"aboutyouBIG_AGREE_BUTTON.png"] forState:UIControlStateNormal];
                [cell.disagree setImage:[UIImage imageNamed:@"aboutyouBIG_DISAGREE_BUTTON.png"] forState:UIControlStateNormal];
                
                if([self.answerReadStatus objectForKey:key])
                {
                    //NSLog(@"Was read at position %d", indexPath.row);
                    return [ self displayAnswerAsRead:cell side:[self.answerReadStatus objectForKey:key]];
                }
                else
                {
                    return cell;
                }
                
                

            }
            else if(tableView == self.recs) //if it's a rec
            {
                if (self.reloadingInsights || indexPath.row == self.insightObjects.count)
                {
                    static NSString *CellIdentifier = @"InviteFriends";
                    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
                    if (!cell) {
                        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
                        // More initializations if needed.
                    }
                    return cell;
                }

                //NSLog(@"Getting insight");
                static NSString *CellIdentifier = @"RecsCell";
                //static NSString *CellIdentifier = @"UGQuestionsCell";
                RecsCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
                
                //NSLog(@"IndexPath is %d", indexPath.row);
                NSDictionary *currentObject = [self.insightObjects objectAtIndex:(indexPath.row)];
                
                NSString *newtext = currentObject[@"text"];
                
                //sets the background
                cell.backgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"profile_insight_background.png"]];
                
                cell.text.text = newtext;
                cell.level.text = [NSString stringWithFormat:@"level %@", currentObject[@"level"] ];
                
                //now downloads and saves the images
                
                SDImageCache *imageCache = [SDImageCache sharedImageCache];
                
                //for image
                // instantiate them
                cell.image.image = [UIImage imageNamed:@"profile_icon.png"];
                NSString *leftImageURL = currentObject[@"url"];                
                
                [imageCache queryDiskCacheForKey:leftImageURL done:^(UIImage *image, SDImageCacheType cacheType)
                 {
                     //if it's not there
                     if(image==nil)
                     {
                         [SDWebImageDownloader.sharedDownloader downloadImageWithURL:[NSURL URLWithString:leftImageURL] options:0 progress:^(NSUInteger receivedSize, long long expectedSize)
                          {
                              // progression tracking code
                              // //NSLog(@"At progress point %u out of %lld", receivedSize, expectedSize);
                          }
                                                                           completed:^(UIImage *image, NSData *data, NSError *error, BOOL finished)
                          {
                              if (image && finished)
                              {
                                  // do something with image
                                  //NSLog(@"Finished getting left product image");
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
                
                //adds tap listener
                [cell.agree addTarget:self action:@selector(handleTap:event:) forControlEvents:UIControlEventTouchUpInside];
                
                [cell.disagree addTarget:self action:@selector(handleTap:event:) forControlEvents:UIControlEventTouchUpInside];
                
                //resets the buttons
                [cell.agree setImage:[UIImage imageNamed:@"aboutyouBIG_AGREE_BUTTON.png"] forState:UIControlStateNormal];
                [cell.disagree setImage:[UIImage imageNamed:@"aboutyouBIG_DISAGREE_BUTTON.png"] forState:UIControlStateNormal];
                
                NSString *key = [NSString stringWithFormat:@"%@", currentObject[@"id"], nil];
                
                if([self.recReadStatus objectForKey:key])
                {
                    //NSLog(@"Was read at position %d", indexPath.row);
                    //NSLog(@"Displaying rec as '%@'", [self.recReadStatus objectForKey:key]);
                    return [ self displayRecAsRead:cell side:[self.recReadStatus objectForKey:key]];
                }
                else
                {
                    return cell;
                }
                                        
                return cell;
            }
            else //if it's a UGAnswer
            {
                if (self.reloadingUGAnswerObjects || indexPath.row == self.questionObjects.count)
                {
                    static NSString *CellIdentifier = @"InviteFriends";
                    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
                    if (!cell) {
                        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
                        // More initializations if needed.
                    }
                    return cell;
                }
                
                static NSString *CellIdentifier = @"UGQuestionsCell";
                UGQuestionsCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
                //NSLog(@"IndexPath is %d", indexPath.row);
                //NSLog(@"Question objects is: %@", self.questionObjects);
                NSDictionary *currentObject = [self.questionObjects objectAtIndex:(indexPath.row)];
                
                NSString *newtext = currentObject[@"question_text"];
                
                //sets the background
                cell.backgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"UGC_profile_background.png"]];
                
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
                              // //NSLog(@"At progress point %u out of %lld", receivedSize, expectedSize);
                          }
                                                                           completed:^(UIImage *image, NSData *data, NSError *error, BOOL finished)
                          {
                              if (image && finished)
                              {
                                  // do something with image
                                  //NSLog(@"Finished getting left product image");
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
                              ////NSLog(@"At progress point %u out of %lld", receivedSize, expectedSize);
                          }
                                                                           completed:^(UIImage *image, NSData *data, NSError *error, BOOL finished)
                          {
                              if (image && finished)
                              {
                                  // do something with image
                                  //NSLog(@"Finished getting image");
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
                
                //shows and hides the labels depending on count
                if([currentObject[@"product_1_count"] integerValue]== 0 && [currentObject[@"product_2_count"] integerValue]== 0)
                {
                    //NSLog(@"Hiding");
                    cell.leftDetail.hidden = YES;
                    cell.rightDetail.hidden = YES;
                    cell.leftNumber.hidden = YES;
                    cell.rightNumber.hidden = YES;                                        
                }
                else
                {
                    cell.leftDetail.hidden = NO;
                    cell.rightDetail.hidden = NO;
                    cell.leftNumber.hidden = NO;
                    cell.rightNumber.hidden = NO;
                    
                    cell.leftNumber.text = [currentObject[@"product_1_count"] stringValue];
                    cell.rightNumber.text = [currentObject[@"product_2_count"] stringValue];
                    
                }
                
                
                //shows the tie case if necessary
                if([currentObject[@"product_1_count"] integerValue]== [currentObject[@"product_2_count"] integerValue])
                {
                    [cell.rightDetail setImage:[UIImage imageNamed: @"GREEN_COUNT_UGC_BUTTON.png"]];
                }
                else
                {
                    [cell.rightDetail setImage:[UIImage imageNamed: @"RED_COUNT_UGC_BUTTON.png"]];
                }
                
                //touch listener
                [cell.detail addTarget:self action:@selector(handleTap:event:) forControlEvents:UIControlEventTouchUpInside];
                [cell.share addTarget:self action:@selector(handleTap:event:) forControlEvents:UIControlEventTouchUpInside];
                
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
    
}

- (void)tableView:(UITableView *)tableView didEndDisplayingCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{    
    //NSLog(@"About to cancel cell");
    // free up the requests for each ImageView    
    if(tableView == self.answers) //if it's a rec
    {
        AnswersCell *current = (AnswersCell *)cell;
        @try{
            [current.profilePicture cancelCurrentImageLoad];
            [current.leftProduct cancelCurrentImageLoad];
            [current.rightProduct cancelCurrentImageLoad];
            //NSLog(@"Cancelled AnswersCell for %d", indexPath.row);
        }
        @catch (NSException * e) {
            //NSLog(@"Got an exception: %@", e);
        }
    }
    else if(tableView == self.recs) //if it's a rec
    {
        RecsCell *current = (RecsCell *)cell;
        @try{
            [current.image cancelCurrentImageLoad];
            //NSLog(@"Cancelled RecsCell for %d", indexPath.row);            
        }
        @catch (NSException * e) {
            //NSLog(@"Got an exception: %@", e);
        }
    }
    else if(tableView == self.ugQuestions) //if it's a rec
    {
        UGQuestionsCell *current = (UGQuestionsCell *)cell;
        @try{
            [current.leftProduct cancelCurrentImageLoad];
            [current.rightProduct cancelCurrentImageLoad];
            //NSLog(@"Cancelled UGQuestionsCell for %d", indexPath.row);            
        }
        @catch (NSException * e) {
            //NSLog(@"Got an exception: %@", e);
        }
    }
}

@end