//
//  PersonalFeedController.h
//  Pave
//
//  Created by Neel Patel on 6/18/13.
//  Copyright (c) 2013 Pave. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UIImageView+WebCache.h"
#import "AboutUGQuestion.h"
#import "MKNumberBadgeView.h"
#import "StatusBar.h"


@interface PersonalFeedController : UIViewController <UITableViewDataSource, UITableViewDelegate>
@property (weak, nonatomic) IBOutlet UINavigationBar *topBar;

@property (weak, nonatomic) IBOutlet UITextView *name;
@property (weak, nonatomic) IBOutlet UIImageView *profile;

@property (weak, nonatomic) IBOutlet UITableView *answers;
@property (weak, nonatomic) IBOutlet UITableView *ugQuestions;
@property (weak, nonatomic) IBOutlet UITableView *recs;

@property (weak, nonatomic) IBOutlet UIView *tableViewBackground;

// store the values of the required instance variables
@property (nonatomic, strong)SDImageCache *myImageCache;
@property (nonatomic, assign)BOOL doneLoadingFeed;

@property (nonatomic, assign)BOOL reloadingUGAnswerObjects;
@property (nonatomic, assign)BOOL reloadingAnswers;
@property (nonatomic, assign)BOOL reloadingInsights;

//stores the list of friend ids (as strings this time)
@property (nonatomic, retain)NSMutableArray *idStrings;

// new properties to prevent crashes 
@property (nonatomic, retain)NSArray *feedObjects;
@property (nonatomic, retain)NSArray *answerObjects;
@property (nonatomic, retain)NSArray *insightObjects;
@property (nonatomic, retain)NSArray *questionObjects;

//stores the image paths
@property (nonatomic, retain)NSArray *paths;
@property (nonatomic, retain)NSString *dataPath;
@property (nonatomic, retain)NSMutableDictionary *imageRequests;
@property (nonatomic,assign) BOOL reloadingFeedObject;

@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *answersLoading;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *insightsLoading;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *questionsLoading;

//stores and changes the current table
@property (nonatomic, retain)NSString *currentTable;
- (IBAction)changeTable:(id)sender;
- (IBAction)viewAnswers:(id)sender;
- (IBAction)viewInsights:(id)sender;
- (IBAction)viewQuestions:(id)sender;

//buttons for changing the table
@property (weak, nonatomic) IBOutlet UIButton *answersButton;
@property (weak, nonatomic) IBOutlet UIButton *insightsButton;
@property (weak, nonatomic) IBOutlet UIButton *questionsButton;

//for the popup
@property (nonatomic, retain)AboutUGQuestion *popup;
@property (strong, nonatomic) UIRefreshControl *refreshControl;
@property (strong, nonatomic) UIRefreshControl *answersRefreshControl;
@property (strong, nonatomic) UIRefreshControl *recsRefreshControl;
@property (strong, nonatomic) UIRefreshControl *ugRefreshControl;

//for the read status of recs and answers
@property (nonatomic, retain)NSMutableDictionary *answerReadStatus;
@property (nonatomic, retain)NSMutableDictionary *recReadStatus;

@property (retain, nonatomic)  MKNumberBadgeView *badge_answers;
@property (retain, nonatomic)  MKNumberBadgeView *badge_ug_answers;
@property (retain, nonatomic)  MKNumberBadgeView *badge_recs;

@property (weak, nonatomic) IBOutlet UITextView *votesTextField;
@property (weak, nonatomic) IBOutlet UITextView *answersTextField;
@property (weak, nonatomic) IBOutlet UITextView *questionsTextField;
@property (weak, nonatomic) IBOutlet UITextView *levelTextField;

- (IBAction)refresh:(id)sender;
- (void)refreshWithPull:(UIRefreshControl *)refreshControl;
- (IBAction)inviteFriends:(id)sender;

@property (nonatomic, retain) StatusBar *sbar;

@end
