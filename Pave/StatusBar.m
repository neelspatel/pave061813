//
//  StatusBar.m
//  Pave
//
//  Created by Nithin Tumma on 7/19/13.
//  Copyright (c) 2013 Pave. All rights reserved.
//

#import "StatusBar.h"
#import "AppDelegate.h"

@implementation StatusBar

+ (id) statusBarCreate
{
    StatusBar *statusBar = [[[NSBundle mainBundle] loadNibNamed:@"StatusBarView" owner:nil options:nil] lastObject];
    [statusBar baseInit];
    if ([statusBar isKindOfClass:[StatusBar class]])
        return statusBar;
    else
        return nil;
}

-(void) baseInit {
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(redrawBarFromNotification:)
                                                 name:@"refreshStatusScore"
                                               object:nil];
    
    self.onCircle = [UIImage imageNamed: @"circle.png"];
    self.offCircle = [UIImage imageNamed: @"off_circle.png"];
    
    [self.image1 setImage: self.onCircle];
    [self.image2 setImage: self.onCircle];
    [self.image3 setImage: self.offCircle];
    [self.image4 setImage: self.offCircle];
    [self.image5 setImage: self.offCircle];
    [self.image6 setImage: self.offCircle];
    [self.image7 setImage: self.offCircle];
    [self.image8 setImage: self.offCircle];
    [self.image9 setImage: self.offCircle];
    [self.image10 setImage: self.offCircle];
    
    self.imageViews = [[NSMutableArray alloc] initWithObjects: self.image1, self.image2, self.image3, self.image4, self.image5, self.image6, self.image7, self.image8, self.image9, self.image10, nil];
    AppDelegate* delegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];

    self.statusScore = delegate.currentStatusScore;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self baseInit];
    }
    return self;
}

- (id) initWithCoder: (NSCoder *) aDecoder {
    if ((self = [super initWithCoder:aDecoder])) {
        [self baseInit];
    }
    return self;
}

-(void) redrawBarFromNotification:(NSNotification *) notification
{
    NSLog(@"Notification recieved in status bar");
    [self redrawBar];
}

// function to call to draw the status bar to the correct
-(void) redrawBar
{
    AppDelegate* delegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    self.statusScore = delegate.currentStatusScore;
    
    NSInteger num_bars = self.statusScore / 10;
    NSLog(@"Number of bars: %d", delegate.currentStatusScore);
    int index = 0;
    for (UIImageView *imageView in self.imageViews)
    {
        if (index <= num_bars)
            [imageView setImage: self.onCircle];
        else
            [imageView setImage: self.offCircle];
        index++;
    }
    
}

-(void) refresh {
    for (int i = 0; i < self.imageViews.count; i++)
    {
        UIImageView *imageView = [self.imageViews objectAtIndex:i];
        if (self.statusScore >= i + 1)
        {
            imageView.hidden = NO;
        }
    }
}

-(void) layoutSubviews {
    [super layoutSubviews];
    /*
    float desiredImageWidth = 4;
    float imageWidth = 4;
    float imageHeight = 4;
    float barWidth = 30;
    float barHeight = 2;
    
    for (int i=0; i<self.imageViews.count; ++i)
    {
        UIImageView  *imageView  = [self.imageViews objectAtIndex:i];
        CGRect imageFrame = CGRectMake(<#CGFloat x#>, <#CGFloat y#>, imageWidth, imageHeight)
    } */
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
