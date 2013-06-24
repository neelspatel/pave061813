//
//  TrendingController.h
//  Pave
//
//  Created by Neel Patel on 6/20/13.
//  Copyright (c) 2013 Pave. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UIImageView+WebCache.h"

@interface TrendingController : UIViewController <UITableViewDataSource, UITableViewDelegate, UIGestureRecognizerDelegate>

@property (nonatomic, copy) NSDictionary *typeDictionary;
@property (weak, nonatomic) IBOutlet UINavigationBar *topBar;

@property (weak, nonatomic) IBOutlet UITableView *tableView;


@property (weak, nonatomic) IBOutlet UIButton *backButton;
- (IBAction)back:(id)sender;


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
@end
