//
//  NSData+HD_MD5.h
//  HDKitCore
//
//  Created by VanJay on 2017/9/20.
//  Copyright © 2017年 chaos network technology. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSData (HD_MD5)
/// 获取 md5 串
@property (nonatomic, copy, readonly) NSString *hd_md5;

@end

NS_ASSUME_NONNULL_END
