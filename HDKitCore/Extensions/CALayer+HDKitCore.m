//
//  CALayer+HD.m
//  HDKitCore
//
//  Created by VanJay on 2019/12/30.
//  Copyright © 2019 chaos network technology. All rights reserved.
//

#import "CALayer+HDKitCore.h"
#import "HDAssociatedObjectHelper.h"
#import "HDCommonDefines.h"
#import "HDLog.h"
#import "HDRunTime.h"
#import "NSObject+HDKitCore.h"
#import "UIColor+HDKitCore.h"
#import "UIView+HDKitCore.h"

@interface CALayer ()
@property (nonatomic, assign) float hd_speedBeforePause;
@end

@implementation CALayer (HDKitCore)

HDSynthesizeFloatProperty(hd_speedBeforePause, setHd_speedBeforePause);
HDSynthesizeCGFloatProperty(hd_originCornerRadius, setHd_originCornerRadius);

+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        // 由于其他方法需要通过调用 hdlayer_setCornerRadius: 来执行 swizzle 前的实现，所以这里暂时用 ExchangeImplementations
        ExchangeImplementations([CALayer class], @selector(setCornerRadius:), @selector(hdlayer_setCornerRadius:));

        ExtendImplementationOfNonVoidMethodWithoutArguments([CALayer class], @selector(init), CALayer *, ^CALayer *(CALayer *selfObject, CALayer *originReturnValue) {
            selfObject.hd_speedBeforePause = selfObject.speed;
            selfObject.hd_maskedCorners = HDLayerMinXMinYCorner | HDLayerMaxXMinYCorner | HDLayerMinXMaxYCorner | HDLayerMaxXMaxYCorner;
            return originReturnValue;
        });

        OverrideImplementation([CALayer class], @selector(setBounds:), ^id(__unsafe_unretained Class originClass, SEL originCMD, IMP (^originalIMPProvider)(void)) {
            return ^(CALayer *selfObject, CGRect bounds) {
                // 对非法的 bounds，Debug 下中 assert，Release 下会将其中的 NaN 改为 0，避免 crash
                if (CGRectIsNaN(bounds)) {
                    HDLogWarn(@"CALayer (HDKitCore)", @"%@ setBounds:%@，参数包含 NaN，已被拦截并处理为 0。%@", selfObject, NSStringFromCGRect(bounds), [NSThread callStackSymbols]);
                    NSAssert(NO, @"CALayer setBounds: 出现 NaN");
                    if (!IS_DEBUG) {
                        bounds = CGRectSafeValue(bounds);
                    }
                }

                // call super
                void (*originSelectorIMP)(id, SEL, CGRect);
                originSelectorIMP = (void (*)(id, SEL, CGRect))originalIMPProvider();
                originSelectorIMP(selfObject, originCMD, bounds);
            };
        });

        OverrideImplementation([CALayer class], @selector(setPosition:), ^id(__unsafe_unretained Class originClass, SEL originCMD, IMP (^originalIMPProvider)(void)) {
            return ^(CALayer *selfObject, CGPoint position) {
                // 对非法的 position，Debug 下中 assert，Release 下会将其中的 NaN 改为 0，避免 crash
                if (isnan(position.x) || isnan(position.y)) {
                    HDLogWarn(@"CALayer (HDKitCore)", @"%@ setPosition:%@，参数包含 NaN，已被拦截并处理为 0。%@", selfObject, NSStringFromCGPoint(position), [NSThread callStackSymbols]);
                    //if (HDCMIActivated && !ShouldPrintHDWarnLogToConsole) {
                    NSAssert(NO, @"CALayer setPosition: 出现 NaN");
                    //}
                    if (!IS_DEBUG) {
                        position = CGPointMake(CGFloatSafeValue(position.x), CGFloatSafeValue(position.y));
                    }
                }

                // call super
                void (*originSelectorIMP)(id, SEL, CGPoint);
                originSelectorIMP = (void (*)(id, SEL, CGPoint))originalIMPProvider();
                originSelectorIMP(selfObject, originCMD, position);
            };
        });
    });
}

- (BOOL)hd_isRootLayerOfView {
    return [self.delegate isKindOfClass:[UIView class]] && ((UIView *)self.delegate).layer == self;
}

