//
//  GameController.h
//  Pave
//
//  Created by Neel Patel on 6/18/13.
//  Copyright (c) 2013 Pave. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UIImageView+WebCache.h"


@interface PersonalFeedController : UIViewController <UITableViewDataSource, UITableViewDelegate>
@property (weak, nonatomic) IBOutlet UINavigationBar *topBar;

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIView *tableViewBackground;

// store the values of the required instance variables
@property (nonatomic, retain)NSArray *feedObjects;
@property (nonatomic, strong)SDImageCache *myImageCache;
@property (nonatomic, assign)BOOL doneLoadingFeed;


//stores the image paths
@property (nonatomic, retain)NSArray *paths;
@property (nonatomic, retain)NSString *dataPath;
@property (nonatomic, retain)NSMutableDictionary *imageRequests;
@property (nonatomic,assign) BOOL reloadingFeedObject;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *loading;

- (IBAction)refresh:(id)sender;
- (IBAction)inviteFriends:(id)sender;

@property (weak, nonatomic) IBOutlet UIButton *logoutButton;
- (IBAction)logout:(id)sender;


@end
