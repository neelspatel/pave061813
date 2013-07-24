//
//  RecsCell.h
//  Pave
//
//  Created by Neel Patel on 7/17/13.
//  Copyright (c) 2013 Pave. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RecsCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *image;
@property (weak, nonatomic) IBOutlet UILabel *text;
@property (weak, nonatomic) IBOutlet UILabel *level;
@property (weak, nonatomic) IBOutlet UIButton *agree;
@property (weak, nonatomic) IBOutlet UIButton *disagree;

@end
