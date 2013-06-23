//
//  PersonalFeedController
//  Pave
//
//  Created by Neel Patel on 6/18/13.
//  Copyright (c) 2013 Pave. All rights reserved.
//

#import "PersonalFeedController.h"
#import <QuartzCore/QuartzCore.h>
#import "PaveAPIClient.h"
#import "UIImageView+WebCache.h"
#import "SDImageCache.h"
#import "ProfileObjectCell.h"
#import "ProfileViewCell.h"
#import "MBProgressHUD.h"
#import <FacebookSDK/FacebookSDK.h>
#import "AppDelegate.h"
#import "LoginViewController.h"

@interface PersonalFeedController ()

@end

@implementation PersonalFeedController


- (void)viewDidLoad
{    
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    //loads up the picture in the top bar
    [[UINavigationBar appearance] setBackgroundImage:[UIImage imageNamed:@"top_bar.png"] forBarMetrics:UIBarMetricsDefault];    
    
    //loads image cache
    self.myImageCache = [SDImageCache.alloc initWithNamespace:@"FeedObjects"];
    
    self.tableView.layer.cornerRadius=5;
    self.tableViewBackground.layer.cornerRadius=5;
    
    self.feedObjects = [NSArray array];
    
    self.imageRequests = [[NSMutableDictionary alloc] init];
    self.reloadingFeedObject = NO;
    
    
    NSLog(@"Feed objects are %@", self.feedObjects);
    [self getFeedObjects];
    
}

- (IBAction)refresh:(id)sender
{
    NSLog(@"reloading personal datapre");
    self.feedObjects = [NSArray array];
    NSLog(@"reloading personal data");
    [self getFeedObjects];
}




- (IBAction)logout:(id)sender;
{
    NSLog(@"in logout");
    //AppDelegate* delegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    //FBSession* session = delegate.session;
    //[session closeAndClearTokenInformation];
    //[session close];
    //[FBSession setActiveSession:nil];
    //[FBSession.activeSession close];
    //[FBSession.activeSession  closeAndClearTokenInformation];
    
    [self performSegueWithIdentifier:@"profileToLoginScreen" sender:self];
}


- (void) getFeedObjects
{
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, 0.01 * NSEC_PER_SEC);
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        // Do something...
        [MBProgressHUD hideHUDForView:self.view animated:YES];
    
    
        NSLog(@"About to get feed objects");
        
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        NSString *path = @"/data/getallfeedobjects/";
        path = [path stringByAppendingString:[defaults objectForKey:@"profile"][@"facebookId"]];
        //path = [path stringByAppendingString:@"1"];
        path = [path stringByAppendingString:@"/"];
        
        [[PaveAPIClient sharedClient] postPath:path parameters:nil success:^(AFHTTPRequestOperation *operation, id results) {
            if (results) {
                //NSMutableArray *ids = [[NSMutableArray alloc] init];
                //for(NSDictionary *current in results)
                //{
                //    [ids addObject:current[@"id"]];
                //}
                NSLog(@"Just finished getting results: %@", results);
                self.feedObjects = [self.feedObjects arrayByAddingObjectsFromArray:results];
                NSLog(@"Just finished getting feed ids: %@", self.feedObjects);
                self.doneLoadingFeed = YES;
                [self.tableView performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:NO];
                
            } }
                                       failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                           NSLog(@"error logging in user to Django %@", error);
                                       }];
        });
}

