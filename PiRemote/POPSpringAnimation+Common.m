//
//  POPSpringAnimation+Common.m
//  PiRemote
//
//  Created by Aaron Randall on 11/05/2014.
//  Copyright (c) 2014 Aaron Randall. All rights reserved.
//

#import "POPSpringAnimation+Common.h"

static const int kSpringBounciness = 10;
static const int kSpringSpeed = 10;

@implementation POPSpringAnimation (Common)

+ (POPSpringAnimation*)positionYAnimationFrom:(id)from to:(id)to
{
    POPSpringAnimation *slideDownAnimation = [self animationWithPropertyNamed:kPOPLayerPositionY];
    slideDownAnimation.fromValue = from;
    slideDownAnimation.toValue = to;
    slideDownAnimation.springBounciness = kSpringBounciness;
    slideDownAnimation.springSpeed = kSpringSpeed;
    
    return slideDownAnimation;
}

@end
