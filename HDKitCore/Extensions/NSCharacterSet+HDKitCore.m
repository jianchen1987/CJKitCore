//
//  NSCharacterSet+HDKitCore.m
//  HDKitCore
//
//  Created by VanJay on 2019/9/5.
//  Copyright © 2019 chaos network technology. All rights reserved.
//

#import "NSCharacterSet+HDKitCore.h"

@implementation NSCharacterSet (HDKitCore)

+ (NSCharacterSet *)hd_URLUserInputQueryAllowedCharacterSet {
    NSMutableCharacterSet *set = [NSCharacterSet URLQueryAllowedCharacterSet].mutableCopy;
    [set removeCharactersInString:@"#&="];
    return set.copy;
}

@end
