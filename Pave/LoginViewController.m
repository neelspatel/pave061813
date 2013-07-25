//
//  LoginViewController.m
//  Mockup
//
//  Created by Nithin Tumma on 6/6/13.
//  Copyright (c) 2013 Neel Patel. All rights reserved.
//

#import "GameController.h"
#import "LoginViewController.h"
#import "AppDelegate.h"
#import "PaveAPIClient.h"
#import "AFNetworking.h"
#import <FacebookSDK/FacebookSDK.h>
#import "MBProgressHUD.h"
#import "WalkthroughViewController.h"

@interface LoginViewController ()

@end

@implementation LoginViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = @"Log In";
    self.didCompleteProfileInformation = NO;
    self.didCompleteFriendsInformation = NO;
    self.loggedIn = NO;
    
    //sets up everything as hidden
    self.instructionButton1.hidden = TRUE;
    self.count = 0;
    /**
    [self.instructionButton1 setBackgroundImage:[UIImage imageNamed:@"instruction1Large.png"] forState: UIControlStateNormal];
    [self.instructionButton1 setBackgroundImage:[UIImage imageNamed:@"instruction1Large.png"] forState: UIControlStateSelected];
    [self.instructionButton1 setBackgroundImage:[UIImage imageNamed:@"instruction1Large.png"] forState: UIControlStateHighlighted];*/
    self.instructionButton1.showsTouchWhenHighlighted = NO;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(tutorialComplete:) name:@"tutorialComplete" object:nil];
    
    self.tutorialComplete = NO;
    self.createdUser = NO;
}

-(void)checkToContinueToGameFeed
{
    NSLog(@"Trying to continue to game feed");
    if (self.tutorialComplete && self.createdUser)
    {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"getFeedObjects"  object:nil userInfo:nil];
        [self dismissViewControllerAnimated:YES completion:^{
            [[NSNotificationCenter defaultCenter] postNotificationName:@"walkthroughComplete" object:self];
        }];

    }
}

-(void)tutorialComplete:(NSNotification *)notification
{
    self.tutorialComplete= YES;
    [self checkToContinueToGameFeed];
}

-(void)serverCreateUserComplete
{
    
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)saveUserFacebookInformation
{

        NSLog(@"about to request user");
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        [defaults setObject:self.userProfile forKey:@"profile"];
        [defaults setObject:self.userProfile[@"facebookId"] forKey:@"id"];
        [defaults synchronize];
    
        // show tutorial screen
    WalkthroughViewController *walkthroughController = [[WalkthroughViewController alloc] initWithNibName:@"WalkthroughViewController" bundle:nil];
    [self presentViewController:walkthroughController animated:YES completion:nil];
    
}

