//
//  TrainingController.m
//  Pave
//
//  Created by Neel Patel on 7/18/13.
//  Copyright (c) 2013 Pave. All rights reserved.
//

#import "TrainingController.h"
#import "PaveAPIClient.h"
#import "UIImageView+WebCache.h"
#import "SDImageCache.h"
#import "MBProgressHUD.h"
#import "StatusBar.h"
#import "NotificationPopupView.h"
#import "Flurry.h"

@interface TrainingController ()

@end

@implementation TrainingController

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
    [self setUpStatusBar];
    //loads image cache
    self.myImageCache = [SDImageCache.alloc initWithNamespace:@"FeedObjects"];
    
    self.feedObjects = [NSMutableArray array];
    self.readStatus = [[NSMutableDictionary alloc] init];
    
    self.imageRequests = [[NSMutableDictionary alloc] init];
    self.reloadingFeedObject = NO;
    
    //sets the current number
    self.currentNumber = 0;
    [self reloadData];
}

- (void) setUpStatusBar
{
    self.sbar = [StatusBar statusBarCreate];
    [self.sbar redrawBar];
    self.sbar.frame = CGRectMake(0, 37, self.sbar.frame.size.width, self.sbar.frame.size.height);
    [self.view addSubview:self.sbar];
}

- (void)viewWillAppear:(BOOL)animated
{
    [self.sbar redrawBar];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(requestInsight:) name:@"insightReady" object:nil];
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    //first reload the data
    NSLog(@"View did appear in training");
    //[self reloadData];
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:[defaults objectForKey:@"id"] , @"user_id", nil];
    [Flurry logEvent:@"Sprint Time" withParameters:params timed:YES];
    [super viewDidDisappear:animated];
}

-(void) viewWillDisappear:(BOOL) animated
{
    NSLog(@"Leaving and cancelling");
    [[NSNotificationCenter defaultCenter] removeObserver: self name:@"insightReady" object:nil];
    [self.profilePicture cancelCurrentImageLoad];
    [self.rightProduct cancelCurrentImageLoad];
    [self.leftProduct cancelCurrentImageLoad];
    [Flurry endTimedEvent:@"Sprint Time" withParameters:nil];
    [super viewWillDisappear:animated];
}


-(void) requestInsight:(NSNotification *) notification
{
    NSLog(@"Getting called request insight");
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    // hit the endpoint
    NSString *path = @"/data/getnewrec/";
    path = [path stringByAppendingString:[defaults objectForKey:@"id"]];
    path = [path stringByAppendingString:@"/"];
    
    [[PaveAPIClient sharedClient] postPath:path parameters:nil success:^(AFHTTPRequestOperation *operation, id results) {
        if (results)
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self createNotificationPopup:[NSDictionary dictionaryWithObjectsAndKeys:[[results objectForKey:@"text"] stringValue], @"rec_text", nil]];
            });
        }
    }
                                   failure: ^(AFHTTPRequestOperation *operation, NSError *error) {
                                       NSLog(@"Failure while getting rec");
                                   }
     ];
    [Flurry logEvent: @"Notification requested"];
}

-(void)createNotificationPopup:(NSDictionary *) data
{
    NotificationPopupView *notificationPopup = [NotificationPopupView notificationPopupCreateWithData:data];
    [self.view addSubview:notificationPopup];
}


//skips to the next one
- (IBAction)skip:(id)sender
{
    NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:self.questionId], @"question_id", nil];
    [Flurry logEvent:@"Sprint Skipped" withParameters:params];
    //cancels any requests if they are still out
    [self.profilePicture cancelCurrentImageLoad];
    [self.rightProduct cancelCurrentImageLoad];
    [self.leftProduct cancelCurrentImageLoad];
    
    NSLog(@"About to clear all vars");
    
    //clears the data on screen (just in case...)
    self.question.text = @"";
    self.leftProductId = 0;
    self.rightProductId = 0;
    self.questionId = 0;
    
    //increments the count
    self.currentNumber += 1;

    NSLog(@"About to refresh");
    [self refreshScreen];
}

//detects taps
- (IBAction)leftTap:(id)sender
{
    NSLog(@"Just tapped the left one...");
    [self answer:@"left"];
}

//detects taps
- (IBAction)rightTap:(id)sender
{
    NSLog(@"Just tapped the right one...");
    [self answer:@"right"];    
}

