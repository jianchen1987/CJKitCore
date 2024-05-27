//
//  HDAlertQueueManager.m
//  HDUIKit
//
//  Created by Chaos on 2021/6/22.
//

#import "HDAlertQueueManager.h"
#import "HDDispatchMainQueueSafe.h"
#import "HDRunTime.h"
#import "NSArray+HDKitCore.h"
#import "NSObject+HDKitCore.h"
#import "UIViewController+HDKitCore.h"

#pragma mark - HDAlertQueueCacheObject
@interface HDAlertQueueAlertObject : NSObject

/// 优先级
@property (nonatomic, assign) HDAlertQueuePriority priority;
/// show回调
@property (nonatomic, copy) void (^showBlock)(void);
/// dismiss回调
@property (nonatomic, copy) void (^dismissBlock)(void);
/// observer释放回调
@property (nonatomic, copy) void (^observerDeallocBlock)(void);
/// 绑定的弹窗对象
@property (nonatomic, weak) id observer;
/// 在该控制器内显示
@property (nonatomic, strong) Class showInController;
/// 是否正在展示
@property (nonatomic, assign) BOOL isShowing;
///< 唯一标识
@property (nonatomic, copy) NSString *identify;

@end

@implementation HDAlertQueueAlertObject

- (BOOL)isEqual:(HDAlertQueueAlertObject *)object {
    return self.observer == object.observer;
}

@end

#pragma mark - HDAlertQueueManager
// 弹窗对象展示前通过该数组强引用observer，防止其释放，展示后从数组中删除，生命周期交由外部管理
static NSMutableArray *__strongObservers = nil;
static NSMutableArray<HDAlertQueueAlertObject *> *__alertQueueCache = nil;
@implementation HDAlertQueueManager

#pragma mark - public methods
+ (void)show:(NSObject<HDAlertQueueObject> *)observer {

    NSString *identify = [observer hd_alertIdentify];
    NSArray<id<HDAlertQueueObject>> *bingo = [[self alertQueue] hd_filterWithBlock:^BOOL(HDAlertQueueAlertObject *_Nonnull item) {
        return [item.identify isEqualToString:identify];
    }];
    if (bingo.count) {
        // 已经存在, 不用添加
        return;
    }

    HDAlertQueueAlertObject *object = HDAlertQueueAlertObject.new;
    object.observer = observer;
    __weak __typeof(observer) weakObserver = observer;
    if ([observer respondsToSelector:@selector(hd_alertQueuePriority)]) {
        object.priority = [observer hd_alertQueuePriority];
    }
    if ([observer respondsToSelector:@selector(hd_alertQueueShow)]) {
        object.showBlock = ^{
            [weakObserver hd_alertQueueShow];
        };
    }
    if ([observer respondsToSelector:@selector(hd_alertQueueDismiss)]) {
        object.dismissBlock = ^{
            [weakObserver hd_alertQueueDismiss];
        };
    }
    if ([observer respondsToSelector:@selector(hd_alertQueueShowInController)]) {
        object.showInController = [observer hd_alertQueueShowInController];
    }
    observer.hd_objectDeallocBlock = ^{
        [self dismiss:weakObserver];
    };
    object.identify = [observer hd_alertIdentify];
    [[self strongObservers] addObject:observer];
    [self showWithCacheObject:object];
}

+ (void)showWithObserver:(NSObject *)observer priority:(HDAlertQueuePriority)priority showInController:(Class)showInController showBlock:(void (^)(void))showBlock dismissBlock:(void (^)(void))dismissBlock {
    HDAlertQueueAlertObject *object = HDAlertQueueAlertObject.new;
    object.observer = observer;
    object.priority = priority;
    object.showInController = showInController;
    object.showBlock = showBlock;
    object.dismissBlock = dismissBlock;
    __weak __typeof(observer) weakObserver = observer;
    observer.hd_objectDeallocBlock = ^{
        [self dismiss:weakObserver];
    };
    [[self strongObservers] addObject:observer];
    [self showWithCacheObject:object];
}

+ (void)dismiss:(id)observer {
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        // 删除队列中observer为空或与入参observer相等的
        NSMutableArray<HDAlertQueueAlertObject *> *alertQueue = [self alertQueue];
        [alertQueue enumerateObjectsWithOptions:NSEnumerationReverse
                                     usingBlock:^(HDAlertQueueAlertObject *_Nonnull obj, NSUInteger idx, BOOL *_Nonnull stop) {
                                         if (!obj.observer || obj.observer == observer) {
                                             [alertQueue removeObject:obj];
                                         }
                                     }];
        // 取当前最高优先级展示
        __block HDAlertQueueAlertObject *showingObject = nil;
        [alertQueue enumerateObjectsUsingBlock:^(HDAlertQueueAlertObject *_Nonnull obj, NSUInteger idx, BOOL *_Nonnull stop) {
            // 如果有正在展示中的，直接结束
            if (obj.isShowing) {
                showingObject = nil;
                *stop = true;
                return;
            }
            if ([self canShowAlertInVisibleViewController:obj] && obj.priority > showingObject.priority) {
                showingObject = obj;
            }
        }];
        if (showingObject) {
            [self showAlert:showingObject];
        }
    });
}

