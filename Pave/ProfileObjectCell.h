//
//  ProfileObjectCell.h
//  Pave
//
//  Created by Neel Patel on 6/19/13.
//  Copyright (c) 2013 Pave. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ProfileObjectCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *profilePictureBackground;
@property (weak, nonatomic) IBOutlet UIImageView *profilePicture;
@property (weak, nonatomic) IBOutlet UIImageView *leftProductBackground;
@property (weak, nonatomic) IBOutlet UIImageView *leftProductHighlight;
@property (weak, nonatomic) IBOutlet UIImageView *leftProduct;
@property (weak, nonatomic) IBOutlet UIImageView *rightProduct;
@property (weak, nonatomic) IBOutlet UIImageView *rightProductBackground;
@property (weak, nonatomic) IBOutlet UIImageView *rightProductHighlight;
@property (weak, nonatomic) IBOutlet UILabel *question;



@property(nonatomic, assign) NSInteger leftProductId;
@property(nonatomic, assign) NSInteger rightProductId;
@property(nonatomic, assign) NSString *questionText;


@end
