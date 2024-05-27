//
//  HDAlertQueueManager.h
//  HDUIKit
//
//  Created by Chaos on 2021/6/22.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, HDAlertQueuePriority) {
    HDAlertQueuePriorityLow = 1,           // 低
    HDAlertQueuePriorityNormal = 500,      // 中
    HDAlertQueuePriorityHigh = 1000,       // 高
    HDAlertQueuePriorityImmediate = 2000,  // 立即展示（如果有此级别加入，则关闭当前展示的（除非当前展示的也是该级别的），展示此弹窗）
};

@protocol HDAlertQueueObject <NSObject>

@required
/// 弹窗的唯一标识，队列中同一标识只允许存在一个，防止重复弹窗
- (NSString *_Nonnull)hd_alertIdentify;

@optional
/// 优先级
- (HDAlertQueuePriority)hd_alertQueuePriority;
/// 实际展示回调
- (void)hd_alertQueueShow;
/// 内部主动关闭回调（如队列中加入了一个需要立马展示的弹窗，则内部主动关闭当前弹窗，除非当前展示的也是该级别的）
- (void)hd_alertQueueDismiss;
/// 弹窗只在该控制器中展示，为空时表示不限制
- (nullable Class)hd_alertQueueShowInController;

@end

@interface HDAlertQueueManager : NSObject

/// 代理方式
/// 监听observer对象，当对象释放时，则认为该弹窗关闭，取队列中下一个弹窗展示
+ (void)show:(NSObject<HDAlertQueueObject> *)observer;

/// block方式
/// @param observer 需要监听的对象，当对象释放时，则认为该弹窗关闭，取队列中下一个弹窗展示
/// @param priority 优先级
/// @param showInController 弹窗只在该控制器中展示，为空时表示不限制
/// @param showBlock 实际展示回调
/// @param dismissBlock 内部主动关闭回调（如队列中加入了一个需要立马展示的弹窗，则内部主动关闭当前弹窗，除非当前展示的也是该级别的）
/// 注：如showBlock，dismissBlock内部引用了observer或showInController，都需使用__weak修饰
+ (void)showWithObserver:(NSObject *)observer
                priority:(HDAlertQueuePriority)priority
        showInController:(nullable Class)showInController
               showBlock:(void (^)(void))showBlock
            dismissBlock:(void (^)(void))dismissBlock;

/// 如果弹窗关闭时不会销毁弹窗对象，则需主动调用该方法
/// @param observer 弹窗对象
+ (void)dismiss:(id)observer;

@end

NS_ASSUME_NONNULL_END
