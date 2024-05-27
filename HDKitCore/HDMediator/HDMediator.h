//
//  HDMediator.h
//  HDMediator
//
//  Created by casa on 16/3/13.
//  Copyright © 2016年 casa. All rights reserved.
//

#import <UIKit/UIKit.h>

extern NSString *_Nonnull const kHDMediatorParamsKeySwiftTargetModuleName;
extern NSString *_Nonnull const kHDMediatorTargetPrefix;
extern NSString *_Nonnull const kHDMediatorActionPrefix;

typedef NS_ENUM(NSUInteger, HDMediatorNoTargetActionResponseType) {
    HDMediatorNoTargetActionResponseTypeNoTarget = 0,      ///< 无 target
    HDMediatorNoTargetActionResponseTypeNoAction,          ///< 无 action
    HDMediatorNoTargetActionResponseTypeURLInValidScheme,  ///< URL scheme 不合法
};

#ifndef _Target
#define _Target(name) Target_##name
#endif

#ifndef _Action
#define _Action(name) action_##name
#endif

NS_ASSUME_NONNULL_BEGIN

/// 没有 target 响应
typedef void (^HDMediatorNoTargetHandler)(NSString *target, NSString *action, NSDictionary *params);
/// target 没有 action 响应
typedef void (^HDMediatorNoActionHandler)(NSString *target, NSString *action, NSDictionary *params);

/// 在跳转前回调
typedef void (^HDMediatorWillPerformHandler)(NSString *routePath, NSString *target, NSString *action, NSDictionary *params);

/// http、https 协议
typedef void (^HDMediatorHTTPSchemeHandler)(NSURL *url);

@interface HDMediator : NSObject

+ (instancetype _Nonnull)sharedInstance;

/// Scheme
@property (nonatomic, copy) NSString *scheme;

/// 没有 target 响应
@property (nonatomic, copy) HDMediatorNoTargetHandler noTargetHandler;

/// target 没有 action 响应
@property (nonatomic, copy) HDMediatorNoActionHandler noActionHandler;

/// http、https 协议处理回调
@property (nonatomic, copy) HDMediatorHTTPSchemeHandler httpSchemeHandler;

///< 跳转前回调
@property (nonatomic, copy) HDMediatorWillPerformHandler willPerformHandler;

/// 以 URL 的形式调用
/// @param urlStr url 全路径，格式：scheme://[target]/[action]?[params]，如：chaos://targetA/actionB?id=1234
- (id _Nullable)performActionWithURL:(NSString *_Nullable)urlStr;

/// 以 URL 的形式调用
/// @param urlStr url 全路径，格式：scheme://[target]/[action]?[params]，如：chaos://targetA/actionB?id=1234
/// @param params 更多的参数，会与 url 的参数合并，优先级高于 url 内的参数
- (id _Nullable)performActionWithURL:(NSString *_Nullable)urlStr params:(NSDictionary *_Nullable)params;

/// 以 target-action形式调用
/// @param targetName target 名称（不包含前缀）
/// @param actionName action 名称（不包含前缀）
- (id _Nullable)performTarget:(NSString *_Nullable)targetName action:(NSString *_Nullable)actionName;

/// 以 target-action形式调用
/// @param targetName target 名称（不包含前缀）
/// @param actionName action 名称（不包含前缀）
/// @param shouldCacheTarget 是否要缓存 target class 名称
- (id _Nullable)performTarget:(NSString *_Nullable)targetName action:(NSString *_Nullable)actionName shouldCacheTarget:(BOOL)shouldCacheTarget;

/// 以 target-action形式调用
/// @param targetName target 名称（不包含前缀）
/// @param actionName action 名称（不包含前缀）
/// @param params 参数
- (id _Nullable)performTarget:(NSString *_Nullable)targetName action:(NSString *_Nullable)actionName params:(NSDictionary *_Nullable)params;

/// 以 target-action形式调用
/// @param targetName target 名称（不包含前缀）
/// @param actionName action 名称（不包含前缀）
/// @param params 参数
/// @param shouldCacheTarget 是否要缓存 target class
- (id _Nullable)performTarget:(NSString *_Nullable)targetName action:(NSString *_Nullable)actionName params:(NSDictionary *_Nullable)params shouldCacheTarget:(BOOL)shouldCacheTarget;

/// 移除某 target class 的缓存
/// @param targetName target class 名称
- (void)releaseCachedTargetWithTargetName:(NSString *_Nullable)targetName;

@end

@interface HDMediator (Helper)

/// 校验是否可以打开 URL
/// @param urlStr url 全路径
- (BOOL)canPerformActionWithURL:(NSString *)urlStr;
@end

NS_ASSUME_NONNULL_END
