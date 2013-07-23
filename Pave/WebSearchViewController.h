//
//  WebSearchViewController.h
//  Pave
//
//  Created by Neel Patel on 7/14/13.
//  Copyright (c) 2013 Pave. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WebSearchViewController : UIViewController <UICollectionViewDelegate,UICollectionViewDataSource, UISearchBarDelegate>

@property (nonatomic, retain)NSArray *results;
@property (weak, nonatomic) IBOutlet UICollectionView *collection;
@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;
@property (nonatomic, retain) NSString *side;

- (IBAction)search:(id)sender;
- (IBAction)back:(id)sender;

@end
