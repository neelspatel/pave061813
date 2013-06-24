//
//  Answerl.m
//  Mockup
//
//  Created by Nithin Tumma on 6/12/13.
//  Copyright (c) 2013 Neel Patel. All rights reserved.
//

#import "FeedObject.h"

@implementation FeedObject


// required for KCSPersistable protocol
-(NSDictionary *)hostToKinveyPropertyMapping {
    // maybe update to use dispatch_once to improve efficiency
    return @{
    @"answers": @"answers",
    @"entityId": KCSEntityKeyId,
    @"questionId": @"questionId",
    @"questionText": @"questionText",
    @"firstProductId": @"firstProductId",
    @"secondProductId": @"secondProductId",
    @"firstProductFileName": @"firstProductFileName",
    @"secondProductFileName": @"secondProductFileName",
    @"userId": @"userId",
    //@"metadata": KCSEntityKeyMetadata
    };
    
}

@end

