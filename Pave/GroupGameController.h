//
//  GroupGameController.h
//  Pave
//
//  Created by Nithin Tumma on 7/13/13.
//  Copyright (c) 2013 Pave. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UIImageView+WebCache.h"


@interface GroupGameController : UIViewController <UITableViewDataSource, UITableViewDelegate, UIGestureRecognizerDelegate>
@property (weak, nonatomic) IBOutlet UINavigationBar *topBar;

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, retain)NSMutableArray *feedObjects;
@property (nonatomic, retain)NSMutableDictionary *readStatus;
@property (nonatomic, strong)SDImageCache *myImageCache;
@property (nonatomic, assign)BOOL doneLoadingFeed;

@property (weak, nonatomic) IBOutlet UIButton *refreshButton;
- (IBAction)refresh:(id)sender;

@property (nonatomic, retain)NSArray *paths;
@property (nonatomic, retain)NSString *dataPath;
@property (nonatomic, retain)NSMutableDictionary *imageRequests;
@property (nonatomic, assign)BOOL reloadingFeedObject;

@property (nonatomic, assign)BOOL loggedIn;
@property (nonatomic, assign)BOOL didCompleteProfileInformation;

@property (nonatomic, retain)NSMutableDictionary *group;

@end
