//
//  TrendingListCell.m
//  Pave
//
//  Created by Neel Patel on 6/20/13.
//  Copyright (c) 2013 Pave. All rights reserved.
//

#import "TrendingListCell.h"

@implementation TrendingListCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        NSLog(@"Changing cell style..");
        self.imageView.image = [UIImage imageNamed:@"unselected_one_trending_topic_box.png"];
        self.imageView.highlightedImage = [UIImage imageNamed:@"selected_trending_topic_box.png"];
        
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
