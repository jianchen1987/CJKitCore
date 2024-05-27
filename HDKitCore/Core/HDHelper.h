//
//  HDHelper.h
//  HDKitCore
//
//  Created by VanJay on 2019/9/5.
//  Copyright © 2019 chaos network technology. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface HDHelper : NSObject
+ (instancetype _Nonnull)sharedInstance;
@end

@interface HDHelper (AudioSession)

/**
 *  听筒和扬声器的切换
 *
 *  @param speaker   是否转为扬声器，NO则听筒
 *  @param temporary 决定使用kAudioSessionProperty_OverrideAudioRoute还是kAudioSessionProperty_OverrideCategoryDefaultToSpeaker，两者的区别请查看本组的博客文章:http://km.oa.com/group/gyui/articles/show/235957
 */
+ (void)redirectAudioRouteWithSpeaker:(BOOL)speaker temporary:(BOOL)temporary;

/**
 *  设置category
 *
 *  @param category 使用iOS7的category，iOS6的会自动适配
 */
+ (void)setAudioSessionCategory:(nullable NSString *)category;
@end

@interface HDHelper (UIGraphic)

/// 获取一像素的大小
+ (CGFloat)pixelOne;

/// 判断size是否超出范围
+ (void)inspectContextSize:(CGSize)size;

/// context是否合法
+ (void)inspectContextIfInvalidatedInDebugMode:(CGContextRef _Nonnull)context;
+ (BOOL)inspectContextIfInvalidatedInReleaseMode:(CGContextRef _Nonnull)context;
@end

@interface HDHelper (Device)

+ (nonnull NSString *)deviceModel;

+ (BOOL)isIPad;
+ (BOOL)isIPod;
+ (BOOL)isIPhone;
+ (BOOL)isSimulator;

/// 带物理凹槽的刘海屏或者使用 Home Indicator 类型的设备
+ (BOOL)isNotchedScreen;

/// 将屏幕分为普通和紧凑两种，这个方法用于判断普通屏幕
+ (BOOL)isRegularScreen;

/// iPhone XS Max
+ (BOOL)is65InchScreen;

/// iPhone XR
+ (BOOL)is61InchScreen;

/// iPhone X/XS
+ (BOOL)is58InchScreen;

/// iPhone 8 Plus
+ (BOOL)is55InchScreen;

/// iPhone 8
+ (BOOL)is47InchScreen;

/// iPhone 5
+ (BOOL)is40InchScreen;

/// iPhone 4
+ (BOOL)is35InchScreen;

+ (CGSize)screenSizeFor65Inch;
+ (CGSize)screenSizeFor61Inch;
+ (CGSize)screenSizeFor58Inch;
+ (CGSize)screenSizeFor55Inch;
+ (CGSize)screenSizeFor47Inch;
+ (CGSize)screenSizeFor40Inch;
+ (CGSize)screenSizeFor35Inch;

+ (CGFloat)preferredLayoutAsSimilarScreenWidthForIPad;

// 用于获取 isNotchedScreen 设备的 insets，注意对于 iPad Pro 11-inch 这种无刘海凹槽但却有使用 Home Indicator 的设备，它的 top 返回0，bottom 返回 safeAreaInsets.bottom 的值
+ (UIEdgeInsets)safeAreaInsetsForDeviceWithNotch;

/// 判断当前设备是否高性能设备，只会判断一次，以后都直接读取结果，所以没有性能问题
+ (BOOL)isHighPerformanceDevice;

/// 系统设置里是否开启了“放大显示-试图-放大”，支持放大模式的 iPhone 设备可在官方文档中查询 https://support.apple.com/zh-cn/guide/iphone/iphd6804774e/ios
+ (BOOL)isZoomedMode;

/**
 在 iPad 分屏模式下可获得实际运行区域的窗口大小，如需适配 iPad 分屏，建议用这个方法来代替 [UIScreen mainScreen].bounds.size
 @return 应用运行的窗口大小
 */
+ (CGSize)applicationSize;

// 判断是否是刘海屏
+ (BOOL)hd_navigationBarIsNotchedScreen;

/// 顶部安全区高度
+ (CGFloat)hd_safeDistanceTop;

/// 底部安全区高度
+ (CGFloat)hd_safeDistanceBottom;

/// 顶部状态栏高度（包括安全区）
+ (CGFloat)hd_statusBarHeight;

/// 导航栏高度
+ (CGFloat)hd_navigationBarHeight;

/// 状态栏+导航栏的高度
+ (CGFloat)hd_navigationFullHeight;

/// 底部导航栏高度
+ (CGFloat)hd_tabBarHeight;

/// 底部导航栏高度（包括安全区）
+ (CGFloat)hd_tabBarFullHeight;

@end

@interface HDHelper (SystemVersion)
+ (NSInteger)numbericOSVersion;
+ (NSComparisonResult)compareSystemVersion:(nonnull NSString *)currentVersion toVersion:(nonnull NSString *)targetVersion;
+ (BOOL)isCurrentSystemAtLeastVersion:(nonnull NSString *)targetVersion;
+ (BOOL)isCurrentSystemLowerThanVersion:(nonnull NSString *)targetVersion;
@end

@interface HDHelper (Image)

