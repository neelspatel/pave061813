//
//  GroupGameController.h
//  Pave
//
//  Created by Nithin Tumma on 7/13/13.
//  Copyright (c) 2013 Pave. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UIImageView+WebCache.h"
#import "MembersView.h"
#import "StatusBar.h"

@interface GroupGameController : UIViewController <UITableViewDataSource, UITableViewDelegate, UIGestureRecognizerDelegate>
@property (weak, nonatomic) IBOutlet UINavigationBar *topBar;

//creates the popup
@property (nonatomic, retain)MembersView *popup;


@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, retain)NSMutableArray *feedObjects;
@property (nonatomic, retain)NSMutableDictionary *readStatus;
@property (nonatomic, retain)NSMutableDictionary *anonStatus;
@property (nonatomic, strong)SDImageCache *myImageCache;
@property (nonatomic, assign)BOOL doneLoadingFeed;

@property (weak, nonatomic) IBOutlet UIButton *refreshButton;
- (void)refreshWithPull:(UIRefreshControl *)refreshControl;
@property (nonatomic, retain) UIRefreshControl *refreshControl;

@property (nonatomic, retain)NSArray *paths;
@property (nonatomic, retain)NSString *dataPath;
@property (nonatomic, retain)NSMutableDictionary *imageRequests;
@property (nonatomic, assign)BOOL reloadingFeedObject;

@property (nonatomic, assign)BOOL loggedIn;
@property (nonatomic, assign)BOOL didCompleteProfileInformation;

@property (nonatomic, retain)NSMutableDictionary *group;

- (IBAction)viewMembers:(id)sender;

@property (nonatomic, retain) StatusBar *sbar;

- (IBAction)backButtonPushed:(id)sender;

@end
