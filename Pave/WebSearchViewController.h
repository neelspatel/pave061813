//
//  WebSearchViewController.h
//  Pave
//
//  Created by Neel Patel on 7/14/13.
//  Copyright (c) 2013 Pave. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WebSearchViewController : UIViewController <UICollectionViewDelegate,UICollectionViewDataSource>

@property (nonatomic, retain)NSArray *results;
@property (weak, nonatomic) IBOutlet UICollectionView *collection;
@property (nonatomic, retain) NSString *side;


@end
