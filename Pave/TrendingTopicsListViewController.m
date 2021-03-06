//
//  TrendingTopicsListViewController.m
//  Pave
//
//  Created by Nithin Tumma on 6/20/13.
//  Copyright (c) 2013 Pave. All rights reserved.
//

#import "TrendingTopicsListViewController.h"
#import "TrendingListCell.h"
#import "TrendingController.h"
#import "AppDelegate.h"
#import <Foundation/Foundation.h>
#import "PaveAPIClient.h"
#import "MBProgressHUD.h"

@interface TrendingTopicsListViewController ()

@end

@implementation TrendingTopicsListViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void) viewDidAppear:(BOOL)animated
{
    NSLog(@"Table list appeared");    
    CGRect windowFrame = [UIScreen mainScreen].applicationFrame;
    
    [self.navigationController.navigationBar setFrame:CGRectMake(0,16, windowFrame.size.width, 42)];
    
    //now updates the tables
    self.feedObjects = [NSMutableArray array];
    [self getFeedObjects];
}


- (void)viewDidLoad
{
    NSLog(@"Table list loaded");
    [super viewDidLoad];
	// refresh data from here 
    // Do any additional setup after loading the view.    
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

// how to get the type
/**
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self performSegueWithIdentifier:@"trendingListToTrendingTopics" sender:self.feedObjects[indexPath.row]];
}
*/

/**
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    //setup trending controller
    if([segue.identifier isEqualToString:@"trendingListToTrendingTopics"]){
        TrendingController *destination = segue.destinationViewController;
        destination.typeDictionary = sender;  //note this is the back reference
    }
}
*/

- (void) getFeedObjects
{
    NSLog(@"About to get feed objects in trending list view controller");
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *path = @"/data/gettrendingobjects/";
    path = [path stringByAppendingString:[defaults objectForKey:@"profile"][@"facebookId"]];
    path = [path stringByAppendingString:@"/"];
    
    [[PaveAPIClient sharedClient] postPath:path parameters:nil
        success:^(AFHTTPRequestOperation *operation, id results) {
        if (results) {
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

- (void) viewWillAppear:(BOOL)animated {
    [self.tableView deselectRowAtIndexPath:[self.tableView  indexPathForSelectedRow] animated:animated];
    [super viewWillAppear:animated];
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

- (TrendingListCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    static NSString *CellIdentifier = @"Cell";
    TrendingListCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    NSDictionary *currentObject = [self.feedObjects objectAtIndex:indexPath.row];

    
    NSLog(@"Changing cell style in view controller..");
    UIImageView *av = [[UIImageView alloc] initWithFrame:CGRectMake(20, 20, 277, 58)];
    av.backgroundColor = [UIColor clearColor];
    av.opaque = NO;
    av.image = [UIImage imageNamed:@"unselected_one_trending_topic_box.png"];
     
    
    cell.backgroundView = av;
    
    cell.selectedBackgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"selected_trending_topic_box.png"]];
    
    cell.label.text = [[currentObject allKeys] objectAtIndex:0];
    NSLog(@"Set text to %@", [[currentObject allKeys] objectAtIndex:0]);
    
    return cell;        
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {    
    [self performSegueWithIdentifier:@"trendingListToTrendingTopics" sender:self.feedObjects[indexPath.row]];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    //setup trending controller
    if([segue.identifier isEqualToString:@"trendingListToTrendingTopics"]){
        TrendingController *destination = segue.destinationViewController;
        destination.typeDictionary = sender;  //note this is the back reference
    }
}

#pragma unused 
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


- (IBAction)refresh:(id)sender {
    NSLog(@"Refreshing frmo button click");
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, 0.01 * NSEC_PER_SEC);
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        // Do something...
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        //now updates the tables
        self.feedObjects = [NSMutableArray array];
        [self getFeedObjects];
    });
}
@end
