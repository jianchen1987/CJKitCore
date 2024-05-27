//
//  UIView+HD.m
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
#import "HDWeakObjectContainer.h"
#import "NSObject+HDKitCore.h"
#import "UIColor+HDKitCore.h"
#import "UIImage+HDKitCore.h"
#import "UIView+HDKitCore.h"
#import "UIViewController+HDKitCore.h"

@interface UIView ()

/// HD_Debug
@property (nonatomic, assign, readwrite) BOOL hd_hasDebugColor;

/// HD_Border
@property (nonatomic, strong, readwrite) CAShapeLayer *hd_borderLayer;

@end

@implementation UIView (HDKitCore)

HDSynthesizeBOOLProperty(hd_tintColorCustomized, setHd_tintColorCustomized);
HDSynthesizeIdCopyProperty(hd_frameWillChangeBlock, setHd_frameWillChangeBlock);
HDSynthesizeIdCopyProperty(hd_frameDidChangeBlock, setHd_frameDidChangeBlock);
HDSynthesizeIdCopyProperty(hd_tintColorDidChangeBlock, setHd_tintColorDidChangeBlock);
HDSynthesizeIdCopyProperty(hd_hitTestBlock, setHd_hitTestBlock);

+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        ExtendImplementationOfVoidMethodWithSingleArgument([UIView class], @selector(setTintColor:), UIColor *, ^(UIView *selfObject, UIColor *tintColor) {
            selfObject.hd_tintColorCustomized = !!tintColor;
        });

        ExtendImplementationOfVoidMethodWithoutArguments([UIView class], @selector(tintColorDidChange), ^(UIView *selfObject) {
            if (selfObject.hd_tintColorDidChangeBlock) {
                selfObject.hd_tintColorDidChangeBlock(selfObject);
            }
        });

        ExtendImplementationOfNonVoidMethodWithTwoArguments([UIView class], @selector(hitTest:withEvent:), CGPoint, UIEvent *, UIView *, ^UIView *(UIView *selfObject, CGPoint point, UIEvent *event, UIView *originReturnValue) {
            if (selfObject.hd_hitTestBlock) {
                UIView *view = selfObject.hd_hitTestBlock(point, event, originReturnValue);
                return view;
            }
            return originReturnValue;
        });

        // 这个私有方法在 view 被调用 becomeFirstResponder 并且处于 window 上时，才会被调用，所以比 becomeFirstResponder 更适合用来检测
        ExtendImplementationOfVoidMethodWithSingleArgument([UIView class], NSSelectorFromString(@"_didChangeToFirstResponder:"), id, ^(UIView *selfObject, id firstArgv) {
            if (selfObject == firstArgv && [selfObject conformsToProtocol:@protocol(UITextInput)]) {
                // 像 HDModalPresentationViewController 那种以 window 的形式展示浮层，浮层里的输入框 becomeFirstResponder 的场景，[window makeKeyAndVisible] 被调用后，就会立即走到这里，但此时该 window 尚不是 keyWindow，所以这里延迟到下一个 runloop 里再去判断
                dispatch_async(dispatch_get_main_queue(), ^{
                    if (IS_DEBUG && ![selfObject isKindOfClass:[UIWindow class]] && selfObject.window && !selfObject.window.keyWindow) {
                        [selfObject HDSymbolicUIViewBecomeFirstResponderWithoutKeyWindow];
                    }
                });
            }
        });

        OverrideImplementation([UIView class], @selector(addSubview:), ^id(__unsafe_unretained Class originClass, SEL originCMD, IMP (^originalIMPProvider)(void)) {
            return ^(UIView *selfObject, UIView *view) {
                if (view == selfObject) {
                    [selfObject printLogForAddSubviewToSelf];
                    return;
                }

                // call super
                void (*originSelectorIMP)(id, SEL, UIView *);
                originSelectorIMP = (void (*)(id, SEL, UIView *))originalIMPProvider();
                originSelectorIMP(selfObject, originCMD, view);
            };
        });

        OverrideImplementation([UIView class], @selector(insertSubview:atIndex:), ^id(__unsafe_unretained Class originClass, SEL originCMD, IMP (^originalIMPProvider)(void)) {
            return ^(UIView *selfObject, UIView *view, NSInteger index) {
                if (view == selfObject) {
                    [selfObject printLogForAddSubviewToSelf];
                    return;
                }

                // call super
                void (*originSelectorIMP)(id, SEL, UIView *, NSInteger);
                originSelectorIMP = (void (*)(id, SEL, UIView *, NSInteger))originalIMPProvider();
                originSelectorIMP(selfObject, originCMD, view, index);
            };
        });

        OverrideImplementation([UIView class], @selector(insertSubview:aboveSubview:), ^id(__unsafe_unretained Class originClass, SEL originCMD, IMP (^originalIMPProvider)(void)) {
            return ^(UIView *selfObject, UIView *view, UIView *siblingSubview) {
                if (view == self) {
                    [selfObject printLogForAddSubviewToSelf];
                    return;
                }

                // call super
                void (*originSelectorIMP)(id, SEL, UIView *, UIView *);
                originSelectorIMP = (void (*)(id, SEL, UIView *, UIView *))originalIMPProvider();
                originSelectorIMP(selfObject, originCMD, view, siblingSubview);
            };
        });

        OverrideImplementation([UIView class], @selector(insertSubview:belowSubview:), ^id(__unsafe_unretained Class originClass, SEL originCMD, IMP (^originalIMPProvider)(void)) {
            return ^(UIView *selfObject, UIView *view, UIView *siblingSubview) {
                if (view == self) {
                    [selfObject printLogForAddSubviewToSelf];
                    return;
                }

                // call super
                void (*originSelectorIMP)(id, SEL, UIView *, UIView *);
                originSelectorIMP = (void (*)(id, SEL, UIView *, UIView *))originalIMPProvider();
                originSelectorIMP(selfObject, originCMD, view, siblingSubview);
            };
        });

        OverrideImplementation([UIView class], @selector(convertPoint:toView:), ^id(__unsafe_unretained Class originClass, SEL originCMD, IMP (^originalIMPProvider)(void)) {
            return ^CGPoint(UIView *selfObject, CGPoint point, UIView *view) {
                [selfObject alertConvertValueWithView:view];

                // call super
                CGPoint (*originSelectorIMP)(id, SEL, CGPoint, UIView *);
                originSelectorIMP = (CGPoint(*)(id, SEL, CGPoint, UIView *))originalIMPProvider();
                CGPoint result = originSelectorIMP(selfObject, originCMD, point, view);

                return result;
            };
        });

        OverrideImplementation([UIView class], @selector(convertPoint:fromView:), ^id(__unsafe_unretained Class originClass, SEL originCMD, IMP (^originalIMPProvider)(void)) {
            return ^CGPoint(UIView *selfObject, CGPoint point, UIView *view) {
                [selfObject alertConvertValueWithView:view];

                // call super
                CGPoint (*originSelectorIMP)(id, SEL, CGPoint, UIView *);
                originSelectorIMP = (CGPoint(*)(id, SEL, CGPoint, UIView *))originalIMPProvider();
                CGPoint result = originSelectorIMP(selfObject, originCMD, point, view);

                return result;
            };
        });

        OverrideImplementation([UIView class], @selector(convertRect:toView:), ^id(__unsafe_unretained Class originClass, SEL originCMD, IMP (^originalIMPProvider)(void)) {
            return ^CGRect(UIView *selfObject, CGRect rect, UIView *view) {
                [selfObject alertConvertValueWithView:view];

                // call super
                CGRect (*originSelectorIMP)(id, SEL, CGRect, UIView *);
                originSelectorIMP = (CGRect(*)(id, SEL, CGRect, UIView *))originalIMPProvider();
                CGRect result = originSelectorIMP(selfObject, originCMD, rect, view);

                return result;
            };
        });

        OverrideImplementation([UIView class], @selector(convertRect:fromView:), ^id(__unsafe_unretained Class originClass, SEL originCMD, IMP (^originalIMPProvider)(void)) {
            return ^CGRect(UIView *selfObject, CGRect rect, UIView *view) {
                [selfObject alertConvertValueWithView:view];

                // call super
                CGRect (*originSelectorIMP)(id, SEL, CGRect, UIView *);
                originSelectorIMP = (CGRect(*)(id, SEL, CGRect, UIView *))originalIMPProvider();
                CGRect result = originSelectorIMP(selfObject, originCMD, rect, view);

                return result;
            };
        });
    });
}

