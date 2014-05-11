//
//  PRViewController.m
//  PiRemote
//
//  Created by Aaron Randall on 05/05/2014.
//  Copyright (c) 2014 Aaron Randall. All rights reserved.
//

#import "PRViewController.h"
#import "PRNetworkDeviceDiscovery.h"
#import "FBShimmeringView+Common.h"
#import "POPSpringAnimation+Common.h"

@interface PRViewController ()

@end

@implementation PRViewController {
    PRNetworkDeviceDiscovery *_networkDeviceDiscovery;
    FBShimmeringView *_shimmeringView;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	
    [self setupNetworkDeviceDiscovery];
}

- (void)viewWillAppear:(BOOL)animated
{
    [self startSearchingLabelAnimation];
}

- (void)viewDidAppear:(BOOL)animated
{
    CALayer *layer = self.searchingLabel.layer;
    [layer pop_removeAllAnimations];
    
    POPSpringAnimation *animation = [POPSpringAnimation slideDownAnimationFrom:@(-200) to:@(50)];
    
    animation.completionBlock = ^(POPAnimation *anim, BOOL finished) {
        // Give the shimmer animation a second to display before doing an leg work
        double delayInSeconds = 1.0;
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
            [_networkDeviceDiscovery startDiscovery];
        });
    };
    
    [layer pop_addAnimation:animation forKey:@"slide_down"];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark -
#pragma mark Setups

- (void)setupNetworkDeviceDiscovery
{
    NSDictionary* infoDict = [[NSBundle mainBundle] infoDictionary];
    NSDictionary* piRemoteServer = [infoDict objectForKey:@"PiRemoteServerDiscoverAPI"];
    
    NSString *scheme = piRemoteServer[@"Scheme"];
    int port = [piRemoteServer[@"Port"] intValue];
    NSString *path = piRemoteServer[@"Path"];
    
    _networkDeviceDiscovery = [[PRNetworkDeviceDiscovery alloc] initWithScheme:scheme
                                                                          port:port
                                                                          path:path];
    _networkDeviceDiscovery.delegate = self;
}

#pragma mark -
#pragma mark Animations

- (void)startSearchingLabelAnimation
{
    _shimmeringView = [FBShimmeringView commonConfigurationWithFrame:self.searchingLabel.frame];
    
    [self.view addSubview:_shimmeringView];
    
    _shimmeringView.contentView = self.searchingLabel;
    _shimmeringView.shimmering = YES;
}

#pragma mark -
#pragma mark PRNetworkDeviceDiscoveryDelegate callbacks

- (void)didDiscoverNetworkDeviceAtIP:(NSString *)ip withHostname:(NSString *)hostname
{
    self.discoveredRaspberryPiLabel.text = [NSString stringWithFormat: @"Woohoo! Found %@.", hostname];
    
    _shimmeringView.shimmering = NO;
    
    CALayer *layer = self.searchingLabel.layer;
    [layer pop_removeAllAnimations];
    
    POPSpringAnimation *animation = [POPSpringAnimation slideUpAnimationFrom:nil to:@(25)];
    
    animation.completionBlock = ^(POPAnimation *anim, BOOL finished) {
        self.discoveredRaspberryPiLabel.alpha = 0;
        self.discoveredRaspberryPiLabel.hidden = NO;
        
        [UIView animateWithDuration:0.7f
                         animations:^{
                             self.discoveredRaspberryPiLabel.alpha = 1;
                         } completion:^(BOOL finished) {
                             double delayInSeconds = 2.0;
                             dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
                             dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                                 [self performSegueWithIdentifier: @"ToRemoteView" sender: self];
                             });
                         }];
    };
    
    [layer pop_addAnimation:animation forKey:@"slide_up"];
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