- (void)hdlayer_setCornerRadius:(CGFloat)cornerRadius {
    BOOL cornerRadiusChanged = flat(self.hd_originCornerRadius) != flat(cornerRadius);  // flat 处理，避免浮点精度问题
    self.hd_originCornerRadius = cornerRadius;
    if (@available(iOS 11, *)) {
        [self hdlayer_setCornerRadius:cornerRadius];
    } else {
        if (self.hd_maskedCorners && ![self hasFourCornerRadius]) {
            [self hdlayer_setCornerRadius:0];
        } else {
            [self hdlayer_setCornerRadius:cornerRadius];
        }
        if (cornerRadiusChanged) {
            // 需要刷新mask
            [self setNeedsLayout];
        }
    }
    if (cornerRadiusChanged) {
        // 需要刷新border
        if ([self.delegate respondsToSelector:@selector(layoutSublayersOfLayer:)]) {
            UIView *view = (UIView *)self.delegate;
            if (view.hd_borderPosition > 0 && view.hd_borderWidth > 0) {
                [view layoutSublayersOfLayer:self];
            }
        }
    }
}

static char kAssociatedObjectKey_pause;
- (void)setHd_pause:(BOOL)hd_pause {
    if (hd_pause == self.hd_pause) {
        return;
    }
    if (hd_pause) {
        self.hd_speedBeforePause = self.speed;
        CFTimeInterval pausedTime = [self convertTime:CACurrentMediaTime() fromLayer:nil];
        self.speed = 0;
        self.timeOffset = pausedTime;
    } else {
        CFTimeInterval pausedTime = self.timeOffset;
        self.speed = self.hd_speedBeforePause;
        self.timeOffset = 0;
        self.beginTime = 0;
        CFTimeInterval timeSincePause = [self convertTime:CACurrentMediaTime() fromLayer:nil] - pausedTime;
        self.beginTime = timeSincePause;
    }
    objc_setAssociatedObject(self, &kAssociatedObjectKey_pause, @(hd_pause), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (BOOL)hd_pause {
    return [((NSNumber *)objc_getAssociatedObject(self, &kAssociatedObjectKey_pause)) boolValue];
}

static char kAssociatedObjectKey_maskedCorners;
- (void)setHd_maskedCorners:(HDCornerMask)hd_maskedCorners {
    BOOL maskedCornersChanged = hd_maskedCorners != self.hd_maskedCorners;
    objc_setAssociatedObject(self, &kAssociatedObjectKey_maskedCorners, @(hd_maskedCorners), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    if (@available(iOS 11, *)) {
        self.maskedCorners = (CACornerMask)hd_maskedCorners;
    } else {
        if (hd_maskedCorners && ![self hasFourCornerRadius]) {
            [self hdlayer_setCornerRadius:0];
        }
        if (maskedCornersChanged) {
            // 需要刷新mask
            if ([NSThread isMainThread]) {
                [self setNeedsLayout];
            } else {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self setNeedsLayout];
                });
            }
        }
    }
    if (maskedCornersChanged) {
        // 需要刷新border
        if ([self.delegate respondsToSelector:@selector(layoutSublayersOfLayer:)]) {
            UIView *view = (UIView *)self.delegate;
            if (view.hd_borderPosition > 0 && view.hd_borderWidth > 0) {
                [view layoutSublayersOfLayer:self];
            }
        }
    }
}

- (HDCornerMask)hd_maskedCorners {
    return [objc_getAssociatedObject(self, &kAssociatedObjectKey_maskedCorners) unsignedIntegerValue];
}

- (void)hd_sendSublayerToBack:(CALayer *)sublayer {
    if (sublayer.superlayer == self) {
        [sublayer removeFromSuperlayer];
        [self insertSublayer:sublayer atIndex:0];
    }
}

- (void)hd_bringSublayerToFront:(CALayer *)sublayer {
    if (sublayer.superlayer == self) {
        [sublayer removeFromSuperlayer];
        [self insertSublayer:sublayer atIndex:(unsigned)self.sublayers.count];
    }
}

