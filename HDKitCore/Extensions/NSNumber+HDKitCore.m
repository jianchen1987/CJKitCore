//
//  NSNumber+HDKitCore.m
//  HDKitCore
//
//  Created by VanJay on 2019/9/5.
//  Copyright © 2019 chaos network technology. All rights reserved.
//

#import "NSNumber+HDKitCore.h"

@implementation NSNumber (HDKitCore)
- (CGFloat)hd_CGFloatValue {
#if CGFLOAT_IS_DOUBLE
    return self.doubleValue;
#else
    return self.floatValue;
#endif
}
@end
