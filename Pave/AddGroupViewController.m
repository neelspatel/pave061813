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
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    self.friendIds = [prefs objectForKey:@"friends"];
    self.friendNames = [prefs objectForKey:@"names"];
    // if no friends, reload friend data from server
    self.filteredNames = [[NSMutableArray alloc] init];
    self.addFriendsSearchBar.delegate = (id)self;
    [super viewDidLoad];
    self.addFriendsSearchBar.delaysContentTouches = NO;

	// Do any additional setup after loading the view.
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

@end
