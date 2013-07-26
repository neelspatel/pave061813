//
//  ConfirmationViewController.m
//  Pave
//
//  Created by Nithin Tumma on 7/25/13.
//  Copyright (c) 2013 Pave. All rights reserved.
//

#import "ConfirmationViewController.h"
#import "AppDelegate.h"
#import "Flurry.h"
#import <MessageUI/MessageUI.h>
#import <FacebookSDK/FacebookSDK.h>


@interface ConfirmationViewController ()

@end

@implementation ConfirmationViewController

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
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)completeButtonPushed:(id)sender {
    NSLog(@"About to get out of here");
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)inviteFriends:(id)sender {
    AppDelegate *delegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    NSArray *topFriends = [[defaults objectForKey:@"top_friends"]subarrayWithRange:NSMakeRange(0, 10)];
    NSLog(@"Top Friends in facebook: %@", topFriends);
    // for current users I guess
    if (!topFriends)
        topFriends = [[defaults objectForKey:@"friends"]subarrayWithRange:NSMakeRange(0, 10)];
    
    NSMutableDictionary* params =   [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                     [topFriends componentsJoinedByString:@","], @"suggestions", nil];
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithObject:self.questionText forKey:@"question"];
    [Flurry logEvent:@"Invite Friends UGC" withParameters:dict timed:YES];
    NSLog(@"Active session: %@", [FBSession activeSession]);
    [FBWebDialogs presentRequestsDialogModallyWithSession:[FBSession activeSession]
                                                  message:[NSString stringWithFormat:@"Download Side to see personal recommendations based on questions your friends are answering about you!"]
                                                    title:@"Side - Friend Powered Recommendations"
                                               parameters:params
                                                  handler:^(FBWebDialogResult result, NSURL *resultURL, NSError *error) {
                                                      if (error) {
                                                          // Case A: Error launching the dialog or sending request.
                                                          NSLog(@"Error sending request.");
                                                          [dict setObject:@"True" forKey:@"Failed"];
                                                          [Flurry endTimedEvent:@"Invite Friends UGC" withParameters:dict];
                                                      } else {
                                                          if (result == FBWebDialogResultDialogNotCompleted) {
                                                              // Case B: User clicked the "x" icon
                                                              NSLog(@"User canceled request.");
                                                              [dict setObject:@"True" forKey:@"Cancelled"];
                                                              [Flurry endTimedEvent:@"Invite Friends UGC" withParameters:dict];

                                                          } else {
                                                              NSLog(@"Request Sent.");
                                                              [dict setObject:@"True" forKey:@"Sent"];
                                                              [Flurry endTimedEvent:@"Invite Friends UGC" withParameters:dict];

                                                          }
                                                      }}];
    

}

- (IBAction)sendToSide:(id)sender {
}

