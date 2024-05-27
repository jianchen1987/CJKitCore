//
//  UIButton+EnlargeEdge.h
//  HDKitCore
//
//  Created by VanJay on 2017/8/4.
//  Copyright © 2017年 chaos network technology. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIButton (EnlargeEdge)
/**
*
*  同时向按钮的四个方向延伸响应面积
*
*  @param size 间距
*/
- (void)setEnlargeEdge:(CGFloat)size;

/**
 *  @author hj, 06.27 2016 20:06
 *
 *  向按钮的四个方向延伸响应面积
 *
 *  @param top    上间距
 *  @param left   左间距
 *  @param bottom 下间距
 *  @param right  右间距
 */
- (void)setEnlargeEdgeWithTop:(CGFloat)top left:(CGFloat)left bottom:(CGFloat)bottom right:(CGFloat)right;

@end
