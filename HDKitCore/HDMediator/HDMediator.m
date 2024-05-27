//
//  HDMediator.m
//  HDMediator
//
//  Created by casa on 16/3/13.
//  Copyright © 2016年 casa. All rights reserved.
//

#import "HDMediator.h"
#import <objc/runtime.h>

NSString *const kHDMediatorParamsKeySwiftTargetModuleName = @"kHDMediatorParamsKeySwiftTargetModuleName";

NSString *_Nonnull const kHDMediatorTargetPrefix = @"Target_";
NSString *_Nonnull const kHDMediatorActionPrefix = @"action_";

@interface HDMediator ()
@property (nonatomic, strong) NSMutableDictionary *cachedTarget;
@end

@interface NSString (HDMediator)
- (NSString *)hdm_URLEncodedString;
- (NSString *)hdm_URLDecodedString;
@end

@implementation HDMediator
#pragma mark - public methods
+ (instancetype)sharedInstance {
    static dispatch_once_t onceToken;
    static HDMediator *instance = nil;
    dispatch_once(&onceToken, ^{
        instance = [[super allocWithZone:NULL] init];
    });
    return instance;
}

+ (id)allocWithZone:(struct _NSZone *)zone {
    return [self sharedInstance];
}

- (id)performActionWithURL:(NSString *)urlStr {
    return [self performActionWithURL:urlStr params:nil];
}

- (id)performActionWithURL:(NSString *)urlStr params:(NSDictionary *_Nullable)params {
    if (!urlStr || ![urlStr isKindOfClass:NSString.class] || urlStr.length <= 0) {
        return nil;
    }

    NSURL *url = [NSURL URLWithString:urlStr.hdm_URLEncodedString];
    NSDictionary *finalParams = [self paramsWithURL:url extraParams:params];
    // 校验协议头
    if (![self isSchemeVaild:url.scheme]) {
        // 处理无 target 响应，回调优先
        if (self.noTargetHandler) {
            self.noTargetHandler(url.host, url.path, finalParams);
        } else {
            [self performNoTargetActionResponseWithTargetString:url.host selectorString:url.path originParams:finalParams type:HDMediatorNoTargetActionResponseTypeURLInValidScheme];
        }
        return nil;
    }

    // http 或 https 协议
    if ([self isSchemeHTTP:url.scheme]) {
        if (self.httpSchemeHandler) {
            self.httpSchemeHandler(url);
            return nil;
        } else {
            return [self performTarget:@"HTTP" action:@"openURL" params:@{@"url": url}];
        }
    }

    NSString *actionName = [url.path stringByReplacingOccurrencesOfString:@"/" withString:@""];

    // 取对应的 target 名字和 method 名字,如果需要拓展，在这个方法调用之前加入完整的路由逻辑
    id result = [self performTarget:url.host action:actionName params:finalParams shouldCacheTarget:NO];
    return result;
}

- (id _Nullable)performTarget:(NSString *_Nullable)targetName action:(NSString *_Nullable)actionName {
    return [self performTarget:targetName action:actionName shouldCacheTarget:false];
}

- (id _Nullable)performTarget:(NSString *_Nullable)targetName action:(NSString *_Nullable)actionName shouldCacheTarget:(BOOL)shouldCacheTarget {
    return [self performTarget:targetName action:actionName params:nil shouldCacheTarget:shouldCacheTarget];
}

- (id _Nullable)performTarget:(NSString *_Nullable)targetName action:(NSString *_Nullable)actionName params:(NSDictionary *_Nullable)params {
    return [self performTarget:targetName action:actionName params:params shouldCacheTarget:false];
}

