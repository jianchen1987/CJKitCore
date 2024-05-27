//
//  HDLogItem.h
//  HDKitCore
//
//  Created by VanJay on 2019/12/30.
//  Copyright © 2019 chaos network technology. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, HDLogLevel) {
    HDLogLevelDefault,  // 当使用 HDLog() 时使用的等级, 调试信息
    HDLogLevelInfo,     // 当使用 HDLogInfo() 时使用的等级，比 HDLogLevelDefault 要轻量，适用于一些无关紧要的信息
    HDLogLevelWarn,     // 当使用 HDLogWarn() 时使用的等级，最重，适用于一些异常或者警告的场景
    HDLogLevelErr       // 当使用 HDLogErr() 时使用的等级，最重，适用于严重错误的场景
};

/// 每一条 HDLog 日志都以 HDLogItem 的形式包装起来
@interface HDLogItem : NSObject

/// 日志的等级，可通过 HDConfigurationTemplate 配置表控制全局每个 level 是否可用
@property (nonatomic, assign) HDLogLevel level;
@property (nonatomic, copy, readonly) NSString *levelDisplayString;

/// 可利用 name 字段为日志分类，HDLogNameManager 可全局控制某一个 name 是否可用
@property (nullable, nonatomic, copy) NSString *name;

/// 日志的内容
@property (nonatomic, copy) NSString *logString;

/// 当前 logItem 对应的 name 是否可用，可通过 HDLogNameManager 控制，默认为 YES
@property (nonatomic, assign) BOOL enabled;

+ (nonnull instancetype)logItemWithLevel:(HDLogLevel)level name:(nullable NSString *)name logString:(nonnull NSString *)logString, ... NS_FORMAT_FUNCTION(3, 4);
@end

NS_ASSUME_NONNULL_END