// clang-format off
- (void)hd_removeDefaultAnimations {
    NSMutableDictionary<NSString *, id<CAAction>> *actions = @{ NSStringFromSelector(@selector(bounds)): [NSNull null],
                                                                NSStringFromSelector(@selector(position)): [NSNull null],
                                                                NSStringFromSelector(@selector(zPosition)): [NSNull null],
                                                                NSStringFromSelector(@selector(anchorPoint)): [NSNull null],
                                                                NSStringFromSelector(@selector(anchorPointZ)): [NSNull null],
                                                                NSStringFromSelector(@selector(transform)): [NSNull null],
                                                                BeginIgnoreClangWarning(-Wundeclared-selector)
                                                                    NSStringFromSelector(@selector(hidden)): [NSNull null],
                                                                NSStringFromSelector(@selector(doubleSided)): [NSNull null],
                                                                EndIgnoreClangWarning
                                                                    NSStringFromSelector(@selector(sublayerTransform)): [NSNull null],
                                                                NSStringFromSelector(@selector(masksToBounds)): [NSNull null],
                                                                NSStringFromSelector(@selector(contents)): [NSNull null],
                                                                NSStringFromSelector(@selector(contentsRect)): [NSNull null],
                                                                NSStringFromSelector(@selector(contentsScale)): [NSNull null],
                                                                NSStringFromSelector(@selector(contentsCenter)): [NSNull null],
                                                                NSStringFromSelector(@selector(minificationFilterBias)): [NSNull null],
                                                                NSStringFromSelector(@selector(backgroundColor)): [NSNull null],
                                                                NSStringFromSelector(@selector(cornerRadius)): [NSNull null],
                                                                NSStringFromSelector(@selector(borderWidth)): [NSNull null],
                                                                NSStringFromSelector(@selector(borderColor)): [NSNull null],
                                                                NSStringFromSelector(@selector(opacity)): [NSNull null],
                                                                NSStringFromSelector(@selector(compositingFilter)): [NSNull null],
                                                                NSStringFromSelector(@selector(filters)): [NSNull null],
                                                                NSStringFromSelector(@selector(backgroundFilters)): [NSNull null],
                                                                NSStringFromSelector(@selector(shouldRasterize)): [NSNull null],
                                                                NSStringFromSelector(@selector(rasterizationScale)): [NSNull null],
                                                                NSStringFromSelector(@selector(shadowColor)): [NSNull null],
                                                                NSStringFromSelector(@selector(shadowOpacity)): [NSNull null],
                                                                NSStringFromSelector(@selector(shadowOffset)): [NSNull null],
                                                                NSStringFromSelector(@selector(shadowRadius)): [NSNull null],
                                                                NSStringFromSelector(@selector(shadowPath)): [NSNull null] }
                                                                 .mutableCopy;

    if ([self isKindOfClass:[CAShapeLayer class]]) {
        [actions addEntriesFromDictionary:@{ NSStringFromSelector(@selector(path)): [NSNull null],
                                             NSStringFromSelector(@selector(fillColor)): [NSNull null],
                                             NSStringFromSelector(@selector(strokeColor)): [NSNull null],
                                             NSStringFromSelector(@selector(strokeStart)): [NSNull null],
                                             NSStringFromSelector(@selector(strokeEnd)): [NSNull null],
                                             NSStringFromSelector(@selector(lineWidth)): [NSNull null],
                                             NSStringFromSelector(@selector(miterLimit)): [NSNull null],
                                             NSStringFromSelector(@selector(lineDashPhase)): [NSNull null] }];
    }

    if ([self isKindOfClass:[CAGradientLayer class]]) {
        [actions addEntriesFromDictionary:@{ NSStringFromSelector(@selector(colors)): [NSNull null],
                                             NSStringFromSelector(@selector(locations)): [NSNull null],
                                             NSStringFromSelector(@selector(startPoint)): [NSNull null],
                                             NSStringFromSelector(@selector(endPoint)): [NSNull null] }];
    }

    self.actions = actions;
}
// clang-format on

+ (void)hd_performWithoutAnimation:(void(NS_NOESCAPE ^)(void))actionsWithoutAnimation {
    if (!actionsWithoutAnimation) return;
    [CATransaction begin];
    [CATransaction setDisableActions:YES];
    actionsWithoutAnimation();
    [CATransaction commit];
}

+ (CAShapeLayer *)hd_separatorDashLayerWithLineLength:(NSInteger)lineLength
                                          lineSpacing:(NSInteger)lineSpacing
                                            lineWidth:(CGFloat)lineWidth
                                            lineColor:(CGColorRef)lineColor
                                         isHorizontal:(BOOL)isHorizontal {
    CAShapeLayer *layer = [CAShapeLayer layer];
    layer.fillColor = UIColor.clearColor.CGColor;
    layer.strokeColor = lineColor;
    layer.lineWidth = lineWidth;
    layer.lineDashPattern = [NSArray arrayWithObjects:[NSNumber numberWithInteger:lineLength], [NSNumber numberWithInteger:lineSpacing], nil];
    layer.masksToBounds = YES;

    CGMutablePathRef path = CGPathCreateMutable();
    if (isHorizontal) {
        CGPathMoveToPoint(path, NULL, 0, lineWidth / 2);
        CGPathAddLineToPoint(path, NULL, kScreenWidth, lineWidth / 2);
    } else {
        CGPathMoveToPoint(path, NULL, lineWidth / 2, 0);
        CGPathAddLineToPoint(path, NULL, lineWidth / 2, kScreenHeight);
    }
    layer.path = path;
    CGPathRelease(path);

    return layer;
}

