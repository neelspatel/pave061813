//
//  TrainingController.h
//  Pave
//
//  Created by Neel Patel on 7/18/13.
//  Copyright (c) 2013 Pave. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UIImageView+WebCache.h"
#import "StatusBar.h"

@interface TrainingController : UIViewController

- (IBAction)skip:(id)sender;
- (IBAction)leftTap:(id)sender;
- (IBAction)rightTap:(id)sender;

@property (weak, nonatomic) IBOutlet UILabel *question;
@property (weak, nonatomic) IBOutlet UIImageView *profilePicture;
@property (weak, nonatomic) IBOutlet UIImageView *leftProduct;
@property (weak, nonatomic) IBOutlet UIImageView *rightProduct;

@property (assign, nonatomic) UIImageView *check;

@property(nonatomic, assign) NSInteger leftProductId;
@property(nonatomic, assign) NSInteger rightProductId;
@property(nonatomic, assign) NSInteger questionId;
@property(nonatomic, copy) NSString *questionText;
@property(nonatomic, copy) NSString *currentId;

// store the values of the required instance variables
@property (nonatomic, retain)NSMutableArray *feedObjects;
@property (nonatomic, retain)NSMutableDictionary *readStatus;
@property (nonatomic, strong)SDImageCache *myImageCache;
@property (nonatomic, assign)BOOL doneLoadingFeed;

//stores the image paths
@property (nonatomic, retain)NSArray *paths;
@property (nonatomic, retain)NSString *dataPath;
@property (nonatomic, retain)NSMutableDictionary *imageRequests;
@property (nonatomic, assign)BOOL reloadingFeedObject;

//stores the current object number
@property(nonatomic, assign) NSInteger currentNumber;

@property (nonatomic, retain) StatusBar *sbar;

@property (weak, nonatomic) IBOutlet UIImageView *rightCheck;
@property (weak, nonatomic) IBOutlet UIImageView *leftCheck;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *leftActivityIndicator;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *rightActivityIndicator;

@end
