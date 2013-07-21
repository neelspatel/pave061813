//
//  StatusBar.h
//  Pave
//
//  Created by Nithin Tumma on 7/19/13.
//  Copyright (c) 2013 Pave. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface StatusBar : UIView

@property (assign, nonatomic) NSInteger statusScore;

// the circles
@property (strong) NSMutableArray *imageViews;

// individual circles
@property (weak, nonatomic) IBOutlet UIImageView *image1;
@property (weak, nonatomic) IBOutlet UIImageView *image2;
@property (weak, nonatomic) IBOutlet UIImageView *image3;
@property (weak, nonatomic) IBOutlet UIImageView *image4;
@property (weak, nonatomic) IBOutlet UIImageView *image5;
@property (weak, nonatomic) IBOutlet UIImageView *image6;
@property (weak, nonatomic) IBOutlet UIImageView *image7;
@property (weak, nonatomic) IBOutlet UIImageView *image8;
@property (weak, nonatomic) IBOutlet UIImageView *image9;
@property (weak, nonatomic) IBOutlet UIImageView *image10;

@property (strong) NSMutableArray *lineViews;
// lines
@property (weak, nonatomic) IBOutlet UIImageView *connector2;
@property (weak, nonatomic) IBOutlet UIImageView *connector5;
@property (weak, nonatomic) IBOutlet UIImageView *connector1;
@property (weak, nonatomic) IBOutlet UIImageView *connector3;
@property (weak, nonatomic) IBOutlet UIImageView *connector4;

@property (weak, nonatomic) IBOutlet UIImageView *connector6;

@property (weak, nonatomic) IBOutlet UIImageView *connector7;
@property (weak, nonatomic) IBOutlet UIImageView *connector8;
@property (weak, nonatomic) IBOutlet UIImageView *connector9;



@property (weak, nonatomic) UIImage *onCircle;
@property (weak, nonatomic) UIImage *offCircle;

@property (weak, nonatomic) UIImage *offBulb;
@property (weak, nonatomic) UIImage *onBulb;

@property (weak, nonatomic) UIImage *line;

-(void)redrawBar;

+(id)statusBarCreate;


@end