// checks both instance variables to see if the requests went through
-(void) sendSaveUserAndFacebookInformation
{

    if (self.didCompleteProfileInformation && self.didCompleteFriendsInformation) {
        [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, 0.01 * NSEC_PER_SEC);
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
            // Do something...
            [MBProgressHUD hideHUDForView:self.view animated:YES];
        // use the singleton APIClient
            NSLog(@"about to request user");
            
            //splits the friends into id, name, and gender
            NSMutableArray *genders = [[NSMutableArray alloc] init];
            NSMutableArray *friends = [[NSMutableArray alloc] init];
            NSMutableArray *names = [[NSMutableArray alloc] init];
            
            for(id object in self.friendIds)
            {
                [genders addObject:object[@"sex"]];
                [friends addObject:object[@"uid"]];
                [names addObject:object[@"name"]];
            }
            
            
            NSData *jsonProfile = [NSJSONSerialization dataWithJSONObject:self.userProfile options:NSJSONWritingPrettyPrinted error:nil];
            NSString *jsonProfileString = [[NSString alloc] initWithData:jsonProfile encoding:NSUTF8StringEncoding];
            
            NSData *jsonFriends = [NSJSONSerialization dataWithJSONObject:friends options:NSJSONWritingPrettyPrinted error:nil];
            NSString *jsonFriendsString = [[NSString alloc] initWithData:jsonFriends encoding:NSUTF8StringEncoding];
            
            NSData *jsonNames = [NSJSONSerialization dataWithJSONObject:names options:NSJSONWritingPrettyPrinted error:nil];
            NSString *jsonNamesString = [[NSString alloc] initWithData:jsonNames encoding:NSUTF8StringEncoding];
            
            NSData *jsonGenders = [NSJSONSerialization dataWithJSONObject:genders options:NSJSONWritingPrettyPrinted error:nil];
            NSString *jsonGendersString = [[NSString alloc] initWithData:jsonGenders encoding:NSUTF8StringEncoding];
            
            NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys: self.userProfile[@"facebookId"], @"id_facebookID", jsonProfileString,  @"id_profile", jsonFriendsString, @"id_friends", jsonNamesString, @"id_names", jsonGendersString, @"id_genders", nil];
            
            NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
            [defaults setObject:friends forKey:@"friends"];
            [defaults setObject:genders forKey:@"genders"];
            [defaults setObject:names forKey:@"names"];
            [defaults setObject:self.userProfile forKey:@"profile"];
            [defaults setObject:self.userProfile[@"facebookId"] forKey:@"id"];
                    
            [defaults synchronize];
            
            //[self performSegueWithIdentifier:@"loginToHomeScreen" sender:self];

            //NSLog(@"%@", self.userProfile);
            //NSLog(@"%@",  jsonString);
            NSLog(@"Initialized friends as %@", self.friendIds);
            //NSLog(@"%@", [NSJSONSerialization dataWithJSONObject:self.friendIds options:nil error:nil]);
            [[PaveAPIClient sharedClient] postPath:@"/data/newuser"
                                        parameters:params success:^(AFHTTPRequestOperation *operation, id JSON) {
                                            NSLog(@"successfully logged in user to Django");
                                            //now fetches the feed objects
                                            [[NSNotificationCenter defaultCenter] postNotificationName:@"getFeedObjects"  object:nil userInfo:nil];

                                            self.instructionButton1.hidden = FALSE;
                                            
                                        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                            NSLog(@"error logging in user to Django %@", error);
                                        }];
        });
    }

}

-(void) setupFacebookInformation
{
    NSLog(@"Setting up Facebook Information");
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, 0.01 * NSEC_PER_SEC);
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        // Do something...
        self.didCompleteProfileInformation = NO;
        self.didCompleteFriendsInformation = NO;
        // get basic user information and
        FBRequest *request = [FBRequest requestForMe];
        // set a property and call a method to check both properties
        [request startWithCompletionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
            // handle response
            if (!error) {
                [MBProgressHUD hideHUDForView:self.view animated:YES];
                
                // Parse the data received
                NSDictionary *userData = (NSDictionary *)result;
                NSLog(@"Result of profile: %@", result);

                NSString *facebookID = userData[@"id"];
                NSURL *pictureURL = [NSURL URLWithString:[NSString stringWithFormat:@"https://graph.facebook.com/%@/picture?type=large&return_ssl_resources=1", facebookID]];
                self.userProfile = [NSMutableDictionary dictionaryWithCapacity:7];
                if (facebookID) 
                    self.userProfile[@"facebookId"] = facebookID;
                
                
                if (userData[@"name"]) 
                    self.userProfile[@"name"] = userData[@"name"];
                
                
                if (userData[@"location"][@"name"]) 
                    self.userProfile[@"location"] = userData[@"location"][@"name"];
                
                
                if (userData[@"gender"]) 
                    self.userProfile[@"gender"] = userData[@"gender"];
                
                
                if (userData[@"birthday"]) 
                    self.userProfile[@"birthday"] = userData[@"birthday"];
                
                
                if (userData[@"relationship_status"]) 
                    self.userProfile[@"relationship"] = userData[@"relationship_status"];
                
                
                if ([pictureURL absoluteString]) 
                    self.userProfile[@"pictureURL"] = [pictureURL absoluteString];
                
                NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
                AppDelegate* delegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
                
                if (delegate.firstLaunch)
                {
                    [self saveUserFacebookInformation];
                }
                else
                {
                    [self dismissViewControllerAnimated:NO completion:^{
                        
                        [[NSNotificationCenter defaultCenter] postNotificationName:@"getFeedObjects"  object:nil userInfo:nil];
                    }];
                }
                
            } else if ([[[[error userInfo] objectForKey:@"error"] objectForKey:@"type"]
                        isEqualToString: @"OAuthException"]) {
                    // Since the request failed, we can check if it was due to an invalid session
                NSLog(@"The facebook session was invalidated");
            } else {
                NSLog(@"Some other error: %@", error);
            }
        }];
    
    });
}
                   
                   
- (void) finishIntro
{
    [self dismissViewControllerAnimated:NO completion:nil];
}


