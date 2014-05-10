//
//  PRNetworkDeviceDiscovery.m
//  PiRemote
//
//  Created by Aaron Randall on 05/05/2014.
//  Copyright (c) 2014 Aaron Randall. All rights reserved.
//

#import "PRNetworkDeviceDiscovery.h"
#import "AFNetworking.h"
#import "Reachability.h"

static const int maxConcurrentOperationCount = 8;

@implementation PRNetworkDeviceDiscovery {
    NSString *_scheme;
    int _port;
    NSString *_path;
    
    AFHTTPRequestOperationManager *_manager;
    NSMutableArray *_requestOperations;
}

- (id)init
{
    return [self initWithScheme:@"http" port:80 path:@"/"];
}

- (id)initWithScheme:(NSString*)scheme port:(int)port path:(NSString*)path
{
    self = [super init];
    
    if(self) {
        _scheme = scheme;
        _port = port;
        _path = path;
        
        _manager = [AFHTTPRequestOperationManager manager];
        _requestOperations = [NSMutableArray array];
    }
    
    return self;
}

- (void)startDiscovery
{
    if ([self deviceIsOnWiFi]) {
        // Try to autodetect the server
        
        // Get the device IP address
        NSString *ipAddress = [self getIPAddress];
        
        // Get the first 3 octecs, and try to find the server on all IPs in that range
        NSArray *ipAdressOctets = [ipAddress componentsSeparatedByString:@"."];
        NSString *ipAddress3Octets = [NSString stringWithFormat:@"%@.%@.%@",
                                      [ipAdressOctets objectAtIndex:0],
                                      [ipAdressOctets objectAtIndex:1],
                                      [ipAdressOctets objectAtIndex:2]];
        
        // Set the max concurrent operations to 8
        [[_manager operationQueue] setMaxConcurrentOperationCount:maxConcurrentOperationCount];
        
        for (int i = 0; i < 256; i++) {
            NSString *currentIPAddress = [NSString stringWithFormat:@"%@.%d",ipAddress3Octets, i];
            
            NSString *urlString = [NSString stringWithFormat:@"%@://%@:%d%@", _scheme, currentIPAddress, _port, _path];
            NSURL *url = [NSURL URLWithString:urlString];
            
            NSLog(@"* Requesting %@", urlString);
            
            // Construct a request operation for the current IP
            [_requestOperations addObject:[self requestOperationForURL:url]];
        }
        
        [self processRequestOperations];
        
    } else {
        // Show prompt to connect to wifi or enter IP manually
    }
}

- (AFHTTPRequestOperation*)requestOperationForURL:(NSURL*)url
{
    NSURLRequest *request = [NSURLRequest requestWithURL:url
                                             cachePolicy:NSURLRequestUseProtocolCachePolicy
                                         timeoutInterval:2.0];
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSDictionary *operationResponse = [self dictionaryWithResponseObject:responseObject];
        
        if ([self requestOperationResponseContainsSuccessStatus:operationResponse]) {
            NSString *host = [[[operation request] URL] host];
            NSString *hostname = operationResponse[@"data"][@"hostname"];
            
            [self discoveredNetworkDeviceAtIP:host withHostname:hostname];
        }
    }
                                     failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                         NSLog(@"ERROR for URL: %@: %@",  [[operation request] URL], error.description);
                                         
                                     }
     ];
    
    return operation;
}

- (void)processRequestOperations
{
    NSArray *batchOperations = [AFURLConnectionOperation batchOfRequestOperations:_requestOperations
                                                                    progressBlock:NULL
                                                                  completionBlock:^(NSArray *operations) {
                                                                      // All requests finished
                                                                      [self failedToDiscoverNetworkDevice];
                                                                  }];
    
    [[_manager operationQueue] addOperations:batchOperations waitUntilFinished:NO];
}

- (NSString *)getIPAddress
{
    NSString *address = @"error";
    struct ifaddrs *interfaces = NULL;
    struct ifaddrs *temp_addr = NULL;
    int success = 0;
    
    // retrieve the current interfaces - returns 0 on success
    success = getifaddrs(&interfaces);
    if (success == 0) {
        // Loop through linked list of interfaces
        temp_addr = interfaces;
        while (temp_addr != NULL) {
            if( temp_addr->ifa_addr->sa_family == AF_INET) {
                // Check if interface is en0 which is the wifi connection on the iPhone
                if ([[NSString stringWithUTF8String:temp_addr->ifa_name] isEqualToString:@"en0"]) {
                    // Get NSString from C String
                    address = [NSString stringWithUTF8String:inet_ntoa(((struct sockaddr_in *)temp_addr->ifa_addr)->sin_addr)];
                }
            }
            
            temp_addr = temp_addr->ifa_next;
        }
    }
    
    // Free memory
    freeifaddrs(interfaces);
    
    return address;
}

- (BOOL)deviceIsOnWiFi
{
    Reachability *reachability = [Reachability reachabilityForInternetConnection];
    [reachability startNotifier];
    
    NetworkStatus status = [reachability currentReachabilityStatus];
    
    if (status == ReachableViaWiFi)
    {
        return YES;
    }
    
    return NO;
}

- (NSDictionary*)dictionaryWithResponseObject:(id)responseObject
{
    NSDictionary *operationResponse;
    NSError *error = nil;
    if (responseObject != nil) {
        operationResponse = [NSJSONSerialization JSONObjectWithData:responseObject
                                                            options:NSJSONReadingMutableContainers
                                                              error:&error];
    }
    
    return operationResponse;
}

- (BOOL)requestOperationResponseContainsSuccessStatus:(NSDictionary*)response
{
    if (response && response[@"status"]) {
        NSString *status = [response[@"status"] lowercaseString];
        
        if ([status isEqualToString:@"success"]) {
            return YES;
        }
    }
    
    return NO;
}

- (void)discoveredNetworkDeviceAtIP:(NSString*)ip withHostname:(NSString*)hostname
{
    // Stop all other requests
    [[_manager operationQueue] cancelAllOperations];
    
    [self.delegate didDiscoverNetworkDeviceAtIP:ip withHostname:hostname];
}

- (void)failedToDiscoverNetworkDevice
{
    [self.delegate didFailToDiscoverNetworkDevice];
}

@end
