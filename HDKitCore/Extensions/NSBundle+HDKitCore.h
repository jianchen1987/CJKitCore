//
//  NSBundle+HDKitCore.h
//  HDKitCore
//
//  Created by VanJay on 2020/5/11.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSBundle (HDKitCore)

/// HDKitCoreResources 资源包
+ (NSBundle *)hd_kitCoreHDKitCoreResources;

/// 获取某个组件内部的bundle
/// @param frameworkName 组件库名（例：HDKitCore，HDUIKit，HDServiceKit等）
/// @param bundleName 资源bundle名
+ (NSBundle *)hd_bundleInFramework:(NSString *)frameworkName bundleName:(NSString *)bundleName;

@end

NS_ASSUME_NONNULL_END
