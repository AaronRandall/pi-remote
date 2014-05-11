//
//  PRViewController.m
//  PiRemote
//
//  Created by Aaron Randall on 05/05/2014.
//  Copyright (c) 2014 Aaron Randall. All rights reserved.
//

#import "PRViewController.h"
#import "PRNetworkDeviceDiscovery.h"
#import "FBShimmeringView.h"
#import <POP/POP.h>

@interface PRViewController ()

@end

@implementation PRViewController {
    FBShimmeringView *_shimmeringView;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
}

- (void)viewWillAppear:(BOOL)animated
{
    _shimmeringView = [[FBShimmeringView alloc] initWithFrame:self.searchingLabel.frame];
    _shimmeringView.shimmering = YES;
    _shimmeringView.shimmeringOpacity = 0.2;
    _shimmeringView.shimmeringSpeed = 100;
    
    [self.view addSubview:_shimmeringView];
    
    _shimmeringView.contentView = self.searchingLabel;
    _shimmeringView.shimmering = YES;
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
    
    
    CALayer *layer = self.searchingLabel.layer;
    [layer pop_removeAllAnimations];
    
    POPSpringAnimation *anim = [POPSpringAnimation animationWithPropertyNamed:kPOPLayerPositionY];
    anim.fromValue = @(-200);
    anim.toValue = @(50);
    anim.springBounciness = 10;
    anim.springSpeed = 2;
    
    anim.completionBlock = ^(POPAnimation *anim, BOOL finished) {
        // Give the shimmer animation a second to display before doing an leg work
        double delayInSeconds = 1.0;
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
            [networkDeviceDiscovery startDiscovery];
        });
    };
    
    [layer pop_addAnimation:anim forKey:@"slide_down"];
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
    
    self.discoveredRaspberryPiLabel.text = [NSString stringWithFormat: @"Woohoo! Found %@.", hostname];
    
    _shimmeringView.shimmering = NO;
    
    CALayer *layer = self.searchingLabel.layer;
    [layer pop_removeAllAnimations];
    
    POPSpringAnimation *anim = [POPSpringAnimation animationWithPropertyNamed:kPOPLayerPositionY];
    anim.toValue = @(25);
    anim.springBounciness = 10;
    anim.springSpeed = 2;
    
    anim.completionBlock = ^(POPAnimation *anim, BOOL finished) {
        self.discoveredRaspberryPiLabel.alpha = 0;
        self.discoveredRaspberryPiLabel.hidden = NO;
        
        [UIView animateWithDuration:0.7f
                         animations:^{
                             self.discoveredRaspberryPiLabel.alpha = 1;
                         } completion:^(BOOL finished) {
                             NSLog(@"TODO: Move onto main remote view");
                             double delayInSeconds = 2.0;
                             dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
                             dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                                 [self performSegueWithIdentifier: @"ToRemoteView" sender: self];
                             });
                         }];
    };
    
    [layer pop_addAnimation:anim forKey:@"slide_up"];
}

- (void)didFailToDiscoverNetworkDeviceWithFailureReason:(PRNetworkDeviceDiscoveryFailureReason)failureReason
{
    NSLog(@"In callback for didFailToDiscoverNetworkDevice");
    switch (failureReason) {
        case PRNetworkDeviceDiscoveryFailureReasonNoWifi:
            NSLog(@"No wifi found");
            break;
        case PRNetworkDeviceDiscoveryFailureReasonServerNotFound:
            NSLog(@"Server not found");
            break;
        default:
            break;
    }
}

@end