- (void) answer:(NSString *) side
{
    NSDictionary *params;
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];

    if([side isEqualToString:@"left"])
    {
        //displays an image
        /*
        UIImageView *imgView = [[UIImageView alloc] initWithFrame:CGRectMake(40, 240, 100, 50)];
        imgView.image = [UIImage imageNamed:@"BLUE_CREATE.png"];
        self.check = imgView;
        [self.view addSubview: self.check];
        */
        self.rightCheck.hidden = NO;
        
        params = [NSDictionary dictionaryWithObjectsAndKeys: [defaults objectForKey:@"id"], @"id_facebookID", [defaults objectForKey:@"id"], @"id_forFacebookID", [NSString stringWithFormat:@"%d", self.leftProductId], @"id_chosenProduct", [NSString stringWithFormat:@"%d", self.rightProductId], @"id_wrongProduct", [NSString stringWithFormat:@"%d", self.questionId], @"id_question", @"true", @"is_training", nil];
    }
    else
    {
        //displays an image
        /*
        UIImageView *imgView = [[UIImageView alloc] initWithFrame:CGRectMake(195, 240, 100, 50)];
        imgView.image = [UIImage imageNamed:@"BLUE_CREATE.png"];
        self.check = imgView;
        [self.view addSubview: self.check];        
        */
        self.leftCheck.hidden = NO;
        
        params = [NSDictionary dictionaryWithObjectsAndKeys: [defaults objectForKey:@"id"], @"id_facebookID", [defaults objectForKey:@"id"], @"id_forFacebookID", [NSString stringWithFormat:@"%d", self.rightProductId], @"id_chosenProduct", [NSString stringWithFormat:@"%d", self.leftProductId], @"id_wrongProduct", [NSString stringWithFormat:@"%d", self.questionId], @"id_question", @"true", @"is_training", nil];
    }
    
    NSLog(@"params;%@", params);
    
    [[PaveAPIClient sharedClient] postPath:@"/data/newanswer"
                                parameters:params success:^(AFHTTPRequestOperation *operation, id JSON) {
                                    NSLog(@"successfully saved answer");
                                    [self refreshScreen];
                                    
                                    
                                } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                    NSLog(@"error saving answer %@", error);
                                    [self refreshScreen];
                                }];
    
}

- (void)refreshScreen
{
    //if we're in the process of reloading, wait 10 sec and try again
    if(self.reloadingFeedObject)
    {
        NSLog(@"Refreshing right now");
        //[self performSelector:@selector(refreshScreen) withObject:nil afterDelay:0.5];
    }
    else if(self.currentNumber < self.feedObjects.count) //otherwise if we have the data
    {
        //cancel the old requests
        [self.leftProduct cancelCurrentImageLoad];
        [self.rightProduct cancelCurrentImageLoad];
        
        NSLog(@"We have the data");
        NSMutableDictionary *currentObject = [self.feedObjects objectAtIndex:self.currentNumber];
        
        self.question.text = currentObject[@"questionText"];
        //self.question.text = [NSString stringWithFormat:@"%d out of %d", self.currentNumber, self.feedObjects.count];
        self.leftProductId = [(currentObject[@"product1"]) integerValue];
        self.rightProductId = [(currentObject[@"product2"]) integerValue];
        self.questionId = [(currentObject[@"currentQuestion"]) integerValue];
        
        //sets images
        [UIView transitionWithView:self.view
                          duration:0.2f
                           options:UIViewAnimationOptionTransitionCrossDissolve
                        animations:^{

                            self.rightCheck.hidden = YES;
                            self.leftCheck.hidden = YES;
/*
                            @try {
                                // Try something
                                [self.check removeFromSuperview];
                            }
                            @catch (NSException * e) {
                                NSLog(@"Exception: %@", e);
                            }
*/
                            
                            self.leftProduct.userInteractionEnabled = NO;
                            self.rightProduct.userInteractionEnabled = YES;
                            [self.leftActivityIndicator startAnimating];
                            [self.rightActivityIndicator startAnimating];

                            [self.leftProduct setImageWithURL:[NSURL URLWithString:currentObject[@"image1"]] placeholderImage:[UIImage imageNamed:@"profile_icon.png"] completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType) {
                                self.leftProduct.userInteractionEnabled = YES;
                                [self.leftActivityIndicator stopAnimating];

                            }];
                            [self.rightProduct setImageWithURL:[NSURL URLWithString:currentObject[@"image2"]] placeholderImage:[UIImage imageNamed:@"profile_icon.png"] completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType) {
                                self.rightProduct.userInteractionEnabled = YES;
                                [self.rightActivityIndicator stopAnimating];
                            }];
                        } completion:nil];
        
        
        self.currentNumber += 1;
        
    }
    else //if we ran out of data
    {
        NSLog(@"Getting new data - ran out");
        [self reloadData];
    }
}

- (void)reloadData
{
    NSLog(@"Getting feed objects now in training");
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    
    self.reloadingFeedObject = YES;
    // Do something...
    [MBProgressHUD hideHUDForView:self.view animated:YES];
    
    
    NSLog(@"About to get feed objects");
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    //NSString *path = @"/data/getlistquestions/";
    NSString *path = @"/data/traininggetlistquestions/";
    
    path = [path stringByAppendingString:[defaults objectForKey:@"id"]];
    //path = [path stringByAppendingString:@"1"];
    path = [path stringByAppendingString:@"/"];
    NSLog(@"Path is %@", path);
    
    [[PaveAPIClient sharedClient] postPath:path parameters:nil success:^(AFHTTPRequestOperation *operation, id results) {
        if (results) {
            //NSMutableArray *ids = [[NSMutableArray alloc] init];
            //for(NSDictionary *current in results)
            //{
            //    [ids addObject:current[@"id"]];
            //}
            NSLog(@"Just finished getting results: %@", results);
            self.feedObjects = [self.feedObjects arrayByAddingObjectsFromArray:results];
            NSLog(@"Just finished getting feed ids: %@", self.feedObjects);
            self.reloadingFeedObject = NO;

            [self refreshScreen];
            
        } }
                                   failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                       NSLog(@"error getting feed objects from database %@", error);
                                   }];


}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
