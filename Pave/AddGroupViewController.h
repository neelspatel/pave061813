//
//  AddGroupViewController.h
//  Pave
//
//  Created by Nithin Tumma on 7/12/13.
//  Copyright (c) 2013 Pave. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AddGroupViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate>


- (IBAction)showCreate:(id)sender;
- (IBAction)createGroup:(id)sender;

@property (nonatomic, retain) NSMutableArray *friendNames;
@property (nonatomic, retain) NSMutableArray *friendIds;
@property (nonatomic, retain) NSMutableArray *filteredNames;
@property (retain, nonatomic) NSMutableArray  *currentGroup;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, assign) BOOL isFiltered;
@property (weak, nonatomic) IBOutlet UITextView *addedFriendsTextField;
@property (weak, nonatomic) IBOutlet UISearchBar *addFriendsSearchBar;
@property (weak, nonatomic) IBOutlet UITextField *groupName;
@property(nonatomic, copy) NSString *currentGroupName;

@property (weak, nonatomic) IBOutlet UIView *popup;
@end
