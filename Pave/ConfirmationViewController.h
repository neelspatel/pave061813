//
//  ConfirmationViewController.h
//  Pave
//
//  Created by Nithin Tumma on 7/25/13.
//  Copyright (c) 2013 Pave. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ConfirmationViewController : UIViewController
- (IBAction)completeButtonPushed:(id)sender;
- (IBAction)inviteFriends:(id)sender;
- (IBAction)shareQuestion:(id)sender;
- (IBAction)askUs:(id)sender;

@property (nonatomic, retain) NSString *questionText;

@end
