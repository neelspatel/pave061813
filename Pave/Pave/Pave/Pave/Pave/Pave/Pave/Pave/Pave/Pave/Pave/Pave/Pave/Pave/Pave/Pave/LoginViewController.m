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
    self.instruction1.hidden = TRUE;
    self.instruction2.hidden = TRUE;
    
    
    self.instruction1.userInteractionEnabled = YES;
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self.instruction1 action:@selector(showScreenTwo)];
    [self.instruction1 addGestureRecognizer:tapGesture];

    self.instruction2.userInteractionEnabled = YES;
    UITapGestureRecognizer *tapGesture2 = [[UITapGestureRecognizer alloc] initWithTarget:self.instruction2 action:@selector(finishIntro)];
    [self.instruction2 addGestureRecognizer:tapGesture2];
    
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
             //                            parameters:@{@"id_facebookID":self.userProfile[@"facebookId"], @"id_profile": self.userProfile, @"friends": self.friendIds} success:^(AFHTTPRequestOperation *operation, id JSON) {
                                        parameters:params success:^(AFHTTPRequestOperation *operation, id JSON) {
                                            NSLog(@"successfully logged in user to Django");
                                            //now fetches the feed objects
                                            [[NSNotificationCenter defaultCenter] postNotificationName:@"getFeedObjects"  object:nil userInfo:nil];

                                            [self showScreenOne];
                                            
                                        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                            NSLog(@"error logging in user to Django %@", error);
                                        }];
        });
    }

}

- (void) showScreenOne
{
    self.instruction1.hidden = FALSE;
}

- (void) showScreenTwo
{
    self.instruction1.hidden = TRUE;
    self.instruction2.hidden = FALSE;
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
        NSArray *permissionsArray = @[ @"user_about_me", @"user_relationships", @"user_birthday", @"user_location"];
        
        [FBSession.activeSession closeAndClearTokenInformation];
        [FBSession.activeSession close];
        [FBSession setActiveSession:nil];
        
        [delegate setSession:[[FBSession alloc] initWithAppID:@"545929018807731" permissions:permissionsArray defaultAudience:nil urlSchemeSuffix:nil tokenCacheStrategy:nil]];
        session = [delegate session];        
    }
    
    NSLog(@"Session is %@", session);
    NSLog(@"Status is %u", session.state);
    
    
        [session openWithCompletionHandler:^(FBSession *session, FBSessionState status, NSError *error) {
            [FBSession setActiveSession:session];
            if (status == FBSessionStateOpen) {
                NSString* accessToken = session.accessToken;
                /**
                 [KCSUser loginWithSocialIdentity:KCSSocialIDFacebook accessDictionary:@{KCSUserAccessTokenKey : accessToken} withCompletionBlock:^(KCSUser *user, NSError *errorOrNil, KCSUserActionResult result) {
                 NSLog(@"Finished login");
                 
                 NSLog(@"Accesstoken: %@", accessToken);
                 
                 //saves and updates data
                 [self initializeFacebookInformation];
                 [self performSegueWithIdentifier:@"loginToHomeScreen" sender:self];
                 }];
                 */
                NSLog(@"Finished login");
                
                NSLog(@"Accesstoken: %@", accessToken);
                                
                //saves and updates data
                [self initializeFacebookInformation];
                
                //hides elements on screen
                self.loginButton.hidden = TRUE;
                self.dividingBar.hidden = TRUE;
                self.loginInfo.hidden = TRUE;
                self.connectWith.text = @"Awesome! We're logging you in now.";
            }
            else
            {
                NSLog(@"Session: %@", session);
                NSLog(@"Some other status: %u", status);
            }
        }];
        NSLog(@"Exited block");
    
}

@end
