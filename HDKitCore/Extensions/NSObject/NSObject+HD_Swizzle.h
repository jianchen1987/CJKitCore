//
//  NSObject+HD_Swizzle.h
//  HDKitCore
//
//  Created by VanJay on 2019/4/14.
//  Copyright © 2019 chaos network technology. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

void hd_swizzleClassMethod(Class cls, SEL origSelector, SEL newSelector);
void hd_swizzleInstanceMethod(Class cls, SEL origSelector, SEL newSelector);

@interface NSObject (HD_Swizzle)

/**
 交换类方法

 @param origSelector 源方法
 @param newSelector 目标方法
 */
+ (void)hd_swizzleClassMethod:(SEL)origSelector withMethod:(SEL)newSelector;

/**
 交换类方法

 @param origSelector 源方法
 @param newSelector 目标方法
 */
+ (void)hd_swizzleInstanceMethod:(SEL)origSelector withMethod:(SEL)newSelector;

/**
 交换类方法

 @param origSelector 源方法
 @param newSelector 目标方法
 */
- (void)hd_swizzleInstanceMethod:(SEL)origSelector withMethod:(SEL)newSelector;
@end

NS_ASSUME_NONNULL_END
