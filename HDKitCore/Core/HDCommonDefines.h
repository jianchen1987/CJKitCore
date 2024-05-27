//
//  HDCommonDefines.h
//  HDKitCore
//
//  Created by VanJay on 2020/2/26.
//  Copyright © 2019 chaos network technology. All rights reserved.
//

#ifndef HDCommonDefines_h
#define HDCommonDefines_h

#import "HDHelper.h"
#import "HDHelperFunction.h"
#import "HDLog.h"

#define IS_IPAD [HDHelper isIPad]
#define IS_IPOD [HDHelper isIPod]
#define IS_IPHONE [HDHelper isIPhone]
#define IS_SIMULATOR [HDHelper isSimulator]

#pragma mark - 屏幕

/// 是否放大模式（iPhone 6及以上的设备支持放大模式，iPhone X 除外）
#define isDeviceZoomedMode [HDHelper isZoomedMode]

/// 模拟器
#define isDeviceSimulator [HDHelper isSimulator]

/// 获取一个像素
#ifndef PixelOne
#define PixelOne [HDHelper pixelOne]
#endif

#define isScreen4Inch ([UIScreen instancesRespondToSelector:@selector(currentMode)] ? CGSizeEqualToSize(CGSizeMake(640, 1136), [[UIScreen mainScreen] currentMode].size) : NO)
#define isScreen47Inch ([UIScreen instancesRespondToSelector:@selector(currentMode)] ? CGSizeEqualToSize(CGSizeMake(750, 1334), [[UIScreen mainScreen] currentMode].size) : NO)
#define isScreen55Inch ([UIScreen instancesRespondToSelector:@selector(currentMode)] ? CGSizeEqualToSize(CGSizeMake(1242, 2208), [[UIScreen mainScreen] currentMode].size) : NO)

#ifndef iPhoneXSeries
#define iPhoneXSeries [HDHelper hd_navigationBarIsNotchedScreen]
#endif

/// 屏幕宽度，会根据横竖屏的变化而变化
#define SCREEN_WIDTH ([[UIScreen mainScreen] bounds].size.width)

/// 屏幕高度，会根据横竖屏的变化而变化
#define SCREEN_HEIGHT ([[UIScreen mainScreen] bounds].size.height)

/// 判断当前是否是处于分屏模式的 iPad
#define IS_SPLIT_SCREEN_IPAD (IS_IPAD && APPLICATION_WIDTH != SCREEN_WIDTH)

/// 若 iPad 处于分屏模式下，返回 iPad 接近 iPhone 宽度（320、375、414）中近似的一种，方便屏幕适配。
#define IPAD_SIMILAR_SCREEN_WIDTH [HDHelper preferredLayoutAsSimilarScreenWidthForIPad]

/// 在 iPad 分屏模式下等于 app 实际运行宽度，否则等同于 SCREEN_WIDTH
#define APPLICATION_WIDTH [HDHelper applicationSize].width

/// 在 iPad 分屏模式下等于 app 实际运行宽度，否则等同于 DEVICE_HEIGHT
#define APPLICATION_HEIGHT [HDHelper applicationSize].height

#pragma mark - 用来判断宽度是否和 4、4.7、5.5 屏相等
#define isScreenWidthEqualTo4Inch (kDeviceWidth == 320)
#define isScreenWidthEqualTo47Inch (kDeviceWidth == 375)
#define isScreenWidthEqualTo55Inch (kDeviceWidth == 414)

#define isScreenHeightGraterThan47Inch (kDeviceHeight > 667)
#define isScreenHeightLessThanOrEqualTo47Inch (kDeviceHeight <= 667)
#define isScreenHeightLessThan47Inch (kDeviceHeight < 667)

#define iS_iPad (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
#define iS_iPhone (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)

#define iPhone5 ([UIScreen instancesRespondToSelector:@selector(currentMode)] ? CGSizeEqualToSize(CGSizeMake(640, 1136), [[UIScreen mainScreen] currentMode].size) : NO)

#define AppOrientation [[UIApplication sharedApplication] statusBarOrientation]
#define isPortrait (AppOrientation == UIInterfaceOrientationPortrait || AppOrientation == UIInterfaceOrientationPortraitUpsideDown)
#define isLandscape (AppOrientation == UIInterfaceOrientationLandscapeLeft || AppOrientation == UIInterfaceOrientationLandscapeRight)

// clang-format off
#ifndef HDWeakify
    #if DEBUG
        #if __has_feature(objc_arc)
            #define HDWeakify(obj) autoreleasepool{} __weak __typeof__(obj) obj##Weak = obj;
        #else
            #define HDWeakify(obj) autoreleasepool{} __block __typeof__(obj) obj##Block = obj;
        #endif
    #else
        #if __has_feature(objc_arc)
            #define HDWeakify(obj) try{} @finally{} {} __weak __typeof__(obj) obj##Weak = obj;
        #else
            #define HDWeakify(obj) try{} @finally{} {} __block __typeof__(obj) obj##Block = obj;
        #endif
    #endif
#endif

#ifndef HDStrongify
    #if DEBUG
        #if __has_feature(objc_arc)
            #define HDStrongify(obj) autoreleasepool{} __typeof__(obj) obj = obj##Weak;
        #else
            #define HDStrongify(obj) autoreleasepool{} __typeof__(obj) obj = obj##Block;
        #endif
    #else
        #if __has_feature(objc_arc)
            #define HDStrongify(obj) try{} @finally{} __typeof__(obj) obj = obj##Weak;
        #else
            #define HDStrongify(obj) try{} @finally{} __typeof__(obj) obj = obj##Block;
        #endif
    #endif
#endif
// clang-format on

