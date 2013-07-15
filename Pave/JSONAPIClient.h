//
//  JSONAPIClient.h
//  Pave
//
//  Created by Nithin Tumma on 7/14/13.
//  Copyright (c) 2013 Pave. All rights reserved.
//

#import "AFHTTPClient.h"

@interface JSONAPIClient : AFHTTPClient

+ (JSONAPIClient *) sharedClient;

@end