- (instancetype)hd_initWithSize:(CGSize)size {
    return [self initWithFrame:CGRectMakeWithSize(size)];
}

- (void)setHd_frameApplyTransform:(CGRect)hd_frameApplyTransform {
    self.frame = CGRectApplyAffineTransformWithAnchorPoint(hd_frameApplyTransform, self.transform, self.layer.anchorPoint);
}

- (CGRect)hd_frameApplyTransform {
    return self.frame;
}

- (UIEdgeInsets)hd_safeAreaInsets {
    if (@available(iOS 11.0, *)) {
        return self.safeAreaInsets;
    }
    return UIEdgeInsetsZero;
}

- (void)hd_removeAllSubviews {
    [self.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
}

- (CGPoint)hd_convertPoint:(CGPoint)point toView:(nullable UIView *)view {
    if (view) {
        return [view hd_convertPoint:point fromView:view];
    }
    return [self convertPoint:point toView:view];
}

- (CGPoint)hd_convertPoint:(CGPoint)point fromView:(nullable UIView *)view {
    UIWindow *selfWindow = [self isKindOfClass:[UIWindow class]] ? (UIWindow *)self : self.window;
    UIWindow *fromWindow = [view isKindOfClass:[UIWindow class]] ? (UIWindow *)view : view.window;
    if (selfWindow && fromWindow && selfWindow != fromWindow) {
        CGPoint pointInFromWindow = fromWindow == view ? point : [view convertPoint:point toView:nil];
        CGPoint pointInSelfWindow = [selfWindow convertPoint:pointInFromWindow fromWindow:fromWindow];
        CGPoint pointInSelf = selfWindow == self ? pointInSelfWindow : [self convertPoint:pointInSelfWindow fromView:nil];
        return pointInSelf;
    }
    return [self convertPoint:point fromView:view];
}

- (CGRect)hd_convertRect:(CGRect)rect toView:(nullable UIView *)view {
    if (view) {
        return [view hd_convertRect:rect fromView:self];
    }
    return [self convertRect:rect toView:view];
}

- (CGRect)hd_convertRect:(CGRect)rect fromView:(nullable UIView *)view {
    UIWindow *selfWindow = [self isKindOfClass:[UIWindow class]] ? (UIWindow *)self : self.window;
    UIWindow *fromWindow = [view isKindOfClass:[UIWindow class]] ? (UIWindow *)view : view.window;
    if (selfWindow && fromWindow && selfWindow != fromWindow) {
        CGRect rectInFromWindow = fromWindow == view ? rect : [view convertRect:rect toView:nil];
        CGRect rectInSelfWindow = [selfWindow convertRect:rectInFromWindow fromWindow:fromWindow];
        CGRect rectInSelf = selfWindow == self ? rectInSelfWindow : [self convertRect:rectInSelfWindow fromView:nil];
        return rectInSelf;
    }
    return [self convertRect:rect fromView:view];
}

+ (void)hd_animateWithAnimated:(BOOL)animated duration:(NSTimeInterval)duration delay:(NSTimeInterval)delay options:(UIViewAnimationOptions)options animations:(void (^)(void))animations completion:(void (^__nullable)(BOOL finished))completion {
    if (animated) {
        [UIView animateWithDuration:duration delay:delay options:options animations:animations completion:completion];
    } else {
        if (animations) {
            animations();
        }
        if (completion) {
            completion(YES);
        }
    }
}

+ (void)hd_animateWithAnimated:(BOOL)animated duration:(NSTimeInterval)duration animations:(void (^__nullable)(void))animations completion:(void (^)(BOOL finished))completion {
    if (animated) {
        [UIView animateWithDuration:duration animations:animations completion:completion];
    } else {
        if (animations) {
            animations();
        }
        if (completion) {
            completion(YES);
        }
    }
}

+ (void)hd_animateWithAnimated:(BOOL)animated duration:(NSTimeInterval)duration animations:(void (^__nullable)(void))animations {
    if (animated) {
        [UIView animateWithDuration:duration animations:animations];
    } else {
        if (animations) {
            animations();
        }
    }
}

+ (void)hd_animateWithAnimated:(BOOL)animated duration:(NSTimeInterval)duration delay:(NSTimeInterval)delay usingSpringWithDamping:(CGFloat)dampingRatio initialSpringVelocity:(CGFloat)velocity options:(UIViewAnimationOptions)options animations:(void (^)(void))animations completion:(void (^)(BOOL finished))completion {
    if (animated) {
        [UIView animateWithDuration:duration delay:delay usingSpringWithDamping:dampingRatio initialSpringVelocity:velocity options:options animations:animations completion:completion];
    } else {
        if (animations) {
            animations();
        }
        if (completion) {
            completion(YES);
        }
    }
}

- (void)printLogForAddSubviewToSelf {
    UIViewController *visibleViewController = [HDHelper visibleViewController];
    NSString *log = [NSString stringWithFormat:@"UIView (HDKitCore) addSubview:, 把自己作为 subview 添加到自己身上，self = %@, visibleViewController = %@, visibleState = %@, viewControllers = %@\n%@", self, visibleViewController, @(visibleViewController.hd_visibleState), visibleViewController.navigationController.viewControllers, [NSThread callStackSymbols]];
    NSAssert(NO, log);
    HDLogWarn(@"UIView (HDKitCore)", @"%@", log);
}

- (void)HDSymbolicUIViewBecomeFirstResponderWithoutKeyWindow {
    HDLogWarn(@"UIView (HDKitCore)", @"尝试让一个处于非 keyWindow 上的 %@ becomeFirstResponder，可能导致界面显示异常，请添加 '%@' 的 Symbolic Breakpoint 以捕捉此类信息\n%@", NSStringFromClass(self.class), NSStringFromSelector(_cmd), [NSThread callStackSymbols]);
}

- (BOOL)hasSharedAncestorViewWithView:(UIView *)view {
    UIView *sharedAncestorView = self;
    if (!view) {
        return YES;
    }
    while (sharedAncestorView && ![view isDescendantOfView:sharedAncestorView]) {
        sharedAncestorView = sharedAncestorView.superview;
    }
    return !!sharedAncestorView;
}

- (BOOL)isUIKitPrivateView {
    // 系统有些东西本身也存在不合理，但我们不关心这种，所以过滤掉
    if ([self isKindOfClass:[UIWindow class]]) return YES;

    __block BOOL isPrivate = NO;
    NSString *classString = NSStringFromClass(self.class);
    [@[@"LayoutContainer", @"NavigationItemButton", @"NavigationItemView", @"SelectionGrabber", @"InputViewContent", @"InputSetContainer", @"TextFieldContentView", @"KeyboardImpl"] enumerateObjectsUsingBlock:^(NSString *_Nonnull obj, NSUInteger idx, BOOL *_Nonnull stop) {
        if (([classString hasPrefix:@"UI"] || [classString hasPrefix:@"_UI"]) && [classString containsString:obj]) {
            isPrivate = YES;
            *stop = YES;
        }
    }];
    return isPrivate;
}

- (void)alertConvertValueWithView:(UIView *)view {
    if (IS_DEBUG && ![self isUIKitPrivateView] && ![self hasSharedAncestorViewWithView:view]) {
        // HDLogInfo(@"UIView (HDKitCore)", @"进行坐标系转换运算的 %@ 和 %@ 不存在共同的父 view，可能导致运算结果不准确（特别是在横竖屏旋转时，如果两个 view 处于不同的 window，由于 window 旋转有先后顺序，可能转换时两个 window 的方向不一致，坐标就会错乱）", self, view);
    }
}

@end

@implementation UIView (HD_ViewController)

HDSynthesizeBOOLProperty(hd_isControllerRootView, setHd_isControllerRootView);

- (BOOL)hd_visible {
    if (self.hidden || self.alpha <= 0.01) {
        return NO;
    }
    if (self.window) {
        return YES;
    }
    if ([self isKindOfClass:UIWindow.class]) {
        if (@available(iOS 13.0, *)) {
            return !!((UIWindow *)self).windowScene;
        } else {
            return YES;
        }
    }
    UIViewController *viewController = self.hd_viewController;
    return viewController.hd_visibleState >= HDViewControllerWillAppear && viewController.hd_visibleState < HDViewControllerWillDisappear;
}

static char kAssociatedObjectKey_viewController;
- (void)setHd_viewController:(__kindof UIViewController *_Nullable)hd_viewController {
    HDWeakObjectContainer *weakContainer = objc_getAssociatedObject(self, &kAssociatedObjectKey_viewController);
    if (!weakContainer) {
        weakContainer = [HDWeakObjectContainer new];
    }
    weakContainer.object = hd_viewController;
    objc_setAssociatedObject(self, &kAssociatedObjectKey_viewController, weakContainer, OBJC_ASSOCIATION_RETAIN_NONATOMIC);

    self.hd_isControllerRootView = !!hd_viewController;
}

- (__kindof UIViewController *)hd_viewController {
    if (self.hd_isControllerRootView) {
        return (__kindof UIViewController *)((HDWeakObjectContainer *)objc_getAssociatedObject(self, &kAssociatedObjectKey_viewController)).object;
    }
    return self.superview.hd_viewController;
}

@end

@interface UIViewController (HD_View)

@end

@implementation UIViewController (HD_View)

+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        ExtendImplementationOfVoidMethodWithoutArguments([UIViewController class], @selector(viewDidLoad), ^(UIViewController *selfObject) {
            if (@available(iOS 11.0, *)) {
                selfObject.view.hd_viewController = selfObject;
            } else {
                ((UIView *)[selfObject valueForKey:@"_view"]).hd_viewController = selfObject;
            }
        });
    });
}

