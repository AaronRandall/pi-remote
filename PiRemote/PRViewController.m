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

#pragma mark -
#pragma mark View lifecycle

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
    self.searchingLabel.hidden = YES;
    
    CALayer *layer = self.searchingLabel.layer;
    [layer pop_removeAllAnimations];
    
    POPSpringAnimation *animation = [POPSpringAnimation slideDownAnimationFrom:@(-50) to:@(25)];
    
    animation.completionBlock = ^(POPAnimation *animation, BOOL finished) {
        // Give the shimmer animation a short delay to display before attempting to discover the server
        dispatch_async_main_after(1.5, ^(void){
            [_networkDeviceDiscovery startDiscovery];
        });
    };
    
    dispatch_async_main_after(1.0, ^(void){
        [layer pop_addAnimation:animation forKey:@"slide_down"];
        self.searchingLabel.hidden = NO;
    });
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
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
    self.discoveredRaspberryPiLabel.text = [NSString stringWithFormat: @"Woohoo! Found '%@.'", hostname];
    
    _shimmeringView.shimmering = NO;
    
    CALayer *layer = self.searchingLabel.layer;
    [layer pop_removeAllAnimations];
    
    POPSpringAnimation *animation = [POPSpringAnimation slideUpAnimationFrom:nil to:@(26)];
    
    animation.completionBlock = ^(POPAnimation *animation, BOOL finished) {
        self.discoveredRaspberryPiLabel.alpha = 0;
        self.discoveredRaspberryPiLabel.hidden = NO;
        
        [UIView animateWithDuration:0.7f
                         animations:^{
                             self.discoveredRaspberryPiLabel.alpha = 1;
                         } completion:^(BOOL finished) {
                             dispatch_async_main_after(2.0, ^(void){
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

- (void)didUpdatePercentageProgress:(float)progress
{
    [self.progressView setProgress:progress animated:YES];
}

@end
