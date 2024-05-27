//
//  NSArray+HDKitCore.m
//  HDKitCore
//
//  Created by VanJay on 2019/7/22.
//  Copyright © 2019 chaos network technology. All rights reserved.
//

#import "NSArray+HDKitCore.h"

@implementation NSArray (Map)
- (NSArray *)mapObjectsUsingBlock:(id (^)(id obj, NSUInteger idx))block {
    NSMutableArray *result = [NSMutableArray arrayWithCapacity:self.count];
    [self enumerateObjectsUsingBlock:^(id objIn, NSUInteger idxIn, BOOL *stop) {
        id willAddObj = block(objIn, idxIn);
        if (willAddObj) {
            [result addObject:willAddObj];
        }
    }];
    return result;
}
@end

@implementation NSArray (HDKitCore)

+ (instancetype)hd_arrayWithObjects:(id)object, ... {
    void (^addObjectToArrayBlock)(NSMutableArray *array, id obj) = ^void(NSMutableArray *array, id obj) {
        if ([obj isKindOfClass:[NSArray class]]) {
            [array addObjectsFromArray:obj];
        } else {
            [array addObject:obj];
        }
    };

    NSMutableArray *result = [[NSMutableArray alloc] init];
    addObjectToArrayBlock(result, object);

    va_list argumentList;
    va_start(argumentList, object);
    id argument;
    while ((argument = va_arg(argumentList, id))) {
        addObjectToArrayBlock(result, argument);
    }
    va_end(argumentList);
    if ([self isKindOfClass:[NSMutableArray class]]) {
        return result;
    }
    return result.copy;
}

- (void)hd_enumerateNestedArrayWithBlock:(void (^)(id, BOOL *))block {
    BOOL stop = NO;
    for (NSInteger i = 0; i < self.count; i++) {
        id object = self[i];
        if ([object isKindOfClass:[NSArray class]]) {
            [((NSArray *)object) hd_enumerateNestedArrayWithBlock:block];
        } else {
            block(object, &stop);
        }
        if (stop) {
            return;
        }
    }
}

- (NSMutableArray *)hd_mutableCopyNestedArray {
    NSMutableArray *mutableResult = [self mutableCopy];
    for (NSInteger i = 0; i < self.count; i++) {
        id object = self[i];
        if ([object isKindOfClass:[NSArray class]]) {
            NSMutableArray *mutableItem = [((NSArray *)object) hd_mutableCopyNestedArray];
            [mutableResult replaceObjectAtIndex:i withObject:mutableItem];
        }
    }
    return mutableResult;
}

- (NSArray *)hd_filterWithBlock:(BOOL (^)(id))block {
    if (!block) {
        return self;
    }

    NSMutableArray *result = [[NSMutableArray alloc] init];
    for (NSInteger i = 0; i < self.count; i++) {
        id item = self[i];
        if (block(item)) {
            [result addObject:item];
        }
    }
    return [result copy];
}

- (NSArray *)hd_splitArrayWithEachCount:(NSUInteger)count {
    NSMutableArray *arrayOfArrays = [NSMutableArray array];
    NSUInteger countRemaining = self.count;
    int j = 0;
    while (countRemaining) {
        NSRange range = NSMakeRange(j, MIN(count, countRemaining));
        NSArray *subLogArr = [self subarrayWithRange:range];
        [arrayOfArrays addObject:subLogArr];
        countRemaining -= range.length;
        j += range.length;
    }
    return arrayOfArrays;
}
@end
