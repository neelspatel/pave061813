//
//  FeedObjectCell.m
//  Mockup
//
//  Created by Neel Patel on 6/14/13.
//  Copyright (c) 2013 Neel Patel. All rights reserved.
//

#import "FeedObjectCell.h"
#import <QuartzCore/QuartzCore.h>
#import "AppDelegate.h"


@implementation FeedObjectCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        NSLog(@"Just called init");
        self.leftBackground.layer.cornerRadius = 10;
        self.leftBackground.clipsToBounds = YES;
        self.rightBackground.layer.cornerRadius = 10;
        self.rightBackground.clipsToBounds = YES;
        self.profilePictureBackground.layer.cornerRadius = 10;
        self.profilePictureBackground.clipsToBounds = YES;
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

-(IBAction) submitLeft:(id)sender
{
    NSLog(@"Just submitted left");
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
    
    NSLog(@"Session in post to fb is %@", session);
    
    
    [FBWebDialogs presentRequestsDialogModallyWithSession:session
          message:@"Ever wondered what people think about you? I'll tell you if you download Side!" title:nil parameters:paramsForFB handler:^(FBWebDialogResult result, NSURL *resultURL, NSError *error) {
              if (error) {
                  NSLog(@"Error");
                  // Case A: Error launching the dialog or sending request.
              } else {
                  if (result == FBWebDialogResultDialogNotCompleted) {
                      //Case B: User clicked the "x" icon
                      NSLog(@"closed");
                  } else {
                      NSLog(@"Sent");
                      //Case C: Dialog shown and the user clicks Cancel or Send
                  }
              }
          }];
}

- (IBAction)leftFacebookNotify:(id)sender {
    [self showFBRequest:self.currentId];
    
}

- (IBAction)rightFacebookNotify:(id)sender {
    [self showFBRequest:self.currentId];
    
}
@end