@end

@implementation UIView (HD_Runtime)

- (BOOL)hd_hasOverrideUIKitMethod:(SEL)selector {
    // 排序依照 Xcode Interface Builder 里的控件排序，但保证子类在父类前面
    NSMutableArray<Class> *viewSuperclasses = [[NSMutableArray alloc] initWithObjects:
                                                                          [UILabel class],
                                                                          [UIButton class],
                                                                          [UISegmentedControl class],
                                                                          [UITextField class],
                                                                          [UISlider class],
                                                                          [UISwitch class],
                                                                          [UIActivityIndicatorView class],
                                                                          [UIProgressView class],
                                                                          [UIPageControl class],
                                                                          [UIStepper class],
                                                                          [UITableView class],
                                                                          [UITableViewCell class],
                                                                          [UIImageView class],
                                                                          [UICollectionView class],
                                                                          [UICollectionViewCell class],
                                                                          [UICollectionReusableView class],
                                                                          [UITextView class],
                                                                          [UIScrollView class],
                                                                          [UIDatePicker class],
                                                                          [UIPickerView class],
                                                                          [UIVisualEffectView class],
                                                                          [UIWindow class],
                                                                          [UINavigationBar class],
                                                                          [UIToolbar class],
                                                                          [UITabBar class],
                                                                          [UISearchBar class],
                                                                          [UIControl class],
                                                                          [UIView class],
                                                                          nil];

    if (@available(iOS 9, *)) {
        [viewSuperclasses insertObject:[UIStackView class] atIndex:0];
    }

    for (NSInteger i = 0, l = viewSuperclasses.count; i < l; i++) {
        Class superclass = viewSuperclasses[i];
        if ([self hd_hasOverrideMethod:selector ofSuperclass:superclass]) {
            return YES;
        }
    }
    return NO;
}

