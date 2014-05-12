//
//  PRViewController.h
//  PiRemote
//
//  Created by Aaron Randall on 05/05/2014.
//  Copyright (c) 2014 Aaron Randall. All rights reserved.
//

#import "PRNetworkDeviceDiscoveryDelegate.h"

@interface PRViewController : UIViewController<PRNetworkDeviceDiscoveryDelegate>

@property (weak, nonatomic) IBOutlet UILabel *searchingLabel;
@property (weak, nonatomic) IBOutlet UILabel *discoveredRaspberryPiLabel;
@property (weak, nonatomic) IBOutlet UIProgressView *progressView;

@end
