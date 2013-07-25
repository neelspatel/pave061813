//
//  WalkthroughChildViewController.m
//  Pave
//
//  Created by Nithin Tumma on 7/22/13.
//  Copyright (c) 2013 Pave. All rights reserved.
//

#import "WalkthroughChildViewController.h"

@interface WalkthroughChildViewController ()

@end

@implementation WalkthroughChildViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    //self.screenNumber.text = [NSString stringWithFormat:@"Screen #%d", self.index];
    [self.backgroundImage setImage:[UIImage imageNamed:@"2test_page1_walkthrough.png"]];
    switch (self.index)
    {
            case 0:
                [self.backgroundImage setImage:[UIImage imageNamed:@"page1_walkthrough.png"]];
                break;
            case 1:
                [self.backgroundImage setImage:[UIImage imageNamed:@"page2_walkthrough.png"]];
                break;
            case 2:
                [self.backgroundImage setImage:[UIImage imageNamed:@"page3_walkthrough.png"]];
                break;
            case 3:
                [self.backgroundImage setImage:[UIImage imageNamed:@"page4_walkthrough.png"]];
                self.doneButton.hidden = YES;
                self.startSidingButton.hidden = NO;
                break;
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)doneButtonPushed:(id)sender {
    [self dismissViewControllerAnimated:NO completion:^{
            // send notification to login view controller to dismiss and return to game feecd
        [[NSNotificationCenter defaultCenter] postNotificationName:@"tutorialComplete" object:nil];
        }];
}
@end