- (id)performTarget:(NSString *)targetName action:(NSString *)actionName params:(NSDictionary *)params shouldCacheTarget:(BOOL)shouldCacheTarget {
    if (targetName == nil || actionName == nil) {
        return nil;
    }
    
    /// 开放钩子给外部调用
    if(self.willPerformHandler) {
        if([targetName.lowercaseString isEqualToString:@"http"]) {
            NSURL *url = [params valueForKey:@"url"];
            self.willPerformHandler(url.absoluteString, targetName, actionName, params);
            
        } else {
            self.willPerformHandler([NSString stringWithFormat:@"SuperApp://%@/%@", targetName, actionName], targetName, actionName, params);
            
        }
    }
    

    // generate target
    NSString *targetClassString = [self targetClassStringWithTargetName:targetName params:params];
    NSObject *target = [self targetWithTargetClassString:targetClassString];

    // generate action
    NSString *actionString = [self actionStringWithActionName:actionName];
    SEL action = NSSelectorFromString(actionString);

    if (target == nil) {
        // 处理无 target 响应，回调优先
        if (self.noTargetHandler) {
            self.noTargetHandler(targetClassString, actionString, params);
        } else {
            [self performNoTargetActionResponseWithTargetString:targetClassString selectorString:actionString originParams:params type:HDMediatorNoTargetActionResponseTypeNoTarget];
        }
        return nil;
    }

    if (shouldCacheTarget) {
        self.cachedTarget[targetClassString] = target;
    }

    if ([target respondsToSelector:action]) {
        return [self safePerformAction:action target:target params:params];
    } else {
        // 这里是处理无响应请求的地方，如果无响应，则尝试调用对应target的notFound方法统一处理
        NSString *notFoundStr = [NSString stringWithFormat:@"%@notFound:", kHDMediatorActionPrefix];
        SEL action = NSSelectorFromString(notFoundStr);
        if ([target respondsToSelector:action]) {
            return [self safePerformAction:action target:target params:params];
        } else {
            // 处理无 action 响应，回调优先
            if (self.noActionHandler) {
                self.noActionHandler(targetClassString, actionString, params);
            } else {
                [self performNoTargetActionResponseWithTargetString:targetClassString selectorString:actionString originParams:params type:HDMediatorNoTargetActionResponseTypeNoAction];
            }
            [self.cachedTarget removeObjectForKey:targetClassString];
            return nil;
        }
    }
}

- (void)releaseCachedTargetWithTargetName:(NSString *)targetName {
    if (targetName == nil) {
        return;
    }
    NSString *targetClassString = [NSString stringWithFormat:@"%@%@", kHDMediatorTargetPrefix, targetName];
    [self.cachedTarget removeObjectForKey:targetClassString];
}

#pragma mark - private methods
- (void)performNoTargetActionResponseWithTargetString:(NSString *)targetString selectorString:(NSString *)selectorString originParams:(NSDictionary *)originParams type:(HDMediatorNoTargetActionResponseType)type {
    NSObject *target = [[NSClassFromString([NSString stringWithFormat:@"%@NoTargetAction", kHDMediatorTargetPrefix]) alloc] init];
    SEL action = NSSelectorFromString([NSString stringWithFormat:@"%@response:", kHDMediatorActionPrefix]);

    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    params[@"originParams"] = originParams;
    params[@"targetString"] = targetString;
    params[@"selectorString"] = selectorString;
    params[@"type"] = @(type);

    [self safePerformAction:action target:target params:params];
}

// clang-format off
#define __returnSpecifiedTypeValue(type, expression, getReturnValueExpression, returnValue) \
    if (strcmp(retType, @encode(type)) == 0) {                                              \
        NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:methodSig];  \
        [invocation setArgument:&params atIndex:2];                                         \
        [invocation setSelector:action];                                                    \
        [invocation setTarget:target];                                                      \
        [invocation invoke];                                                                \
        expression;                                                                         \
        getReturnValueExpression;                                                           \
        return returnValue;                                                                 \
    }
// clang-format on

- (id)safePerformAction:(SEL)action target:(NSObject *)target params:(NSDictionary *)params {
    NSMethodSignature *methodSig = [target methodSignatureForSelector:action];
    if (methodSig == nil) {
        return nil;
    }
    const char *retType = [methodSig methodReturnType];

    __returnSpecifiedTypeValue(void, , , nil);
    __returnSpecifiedTypeValue(NSInteger, NSInteger result = 0, [invocation getReturnValue:&result], @(result));
    __returnSpecifiedTypeValue(BOOL, BOOL result = 0, [invocation getReturnValue:&result], @(result));
    __returnSpecifiedTypeValue(CGFloat, CGFloat result = 0, [invocation getReturnValue:&result], @(result));
    __returnSpecifiedTypeValue(NSUInteger, NSUInteger result = 0, [invocation getReturnValue:&result], @(result));

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
    return [target performSelector:action withObject:params];
#pragma clang diagnostic pop
}

