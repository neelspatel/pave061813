//
//  TrendingObjectCell.m
//  Pave
//
//  Created by Neel Patel on 6/19/13.
//  Copyright (c) 2013 Pave. All rights reserved.
//

#import "TrendingObjectCell.h"
#import "AppDelegate.h"

@implementation TrendingObjectCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

-(void)showFBRequest: (NSString*) currentId
{
    NSMutableDictionary* paramsForFB =   [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                          // 2. Optionally provide a 'to' param to direct the request at
                                          currentId, @"to", @"true", @"new_style_message", @"Hey, get Pave!", @"message", @"apprequests", @"method", // Ali
                                          nil];
    //NSMutableDictionary* paramsForFB =   [NSMutableDictionary dictionaryWithObjectsAndKeys:nil];
    
    AppDelegate* delegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    FBSession* session = delegate.session;
    
    //NSLog(@"Session in post to fb is %@", session);
        
    // Prepare the native share dialog parameters
    FBShareDialogParams *shareParams = [[FBShareDialogParams alloc] init];
    shareParams.link = [NSURL URLWithString:@"https://getsideapp.com"];
    shareParams.name = @"Side App";
    shareParams.caption= @"Discover yourself.";
    shareParams.picture= [NSURL URLWithString:@"https://getsideapp.com/icon.png"];
    shareParams.description = @"Answer quick, 2-choice questions about your closest Facebook friends and see all of their answers about you. Get answers, give feedback, and learn about yourself. Plus, it’s fun!";
    
    /**
    if ([FBDialogs canPresentShareDialogWithParams:shareParams]){
        
        [FBDialogs presentShareDialogWithParams:shareParams
                                    clientState:nil
                                        handler:^(FBAppCall *call, NSDictionary *results, NSError *error) {
                                            if(error) {
                                                //NSLog(@"Error publishing story.");
                                            } else if (results[@"completionGesture"] && [results[@"completionGesture"] isEqualToString:@"cancel"]) {
                                                //NSLog(@"User canceled story publishing.");
                                            } else {
                                                //NSLog(@"Story published.");
                                            }
                                        }];
        
    }else {
        
        // Prepare the web dialog parameters
        NSDictionary *params = @{
                                 @"name" : shareParams.name,
                                 @"caption" : shareParams.caption,
                                 @"description" : shareParams.description,
                                 @"picture" : @"https://getsideapp.com/icon.png",
                                 @"link" : @"https://getsideapp.com"
                                 };
        
        // Invoke the dialog
        [FBWebDialogs presentFeedDialogModallyWithSession:nil
                                               parameters:params
                                                  handler:
         ^(FBWebDialogResult result, NSURL *resultURL, NSError *error) {
             if (error) {
                 //NSLog(@"Error publishing story.");
             } else {
                 if (result == FBWebDialogResultDialogNotCompleted) {
                     //NSLog(@"User canceled story publishing.");
                 } else {
                     //NSLog(@"Story published.");
                 }
             }}];
    }
    */
    
    //force web dialog
    // Prepare the web dialog parameters
    NSDictionary *params = @{
                             @"name" : shareParams.name,
                             @"caption" : shareParams.caption,
                             @"description" : shareParams.description,
                             @"picture" : @"https://getsideapp.com/icon.png",
                             @"link" : @"https://itunes.apple.com/us/app/side/id665955920?ls=1&mt=8"
                             };
    
    // Invoke the dialog
    [FBWebDialogs presentFeedDialogModallyWithSession:session
                                           parameters:params
                                              handler:
     ^(FBWebDialogResult result, NSURL *resultURL, NSError *error) {
         if (error) {
             //NSLog(@"Error publishing story.");
         } else {
             if (result == FBWebDialogResultDialogNotCompleted) {
                 //NSLog(@"User canceled story publishing.");
             } else {
                 //NSLog(@"Story published.");
             }
         }}];
    
    
}

- (IBAction)leftSend:(id)sender {
    [self showFBRequest:self.currentId];
}

- (IBAction)rightSend:(id)sender {
    [self showFBRequest:self.currentId];
}
@end
