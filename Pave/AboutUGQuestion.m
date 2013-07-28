//
//  AboutUGQuestion.m
//  Pave
//
//  Created by Neel Patel on 7/19/13.
//  Copyright (c) 2013 Pave. All rights reserved.
//

#import "AboutUGQuestion.h"
#import "NameCell.h"
#import "UIImageView+WebCache.h"
#import <objc/runtime.h>

@interface AboutUGQuestion ()

@end

@implementation AboutUGQuestion

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
    if ([[UIScreen mainScreen] bounds].size.height == 568) {
        NSLog(@"Trying to create for iPhone size 5");
        self = [super initWithNibName:@"5_AboutUGQuestionView" bundle: nil];
    } else {
        self = [super initWithNibName:@"AboutUGQuestion" bundle: nil];
    }
    if(self)
    {
        NSLog(@"Just created");
        self.data = data;
        
        NSLog(@"%@", [[NSUserDefaults standardUserDefaults] dictionaryRepresentation]);

    }

    //NSLog(@"NSUser: %@", [[NSUserDefaults standardUserDefaults] dictionaryRepresentation]);

    
    return self;

}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.question.text = [self.data objectForKey:@"question_text"];
    
    [self.leftImage setImageWithURL:[NSURL URLWithString: self.data[@"product_1_url"]] placeholderImage:[UIImage imageNamed:@"profile_icon.png"]];
        
    [self.rightImage setImageWithURL:[NSURL URLWithString: self.data[@"product_2_url"]] placeholderImage:[UIImage imageNamed:@"profile_icon.png"]];
    
    //shows and hides the details and numbers
    //shows and hides the labels depending on count
    if([self.data[@"product_1_count"] integerValue]== 0 && [self.data[@"product_2_count"] integerValue]== 0)
    {
        NSLog(@"Hiding");
        self.leftDetail.hidden = YES;
        self.rightDetail.hidden = YES;
        self.leftNumber.hidden = YES;
        self.rightNumber.hidden = YES;
    }
    else
    {
        self.leftDetail.hidden = NO;
        self.rightDetail.hidden = NO;
        self.leftNumber.hidden = NO;
        self.rightNumber.hidden = NO;
        
        self.leftNumber.text = [self.data[@"product_1_count"] stringValue];
        self.rightNumber.text = [self.data[@"product_2_count"] stringValue];
        
    }
    
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
    // Return the number of rows in the section.    
    int left = [[self.data objectForKey:@"fbFriend1"] count];
    int right = [[self.data objectForKey:@"fbFriend2"] count];
    if( left > right)
        return left;
    else
        return right;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{    
    NameCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
    if (!cell) {
        //cell = [[NameCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"Cell"];
        // More initializations if needed.
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"NameCell" owner:self options:nil];
        cell = (NameCell *)[nib objectAtIndex:0];
    }
    NSArray * leftFriends = [self.data objectForKey:@"fbFriend1"];
    NSArray * rightFriends = [self.data objectForKey:@"fbFriend2"];
    
    cell.leftImage.clipsToBounds = YES;
    cell.rightImage.clipsToBounds = YES;
    
    NSArray *ids = [[NSUserDefaults standardUserDefaults] objectForKey:@"friends"];
    NSArray *names = [[NSUserDefaults standardUserDefaults] objectForKey:@"names"];
    
    if (leftFriends.count > indexPath.row) // if we have something
    {
        //gets the id and name as a string
        NSString * currentID = [leftFriends objectAtIndex:indexPath.row];
        NSArray *ids = [[NSUserDefaults standardUserDefaults] objectForKey:@"friendsStrings"];
        NSArray *names = [[NSUserDefaults standardUserDefaults] objectForKey:@"names"];
        
        int index = [ids indexOfObject:currentID];
        NSString *name = [names objectAtIndex: index];
        
        cell.leftName.text = name;
        
        //now sets the image
        NSString *profileURL = @"https://graph.facebook.com/";
        profileURL = [profileURL stringByAppendingString:currentID];
        profileURL = [profileURL stringByAppendingString:@"/picture?type=normal"];
        [cell.leftImage setImageWithURL:[NSURL URLWithString:profileURL] placeholderImage:[UIImage imageNamed:@"profile_icon.png"]];
    }
    else
    {
        cell.leftName.text = @"";
    }
    
    if (rightFriends.count > indexPath.row) // if we have something
    {                
        //gets the id and name as a string
        NSString * currentID = [rightFriends objectAtIndex:indexPath.row];
        NSArray *ids = [[NSUserDefaults standardUserDefaults] objectForKey:@"friendsStrings"];
        NSArray *names = [[NSUserDefaults standardUserDefaults] objectForKey:@"names"];
        
        int index = [ids indexOfObject:currentID];
        NSString *name = [names objectAtIndex: index];
        
        cell.rightName.text = name;
        
        //now sets the image
        NSString *profileURL = @"https://graph.facebook.com/";
        profileURL = [profileURL stringByAppendingString:currentID];
        profileURL = [profileURL stringByAppendingString:@"/picture?type=normal"];
        [cell.rightImage setImageWithURL:[NSURL URLWithString:profileURL] placeholderImage:[UIImage imageNamed:@"profile_icon.png"]];                
        
    }
    else
    {
        cell.rightName.text = @"";
    }
        
    NSLog(@"Just set the stuff");
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didEndDisplayingCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    NameCell *current = (NameCell *) cell;
    [current.leftImage cancelCurrentImageLoad];
    [current.rightImage cancelCurrentImageLoad];
}

@end
