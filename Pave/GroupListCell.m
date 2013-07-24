//
//  GroupListCell.m
//  Pave
//
//  Created by Nithin Tumma on 7/20/13.
//  Copyright (c) 2013 Pave. All rights reserved.
//

#import "GroupListCell.h"

@implementation GroupListCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        self.contentView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"unselected_group_selector_background.png"]];
        //self.backgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"unselected_group_selector_background.png"]];

        //self.selectedBackgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"selected_group.png"]];
        
        //self.imageView.image = [UIImage imageNamed:@"not_selected_group.png"];
        //self.imageView.highlighted = [UIImage imageNamed:@"selected_group.png"];
    }
    // Initialization code
    
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}

- (void)willTransitionToState:(UITableViewCellStateMask)state
{
    [super willTransitionToState:state];
    if ((state & UITableViewCellStateShowingDeleteConfirmationMask) == UITableViewCellStateShowingDeleteConfirmationMask) {
        for (UIView *subview in self.subviews) {
            if ([NSStringFromClass([subview class]) isEqualToString:@"UITableViewCellDeleteConfirmationControl"]) {
                UIImageView *deleteBtn = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, 64, 33)];
                //[deleteBtn setImage:[UIImage imageNamed:@"ALLI_profile.png"]];
                [[subview.subviews objectAtIndex:0] addSubview:deleteBtn];
            }
        }
    }
}

@end