- (void)viewDidAppear:(BOOL)animated
{
    //removes the badge
    UITabBar *tabBar = (UITabBar *)self.tabBarController.tabBar;
    
    [[tabBar.items objectAtIndex:0] setBadgeValue:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
#warning Potentially incomplete method implementation.
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
#warning Incomplete method implementation.
    // Return the number of rows in the section.
    //extra for profile and invite cells
    return self.feedObjects.count + 2;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    //if it's a header
    if(indexPath.row == 0)
    {
        static NSString *CellIdentifier = @"Profile";
        ProfileViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (!cell) {
            cell = [[ProfileViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
            // More initializations if needed.
        }

        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        NSString *profileURL = @"https://graph.facebook.com/";
        profileURL = [profileURL stringByAppendingString:[defaults objectForKey:@"profile"][@"facebookId"]];
        profileURL = [profileURL stringByAppendingString:@"/picture?type=normal"];
        
        [cell.picture setImageWithURL:[NSURL URLWithString:profileURL]
                            placeholderImage:[UIImage imageNamed:@"profile_icon.png"]];
        NSString *count = [NSString stringWithFormat:@"%d answers", self.feedObjects.count];
        
        cell.backgroundImage.layer.cornerRadius =5;
        cell.backgroundImage.clipsToBounds = YES;
        
        cell.picture.layer.cornerRadius =5;
        cell.picture.clipsToBounds = YES;
        
        cell.name.text = [defaults objectForKey:@"profile"][@"name"];
        cell.number.text = count;

        
        return cell;
    }
    //otherwise if it's a footer
    else if(indexPath.row == self.feedObjects.count + 1)
    {
        static NSString *CellIdentifier = @"InviteFriends";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (!cell) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
            // More initializations if needed.
        }
        
        cell.textLabel.text = @"footer!";        
        
        return cell;
    }
    else
    {
        static NSString *CellIdentifier = @"Cell";
        ProfileObjectCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
        NSDictionary *currentObject = [self.feedObjects objectAtIndex:(indexPath.row-1)];
            
        NSString *newtext = currentObject[@"question"];
        
        cell.question.text = newtext;
        
        //now downloads and saves the images
        NSString *currentID = [NSString stringWithFormat:@"%@", currentObject[@"friend"]];
        //NSString *currentID = @"4";

        SDImageCache *imageCache = [SDImageCache sharedImageCache];
        
        //for profile picture
        cell.profilePicture.image = [UIImage imageNamed:@"profile_icon.png"];
        NSString *profileURL = @"https://graph.facebook.com/";
        profileURL = [profileURL stringByAppendingString:currentID ];
        profileURL = [profileURL stringByAppendingString:@"/picture?type=normal"];
        
        [imageCache queryDiskCacheForKey:profileURL done:^(UIImage *image, SDImageCacheType cacheType)
         {
             //if it's not there
             if(image==nil)
             {
                 [SDWebImageDownloader.sharedDownloader downloadImageWithURL:[NSURL URLWithString:profileURL] options:0 progress:^(NSUInteger receivedSize, long long expectedSize)
                  {
                      // progression tracking code
                      //NSLog(@"At progress point %u out of %lld", receivedSize, expectedSize);
                  }
                                                                   completed:^(UIImage *image, NSData *data, NSError *error, BOOL finished)
                  {
                      if (image && finished)
                      {
                          // do something with image
                          cell.profilePicture.image = image;
                          
                          //and now save it
                          [imageCache storeImage:image forKey:profileURL];
                          
                      }
                  }];
             }
             //otherwise just set it
             else
             {
                 cell.profilePicture.image = image;
             }
             
             //rounds it
             cell.profilePicture.layer.cornerRadius = 2;
             cell.profilePicture.clipsToBounds = YES;
             cell.profilePictureBackground.layer.cornerRadius = 2;
             cell.profilePictureBackground.clipsToBounds = YES;
             
             cell.rightProduct.layer.cornerRadius =2;
             cell.rightProduct.clipsToBounds = YES;
             cell.rightProductBackground.layer.cornerRadius = 2;
             cell.rightProductBackground.clipsToBounds = YES;
             
             cell.leftProduct.layer.cornerRadius = 2;
             cell.leftProduct.clipsToBounds = YES;
             cell.leftProductBackground.layer.cornerRadius = 2;
             cell.leftProductBackground.clipsToBounds = YES;
         }];
        
        //for left product picture
        // instantiate them
        cell.leftProduct.image = [UIImage imageNamed:@"profile_icon.png"];
        NSString *leftImageURL = @"https://s3.amazonaws.com/pave_product_images/";
        leftImageURL = [leftImageURL stringByAppendingString:currentObject[@"chosenProduct"]];
        leftImageURL = [leftImageURL stringByReplacingOccurrencesOfString:@"+" withString:@"%2b"];
        leftImageURL = [leftImageURL stringByReplacingOccurrencesOfString:@" " withString:@"+"];
        
        [imageCache queryDiskCacheForKey:leftImageURL done:^(UIImage *image, SDImageCacheType cacheType)
         {
             //if it's not there
             if(image==nil)
             {
                 [SDWebImageDownloader.sharedDownloader downloadImageWithURL:[NSURL URLWithString:leftImageURL] options:0 progress:^(NSUInteger receivedSize, long long expectedSize)
                  {
                      // progression tracking code
                      // NSLog(@"At progress point %u out of %lld", receivedSize, expectedSize);
                  }
                                                                   completed:^(UIImage *image, NSData *data, NSError *error, BOOL finished)
                  {
                      if (image && finished)
                      {
                          // do something with image
                          NSLog(@"Finished getting left product image");
                          cell.leftProduct.image = image;
                          
                          //and now save it
                          [imageCache storeImage:image forKey:leftImageURL];
                          
                      }
                  }];
             }
             //otherwise just set it
             else
             {
                 cell.leftProduct.image = image;
             }
             
             //rounds it
             cell.leftProduct.layer.cornerRadius = 2;
             cell.leftProduct.clipsToBounds = YES;
         }];
        
        //for right product picture
        cell.rightProduct.image = [UIImage imageNamed:@"profile_icon.png"];
        
        NSString *rightImageURL = @"https://s3.amazonaws.com/pave_product_images/";
        rightImageURL = [rightImageURL stringByAppendingString:currentObject[@"otherProduct"]];
        rightImageURL = [rightImageURL stringByReplacingOccurrencesOfString:@"+" withString:@"%2b"];
        rightImageURL = [rightImageURL stringByReplacingOccurrencesOfString:@" " withString:@"+"];
        
        [imageCache queryDiskCacheForKey:rightImageURL done:^(UIImage *image, SDImageCacheType cacheType)
         {
             //if it's not there
             if(image==nil)
             {
                 [SDWebImageDownloader.sharedDownloader downloadImageWithURL:[NSURL URLWithString:rightImageURL] options:0 progress:^(NSUInteger receivedSize, long long expectedSize)
                  {
                      // progression tracking code
                      //NSLog(@"At progress point %u out of %lld", receivedSize, expectedSize);
                  }
                                                                   completed:^(UIImage *image, NSData *data, NSError *error, BOOL finished)
                  {
                      if (image && finished)
                      {
                          // do something with image
                          NSLog(@"Finished getting image");
                          cell.rightProduct.image = image;
                          
                          //and now save it
                          [imageCache storeImage:image forKey:rightImageURL];
                          
                      }
                  }];
             }
             //otherwise just set it
             else
             {
                 cell.rightProduct.image = image;
             }
             
             //rounds it
             cell.rightProduct.layer.cornerRadius = 2;
             cell.rightProduct.clipsToBounds = YES;
         }];
        return cell;
    }
}



/*
 // Override to support conditional editing of the table view.
 - (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
 {
 // Return NO if you do not want the specified item to be editable.
 return YES;
 }
 */

/*
 // Override to support editing the table view.
 - (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
 {
 if (editingStyle == UITableViewCellEditingStyleDelete) {
 // Delete the row from the data source
 [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
 }
 else if (editingStyle == UITableViewCellEditingStyleInsert) {
 // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
 }
 }
 */

/*
 // Override to support rearranging the table view.
 - (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
 {
 }
 */

/*
 // Override to support conditional rearranging of the table view.
 - (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
 {
 // Return NO if you do not want the item to be re-orderable.
 return YES;
 }
 */


#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Navigation logic may go here. Create and push another view controller.
    /*
     <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
     // ...
     // Pass the selected object to the new view controller.
     [self.navigationController pushViewController:detailViewController animated:YES];
     */
}

@end