- (IBAction)shareQuestion:(id)sender {
    
    AppDelegate* delegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    FBSession* session = delegate.session;
        
    // Prepare the native share dialog parameters
    FBShareDialogParams *shareParams = [[FBShareDialogParams alloc] init];
    shareParams.link = [NSURL URLWithString:@"https://itunes.apple.com/us/app/side/id665955920?ls=1&mt=8"];
    shareParams.name = @"Side";
    shareParams.caption= @"Friend-powered recommendations.";
    shareParams.picture= [NSURL URLWithString:@"http://getsideapp.com/icon.png"];
    
    shareParams.description = [NSString stringWithFormat:@"I just asked \"%@\" on Side. What do you think?", currentObject[@"question_text"]];;
    
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithObject:self.questionText forKey:@"text"];
    [Flurry logEvent:@"Question Facebook Timeline" withParameters:dict timed:YES];
    if ([FBDialogs canPresentShareDialogWithParams:shareParams]){
        
        [FBDialogs presentShareDialogWithParams:shareParams
                                    clientState:nil
                                        handler:^(FBAppCall *call, NSDictionary *results, NSError *error) {
                                            if(error) {
                                                NSLog(@"Error publishing story.");
                                                [dict setObject:@"True" forKey:@"Failed"];
                                                [Flurry endTimedEvent:@"Question Facebook Timeline" withParameters:dict];
                                            } else if (results[@"completionGesture"] && [results[@"completionGesture"] isEqualToString:@"cancel"]) {
                                                NSLog(@"User canceled story publishing.");
                                                [dict setObject:@"True" forKey:@"Cancelled"];
                                                [Flurry endTimedEvent:@"Question Facebook Timeline" withParameters:dict];

                                            } else {
                                                [dict setObject:@"True" forKey:@"Completed"];
                                                [Flurry endTimedEvent:@"Question Facebook Timeline" withParameters:dict];
                                            }
                                        }];
        
    }else {
        NSLog(@"On web dialog");
        
        // Prepare the web dialog parameters
        NSDictionary *params = @{
                                 @"name" : shareParams.name,
                                 @"caption" : shareParams.caption,
                                 @"description" : shareParams.description,
                                 @"picture" : shareParams.picture,
                                 @"link" : shareParams.link;
                                 };
        
        // Invoke the dialog
        [FBWebDialogs presentFeedDialogModallyWithSession:nil
                                               parameters:params
                                                  handler:
         ^(FBWebDialogResult result, NSURL *resultURL, NSError *error) {
             if (error) {
                 [dict setObject:@"True" forKey:@"Failed"];
                 [Flurry endTimedEvent:@"Question Facebook Timeline" withParameters:dict];
                 NSLog(@"Error publishing story.");
             } else {
                 if (result == FBWebDialogResultDialogNotCompleted) {
                     NSLog(@"User canceled story publishing.");
                     [dict setObject:@"True" forKey:@"Cancelled"];
                     [Flurry endTimedEvent:@"Question Facebook Timeline" withParameters:dict];
                 } else {
                     NSLog(@"Story published.");
                     [dict setObject:@"True" forKey:@"Completed"];
                     [Flurry endTimedEvent:@"Question Facebook Timeline" withParameters:dict];
                 }
             }}];
    }

}

- (void)mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error
{
    switch (result)
    {
        case MFMailComposeResultCancelled:
            NSLog(@"Mail cancelled: you cancelled the operation and no email message was queued.");
            break;
        case MFMailComposeResultSaved:
            NSLog(@"Mail saved: you saved the email message in the drafts folder.");
            break;
        case MFMailComposeResultSent:
            NSLog(@"Mail send: the email message is queued in the outbox. It is ready to send.");
            break;
        case MFMailComposeResultFailed:
            NSLog(@"Mail failed: the email message was not saved or queued, possibly due to an error.");
            break;
        default:
            NSLog(@"Mail not sent.");
            break;
    }
    // Remove the mail view
    [self dismissModalViewControllerAnimated:YES];
}


- (IBAction)askUs:(id)sender {
    NSLog(@"Calledemail");
    MFMailComposeViewController *mailer = [[MFMailComposeViewController alloc] init];
    mailer.mailComposeDelegate = self;
    [mailer setSubject:@"Question From Your Favorite User"];
    NSArray *toRecipients = [NSArray arrayWithObjects:@"getsideapp@gmail.com", nil];
    [mailer setToRecipients:toRecipients];
    NSString *toPrepend = @"<div style = 'font-size: 10px;'> Side, I answer your questions all of the time. Now it's your turn. What do you think:</div>";
    NSString *toAppend = [NSString stringWithFormat:@"<div style = 'font-size:15px;'> %@ </div>", self.questionText];
    NSString *emailBody = [toPrepend stringByAppendingString: toAppend];
    [mailer setMessageBody:emailBody isHTML:YES];
    [self presentModalViewController:mailer animated:YES];
    
}
- (IBAction)shareOnFacebook:(id)sender {
}

- (IBAction)inviteFriends:(id)sender {
}
@end
