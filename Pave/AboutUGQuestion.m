//
//  AboutUGQuestion.m
//  Pave
//
//  Created by Neel Patel on 7/19/13.
//  Copyright (c) 2013 Pave. All rights reserved.
//

#import "AboutUGQuestion.h"
#import "NameCell.h"

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
    self = [super init];
    if(self)
    {
        NSLog(@"Just created");
        self.data = data;        
    }

    //NSLog(@"NSUser: %@", [[NSUserDefaults standardUserDefaults] dictionaryRepresentation]);

    
    return self;

}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.question.text = [self.data objectForKey:@"question_text"];
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
    
    NSArray *ids = [[NSUserDefaults standardUserDefaults] objectForKey:@"friends"];
    NSArray *names = [[NSUserDefaults standardUserDefaults] objectForKey:@"names"];
    
    if (leftFriends.count > indexPath.row) // if we have something
    {
        //id currentID = [leftFriends objectAtIndex:indexPath.row];
        //int index = [ids indexOfObject:currentID];
        //NSString *name = [names objectAtIndex:index];
        cell.leftName.text = [leftFriends objectAtIndex:indexPath.row];
    }
    else
    {
        cell.leftName.text = @"";
    }
    
    if (rightFriends.count > indexPath.row) // if we have something
    {        
        //NSString * currentID = [rightFriends objectAtIndex:indexPath.row];
        //int index = [ids indexOfObject:currentID];
        //NSLog(@"For id %@ at index %d", currentID, index);
        //NSString *name = [names objectAtIndex:index];
        cell.rightName.text = [rightFriends objectAtIndex:indexPath.row];
    }
    else
    {
        cell.rightName.text = @"";
    }
        
    NSLog(@"Just set the stuff");
    
    return cell;
}

@end