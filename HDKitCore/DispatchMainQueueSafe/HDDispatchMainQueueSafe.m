//
//  HDDispatchMainQueueSafe.m
//  HDKitCore
//
//  Created by VanJay on 2018/8/18.
//  Copyright © 2018年 chaos network technology. All rights reserved.
//

#include "HDDispatchMainQueueSafe.h"
#import <Foundation/Foundation.h>

void hd_dispatch_main_async_safe(HDDispatchCallbackBlock block) {
    if ([NSThread isMainThread]) {
        block();
    } else {
        dispatch_async(dispatch_get_main_queue(), block);
    }
}

void hd_dispatch_main_sync_safe(HDDispatchCallbackBlock block) {
    if ([NSThread isMainThread]) {
        block();
    } else {
        dispatch_sync(dispatch_get_main_queue(), block);
    }
}
