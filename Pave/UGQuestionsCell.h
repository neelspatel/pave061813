//
//  UGQuestionsCell.h
//  Pave
//
//  Created by Neel Patel on 7/17/13.
//  Copyright (c) 2013 Pave. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UGQuestionsCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *leftProduct;
@property (weak, nonatomic) IBOutlet UIImageView *rightProduct;
@property (weak, nonatomic) IBOutlet UILabel *question;

@property(nonatomic, assign) NSInteger leftProductId;
@property(nonatomic, assign) NSInteger rightProductId;
@property(nonatomic, assign) NSString *questionText;

@end
