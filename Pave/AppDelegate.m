//
//  AppDelegate.m
//  Pave
//
//  Created by Neel Patel on 6/18/13.
//  Copyright (c) 2013 Pave. All rights reserved.
//

#import "AppDelegate.h"
#import "PaveAPIClient.h"
#import <FacebookSDK/FacebookSDK.h>
#import "Flurry.h"
#import "UAirship.h"
#import "UAConfig.h"
#import "UAPush.h"
#import "PersonalFeedController.h"
#import "GameController.h"

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // flurry analytics 
    [Flurry startSession: @"N49JNZBNHFZ6PJ4Y9PSM"];
    
    UAConfig *config = [UAConfig defaultConfig];
    [UAirship takeOff:config];
    
    [self updatePushNotifiactionAlias];
    
    [[UAPush shared] setAutobadgeEnabled:YES];
    [[UAPush shared] resetBadge];

    
    if (launchOptions != nil)
    {
        NSDictionary *tmpDic = [launchOptions objectForKey:UIApplicationLaunchOptionsRemoteNotificationKey];
        //NSLog(@"Notification: %@", tmpDic);
        [self handleNotification:tmpDic];
    }
    
    self.inGroup = NO;
    
    //self.didCompleteProfileInformation = YES;
    // Assign tab bar item with titles
    UITabBarController *tabBarController = (UITabBarController *)self.window.rootViewController;
    UITabBar *tabBar = tabBarController.tabBar;
    UITabBarItem *tabBarItem1 = [tabBar.items objectAtIndex:0];
    UITabBarItem *tabBarItem2 = [tabBar.items objectAtIndex:1];
    UITabBarItem *tabBarItem3 = [tabBar.items objectAtIndex:2];
    UITabBarItem *tabBarItem4 = [tabBar.items objectAtIndex:3];
    UITabBarItem *tabBarItem5 = [tabBar.items objectAtIndex:4];
    
    [tabBarItem1 setFinishedSelectedImage:[UIImage imageNamed:@"final_profile_selected.png"] withFinishedUnselectedImage:[UIImage imageNamed:@"final_profile_unselected.png.png"]];
    [tabBarItem2 setFinishedSelectedImage:[UIImage imageNamed:@"final_groups_selected.png"] withFinishedUnselectedImage:[UIImage imageNamed:@"final_groups_unselected.png"]];
    [tabBarItem3 setFinishedSelectedImage:[UIImage imageNamed:@"final_home_selected.png"] withFinishedUnselectedImage:[UIImage imageNamed:@"final_home_unselected.png"]];
    [tabBarItem4 setFinishedSelectedImage:[UIImage imageNamed:@"final_UGC_selected.png"] withFinishedUnselectedImage:[UIImage imageNamed:@"final_UGC_unselected.png"]];
    [tabBarItem5 setFinishedSelectedImage:[UIImage imageNamed:@"final_sprint_selected.png"] withFinishedUnselectedImage:[UIImage imageNamed:@"final_sprint_unselected.png"]];
            
    //[[UITabBar appearance] setBackgroundImage:tabBarBackground];
    //gets rid of translucent
    [[UITabBar appearance] setBackgroundImage:[[UIImage alloc] init]];
    [[UITabBar appearance] setSelectionIndicatorImage:[[UIImage alloc] init]];
    
    tabBarItem1.title = @"";
    tabBarItem2.title = @"";
    tabBarItem3.title = @"";
    tabBarItem4.title = @"";
    tabBarItem5.title = @"";
    
    tabBarItem1.imageInsets = UIEdgeInsetsMake(0, 0, 0, 0);
    tabBarItem2.imageInsets = UIEdgeInsetsMake(0, 0, 0, 0);
    tabBarItem3.imageInsets = UIEdgeInsetsMake(0, 0, 0, 0);
    tabBarItem4.imageInsets = UIEdgeInsetsMake(0, 0, 0, 0);
    tabBarItem5.imageInsets = UIEdgeInsetsMake(0, 0, 0, 0);
    tabBarController.selectedIndex = 2;
    
    self.tabBarController = tabBarController;

    // log all page views on the tab bar 
    [Flurry logAllPageViews:self.tabBarController];
    // FB Login
    NSArray *permissionsArray = @[ @"email", @"user_likes", @"user_interests", @"user_about_me", @"user_birthday", @"friends_about_me", @"friends_interests", @"read_stream"];
    
    self.session = [[FBSession alloc] initWithAppID:@"545929018807731" permissions:permissionsArray defaultAudience:nil urlSchemeSuffix:@"app" tokenCacheStrategy:nil];
    
    //timer to check for notifications
    NSTimer* myTimer = [NSTimer scheduledTimerWithTimeInterval: 30.0 target: self
                                                      selector: @selector(refreshNotifications:) userInfo: nil repeats: YES];
    
    // read in the current status score from NSUserDefaults
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    self.currentStatusScore = [defaults integerForKey: @"status_score"];
    if (!self.currentStatusScore)
        self.currentStatusScore = 0;
    
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"HasLaunchedOnce"])
    {
        // dummy variable so we don't have an error
        self.firstLaunch = NO;
    }
    else
    {
        [Flurry logEvent:@"New User"];
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"HasLaunchedOnce"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        self.firstLaunch = YES;
    }

    
    self.notificationPopupIsOpen = NO;
    
    ////NSLog(@"APP DELEGATE: %d", self.currentStatusScore);
    
    // Override point for customization after application launch.
    
    ////NSLog(@"About to switch to group");
    //[self switchToProfileWithActive:@"questions"];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(nowInGroup) name:@"enteringGroup" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(leavingGroup) name:@"leavingGroup" object:nil];
    return YES;
    
}

