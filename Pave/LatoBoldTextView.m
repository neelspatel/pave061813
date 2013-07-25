//
//  LatoBoldTextView.m
//  Pave
//
//  Created by Nithin Tumma on 7/25/13.
//  Copyright (c) 2013 Pave. All rights reserved.
//

#import "LatoBoldTextView.h"

@implementation LatoBoldTextView

-(void) setup
{
    self.font = [UIFont fontWithName:@"Lato-Bold" size: self.font.pointSize];
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setup];
    }
    return self;
}

-(id) initWithCoder:(NSCoder *)aDecoder
{
    if (self = [super initWithCoder:aDecoder]) {
        [self setup];
    }
    return self;
}

-(id)init {
    if (self = [super init]) {
        [self setup];
    }
    return self;
}


/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
