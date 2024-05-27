//
//  UIView+HD_Extension.m
//  HDKitCore
//
//  Created by VanJay on 2019/12/30.
//  Copyright © 2019 chaos network technology. All rights reserved.
//

#import "UIView+HD_Extension.h"

@implementation UIView (HD_Extension)
+ (instancetype)viewFromXIB {
    return [[[NSBundle mainBundle] loadNibNamed:NSStringFromClass(self) owner:nil options:nil]
        lastObject];
}

- (void)setGradualDiagonalChangingColorFromColor:(UIColor *)fromColor middleColor:(UIColor *)midColor {
    //    CAGradientLayer类对其绘制渐变背景颜色、填充层的形状(包括圆角)
    CAGradientLayer *gradientLayer = [CAGradientLayer layer];
    gradientLayer.frame = self.bounds;

    //  创建渐变色数组，需要转换为CGColor颜色
    gradientLayer.colors = @[(__bridge id)fromColor.CGColor, (__bridge id)midColor.CGColor, (__bridge id)fromColor.CGColor];

    //  设置渐变颜色方向，左上点为(0,0), 右下点为(1,1)
    gradientLayer.startPoint = CGPointMake(0, 0);
    gradientLayer.endPoint = CGPointMake(1, 1);

    //  设置颜色变化点，取值范围 0.0~1.0
    gradientLayer.locations = @[@0, @0.5, @1];

    [self.layer addSublayer:gradientLayer];
}

- (void)setGradualChangingColorFromColor:(UIColor *)fromColor toColor:(UIColor *)toColor {
    [self setGradualChangingColorFromColor:fromColor toColor:toColor endPoint:CGPointMake(1, 0)];
}

- (void)setGradualChangingColorFromColor:(UIColor *)fromColor toColor:(UIColor *)toColor endPoint:(CGPoint)endPoint {
    [self setGradualChangingColorFromColor:fromColor toColor:toColor startPoint:CGPointMake(0, 0) endPoint:endPoint];
}

- (void)setGradualChangingColorFromColor:(UIColor *)fromColor toColor:(UIColor *)toColor startPoint:(CGPoint)startPoint endPoint:(CGPoint)endPoint {
    [self setGradualChangingColors:@[fromColor, toColor] startPoint:startPoint endPoint:endPoint];
}

- (void)setGradualChangingColors:(NSArray<UIColor *> *)colors startPoint:(CGPoint)startPoint endPoint:(CGPoint)endPoint {
    //    CAGradientLayer类对其绘制渐变背景颜色、填充层的形状(包括圆角)
    CAGradientLayer *gradientLayer = [CAGradientLayer layer];
    gradientLayer.frame = self.bounds;

    //  创建渐变色数组，需要转换为CGColor颜色
    NSMutableArray *cgColors = [NSMutableArray array];
    [colors enumerateObjectsUsingBlock:^(UIColor * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [cgColors addObject:(__bridge id)obj.CGColor];
    }];
    gradientLayer.colors = cgColors;

    //  设置渐变颜色方向，左上点为(0,0), 右下点为(1,1)
    gradientLayer.startPoint = startPoint;
    gradientLayer.endPoint = endPoint;

    //  设置颜色变化点，取值范围 0.0~1.0
    gradientLayer.locations = @[@0, @1];

    [self.layer insertSublayer:gradientLayer atIndex:0];
}

- (void)setCorner:(UIRectCorner)coorners {
    [self setCorner:coorners cornerRadii:CGSizeMake(5.f, 5.f)];
}

- (void)setCorner:(UIRectCorner)coorners cornerRadii:(CGSize)cornerRadii {
    UIBezierPath *maskPath;
    maskPath = [UIBezierPath bezierPathWithRoundedRect:self.bounds byRoundingCorners:coorners cornerRadii:cornerRadii];
    CAShapeLayer *maskLayer = [[CAShapeLayer alloc] init];
    maskLayer.frame = self.bounds;
    maskLayer.path = maskPath.CGPath;
    self.layer.mask = maskLayer;
}

- (void)drawDashLineWithlineLength:(int)lineLength lineSpacing:(int)lineSpacing lineColor:(UIColor *)lineColor {
    CAShapeLayer *shapeLayer = [CAShapeLayer layer];
    [shapeLayer setBounds:self.bounds];
    [shapeLayer setPosition:CGPointMake(CGRectGetWidth(self.frame) / 2, CGRectGetHeight(self.frame))];
    [shapeLayer setFillColor:[UIColor clearColor].CGColor];

    //  设置虚线颜色为
    [shapeLayer setStrokeColor:lineColor.CGColor];

    //  设置虚线宽度
    [shapeLayer setLineWidth:CGRectGetHeight(self.frame)];
    [shapeLayer setLineJoin:kCALineJoinRound];

    //  设置线宽，线间距
    [shapeLayer setLineDashPattern:[NSArray arrayWithObjects:[NSNumber numberWithInt:lineLength], [NSNumber numberWithInt:lineSpacing], nil]];

    //  设置路径
    CGMutablePathRef path = CGPathCreateMutable();
    CGPathMoveToPoint(path, NULL, 0, 0);
    CGPathAddLineToPoint(path, NULL, CGRectGetWidth(self.frame), 0);

    [shapeLayer setPath:path];
    CGPathRelease(path);

    //  把绘制好的虚线添加上来
    [self.layer addSublayer:shapeLayer];
}

