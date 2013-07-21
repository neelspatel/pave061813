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
#import "PaveAPIClient.h"
#import "StatusBar.h"

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
    
    [self setUpStatusBar];
    
    NSLog(@"Defaults: %@", [[NSUserDefaults standardUserDefaults] dictionaryRepresentation]);

    
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
    
    //updates create button
    [self updateCreateButton];
}

- (IBAction)closeOptions:(id)sender
{
    //hides the add view
    self.addOptions.hidden = YES;
}

-(void)viewWillAppear:(BOOL) animated
{
    [self.sbar redrawBar];
}

- (void) setUpStatusBar
{
    self.sbar = [StatusBar statusBarCreate];
    self.sbar.frame = CGRectMake(0, 37, self.sbar.frame.size.width, self.sbar.frame.size.height);
    [self.sbar redrawBar];
    [self.view addSubview:self.sbar];
    
}


- (IBAction)create:(id)sender
{
    NSLog(@"About to submit now");
    
    NSString *path = @"createugquestion/";
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    path = [path stringByAppendingString:[defaults objectForKey:@"id"]];
    path = [path stringByAppendingString:@"/"];
    
    NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys: self.leftURL, @"product1_url", self.rightURL, @"product2_url", @"product1", @"product1_description", @"product2", @"product2_description", @"QUESTION GOES HERE", @"question_text",  nil];
    NSLog(@"Sent with params %@", params);
    
    [[PaveAPIClient sharedClient] postPath:path
                                parameters:params success:^(AFHTTPRequestOperation *operation, id JSON) {
                                    NSLog(@"successfully created question");
                                
                                    [self performSegueWithIdentifier:@"finishedSubmitting" sender:self];
                                } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                    NSLog(@"error saving answer %@", error);
                                }];
    
    
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
            
            //hides the button
            self.leftAddButton.hidden = YES;
            
            //shows the x button
            self.leftCancelButton.hidden = NO;
        }
        else if( [side isEqualToString: @"right"])
        {
            self.rightURL = url;
            self.rightURLView.text = url;
            NSLog(@"Right Url is %@", self.rightURL);
            [self.rightImage setImageWithURL:[NSURL URLWithString:self.rightURL] ];
            
            //hides the button
            self.rightAddButton.hidden = YES;
            
            //shows the x button
            self.rightCancelButton.hidden = NO;
        }
        
        [self updateCreateButton];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) updateCreateButton
{
    if(self.leftURL && self.rightURL)
    {
        NSLog(@"Ready to create if you want to");
        [self.createButton setImage:[UIImage imageNamed:@"create_selected.png"] forState:UIControlStateNormal];
        [self.createButton setEnabled:YES];
    }
    else
    {
        [self.createButton setImage:[UIImage imageNamed:@"create_unselected.png"] forState:UIControlStateNormal];
        [self.createButton setEnabled:NO];
    }
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

//cancels from the left side
- (IBAction)leftCancel:(id)sender
{
    self.leftCancelButton.hidden = TRUE;
    self.leftAddButton.hidden = FALSE;
    [self.leftImage setImage:[UIImage imageNamed: @"unselected_pic.png"]];
    
    self.leftURL = @"";
    self.leftURLView.text = @"";
    
    [self updateCreateButton];    
}

//cancels from the left side
- (IBAction)rightCancel:(id)sender
{
    self.rightCancelButton.hidden = TRUE;
    self.rightAddButton.hidden = FALSE;
    [self.rightImage setImage:[UIImage imageNamed: @"unselected_pic.png"]];
    
    self.rightURL = @"";
    self.rightURLView.text = @"";
    
    [self updateCreateButton];
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
        
        //hides the button
        self.leftAddButton.hidden = YES;
        
        //shows the x button
        self.leftCancelButton.hidden = NO;
    }
    else if( [self.currentSide isEqualToString: @"Right"])
    {
        NSLog(@"Setting right image");
        [self.rightImage setImage:image];
        
        //hides the button
        self.rightAddButton.hidden = YES;
        
        //shows the x button
        self.rightCancelButton.hidden = NO;
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
        
        NSString * name = [NSString stringWithFormat:@"%.0f.jpg",  [[NSDate date] timeIntervalSince1970] * 1000];
        
        if( [self.currentSide isEqualToString: @"Left"])
        {
            currentURLView = self.leftURLView;
            
            self.leftURL = [@"https://s3.amazonaws.com/preparsedugproductimages/" stringByAppendingString:name];
        }
        else if( [self.currentSide isEqualToString: @"Right"])
        {
            currentURLView = self.rightURLView;
            
            self.rightURL = [@"https://s3.amazonaws.com/preparsedugproductimages/" stringByAppendingString:name];
        }
        

        
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
                [self updateCreateButton];
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