-(BOOL)updatePushNotifiactionAlias
{
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *userID = [defaults objectForKey:@"id"];
    if (userID)
    {
        //NSLog(@"In user id block: %@", userID);
        [UAPush shared].alias = userID;
        //NSLog(@"UA Push alias: %@", [UAPush shared].alias);
        [[UAPush shared] updateRegistration];
        return YES;
    }
    else
    {
        return NO;
    }
}

-(void)switchToGameFeed
{
    [self.tabBarController setSelectedIndex:2];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"getFeedObjects" object:nil];
}

-(void)switchToGroups
{
    [self.tabBarController setSelectedIndex:1];
}

-(void)switchToProfileWithActive: (NSString*) activeTab
{
    PersonalFeedController *profileController = [self.tabBarController.viewControllers objectAtIndex:0];
    [self.tabBarController setSelectedViewController: profileController];
    if ([activeTab isEqualToString:@"insights"])
    {
        [profileController viewInsights:self];
    }
    else if ([activeTab isEqualToString:@"questions"])
    {
        [profileController viewQuestions:self];
    }
    else
    {
        // active tab is "answers"
        [profileController viewAnswers:self];
    }
}

-(void)switchToTraining
{
    [self.tabBarController setSelectedIndex:4];
}

-(void)switchToAsk
{
    [self.tabBarController setSelectedIndex:3];
}

