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
        //self.backgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"not_selected_group.png"]];
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

@end
