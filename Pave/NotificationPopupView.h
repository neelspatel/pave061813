//
//  NotificationPopupView.h
//  Pave
//
//  Created by Nithin Tumma on 7/20/13.
//  Copyright (c) 2013 Pave. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface NotificationPopupView : UIView
@property (weak, nonatomic) IBOutlet UILabel *label;
@property (weak, nonatomic) IBOutlet UIImageView *recImage;
@property (weak, nonatomic) IBOutlet UIButton *viewDetailsButton;
@property (weak, nonatomic) IBOutlet UIButton *keepPlayingButton;
- (IBAction)viewDetailsPushed:(id)sender;
- (IBAction)keepPlayingPushed:(id)sender;

+ (id) notificationPopupCreateWithData: (NSDictionary *) data;

@end
