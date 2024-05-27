//
//  HDFunctionThrottle.m
//  HDKitCore
//
//  Created by VanJay on 2019/10/31.
//  Copyright © 2019 chaos network technology. All rights reserved.
//

#import "HDFunctionThrottle.h"

@implementation HDFunctionThrottle

#pragma mark - public methods

void dispatch_throttle(NSTimeInterval interval, NSString *__nullable key, HDFunctionThrottleHandler __nullable handler) {
    [HDFunctionThrottle throttleWithInterval:interval type:HDFunctionThrottleTypeDelayAndInvokeLast queue:nil handler:handler];
}

void dispatch_throttle_on_queue(NSTimeInterval interval, dispatch_queue_t queue, NSString *__nullable key, HDFunctionThrottleHandler __nullable handler) {
    [HDFunctionThrottle throttleWithInterval:interval type:HDFunctionThrottleTypeDelayAndInvokeLast queue:queue handler:handler];
}

void dispatch_throttle_by_type(NSTimeInterval interval, HDFunctionThrottleType type, NSString *__nullable key, HDFunctionThrottleHandler __nullable handler) {
    [HDFunctionThrottle throttleWithInterval:interval type:type key:key queue:nil handler:handler];
}

void dispatch_throttle_by_type_on_queue(NSTimeInterval interval, HDFunctionThrottleType type, dispatch_queue_t __nullable queue, NSString *__nullable key, HDFunctionThrottleHandler __nullable handler) {
    [HDFunctionThrottle throttleWithInterval:interval type:type key:key queue:queue handler:handler];
}

void dispatch_throttle_cancel(NSString *__nonnull key) {
    [HDFunctionThrottle throttleCancelWithKey:key];
}

// HDFunctionThrottleTypeInvokeOnceInEachInterval 类型时触发最后一次调用的定时器
dispatch_source_t _checkLastTTimeCallTimer;

#pragma mark private: general
+ (NSMutableDictionary<NSString *, dispatch_source_t> *)scheduledSources {
    static NSMutableDictionary *_sources = nil;
    static dispatch_once_t token;
    dispatch_once(&token, ^{
        _sources = [NSMutableDictionary dictionary];
    });
    return _sources;
}

+ (void)throttleWithInterval:(NSTimeInterval)interval handler:(HDFunctionThrottleHandler __nullable)handler {
    [self throttleWithInterval:interval type:HDFunctionThrottleTypeDelayAndInvokeLast key:nil handler:handler];
}

+ (void)throttleWithInterval:(NSTimeInterval)interval type:(HDFunctionThrottleType)type handler:(HDFunctionThrottleHandler __nullable)handler {
    [self throttleWithInterval:interval type:type key:nil handler:handler];
}

+ (void)throttleWithInterval:(NSTimeInterval)interval key:(NSString *__nullable)key handler:(HDFunctionThrottleHandler __nullable)handler {
    [self throttleWithInterval:interval type:HDFunctionThrottleTypeDelayAndInvokeLast key:key handler:handler];
}

+ (void)throttleWithInterval:(NSTimeInterval)interval type:(HDFunctionThrottleType)type key:(NSString *__nullable)key handler:(HDFunctionThrottleHandler __nullable)handler {
    [self throttleWithInterval:interval type:HDFunctionThrottleTypeDelayAndInvokeLast key:key queue:nil handler:handler];
}

+ (void)throttleWithInterval:(NSTimeInterval)interval type:(HDFunctionThrottleType)type queue:(dispatch_queue_t)queue handler:(HDFunctionThrottleHandler __nullable)handler {
    [self throttleWithInterval:interval type:type key:nil queue:queue handler:handler];
}

+ (void)throttleWithInterval:(NSTimeInterval)interval key:(NSString *__nullable)key queue:(dispatch_queue_t)queue handler:(HDFunctionThrottleHandler __nullable)handler {
    [self throttleWithInterval:interval type:HDFunctionThrottleTypeDelayAndInvokeLast key:key queue:queue handler:handler];
}

+ (void)throttleWithInterval:(NSTimeInterval)interval type:(HDFunctionThrottleType)type key:(NSString *__nullable)key queue:(dispatch_queue_t)queue handler:(HDFunctionThrottleHandler __nullable)handler {
    queue = queue ?: dispatch_get_main_queue();
    key = key ?: [NSThread callStackSymbols][1];

    NSMutableDictionary *scheduledSources = self.scheduledSources;

    dispatch_source_t timer = scheduledSources[key];

    if (type == HDFunctionThrottleTypeDelayAndInvokeLast) {
        if (timer) {
            dispatch_source_cancel(timer);
        }

        timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, queue);
        dispatch_source_set_timer(timer, dispatch_time(DISPATCH_TIME_NOW, interval * NSEC_PER_SEC), DISPATCH_TIME_FOREVER, 0);
        dispatch_source_set_event_handler(timer, ^{
            !handler ?: handler();
            dispatch_source_cancel(timer);
            [scheduledSources removeObjectForKey:key];
        });
        dispatch_resume(timer);

        scheduledSources[key] = timer;
    } else if (type == HDFunctionThrottleTypeInvokeOnceInEachInterval) {
        if (timer) {
            // 触发最后一次调用
            if (_checkLastTTimeCallTimer) {
                dispatch_source_cancel(_checkLastTTimeCallTimer);
            }

            _checkLastTTimeCallTimer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, dispatch_get_main_queue());
            dispatch_source_set_timer(_checkLastTTimeCallTimer, dispatch_time(DISPATCH_TIME_NOW, interval * NSEC_PER_SEC), DISPATCH_TIME_FOREVER, 0);
            dispatch_source_set_event_handler(_checkLastTTimeCallTimer, ^{
                !handler ?: handler();
                dispatch_source_cancel(_checkLastTTimeCallTimer);
            });
            dispatch_resume(_checkLastTTimeCallTimer);
            return;
        }

        !handler ?: handler();
        timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, queue);
        dispatch_source_set_timer(timer, dispatch_time(DISPATCH_TIME_NOW, interval * NSEC_PER_SEC), DISPATCH_TIME_FOREVER, 0);
        dispatch_source_set_event_handler(timer, ^{
            dispatch_source_cancel(timer);
            [scheduledSources removeObjectForKey:key];
        });
        dispatch_resume(timer);

        scheduledSources[key] = timer;
    }
}

+ (void)throttleCancelWithKey:(NSString *__nullable)key {
    key = key ?: [NSThread callStackSymbols][1];

    // HDFunctionThrottleTypeDelayAndInvokeLast
    dispatch_source_t timer = HDFunctionThrottle.scheduledSources[key];
    if (timer) {
        dispatch_source_cancel(timer);
    }
    [HDFunctionThrottle.scheduledSources removeObjectForKey:key];

    // HDFunctionThrottleTypeInvokeOnceInEachInterval
    if (_checkLastTTimeCallTimer) {
        dispatch_source_cancel(_checkLastTTimeCallTimer);
    }
}
@end
