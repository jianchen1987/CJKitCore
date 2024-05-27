//
//  NSObject+HDMultipleDelegates.h
//  HDKitCore
//
//  Created by VanJay on 2020/1/9.
//  Copyright © 2020 chaos network technology. All rights reserved.
//

#import "NSObject+HDMultipleDelegates.h"
#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

/// 存放多个 delegate 指针的容器，必须搭配其他控件使用，一般不需要你自己 init。作用是让某个 class 支持同时存在多个 delegate。更多说明请查看 NSObject (HDMultipleDelegates) 的注释。
@interface HDMultipleDelegates : NSObject

+ (instancetype)weakDelegates;
+ (instancetype)strongDelegates;

@property (nonatomic, strong, readonly) NSPointerArray *delegates;
@property (nonatomic, weak) NSObject *parentObject;

- (void)addDelegate:(id)delegate;
- (BOOL)removeDelegate:(id)delegate;
- (void)removeAllDelegates;
- (BOOL)containsDelegate:(id)delegate;
@end