+ (CAShapeLayer *)hd_separatorDashLayerInHorizontal {
    CAShapeLayer *layer = [CAShapeLayer hd_separatorDashLayerWithLineLength:2 lineSpacing:2 lineWidth:PixelOne lineColor:HDColor(222, 224, 226, 1).CGColor isHorizontal:YES];
    return layer;
}

+ (CAShapeLayer *)hd_separatorDashLayerInVertical {
    CAShapeLayer *layer = [CAShapeLayer hd_separatorDashLayerWithLineLength:2 lineSpacing:2 lineWidth:PixelOne lineColor:HDColor(222, 224, 226, 1).CGColor isHorizontal:NO];
    return layer;
}

+ (CALayer *)hd_separatorLayer {
    CALayer *layer = [CALayer layer];
    [layer hd_removeDefaultAnimations];
    layer.backgroundColor = HDColor(222, 224, 226, 1).CGColor;
    layer.frame = CGRectMake(0, 0, 0, PixelOne);
    return layer;
}

+ (CALayer *)hd_separatorLayerForTableView {
    CALayer *layer = [self hd_separatorLayer];
    layer.backgroundColor = HDColor(222, 224, 226, 1).CGColor;
    return layer;
}

- (BOOL)hasFourCornerRadius {
    return (self.hd_maskedCorners & HDLayerMinXMinYCorner) == HDLayerMinXMinYCorner &&
        (self.hd_maskedCorners & HDLayerMaxXMinYCorner) == HDLayerMaxXMinYCorner &&
        (self.hd_maskedCorners & HDLayerMinXMaxYCorner) == HDLayerMinXMaxYCorner &&
        (self.hd_maskedCorners & HDLayerMaxXMaxYCorner) == HDLayerMaxXMaxYCorner;
}

@end

@implementation UIView (HD_CornerRadius)

static NSString *kMaskName = @"HD_CornerRadius_Mask";

+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        ExtendImplementationOfVoidMethodWithSingleArgument([UIView class], @selector(layoutSublayersOfLayer:), CALayer *, ^(UIView *selfObject, CALayer *layer) {
            if (@available(iOS 11, *)) {
            } else {
                if (selfObject.layer.mask && ![selfObject.layer.mask.name isEqualToString:kMaskName]) {
                    return;
                }
                if (selfObject.layer.hd_maskedCorners) {
                    if (selfObject.layer.hd_originCornerRadius <= 0 || [selfObject hasFourCornerRadius]) {
                        if (selfObject.layer.mask) {
                            selfObject.layer.mask = nil;
                        }
                    } else {
                        CAShapeLayer *cornerMaskLayer = [CAShapeLayer layer];
                        cornerMaskLayer.name = kMaskName;
                        UIRectCorner rectCorner = 0;
                        if ((selfObject.layer.hd_maskedCorners & HDLayerMinXMinYCorner) == HDLayerMinXMinYCorner) {
                            rectCorner |= UIRectCornerTopLeft;
                        }
                        if ((selfObject.layer.hd_maskedCorners & HDLayerMaxXMinYCorner) == HDLayerMaxXMinYCorner) {
                            rectCorner |= UIRectCornerTopRight;
                        }
                        if ((selfObject.layer.hd_maskedCorners & HDLayerMinXMaxYCorner) == HDLayerMinXMaxYCorner) {
                            rectCorner |= UIRectCornerBottomLeft;
                        }
                        if ((selfObject.layer.hd_maskedCorners & HDLayerMaxXMaxYCorner) == HDLayerMaxXMaxYCorner) {
                            rectCorner |= UIRectCornerBottomRight;
                        }
                        UIBezierPath *path = [UIBezierPath bezierPathWithRoundedRect:selfObject.bounds byRoundingCorners:rectCorner cornerRadii:CGSizeMake(selfObject.layer.hd_originCornerRadius, selfObject.layer.hd_originCornerRadius)];
                        cornerMaskLayer.frame = CGRectMakeWithSize(selfObject.bounds.size);
                        cornerMaskLayer.path = path.CGPath;
                        selfObject.layer.mask = cornerMaskLayer;
                    }
                }
            }
        });
    });
}

- (BOOL)hasFourCornerRadius {
    return (self.layer.hd_maskedCorners & HDLayerMinXMinYCorner) == HDLayerMinXMinYCorner &&
        (self.layer.hd_maskedCorners & HDLayerMaxXMinYCorner) == HDLayerMaxXMinYCorner &&
        (self.layer.hd_maskedCorners & HDLayerMinXMaxYCorner) == HDLayerMinXMaxYCorner &&
        (self.layer.hd_maskedCorners & HDLayerMaxXMaxYCorner) == HDLayerMaxXMaxYCorner;
}

