//
//  GameController.h
//  Pave
//
//  Created by Neel Patel on 6/18/13.
//  Copyright (c) 2013 Pave. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UIImageView+WebCache.h"
#import <MessageUI/MessageUI.h>

@interface GameController : UIViewController <UITableViewDataSource, UITableViewDelegate, UIGestureRecognizerDelegate, MFMailComposeViewControllerDelegate>
@property (weak, nonatomic) IBOutlet UINavigationBar *topBar;

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIButton *emailButton;
- (IBAction)sendEmail:(id)sender;

// store the values of the required instance variables
@property (nonatomic, retain)NSMutableArray *feedObjects;
@property (nonatomic, retain)NSMutableDictionary *readStatus;
@property (nonatomic, strong)SDImageCache *myImageCache;
@property (nonatomic, assign)BOOL doneLoadingFeed;

//stores the image paths
@property (nonatomic, retain)NSArray *paths;
@property (nonatomic, retain)NSString *dataPath;
@property (nonatomic, retain)NSMutableDictionary *imageRequests;
@property (nonatomic, assign)BOOL reloadingFeedObject;

@property (nonatomic, assign)BOOL loggedIn;
@property (nonatomic, assign)BOOL didCompleteProfileInformation;
@end
