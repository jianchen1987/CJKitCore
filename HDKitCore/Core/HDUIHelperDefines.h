//
//  HDUIHelperDefines.h
//  HDKitCore
//
//  Created by VanJay on 2020/2/26.
//  Copyright © 2019 chaos network technology. All rights reserved.
//

#ifndef HDUIHelperDefines_h
#define HDUIHelperDefines_h

#import <UIKit/UIKit.h>

// 获取屏幕宽高
#ifndef kScreenWidth
#define kScreenWidth ([UIScreen mainScreen].bounds.size.width)
#endif

#ifndef kScreenHeight
#define kScreenHeight ([UIScreen mainScreen].bounds.size.height)
#endif
#define kScreenBounds [UIScreen mainScreen].bounds

/// 是否横竖屏
/// 用户界面横屏了才会返回YES
#ifndef IS_LANDSCAPE
#define IS_LANDSCAPE UIInterfaceOrientationIsLandscape([[UIApplication sharedApplication] statusBarOrientation])
#endif

/// 无论支不支持横屏，只要设备横屏了，就会返回YES
#ifndef IS_DEVICE_LANDSCAPE
#define IS_DEVICE_LANDSCAPE UIDeviceOrientationIsLandscape([[UIDevice currentDevice] orientation])
#endif

/// 屏幕宽度，跟横竖屏无关
#ifndef kDeviceWidth
#define kDeviceWidth (IS_LANDSCAPE ? kScreenHeight : kScreenWidth)
#endif

/// 屏幕高度，跟横竖屏无关
#ifndef kDeviceHeight
#define kDeviceHeight (IS_LANDSCAPE ? kScreenWidth : kScreenHeight)
#endif

#define iPhone4 (kDeviceHeight == 480)
#define iPhone6 (kDeviceHeight == 667)
#define iPhone6Plus (kDeviceHeight == 736)

/// 是否Retina
#define isRetainScreen ([[UIScreen mainScreen] scale] >= 2.0)

#define kScreenScale ([[UIScreen mainScreen] scale])

#endif /* HDUIHelperDefines_h */
