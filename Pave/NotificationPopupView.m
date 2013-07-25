//
//  NotificationPopupView.m
//  Pave
//
//  Created by Nithin Tumma on 7/20/13.
//  Copyright (c) 2013 Pave. All rights reserved.
//

#import "NotificationPopupView.h"
#import "AppDelegate.h"
#import "UIImageView+WebCache.h"
#import "Flurry.h"

@implementation NotificationPopupView

+ (id) notificationPopupCreateWithData: (NSDictionary *) data
{
    NSLog(@"Dataforrec: %@", data);
    NotificationPopupView *notificationPopup = [[[NSBundle mainBundle] loadNibNamed:@"NotificationPopup" owner:nil options:nil] lastObject];
    
    notificationPopup.label.text = [data objectForKey:@"rec_text"];
    [notificationPopup.recImage setImageWithURL:[NSURL URLWithString:@"http://iteigo.net/wp/wp-content/uploads/2013/04/sample.jpg"]
                      placeholderImage:[UIImage imageNamed:@"profile_icon.png"]];
    
    [notificationPopup baseInit];
    if ([notificationPopup isKindOfClass:[NotificationPopupView class]])
        return notificationPopup;
    else
        return nil;
}

-(void) baseInit
{
    // set up background
    NSLog(@"This is called");
    UIImageView *backgroundImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"iphone4popup_translucent_layer_wbackground.png"]];
    backgroundImage.frame = CGRectMake(0, 0, 320, 327);
    [self addSubview:backgroundImage];
    [self sendSubviewToBack:backgroundImage];
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
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

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

- (IBAction)viewDetailsPushed:(id)sender {
    
    [Flurry logEvent:@"Recommendation Accessed" withParameters:nil];
    // figure out how to segue
    AppDelegate* delegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    [delegate.tabBarController setSelectedIndex:0];
    delegate.currentStatusScore = 0;
    [[NSNotificationCenter defaultCenter] postNotificationName:@"resetStatusScore"  object:nil userInfo:nil];
    [self removeFromSuperview];
    delegate.notificationPopupIsOpen = NO;

    [[NSNotificationCenter defaultCenter] postNotificationName:@"newRecommendation"  object:nil userInfo:nil];
}

- (IBAction)keepPlayingPushed:(id)sender {
    [Flurry logEvent:@"Recommendation Dismissed" withParameters:nil];
    AppDelegate* delegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    delegate.currentStatusScore = 0;
    delegate.notificationPopupIsOpen = NO;

    // first post a Notification to reset the bar
    [[NSNotificationCenter defaultCenter] postNotificationName:@"resetStatusScore"  object:nil userInfo:nil];
    [self removeFromSuperview];
    delegate.notificationPopupIsOpen = NO;

}
@end
