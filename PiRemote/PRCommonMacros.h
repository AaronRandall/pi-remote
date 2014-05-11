//
//  PRCommonMacros.h
//  PiRemote
//
//  Created by Aaron Randall on 11/05/2014.
//  Copyright (c) 2014 Aaron Randall. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PRCommonMacros : NSObject

static inline void dispatch_async_main_after(NSTimeInterval after, dispatch_block_t block) {
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(after * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), block);
}

@end
