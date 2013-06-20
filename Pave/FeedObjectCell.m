//
//  FeedObjectCell.m
//  Mockup
//
//  Created by Neel Patel on 6/14/13.
//  Copyright (c) 2013 Neel Patel. All rights reserved.
//

#import "FeedObjectCell.h"
#import <QuartzCore/QuartzCore.h>


@implementation FeedObjectCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        NSLog(@"Just called init");
        self.leftBackground.layer.cornerRadius = 10;
        self.leftBackground.clipsToBounds = YES;
        self.rightBackground.layer.cornerRadius = 10;
        self.rightBackground.clipsToBounds = YES;
        self.profilePictureBackground.layer.cornerRadius = 10;
        self.profilePictureBackground.clipsToBounds = YES;
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

-(IBAction) submitLeft:(id)sender
{
    NSLog(@"Just submitted left");
}

@end
