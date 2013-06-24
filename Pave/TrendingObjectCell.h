//
//  TrendingObjectCell.h
//  Pave
//
//  Created by Neel Patel on 6/19/13.
//  Copyright (c) 2013 Pave. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TrendingObjectCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *profilePicture;
@property (weak, nonatomic) IBOutlet UIImageView *leftProduct;
@property (weak, nonatomic) IBOutlet UIImageView *rightProduct;
@property (weak, nonatomic) IBOutlet UILabel *question;
@property (weak, nonatomic) IBOutlet UILabel *leftLabel;
@property (weak, nonatomic) IBOutlet UILabel *leftNum;
@property (weak, nonatomic) IBOutlet UILabel *rightLabel;
@property (weak, nonatomic) IBOutlet UILabel *rightNum;
@property (weak, nonatomic) IBOutlet UIImageView *profilePictureBackground;
@property (weak, nonatomic) IBOutlet UIImageView *leftBackground;
@property (weak, nonatomic) IBOutlet UIImageView *rightBackground;
@property (weak, nonatomic) IBOutlet UITextView *responseCount;

@property(nonatomic, assign) NSInteger leftFriendId;
@property(nonatomic, assign) NSInteger rightFriendId;
@property(nonatomic, assign) NSInteger leftProductId;
@property(nonatomic, assign) NSInteger rightProductId;
@property (weak, nonatomic) IBOutlet UIButton *leftFacebookButton;
@property (weak, nonatomic) IBOutlet UIButton *rightFacebookButton;
- (IBAction)leftSend:(id)sender;
- (IBAction)rightSend:(id)sender;


@property(nonatomic, assign) NSInteger leftProductCount;
@property(nonatomic, assign) NSInteger rightProductCount;
@property(nonatomic, assign) NSInteger questionId;
@property(nonatomic, copy) NSString *questionText;
@property(nonatomic, copy) NSString * currentId;

@end
