//
//  NSData+HD_AES.h
//  HDKitCore
//
//  Created by VanJay on 2020/3/24.
//  Copyright © 2020 chaos network technology. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSData (HD_AES)

/// AES128 加密
/// @param key 要加密的字符串
/// @param iv 初始向量

- (NSData *)hd_AES128CBCEncryptWithKey:(NSString *)key iv:(NSString *)iv;

/// AES128 解密
/// @param key 要解密的字符串
/// @param iv 初始向量
- (NSData *)hd_AES128CBCDecryptWithKey:(NSString *)key iv:(NSString *)iv;

/// AES256加密，ECB模式，填充方式PaddingMode.Zeros，初始向量不用填
/// @param key 要加密的字符串
- (NSData *)hd_AES256ECBEncryptWithKey:(NSString *)key;

/// AES256解密，ECB模式，填充方式PaddingMode.Zeros，初始向量不用填
/// @param key 要解密密的字符串
- (NSData *)hd_AES256ECBDecryptWithKey:(NSString *)key;

@end

NS_ASSUME_NONNULL_END
