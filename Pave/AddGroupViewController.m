//
//  AddGroupViewController.m
//  Pave
//
//  Created by Nithin Tumma on 7/12/13.
//  Copyright (c) 2013 Pave. All rights reserved.
//

#import "AddGroupViewController.h"

@interface AddGroupViewController ()

@end

@implementation AddGroupViewController

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
    
    // initing the arrays
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    self.friendIds = [prefs objectForKey:@"friends"];
    self.friendNames = [prefs objectForKey:@"names"];
    
    // if no friends, reload friend data from server
    
    self.filteredNames = [[NSMutableArray alloc] init];
    
    self.addFriendsSearchBar.delaysContentTouches = NO;

	// Do any additional setup after loading the view.
    
    // setting our delegates
    self.addFriendsSearchBar.delegate = (id)self;
    self.groupName.delegate = (id)self;
    self.currentGroup = [[NSMutableArray alloc] init];

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    int rowCount;
    if (self.isFiltered)
        rowCount = self.filteredNames.count;
    else
        rowCount = self.friendNames.count;
    
    return rowCount;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (self.isFiltered)
        cell.textLabel.text = [self.filteredNames objectAtIndex:indexPath.row];
    else
        cell.textLabel.text = [self.friendNames objectAtIndex:indexPath.row];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    // [self performSegueWithIdentifier:@"trendingListToTrendingTopics" sender:self.feedObjects[indexPath.row]];
    // append name to the text view that will be displayed
    NSLog(@"Selected %d", indexPath.row);
    [self.view endEditing:YES];
    
    NSString *selectedName;
    if (self.isFiltered)
        selectedName = [[NSString alloc] initWithString: [self.filteredNames objectAtIndex:indexPath.row]];
    else
        selectedName = [[NSString alloc] initWithString: [self.friendNames objectAtIndex:indexPath.row]];
    
    // add the seleced name to the current group
    [self.currentGroup addObject:selectedName];
    NSLog(@"%@", self.currentGroup);
    NSString *curText = self.addedFriendsTextField.text;
    
    NSString *newText = [NSString stringWithFormat:@"%@, %@",curText, selectedName];
    self.addedFriendsTextField.text = newText;
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar
{
    NSLog(@"Search button cancelled");
    [searchBar resignFirstResponder];
}

-(void)searchBar:(UISearchBar*)searchBar textDidChange:(NSString*)text
{
    if (text.length == 0)
    {
        self.isFiltered = NO;
    }
    else
    {
        self.isFiltered = YES;
        self.filteredNames = [[NSMutableArray alloc] init];
        for (NSString *currName in self.friendNames){
            NSRange nameRange = [currName rangeOfString:text options: NSCaseInsensitiveSearch];
            if (nameRange.location == 0) {
                [self.filteredNames addObject:currName];
            }
        }
    }
    [self.tableView reloadData];

}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if (textField == self.groupName) {
        [textField resignFirstResponder];
        self.currentGroupName = self.groupName.text;
        // gray out the text or something
        self.groupName.textColor = [UIColor lightGrayColor];
        return NO;
    }
    return YES;
}


- (IBAction)createGroup:(id)sender {
    // check if everything is in line
    if (self.currentGroup.count > 0)
    {
        NSLog(@"Succesfully created group %@", self.currentGroupName);
        // if there is no group name
        if (!self.currentGroupName)
                self.currentGroupName = @"";
            
        NSMutableDictionary *currentGroup = [[NSMutableDictionary alloc] initWithObjects:@[self.currentGroupName, self.currentGroup] forKeys:@[@"name", @"friends"]];
        NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
        NSMutableArray *groups = [prefs objectForKey:@"groups"];
        [groups addObject:currentGroup];
        [prefs setObject:groups forKey:@"groups"];
        [prefs synchronize];
        
        [self performSegueWithIdentifier:@"createGroupToGroupList" sender:self];
        // You succesfully created this group!
    }
    else{
        NSLog(@"Empty group cannot complete");
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Error" message:@"You have to add group members" delegate:self cancelButtonTitle:@"Go Back" otherButtonTitles:nil];
        [alertView show];
    }
}
@end
