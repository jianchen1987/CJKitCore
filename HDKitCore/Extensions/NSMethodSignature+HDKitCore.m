//
//  NSMethodSignature+HD.m
//  HDKitCore
//
//  Created by VanJay on 2019/12/30.
//  Copyright © 2019 chaos network technology. All rights reserved.
//

#import "NSMethodSignature+HDKitCore.h"

@implementation NSMethodSignature (HDKitCore)

+ (NSMethodSignature *)hd_avoidExceptionSignature {
    return [NSMethodSignature signatureWithObjCTypes:"@^v^c"];
}

- (NSString *)hd_typeString {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
    NSString *typeString = [self performSelector:NSSelectorFromString([NSString stringWithFormat:@"_%@String", @"type"])];
#pragma clang diagnostic pop
    return typeString;
}

- (const char *)hd_typeEncoding {
    return self.hd_typeString.UTF8String;
}

@end
