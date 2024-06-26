//
//  UIInterface+HD.h
//  HDKitCore
//
//  Created by VanJay on 2019/12/30.
//  Copyright © 2019 chaos network technology. All rights reserved.
//

#import "HDHelper.h"
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface HDHelper (Interface)

/**
 *  旋转当前设备的方向到指定方向，一般用于 [UIViewController supportedInterfaceOrientations] 发生变化时主动触发界面方向的刷新
 *  @return 是否真正旋转了方向，YES 表示参数的方向和目前设备方向不一致，NO 表示一致也即不会旋转
 *  @see [HDConfiguration automaticallyRotateDeviceOrientation]
 */
+ (BOOL)rotateToDeviceOrientation:(UIDeviceOrientation)orientation;

/**
 *  记录手动旋转方向前的设备方向，当值不为 UIDeviceOrientationUnknown 时表示设备方向有经过了手动调整。默认值为 UIDeviceOrientationUnknown。
 *  @see [HDHelper rotateToDeviceOrientation]
 */
@property (nonatomic, assign) UIDeviceOrientation orientationBeforeChangingByHelper;

/// 将一个 UIInterfaceOrientationMask 转换成对应的 UIDeviceOrientation
+ (UIDeviceOrientation)deviceOrientationWithInterfaceOrientationMask:(UIInterfaceOrientationMask)mask;

/// 判断一个 UIInterfaceOrientationMask 是否包含某个给定的 UIDeviceOrientation 方向
+ (BOOL)interfaceOrientationMask:(UIInterfaceOrientationMask)mask containsDeviceOrientation:(UIDeviceOrientation)deviceOrientation;

/// 判断一个 UIInterfaceOrientationMask 是否包含某个给定的 UIInterfaceOrientation 方向
+ (BOOL)interfaceOrientationMask:(UIInterfaceOrientationMask)mask containsInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation;

/// 根据指定的旋转方向计算出对应的旋转角度
+ (CGFloat)angleForTransformWithInterfaceOrientation:(UIInterfaceOrientation)orientation;

/// 根据当前设备的旋转方向计算出对应的CGAffineTransform
+ (CGAffineTransform)transformForCurrentInterfaceOrientation;

/// 根据指定的旋转方向计算出对应的CGAffineTransform
+ (CGAffineTransform)transformWithInterfaceOrientation:(UIInterfaceOrientation)orientation;

/// 给 HDHelper instance 通知用
- (void)handleDeviceOrientationNotification:(NSNotification *)notification;

@end

NS_ASSUME_NONNULL_END
