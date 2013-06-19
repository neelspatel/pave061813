//
//  PaveAPIClient.h
//  Mockup
//
//  Created by Nithin Tumma on 6/16/13.
//  Copyright (c) 2013 Neel Patel. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AFHTTPClient.h"

@interface PaveAPIClient : AFHTTPClient

+ (PaveAPIClient *) sharedClient;

@end
