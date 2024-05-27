//
//  UIView+HD_Extension.h
//  HDKitCore
//
//  Created by VanJay on 2019/12/30.
//  Copyright © 2019 chaos network technology. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIView (HD_Extension)

+ (instancetype)viewFromXIB;

/**
 设置一个从左到右的渐变色

 @param fromColor 颜色
 @param toColor 渐变色
 */
- (void)setGradualChangingColorFromColor:(UIColor *)fromColor toColor:(UIColor *)toColor;

/**
 自定义渐变方向的渐变色

 @param fromColor 颜色
 @param toColor 渐变色
 @param endPoint 结束位置
 */
- (void)setGradualChangingColorFromColor:(UIColor *)fromColor toColor:(UIColor *)toColor endPoint:(CGPoint)endPoint;

/**
 自定义渐变方向的渐变色

 @param fromColor 颜色
 @param toColor 渐变色
 @param startPoint 开始位置 
 @param endPoint 结束位置
 */
- (void)setGradualChangingColorFromColor:(UIColor *)fromColor toColor:(UIColor *)toColor startPoint:(CGPoint)startPoint endPoint:(CGPoint)endPoint;

/**
 自定义渐变方向的渐变色

 @param colors 渐变色数组
 @param startPoint 开始位置
 @param endPoint 结束位置
 */
- (void)setGradualChangingColors:(NSArray<UIColor *> *)colors startPoint:(CGPoint)startPoint endPoint:(CGPoint)endPoint;

/**
 设置一个斜线渐变色

 @param fromColor 边缘色
 @param midColor 中间色
 */
- (void)setGradualDiagonalChangingColorFromColor:(UIColor *)fromColor middleColor:(UIColor *)midColor;

/**
 设置圆角

 @param coorners 圆角位置
 */
- (void)setCorner:(UIRectCorner)coorners;

/**
 设置圆角

 @param coorners 位置
 @param cornerRadii 大小
 */
- (void)setCorner:(UIRectCorner)coorners cornerRadii:(CGSize)cornerRadii;

/**
 画虚线

 @param lineLength 长度
 @param lineSpacing 间隔
 @param lineColor 颜色
 */
- (void)drawDashLineWithlineLength:(int)lineLength lineSpacing:(int)lineSpacing lineColor:(UIColor *)lineColor;

/**
 获取当前所在控制器
 */
- (UIViewController *)currentViewController;
@end

@interface UIView (SnapShot)

- (UIImage *)snapshotImage;

//iOS 7上UIView上提供了drawViewHierarchyInRect:afterScreenUpdates:来截图，速度比renderInContext:快15倍。
- (UIImage *)snapshotImageAfterScreenUpdates:(BOOL)afterUpdates;

/**
 移除所有子控件
 */
- (void)hd_removeAllSubviews;

/**
 获取所在控制器
 */
- (UIViewController *)viewController;

/**
 设置圆角

 @param corners 圆角位置
 @param radius 圆角半径
 */
- (CAShapeLayer *)setRoundedCorners:(UIRectCorner)corners radius:(CGFloat)radius;

/**
 设置圆角和边框

 @param corners 圆角位置
 @param radius 圆角半径
 @param borderWidth 边框大小
 @param borderColor 边框颜色
 */
- (CAShapeLayer *)setRoundedCorners:(UIRectCorner)corners radius:(CGFloat)radius borderWidth:(CGFloat)borderWidth borderColor:(UIColor *)borderColor;

/**
 设置圆角和边框

 @param corners 圆角位置
 @param radius 圆角半径
 @param borderWidth 边框大小
 @param borderColor 边框颜色
 @param layerIndex 图层位置
 */
- (CAShapeLayer *)setRoundedCorners:(UIRectCorner)corners radius:(CGFloat)radius borderWidth:(CGFloat)borderWidth borderColor:(UIColor *)borderColor layerIndex:(unsigned)layerIndex;

/**
 设置圆角阴影

 @param corners 圆角位置
 @param radius 圆角半径
 @param shadowRadius 阴影半径
 @param shadowOpacity 阴影透明度
 @param shadowColor 阴影颜色
 @param fillColor 填充颜色
 @param shadowOffset 阴影偏移
 @return 添加的图层
 */
- (CAShapeLayer *)setRoundedCorners:(UIRectCorner)corners radius:(CGFloat)radius shadowRadius:(CGFloat)shadowRadius shadowOpacity:(float)shadowOpacity shadowColor:(CGColorRef)shadowColor fillColor:(CGColorRef)fillColor shadowOffset:(CGSize)shadowOffset;

/**
 设置圆角阴影

 @param corners 圆角位置
 @param radius 圆角半径
 @param shadowRadius 阴影半径
 @param shadowOpacity 阴影透明度
 @param shadowColor 阴影颜色
 @param fillColor 填充颜色
 @param shadowOffset 阴影偏移
 @param layerIndex 图层位置
 @return 添加的图层
 */
- (CAShapeLayer *)setRoundedCorners:(UIRectCorner)corners radius:(CGFloat)radius shadowRadius:(CGFloat)shadowRadius shadowOpacity:(float)shadowOpacity shadowColor:(CGColorRef)shadowColor fillColor:(CGColorRef)fillColor shadowOffset:(CGSize)shadowOffset layerIndex:(unsigned)layerIndex;
@end
