//
//  JSONAPIClient.m
//  Pave
//
//  Created by Nithin Tumma on 7/14/13.
//  Copyright (c) 2013 Pave. All rights reserved.
//

#import "JSONAPIClient.h"
#import "AFJSONRequestOperation.h"

// the url of our AWS
//static NSString * const kPaveAPIBaseURLString = @"http://ec2-54-245-213-191.us-west-2.compute.amazonaws.com/data/";
static NSString * const kPaveAPIBaseURLString = @"http://54.244.251.104/data/";


@implementation JSONAPIClient

+ (JSONAPIClient *)sharedClient {
    NSLog(@"got sharedClient");
    static JSONAPIClient *_sharedClient = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedClient = [[JSONAPIClient alloc] initWithBaseURL:[NSURL URLWithString:kPaveAPIBaseURLString]];
    });
    
    return _sharedClient;
}

// might need to deal with the SSL Pinning
- (id)initWithBaseURL:(NSURL *)url {
    NSLog(@"initialized sharedClient");
    self = [super initWithBaseURL:url];
    if (!self) {
        return nil;
    }
    
    [self registerHTTPOperationClass:[AFJSONRequestOperation class]];
    
    // Accept HTTP Header; see http://www.w3.org/Protocols/rfc2616/rfc2616-sec14.html#sec14.1
	[self setDefaultHeader:@"Accept" value:@"application/json"];
    [self setParameterEncoding:AFFormURLParameterEncoding];
    
    return self;
}

@end
