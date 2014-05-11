//
//  FBShimmeringView+Common.m
//  PiRemote
//
//  Created by Aaron Randall on 11/05/2014.
//  Copyright (c) 2014 Aaron Randall. All rights reserved.
//

#import "FBShimmeringView+Common.h"

@implementation FBShimmeringView (Common)

+ (FBShimmeringView*)commonConfigurationWithFrame:(CGRect)frame
{
    FBShimmeringView *shimmeringView = [[self alloc] initWithFrame:frame];
    shimmeringView.shimmering = YES;
    shimmeringView.shimmeringOpacity = 0.2;
    shimmeringView.shimmeringSpeed = 100;
    
    return shimmeringView;
}
    
@end
