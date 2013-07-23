//
//  LoginViewController.h
//  Mockup
//
//  Created by Nithin Tumma on 6/6/13.
//  Copyright (c) 2013 Neel Patel. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LoginViewController : UIViewController
- (IBAction)loginButtonTouch:(id)sender;
@property (weak, nonatomic) IBOutlet UIButton *loginButton;
@property (weak, nonatomic) IBOutlet UIImageView *dividingBar;
@property (weak, nonatomic) IBOutlet UITextView *loginInfo;
@property (weak, nonatomic) IBOutlet UITextView *connectWith;
@property (weak, nonatomic) IBOutlet UIButton *instructionButton1;
- (IBAction)instructionButtonTouch:(id)sender;

@property (nonatomic, assign) int count;

@property (nonatomic, strong) IBOutlet UIActivityIndicatorView *activityIndicator;
@property (nonatomic, assign) BOOL loggedIn;
@property (nonatomic, assign) BOOL didCompleteProfileInformation;
@property (nonatomic, assign) BOOL didCompleteFriendsInformation;
@property (nonatomic, strong) NSMutableDictionary *userProfile;
@property (nonatomic, strong) NSMutableArray *friendIds;

@property (nonatomic, assign) BOOL tutorialComplete;
@property (nonatomic, assign) BOOL createdUser;

@end
