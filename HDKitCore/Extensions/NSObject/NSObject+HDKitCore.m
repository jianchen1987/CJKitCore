//
//  NSObject+HDKitCore.m
//  HDKitCore
//
//  Created by VanJay on 2019/9/5.
//  Copyright © 2019 chaos network technology. All rights reserved.
//

#import "HDCommonDefines.h"
#import "HDAssociatedObjectHelper.h"
#import "HDWeakObjectContainer.h"
#import "NSObject+HD_Swizzle.h"
#import "NSObject+HDKitCore.h"
#import "NSString+HDKitCore.h"
#import <objc/message.h>
#import <objc/runtime.h>

@implementation NSObject (HDKitCore)

- (BOOL)hd_hasOverrideMethod:(SEL)selector ofSuperclass:(Class)superclass {
    return [NSObject hd_hasOverrideMethod:selector forClass:self.class ofSuperclass:superclass];
}

+ (BOOL)hd_hasOverrideMethod:(SEL)selector forClass:(Class)aClass ofSuperclass:(Class)superclass {
    if (![aClass isSubclassOfClass:superclass]) {
        return NO;
    }

    if (![superclass instancesRespondToSelector:selector]) {
        return NO;
    }

    Method superclassMethod = class_getInstanceMethod(superclass, selector);
    Method instanceMethod = class_getInstanceMethod(aClass, selector);
    if (!instanceMethod || instanceMethod == superclassMethod) {
        return NO;
    }
    return YES;
}

- (id)hd_performSelectorToSuperclass:(SEL)aSelector {
    struct objc_super mySuper;
    mySuper.receiver = self;
    mySuper.super_class = class_getSuperclass(object_getClass(self));

    id (*objc_superAllocTyped)(struct objc_super *, SEL) = (void *)&objc_msgSendSuper;
    return (*objc_superAllocTyped)(&mySuper, aSelector);
}

- (id)hd_performSelectorToSuperclass:(SEL)aSelector withObject:(id)object {
    struct objc_super mySuper;
    mySuper.receiver = self;
    mySuper.super_class = class_getSuperclass(object_getClass(self));

    id (*objc_superAllocTyped)(struct objc_super *, SEL, ...) = (void *)&objc_msgSendSuper;
    return (*objc_superAllocTyped)(&mySuper, aSelector, object);
}

- (id)hd_performSelector:(SEL)selector withArguments:(void *)firstArgument, ... {
    NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:[self methodSignatureForSelector:selector]];
    [invocation setTarget:self];
    [invocation setSelector:selector];

    if (firstArgument) {
        va_list valist;
        va_start(valist, firstArgument);
        [invocation setArgument:firstArgument atIndex:2];  // 0->self, 1->_cmd

        void *currentArgument;
        NSInteger index = 3;
        while ((currentArgument = va_arg(valist, void *))) {
            [invocation setArgument:currentArgument atIndex:index];
            index++;
        }
        va_end(valist);
    }

    [invocation invoke];

    const char *typeEncoding = method_getTypeEncoding(class_getInstanceMethod(object_getClass(self), selector));
    if (strncmp(typeEncoding, "@", 1) == 0) {
        __unsafe_unretained id returnValue;
        [invocation getReturnValue:&returnValue];
        return returnValue;
    }
    return nil;
}

- (void)hd_performSelector:(SEL)selector withPrimitiveReturnValue:(void *)returnValue {
    [self hd_performSelector:selector withPrimitiveReturnValue:returnValue arguments:nil];
}

- (void)hd_performSelector:(SEL)selector withPrimitiveReturnValue:(void *)returnValue arguments:(void *)firstArgument, ... {
    NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:[self methodSignatureForSelector:selector]];
    [invocation setTarget:self];
    [invocation setSelector:selector];

    if (firstArgument) {
        va_list valist;
        va_start(valist, firstArgument);
        [invocation setArgument:firstArgument atIndex:2];  // 0->self, 1->_cmd

        void *currentArgument;
        NSInteger index = 3;
        while ((currentArgument = va_arg(valist, void *))) {
            [invocation setArgument:currentArgument atIndex:index];
            index++;
        }
        va_end(valist);
    }

    [invocation invoke];

    if (returnValue) {
        [invocation getReturnValue:returnValue];
    }
}

