//
//  GroupMemberCell.h
//  Pave
//
//  Created by Neel Patel on 7/23/13.
//  Copyright (c) 2013 Pave. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GroupMemberCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *friendName;

@property (weak, nonatomic) IBOutlet UIImageView *friendProfilePicture;

@end
