//
//  Mockup
//
//  Created by Nithin Tumma on 6/12/13.
//  Copyright (c) 2013 Neel Patel. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FeedObject : NSObject

@property (nonatomic, copy) NSString *entityId;
@property (nonatomic, strong) NSMutableArray* answers;
@property (nonatomic, copy) NSString *questionId;
@property (nonatomic, copy) NSString *questionText;
@property (nonatomic, copy) NSString *firstProductId;
@property (nonatomic, copy) NSString *secondProductId;
@property (nonatomic, copy) NSString *firstProductFileName;
@property (nonatomic, copy) NSString *secondProductFileName;
@property (nonatomic, copy) NSString *userId;

@end