-(void) refreshNotifications:(NSTimer*) t
{
    //if we're logged in
    if(self.session.state == FBSessionStateOpen)
    {
        UITabBarItem *item = [self.tabBarController.tabBar.items objectAtIndex:0];
        NSString *oldvalue = item.badgeValue;

        int seconds = (int)[[NSDate date] timeIntervalSince1970];
        
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
                
        
        //either checks the last time that we polled the server, or polls based on that previous time. then stores the current value
        int polltime = 0;
        if([defaults integerForKey:@"lastpolled"] != nil)
        {
            ////NSLog(@"(old time was %d", [defaults integerForKey:@"lastpolled"]);
            polltime = [defaults integerForKey:@"lastpolled"];
            
        }
        ////NSLog(@"Trying to get the polls");
        
        // checks if the the user is first timer         
        NSString *path = @"/data/getnotification/";
        path = [path stringByAppendingString:[defaults objectForKey:@"id"]];
        
        path = [path stringByAppendingString:@"/"];
        
        ////NSLog(@"Path is %@", path);
        
        [[PaveAPIClient sharedClient] postPath:path parameters:nil success:^(AFHTTPRequestOperation *operation, id results) {
                if (results) {
                    //NSLog(@"Results %@", results);
                    NSInteger new_inc = [[results objectForKey:@"recs"] intValue] + [[results objectForKey:@"answers"] intValue] + [[results objectForKey:@"ug_answers"] intValue];
                    ////NSLog(@"%d", new_inc);
                    
                    NSInteger status_score = [[results objectForKey:@"status_score"] intValue];
                    if (!status_score)
                    {
                        //NSLog(@"Status score is null");
                        status_score = 0;
                    }
                    
                    if (self.currentStatusScore != status_score)
                    {
                        ////NSLog(@"ABOUT TO UPDATE STATUS SCORE");
                        self.currentStatusScore = status_score;
                        NSDictionary *data = [NSDictionary dictionaryWithObjectsAndKeys: @(status_score), @"status_score", nil];

                        if (!self.inGroup)
                            [[NSNotificationCenter defaultCenter] postNotificationName:@"refreshStatusScore" object:nil userInfo: data];
                    }
                    
                    // broadcast notification to everyone
                    if ((self.currentStatusScore >= 100) && (!self.notificationPopupIsOpen) && (!self.inGroup))
                    {
                        //NSLog(@"Notification is coming up!");
                        self.notificationPopupIsOpen = YES;
                        [self performSelector:@selector(sendInsightReady) withObject:nil afterDelay:0.5];
                    } else
                    {
                        //NSLog(@"Notification is not ready");
                    }
                    
                    NSInteger old_recs = [defaults integerForKey:@"num_recs"];
                    if (!old_recs)
                        old_recs = 0;
                    NSInteger old_answers = [defaults integerForKey:@"num_answers"];
                    if (!old_answers)
                        old_answers = 0;
                    NSInteger old_ug_answers = [defaults integerForKey:@"num_ug_answers"];
                    if (!old_ug_answers)
                        old_ug_answers = 0;
                    
                    // set the status score and the rest of the properties
                    [defaults setInteger: status_score forKey:@"status_score"];
                    
                    NSInteger new_recs = [[results objectForKey:@"recs"] intValue] + old_recs;
                    [defaults setInteger: new_recs forKey:@"num_recs"];
                    
                    NSInteger new_answer = [[results objectForKey:@"answers"] intValue] + old_answers;
                    [defaults setInteger:new_answer forKey:@"num_answers"];
                    
                    NSInteger new_ug_answer = [[results objectForKey:@"ug_answers"] intValue] + old_ug_answers;
                    [defaults setInteger:new_ug_answer forKey:@"num_ug_answers"];
                    
                    [defaults synchronize];
                    
                    ////NSLog(@"Numbers: %d, %d, %d, %d", old_recs, old_answers, old_ug_answers, status_score);
                    //NSLog(@"New Numbers: %d, %d, %d, %d", new_recs, new_answer, new_ug_answer, status_score);
                    
                    //[defaults setObject:[results objectForKey:@"answers"] forKey:@"num_answers"];
                    //[defaults setObject:[results objectForKey:@"ug_answers"] forKey:@"num_ug_answers"];
                    
                    if(new_inc != 0)
                    {
                        ////NSLog(@"Incremented by %d!", new_inc);
                        [[self.tabBarController.tabBar.items objectAtIndex:0] setBadgeValue:[self incrementString:oldvalue : new_inc]];
                    }
                    //changes the old value
                    [defaults setInteger:[[results objectForKey:@"last"] intValue] forKey:@"lastpolled"];
                    [[NSNotificationCenter defaultCenter] postNotificationName:@"updateProfileBadgeCounts" object:nil userInfo:nil];
                    //[self performSelector:@() withObject:nil afterDelay:0.5];
                }
            }
            failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                ////NSLog(@"error getting notifications from database %@", error);
            }];    
    }
}

-(void)nowInGroup
{
    //NSLog(@"now in group");
    self.inGroup = YES;
}
-(void)leavingGroup
{
    //NSLog(@"Leaving group");
    self.inGroup = NO;
}

-(void) handleNotification:(NSDictionary *) notification
{
    //NSLog(@"Trying to handle notification: ");
    NSString *action = [[notification objectForKey:@"data"] objectForKey:@"action"];
    if ([action isEqualToString:@"switchToGroups"])
    {
        [self switchToGroups];
    }
    else if ([action isEqualToString:@"switchToAnswers"])
    {
        [self switchToProfileWithActive: @"answers"];
    }
    else if ([action isEqualToString:@"switchToQuestions"])
    {
        [self switchToProfileWithActive:@"questions"];
    }
    else if ([action isEqualToString:@"switchToInsights"])
    {
        [self switchToProfileWithActive:@"insights"];
    }
    else if ([action isEqualToString:@"switchToSprint"])
    {
        [self switchToTraining];
    }
    else if ([action isEqualToString:@"switchToAsk"])
    {
        [self switchToAsk];
    }
    else if ([action isEqualToString:@"switchToHome"])
    {
        [self switchToGameFeed];
    }
}

-(void)sendInsightReady
{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"insightReady" object:nil userInfo:nil];
}

