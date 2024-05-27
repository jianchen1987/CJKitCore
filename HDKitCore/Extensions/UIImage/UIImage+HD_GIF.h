//
//  UIImage+HD_GIF.h
//  HDKitCore
//
//  Created by VanJay on 2020/2/26.
//  Copyright © 2019 chaos network technology. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIImage (HD_GIF)

/// 从二进制加载 gif 图片
/// @param theData 二进制数据
+ (UIImage *_Nullable)animatedImageWithAnimatedGIFData:(NSData *_Nonnull)theData;

/// 从 url 加载 gif 图片
/// @param theURL url
+ (UIImage *_Nullable)animatedImageWithAnimatedGIFURL:(NSURL *_Nonnull)theURL;
@end

NS_ASSUME_NONNULL_END
