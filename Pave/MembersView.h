//
//  MembersView.h
//  Pave
//
//  Created by Neel Patel on 7/23/13.
//  Copyright (c) 2013 Pave. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MembersView : UIViewController <UITableViewDataSource, UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UILabel *label;
@property (nonatomic, retain) NSDictionary *data;
@property (weak, nonatomic) IBOutlet UITableView *tableView;

-(id) initWithData:(NSDictionary *)data;


@end
