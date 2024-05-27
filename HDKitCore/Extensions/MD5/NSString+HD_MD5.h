//
//  NSString+HD_MD5.h
//  HDKitCore
//
//  Created by VanJay on 2017/9/20.
//  Copyright © 2017年 chaos network technology. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSString (HD_MD5)
/// 获取 md5 串
@property (nonatomic, copy, readonly) NSString *hd_md5;
/// 获取 MD5 串
@property (nonatomic, copy, readonly) NSString *hd_MD5;
/// 获取 md5 16位串
@property (nonatomic, copy, readonly) NSString *hd_md5_16;

/// 获取文件 md5
/// @param filePath 文件路径
+ (NSString *)hd_fileMD5FilePath:(NSString *)filePath;

/// 文件名 md5 hash
/// @param fileName 文件名
+ (NSString *)hd_MD5HashFileName:(NSString *)fileName;
- (NSString *)hd_encodeWithMD5:(NSString *)key;
- (NSString *)hd_encodeMD5WithKey:(NSString *)key;
@end

NS_ASSUME_NONNULL_END
