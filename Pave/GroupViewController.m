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
#import "GroupListCell.h"
#import "NotificationPopupView.h"

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

    // instantiate the status bar and set it to the right location
    [self setUpStatusBar];

    [super viewDidLoad];
	// refresh data from here
    // Do any additional setup after loading the view.
}

- (void) setUpStatusBar
{
    self.sbar = [StatusBar statusBarCreate];
    self.sbar.frame = CGRectMake(0, 37, self.sbar.frame.size.width, self.sbar.frame.size.height);
    [self.sbar redrawBar];
    [self.view addSubview:self.sbar];
    
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
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(requestInsight:) name:@"insightReady" object:nil];

    
}

- (void)viewWillDisappear:(BOOL)animated
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"insightReady" object:nil];
}

-(void) requestInsight:(NSNotification *) notification
{
    NSLog(@"Getting called request insight");
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    // hit the endpoint
    NSString *path = @"/data/getnewrec/";
    path = [path stringByAppendingString:[defaults objectForKey:@"id"]];
    path = [path stringByAppendingString:@"/"];
    
    [[PaveAPIClient sharedClient] postPath:path parameters:nil success:^(AFHTTPRequestOperation *operation, id results) {
        if (results)
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self createNotificationPopup:[NSDictionary dictionaryWithObjectsAndKeys:[[results objectForKey:@"text"] stringValue], @"rec_text", nil]];
            });
        }
    }
                                   failure: ^(AFHTTPRequestOperation *operation, NSError *error) {
                                       NSLog(@"Failure while getting rec");
                                   }
     ];
    
}

-(void)createNotificationPopup:(NSDictionary *) data
{
    NotificationPopupView *notificationPopup = [NotificationPopupView notificationPopupCreateWithData:data];
    [self.view addSubview:notificationPopup];
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
    
    GroupListCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    NSMutableDictionary *currentObject = [self.groups objectAtIndex:indexPath.row];
    
    //sets the background
    //cell.backgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"2TESTHOMEBACKGROUND@2X.png"]];
    
    cell.selectedBackgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"selected_trending_topic_box.png"]];
    
    cell.groupName.text = [currentObject objectForKey:@"name"];
    NSLog(@"Current object: %@", currentObject);
    cell.groupMembers.text = [[currentObject objectForKey:@"friend_names"] componentsJoinedByString:@", "];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSMutableDictionary *currentGroup = [self.groups objectAtIndex:indexPath.row];
   [self performSegueWithIdentifier:@"groupListToGroupGame" sender:currentGroup];
    // do something when the table view is selected
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return YES if you want the specified item to be editable.
    return YES;
}

// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
            NSLog(@"Tryna delete");
        
        //first removes and resets array
        NSMutableArray *newArray = [NSMutableArray arrayWithArray:self.groups];
        [newArray removeObjectAtIndex:indexPath.row];
        self.groups = [NSArray arrayWithArray:newArray];
        
        //now saves it in NSUser defaults
        NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
        
        [prefs setObject:self.groups forKey:@"groups"];
        
        //now updates the table
        [self.tableView reloadData];
    }
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