/// 合成一张带 logo 的占位图，默认 logo 居中，有特殊场景可增加绘制 logo 起点参数
/// @param bgColor 背景色
/// @param radius 背景圆角，默认 5
/// @param size 背景大小
/// @param logoImage logo 图，为空将使用默认的白色 HDKitCore logo
/// @param logoSize logo 大小，如果为空有默认大小
/// @param logo2CointainerWidthRate logo 宽度相对于容器宽度的比例，默认 0.4
+ (UIImage *)placeholderImageWithBgColor:(UIColor *__nullable)bgColor cornerRadius:(CGFloat)radius size:(CGSize)size logoImage:(UIImage *__nullable)logoImage logoSize:(CGSize)logoSize logo2CointainerWidthRate:(CGFloat)logo2CointainerWidthRate;
+ (UIImage *)placeholderImageWithBgColor:(UIColor *__nullable)bgColor cornerRadius:(CGFloat)radius size:(CGSize)size logoImage:(UIImage *__nullable)logoImage logoSize:(CGSize)logoSize;
+ (UIImage *)placeholderImageWithBgColor:(UIColor *__nullable)bgColor cornerRadius:(CGFloat)radius size:(CGSize)size;
+ (UIImage *)placeholderImageWithCornerRadius:(CGFloat)radius size:(CGSize)size logoWidth:(CGFloat)logoWidth;
+ (UIImage *)placeholderImageWithCornerRadius:(CGFloat)radius size:(CGSize)size logoSize:(CGSize)logoSize;
+ (UIImage *)placeholderImageWithSize:(CGSize)size logoWidth:(CGFloat)logoWidth;
+ (UIImage *)placeholderImageWithCornerRadius:(CGFloat)radius size:(CGSize)size;
+ (UIImage *)placeholderImageWithSize:(CGSize)size;
+ (UIImage *)circlePlaceholderImage;
+ (UIImage *)placeholderImage;
@end

@interface HDHelper (Font)
+ (__kindof NSString *)narrowestFontName;
@end

@interface HDHelper (Animation)

/**
 在 animationBlock 里的操作完成之后会调用 completionBlock，常用于一些不提供 completionBlock 的系统动画操作，例如 [UINavigationController pushViewController:animated:YES] 的场景，注意 UIScrollView 系列的滚动无法使用这个方法。

 @param animationBlock 要进行的带动画的操作
 @param completionBlock 操作完成后的回调
 */
+ (void)executeAnimationBlock:(nonnull __attribute__((noescape)) void (^)(void))animationBlock completionBlock:(nullable __attribute__((noescape)) void (^)(void))completionBlock;

@end

@interface HDHelper (Keyboard)

/**
 * 判断当前 App 里的键盘是否升起，默认为 NO
 * Returns the visibility of the keybord. Default value is NO.
 */
+ (BOOL)isKeyboardVisible;

/**
 * 记录上一次键盘显示时的高度（基于整个 App 所在的 window 的坐标系），注意使用前用 `isKeyboardVisible` 判断键盘是否显示，因为即便是键盘被隐藏的情况下，调用 `lastKeyboardHeightInApplicationWindowWhenVisible` 也会得到高度值。
 */
+ (CGFloat)lastKeyboardHeightInApplicationWindowWhenVisible;

/**
 * 获取当前键盘frame相关
 * @warning 注意iOS8以下的系统在横屏时得到的rect，宽度和高度相反了，所以不建议直接通过这个方法获取高度，而是使用<code>keyboardHeightWithNotification:inView:</code>，因为在后者的实现里会将键盘的rect转换坐标系，转换过程就会处理横竖屏旋转问题。
 */
+ (CGRect)keyboardRectWithNotification:(nullable NSNotification *)notification;

/// 获取当前键盘的高度，注意高度可能为0（例如第三方键盘会发出两次notification，其中第一次的高度就为0）
+ (CGFloat)keyboardHeightWithNotification:(nullable NSNotification *)notification;

/**
 * 获取当前键盘在屏幕上的可见高度，注意外接键盘（iPad那种）时，[HDIHelper keyboardRectWithNotification]得到的键盘rect里有一部分是超出屏幕，不可见的，如果直接拿rect的高度来计算就会与意图相悖。
 * @param notification 接收到的键盘事件的UINotification对象
 * @param view 要得到的键盘高度是相对于哪个View的键盘高度，若为nil，则等同于调用[HDIHelper keyboardHeightWithNotification:]
 * @warning 如果view.window为空（当前View尚不可见），则会使用App默认的UIWindow来做坐标转换，可能会导致一些计算错误
 * @return 键盘在view里的可视高度
 */
+ (CGFloat)keyboardHeightWithNotification:(nullable NSNotification *)notification inView:(nullable UIView *)view;

/// 获取键盘显示/隐藏的动画时长，注意返回值可能为0
+ (NSTimeInterval)keyboardAnimationDurationWithNotification:(nullable NSNotification *)notification;

/// 获取键盘显示/隐藏的动画时间函数
+ (UIViewAnimationCurve)keyboardAnimationCurveWithNotification:(nullable NSNotification *)notification;

/// 获取键盘显示/隐藏的动画时间函数
+ (UIViewAnimationOptions)keyboardAnimationOptionsWithNotification:(nullable NSNotification *)notification;
@end


NS_ASSUME_NONNULL_END
