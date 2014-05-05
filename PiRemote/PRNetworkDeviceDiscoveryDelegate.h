//
//  PRNetworkDeviceDiscoveryDelegate.h
//  PiRemote
//
//  Created by Aaron Randall on 05/05/2014.
//  Copyright (c) 2014 Aaron Randall. All rights reserved.
//

@protocol PRNetworkDeviceDiscoveryDelegate <NSObject>

- (void)didDiscoverNetworkDeviceAtIP:(NSString*)ip withHostname:(NSString*)hostname;

@end