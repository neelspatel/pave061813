//
//  GroupListCell.h
//  Pave
//
//  Created by Nithin Tumma on 7/20/13.
//  Copyright (c) 2013 Pave. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GroupListCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *groupName;
@property (weak, nonatomic) IBOutlet UILabel *groupMembers;
@property (weak, nonatomic) IBOutlet UIImageView *backgroundImage;

@end
