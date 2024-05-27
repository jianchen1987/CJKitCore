//
//  HDLogger.h
//  HDKitCore
//
//  Created by VanJay on 2019/12/30.
//  Copyright © 2019 chaos network technology. All rights reserved.
//

#import <Foundation/Foundation.h>

@class HDLogNameManager;
@class HDLogItem;

NS_ASSUME_NONNULL_BEGIN

@protocol HDLoggerDelegate <NSObject>

@optional

/**
 *  当每一个 enabled 的 HDLog 被使用时都会走到这里，可以由业务自行决定要如何处理这些 log，如果没实现这个方法，默认用 fprintf 打印内容
 *  @param file 当前的文件的本地完整路径，可通过 file.lastPathComponent 获取文件名
 *  @param line 当前 log 命令在该文件里的代码行数
 *  @param func 当前 log 命令所在的方法名
 *  @param logItem 当前 log 命令对应的 HDLogItem，可得知该 log 的 level
 *  @param defaultString 默认拼好的 log 内容
 */
- (NSString *_Nullable)printLogWithFile:(nonnull NSString *)file line:(int)line func:(nullable NSString *)func logItem:(nullable HDLogItem *)logItem defaultString:(nullable NSString *)defaultString;

/**
 *  当某个 logName 的 enabled 发生变化时，通知到 delegate。注意如果是新创建某个 logName 也会走到这里。
 *  @param logName 变化的 logName
 *  @param enabled 变化后的值
 */
- (void)logName:(nonnull NSString *)logName didChangeEnabled:(BOOL)enabled;

/**
 *  某个 logName 被删除时通知到 delegate
 *  @param logName 被删除的 logName
 */
- (void)HDLogNameDidRemove:(nonnull NSString *)logName;

@end

@interface HDLogger : NSObject

@property (nullable, nonatomic, weak) id<HDLoggerDelegate> delegate;
@property (nonnull, nonatomic, strong) HDLogNameManager *logNameManager;
@property (nonatomic, strong, readonly) NSDateFormatter *dateFormatter;  ///< dateFormatter

+ (nonnull instancetype)sharedInstance;
- (NSString *_Nullable)printLogWithFile:(nullable const char *)file line:(int)line func:(nonnull const char *)func logItem:(nullable HDLogItem *)logItem;
@end

NS_ASSUME_NONNULL_END
