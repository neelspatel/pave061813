//
//  ProfileViewCell.h
//  Pave
//
//  Created by Neel Patel on 6/23/13.
//  Copyright (c) 2013 Pave. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ProfileViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *backgroundImage;
@property (weak, nonatomic) IBOutlet UIImageView *picture;
@property (weak, nonatomic) IBOutlet UILabel *name;
@property (weak, nonatomic) IBOutlet UILabel *numberVotes;
@property (weak, nonatomic) IBOutlet UILabel *numberAnswers;

@end
