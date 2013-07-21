//
//  AskViewController.h
//  Pave
//
//  Created by Neel Patel on 7/14/13.
//  Copyright (c) 2013 Pave. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AWSRuntime/AWSRuntime.h>
#import <AWSS3/AWSS3.h>

@interface AskViewController : UIViewController<UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextViewDelegate> {}

- (IBAction)leftAdd:(id)sender;
- (IBAction)rightAdd:(id)sender;

- (IBAction)leftCancel:(id)sender;
- (IBAction)rightCancel:(id)sender;

- (IBAction)choosePicture:(id)sender;
- (IBAction)takePicture:(id)sender;

- (IBAction)create:(id)sender;
@property (nonatomic, retain) AmazonS3Client *s3;

@property (nonatomic, retain) NSString *currentSide;

@property (weak, nonatomic) IBOutlet UIView *addOptions;

@property (nonatomic, retain) NSString *leftURL;
@property (weak, nonatomic) IBOutlet UIImageView *leftImage;

@property (weak, nonatomic) IBOutlet UIButton * leftAddButton;
@property (weak, nonatomic) IBOutlet UIButton * leftCancelButton;

@property (weak, nonatomic) IBOutlet UITextField *leftURLView;

@property (nonatomic, retain) NSString *rightURL;
@property (weak, nonatomic) IBOutlet UIImageView *rightImage;
@property (weak, nonatomic) IBOutlet UIButton * rightAddButton
;
@property (weak, nonatomic) IBOutlet UIButton * rightCancelButton;

@property (weak, nonatomic) IBOutlet UITextField *rightURLView;


@end
