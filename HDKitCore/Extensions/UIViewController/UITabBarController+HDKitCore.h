//
//  UITabBarController+HDKitCore.h
//  HDKitCore
//
//  Created by VanJay on 2019/8/20.
//  Copyright © 2019 chaos network technology. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void (^TabBarVCDidAppearSelectIndexHandler)(void);

NS_ASSUME_NONNULL_BEGIN

@interface UITabBarController (HDKitCore)

/**
 增加水平滑动过渡动画

 @param willSelectIndex 将要选择的位置
 @param duration 动画时长
 */
- (void)addTransitionAnimationForWillSelectIndex:(NSInteger)willSelectIndex duration:(NSTimeInterval)duration;

///< UITabBarController 已经显示回调
- (void)setTabBarVCDidAppearSelectIndexHandler:(TabBarVCDidAppearSelectIndexHandler __nullable)didAppearSelectIndexHandler;

///< UITabBarController 已经显示并选择指定索引回调
- (void)setTabBarVCDidAppearSelectIndexHandler:(TabBarVCDidAppearSelectIndexHandler __nullable)didAppearSelectIndexHandler willSelectindex:(NSUInteger)willSelectindex;

/// 执行已经显示并选择指定索引的回调
- (void)performDidAppearSelectIndexHandler;
@end

NS_ASSUME_NONNULL_END