/** 主窗口 */
#define KeyWindow [[UIApplication sharedApplication].delegate window]
/** 导航栏的高度 */
#define kNavigationBarH [HDHelper hd_navigationFullHeight]
/** TabBar的高度 */
#define kTabBarH [HDHelper hd_tabBarFullHeight]
/** iphoneX底部安全区域高度 */
#define kiPhoneXSeriesSafeBottomHeight [HDHelper hd_safeDistanceBottom]
/** 适配顶部状态栏高度 */
#define kStatusBarH [HDHelper hd_statusBarHeight]
// 打电话、定位、录音等场景热区高度
#define kHotSpotStatusBarH 20

#define SCREEN_MAX_LENGTH (MAX(kScreenWidth, kScreenHeight))
#define SCREEN_MIN_LENGTH (MIN(kScreenWidth, kScreenHeight))

#define kWidthCoefficientTo6S kScreenWidth / 375.0
#define kHeightCoefficientTo6S (iPhoneXSeries ? 667.0 / 667.0 : kScreenHeight / 667.0)

#ifndef AngleWithDegrees
#define AngleWithDegrees(deg) (M_PI * (deg) / 180.0)
#endif

#pragma mark - 颜色
#define HDColorAlphaFull(r, g, b) [UIColor colorWithRed:(r) / 255.0 green:(g) / 255.0 blue:(b) / 255.0 alpha:(1) / 1.0]
#define HDColor(r, g, b, a) [UIColor colorWithRed:(r) / 255.0 green:(g) / 255.0 blue:(b) / 255.0 alpha:(a) / 1.0]
// 随机色
#define HDRandomColor HDColor(arc4random_uniform(256.0), arc4random_uniform(256.0), arc4random_uniform(256.0), 1)

#define HexColor(hexValue) [UIColor colorWithRed:((float)((hexValue & 0xFF0000) >> 16)) / 255.0 green:((float)((hexValue & 0xFF00) >> 8)) / 255.0 blue:((float)(hexValue & 0xFF)) / 255.0 alpha:1]

#pragma mark - 根据ip6s的屏幕来拉伸，向下取整
#define kRealWidth(with) (floor((with) * (kWidthCoefficientTo6S)))
#define kRealHeight(with) (floor((with) * (kHeightCoefficientTo6S)))

#define frameString(...) NSStringFromCGRect(__VA_ARGS__)
#define pointString(...) NSStringFromCGPoint(__VA_ARGS__)

#pragma mark - 动画

#define HDViewAnimationOptionsCurveOut (7 << 16)
#define HDViewAnimationOptionsCurveIn (8 << 16)

#pragma mark - Clang

#define ArgumentToString(macro) #macro
#define ClangWarningConcat(warning_name) ArgumentToString(clang diagnostic ignored warning_name)

/// 参数可直接传入 clang 的 warning 名，warning 列表参考：https://clang.llvm.org/docs/DiagnosticsReference.html
#define BeginIgnoreClangWarning(warningName) _Pragma("clang diagnostic push") _Pragma(ClangWarningConcat(#warningName))
#define EndIgnoreClangWarning _Pragma("clang diagnostic pop")

// clang-format off
#define BeginIgnorePerformSelectorLeaksWarning BeginIgnoreClangWarning(-Warc-performSelector-leaks)
#define EndIgnorePerformSelectorLeaksWarning EndIgnoreClangWarning

#define BeginIgnoreAvailabilityWarning BeginIgnoreClangWarning(-Wpartial-availability)
#define EndIgnoreAvailabilityWarning EndIgnoreClangWarning

#define BeginIgnoreDeprecatedWarning BeginIgnoreClangWarning(-Wdeprecated-declarations)
#define EndIgnoreDeprecatedWarning EndIgnoreClangWarning
// clang-format on

#pragma mark - ENV

#ifdef DEBUG
#define IS_DEBUG YES
#else
#define IS_DEBUG NO
#endif

#pragma mark - 判断

// 是否为空对象
#ifndef HDIsObjectNil
#define HDIsObjectNil(__object) ((nil == __object) || [__object isKindOfClass:[NSNull class]])
#endif

// 字符串为空
#ifndef HDIsStringEmpty
#define HDIsStringEmpty(__string) (HDIsObjectNil(__string) || (__string.length == 0))
#endif

// 字符串不为空
#ifndef HDIsStringNotEmpty
#define HDIsStringNotEmpty(__string) (!HDIsStringEmpty(__string))
#endif

// 数组为空
#ifndef HDIsArrayEmpty
#define HDIsArrayEmpty(__array) ((HDIsObjectNil(__array)) || (__array.count == 0))
#endif

#pragma mark - Block

#ifndef VoidBlock
typedef void (^VoidBlock)(void);
#endif

#ifndef StringBlock
typedef void (^StringBlock)(NSString *__nullable string);
#endif

#pragma mark - 系统版本

#define HD_iOSVersion [[UIDevice currentDevice] systemVersion].floatValue
#define HD_iOS7_VERSTION_LATER (HD_iOSVersion >= 7.0)
#define HD_iOS8_VERSTION_LATER (HD_iOSVersion >= 8.0)
#define HD_iOS9_VERSTION_LATER (HD_iOSVersion >= 9.0)
#define HD_iOS10_VERSTION_LATER (HD_iOSVersion >= 10.0)
#define HD_iOS11_VERSTION_LATER (HD_iOSVersion >= 11.0)
#define HD_iOS12_VERSTION_LATER (HD_iOSVersion >= 12.0)

#pragma mark - 国际化
#define HDLocalizedStringInBundleForLanguageFromTable(_bundle, _language, _key, _value, _table) [[NSBundle bundleWithPath:[_bundle pathForResource:_language ofType:@"lproj"]] localizedStringForKey:_key value:_value table:_table]

#endif /* HDCommonDefines_h */
