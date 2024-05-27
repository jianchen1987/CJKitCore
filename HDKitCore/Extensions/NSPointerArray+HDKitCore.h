//
//  NSObject+NSPointerArray+HD.h
//  HDKitCore
//
//  Created by VanJay on 2020/1/9.
//  Copyright © 2020 chaos network technology. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSPointerArray (HDKitCore)

- (NSUInteger)hd_indexOfPointer:(nullable void *)pointer;
- (BOOL)hd_containsPointer:(nullable void *)pointer;
@end