- (void) initializeFacebookInformation
{
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, 0.01 * NSEC_PER_SEC);
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        // Do something...
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        self.didCompleteProfileInformation = NO;
        self.didCompleteFriendsInformation = NO;
        // get basic user information and
        FBRequest *request = [FBRequest requestForMe];
        
        // add gender and name to the query
        NSString *query =
        @"SELECT uid, name, sex FROM user WHERE uid IN (SELECT uid2 FROM friend WHERE uid1 = me()) ORDER BY mutual_friend_count DESC";
        
        NSString *query2 =
        @"SELECT (uid, gender, name) FROM user WHERE uid IN (SELECT uid2 FROM friend WHERE uid1 = me()) ORDER BY mutual_friend_count DESC";
        
        // Set up the query parameter
        NSDictionary *queryParam = [NSDictionary dictionaryWithObjectsAndKeys:query, @"q", nil];
        // Make the API request that uses FQL
        [FBRequestConnection startWithGraphPath:@"/fql"
                                     parameters:queryParam
                                     HTTPMethod:@"GET"
                              completionHandler:^(FBRequestConnection *connection,
                                                  id result,
                                                  NSError *error) {
                                  if (error) {
                                      NSLog(@"Error while getting facebook friends, retry");
                                  } else {
                                      self.friendIds = [[NSMutableArray alloc] initWithCapacity: [result count]];
                                      
                                      NSArray *parsed = result[@"data"];
                                      
                                      for(id object in parsed)
                                      {
                                          [self.friendIds addObject: object];
                                      }
                                      
                                      self.didCompleteFriendsInformation = YES;
                                      [self sendSaveUserAndFacebookInformation];
                                      
                                      // need to save the active user's values
                                      /*
                                       [[KCSUser activeUser] setValue: ids forAttribute: @"friends"];
                                       [[KCSUser activeUser] saveWithCompletionBlock:^(NSArray *objectsOrNil, NSError *errorOrNil) {
                                       NSLog(@"shit happens");
                                       }]; */
                                      
                                  }
                              }];
        
        // set a property and call a method to check both properties
        [request startWithCompletionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
            // handle response
            if (!error) {
                // Parse the data received
                NSDictionary *userData = (NSDictionary *)result;
                NSString *facebookID = userData[@"id"];
                NSURL *pictureURL = [NSURL URLWithString:[NSString stringWithFormat:@"https://graph.facebook.com/%@/picture?type=large&return_ssl_resources=1", facebookID]];
                self.userProfile = [NSMutableDictionary dictionaryWithCapacity:7];
                if (facebookID) {
                    self.userProfile[@"facebookId"] = facebookID;
                }
                
                if (userData[@"name"]) {
                    self.userProfile[@"name"] = userData[@"name"];
                }
                
                if (userData[@"location"][@"name"]) {
                    self.userProfile[@"location"] = userData[@"location"][@"name"];
                }
                
                if (userData[@"gender"]) {
                    self.userProfile[@"gender"] = userData[@"gender"];
                }
                
                if (userData[@"birthday"]) {
                    self.userProfile[@"birthday"] = userData[@"birthday"];
                }
                
                if (userData[@"relationship_status"]) {
                    self.userProfile[@"relationship"] = userData[@"relationship_status"];
                }
                
                if ([pictureURL absoluteString]) {
                    self.userProfile[@"pictureURL"] = [pictureURL absoluteString];
                }

          
                self.didCompleteProfileInformation = YES;
                [self sendSaveUserAndFacebookInformation];
                
                //[[KCSUser activeUser] setValue: userProfile forAttribute: @"profile"];
                
            } else if ([[[[error userInfo] objectForKey:@"error"] objectForKey:@"type"]
                        isEqualToString: @"OAuthException"]) { // Since the request failed, we can check if it was due to an invalid session
                NSLog(@"The facebook session was invalidated");
            } else {
                NSLog(@"Some other error: %@", error);
            }
        }];
    });
}


