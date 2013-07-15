//
//  GroupViewController.m
//  Pave
//
//  Created by Nithin Tumma on 7/12/13.
//  Copyright (c) 2013 Pave. All rights reserved.
//

#import "GroupViewController.h"
#import "GroupGameController.h"
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
    [super viewDidAppear:animated];
}


- (void)viewDidLoad
{
    
    NSLog(@"Table list loaded");
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    
    self.groups = [prefs objectForKey:@"groups"];
    NSLog(@"Groups: %@", self.groups);

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
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    
    self.groups = [prefs objectForKey:@"groups"];

    [self.tableView deselectRowAtIndexPath:[self.tableView  indexPathForSelectedRow] animated:animated];
    [self.tableView reloadData];
    [super viewWillAppear:animated];
    
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSLog(@"Getting length");
    // Return the number of rows in the section.
    NSLog(@"%@", self.groups);
    return self.groups.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"Load cell");
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    NSMutableDictionary *currentObject = [self.groups objectAtIndex:indexPath.row];
    
    
        
    cell.selectedBackgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"selected_trending_topic_box.png"]];
    
    cell.textLabel.text = [currentObject objectForKey:@"name"];
    NSLog(@"Set text to %@", cell.textLabel.text);
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSMutableDictionary *currentGroup = [self.groups objectAtIndex:indexPath.row];
   [self performSegueWithIdentifier:@"groupListToGroupGame" sender:currentGroup];
    // do something when the table view is selected
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    //setup trending controller
    
    if([segue.identifier isEqualToString:@"groupListToGroupGame"]){
        GroupGameController *destination = segue.destinationViewController;
        destination.group = sender;  //note this is the back reference
    }
     
    
}


- (IBAction)addGroup:(id)sender {
    NSLog(@"Clicked add group");
    [self performSegueWithIdentifier:@"groupListToAddGroup" sender:self];
    // display popover 
}
@end