- (UIViewController *)currentViewController {

    UIView *next = self;
    while ((next = [next superview])) {
        UIResponder *nextResponder = [next nextResponder];
        if ([nextResponder isKindOfClass:[UIViewController class]]) {
            return (UIViewController *)nextResponder;
        }
    }
    return nil;
}
@end

@implementation UIView (SnapShot)

- (UIImage *)snapshotImage {
    UIGraphicsBeginImageContextWithOptions(self.bounds.size, false, 0);
    [self.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *snap = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return snap;
}

// iOS 7上UIView上提供了drawViewHierarchyInRect:afterScreenUpdates:来截图，速度比renderInContext:快15倍。
- (UIImage *)snapshotImageAfterScreenUpdates:(BOOL)afterUpdates {
    if (![self respondsToSelector:@selector(drawViewHierarchyInRect:afterScreenUpdates:)]) {
        return [self snapshotImage];
    }
    UIGraphicsBeginImageContextWithOptions(self.bounds.size, false, 0);
    [self drawViewHierarchyInRect:self.bounds afterScreenUpdates:afterUpdates];
    UIImage *snap = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return snap;
}

- (void)hd_removeAllSubviews {
    while (self.subviews.count) {
        UIView *child = self.subviews.lastObject;
        [child removeFromSuperview];
    }
}

- (UIViewController *)viewController {
    UIView *next = self;
    while ((next = [next superview])) {
        UIResponder *nextResponder = [next nextResponder];
        if ([nextResponder isKindOfClass:[UIViewController class]]) {
            return (UIViewController *)nextResponder;
        }
    }
    return nil;
}

- (CAShapeLayer *)setRoundedCorners:(UIRectCorner)corners radius:(CGFloat)radius {
    CGRect rect = self.bounds;

    // Create the path
    UIBezierPath *maskPath = [UIBezierPath bezierPathWithRoundedRect:rect
                                                   byRoundingCorners:corners
                                                         cornerRadii:CGSizeMake(radius, radius)];

    // Create the shape layer and set its path
    CAShapeLayer *maskLayer = [CAShapeLayer layer];
    maskLayer.frame = rect;
    maskLayer.path = maskPath.CGPath;

    // Set the newly created shape layer as the mask for the view's layer
    self.layer.mask = maskLayer;
    return maskLayer;
}

- (CAShapeLayer *)setRoundedCorners:(UIRectCorner)corners radius:(CGFloat)radius borderWidth:(CGFloat)borderWidth borderColor:(UIColor *)borderColor {
    return [self setRoundedCorners:corners radius:radius borderWidth:borderWidth borderColor:borderColor layerIndex:0];
}

- (CAShapeLayer *)setRoundedCorners:(UIRectCorner)corners radius:(CGFloat)radius borderWidth:(CGFloat)borderWidth borderColor:(UIColor *)borderColor layerIndex:(unsigned)layerIndex {
    [self setRoundedCorners:corners radius:radius];

    CGRect rect = self.bounds;

    // Create the path
    UIBezierPath *maskPath = [UIBezierPath bezierPathWithRoundedRect:rect
                                                   byRoundingCorners:corners
                                                         cornerRadii:CGSizeMake(radius, radius)];

    CAShapeLayer *borderLayer = [CAShapeLayer layer];
    borderLayer.frame = rect;
    borderLayer.path = maskPath.CGPath;
    borderLayer.fillColor = [UIColor clearColor].CGColor;
    borderLayer.strokeColor = borderColor.CGColor;
    borderLayer.lineWidth = borderWidth;
    [self.layer insertSublayer:borderLayer atIndex:layerIndex];
    return borderLayer;
}

- (CAShapeLayer *)setRoundedCorners:(UIRectCorner)corners radius:(CGFloat)radius shadowRadius:(CGFloat)shadowRadius shadowOpacity:(float)shadowOpacity shadowColor:(CGColorRef)shadowColor fillColor:(CGColorRef)fillColor shadowOffset:(CGSize)shadowOffset {
    return [self setRoundedCorners:corners radius:radius shadowRadius:shadowRadius shadowOpacity:shadowOpacity shadowColor:shadowColor fillColor:fillColor shadowOffset:shadowOffset layerIndex:0];
}

- (CAShapeLayer *)setRoundedCorners:(UIRectCorner)corners radius:(CGFloat)radius shadowRadius:(CGFloat)shadowRadius shadowOpacity:(float)shadowOpacity shadowColor:(CGColorRef)shadowColor fillColor:(CGColorRef)fillColor shadowOffset:(CGSize)shadowOffset layerIndex:(unsigned)layerIndex {

    CGRect bounds = self.bounds;
    UIBezierPath *maskPath = [UIBezierPath bezierPathWithRoundedRect:bounds
                                                   byRoundingCorners:corners
                                                         cornerRadii:CGSizeMake(radius, radius)];

    CAShapeLayer *maskLayer = [CAShapeLayer layer];
    maskLayer.frame = bounds;
    maskLayer.path = maskPath.CGPath;
    maskLayer.shadowRadius = shadowRadius;
    maskLayer.shadowOpacity = shadowOpacity;
    maskLayer.shadowColor = shadowColor;
    maskLayer.fillColor = fillColor;
    maskLayer.shadowOffset = shadowOffset;
    [self.layer insertSublayer:maskLayer atIndex:layerIndex];
    return maskLayer;
}
@end