- (NSString *)targetClassStringWithTargetName:(NSString *)targetName params:(NSDictionary *)params {
    NSString *swiftModuleName = params[kHDMediatorParamsKeySwiftTargetModuleName];
    NSString *targetClassString = nil;
    if (swiftModuleName.length > 0) {
        targetClassString = [NSString stringWithFormat:@"%@.%@%@", swiftModuleName, kHDMediatorTargetPrefix, targetName];
    } else {
        targetClassString = [NSString stringWithFormat:@"%@%@", kHDMediatorTargetPrefix, targetName];
    }
    return targetClassString;
}

- (NSObject *)targetWithTargetClassString:(NSString *)targetClassString {
    NSObject *target = self.cachedTarget[targetClassString];
    if (target == nil) {
        Class targetClass = NSClassFromString(targetClassString);
        target = [[targetClass alloc] init];
    }
    return target;
}

- (NSString *)actionStringWithActionName:(NSString *)actionName {
    NSString *actionString = [NSString stringWithFormat:@"%@%@:", kHDMediatorActionPrefix, actionName];
    return actionString;
}

- (NSDictionary *)paramsWithURL:(NSURL *)url extraParams:(NSDictionary *)extraParams {
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    NSString *urlString = [url query];
    for (NSString *param in [urlString componentsSeparatedByString:@"&"]) {
        NSArray *elts = [param componentsSeparatedByString:@"="];
        if ([elts count] < 2) continue;
        id value = [elts lastObject];
        if ([value isKindOfClass:NSString.class]) {
            value = [((NSString *)value) hdm_URLDecodedString];
        }
        [params setObject:value forKey:[elts firstObject]];
    }

    NSMutableDictionary *finalParams = [NSMutableDictionary dictionary];
    if (params && params.allKeys.count > 0) {
        [finalParams addEntriesFromDictionary:params];
    }
    // extraParams 优先级更高，覆盖相同 key 的 value
    if (extraParams && extraParams.allKeys.count > 0) {
        [finalParams addEntriesFromDictionary:extraParams];
    }
    return finalParams;
}

- (BOOL)isSchemeVaild:(NSString *)scheme {
    scheme = scheme.lowercaseString;
    return [scheme isEqualToString:self.scheme.lowercaseString] || [self isSchemeHTTP:scheme];
}

- (BOOL)isSchemeHTTP:(NSString *)scheme {
    scheme = scheme.lowercaseString;
    return [scheme isEqualToString:@"http"] || [scheme isEqualToString:@"https"];
}

#pragma mark - getters and setters
- (NSMutableDictionary *)cachedTarget {
    if (_cachedTarget == nil) {
        _cachedTarget = [[NSMutableDictionary alloc] init];
    }
    return _cachedTarget;
}

- (NSString *)scheme {
    if (!_scheme) {
        _scheme = @"SuperApp";
    }
    return _scheme;
}

@end

@implementation HDMediator (Helper)
- (BOOL)canPerformActionWithURL:(NSString *)urlStr {
    NSURL *url = [NSURL URLWithString:[urlStr hdm_URLEncodedString]];
    // 校验协议头
    if (![self isSchemeVaild:url.scheme]) {
        return false;
    }
    if ([self isSchemeHTTP:url.scheme]) {
        return true;
    }
    NSString *actionName = [url.path stringByReplacingOccurrencesOfString:@"/" withString:@""];
    NSDictionary *params = [self paramsWithURL:url extraParams:nil];
    NSObject *target = [self targetWithTargetClassString:[self targetClassStringWithTargetName:url.host params:params]];

    if (![target respondsToSelector:NSSelectorFromString([self actionStringWithActionName:actionName])]) {
        return false;
    }
    return true;
}

@end

@implementation NSString (HDMediator)
- (NSString *)hdm_URLEncodedString {
    NSCharacterSet *encodeUrlSet = [NSCharacterSet URLQueryAllowedCharacterSet];
    NSString *encodeUrl = [self stringByAddingPercentEncodingWithAllowedCharacters:encodeUrlSet];
    return encodeUrl;
}

- (NSString *)hdm_URLDecodedString {
    NSString *decodedString = (__bridge_transfer NSString *)CFURLCreateStringByReplacingPercentEscapes(NULL, (CFStringRef)self, CFSTR(""));
    return decodedString;
}
@end
