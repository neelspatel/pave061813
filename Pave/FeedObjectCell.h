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

@property (weak, nonatomic) IBOutlet UIImageView *profilePictureBackground;
@property (weak, nonatomic) IBOutlet UILabel *question;
@property (weak, nonatomic) IBOutlet UIImageView *profilePicture;
@property (weak, nonatomic) IBOutlet UIImageView *leftProduct;
@property (weak, nonatomic) IBOutlet UIImageView *rightProduct;
@property (weak, nonatomic) IBOutlet UIImageView *leftFriend;
@property (weak, nonatomic) IBOutlet UILabel *leftNum;
@property (weak, nonatomic) IBOutlet UILabel *rightNum;
@property (weak, nonatomic) IBOutlet UIImageView *rightFriend;
@property (weak, nonatomic) IBOutlet UIImageView *leftBackground;
@property (weak, nonatomic) IBOutlet UIImageView *rightBackground;

@property(nonatomic, assign) NSInteger leftFriendId;
@property(nonatomic, assign) NSInteger rightFriendId;
@property(nonatomic, assign) NSInteger leftProductId;
@property(nonatomic, assign) NSInteger rightProductId;
@property(nonatomic, assign) NSString *questionText;

@end
