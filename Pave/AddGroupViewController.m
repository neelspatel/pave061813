//
//  AddGroupViewController.m
//  Pave
//
//  Created by Nithin Tumma on 7/12/13.
//  Copyright (c) 2013 Pave. All rights reserved.
//

#import "AddGroupViewController.h"
#import "AddFriendCell.h"
#import "UIImageView+WebCache.h"


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
    
    NSLog(@"Called view did load when adding a group");
    // initing the arrays
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    self.friendNames = [[NSMutableArray alloc] initWithArray:[[prefs objectForKey:@"names"] copy]];
    self.friendIds = [[NSMutableArray alloc] initWithArray:[[prefs objectForKey:@"friends"] copy]];
    NSLog(@"Friend ids: %@", self.friendIds);
    // if no friends, reload friend data from server
    
    self.filteredNames = [[NSMutableArray alloc] init];
    self.filteredIds = [[NSMutableArray alloc] init];
    
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

- (AddFriendCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    NSString *userID;
    
    AddFriendCell *cell = [self.tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (self.isFiltered)
    {
        cell.friendName.text = [self.filteredNames objectAtIndex:indexPath.row];
        userID = [[self.filteredIds objectAtIndex:indexPath.row] stringValue];
    }
        
    else
    {
        cell.friendName.text = [self.friendNames objectAtIndex:indexPath.row];
        userID = [[self.friendIds objectAtIndex:indexPath.row] stringValue];                
    }
    
    //sets the background
    cell.backgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"unselected_group_selector_background.png"]];
    cell.selectedBackgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"selected_group_selector_background.png"]];
    
    NSString *profileURL = @"https://graph.facebook.com/";
    //profileURL = [profileURL stringByAppendingString:[NSString stringWithFormat:@"%d",cell.currentId] ];
    profileURL = [profileURL stringByAppendingString:userID];
    profileURL = [profileURL stringByAppendingString:@"/picture?type=normal"];
    [cell.friendProfilePicture setImageWithURL:[NSURL URLWithString:profileURL]
                        placeholderImage:[UIImage imageNamed:@"profile_icon.png"]];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {

    // append name to the text view that will be displayed
    
    [self.tableView deselectRowAtIndexPath:[self.tableView  indexPathForSelectedRow] animated:YES];
    
    NSLog(@"Selected %d", indexPath.row);
    [self.view endEditing:YES];
    
    NSString *selectedName;
    NSString *selectedId;
    if (self.isFiltered)
    {
        selectedName = [[NSString alloc] initWithString: [self.filteredNames objectAtIndex:indexPath.row]];
        selectedId = [[NSString alloc] initWithString: [[self.filteredIds objectAtIndex:indexPath.row] stringValue]];
    }
    else
    {
        selectedName = [[NSString alloc] initWithString: [self.friendNames objectAtIndex:indexPath.row]];
        selectedId = [[NSString alloc] initWithString: [[self.friendIds objectAtIndex:indexPath.row] stringValue]];
    }
    
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
    //must do these two first so we remove the right ID
    [self.filteredIds removeObject:[self.friendIds objectAtIndex:indexPath.row]];
    [self.friendIds removeObject:[self.friendIds objectAtIndex:indexPath.row]];
    //now remove name
    [self.filteredNames removeObject:selectedName];
    [self.friendNames removeObject:selectedName];
    [self.tableView reloadData];
}

- (void)tableView:(UITableView *)tableView didEndDisplayingCell:(AddFriendCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"About to cancel cell");
    // free up the requests for each ImageView
    [cell.friendProfilePicture cancelCurrentImageLoad];    
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
        self.filteredIds = [[NSMutableArray alloc] init];
        for (NSString *currName in self.friendNames){
            NSRange nameRange = [currName rangeOfString:text options: NSCaseInsensitiveSearch];
            if (nameRange.location == 0) {
                [self.filteredNames addObject:currName];
                
                //now gets the same position for the id
                int index = [self.friendNames indexOfObject:currName];
                NSNumber *currId = [self.friendIds objectAtIndex:index];
                [self.filteredIds addObject:currId];
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
    self.createButton.hidden = YES;
    self.popup.hidden = NO;
}


- (IBAction)createGroup:(id)sender {
    [self createGroupAction];
}

- (void) createGroupAction
{
    NSLog(@"About to create a group");
    // check if everything is in line
    if (self.currentGroup.count > 0)
    {
        NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
        
        // if there is no group name
        if (!self.currentGroupName)
            self.currentGroupName = @"Default Name";

        NSLog(@"Before accessing groups");
        
        NSMutableArray *friendIds = [prefs objectForKey:@"friends"];
        NSMutableArray *friendNames = [prefs objectForKey:@"names"];
        NSMutableArray *groupFriendIds = [[NSMutableArray alloc] initWithCapacity: self.currentGroup.count];
        
       // NSLog(@"%@", friendNames);
        
        for (NSString *curName in self.currentGroup) {
            NSInteger index = [friendNames indexOfObject:curName];
            NSLog(@"Index: %d", index);
            [groupFriendIds addObject:[friendIds objectAtIndex:index]];
        }
        
        NSLog(@"Group Friend IDS: %@", groupFriendIds);
        
        NSMutableDictionary *currentGroup = [[NSMutableDictionary alloc] initWithObjects:@[self.currentGroupName, groupFriendIds, self.currentGroup] forKeys:@[@"name", @"friend_ids", @"friend_names"]];
        
        NSLog(@"Current Group: %@", currentGroup);

        NSMutableArray *groups = [[NSMutableArray alloc] initWithArray:[prefs objectForKey:@"groups"]];
        NSLog(@"User defaults group: %@", groups);
    
        if (!groups)
        {
            NSLog(@"Not groups");
            groups = [[NSMutableArray alloc] init];
        }
        
        [groups addObject:currentGroup];
        NSLog(@"Groups %@", groups);
        [prefs setObject:groups forKey:@"groups"];
        [prefs synchronize];
        NSLog(@"Succesfully created group %@", self.currentGroupName);

        [self dismissViewControllerAnimated:YES completion:nil];
        // You succesfully created this group!
    }
    else{
        NSLog(@"Empty group cannot complete");
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Please add group members" delegate:self cancelButtonTitle:@"Go Back" otherButtonTitles:nil];
        [alertView show];
    }
}

- (IBAction)back:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
