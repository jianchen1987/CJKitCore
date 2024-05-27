//
//  HDFunctionThrottle.h
//  HDKitCore
//
//  Created by VanJay on 2019/10/31.
//  Copyright © 2019 chaos network technology. All rights reserved.
//

#import <Foundation/Foundation.h>

/** 方法节流类型 */
typedef NS_ENUM(NSInteger, HDFunctionThrottleType) {
    HDFunctionThrottleTypeDelayAndInvokeLast,       ///< 消息发送后延迟一段时间执行，如果在这段时间内继续发送消息，则重新计时
    HDFunctionThrottleTypeInvokeOnceInEachInterval  ///< 至少每隔指定的时间执行一次，多余的会被忽略，最后一次也会执行
};

typedef void (^HDFunctionThrottleHandler)(void);

@interface HDFunctionThrottle : NSObject

/// 方法节流
/// @param interval 时间间隔
/// @param handler 节流回调
+ (void)throttleWithInterval:(NSTimeInterval)interval handler:(HDFunctionThrottleHandler __nullable)handler;

/// 方法节流
/// @param interval 时间间隔
/// @param type 类型
/// @param handler 节流回调
+ (void)throttleWithInterval:(NSTimeInterval)interval type:(HDFunctionThrottleType)type handler:(HDFunctionThrottleHandler __nullable)handler;

/// 方法节流
/// @param interval 时间间隔
/// @param key 用于取消节流的 key，如果无需取消传 nil 即可
/// @param handler 节流回调
+ (void)throttleWithInterval:(NSTimeInterval)interval key:(NSString *__nullable)key handler:(HDFunctionThrottleHandler __nullable)handler;

/// 方法节流
/// @param interval 时间间隔
/// @param type 类型
/// @param key 用于取消节流的 key，如果无需取消传 nil 即可
/// @param handler 节流回调
+ (void)throttleWithInterval:(NSTimeInterval)interval type:(HDFunctionThrottleType)type key:(NSString *__nullable)key handler:(HDFunctionThrottleHandler __nullable)handler;

/// 方法节流
/// @param interval 时间间隔
/// @param type 类型
/// @param queue 线程，为 nil 则使用主线程
/// @param handler 节流回调
+ (void)throttleWithInterval:(NSTimeInterval)interval type:(HDFunctionThrottleType)type queue:(dispatch_queue_t __nullable)queue handler:(HDFunctionThrottleHandler __nullable)handler;

/// 方法节流
/// @param interval 时间间隔
/// @param key 用于取消节流的 key，如果无需取消传 nil 即可
/// @param queue 线程，为 nil 则使用主线程
/// @param handler 节流回调
+ (void)throttleWithInterval:(NSTimeInterval)interval key:(NSString *__nullable)key queue:(dispatch_queue_t __nullable)queue handler:(HDFunctionThrottleHandler __nullable)handler;

/// 方法节流
/// @param interval 时间间隔
/// @param type 类型
/// @param key 用于取消节流的 key，如果无需取消传 nil 即可
/// @param queue 线程，为 nil 则使用主线程
/// @param handler 节流回调
+ (void)throttleWithInterval:(NSTimeInterval)interval type:(HDFunctionThrottleType)type key:(NSString *__nullable)key queue:(dispatch_queue_t __nullable)queue handler:(HDFunctionThrottleHandler __nullable)handler;

/// 取消方法节流，无需传入 type，内部根据 key 取消所有类型的节流，所以如果使用的策略不同尽量使用不同的 key
/// @param key 标志 key
+ (void)throttleCancelWithKey:(NSString *__nullable)key;

/// 方法节流
/// @param interval 时间间隔
/// @param key 用于取消节流的 key，如果无需取消传 nil 即可
/// @param handler 节流回调
void dispatch_throttle(NSTimeInterval interval, NSString *__nullable key, HDFunctionThrottleHandler __nullable handler);

/// 方法节流
/// @param interval 时间间隔
/// @param key 用于取消节流的 key，如果无需取消传 nil 即可
/// @param queue 线程，为 nil 则使用主线程
/// @param handler 节流回调
void dispatch_throttle_on_queue(NSTimeInterval interval, dispatch_queue_t __nullable queue, NSString *__nullable key, HDFunctionThrottleHandler __nullable handler);

/// 方法节流
/// @param interval 时间间隔
/// @param type 类型
/// @param key 用于取消节流的 key，如果无需取消传 nil 即可
/// @param handler 节流回调
void dispatch_throttle_by_type(NSTimeInterval interval, HDFunctionThrottleType type, NSString *__nullable key, HDFunctionThrottleHandler __nullable handler);

/// 方法节流
/// @param interval 时间间隔
/// @param type 类型
/// @param key 用于取消节流的 key，如果无需取消传 nil 即可
/// @param queue 线程，为 nil 则使用主线程
/// @param handler 节流回调
void dispatch_throttle_by_type_on_queue(NSTimeInterval interval, HDFunctionThrottleType type, dispatch_queue_t __nullable queue, NSString *__nullable key, HDFunctionThrottleHandler __nullable handler);

/// 取消方法节流，无需传入 type，内部根据 key 取消所有类型的节流，所以如果使用的策略不同尽量使用不同的 key
/// @param key 标志 key
void dispatch_throttle_cancel(NSString *__nonnull key);

@end
