//
//  PaveAPIClient.m
//  Mockup
//
//  Created by Nithin Tumma on 6/16/13.
//  Copyright (c) 2013 Neel Patel. All rights reserved.
//

#import "PaveAPIClient.h"
#import "AFJSONRequestOperation.h"

// the url of our AWS 
static NSString * const kPaveAPIBaseURLString = @"http://ec2-54-245-213-191.us-west-2.compute.amazonaws.com/data/";

@implementation PaveAPIClient

+ (PaveAPIClient *)sharedClient {
    NSLog(@"got sharedClient");
    static PaveAPIClient *_sharedClient = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedClient = [[PaveAPIClient alloc] initWithBaseURL:[NSURL URLWithString:kPaveAPIBaseURLString]];
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
