//
//  AboutUGQuestion.h
//  Pave
//
//  Created by Neel Patel on 7/19/13.
//  Copyright (c) 2013 Pave. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AboutUGQuestion : UIViewController <UITableViewDataSource, UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UIButton *closeButton;
@property (weak, nonatomic) IBOutlet UIImageView *leftImage;
@property (weak, nonatomic) IBOutlet UIImageView *rightImage;
@property (weak, nonatomic) IBOutlet UILabel *question;
@property (nonatomic, retain) NSDictionary *data; 

//tableview
@property (weak, nonatomic) IBOutlet UITableView *answers;


- (IBAction)close:(id)sender;

-(id) initWithData:(NSDictionary *)data;


@end
