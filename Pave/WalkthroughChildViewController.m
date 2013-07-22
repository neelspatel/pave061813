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
    self.screenNumber.text = [NSString stringWithFormat:@"Screen #%d", self.index];

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
