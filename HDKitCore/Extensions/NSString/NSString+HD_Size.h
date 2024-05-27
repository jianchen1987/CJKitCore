//
//  NSString+HD_Size.h
//  HDKitCore
//
//  Created by VanJay on 2019/12/30.
//  Copyright © 2019 chaos network technology. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface NSString (HD_Size)

/// 计算字符串大小
/// @param size 限制尺寸
/// @param font 字体
- (CGSize)boundingAllRectWithSize:(CGSize)size font:(UIFont *)font;

/// 计算字符串大小
/// @param size 限制尺寸
/// @param font 字体
/// @param lineSpacing 行距
- (CGSize)boundingAllRectWithSize:(CGSize)size font:(UIFont *)font lineSpacing:(CGFloat)lineSpacing;
@end
