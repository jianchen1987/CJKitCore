//
//  HDLog.h
//  HDKitCore
//
//  Created by VanJay on 2019/12/30.
//  Copyright © 2019 chaos network technology. All rights reserved.
//

#import "HDLogItem.h"
#import "HDLogNameManager.h"
#import "HDLogger.h"
#import <Foundation/Foundation.h>
#import <stdio.h>

/// 提供用于代替 NSLog() 的打 log 的方法，可根据 logName、logLevel 两个维度来控制某些 log 是否要被打印，以便在调试时去掉不关注的 log。

#define HDLogDefault(_name, ...) [[HDLogger sharedInstance] printLogWithFile:__FILE__ line:__LINE__ func:__FUNCTION__ logItem:[HDLogItem logItemWithLevel:HDLogLevelDefault name:_name logString:__VA_ARGS__]]

#define HDLogInfo(_name, ...) [[HDLogger sharedInstance] printLogWithFile:__FILE__ line:__LINE__ func:__FUNCTION__ logItem:[HDLogItem logItemWithLevel:HDLogLevelInfo name:_name logString:__VA_ARGS__]]
#define HDLogWarn(_name, ...) [[HDLogger sharedInstance] printLogWithFile:__FILE__ line:__LINE__ func:__FUNCTION__ logItem:[HDLogItem logItemWithLevel:HDLogLevelWarn name:_name logString:__VA_ARGS__]]
#define HDLogErr(_name, ...) [[HDLogger sharedInstance] printLogWithFile:__FILE__ line:__LINE__ func:__FUNCTION__ logItem:[HDLogItem logItemWithLevel:HDLogLevelErr name:_name logString:__VA_ARGS__]]

#ifdef DEBUG
#define HDLog(...) [[HDLogger sharedInstance] printLogWithFile:__FILE__ line:__LINE__ func:__FUNCTION__ logItem:[HDLogItem logItemWithLevel:HDLogLevelDefault name:@"HDKitCore" logString:__VA_ARGS__]]
#else
#define HDLog(...)
#endif