@end

@interface CAShapeLayer (HD_DynamicColor)

@property (nonatomic, strong) UIColor *qcl_originalFillColor;
@property (nonatomic, strong) UIColor *qcl_originalStrokeColor;

@end

@implementation CAShapeLayer (HD_DynamicColor)

HDSynthesizeIdStrongProperty(qcl_originalFillColor, setQcl_originalFillColor)
    HDSynthesizeIdStrongProperty(qcl_originalStrokeColor, setQcl_originalStrokeColor);

+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        OverrideImplementation([CAShapeLayer class], @selector(setFillColor:), ^id(__unsafe_unretained Class originClass, SEL originCMD, IMP (^originalIMPProvider)(void)) {
            return ^(CAShapeLayer *selfObject, CGColorRef color) {
                UIColor *originalColor = [(__bridge id)(color) hd_getBoundObjectForKey:HDCGColorOriginalColorBindKey];
                selfObject.qcl_originalFillColor = originalColor;

                // call super
                void (*originSelectorIMP)(id, SEL, CGColorRef);
                originSelectorIMP = (void (*)(id, SEL, CGColorRef))originalIMPProvider();
                originSelectorIMP(selfObject, originCMD, color);
            };
        });

        OverrideImplementation([CAShapeLayer class], @selector(setStrokeColor:), ^id(__unsafe_unretained Class originClass, SEL originCMD, IMP (^originalIMPProvider)(void)) {
            return ^(CAShapeLayer *selfObject, CGColorRef color) {
                UIColor *originalColor = [(__bridge id)(color) hd_getBoundObjectForKey:HDCGColorOriginalColorBindKey];
                selfObject.qcl_originalStrokeColor = originalColor;

                // call super
                void (*originSelectorIMP)(id, SEL, CGColorRef);
                originSelectorIMP = (void (*)(id, SEL, CGColorRef))originalIMPProvider();
                originSelectorIMP(selfObject, originCMD, color);
            };
        });
    });
}

- (void)hd_setNeedsUpdateDynamicStyle {
    [super hd_setNeedsUpdateDynamicStyle];

    if (self.qcl_originalFillColor) {
        self.fillColor = self.qcl_originalFillColor.CGColor;
    }

    if (self.qcl_originalStrokeColor) {
        self.strokeColor = self.qcl_originalStrokeColor.CGColor;
    }
}

@end

@interface CAGradientLayer (HD_DynamicColor)

@property (nonatomic, strong) NSArray<UIColor *> *qcl_originalColors;

@end

@implementation CAGradientLayer (HD_DynamicColor)

HDSynthesizeIdStrongProperty(qcl_originalColors, setQcl_originalColors);

+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        OverrideImplementation([CAGradientLayer class], @selector(setColors:), ^id(__unsafe_unretained Class originClass, SEL originCMD, IMP (^originalIMPProvider)(void)) {
            return ^(CAGradientLayer *selfObject, NSArray *colors) {
                void (*originSelectorIMP)(id, SEL, NSArray *);
                originSelectorIMP = (void (*)(id, SEL, NSArray *))originalIMPProvider();
                originSelectorIMP(selfObject, originCMD, colors);

                __block BOOL hasDynamicColor = NO;
                NSMutableArray *originalColors = [NSMutableArray array];
                [colors enumerateObjectsUsingBlock:^(id color, NSUInteger idx, BOOL *_Nonnull stop) {
                    UIColor *originalColor = [color hd_getBoundObjectForKey:HDCGColorOriginalColorBindKey];
                    if (originalColor) {
                        hasDynamicColor = YES;
                        [originalColors addObject:originalColor];
                    } else {
                        [originalColors addObject:[UIColor colorWithCGColor:(__bridge CGColorRef _Nonnull)(color)]];
                    }
                }];

                if (hasDynamicColor) {
                    selfObject.qcl_originalColors = originalColors;
                } else {
                    selfObject.qcl_originalColors = nil;
                }
            };
        });
    });
}

- (void)hd_setNeedsUpdateDynamicStyle {
    [super hd_setNeedsUpdateDynamicStyle];

    if (self.qcl_originalColors) {
        NSMutableArray *colors = [NSMutableArray array];
        [self.qcl_originalColors enumerateObjectsUsingBlock:^(UIColor *_Nonnull color, NSUInteger idx, BOOL *_Nonnull stop) {
            [colors addObject:(__bridge id _Nonnull)(color.CGColor)];
        }];
        self.colors = colors;
    }
}

@end
