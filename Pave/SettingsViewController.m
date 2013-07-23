//
//  SettingsViewController.m
//  Pave
//
//  Created by Nithin Tumma on 7/20/13.
//  Copyright (c) 2013 Pave. All rights reserved.
//

#import "SettingsViewController.h"
#import "AppDelegate.h"
#import "LoginViewController.h" 

@interface SettingsViewController ()

@end

@implementation SettingsViewController

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
    NSLog(@"Created the settings page");
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)dismissSettingsPushed:(id)sender {
    NSLog(@"Trying to dismiss");
    [self dismissViewControllerAnimated:NO completion:nil];
}

- (IBAction)dismiss:(id)sender {
    NSLog(@"Trying to dismiss");
    [self dismissViewControllerAnimated:YES completion:nil];

}

- (IBAction)feedbackPushed:(id)sender {
}

- (IBAction)invitePushed:(id)sender {
}

- (IBAction)ratePushed:(id)sender {
}

- (IBAction)logoutPushed:(id)sender {
  
    NSLog(@"About to logout");
    
    AppDelegate* delegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    FBSession* session = delegate.session;

    /*
     [session closeAndClearTokenInformation];
    [session close];
    */
    
    //[FBSession setActiveSession:nil];
    
    //[FBSession.activeSession close];
    
    [FBSession.activeSession  closeAndClearTokenInformation];

    NSArray *permissionsArray = @[ @"email", @"user_likes", @"user_interests", @"user_about_me", @"user_birthday", @"friends_about_me", @"friends_interests", @"read_stream"];
    
    delegate.session = [[FBSession alloc] initWithAppID:@"545929018807731" permissions:permissionsArray defaultAudience:nil urlSchemeSuffix:nil tokenCacheStrategy:nil];

    
    [self dismissViewControllerAnimated:NO completion:
        ^(void){
            NSLog(@"Trying to present main feed");
            delegate.tabBarController.selectedViewController = [delegate.tabBarController.viewControllers objectAtIndex:2];
        
        }];
    
    //[(UITabBarController*)self.navigationController.topViewController setSelectedIndex:2];
   
    /*
    LoginViewController *loginViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"loginViewController"];
    [self presentViewController: loginViewController animated: NO completion: nil];
     */
}
@end
