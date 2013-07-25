//
//  FeedObjectCell.h
//  Mockup
//
//  Created by Neel Patel on 6/14/13.
//  Copyright (c) 2013 Neel Patel. All rights reserved.
//

#import <UIKit/UIKit.h>
//#import <FacebookSDK/FacebookSDK.h>

@interface FeedObjectCell : UITableViewCell


@property (weak, nonatomic) IBOutlet UILabel *question;
@property (weak, nonatomic) IBOutlet UIImageView *profilePicture;
@property (weak, nonatomic) IBOutlet UIImageView *leftProduct;
@property (weak, nonatomic) IBOutlet UIImageView *rightProduct;
@property (weak, nonatomic) IBOutlet UIImageView *onOffButton;

- (IBAction)switched:(id)sender;

@property (weak, nonatomic) IBOutlet UIImageView *leftCheck;
@property (weak, nonatomic) IBOutlet UIImageView *leftX;
@property (weak, nonatomic) IBOutlet UIImageView *rightCheck;
@property (weak, nonatomic) IBOutlet UIImageView *rightX;
@property (weak, nonatomic) IBOutlet UILabel *leftLabel;
@property (weak, nonatomic) IBOutlet UILabel *leftNum;
@property (weak, nonatomic) IBOutlet UILabel *rightNum;
@property (weak, nonatomic) IBOutlet UILabel *rightLabel;

@property (weak, nonatomic) IBOutlet UITextView *responseCount;
@property (weak, nonatomic) IBOutlet UIButton *facebookButton;

- (IBAction)facebookNotify:(id)sender;

@property(nonatomic, assign) NSInteger leftFriendId;
@property(nonatomic, assign) NSInteger rightFriendId;
@property(nonatomic, assign) NSInteger leftProductId;
@property(nonatomic, assign) NSInteger rightProductId;
@property(nonatomic, assign) NSInteger questionId;
@property(nonatomic, copy) NSString *questionText;
@property(nonatomic, copy) NSString * currentId;
@property(nonatomic, assign) BOOL isUG;
@property(nonatomic, assign) NSString * anonymous;

@end
