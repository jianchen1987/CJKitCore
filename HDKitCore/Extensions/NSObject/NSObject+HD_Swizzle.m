//
//  NSObject+HD_Swizzle.m
//  HDKitCore
//
//  Created by VanJay on 2019/4/14.
//  Copyright © 2019 chaos network technology. All rights reserved.
//

#import "NSObject+HD_Swizzle.h"
#import <objc/runtime.h>

@implementation NSObject (HD_Swizzle)
+ (void)hd_swizzleClassMethod:(SEL)origSelector withMethod:(SEL)newSelector {
    hd_swizzleClassMethod(self.class, origSelector, newSelector);
}

+ (void)hd_swizzleInstanceMethod:(SEL)origSelector withMethod:(SEL)newSelector {
    hd_swizzleInstanceMethod(self.class, origSelector, newSelector);
}

- (void)hd_swizzleInstanceMethod:(SEL)origSelector withMethod:(SEL)newSelector {
    hd_swizzleInstanceMethod(self.class, origSelector, newSelector);
}

void hd_swizzleClassMethod(Class cls, SEL origSelector, SEL newSelector) {
    if (!cls) return;
    Method originalMethod = class_getClassMethod(cls, origSelector);
    Method hd_swizzledMethod = class_getClassMethod(cls, newSelector);

    Class metacls = objc_getMetaClass(NSStringFromClass(cls).UTF8String);
    if (class_addMethod(metacls,
                        origSelector,
                        method_getImplementation(hd_swizzledMethod),
                        method_getTypeEncoding(hd_swizzledMethod))) {
        // 交换父类的类方法，如果不存在则添加
        class_replaceMethod(metacls,
                            newSelector,
                            method_getImplementation(originalMethod),
                            method_getTypeEncoding(originalMethod));

    } else {
        // 交换方法可能属于父类
        class_replaceMethod(metacls,
                            newSelector,
                            class_replaceMethod(metacls,
                                                origSelector,
                                                method_getImplementation(hd_swizzledMethod),
                                                method_getTypeEncoding(hd_swizzledMethod)),
                            method_getTypeEncoding(originalMethod));
    }
}

void hd_swizzleInstanceMethod(Class cls, SEL origSelector, SEL newSelector) {
    if (!cls) {
        return;
    }
    // 如果本类中不存在该方法，则去父类获取
    Method originalMethod = class_getInstanceMethod(cls, origSelector);
    Method hd_swizzledMethod = class_getInstanceMethod(cls, newSelector);

    // 如果方法不存在则添加
    if (class_addMethod(cls,
                        origSelector,
                        method_getImplementation(hd_swizzledMethod),
                        method_getTypeEncoding(hd_swizzledMethod))) {
        // 替换实例方法，如果不存在则添加
        class_replaceMethod(cls,
                            newSelector,
                            method_getImplementation(originalMethod),
                            method_getTypeEncoding(originalMethod));

    } else {
        // 交换方法可能属于父类
        class_replaceMethod(cls,
                            newSelector,
                            class_replaceMethod(cls,
                                                origSelector,
                                                method_getImplementation(hd_swizzledMethod),
                                                method_getTypeEncoding(hd_swizzledMethod)),
                            method_getTypeEncoding(originalMethod));
    }
}
@end