- (void)hd_enumrateIvarsUsingBlock:(void (^)(Ivar ivar, NSString *ivarDescription))block {
    [self hd_enumrateIvarsIncludingInherited:NO usingBlock:block];
}

- (void)hd_enumrateIvarsIncludingInherited:(BOOL)includingInherited usingBlock:(void (^)(Ivar ivar, NSString *ivarDescription))block {
    NSMutableArray<NSString *> *ivarDescriptions = [NSMutableArray new];
    NSString *ivarList = [self hd_ivarList];
    NSError *error;
    NSRegularExpression *reg = [NSRegularExpression regularExpressionWithPattern:[NSString stringWithFormat:@"in %@:(.*?)((?=in \\w+:)|$)", NSStringFromClass(self.class)] options:NSRegularExpressionDotMatchesLineSeparators error:&error];
    if (!error) {
        NSArray<NSTextCheckingResult *> *result = [reg matchesInString:ivarList options:NSMatchingReportCompletion range:NSMakeRange(0, ivarList.length)];
        [result enumerateObjectsUsingBlock:^(NSTextCheckingResult *_Nonnull obj, NSUInteger idx, BOOL *_Nonnull stop) {
            NSString *ivars = [ivarList substringWithRange:[obj rangeAtIndex:1]];
            [ivars enumerateLinesUsingBlock:^(NSString *_Nonnull line, BOOL *_Nonnull stop) {
                if (![line hasPrefix:@"\t\t"]) {  // 有些 struct 类型的变量，会把 struct 的成员也缩进打出来，所以用这种方式过滤掉
                    line = line.hd_trim;
                    if (line.length > 2) {  // 过滤掉空行或者 struct 结尾的"}"
                        NSRange range = [line rangeOfString:@":"];
                        if (range.location != NSNotFound)                   // 有些"unknow type"的变量不会显示指针地址（例如 UIView->_viewFlags）
                            line = [line substringToIndex:range.location];  // 去掉指针地址
                        NSUInteger typeStart = [line rangeOfString:@" ("].location;
                        line = [NSString stringWithFormat:@"%@ %@", [line substringWithRange:NSMakeRange(typeStart + 2, line.length - 1 - (typeStart + 2))], [line substringToIndex:typeStart]];  // 交换变量类型和变量名的位置，变量类型在前，变量名在后，空格隔开
                        [ivarDescriptions addObject:line];
                    }
                }
            }];
        }];
    }

    unsigned int outCount = 0;
    Ivar *ivars = class_copyIvarList(self.class, &outCount);
    for (unsigned int i = 0; i < outCount; i++) {
        Ivar ivar = ivars[i];
        NSString *ivarName = [NSString stringWithFormat:@"%s", ivar_getName(ivar)];
        for (NSString *desc in ivarDescriptions) {
            if ([desc hasSuffix:ivarName]) {
                block(ivar, desc);
                break;
            }
        }
    }
    free(ivars);

    if (includingInherited) {
        Class superclass = self.superclass;
        if (superclass) {
            [NSObject hd_enumrateIvarsOfClass:superclass includingInherited:includingInherited usingBlock:block];
        }
    }
}

+ (void)hd_enumrateIvarsOfClass:(Class)aClass includingInherited:(BOOL)includingInherited usingBlock:(void (^)(Ivar, NSString *))block {
    if (!block) return;
    NSObject *obj = nil;
    if ([aClass isSubclassOfClass:[UICollectionView class]]) {
        obj = [[aClass alloc] initWithFrame:CGRectZero collectionViewLayout:UICollectionViewFlowLayout.new];
    } else {
        obj = [aClass new];
    }
    [obj hd_enumrateIvarsIncludingInherited:includingInherited usingBlock:block];
}

