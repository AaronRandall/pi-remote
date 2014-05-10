//
//  PRViewController.m
//  PiRemote
//
//  Created by Aaron Randall on 05/05/2014.
//  Copyright (c) 2014 Aaron Randall. All rights reserved.
//

#import "PRViewController.h"
#import "PRNetworkDeviceDiscovery.h"

@interface PRViewController ()

@end

@implementation PRViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
}

- (void)viewDidAppear:(BOOL)animated
{
    NSDictionary* infoDict = [[NSBundle mainBundle] infoDictionary];
    NSDictionary* piRemoteServer = [infoDict objectForKey:@"PiRemoteServerDiscoverAPI"];
    
    NSString *scheme = piRemoteServer[@"Scheme"];
    int port = [piRemoteServer[@"Port"] integerValue];
    NSString *path = piRemoteServer[@"Path"];
    
    PRNetworkDeviceDiscovery *networkDeviceDiscovery = [[PRNetworkDeviceDiscovery alloc] initWithScheme:scheme
                                                                                                   port:port
                                                                                                   path:path];
    networkDeviceDiscovery.delegate = self;
    
    [networkDeviceDiscovery startDiscovery];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark -
#pragma mark PRNetworkDeviceDiscoveryDelegate callbacks

- (void)didDiscoverNetworkDeviceAtIP:(NSString *)ip withHostname:(NSString *)hostname
{
    NSLog(@"In callback for didDiscoverNetworkDeviceAtIP");
}

- (void)didFailToDiscoverNetworkDevice
{
    NSLog(@"In callback for didFailToDiscoverNetworkDevice");
}

@end
