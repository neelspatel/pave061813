//
//  NotificationPopupView.m
//  Pave
//
//  Created by Nithin Tumma on 7/20/13.
//  Copyright (c) 2013 Pave. All rights reserved.
//

#import "NotificationPopupView.h"
#import "AppDelegate.h"

@implementation NotificationPopupView

+ (id) notificationPopupCreateWithData: (NSDictionary *) data
{
    NotificationPopupView *notificationPopup = [[[NSBundle mainBundle] loadNibNamed:@"NotificationPopup" owner:nil options:nil] lastObject];
    
    notificationPopup.label.text = [data objectForKey:@"rec_text"];
    
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
    // figure out how to segue
    AppDelegate* delegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    [delegate.tabBarController setSelectedIndex:0];
    [self removeFromSuperview];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"newRecommendation"  object:nil userInfo:nil];
}

- (IBAction)keepPlayingPushed:(id)sender {
    [self removeFromSuperview];
}
@end
