//
//  AddGroupViewController.m
//  Pave
//
//  Created by Nithin Tumma on 7/12/13.
//  Copyright (c) 2013 Pave. All rights reserved.
//

#import "AddGroupViewController.h"
#import "AddFriendCell.h"

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
    self.friendNames = [[NSMutableArray alloc] initWithArray:[[prefs objectForKey:@"names"] copy]];
    
    // if no friends, reload friend data from server
    
    self.filteredNames = [[NSMutableArray alloc] init];
    
    self.tableView.delaysContentTouches = NO;

	// Do any additional setup after loading the view.
    
    // setting our delegates
    self.addFriendsSearchBar.delegate = (id)self;
    self.groupName.delegate = (id)self;
    self.currentGroup = [[NSMutableArray alloc] init];
    
    //customize searchbar
    /**
    [[[self.addFriendsSearchBar subviews] objectAtIndex:0] setHidden:YES];
    for (id img in self.addFriendsSearchBar.subviews) {
        if ([img isKindOfClass:NSClassFromString(@"UISearchBarBackground")]) {
            [img removeFromSuperview];
        }
    }
    */

    //[[UISearchBar appearance] setSearchFieldBackgroundImage:[UIImage imageNamed:@"group_searchbar.png"]forState:UIControlStateNormal];
    //[self.addFriendsSearchBar setSearchFieldBackgroundImage:[UIImage imageNamed:@"group_searchbar.png"] forState:UIControlStateNormal];

    /*for (UIView * view in [self.addFriendsSearchBar  subviews]) {
        if (![view isKindOfClass:[UITextField class]]) {
            view .alpha = 0;
        }
    }*/

    [[self.addFriendsSearchBar.subviews objectAtIndex:0] removeFromSuperview];

    
    CGRect frame = self.addFriendsSearchBar.frame;
    frame.size.height = 30;
    self.addFriendsSearchBar.frame = frame;
    
    //hides the popup
    self.popup.hidden = YES;    

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
    
    AddFriendCell *cell = [self.tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (self.isFiltered)
        cell.friendName.text = [self.filteredNames objectAtIndex:indexPath.row];
    else
        cell.friendName.text = [self.friendNames objectAtIndex:indexPath.row];
    
    // do logic for getting profile picture here 
    [cell.friendProfilePicture setImage: [UIImage imageNamed:@"add_picture_icon.png"]];
    return cell;

}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {

    // append name to the text view that will be displayed
    
    [self.tableView deselectRowAtIndexPath:[self.tableView  indexPathForSelectedRow] animated:YES];
    
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
    NSString *newText;
    if ([curText isEqual: @"add some friends below!"])
        newText = selectedName;
    else
        newText = [NSString stringWithFormat:@"%@, %@",curText, selectedName];
    
    NSLog(@"%@", newText);
    self.addedFriendsTextField.text = newText;
    
    self.addFriendsSearchBar.text = @"";
    
    // delete the friend from the friends array and from the autocomplete array
    self.isFiltered = NO;
    [self.filteredNames removeObject:selectedName];
    [self.friendNames removeObject:selectedName];
    [self.tableView reloadData];
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

- (IBAction)showCreate:(id)sender {
    self.popup.hidden = NO;
}


- (IBAction)createGroup:(id)sender {
    // check if everything is in line
    if (self.currentGroup.count > 0)
    {
        NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];

        NSLog(@"Succesfully created group %@", self.currentGroupName);
        // if there is no group name
        if (!self.currentGroupName)
                self.currentGroupName = @"Default Name";
        
        NSMutableArray *friendIds = [prefs objectForKey:@"friends"];
        NSMutableArray *friendNames = [prefs objectForKey:@"names"];
        NSMutableArray *groupFriendIds = [[NSMutableArray alloc] init];
        NSLog(@"%@", friendNames);
        for (NSString *curName in self.currentGroup) {
            NSInteger index = [friendNames indexOfObject:curName];
            NSLog(@"Index: %d", index);
            [groupFriendIds addObject:[friendIds objectAtIndex:index]];
        }
        
        NSMutableDictionary *currentGroup = [[NSMutableDictionary alloc] initWithObjects:@[self.currentGroupName, groupFriendIds, self.currentGroup] forKeys:@[@"name", @"friend_ids", @"friend_names"]];
        NSMutableArray *groups = [prefs objectForKey:@"groups"];
        if (!groups)
            groups = [[NSMutableArray alloc] init];
        
        [groups addObject:currentGroup];
        NSLog(@"Groups %@", groups);
        [prefs setObject:groups forKey:@"groups"];
        [prefs synchronize];
        
        [self dismissViewControllerAnimated:YES completion:nil];
        // You succesfully created this group!
    }
    else{
        NSLog(@"Empty group cannot complete");
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Error" message:@"You have to add group members" delegate:self cancelButtonTitle:@"Go Back" otherButtonTitles:nil];
        [alertView show];
    }
}
@end
