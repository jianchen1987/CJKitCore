//
//  HDDispatchMainQueueSafe.h
//  HDKitCore
//
//  Created by VanJay on 2018/8/18.
//  Copyright © 2018年 chaos network technology. All rights reserved.
//

#ifndef __TGDispatchMainQueueSafe__
#define __TGDispatchMainQueueSafe__

#include <stdio.h>

typedef void (^HDDispatchCallbackBlock)(void);

void hd_dispatch_main_async_safe(HDDispatchCallbackBlock block);

void hd_dispatch_main_sync_safe(HDDispatchCallbackBlock block);

#endif
