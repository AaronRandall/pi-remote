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
    NSString *scheme = @"http";
    int port = 8080;
    NSString *apiPath = @"/pi_remote/discover.json";
    
    PRNetworkDeviceDiscovery *networkDeviceDiscovery = [[PRNetworkDeviceDiscovery alloc] initWithScheme:scheme
                                                                                                   port:port
                                                                                                apiPath:apiPath];
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
