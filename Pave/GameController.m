//
//  GameController.m
//  Pave
//
//  Created by Neel Patel on 6/18/13.
//  Copyright (c) 2013 Pave. All rights reserved.
//

#import "GameController.h"
#import <QuartzCore/QuartzCore.h>
#import "PaveAPIClient.h"
#import "UIImageView+WebCache.h"
#import "SDImageCache.h"
#import "FeedObjectCell.h"

@interface GameController ()

@end

@implementation GameController


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
    
    self.feedObjects = [NSMutableArray array];
    
    self.imageRequests = [[NSMutableDictionary alloc] init];
    self.reloadingFeedObject = NO;
        
    
    NSLog(@"Feed objects are %@", self.feedObjects);
    [self getFeedObjects];
    
}

- (void) getFeedObjects
{
    NSLog(@"About to get feed objects");
    
    //NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *path = @"/data/getlistquestions/";
    //path = [path stringByAppendingString:[defaults objectForKey:@"profile"][@"facebookId"]];
    path = [path stringByAppendingString:@"1"];
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
    return self.feedObjects.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    FeedObjectCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    NSDictionary *currentObject = [self.feedObjects objectAtIndex:indexPath.row][@"fields"];
    
    // Configure the cell...
    
    cell.leftBackground.layer.cornerRadius = 5;
    cell.leftBackground.clipsToBounds = YES;
    cell.rightBackground.layer.cornerRadius = 5;
    cell.rightBackground.clipsToBounds = YES;
    cell.profilePictureBackground.layer.cornerRadius = 5;
    cell.profilePictureBackground.clipsToBounds = YES;
    
    
    NSString *newtext = currentObject[@"questionText"];
    
    cell.question.text = newtext;
    cell.leftNum.text = [NSString stringWithFormat:@"%@", currentObject[@"product1Count"]];
    NSLog(@"about to get rightNum");
    cell.rightNum.text = [NSString stringWithFormat:@"%@",currentObject[@"product2Count"]];
    @try
    {
        NSLog(@"leftFriendId");
        cell.leftFriendId = (int) (currentObject[@"fbFriend1"][0]);
    }
    @catch (NSException *e)
    {
        cell.leftFriendId = 0;
    }
    
    @try
    {
        NSLog(@"rightFriendId");
        //cell.rightFriendId = (int) [NSString stringWithFormat:@"%@", (currentObject[@"fbFriend2"][0])];
        cell.rightFriendId = (int) (currentObject[@"fbFriend2"][0]);
    }
    @catch (NSException *e)
    {
        cell.rightFriendId = 0;
    }
    
    cell.leftProductId = (int) (currentObject[@"product1"]);
    cell.rightProductId = (int) (currentObject[@"product2"]);
    
    //now downloads and saves the images
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *currentID = @"4";
    //NSString *currentID = [defaults objectForKey:@"id"];
    
    SDImageCache *imageCache = [SDImageCache sharedImageCache];
    
    //for profile picture
    cell.profilePicture.image = [UIImage imageNamed:@"profile_icon.png"];
    NSString *profileURL = @"https://graph.facebook.com/";
    profileURL = [profileURL stringByAppendingString:currentID ];
    profileURL = [profileURL stringByAppendingString:@"/picture"];
    
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
         cell.profilePicture.layer.cornerRadius = 5;
         cell.profilePicture.clipsToBounds = YES;
     }];
    
    //for left product picture
    // instantiate them
    cell.leftProduct.image = [UIImage imageNamed:@"profile_icon.png"];
    NSString *leftImageURL = @"https://s3.amazonaws.com/pave_product_images/";
    leftImageURL = [leftImageURL stringByAppendingString:currentObject[@"image1"]];
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
         cell.leftProduct.layer.cornerRadius = 5;
         cell.leftProduct.clipsToBounds = YES;
     }];
    
    //for right product picture
    cell.rightProduct.image = [UIImage imageNamed:@"profile_icon.png"];
    
    NSString *rightImageURL = @"https://s3.amazonaws.com/pave_product_images/";
    rightImageURL = [rightImageURL stringByAppendingString:currentObject[@"image2"]];
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
         cell.rightProduct.layer.cornerRadius = 5;
         cell.rightProduct.clipsToBounds = YES;
     }];
    return cell;
}

// make the feed objects only return once
- (void)scrollViewDidEndDecelerating:(UITableView *)tableView {
    float bottomEdge = self.tableView.contentOffset.y + self.tableView.frame.size.height;
    if (bottomEdge >= self.tableView.contentSize.height - 50)  {
        NSLog(@"at the very end");
        // what to do here
        NSLog(@"Getting new feed objects: ");
        if (!self.reloadingFeedObject) {
            self.reloadingFeedObject = YES;
            [self getFeedObjects];
        }
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