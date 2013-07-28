//
//  AppDelegate.h
//  Pave
//
//  Created by Neel Patel on 6/18/13.
//  Copyright (c) 2013 Pave. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <FacebookSDK/FacebookSDK.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) FBSession* session;
@property (nonatomic, assign) NSInteger profileBadgeCount;
@property (nonatomic, assign) NSInteger currentStatusScore;

-(NSInteger) checkForProfileUpdates;

@property (nonatomic, retain) UITabBarController *tabBarController;

@property (nonatomic, assign) BOOL notificationPopupIsOpen;
@property (nonatomic, assign) BOOL firstLaunch;
@property (nonatomic, assign) BOOL inGroup;


-(void) handleNotification:(NSDictionary *) notification;
-(BOOL)updatePushNotifiactionAlias;

-(void)nowInGroup;
-(void)leavingGroup;
-(void) refreshNotificationsFromPushNotification;

@end
