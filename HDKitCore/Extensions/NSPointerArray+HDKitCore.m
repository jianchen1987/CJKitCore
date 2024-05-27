//
//  NSObject+NSPointerArray+HD.m
//  HDKitCore
//
//  Created by VanJay on 2020/1/9.
//  Copyright © 2020 chaos network technology. All rights reserved.
//

#import "HDCommonDefines.h"
#import "HDRunTime.h"
#import "NSPointerArray+HDKitCore.h"

@implementation NSPointerArray (HDKitCore)

+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        ExtendImplementationOfNonVoidMethodWithoutArguments([NSPointerArray class], @selector(description), NSString *, ^NSString *(NSPointerArray *selfObject, NSString *originReturnValue) {
            NSMutableString *result = [[NSMutableString alloc] initWithString:originReturnValue];
            NSPointerArray *array = [selfObject copy];
            for (NSInteger i = 0; i < array.count; i++) {
                ([result appendFormat:@"\npointer[%@] is %@", @(i), [array pointerAtIndex:i]]);
            }
            return result;
        });
    });
}

- (NSUInteger)hd_indexOfPointer:(nullable void *)pointer {
    if (!pointer) {
        return NSNotFound;
    }

    NSPointerArray *array = [self copy];
    for (NSUInteger i = 0; i < array.count; i++) {
        if ([array pointerAtIndex:i] == ((void *)pointer)) {
            return i;
        }
    }
    return NSNotFound;
}

- (BOOL)hd_containsPointer:(void *)pointer {
    if (!pointer) {
        return NO;
    }
    if ([self hd_indexOfPointer:pointer] != NSNotFound) {
        return YES;
    }
    return NO;
}

@end
