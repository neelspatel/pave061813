//
//  WalkthroughViewController.h
//  Pave
//
//  Created by Nithin Tumma on 7/22/13.
//  Copyright (c) 2013 Pave. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WalkthroughViewController : UIViewController <UIPageViewControllerDataSource>

@property (strong, nonatomic) UIPageViewController *pageController;

@property (strong, nonatomic) NSDictionary *flurryDict;
@end

