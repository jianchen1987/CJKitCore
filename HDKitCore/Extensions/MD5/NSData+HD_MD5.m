//
//  NSData+HD_MD5.m
//  HDKitCore
//
//  Created by VanJay on 2017/9/20.
//  Copyright © 2017年 chaos network technology. All rights reserved.
//

#import "NSData+HD_MD5.h"
#import <CommonCrypto/CommonCrypto.h>

@implementation NSData (HD_MD5)

- (NSString *)hd_md5 {
    // 创建一个MD5对象
    CC_MD5_CTX md5;
    // 初始化MD5
    CC_MD5_Init(&md5);
    // 准备MD5加密
    CC_MD5_Update(&md5, self.bytes, (CC_LONG)self.length);
    // 准备一个字符串数组, 存储MD5加密之后的数据
    unsigned char result[CC_MD5_DIGEST_LENGTH];
    // 结束MD5加密
    CC_MD5_Final(result, &md5);
    NSMutableString *resultString = [NSMutableString string];
    // 从result数组中获取最终结果
    for (int i = 0; i < CC_MD5_DIGEST_LENGTH; i++) {
        [resultString appendFormat:@"%02X", result[i]];
    }
    return resultString;
}

@end
