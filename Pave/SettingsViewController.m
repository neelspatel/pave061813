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
#import <MessageUI/MessageUI.h>

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
    //NSLog(@"Created the settings page");
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)dismissSettingsPushed:(id)sender {
    //NSLog(@"Trying to dismiss");
    [self dismissViewControllerAnimated:NO completion:nil];
}

- (IBAction)dismiss:(id)sender {
    //NSLog(@"Trying to dismiss");
    [self dismissViewControllerAnimated:YES completion:nil];

}

- (IBAction)feedbackPushed:(id)sender {
    //NSLog(@"Calledemail");
    MFMailComposeViewController *mailer = [[MFMailComposeViewController alloc] init];
    mailer.mailComposeDelegate = self;
    [mailer setSubject:@"Side, we need to talk..."];
    NSArray *toRecipients = [NSArray arrayWithObjects:@"getsideapp@gmail.com", nil];
    [mailer setToRecipients:toRecipients];
    NSString *emailBody = @"<div style = 'font-size: 10px;'> It's not me, it's you. Here's my feedback on Side:</div>";
    [mailer setMessageBody:emailBody isHTML:YES];
    [self presentModalViewController:mailer animated:YES];

}

- (void)mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error
{
    switch (result)
    {
        case MFMailComposeResultCancelled:
            //NSLog(@"Mail cancelled: you cancelled the operation and no email message was queued.");
            break;
        case MFMailComposeResultSaved:
            //NSLog(@"Mail saved: you saved the email message in the drafts folder.");
            break;
        case MFMailComposeResultSent:
            //NSLog(@"Mail send: the email message is queued in the outbox. It is ready to send.");
            break;
        case MFMailComposeResultFailed:
            //NSLog(@"Mail failed: the email message was not saved or queued, possibly due to an error.");
            break;
        default:
            //NSLog(@"Mail not sent.");
            break;
    }
    // Remove the mail view
    [self dismissModalViewControllerAnimated:YES];
}


- (IBAction)invitePushed:(id)sender {
    AppDelegate *delegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    NSArray *topFriends = [[defaults objectForKey:@"top_friends"]subarrayWithRange:NSMakeRange(0, 10)];
    //NSLog(@"Top Friends in facebook: %@", topFriends);
    // for current users I guess
    if (!topFriends)
         topFriends = [[defaults objectForKey:@"friends"]subarrayWithRange:NSMakeRange(0, 10)];
    
    NSMutableDictionary* params =   [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                     [topFriends componentsJoinedByString:@","], @"suggestions", nil];
    //NSLog(@"Active session: %@", [FBSession activeSession]);
    [FBWebDialogs presentRequestsDialogModallyWithSession:[FBSession activeSession]
                                                  message:[NSString stringWithFormat:@"Get Side, the hottest new social discovery app!"]
                                                    title:nil
                                               parameters:params
                                                  handler:^(FBWebDialogResult result, NSURL *resultURL, NSError *error) {
                                                      if (error) {
                                                          // Case A: Error launching the dialog or sending request.
                                                          //NSLog(@"Error sending request.");
                                                      } else {
                                                          if (result == FBWebDialogResultDialogNotCompleted) {
                                                              // Case B: User clicked the "x" icon
                                                              //NSLog(@"User canceled request.");
                                                          } else {
                                                              //NSLog(@"Request Sent.");
                                                          }
                                                      }}];
    

}

- (IBAction)ratePushed:(id)sender {
    // REPLACE WITH OUR URL
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"https://itunes.apple.com/us/app/side/id665955920?ls=1&mt=8"]];
}

- (IBAction)logoutPushed:(id)sender {
  
    //NSLog(@"About to logout");
    
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
    
    delegate.session = [[FBSession alloc] initWithAppID:@"545929018807731" permissions:permissionsArray defaultAudience:nil urlSchemeSuffix:@"app" tokenCacheStrategy:nil];

    
    [self dismissViewControllerAnimated:NO completion:
        ^(void){
            //NSLog(@"Trying to present main feed");
            delegate.tabBarController.selectedViewController = [delegate.tabBarController.viewControllers objectAtIndex:2];
        
        }];
    
    //[(UITabBarController*)self.navigationController.topViewController setSelectedIndex:2];
   
    /*
    LoginViewController *loginViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"loginViewController"];
    [self presentViewController: loginViewController animated: NO completion: nil];
     */
}
@end
