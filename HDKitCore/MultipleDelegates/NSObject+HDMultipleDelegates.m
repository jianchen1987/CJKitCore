//
//  NSObject+HDMultipleDelegates.m
//  HDKitCore
//
//  Created by VanJay on 2020/1/9.
//  Copyright © 2020 chaos network technology. All rights reserved.
//

#import "HDAssociatedObjectHelper.h"
#import "HDCommonDefines.h"
#import "HDMultipleDelegates.h"
#import "HDRunTime.h"
#import "NSObject+HDMultipleDelegates.h"
#import "NSPointerArray+HDKitCore.h"
#import "NSString+HDKitCore.h"

@interface NSObject ()
@property (nonatomic, strong) NSMutableDictionary<NSString *, HDMultipleDelegates *> *hdmd_delegates;
@end

@implementation NSObject (HDMultipleDelegates)

HDSynthesizeIdStrongProperty(hdmd_delegates, setHdmd_delegates);

static NSMutableSet<NSString *> *hd_methodsReplacedClasses;

static char kAssociatedObjectKey_hdMultipleDelegatesEnabled;
- (void)setHd_multipleDelegatesEnabled:(BOOL)hd_multipleDelegatesEnabled {
    objc_setAssociatedObject(self, &kAssociatedObjectKey_hdMultipleDelegatesEnabled, @(hd_multipleDelegatesEnabled), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    if (hd_multipleDelegatesEnabled) {
        if (!self.hdmd_delegates) {
            self.hdmd_delegates = [NSMutableDictionary dictionary];
        }
        [self hd_registerDelegateSelector:@selector(delegate)];
        if ([self isKindOfClass:[UITableView class]] || [self isKindOfClass:[UICollectionView class]]) {
            [self hd_registerDelegateSelector:@selector(dataSource)];
        }
    }
}

- (BOOL)hd_multipleDelegatesEnabled {
    return [((NSNumber *)objc_getAssociatedObject(self, &kAssociatedObjectKey_hdMultipleDelegatesEnabled)) boolValue];
}

- (void)hd_registerDelegateSelector:(SEL)getter {
    if (!self.hd_multipleDelegatesEnabled) {
        return;
    }

    Class targetClass = [self class];
    SEL originDelegateSetter = setterWithGetter(getter);
    SEL newDelegateSetter = [self newSetterWithGetter:getter];
    Method originMethod = class_getInstanceMethod(targetClass, originDelegateSetter);
    if (!originMethod) {
        return;
    }

    // 为这个 selector 创建一个 HDMultipleDelegates 容器
    NSString *delegateGetterKey = NSStringFromSelector(getter);
    if (!self.hdmd_delegates[delegateGetterKey]) {
        objc_property_t prop = class_getProperty(self.class, delegateGetterKey.UTF8String);
        HDPropertyDescriptor *property = [HDPropertyDescriptor descriptorWithProperty:prop];
        if (property.isStrong) {
            // strong property
            HDMultipleDelegates *strongDelegates = [HDMultipleDelegates strongDelegates];
            strongDelegates.parentObject = self;
            self.hdmd_delegates[delegateGetterKey] = strongDelegates;
        } else {
            // weak property
            HDMultipleDelegates *weakDelegates = [HDMultipleDelegates weakDelegates];
            weakDelegates.parentObject = self;
            self.hdmd_delegates[delegateGetterKey] = weakDelegates;
        }
    }

    // 避免为某个 class 重复替换同一个方法的实现
    if (!hd_methodsReplacedClasses) {
        hd_methodsReplacedClasses = [NSMutableSet set];
    }
    NSString *classAndMethodIdentifier = [NSString stringWithFormat:@"%@-%@", NSStringFromClass(targetClass), delegateGetterKey];
    if (![hd_methodsReplacedClasses containsObject:classAndMethodIdentifier]) {
        [hd_methodsReplacedClasses addObject:classAndMethodIdentifier];

        IMP originIMP = method_getImplementation(originMethod);
        void (*originSelectorIMP)(id, SEL, id);
        originSelectorIMP = (void (*)(id, SEL, id))originIMP;

        BOOL isAddedMethod = class_addMethod(targetClass, newDelegateSetter, imp_implementationWithBlock(^(NSObject *selfObject, id aDelegate) {
                                                 // 保护
                                                 if (!selfObject.hd_multipleDelegatesEnabled || selfObject.class != targetClass) {
                                                     originSelectorIMP(selfObject, originDelegateSetter, aDelegate);
                                                     return;
                                                 }

                                                 HDMultipleDelegates *delegates = selfObject.hdmd_delegates[delegateGetterKey];

                                                 if (!aDelegate) {
                                                     // 对应 setDelegate:nil，表示清理所有的 delegate
                                                     [delegates removeAllDelegates];
                                                     selfObject.hd_delegatesSelf = NO;
                                                     // 只要 hd_multipleDelegatesEnabled 开启，就会保证 delegate 一直是 delegates，所以不去调用系统默认的 set nil
                                                     // originSelectorIMP(selfObject, originDelegateSetter, nil);
                                                     return;
                                                 }

                                                 if (aDelegate != delegates) {  // 过滤掉容器自身，避免把 delegates 传进去 delegates 里，导致死循环
                                                     [delegates addDelegate:aDelegate];
                                                 }

                                                 // 将类似 textView.delegate = textView 的情况标志起来，避免产生循环调用
                                                 selfObject.hd_delegatesSelf = [delegates.delegates hd_containsPointer:(__bridge void *_Nullable)(selfObject)];

                                                 originSelectorIMP(selfObject, originDelegateSetter, nil);        // 先置为 nil 再设置 delegates，从而避免这个问题
                                                 originSelectorIMP(selfObject, originDelegateSetter, delegates);  // 不管外面将什么 object 传给 setDelegate:，最终实际上传进去的都是 HDMultipleDelegates 容器
                                             }),
                                             method_getTypeEncoding(originMethod));
        if (isAddedMethod) {
            Method newMethod = class_getInstanceMethod(targetClass, newDelegateSetter);
            method_exchangeImplementations(originMethod, newMethod);
        }
    }

    // 如果原来已经有 delegate，则将其加到新建的容器里
    BeginIgnorePerformSelectorLeaksWarning;
    id originDelegate = [self performSelector:getter];
    if (originDelegate && originDelegate != self.hdmd_delegates[delegateGetterKey]) {
        [self performSelector:originDelegateSetter withObject:originDelegate];
    }
    EndIgnorePerformSelectorLeaksWarning;
}

- (void)hd_removeDelegate:(id)delegate {
    if (!self.hd_multipleDelegatesEnabled) {
        return;
    }
    NSMutableArray<NSString *> *delegateGetters = [[NSMutableArray alloc] init];
    [self.hdmd_delegates enumerateKeysAndObjectsUsingBlock:^(NSString *_Nonnull key, HDMultipleDelegates *_Nonnull obj, BOOL *_Nonnull stop) {
        BOOL removeSucceed = [obj removeDelegate:delegate];
        if (removeSucceed) {
            [delegateGetters addObject:key];
        }
    }];
    if (delegateGetters.count > 0) {
        for (NSString *getterString in delegateGetters) {
            [self refreshDelegateWithGetter:NSSelectorFromString(getterString)];
        }
    }
}

- (void)refreshDelegateWithGetter:(SEL)getter {
    SEL originSetterSEL = [self newSetterWithGetter:getter];
    BeginIgnorePerformSelectorLeaksWarning;
    id originDelegate = [self performSelector:getter];
    [self performSelector:originSetterSEL withObject:nil];  // 先置为 nil 再设置 delegates，从而避免这个问题
    [self performSelector:originSetterSEL withObject:originDelegate];
    EndIgnorePerformSelectorLeaksWarning;
}

// 根据 delegate property 的 getter，得到 HDMultipleDelegates 为它的 setter 创建的新 setter 方法，最终交换原方法，因此利用这个方法返回的 SEL，可以调用到原来的 delegate property setter 的实现
- (SEL)newSetterWithGetter:(SEL)getter {
    return NSSelectorFromString([NSString stringWithFormat:@"hdmd_%@", NSStringFromSelector(setterWithGetter(getter))]);
}

@end

@implementation NSObject (HDMultipleDelegates_Private)
HDSynthesizeBOOLProperty(hd_delegatesSelf, setHd_delegatesSelf);
@end
