//
//  NSMethodSignature+HD.h
//  HDKitCore
//
//  Created by VanJay on 2019/12/30.
//  Copyright © 2019 chaos network technology. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSMethodSignature (HDKitCore)

/**
 返回一个避免 crash 的方法签名，用于重写 methodSignatureForSelector: 时作为垫底的 return 方案
 */
@property (nullable, class, nonatomic, readonly) NSMethodSignature *hd_avoidExceptionSignature;

/**
 以 NSString 格式返回当前 NSMethodSignature 的 typeEncoding，例如 v@:
 */
@property (nullable, nonatomic, copy, readonly) NSString *hd_typeString;

/**
 以 const char 格式返回当前 NSMethodSignature 的 typeEncoding，例如 v@:
 */
@property (nullable, nonatomic, readonly) const char *hd_typeEncoding;

@end

NS_ASSUME_NONNULL_END
