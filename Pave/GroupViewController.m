//
//  GroupViewController.m
//  Pave
//
//  Created by Nithin Tumma on 7/12/13.
//  Copyright (c) 2013 Pave. All rights reserved.
//

#import "GroupViewController.h"
#import "AppDelegate.h"
#import <Foundation/Foundation.h>
#import "PaveAPIClient.h"
#import "MBProgressHUD.h"

@interface GroupViewController ()

@end

@implementation GroupViewController



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
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    self.groups = [prefs objectForKey:@"groups"];
    // if groups is empty display it
    
    NSLog(@"Table list appeared");
    CGRect windowFrame = [UIScreen mainScreen].applicationFrame;
    
    [self.navigationController.navigationBar setFrame:CGRectMake(0,16, windowFrame.size.width, 42)];
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
    return self.groups.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    NSMutableArray *currentObject = [self.groups objectAtIndex:indexPath.row];
    
    
    NSLog(@"Changing cell style in view controller..");
    UIImageView *av = [[UIImageView alloc] initWithFrame:CGRectMake(20, 20, 277, 58)];
    av.backgroundColor = [UIColor clearColor];
    av.opaque = NO;
    av.image = [UIImage imageNamed:@"unselected_one_trending_topic_box.png"];
    
    
    cell.backgroundView = av;
    
    cell.selectedBackgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"selected_trending_topic_box.png"]];
    
    cell.textLabel.text = [currentObject objectAtIndex:0];
    NSLog(@"Set text to %@", cell.textLabel.text);
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
   // [self performSegueWithIdentifier:@"trendingListToTrendingTopics" sender:self.feedObjects[indexPath.row]];
    // do something when the table view is selected
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    //setup trending controller
    /*
    if([segue.identifier isEqualToString:@"trendingListToTrendingTopics"]){
        TrendingController *destination = segue.destinationViewController;
        destination.typeDictionary = sender;  //note this is the back reference
    }
     */
    
}



- (IBAction)addGroup:(id)sender {
    NSLog(@"Clicked add group");
    [self performSegueWithIdentifier:@"groupListToAddGroup" sender:self];
    // display popover 
}
@end
