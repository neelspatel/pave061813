//
//  StatusBar.m
//  Pave
//
//  Created by Nithin Tumma on 7/19/13.
//  Copyright (c) 2013 Pave. All rights reserved.
//

#import "StatusBar.h"
#import "AppDelegate.h"
#import "PaveAPIClient.h"

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
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(resetBar) name:@"resetStatusScore" object:nil];
    
    self.onCircle = [UIImage imageNamed: @"blue_circle.png"];
    self.offCircle = [UIImage imageNamed: @"gray_circle.png"];
    self.line = [UIImage imageNamed:@"progress_line.png"];
    self.offBulb = [UIImage imageNamed:@"lightbulb_off.png"];
    self.onBulb = [UIImage imageNamed:@"lightbulb_selected_yellow.png"];
    
    [self resetBar];
    
    /*
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
    
    [self.connector1 setImage: self.line];
    */
    
    /*
    self.imageViews = [[NSMutableArray alloc] initWithObjects: self.image1, self.image2, self.image3, self.image4, self.image5, self.image6, self.image7, self.image8, self.image9, self.image10, nil];
    self.lineViews = [[NSMutableArray alloc] initWithObjects: self.connector1, self.connector2, self.connector3, self.connector4, self.connector5, self.connector6, self.connector7, self.connector8, self.connector9, nil];
     */
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

-(void) resetBar
{
    NSLog(@"Resetting bar");
    
    for (UIImageView *imageView in self.subviews)
    {
        if ([imageView tag] == 0)
            continue;
        else if ([imageView tag] == 1)
            [imageView setImage: self.onCircle];
        else if ([imageView tag] == 2)
            [imageView setImage: self.line];
        else if ([imageView tag] == 3)
            [imageView setImage: self.onCircle];
        else
        {
            if ([imageView tag] % 2 == 0)
            {
                imageView.hidden = YES;
                [imageView setImage: self.line];
            }
            else
            {
                if ([imageView tag] == 19)
                    [imageView setImage: self.offBulb];
                else
                {
                    NSLog(@"OFF BULB");
                    [imageView setImage: self.offCircle];
                }
            }
        }
    }

}

// function to call to draw the status bar to the correct
-(void) redrawBar
{
    NSLog(@"About to redraw the bar");
    AppDelegate* delegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    self.statusScore = delegate.currentStatusScore;
    
    NSInteger num_bars = self.statusScore / 10;
    NSLog(@"Number of bars: %d", delegate.currentStatusScore);
    
    // make sure that we never go over
    if (num_bars > 10)
        num_bars = 10;
    
    NSInteger num_tags = (2 * num_bars) - 1;
    
    for (int i = 1; i <= 19; i++)
    {
        if (i <= num_tags)
        {
            if ((i % 2) == 0)
                [self viewWithTag: i].hidden= NO;
            else
            {
                if (i == 19)
                    [(UIImageView *)[self viewWithTag: i] setImage: self.onBulb];
                else
                    [(UIImageView *)[self viewWithTag: i] setImage: self.onCircle];
            }
        
        }
        else
        {
            if ((i % 2) == 0)
                [self viewWithTag: i].hidden = YES;
            else
            {
                if (i == 19)
                     [(UIImageView *)[self viewWithTag: i] setImage: self.offBulb];
                else
                    [(UIImageView *)[self viewWithTag: i] setImage: self.offCircle];
            }
        }
    
    }
/*
    if (num_bars == 10)
    {
        // display Notification
        [[NSNotificationCenter defaultCenter] postNotificationName:@"insightReady" object:nil userInfo:nil];
    }
*/
    
}

-(void) doneLoading
{
    [self.activityIndicator stopAnimating];
}

-(void) startLoading
{
    [self.activityIndicator startAnimating];
}

-(void) layoutSubviews
{
    [super layoutSubviews];
}
@end
