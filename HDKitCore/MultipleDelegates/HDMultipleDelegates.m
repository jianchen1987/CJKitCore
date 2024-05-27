//
//  NSObject+HDMultipleDelegates.m
//  HDKitCore
//
//  Created by VanJay on 2020/1/9.
//  Copyright © 2020 chaos network technology. All rights reserved.
//

#import "HDMultipleDelegates.h"
#import "NSMethodSignature+HDKitCore.h"
#import "NSPointerArray+HDKitCore.h"
#import <objc/runtime.h>

@interface HDMultipleDelegates ()
@property (nonatomic, strong, readwrite) NSPointerArray *delegates;
@end

@implementation HDMultipleDelegates

+ (instancetype)weakDelegates {
    HDMultipleDelegates *delegates = [[HDMultipleDelegates alloc] init];
    delegates.delegates = [NSPointerArray weakObjectsPointerArray];
    return delegates;
}

+ (instancetype)strongDelegates {
    HDMultipleDelegates *delegates = [[HDMultipleDelegates alloc] init];
    delegates.delegates = [NSPointerArray strongObjectsPointerArray];
    return delegates;
}

- (void)addDelegate:(id)delegate {
    if (![self containsDelegate:delegate] && delegate != self) {
        [self.delegates addPointer:(__bridge void *)delegate];
    }
}

- (BOOL)removeDelegate:(id)delegate {
    NSUInteger index = [self.delegates hd_indexOfPointer:(__bridge void *)delegate];
    if (index != NSNotFound) {
        [self.delegates removePointerAtIndex:index];
        return YES;
    }
    return NO;
}

- (void)removeAllDelegates {
    for (NSInteger i = self.delegates.count - 1; i >= 0; i--) {
        [self.delegates removePointerAtIndex:i];
    }
}

- (BOOL)containsDelegate:(id)delegate {
    return [self.delegates hd_containsPointer:(__bridge void *)delegate];
}

- (NSMethodSignature *)methodSignatureForSelector:(SEL)aSelector {
    NSMethodSignature *result = [super methodSignatureForSelector:aSelector];
    if (result) {
        return result;
    }

    NSPointerArray *delegates = [self.delegates copy];
    for (id delegate in delegates) {
        result = [delegate methodSignatureForSelector:aSelector];
        if (result && [delegate respondsToSelector:aSelector]) {
            return result;
        }
    }

    return NSMethodSignature.hd_avoidExceptionSignature;
}

- (void)forwardInvocation:(NSInvocation *)anInvocation {
    SEL selector = anInvocation.selector;
    NSPointerArray *delegates = [self.delegates copy];
    for (id delegate in delegates) {
        if ([delegate respondsToSelector:selector]) {
            [anInvocation invokeWithTarget:delegate];
        }
    }
}

- (BOOL)respondsToSelector:(SEL)aSelector {
    if ([super respondsToSelector:aSelector]) {
        return YES;
    }

    NSPointerArray *delegates = [self.delegates copy];
    for (id delegate in delegates) {
        if (class_respondsToSelector(self.class, aSelector)) {
            return YES;
        }

        // 对 HDMultipleDelegates
        BOOL delegateCanRespondToSelector = [delegate isKindOfClass:self.class] ? [delegate respondsToSelector:aSelector] : class_respondsToSelector(((NSObject *)delegate).class, aSelector);

        // 判断 hd_delegatesSelf
        // 不支持 self.delegate = self 的写法，会引发死循环，有这种需求的场景建议在 self 内部创建一个对象专门用于 delegate 的响应，参考 _HDTextViewDelegator。
        BOOL isDelegateSelf = ((NSObject *)delegate).hd_delegatesSelf;
        if (delegateCanRespondToSelector && !isDelegateSelf) {
            return YES;
        }
    }
    return NO;
}

#pragma mark - Overrides

- (BOOL)isKindOfClass:(Class)aClass {
    BOOL result = [super isKindOfClass:aClass];
    if (result) return YES;

    NSPointerArray *delegates = [self.delegates copy];
    for (id delegate in delegates) {
        if ([delegate isKindOfClass:aClass]) return YES;
    }

    return NO;
}

- (BOOL)isMemberOfClass:(Class)aClass {
    BOOL result = [super isMemberOfClass:aClass];
    if (result) return YES;

    NSPointerArray *delegates = [self.delegates copy];
    for (id delegate in delegates) {
        if ([delegate isMemberOfClass:aClass]) return YES;
    }

    return NO;
}

- (BOOL)conformsToProtocol:(Protocol *)aProtocol {
    BOOL result = [super conformsToProtocol:aProtocol];
    if (result) return YES;

    NSPointerArray *delegates = [self.delegates copy];
    for (id delegate in delegates) {
        if ([delegate conformsToProtocol:aProtocol]) return YES;
    }

    return NO;
}

- (NSString *)description {
    return [NSString stringWithFormat:@"%@, parentObject is %@, %@", [super description], self.parentObject, self.delegates];
}

@end
