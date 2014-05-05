//
//  PRNetworkDeviceDiscovery.h
//  PiRemote
//
//  Created by Aaron Randall on 05/05/2014.
//  Copyright (c) 2014 Aaron Randall. All rights reserved.
//

#import "PRNetworkDeviceDiscoveryDelegate.h"

@interface PRNetworkDeviceDiscovery : NSObject

- (id)initWithApiPath:(NSString*)apiPath;
- (void)startDiscovery;

@property (weak, nonatomic) id<PRNetworkDeviceDiscoveryDelegate> delegate;

@end
