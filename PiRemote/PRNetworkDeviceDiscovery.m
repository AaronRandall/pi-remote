//
//  PRNetworkDeviceDiscovery.m
//  PiRemote
//
//  Created by Aaron Randall on 05/05/2014.
//  Copyright (c) 2014 Aaron Randall. All rights reserved.
//

#import "PRNetworkDeviceDiscovery.h"
#import "AFNetworking.h"

@implementation PRNetworkDeviceDiscovery {
    NSString *_apiPath;
}

- (id)init
{
    return [self initWithApiPath:@""];
}

- (id)initWithApiPath:(NSString*)apiPath
{
    self = [super init];
    
    if(self) {
        _apiPath = apiPath;
    }
    
    return self;
}

- (void)startDiscovery
{
    //[self.delegate didDiscoverNetworkDeviceAtIP:@"1.2.3.4" withHostname:@"some-hostname"];
    
    [self attemptConnectionForIP:@"192.168.0.7:8080" withPath:_apiPath];
    
    
}

- (void)attemptConnectionForIP:(NSString*)ip withPath:(NSString*)path
{
    NSString *string = [NSString stringWithFormat:@"http://%@%@.json", ip, path];
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [manager GET:string parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"JSON: %@", responseObject);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error);
    }];
}

@end
