//
//  GameController.h
//  Pave
//
//  Created by Neel Patel on 6/18/13.
//  Copyright (c) 2013 Pave. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UIImageView+WebCache.h"


@interface GameController : UIViewController <UITableViewDataSource, UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;

// store the values of the required instance variables
@property (nonatomic, retain)NSMutableArray *feedObjects;
@property (nonatomic, strong)SDImageCache *myImageCache;
@property (nonatomic, assign)BOOL doneLoadingFeed;

//stores the image paths
@property (nonatomic, retain)NSArray *paths;
@property (nonatomic, retain)NSString *dataPath;
@property (nonatomic, retain)NSMutableDictionary *imageRequests;

@end