@end

@implementation UIView (HD_Border)

HDSynthesizeIdStrongProperty(hd_borderLayer, setHd_borderLayer);

+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        ExtendImplementationOfNonVoidMethodWithSingleArgument([UIView class], @selector(initWithFrame:), CGRect, UIView *, ^UIView *(UIView *selfObject, CGRect frame, UIView *originReturnValue) {
            [selfObject setDefaultStyle];
            return originReturnValue;
        });

        ExtendImplementationOfNonVoidMethodWithSingleArgument([UIView class], @selector(initWithCoder:), NSCoder *, UIView *, ^UIView *(UIView *selfObject, NSCoder *aDecoder, UIView *originReturnValue) {
            [selfObject setDefaultStyle];
            return originReturnValue;
        });

        ExtendImplementationOfVoidMethodWithSingleArgument([UIView class], @selector(layoutSublayersOfLayer:), CALayer *, ^(UIView *selfObject, CALayer *layer) {
            if ((!selfObject.hd_borderLayer && selfObject.hd_borderPosition == HDViewBorderPositionNone) || (!selfObject.hd_borderLayer && selfObject.hd_borderWidth == 0)) {
                return;
            }

            if (selfObject.hd_borderLayer && selfObject.hd_borderPosition == HDViewBorderPositionNone && !selfObject.hd_borderLayer.path) {
                return;
            }

            if (selfObject.hd_borderLayer && selfObject.hd_borderWidth == 0 && selfObject.hd_borderLayer.lineWidth == 0) {
                return;
            }

            if (!selfObject.hd_borderLayer) {
                selfObject.hd_borderLayer = [CAShapeLayer layer];
                selfObject.hd_borderLayer.fillColor = UIColor.clearColor.CGColor;
                [selfObject.hd_borderLayer hd_removeDefaultAnimations];
                [selfObject.layer addSublayer:selfObject.hd_borderLayer];
            }
            selfObject.hd_borderLayer.frame = selfObject.bounds;

            CGFloat borderWidth = selfObject.hd_borderWidth;
            selfObject.hd_borderLayer.lineWidth = borderWidth;
            selfObject.hd_borderLayer.strokeColor = selfObject.hd_borderColor.CGColor;
            selfObject.hd_borderLayer.lineDashPhase = selfObject.hd_dashPhase;
            selfObject.hd_borderLayer.lineDashPattern = selfObject.hd_dashPattern;

            UIBezierPath *path = nil;

            if (selfObject.hd_borderPosition != HDViewBorderPositionNone) {
                path = [UIBezierPath bezierPath];
            }

            CGFloat (^adjustsLocation)(CGFloat, CGFloat, CGFloat) = ^CGFloat(CGFloat inside, CGFloat center, CGFloat outside) {
                return selfObject.hd_borderLocation == HDViewBorderLocationInside ? inside : (selfObject.hd_borderLocation == HDViewBorderLocationCenter ? center : outside);
            };

            CGFloat lineOffset = adjustsLocation(borderWidth / 2.0, 0, -borderWidth / 2.0);  // 为了像素对齐而做的偏移
            CGFloat lineCapOffset = adjustsLocation(0, borderWidth / 2.0, borderWidth);      // 两条相邻的边框连接的位置

            BOOL shouldShowTopBorder = (selfObject.hd_borderPosition & HDViewBorderPositionTop) == HDViewBorderPositionTop;
            BOOL shouldShowLeftBorder = (selfObject.hd_borderPosition & HDViewBorderPositionLeft) == HDViewBorderPositionLeft;
            BOOL shouldShowBottomBorder = (selfObject.hd_borderPosition & HDViewBorderPositionBottom) == HDViewBorderPositionBottom;
            BOOL shouldShowRightBorder = (selfObject.hd_borderPosition & HDViewBorderPositionRight) == HDViewBorderPositionRight;

            UIBezierPath *topPath = [UIBezierPath bezierPath];
            UIBezierPath *leftPath = [UIBezierPath bezierPath];
            UIBezierPath *bottomPath = [UIBezierPath bezierPath];
            UIBezierPath *rightPath = [UIBezierPath bezierPath];

            if (selfObject.layer.hd_originCornerRadius > 0) {

                CGFloat cornerRadius = selfObject.layer.hd_originCornerRadius;

                if (selfObject.layer.hd_maskedCorners) {
                    if ((selfObject.layer.hd_maskedCorners & HDLayerMinXMinYCorner) == HDLayerMinXMinYCorner) {
                        [topPath addArcWithCenter:CGPointMake(cornerRadius, cornerRadius) radius:cornerRadius - lineOffset startAngle:1.25 * M_PI endAngle:1.5 * M_PI clockwise:YES];
                        [topPath addLineToPoint:CGPointMake(CGRectGetWidth(selfObject.bounds) - cornerRadius, lineOffset)];
                        [leftPath addArcWithCenter:CGPointMake(cornerRadius, cornerRadius) radius:cornerRadius - lineOffset startAngle:-0.75 * M_PI endAngle:-1 * M_PI clockwise:NO];
                        [leftPath addLineToPoint:CGPointMake(lineOffset, CGRectGetHeight(selfObject.bounds) - cornerRadius)];
                    } else {
                        [topPath moveToPoint:CGPointMake(shouldShowLeftBorder ? -lineCapOffset : 0, lineOffset)];
                        [topPath addLineToPoint:CGPointMake(CGRectGetWidth(selfObject.bounds) - cornerRadius, lineOffset)];
                        [leftPath moveToPoint:CGPointMake(lineOffset, shouldShowTopBorder ? -lineCapOffset : 0)];
                        [leftPath addLineToPoint:CGPointMake(lineOffset, CGRectGetHeight(selfObject.bounds) - cornerRadius)];
                    }
                    if ((selfObject.layer.hd_maskedCorners & HDLayerMinXMaxYCorner) == HDLayerMinXMaxYCorner) {
                        [leftPath addArcWithCenter:CGPointMake(cornerRadius, CGRectGetHeight(selfObject.bounds) - cornerRadius) radius:cornerRadius - lineOffset startAngle:-1 * M_PI endAngle:-1.25 * M_PI clockwise:NO];
                        [bottomPath addArcWithCenter:CGPointMake(cornerRadius, CGRectGetHeight(selfObject.bounds) - cornerRadius) radius:cornerRadius - lineOffset startAngle:-1.25 * M_PI endAngle:-1.5 * M_PI clockwise:NO];
                        [bottomPath addLineToPoint:CGPointMake(CGRectGetWidth(selfObject.bounds) - cornerRadius, CGRectGetHeight(selfObject.bounds) - lineOffset)];
                    } else {
                        [leftPath addLineToPoint:CGPointMake(lineOffset, CGRectGetHeight(selfObject.bounds) + (shouldShowBottomBorder ? lineCapOffset : 0))];
                        CGFloat y = CGRectGetHeight(selfObject.bounds) - lineOffset;
                        [bottomPath moveToPoint:CGPointMake(shouldShowLeftBorder ? -lineCapOffset : 0, y)];
                        [bottomPath addLineToPoint:CGPointMake(CGRectGetWidth(selfObject.bounds) - cornerRadius, y)];
                    }
                    if ((selfObject.layer.hd_maskedCorners & HDLayerMaxXMaxYCorner) == HDLayerMaxXMaxYCorner) {
                        [bottomPath addArcWithCenter:CGPointMake(CGRectGetWidth(selfObject.bounds) - cornerRadius, CGRectGetHeight(selfObject.bounds) - cornerRadius) radius:cornerRadius - lineOffset startAngle:-1.5 * M_PI endAngle:-1.75 * M_PI clockwise:NO];
                        [rightPath addArcWithCenter:CGPointMake(CGRectGetWidth(selfObject.bounds) - cornerRadius, CGRectGetHeight(selfObject.bounds) - cornerRadius) radius:cornerRadius - lineOffset startAngle:-1.75 * M_PI endAngle:-2 * M_PI clockwise:NO];
                        [rightPath addLineToPoint:CGPointMake(CGRectGetWidth(selfObject.bounds) - lineOffset, cornerRadius)];
                    } else {
                        CGFloat y = CGRectGetHeight(selfObject.bounds) - lineOffset;
                        [bottomPath addLineToPoint:CGPointMake(CGRectGetWidth(selfObject.bounds) + (shouldShowRightBorder ? lineCapOffset : 0), y)];
                        CGFloat x = CGRectGetWidth(selfObject.bounds) - lineOffset;
                        [rightPath moveToPoint:CGPointMake(x, CGRectGetHeight(selfObject.bounds) + (shouldShowBottomBorder ? lineCapOffset : 0))];
                        [rightPath addLineToPoint:CGPointMake(x, cornerRadius)];
                    }
                    if ((selfObject.layer.hd_maskedCorners & HDLayerMaxXMinYCorner) == HDLayerMaxXMinYCorner) {
                        [rightPath addArcWithCenter:CGPointMake(CGRectGetWidth(selfObject.bounds) - cornerRadius, cornerRadius) radius:cornerRadius - lineOffset startAngle:0 * M_PI endAngle:-0.25 * M_PI clockwise:NO];
                        [topPath addArcWithCenter:CGPointMake(CGRectGetWidth(selfObject.bounds) - cornerRadius, cornerRadius) radius:cornerRadius - lineOffset startAngle:1.5 * M_PI endAngle:1.75 * M_PI clockwise:YES];
                    } else {
                        CGFloat x = CGRectGetWidth(selfObject.bounds) - lineOffset;
                        [rightPath addLineToPoint:CGPointMake(x, shouldShowTopBorder ? -lineCapOffset : 0)];
                        [topPath addLineToPoint:CGPointMake(CGRectGetWidth(selfObject.bounds) + (shouldShowRightBorder ? lineCapOffset : 0), lineOffset)];
                    }
                } else {
                    [topPath addArcWithCenter:CGPointMake(cornerRadius, cornerRadius) radius:cornerRadius - lineOffset startAngle:1.25 * M_PI endAngle:1.5 * M_PI clockwise:YES];
                    [topPath addLineToPoint:CGPointMake(CGRectGetWidth(selfObject.bounds) - cornerRadius, lineOffset)];
                    [topPath addArcWithCenter:CGPointMake(CGRectGetWidth(selfObject.bounds) - cornerRadius, cornerRadius) radius:cornerRadius - lineOffset startAngle:1.5 * M_PI endAngle:1.75 * M_PI clockwise:YES];

                    [leftPath addArcWithCenter:CGPointMake(cornerRadius, cornerRadius) radius:cornerRadius - lineOffset startAngle:-0.75 * M_PI endAngle:-1 * M_PI clockwise:NO];
                    [leftPath addLineToPoint:CGPointMake(lineOffset, CGRectGetHeight(selfObject.bounds) - cornerRadius)];
                    [leftPath addArcWithCenter:CGPointMake(cornerRadius, CGRectGetHeight(selfObject.bounds) - cornerRadius) radius:cornerRadius - lineOffset startAngle:-1 * M_PI endAngle:-1.25 * M_PI clockwise:NO];

                    [bottomPath addArcWithCenter:CGPointMake(cornerRadius, CGRectGetHeight(selfObject.bounds) - cornerRadius) radius:cornerRadius - lineOffset startAngle:-1.25 * M_PI endAngle:-1.5 * M_PI clockwise:NO];
                    [bottomPath addLineToPoint:CGPointMake(CGRectGetWidth(selfObject.bounds) - cornerRadius, CGRectGetHeight(selfObject.bounds) - lineOffset)];
                    [bottomPath addArcWithCenter:CGPointMake(CGRectGetHeight(selfObject.bounds) - cornerRadius, CGRectGetHeight(selfObject.bounds) - cornerRadius) radius:cornerRadius - lineOffset startAngle:-1.5 * M_PI endAngle:-1.75 * M_PI clockwise:NO];

                    [rightPath addArcWithCenter:CGPointMake(CGRectGetWidth(selfObject.bounds) - cornerRadius, CGRectGetHeight(selfObject.bounds) - cornerRadius) radius:cornerRadius - lineOffset startAngle:-1.75 * M_PI endAngle:-2 * M_PI clockwise:NO];
                    [rightPath addLineToPoint:CGPointMake(CGRectGetWidth(selfObject.bounds) - lineOffset, cornerRadius)];
                    [rightPath addArcWithCenter:CGPointMake(CGRectGetWidth(selfObject.bounds) - cornerRadius, cornerRadius) radius:cornerRadius - lineOffset startAngle:0 * M_PI endAngle:-0.25 * M_PI clockwise:NO];
                }

            } else {
                [topPath moveToPoint:CGPointMake(shouldShowLeftBorder ? -lineCapOffset : 0, lineOffset)];
                [topPath addLineToPoint:CGPointMake(CGRectGetWidth(selfObject.bounds) + (shouldShowRightBorder ? lineCapOffset : 0), lineOffset)];

                [leftPath moveToPoint:CGPointMake(lineOffset, shouldShowTopBorder ? -lineCapOffset : 0)];
                [leftPath addLineToPoint:CGPointMake(lineOffset, CGRectGetHeight(selfObject.bounds) + (shouldShowBottomBorder ? lineCapOffset : 0))];

                CGFloat y = CGRectGetHeight(selfObject.bounds) - lineOffset;
                [bottomPath moveToPoint:CGPointMake(shouldShowLeftBorder ? -lineCapOffset : 0, y)];
                [bottomPath addLineToPoint:CGPointMake(CGRectGetWidth(selfObject.bounds) + (shouldShowRightBorder ? lineCapOffset : 0), y)];

                CGFloat x = CGRectGetWidth(selfObject.bounds) - lineOffset;
                [rightPath moveToPoint:CGPointMake(x, CGRectGetHeight(selfObject.bounds) + (shouldShowBottomBorder ? lineCapOffset : 0))];
                [rightPath addLineToPoint:CGPointMake(x, shouldShowTopBorder ? -lineCapOffset : 0)];
            }

            if (shouldShowTopBorder && ![topPath isEmpty]) {
                [path appendPath:topPath];
            }
            if (shouldShowLeftBorder && ![leftPath isEmpty]) {
                [path appendPath:leftPath];
            }
            if (shouldShowBottomBorder && ![bottomPath isEmpty]) {
                [path appendPath:bottomPath];
            }
            if (shouldShowRightBorder && ![rightPath isEmpty]) {
                [path appendPath:rightPath];
            }

            selfObject.hd_borderLayer.path = path.CGPath;
        });
    });
}