- (void)hd_enumratePropertiesUsingBlock:(void (^)(objc_property_t property, NSString *propertyName))block {
    [NSObject hd_enumratePropertiesOfClass:self.class includingInherited:NO usingBlock:block];
}

+ (void)hd_enumratePropertiesOfClass:(Class)aClass includingInherited:(BOOL)includingInherited usingBlock:(void (^)(objc_property_t, NSString *))block {
    if (!block) return;

    unsigned int propertiesCount = 0;
    objc_property_t *properties = class_copyPropertyList(aClass, &propertiesCount);

    for (unsigned int i = 0; i < propertiesCount; i++) {
        objc_property_t property = properties[i];
        if (block) block(property, [NSString stringWithFormat:@"%s", property_getName(property)]);
    }

    free(properties);

    if (includingInherited) {
        Class superclass = class_getSuperclass(aClass);
        if (superclass) {
            [NSObject hd_enumratePropertiesOfClass:superclass includingInherited:includingInherited usingBlock:block];
        }
    }
}

- (void)hd_enumrateInstanceMethodsUsingBlock:(void (^)(Method, SEL))block {
    [NSObject hd_enumrateInstanceMethodsOfClass:self.class includingInherited:NO usingBlock:block];
}

+ (void)hd_enumrateInstanceMethodsOfClass:(Class)aClass includingInherited:(BOOL)includingInherited usingBlock:(void (^)(Method, SEL))block {
    if (!block) return;

    unsigned int methodCount = 0;
    Method *methods = class_copyMethodList(aClass, &methodCount);

    for (unsigned int i = 0; i < methodCount; i++) {
        Method method = methods[i];
        SEL selector = method_getName(method);
        if (block) block(method, selector);
    }

    free(methods);

    if (includingInherited) {
        Class superclass = class_getSuperclass(aClass);
        if (superclass) {
            [NSObject hd_enumrateInstanceMethodsOfClass:superclass includingInherited:includingInherited usingBlock:block];
        }
    }
}

+ (void)hd_enumerateProtocolMethods:(Protocol *)protocol usingBlock:(void (^)(SEL))block {
    if (!block) return;

    unsigned int methodCount = 0;
    struct objc_method_description *methods = protocol_copyMethodDescriptionList(protocol, NO, YES, &methodCount);
    for (int i = 0; i < methodCount; i++) {
        struct objc_method_description methodDescription = methods[i];
        if (block) {
            block(methodDescription.name);
        }
    }
    free(methods);
}