-(NSString*) incrementString:(NSString*) oldvalue: (int) amount
{
    int intvalue = [oldvalue intValue];    
    return [NSString stringWithFormat:@"%d", intvalue+amount];
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    
    // change the push notifications to 0
    [[UAPush shared] setAutobadgeEnabled:YES];
    [[UAPush shared] resetBadge];
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

- (BOOL)application:(UIApplication *)application
            openURL:(NSURL *)url
  sourceApplication:(NSString *)sourceApplication
         annotation:(id)annotation {
    // attempt to extract a token from the url
    return [self.session handleOpenURL:url];
}

- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url
{
    return [FBSession.activeSession handleOpenURL:url];
}

-(NSInteger) checkForProfileUpdates
{
    // send request to endpoint to get shit from server if sending is not the profile
    return 0;
}


-(void) refreshNotificationsFromPushNotification
{
    if(self.session.state == FBSessionStateOpen)
    {
        UITabBarItem *item = [self.tabBarController.tabBar.items objectAtIndex:0];
        NSString *oldvalue = item.badgeValue;
        
        int seconds = (int)[[NSDate date] timeIntervalSince1970];
        
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        
        
        //either checks the last time that we polled the server, or polls based on that previous time. then stores the current value
        int polltime = 0;
        if([defaults integerForKey:@"lastpolled"] != nil)
        {
            ////NSLog(@"(old time was %d", [defaults integerForKey:@"lastpolled"]);
            polltime = [defaults integerForKey:@"lastpolled"];
            
        }
        ////NSLog(@"Trying to get the polls");
        
        // checks if the the user is first timer
        NSString *path = @"/data/getnotification/";
        path = [path stringByAppendingString:[defaults objectForKey:@"id"]];
        
        path = [path stringByAppendingString:@"/"];
        
        ////NSLog(@"Path is %@", path);
        
        [[PaveAPIClient sharedClient] postPath:path parameters:nil success:^(AFHTTPRequestOperation *operation, id results) {
            if (results) {
                //NSLog(@"Results %@", results);
                NSInteger new_inc = [[results objectForKey:@"recs"] intValue] + [[results objectForKey:@"answers"] intValue] + [[results objectForKey:@"ug_answers"] intValue];
                ////NSLog(@"%d", new_inc);
                
                NSInteger status_score = [[results objectForKey:@"status_score"] intValue];
                if (!status_score)
                {
                    //NSLog(@"Status score is null");
                    status_score = 0;
                }
                
                if (self.currentStatusScore != status_score)
                {
                    ////NSLog(@"ABOUT TO UPDATE STATUS SCORE");
                    self.currentStatusScore = status_score;
                    NSDictionary *data = [NSDictionary dictionaryWithObjectsAndKeys: @(status_score), @"status_score", nil];
                    if (!self.inGroup)
                        [[NSNotificationCenter defaultCenter] postNotificationName:@"refreshStatusScore" object:nil userInfo: data];
                }
                
                // broadcast notification to everyone
                if ((self.currentStatusScore >= 100) && (!self.notificationPopupIsOpen) && (!self.inGroup))
                {
                    //NSLog(@"Notification is coming up!");
                    self.notificationPopupIsOpen = YES;
                    [self performSelector:@selector(sendInsightReady) withObject:nil afterDelay:0.5];
                } else
                {
                    //NSLog(@"Notification is not ready");
                }
                
                NSInteger old_recs = [defaults integerForKey:@"num_recs"];
                if (!old_recs)
                    old_recs = 0;
                NSInteger old_answers = [defaults integerForKey:@"num_answers"];
                if (!old_answers)
                    old_answers = 0;
                NSInteger old_ug_answers = [defaults integerForKey:@"num_ug_answers"];
                if (!old_ug_answers)
                    old_ug_answers = 0;
                
                // set the status score and the rest of the properties
                [defaults setInteger: status_score forKey:@"status_score"];
                
                NSInteger new_recs = [[results objectForKey:@"recs"] intValue] + old_recs;
                [defaults setInteger: new_recs forKey:@"num_recs"];
                
                NSInteger new_answer = [[results objectForKey:@"answers"] intValue] + old_answers;
                [defaults setInteger:new_answer forKey:@"num_answers"];
                
                NSInteger new_ug_answer = [[results objectForKey:@"ug_answers"] intValue] + old_ug_answers;
                [defaults setInteger:new_ug_answer forKey:@"num_ug_answers"];
                
                [defaults synchronize];
                
                ////NSLog(@"Numbers: %d, %d, %d, %d", old_recs, old_answers, old_ug_answers, status_score);
                //NSLog(@"New Numbers: %d, %d, %d, %d", new_recs, new_answer, new_ug_answer, status_score);
                
                //[defaults setObject:[results objectForKey:@"answers"] forKey:@"num_answers"];
                //[defaults setObject:[results objectForKey:@"ug_answers"] forKey:@"num_ug_answers"];
                
                if(new_inc != 0)
                {
                    ////NSLog(@"Incremented by %d!", new_inc);
                    [[self.tabBarController.tabBar.items objectAtIndex:0] setBadgeValue:[self incrementString:oldvalue : new_inc]];
                }
                //changes the old value
                [defaults setInteger:[[results objectForKey:@"last"] intValue] forKey:@"lastpolled"];
                [[NSNotificationCenter defaultCenter] postNotificationName:@"updateProfileBadgeCounts" object:nil userInfo:nil];
            }
        }
                                       failure:nil];
    }

}

@end
