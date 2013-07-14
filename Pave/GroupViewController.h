//
//  GroupViewController.h
//  Pave
//
//  Created by Nithin Tumma on 7/12/13.
//  Copyright (c) 2013 Pave. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GroupViewController : UIViewController  <UITableViewDataSource, UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIButton *addGroupButton;
- (IBAction)addGroup:(id)sender;

// load in from NSUser Defaults
@property (nonatomic, retain) NSMutableArray *groups;
@end