- (void)setDefaultStyle {
    self.hd_borderWidth = PixelOne;
    self.hd_borderColor = HDColor(222, 224, 226, 1);
}

static char kAssociatedObjectKey_borderLocation;
- (void)setHd_borderLocation:(HDViewBorderLocation)hd_borderLocation {
    objc_setAssociatedObject(self, &kAssociatedObjectKey_borderLocation, @(hd_borderLocation), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    [self setNeedsLayout];
}

- (HDViewBorderLocation)hd_borderLocation {
    return [((NSNumber *)objc_getAssociatedObject(self, &kAssociatedObjectKey_borderLocation)) unsignedIntegerValue];
}

static char kAssociatedObjectKey_borderPosition;
- (void)setHd_borderPosition:(HDViewBorderPosition)hd_borderPosition {
    objc_setAssociatedObject(self, &kAssociatedObjectKey_borderPosition, @(hd_borderPosition), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    [self setNeedsLayout];
}

- (HDViewBorderPosition)hd_borderPosition {
    return (HDViewBorderPosition)[objc_getAssociatedObject(self, &kAssociatedObjectKey_borderPosition) unsignedIntegerValue];
}

static char kAssociatedObjectKey_borderWidth;
- (void)setHd_borderWidth:(CGFloat)hd_borderWidth {
    objc_setAssociatedObject(self, &kAssociatedObjectKey_borderWidth, @(hd_borderWidth), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    [self setNeedsLayout];
}

- (CGFloat)hd_borderWidth {
    return [((NSNumber *)objc_getAssociatedObject(self, &kAssociatedObjectKey_borderWidth)) hd_CGFloatValue];
}

static char kAssociatedObjectKey_borderColor;
- (void)setHd_borderColor:(UIColor *)hd_borderColor {
    objc_setAssociatedObject(self, &kAssociatedObjectKey_borderColor, hd_borderColor, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    [self setNeedsLayout];
}

- (UIColor *)hd_borderColor {
    return (UIColor *)objc_getAssociatedObject(self, &kAssociatedObjectKey_borderColor);
}

static char kAssociatedObjectKey_dashPhase;
- (void)setHd_dashPhase:(CGFloat)hd_dashPhase {
    objc_setAssociatedObject(self, &kAssociatedObjectKey_dashPhase, @(hd_dashPhase), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    [self setNeedsLayout];
}

- (CGFloat)hd_dashPhase {
    return [(NSNumber *)objc_getAssociatedObject(self, &kAssociatedObjectKey_dashPhase) hd_CGFloatValue];
}

static char kAssociatedObjectKey_dashPattern;
- (void)setHd_dashPattern:(NSArray<NSNumber *> *)hd_dashPattern {
    objc_setAssociatedObject(self, &kAssociatedObjectKey_dashPattern, hd_dashPattern, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    [self setNeedsLayout];
}

- (NSArray *)hd_dashPattern {
    return (NSArray<NSNumber *> *)objc_getAssociatedObject(self, &kAssociatedObjectKey_dashPattern);
}

@end

const CGFloat HDViewSelfSizingHeight = INFINITY;

@implementation UIView (HD_Layout)

+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        OverrideImplementation([UIView class], @selector(setFrame:), ^id(__unsafe_unretained Class originClass, SEL originCMD, IMP (^originalIMPProvider)(void)) {
            return ^(UIView *selfObject, CGRect frame) {
                // HDViewSelfSizingHeight 的功能
                if (CGRectGetWidth(frame) > 0 && isinf(CGRectGetHeight(frame))) {
                    CGFloat height = flat([selfObject sizeThatFits:CGSizeMake(CGRectGetWidth(frame), CGFLOAT_MAX)].height);
                    frame = CGRectSetHeight(frame, height);
                }

                // 对非法的 frame，Debug 下中 assert，Release 下会将其中的 NaN 改为 0，避免 crash
                if (CGRectIsNaN(frame)) {
                    HDLogWarn(@"UIView (HDKitCore)", @"%@ setFrame:%@，参数包含 NaN，已被拦截并处理为 0。%@", selfObject, NSStringFromCGRect(frame), [NSThread callStackSymbols]);
                    NSAssert(NO, @"UIView setFrame: 出现 NaN");
                    if (!IS_DEBUG) {
                        frame = CGRectSafeValue(frame);
                    }
                }

                CGRect precedingFrame = selfObject.frame;
                BOOL valueChange = !CGRectEqualToRect(frame, precedingFrame);
                if (selfObject.hd_frameWillChangeBlock && valueChange) {
                    frame = selfObject.hd_frameWillChangeBlock(selfObject, frame);
                }

                // call super
                void (*originSelectorIMP)(id, SEL, CGRect);
                originSelectorIMP = (void (*)(id, SEL, CGRect))originalIMPProvider();
                originSelectorIMP(selfObject, originCMD, frame);

                if (selfObject.hd_frameDidChangeBlock && valueChange) {
                    selfObject.hd_frameDidChangeBlock(selfObject, precedingFrame);
                }
            };
        });

        OverrideImplementation([UIView class], @selector(setBounds:), ^id(__unsafe_unretained Class originClass, SEL originCMD, IMP (^originalIMPProvider)(void)) {
            return ^(UIView *selfObject, CGRect bounds) {
                CGRect precedingFrame = selfObject.frame;
                CGRect precedingBounds = selfObject.bounds;
                BOOL valueChange = !CGSizeEqualToSize(bounds.size, precedingBounds.size);  // bounds 只有 size 发生变化才会影响 frame
                if (selfObject.hd_frameWillChangeBlock && valueChange) {
                    CGRect followingFrame = CGRectMake(CGRectGetMinX(precedingFrame) + CGFloatGetCenter(CGRectGetWidth(bounds), CGRectGetWidth(precedingFrame)), CGRectGetMinY(precedingFrame) + CGFloatGetCenter(CGRectGetHeight(bounds), CGRectGetHeight(precedingFrame)), bounds.size.width, bounds.size.height);
                    followingFrame = selfObject.hd_frameWillChangeBlock(selfObject, followingFrame);
                    bounds = CGRectSetSize(bounds, followingFrame.size);
                }

                // call super
                void (*originSelectorIMP)(id, SEL, CGRect);
                originSelectorIMP = (void (*)(id, SEL, CGRect))originalIMPProvider();
                originSelectorIMP(selfObject, originCMD, bounds);

                if (selfObject.hd_frameDidChangeBlock && valueChange) {
                    selfObject.hd_frameDidChangeBlock(selfObject, precedingFrame);
                }
            };
        });

        OverrideImplementation([UIView class], @selector(setCenter:), ^id(__unsafe_unretained Class originClass, SEL originCMD, IMP (^originalIMPProvider)(void)) {
            return ^(UIView *selfObject, CGPoint center) {
                CGRect precedingFrame = selfObject.frame;
                CGPoint precedingCenter = selfObject.center;
                BOOL valueChange = !CGPointEqualToPoint(center, precedingCenter);
                if (selfObject.hd_frameWillChangeBlock && valueChange) {
                    CGRect followingFrame = CGRectSetXY(precedingFrame, center.x - CGRectGetWidth(selfObject.frame) / 2, center.y - CGRectGetHeight(selfObject.frame) / 2);
                    followingFrame = selfObject.hd_frameWillChangeBlock(selfObject, followingFrame);
                    center = CGPointMake(CGRectGetMidX(followingFrame), CGRectGetMidY(followingFrame));
                }

                // call super
                void (*originSelectorIMP)(id, SEL, CGPoint);
                originSelectorIMP = (void (*)(id, SEL, CGPoint))originalIMPProvider();
                originSelectorIMP(selfObject, originCMD, center);

                if (selfObject.hd_frameDidChangeBlock && valueChange) {
                    selfObject.hd_frameDidChangeBlock(selfObject, precedingFrame);
                }
            };
        });

        OverrideImplementation([UIView class], @selector(setTransform:), ^id(__unsafe_unretained Class originClass, SEL originCMD, IMP (^originalIMPProvider)(void)) {
            return ^(UIView *selfObject, CGAffineTransform transform) {
                CGRect precedingFrame = selfObject.frame;
                CGAffineTransform precedingTransform = selfObject.transform;
                BOOL valueChange = !CGAffineTransformEqualToTransform(transform, precedingTransform);
                if (selfObject.hd_frameWillChangeBlock && valueChange) {
                    CGRect followingFrame = CGRectApplyAffineTransformWithAnchorPoint(precedingFrame, transform, selfObject.layer.anchorPoint);
                    selfObject.hd_frameWillChangeBlock(selfObject, followingFrame);  // 对于 CGAffineTransform，无法根据修改后的 rect 来算出新的 transform，所以就不修改 transform 的值了
                }

                // call super
                void (*originSelectorIMP)(id, SEL, CGAffineTransform);
                originSelectorIMP = (void (*)(id, SEL, CGAffineTransform))originalIMPProvider();
                originSelectorIMP(selfObject, originCMD, transform);

                if (selfObject.hd_frameDidChangeBlock && valueChange) {
                    selfObject.hd_frameDidChangeBlock(selfObject, precedingFrame);
                }
            };
        });
    });
}

- (CGFloat)hd_top {
    return CGRectGetMinY(self.frame);
}

- (void)setHd_top:(CGFloat)top {
    self.frame = CGRectSetY(self.frame, top);
}

- (CGFloat)hd_left {
    return CGRectGetMinX(self.frame);
}

- (void)setHd_left:(CGFloat)left {
    self.frame = CGRectSetX(self.frame, left);
}

- (CGFloat)hd_bottom {
    return CGRectGetMaxY(self.frame);
}

- (void)setHd_bottom:(CGFloat)bottom {
    self.frame = CGRectSetY(self.frame, bottom - CGRectGetHeight(self.frame));
}

- (CGFloat)hd_right {
    return CGRectGetMaxX(self.frame);
}

- (void)setHd_right:(CGFloat)right {
    self.frame = CGRectSetX(self.frame, right - CGRectGetWidth(self.frame));
}

- (CGFloat)hd_width {
    return CGRectGetWidth(self.frame);
}

- (void)setHd_width:(CGFloat)width {
    self.frame = CGRectSetWidth(self.frame, width);
}

- (CGFloat)hd_height {
    return CGRectGetHeight(self.frame);
}

- (void)setHd_height:(CGFloat)height {
    self.frame = CGRectSetHeight(self.frame, height);
}

- (CGFloat)hd_extendToTop {
    return self.hd_top;
}

- (void)setHd_extendToTop:(CGFloat)hd_extendToTop {
    self.hd_height = self.hd_bottom - hd_extendToTop;
    self.hd_top = hd_extendToTop;
}

- (CGFloat)hd_extendToLeft {
    return self.hd_left;
}

- (void)setHd_extendToLeft:(CGFloat)hd_extendToLeft {
    self.hd_width = self.hd_right - hd_extendToLeft;
    self.hd_left = hd_extendToLeft;
}

- (CGFloat)hd_extendToBottom {
    return self.hd_bottom;
}

- (void)setHd_extendToBottom:(CGFloat)hd_extendToBottom {
    self.hd_height = hd_extendToBottom - self.hd_top;
    self.hd_bottom = hd_extendToBottom;
}

- (CGFloat)hd_extendToRight {
    return self.hd_right;
}

- (void)setHd_extendToRight:(CGFloat)hd_extendToRight {
    self.hd_width = hd_extendToRight - self.hd_left;
    self.hd_right = hd_extendToRight;
}

- (CGFloat)hd_leftWhenCenterInSuperview {
    return CGFloatGetCenter(CGRectGetWidth(self.superview.bounds), CGRectGetWidth(self.frame));
}

- (CGFloat)hd_topWhenCenterInSuperview {
    return CGFloatGetCenter(CGRectGetHeight(self.superview.bounds), CGRectGetHeight(self.frame));
}

@end

@implementation UIView (CGAffineTransform)

- (CGFloat)hd_scaleX {
    return self.transform.a;
}

- (CGFloat)hd_scaleY {
    return self.transform.d;
}

- (CGFloat)hd_translationX {
    return self.transform.tx;
}

- (CGFloat)hd_translationY {
    return self.transform.ty;
}

@end

@implementation UIView (HD_Snapshotting)

- (UIImage *)hd_snapshotLayerImage {
    return [UIImage hd_imageWithView:self];
}

- (UIImage *)hd_snapshotImageAfterScreenUpdates:(BOOL)afterScreenUpdates {
    return [UIImage hd_imageWithView:self afterScreenUpdates:afterScreenUpdates];
}

@end

@implementation UIView (HD_Debug)

HDSynthesizeBOOLProperty(hd_needsDifferentDebugColor, setHd_needsDifferentDebugColor)
    HDSynthesizeBOOLProperty(hd_hasDebugColor, setHd_hasDebugColor);

+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        ExtendImplementationOfVoidMethodWithoutArguments([UIView class], @selector(layoutSubviews), ^(UIView *selfObject) {
            if (selfObject.hd_shouldShowDebugColor) {
                selfObject.hd_hasDebugColor = YES;
                selfObject.backgroundColor = [selfObject debugColor];
                [selfObject renderColorWithSubviews:selfObject.subviews];
            }
        });
    });
}

