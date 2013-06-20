//
//  TrendingTopicsListViewController.h
//  Pave
//
//  Created by Nithin Tumma on 6/20/13.
//  Copyright (c) 2013 Pave. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TrendingTopicsListViewController : UIViewController  <UITableViewDataSource, UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, retain)NSArray *feedObjects;
@property (nonatomic, assign) BOOL doneLoadingFeed;

@end
