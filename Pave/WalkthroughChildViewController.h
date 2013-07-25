//
//  WalkthroughChildViewController.h
//  Pave
//
//  Created by Nithin Tumma on 7/22/13.
//  Copyright (c) 2013 Pave. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WalkthroughChildViewController : UIViewController
@property (assign, nonatomic) NSInteger index;
@property (weak, nonatomic) IBOutlet UIButton *doneButton;
- (IBAction)doneButtonPushed:(id)sender;

@property (weak, nonatomic) IBOutlet UIImageView *backgroundImage;

@property (weak, nonatomic) IBOutlet UIButton *startSidingButton;
@end
