//
//  POPSpringAnimation+Common.h
//  PiRemote
//
//  Created by Aaron Randall on 11/05/2014.
//  Copyright (c) 2014 Aaron Randall. All rights reserved.
//

#import "POPSpringAnimation.h"

@interface POPSpringAnimation (Common)

+ (POPSpringAnimation*)slideDownAnimationFrom:(id)from to:(id)to;
+ (POPSpringAnimation*)slideUpAnimationFrom:(id)from to:(id)to;

@end
