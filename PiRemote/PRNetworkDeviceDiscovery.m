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
        
        NSString *serverPort = @"8080";
        
        for (int i = 0; i <10; i++) {
            NSString *currentIPAddress = [NSString stringWithFormat:@"%@.%d:%@",ipAddress3Octets, i, serverPort];
            [self attemptConnectionForIP:currentIPAddress withPath:_apiPath];
            sleep(1);
        }
    } else {
        // Show prompt to connect to wifi or enter IP manually
    }
}

- (void)attemptConnectionForIP:(NSString*)ip withPath:(NSString*)path
{
    NSString *scheme = @"http";
    NSString *string = [NSString stringWithFormat:@"%@://%@%@.json", scheme, ip, path];
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [manager GET:string parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"JSON: %@", responseObject);
        [self.delegate didDiscoverNetworkDeviceAtIP:ip withHostname:@"some-hostname"];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error);
    }];
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

@end
