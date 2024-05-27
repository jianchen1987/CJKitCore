//
//  NSString+HD_Size.m
//  HDKitCore
//
//  Created by VanJay on 2019/12/30.
//  Copyright © 2019 chaos network technology. All rights reserved.
//

#import "NSString+HD_Size.h"

@implementation NSString (HD_Size)

- (CGSize)boundingAllRectWithSize:(CGSize)size font:(UIFont *)font {
    return [self boundingAllRectWithSize:size font:font lineSpacing:2];
}

- (CGSize)boundingAllRectWithSize:(CGSize)size font:(UIFont *)font lineSpacing:(CGFloat)lineSpacing {
    NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc] init];
    style.lineSpacing = lineSpacing;

    CGSize realSize = CGSizeZero;
    CGRect textRect = [self boundingRectWithSize:size
                                         options:NSStringDrawingUsesLineFragmentOrigin
                                      attributes:@{NSFontAttributeName: font,
                                                   NSParagraphStyleAttributeName: style}
                                         context:nil];
    realSize = textRect.size;
    realSize.width = ceilf(realSize.width);
    realSize.height = ceilf(realSize.height);
    return realSize;
}

@end
