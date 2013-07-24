//
//  MembersView.m
//  Pave
//
//  Created by Neel Patel on 7/23/13.
//  Copyright (c) 2013 Pave. All rights reserved.
//

#import "MembersView.h"
#import "GroupMemberCell.h"
#import "UIImageView+WebCache.h"

@interface MembersView ()

@end

@implementation MembersView

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

-(id) initWithData:(NSDictionary *)data
{
//    self = [super init];
    if ([[UIScreen mainScreen] bounds].size.height == 568) {
        NSLog(@"Trying to create for iPhone size 5");
        self = [super initWithNibName:@"5_MembersView" bundle: nil];
    } else {
        self = [super initWithNibName:@"MembersView" bundle: nil];
    }
    
    if(self)
    {
        NSLog(@"Just created");
        self.data = data;
    }
    
    return self;
    
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)close:(id)sender
{
    [self.view removeFromSuperview];
}

//TABLE METHODS

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
    return [[self.data objectForKey:@"friend_names"] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"Trying to get the addfriend cell");
    GroupMemberCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
    if (!cell) {
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"GroupMemberCell" owner:self options:nil];
        cell = (GroupMemberCell *)[nib objectAtIndex:0];
    }

    //sets name
    cell.friendName.text = [[self.data objectForKey:@"friend_names"]objectAtIndex:indexPath.row];
    
    //sets image
    NSNumber *friendID = [[self.data objectForKey:@"friend_ids"]objectAtIndex:indexPath.row];
    NSString *profileURL = @"https://graph.facebook.com/";
    //profileURL = [profileURL stringByAppendingString:[NSString stringWithFormat:@"%d",cell.currentId] ];
    profileURL = [profileURL stringByAppendingString:[NSString stringWithFormat:@"%@",friendID]];    
    profileURL = [profileURL stringByAppendingString:@"/picture?type=normal"];
    [cell.friendProfilePicture setImageWithURL:[NSURL URLWithString:profileURL]
                              placeholderImage:[UIImage imageNamed:@"profile_icon.png"]];
        
    return cell;
}

- (void)tableView:(UITableView *)tableView didEndDisplayingCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    GroupMemberCell *current = (GroupMemberCell *) cell;
    [current.friendProfilePicture cancelCurrentImageLoad];
}

@end