- (IBAction)loginButtonTouch:(id)sender {
    
    
    AppDelegate* delegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    FBSession* session = [delegate session];
    
    NSLog(@"About to login");
    // login Facebook User
    
    if(session.state == 513 || session.state == 258 || session.state == 257)
    {
        NSLog(@"In session.state comparison view login");
        NSArray *permissionsArray = @[ @"email", @"user_likes", @"user_interests", @"user_about_me", @"user_birthday", @"friends_about_me", @"friends_interests", @"read_stream"];
        
        // might be crashing here
        [FBSession.activeSession closeAndClearTokenInformation];
        [FBSession.activeSession close];
        [FBSession setActiveSession:nil];
        
        [delegate setSession:[[FBSession alloc] initWithAppID:@"545929018807731" permissions:permissionsArray defaultAudience:nil urlSchemeSuffix:nil tokenCacheStrategy:nil]];
        session = [delegate session];        
    }
    
    NSLog(@"in login controller Session is %@", session);
    NSLog(@"in login controller Status is %u", session.state);
    
    NSArray *permissionsArray = @[ @"email", @"user_likes", @"user_interests", @"user_about_me", @"user_birthday", @"friends_about_me", @"friends_interests", @"read_stream"];

    [delegate setSession:[[FBSession alloc] initWithAppID:@"545929018807731" permissions:permissionsArray defaultAudience:nil urlSchemeSuffix:nil tokenCacheStrategy:nil]];
    session = [delegate session];

        [session openWithCompletionHandler:^(FBSession *session, FBSessionState status, NSError *error) {
            NSLog(@"Session is in loginButtonTouch: %@", session);
            if (status == FBSessionStateOpen) {
                [FBSession setActiveSession:session];
                NSString* accessToken = session.accessTokenData.accessToken;
                NSLog(@"Finished login");
                
                NSLog(@"Accesstoken: %@", accessToken);
                                
                //saves and updates data
                [self setupFacebookInformation];
                NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys: accessToken, @"access_token", nil];

                [[PaveAPIClient sharedClient] postPath:@"/data/createuser"
                                            parameters:params success:^(AFHTTPRequestOperation *operation, id JSON) {
                                                NSLog(@"created user");
                                               // NSLog(@"JSON for create user: %@", JSON);
                                                NSDictionary *results = JSON;
                                                NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
                                                [defaults setObject:[results objectForKey:@"friends"] forKey:@"friends"];
                                                [defaults setObject:[results objectForKey:@"genders"] forKey:@"genders"];
                                                [defaults setObject:[results objectForKey:@"names"] forKey:@"names"];
                                                [defaults setObject:[results objectForKey:@"top_friends"] forKey:@"top_friends"];

                                                [defaults synchronize];
                                                
                                                self.createdUser = YES;
                                                
                                                [self checkToContinueToGameFeed];

                                                //self.instructionButton1.hidden = FALSE;
                                                
                                            } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                                NSLog(@"error creating user %@", error);
                                            }];

                //hides elements on screen
                self.loginButton.hidden = TRUE;
                self.dividingBar.hidden = TRUE;
                self.loginInfo.hidden = TRUE;
                self.connectWith.text = @"Awesome! We're logging you in now.";
            }
            else
            {
                NSLog(@"In Login Block");
                NSLog(@"Session: %@", session);
                NSLog(@"Status in login block is: %u", status);
            }
        }];
        NSLog(@"Exited block");
    
}

- (IBAction)instructionButtonTouch:(id)sender {
    if (self.count == 0)
    {
        self.count += 1;
        [self.instructionButton1 setBackgroundImage:[UIImage imageNamed:@"instruction2Large.png"] forState: UIControlStateNormal];
        [self.instructionButton1 setBackgroundImage:[UIImage imageNamed:@"instruction2Large.png"] forState: UIControlStateSelected];
        [self.instructionButton1 setBackgroundImage:[UIImage imageNamed:@"instruction2Large.png"] forState: UIControlStateHighlighted];
        
        
    } else {

        [self dismissViewControllerAnimated:NO completion:nil];

    }
    
}
@end