- (void)setHd_associatedObject:(id)hd_associatedObject {
    [self willChangeValueForKey:@"hd_associatedObject"];
    objc_setAssociatedObject(self, @selector(hd_associatedObject), hd_associatedObject, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    [self didChangeValueForKey:@"hd_associatedObject"];
}

- (id)hd_associatedObject {
    return objc_getAssociatedObject(self, _cmd);
}
@end

@implementation NSObject (Debug)

BeginIgnorePerformSelectorLeaksWarning;
- (NSString *)hd_methodList {
    return [self performSelector:NSSelectorFromString(@"_methodDescription")];
}

- (NSString *)hd_shortMethodList {
    return [self performSelector:NSSelectorFromString(@"_shortMethodDescription")];
}

- (NSString *)hd_ivarList {
    return [self performSelector:NSSelectorFromString(@"_ivarDescription")];
}
EndIgnorePerformSelectorLeaksWarning;

@end

@implementation NSObject (HD_DataBind)

static char kAssociatedObjectKey_HDAllBoundObjects;
- (NSMutableDictionary<id, id> *)hd_allBoundObjects {
    NSMutableDictionary<id, id> *dict = objc_getAssociatedObject(self, &kAssociatedObjectKey_HDAllBoundObjects);
    if (!dict) {
        dict = [NSMutableDictionary dictionary];
        objc_setAssociatedObject(self, &kAssociatedObjectKey_HDAllBoundObjects, dict, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    return dict;
}

- (void)hd_bindObject:(id)object forKey:(NSString *)key {
    if (!key.length) {
        NSAssert(NO, @"");
        return;
    }
    if (object) {
        [[self hd_allBoundObjects] setObject:object forKey:key];
    } else {
        [[self hd_allBoundObjects] removeObjectForKey:key];
    }
}

- (void)hd_bindObjectWeakly:(id)object forKey:(NSString *)key {
    if (!key.length) {
        NSAssert(NO, @"");
        return;
    }
    if (object) {
        HDWeakObjectContainer *container = [[HDWeakObjectContainer alloc] initWithObject:object];
        [self hd_bindObject:container forKey:key];
    } else {
        [[self hd_allBoundObjects] removeObjectForKey:key];
    }
}

- (id)hd_getBoundObjectForKey:(NSString *)key {
    if (!key.length) {
        NSAssert(NO, @"");
        return nil;
    }
    id storedObj = [[self hd_allBoundObjects] objectForKey:key];
    if ([storedObj isKindOfClass:[HDWeakObjectContainer class]]) {
        storedObj = [(HDWeakObjectContainer *)storedObj object];
    }
    return storedObj;
}

- (void)hd_bindDouble:(double)doubleValue forKey:(NSString *)key {
    [self hd_bindObject:@(doubleValue) forKey:key];
}

- (double)hd_getBoundDoubleForKey:(NSString *)key {
    id object = [self hd_getBoundObjectForKey:key];
    if ([object isKindOfClass:[NSNumber class]]) {
        double doubleValue = [(NSNumber *)object doubleValue];
        return doubleValue;

    } else {
        return 0.0;
    }
}

- (void)hd_bindBOOL:(BOOL)boolValue forKey:(NSString *)key {
    [self hd_bindObject:@(boolValue) forKey:key];
}

- (BOOL)hd_getBoundBOOLForKey:(NSString *)key {
    id object = [self hd_getBoundObjectForKey:key];
    if ([object isKindOfClass:[NSNumber class]]) {
        BOOL boolValue = [(NSNumber *)object boolValue];
        return boolValue;

    } else {
        return NO;
    }
}

- (void)hd_bindLong:(long)longValue forKey:(NSString *)key {
    [self hd_bindObject:@(longValue) forKey:key];
}

- (long)hd_getBoundLongForKey:(NSString *)key {
    id object = [self hd_getBoundObjectForKey:key];
    if ([object isKindOfClass:[NSNumber class]]) {
        long longValue = [(NSNumber *)object longValue];
        return longValue;

    } else {
        return 0;
    }
}

- (void)hd_clearBindingForKey:(NSString *)key {
    [self hd_bindObject:nil forKey:key];
}

- (void)hd_clearAllBinding {
    [[self hd_allBoundObjects] removeAllObjects];
}

- (NSArray<NSString *> *)hd_allBindingKeys {
    NSArray<NSString *> *allKeys = [[self hd_allBoundObjects] allKeys];
    return allKeys;
}

- (BOOL)hd_hasBindingKey:(NSString *)key {
    return [[self hd_allBindingKeys] containsObject:key];
}

@end

@implementation NSObject (HD_Dealloc)

HDSynthesizeIdCopyProperty(hd_objectDeallocBlock, setHd_objectDeallocBlock);

+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        hd_swizzleInstanceMethod(self, NSSelectorFromString(@"dealloc"), @selector(hd_objectDealloc));
    });
}

- (void)hd_objectDealloc {
    !self.hd_objectDeallocBlock ?: self.hd_objectDeallocBlock();
    [self hd_objectDealloc];
}

@end
