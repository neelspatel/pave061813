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
#import "GAI.h"
#import "Flurry.h"

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Optional: automatically send uncaught exceptions to Google Analytics.
    [GAI sharedInstance].trackUncaughtExceptions = YES;
    // Optional: set Google Analytics dispatch interval to e.g. 20 seconds.
    [GAI sharedInstance].dispatchInterval = 20;
    // Optional: set debug to YES for extra debugging information.
    [GAI sharedInstance].debug = YES;
    // Create tracker instance.
    id<GAITracker> tracker = [[GAI sharedInstance] trackerWithTrackingId:@"UA-37404339-2"];
    
    // flurry analytics 
    [Flurry startSession: @"N49JNZBNHFZ6PJ4Y9PSM"];
    
    //self.didCompleteProfileInformation = YES;
    // Assign tab bar item with titles
    UITabBarController *tabBarController = (UITabBarController *)self.window.rootViewController;
    UITabBar *tabBar = tabBarController.tabBar;
    UITabBarItem *tabBarItem1 = [tabBar.items objectAtIndex:0];
    UITabBarItem *tabBarItem2 = [tabBar.items objectAtIndex:1];
    UITabBarItem *tabBarItem3 = [tabBar.items objectAtIndex:2];
    
    [tabBarItem1 setFinishedSelectedImage:[UIImage imageNamed:@"smiley_on.png"] withFinishedUnselectedImage:[UIImage imageNamed:@"smiley_off.png"]];
    [tabBarItem2 setFinishedSelectedImage:[UIImage imageNamed:@"house_on.png"] withFinishedUnselectedImage:[UIImage imageNamed:@"house_off.png"]];
    [tabBarItem3 setFinishedSelectedImage:[UIImage imageNamed:@"globe_on.png"] withFinishedUnselectedImage:[UIImage imageNamed:@"globe_off.png"]];
            
    UIImage* tabBarBackground = [UIImage imageNamed:@"nav_bar.png"];
    [[UITabBar appearance] setBackgroundImage:tabBarBackground];
    //gets rid of translucent
    [[UITabBar appearance] setSelectionIndicatorImage:[[UIImage alloc] init]];
    
    tabBarController.selectedIndex = 1;
    
    // FB Login
    NSArray *permissionsArray = @[ @"user_about_me", @"user_relationships", @"user_birthday", @"user_location"];
    
    self.session = [[FBSession alloc] initWithAppID:@"545929018807731" permissions:permissionsArray defaultAudience:nil urlSchemeSuffix:nil tokenCacheStrategy:nil];
    
    //timer to check for notifications
    NSTimer* myTimer = [NSTimer scheduledTimerWithTimeInterval: 30.0 target: self
                                                      selector: @selector(refreshNotifications:) userInfo: nil repeats: YES];
    
    
    
    // Override point for customization after application launch.
    return YES;
    
}

-(void) refreshNotifications:(NSTimer*) t
{
    //if we're logged in
    if(self.session.state == FBSessionStateOpen)
    {
        UITabBarController *tabBarController = (UITabBarController *)self.window.rootViewController;
        UITabBar *tabBar = tabBarController.tabBar;
        UITabBarItem *item = [tabBar.items objectAtIndex:0];
        NSString *oldvalue = item.badgeValue;

        int seconds = (int)[[NSDate date] timeIntervalSince1970];
        
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        
        //either checks the last time that we polled the server, or polls based on that previous time. then stores the current value
        int polltime = 0;
        if([defaults integerForKey:@"lastpolled"] != nil)
        {
            NSLog(@"(old time was %d", [defaults integerForKey:@"lastpolled"]);
                //updates the poll time
            polltime = [defaults integerForKey:@"lastpolled"];
            
        }
        NSLog(@"Trying to get the polls");
        NSString *path = @"/data/numberofnewobjects/";
        path = [path stringByAppendingString:[defaults objectForKey:@"id"]];
        //path = [path stringByAppendingString:@"1"];
        path = [path stringByAppendingString:@"/"];
        path = [path stringByAppendingString:[NSString stringWithFormat:@"%d", polltime]];
        path = [path stringByAppendingString:@"/"];
        NSLog(@"Path is %@", path);
        
        [[PaveAPIClient sharedClient] postPath:path parameters:nil success:^(AFHTTPRequestOperation *operation, id results) {
                if (results) {
                    NSLog(@"Results %@", results);
                    if([[results objectForKey:@"count"] intValue] != 0)
                    {
                        NSLog(@"Incremented by %d!", [[results objectForKey:@"count"] intValue]);
                        [[tabBar.items objectAtIndex:0] setBadgeValue:[self incrementString:oldvalue :[[results objectForKey:@"count"] intValue]]];
                    }
                    //changes the old value
                    [defaults setInteger:[[results objectForKey:@"last"] intValue] forKey:@"lastpolled"];
                }
            }
            failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                NSLog(@"error getting notifications from database %@", error);
            }];    
    }
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


@end
