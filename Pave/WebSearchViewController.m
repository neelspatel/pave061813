//
//  WebSearchViewController.m
//  Pave
//
//  Created by Neel Patel on 7/14/13.
//  Copyright (c) 2013 Pave. All rights reserved.
//

#import "WebSearchViewController.h"
#import "AskViewController.h"
#import "WebImageCell.h"
#import "AFJSONRequestOperation.h"
#import "UIImageView+WebCache.h"

@interface WebSearchViewController ()

@end

@implementation WebSearchViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.results = [[NSArray alloc] init];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    NSURL *url = [NSURL URLWithString:@"http://54.244.251.104/data/imagesearch/fast_car/"];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    
    AFJSONRequestOperation *operation = [AFJSONRequestOperation JSONRequestOperationWithRequest:request success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
        
            NSLog(@"JSON: %@", JSON);
            self.results = JSON;
            [self.collection reloadData];
    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
        NSLog(@"%@", [error userInfo]);
    }];
    
    [operation start];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Collection View Data Sources

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.results.count;
}

// The cell that is returned must be retrieved from a call to - dequeueReusableCellWithReuseIdentifier:forIndexPath:
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    WebImageCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"WebImageCell" forIndexPath:indexPath];
    
    [cell.image setImageWithURL:[NSURL URLWithString:[self.results[indexPath.row] objectForKey: @"thumbnailurl"]] placeholderImage:[UIImage imageNamed:@"profile_icon.png"]];
    NSLog(@"Current: %@", self.results[indexPath.row]);
    
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{       
    NSLog(@"hello, selected %d", indexPath.row);
    
     NSString *url = [self.results[indexPath.row] objectForKey: @"thumbnailurl"];
    
    //sets url
    NSDictionary *data;
    
    if ([self.side isEqualToString: @"Left"])
    {
        //((AskViewController *)self.parentViewController).leftURL = url;
        
        data = [[NSDictionary alloc] initWithObjectsAndKeys: @"left", @"side", url, @"url", nil];
    }
    else if ([self.side isEqualToString: @"Right"])
    {
        //((AskViewController *)self.parentViewController).rightURL = url;
        
        data = [[NSDictionary alloc] initWithObjectsAndKeys: @"right", @"side", url, @"url", nil];
    }
        
    //sends the notificaiton to update
    [[NSNotificationCenter defaultCenter]
     postNotificationName:@"refreshAskImages"
     object:self userInfo: data];
    
    [self dismissViewControllerAnimated:YES completion:nil];
}



@end