static char kAssociatedObjectKey_shouldShowDebugColor;
- (void)setHd_shouldShowDebugColor:(BOOL)hd_shouldShowDebugColor {
    objc_setAssociatedObject(self, &kAssociatedObjectKey_shouldShowDebugColor, @(hd_shouldShowDebugColor), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    if (hd_shouldShowDebugColor) {
        [self setNeedsLayout];
    }
}
- (BOOL)hd_shouldShowDebugColor {
    BOOL flag = [objc_getAssociatedObject(self, &kAssociatedObjectKey_shouldShowDebugColor) boolValue];
    return flag;
}

static char kAssociatedObjectKey_layoutSubviewsBlock;
static NSMutableSet *hd_registeredLayoutSubviewsBlockClasses;
- (void)setHd_layoutSubviewsBlock:(void (^)(__kindof UIView *_Nonnull))hd_layoutSubviewsBlock {
    objc_setAssociatedObject(self, &kAssociatedObjectKey_layoutSubviewsBlock, hd_layoutSubviewsBlock, OBJC_ASSOCIATION_COPY_NONATOMIC);
    if (!hd_registeredLayoutSubviewsBlockClasses) hd_registeredLayoutSubviewsBlockClasses = [NSMutableSet set];
    if (hd_layoutSubviewsBlock) {
        Class viewClass = self.class;
        if (![hd_registeredLayoutSubviewsBlockClasses containsObject:viewClass]) {
            // Extend 每个实例对象的类是为了保证比子类的 layoutSubviews 逻辑要更晚调用
            ExtendImplementationOfVoidMethodWithoutArguments(viewClass, @selector(layoutSubviews), ^(__kindof UIView *selfObject) {
                if (selfObject.hd_layoutSubviewsBlock && [selfObject isMemberOfClass:viewClass]) {
                    selfObject.hd_layoutSubviewsBlock(selfObject);
                }
            });
            [hd_registeredLayoutSubviewsBlockClasses addObject:viewClass];
        }
    }
}

- (void (^)(UIView *_Nonnull))hd_layoutSubviewsBlock {
    return objc_getAssociatedObject(self, &kAssociatedObjectKey_layoutSubviewsBlock);
}

- (void)renderColorWithSubviews:(NSArray *)subviews {
    for (UIView *view in subviews) {
        if (@available(iOS 9.0, *)) {
            if ([view isKindOfClass:[UIStackView class]]) {
                UIStackView *stackView = (UIStackView *)view;
                [self renderColorWithSubviews:stackView.arrangedSubviews];
            }
        }
        view.hd_hasDebugColor = YES;
        view.hd_shouldShowDebugColor = self.hd_shouldShowDebugColor;
        view.hd_needsDifferentDebugColor = self.hd_needsDifferentDebugColor;
        view.backgroundColor = [self debugColor];
    }
}

- (UIColor *)debugColor {
    if (!self.hd_needsDifferentDebugColor) {
        return HDColor(255, 0, 0, 1);
    } else {
        return [[UIColor hd_randomColor] colorWithAlphaComponent:.3];
    }
}

@end