#pragma mark - private methods
+ (void)showWithCacheObject:(HDAlertQueueAlertObject *)object {
    BOOL canShow = [self canShowAlertInVisibleViewController:object];

    NSMutableArray<HDAlertQueueAlertObject *> *alertQueue = [self alertQueue];
    if (![alertQueue containsObject:object]) {
        [alertQueue addObject:object];
    }
    if (alertQueue.count == 0) {
        return;
    }
    if (alertQueue.count == 1 && canShow) {
        [self showAlert:object];
        return;
    }
    // 是否有正在展示中的
    __block HDAlertQueueAlertObject *showingObject = nil;
    [alertQueue enumerateObjectsUsingBlock:^(HDAlertQueueAlertObject *_Nonnull obj, NSUInteger idx, BOOL *_Nonnull stop) {
        if (obj.isShowing) {
            showingObject = obj;
            *stop = true;
        }
    }];
    // 有正在展示中的，判断本次加入的弹窗优先级是否为立即展示，并且高于当前展示的优先级，则关闭当前展示的，展示本次加入的
    if (showingObject && object.priority == HDAlertQueuePriorityImmediate && object.priority > showingObject.priority && canShow) {
        [self dismissAlert:showingObject];
        [self showAlert:object];
        return;
    }
    // 有正在展示中的
    if (showingObject) {
        return;
    }
    // 没有正在展示中的,取当前最高优先级展示
    showingObject = nil;
    [alertQueue enumerateObjectsUsingBlock:^(HDAlertQueueAlertObject *_Nonnull obj, NSUInteger idx, BOOL *_Nonnull stop) {
        if ([self canShowAlertInVisibleViewController:obj] && obj.priority > showingObject.priority) {
            showingObject = obj;
        }
    }];
    if (showingObject) {
        [self showAlert:showingObject];
    }
}

+ (void)showAlert:(HDAlertQueueAlertObject *)alertObject {
    hd_dispatch_main_async_safe(^{
        alertObject.isShowing = true;
        !alertObject.showBlock ?: alertObject.showBlock();
        [[self strongObservers] removeObject:alertObject.observer];
    });
}

+ (void)dismissAlert:(HDAlertQueueAlertObject *)alertObject {
    hd_dispatch_main_async_safe(^{
        alertObject.isShowing = false;
        !alertObject.dismissBlock ?: alertObject.dismissBlock();
        [[self alertQueue] removeObject:alertObject];
        [[self strongObservers] removeObject:alertObject.observer];
    });
}

/// 该弹窗是否可展示在当前可见的控制器中
/// @param object 弹窗对象
+ (BOOL)canShowAlertInVisibleViewController:(HDAlertQueueAlertObject *)object {
    __block UIViewController *visibleViewController = nil;
    __block UITabBarController *tabbarController = nil;
    if ([NSThread isMainThread]) {
        visibleViewController = [HDHelper visibleViewController];
        tabbarController = visibleViewController.tabBarController;
    } else {
        dispatch_semaphore_t signal = dispatch_semaphore_create(0);
        hd_dispatch_main_async_safe(^{
            visibleViewController = [HDHelper visibleViewController];
            tabbarController = visibleViewController.tabBarController;
            dispatch_semaphore_signal(signal);
        });
        dispatch_semaphore_wait(signal, DISPATCH_TIME_FOREVER);
    }
    // 不限制展示控制器 或者 当前可见控制器就是展示控制器 或者 当前可见控制器的tabBarController就是展示控制器
    return !object.showInController || [visibleViewController isMemberOfClass:object.showInController] || [tabbarController isMemberOfClass:object.showInController];
}

+ (void)needShowAlertWhenDidAppear {
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        NSMutableArray<HDAlertQueueAlertObject *> *alertQueue = [self alertQueue];
        if (alertQueue.count == 0) {
            return;
        }
        // 取当前最高优先级展示
        __block HDAlertQueueAlertObject *showingObject = nil;
        [alertQueue enumerateObjectsUsingBlock:^(HDAlertQueueAlertObject *_Nonnull obj, NSUInteger idx, BOOL *_Nonnull stop) {
            // 如果有正在展示中的，直接结束
            if (obj.isShowing) {
                showingObject = nil;
                *stop = true;
                return;
            }
            if ([self canShowAlertInVisibleViewController:obj] && obj.priority > showingObject.priority) {
                showingObject = obj;
            }
        }];
        if (showingObject) {
            [self showAlert:showingObject];
        }
    });
}

+ (NSMutableArray<HDAlertQueueAlertObject *> *)alertQueue {
    if (!__alertQueueCache) {
        __alertQueueCache = [NSMutableArray array];
    }
    return __alertQueueCache;
}

+ (NSMutableArray *)strongObservers {
    if (!__strongObservers) {
        __strongObservers = [NSMutableArray array];
    }
    return __strongObservers;
}

@end

#pragma mark - UIViewController (HDAlertQueue)
@interface UIViewController (HDAlertQueue)
@end

@implementation UIViewController (HDAlertQueue)

+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        ExtendImplementationOfVoidMethodWithSingleArgument([UIViewController class], @selector(viewDidAppear:), BOOL, ^(UIViewController *selfObject, BOOL animated) {
            [HDAlertQueueManager needShowAlertWhenDidAppear];
        });
    });
}

@end
