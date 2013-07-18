//
//  AskViewController.m
//  Pave
//
//  Created by Neel Patel on 7/14/13.
//  Copyright (c) 2013 Pave. All rights reserved.
//

#import "AskViewController.h"
#import <AWSRuntime/AWSRuntime.h>
#import "UIImageView+WebCache.h"
#import "WebSearchViewController.h"

@interface AskViewController ()

@end

@implementation AskViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    self.title = @"Ask away!";
    
    // Initial the S3 Client.
    self.s3 = [[AmazonS3Client alloc] initWithAccessKey:@"AKIAJ5NFFKY3KUKBRTPQ" withSecretKey:@"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"];
    
    // Create the picture bucket.
    S3CreateBucketRequest *createBucketRequest = [[S3CreateBucketRequest alloc] initWithName:@"preparsedugproductimages"] ;
    NSLog(@"About to create...");
    @try {
        S3CreateBucketResponse *createBucketResponse = [self.s3 createBucket:createBucketRequest];
        
        if(createBucketResponse.error != nil)
        {
            NSLog(@"Error: %@", createBucketResponse.error);
        }
        else
        {
            NSLog(@"Bucket created!");
        }
    }
    @catch (AmazonServiceException *exception) {
        NSLog(@"Exception: %@", exception);
    }
    @finally {
        
    }
    
    //adds the notification listener
    [[NSNotificationCenter defaultCenter] addObserver:self
        selector:@selector(refreshAskImages:)
        name:@"refreshAskImages"
        object:nil];
    
    //hides the add view
    self.addOptions.hidden = YES;
}

//exit text field on enter
- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    
    if([text isEqualToString:@"\n"]) {
        [textView resignFirstResponder];
        return NO;
    }
    
    return YES;
}

//listen for the notification
- (void) refreshAskImages:(NSNotification *) notification
{
    //hides the option
    self.addOptions.hidden = YES;
    
    if ([[notification name] isEqualToString:@"refreshAskImages"])
    {

        NSLog(@"Got the notification...");
        NSDictionary *data = [notification userInfo];
        NSString *side = [data objectForKey:@"side"];
        NSString *url = [data objectForKey:@"url"];
        
        if( [side isEqualToString: @"left"])
        {
            self.leftURL = url;
            self.leftURLView.text = url;
            NSLog(@"Left Url is %@", self.leftURL);
            [self.leftImage setImageWithURL:[NSURL URLWithString:self.leftURL] ];
        }
        else if( [side isEqualToString: @"right"])
        {
            self.rightURL = url;
            self.rightURLView.text = url;
            NSLog(@"Right Url is %@", self.rightURL);
            [self.rightImage setImageWithURL:[NSURL URLWithString:self.rightURL] ];
        }                
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//adds from the left side
- (IBAction)leftAdd:(id)sender {
    //sets the current side
    self.currentSide = @"Left";
    
    //now shows the 'add' dialog
    self.addOptions.hidden = FALSE;
    
}

//adds from the right side
- (IBAction)rightAdd:(id)sender {
    //sets the current side
    self.currentSide = @"Right";
    
    //now shows the 'add' dialog
    self.addOptions.hidden = FALSE;
    
}

- (IBAction)choosePicture:(id)sender {
    UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
    imagePicker.delegate = self;
    imagePicker.allowsEditing = YES;
    
    [self presentModalViewController:imagePicker animated:YES];
}

- (IBAction)takePicture:(id)sender {    
    UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
    imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;
    imagePicker.delegate = self;
    imagePicker.allowsEditing = YES;
    
    [self presentModalViewController:imagePicker animated:YES];
}

-(void) clearImage:(NSString *) side {
    
}

-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    //hides the option
    self.addOptions.hidden = YES;
    
    // Get the selected image.
    UIImage *image = [info objectForKey:UIImagePickerControllerOriginalImage];
    
    //sets the image
    if( [self.currentSide isEqualToString: @"Left"])
    {
        NSLog(@"Setting left image");
        [self.leftImage setImage:image];
    }
    else if( [self.currentSide isEqualToString: @"Right"])
    {
        NSLog(@"Setting right image");
        [self.rightImage setImage:image];
    }
    
    
    // Convert the image to JPEG data.
    NSData *imageData = UIImageJPEGRepresentation(image, 1.0);
    
    
    [self processGrandCentralDispatchUpload:imageData];    
    
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    
    [picker dismissModalViewControllerAnimated:YES];
}

-(void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    //hides the option
    self.addOptions.hidden = YES;
    
    [picker dismissModalViewControllerAnimated:YES];
}

- (void)processGrandCentralDispatchUpload:(NSData *)imageData
{
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_async(queue, ^{
        
        UITextView * currentURLView;
        //sets the url view
        if( [self.currentSide isEqualToString: @"Left"])
        {
            currentURLView = self.leftURLView;
        }
        else if( [self.currentSide isEqualToString: @"Right"])
        {
            currentURLView = self.rightURLView;
        }
        
        NSString * name = [NSString stringWithFormat:@"%.0f.jpg",  [[NSDate date] timeIntervalSince1970] * 1000];
        
        // Upload image data.  Remember to set the content type.
        S3PutObjectRequest *por = [[S3PutObjectRequest alloc] initWithKey:name inBucket:@"preparsedugproductimages"];
        por.contentType = @"image/jpeg";
        por.data        = imageData;
        
        // Put the image data into the specified s3 bucket and object.
        S3PutObjectResponse *putObjectResponse = [self.s3 putObject:por];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            if(putObjectResponse.error != nil)
            {
                NSLog(@"Error: %@", putObjectResponse.error);
                [self showAlertMessage:[putObjectResponse.error.userInfo objectForKey:@"message"] withTitle:@"Upload Error"];
            }
            else
            {
                //[self showAlertMessage:@"The image was successfully uploaded." withTitle:@"Upload Completed"];
                currentURLView.text = name;
            }
            
            [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
        });
    });
}

- (void)showAlertMessage:(NSString *)message withTitle:(NSString *)title
{
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:title
                                                         message:message
                                                        delegate:nil
                                               cancelButtonTitle:@"OK"
                                               otherButtonTitles:nil];
    [alertView show];
}

//prepares to get an image
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if([segue.identifier isEqualToString:@"askToWeb"]) {
        if ([self.currentSide isEqualToString:@"Left"]) {
            WebSearchViewController *destViewController = segue.destinationViewController;
            
            destViewController.side = @"Left";
        }
        else if ([self.currentSide isEqualToString:@"Right"]) {
            WebSearchViewController *destViewController = segue.destinationViewController;
            
            destViewController.side = @"Right";
        }
    }
}


@end
