//
//  UIViewController+HD.m
//  HDKitCore
//
//  Created by VanJay on 2019/12/30.
//  Copyright © 2019 chaos network technology. All rights reserved.
//

#import "HDAssociatedObjectHelper.h"
#import "HDCommonDefines.h"
#import "HDLog.h"
#import "HDRunTime.h"
#import "NSObject+HDKitCore.h"
#import "UIInterface+HDKitCore.h"
#import "UINavigationController+HDKitCore.h"
#import "UIView+HDKitCore.h"
#import "UIViewController+HDKitCore.h"

NSNotificationName const HDAppSizeWillChangeNotification = @"HDAppSizeWillChangeNotification";
NSString *const HDPrecedingAppSizeUserInfoKey = @"HDPrecedingAppSizeUserInfoKey";
NSString *const HDFollowingAppSizeUserInfoKey = @"HDFollowingAppSizeUserInfoKey";

NSString *const HDTabBarStyleChangedNotification = @"HDTabBarStyleChangedNotification";

@interface UIViewController ()

@property (nonatomic, strong) UINavigationBar *transitionNavigationBar;  // by molice 对应 UIViewController (NavigationBarTransition) 里的 transitionNavigationBar，为了让这个属性在这里可以被访问到，有点 hack，具体请查看

@property (nonatomic, assign) BOOL hd_hasFixedTabBarInsets;
@end

@implementation UIViewController (HDKitCore)

HDSynthesizeIdCopyProperty(hd_visibleStateDidChangeBlock, setHd_visibleStateDidChangeBlock);
HDSynthesizeBOOLProperty(hd_hasFixedTabBarInsets, setHd_hasFixedTabBarInsets);

+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        ExchangeImplementations([UIViewController class], @selector(description), @selector(hdvc_description));

        ExtendImplementationOfVoidMethodWithoutArguments([UIViewController class], @selector(viewDidLoad), ^(UIViewController *selfObject) {
            selfObject.hd_visibleState = HDViewControllerViewDidLoad;
        });

        ExtendImplementationOfVoidMethodWithSingleArgument([UIViewController class], @selector(viewWillAppear:), BOOL, ^(UIViewController *selfObject, BOOL animated) {
            selfObject.hd_visibleState = HDViewControllerWillAppear;
        });

        ExtendImplementationOfVoidMethodWithSingleArgument([UIViewController class], @selector(viewDidAppear:), BOOL, ^(UIViewController *selfObject, BOOL animated) {
            selfObject.hd_visibleState = HDViewControllerDidAppear;
        });

        ExtendImplementationOfVoidMethodWithSingleArgument([UIViewController class], @selector(viewWillDisappear:), BOOL, ^(UIViewController *selfObject, BOOL animated) {
            selfObject.hd_visibleState = HDViewControllerWillDisappear;
        });

        ExtendImplementationOfVoidMethodWithSingleArgument([UIViewController class], @selector(viewDidDisappear:), BOOL, ^(UIViewController *selfObject, BOOL animated) {
            selfObject.hd_visibleState = HDViewControllerDidDisappear;
        });

        OverrideImplementation([UIViewController class], @selector(viewWillTransitionToSize:withTransitionCoordinator:), ^id(__unsafe_unretained Class originClass, SEL originCMD, IMP (^originalIMPProvider)(void)) {
            return ^(UIViewController *selfObject, CGSize size, id<UIViewControllerTransitionCoordinator> coordinator) {
                if (selfObject == UIApplication.sharedApplication.delegate.window.rootViewController) {
                    CGSize originalSize = selfObject.view.frame.size;
                    BOOL sizeChanged = !CGSizeEqualToSize(originalSize, size);
                    if (sizeChanged) {
                        [[NSNotificationCenter defaultCenter] postNotificationName:HDAppSizeWillChangeNotification
                                                                            object:nil
                                                                          userInfo:@{HDPrecedingAppSizeUserInfoKey: @(originalSize),
                                                                                     HDFollowingAppSizeUserInfoKey: @(size)}];
                    }
                }

                // call super
                void (*originSelectorIMP)(id, SEL, CGSize, id<UIViewControllerTransitionCoordinator>);
                originSelectorIMP = (void (*)(id, SEL, CGSize, id<UIViewControllerTransitionCoordinator>))originalIMPProvider();
                originSelectorIMP(selfObject, originCMD, size, coordinator);
            };
        });

        // 修复 iOS 11 scrollView 无法自动适配不透明的 tabBar，导致底部 inset 错误的问题
        if (@available(iOS 11, *)) {
            ExtendImplementationOfNonVoidMethodWithTwoArguments([UIViewController class], @selector(initWithNibName:bundle:), NSString *, NSBundle *, UIViewController *, ^UIViewController *(UIViewController *selfObject, NSString *nibNameOrNil, NSBundle *nibBundleOrNil, UIViewController *originReturnValue) {
                BOOL isContainerViewController = [selfObject isKindOfClass:[UINavigationController class]] || [selfObject isKindOfClass:[UITabBarController class]] || [selfObject isKindOfClass:[UISplitViewController class]];
                if (!isContainerViewController) {
                    [[NSNotificationCenter defaultCenter] addObserver:selfObject selector:@selector(adjustsAdditionalSafeAreaInsetsForOpaqueTabBarWithNotification:) name:HDTabBarStyleChangedNotification object:nil];
                }
                return originReturnValue;
            });
        }
    });
}

- (NSString *)hdvc_description {
    NSString *result = [NSString stringWithFormat:@"%@\nsuperclass:\t\t\t\t%@\ntitle:\t\t\t\t\t%@\nview:\t\t\t\t\t%@", [self hdvc_description], NSStringFromClass(self.superclass), self.title, [self isViewLoaded] ? self.view : nil];

    if ([self isKindOfClass:[UINavigationController class]]) {

        UINavigationController *navController = (UINavigationController *)self;
        NSString *navDescription = [NSString stringWithFormat:@"\nviewControllers(%@):\t\t%@\ntopViewController:\t\t%@\nvisibleViewController:\t%@", @(navController.viewControllers.count), [self descriptionWithViewControllers:navController.viewControllers], [navController.topViewController hdvc_description], [navController.visibleViewController hdvc_description]];
        result = [result stringByAppendingString:navDescription];

    } else if ([self isKindOfClass:[UITabBarController class]]) {

        UITabBarController *tabBarController = (UITabBarController *)self;
        NSString *tabBarDescription = [NSString stringWithFormat:@"\nviewControllers(%@):\t\t%@\nselectedViewController(%@):\t%@", @(tabBarController.viewControllers.count), [self descriptionWithViewControllers:tabBarController.viewControllers], @(tabBarController.selectedIndex), [tabBarController.selectedViewController hdvc_description]];
        result = [result stringByAppendingString:tabBarDescription];
    }
    return result;
}

- (NSString *)descriptionWithViewControllers:(NSArray<UIViewController *> *)viewControllers {
    NSMutableString *string = [[NSMutableString alloc] init];
    [string appendString:@"(\n"];
    for (NSInteger i = 0, l = viewControllers.count; i < l; i++) {
        [string appendFormat:@"\t\t\t\t\t\t\t[%@]%@%@\n", @(i), [viewControllers[i] hdvc_description], i < l - 1 ? @"," : @""];
    }
    [string appendString:@"\t\t\t\t\t\t)"];
    return [string copy];
}

static char kAssociatedObjectKey_visibleState;
- (void)setHd_visibleState:(HDViewControllerVisibleState)hd_visibleState {
    BOOL valueChanged = self.hd_visibleState != hd_visibleState;
    objc_setAssociatedObject(self, &kAssociatedObjectKey_visibleState, @(hd_visibleState), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    if (valueChanged && self.hd_visibleStateDidChangeBlock) {
        self.hd_visibleStateDidChangeBlock(self, hd_visibleState);
    }
}

- (HDViewControllerVisibleState)hd_visibleState {
    return [((NSNumber *)objc_getAssociatedObject(self, &kAssociatedObjectKey_visibleState)) unsignedIntegerValue];
}

- (void)adjustsAdditionalSafeAreaInsetsForOpaqueTabBarWithNotification:(NSNotification *)notification {
    if (@available(iOS 11, *)) {

        BOOL isCurrentTabBar = self.tabBarController && self.navigationController && self.navigationController.hd_rootViewController == self && self.navigationController.parentViewController == self.tabBarController && (notification ? notification.object == self.tabBarController.tabBar : YES);
        if (!isCurrentTabBar) {
            return;
        }

        UITabBar *tabBar = self.tabBarController.tabBar;

        // 判断
        BOOL isOpaqueBarAndCanExtendedLayout = !tabBar.translucent && self.extendedLayoutIncludesOpaqueBars;
        if (!isOpaqueBarAndCanExtendedLayout) {

            // 如果前面的 isOpaqueBarAndCanExtendedLayout 为 NO，理论上并不满足 issue #218 所陈述的条件，但有可能项目一开始先设置了 translucent 为 NO，于是走了下面的主动调整 additionalSafeAreaInsets 的逻辑，后来又改为 translucent 为 YES，此时如果不把之前主动调整的 additionalSafeAreaInsets 重置回来，就会一直存在一个多余的 inset，导致底部间距错误，因此增加了 hd_hasFixedTabBarInsets 这个属性便于做重置操作。
            if (!self.hd_hasFixedTabBarInsets) {
                return;
            }
        }

        self.hd_hasFixedTabBarInsets = YES;

        if (!isOpaqueBarAndCanExtendedLayout) {
            self.additionalSafeAreaInsets = UIEdgeInsetsSetBottom(self.additionalSafeAreaInsets, 0);
            return;
        }

        BOOL tabBarHidden = tabBar.hidden;

        // 这里直接用 CGRectGetHeight(tabBar.frame) 来计算理论上不准确，
        CGFloat bottom = tabBar.safeAreaInsets.bottom;
        CGFloat correctSafeAreaInsetsBottom = tabBarHidden ? bottom : CGRectGetHeight(tabBar.frame);
        CGFloat additionalSafeAreaInsetsBottom = correctSafeAreaInsetsBottom - bottom;
        self.additionalSafeAreaInsets = UIEdgeInsetsSetBottom(self.additionalSafeAreaInsets, additionalSafeAreaInsetsBottom);
    }
}

- (UIViewController *)hd_previousViewController {
    if (self.navigationController.viewControllers && self.navigationController.viewControllers.count > 1 && self.navigationController.topViewController == self) {
        NSUInteger count = self.navigationController.viewControllers.count;
        return (UIViewController *)[self.navigationController.viewControllers objectAtIndex:count - 2];
    }
    return nil;
}

- (NSString *)hd_previousViewControllerTitle {
    UIViewController *previousViewController = [self hd_previousViewController];
    if (previousViewController) {
        return previousViewController.title;
    }
    return nil;
}

- (BOOL)hd_isPresented {
    UIViewController *viewController = self;
    if (self.navigationController) {
        if (self.navigationController.hd_rootViewController != self) {
            return NO;
        }
        viewController = self.navigationController;
    }
    BOOL result = viewController.presentingViewController.presentedViewController == viewController;
    return result;
}

- (UIViewController *)hd_visibleViewControllerIfExist {

    if (self.presentedViewController) {
        return [self.presentedViewController hd_visibleViewControllerIfExist];
    }

    if ([self isKindOfClass:[UINavigationController class]]) {
        return [((UINavigationController *)self).visibleViewController hd_visibleViewControllerIfExist];
    }

    if ([self isKindOfClass:[UITabBarController class]]) {
        return [((UITabBarController *)self).selectedViewController hd_visibleViewControllerIfExist];
    }

    if ([self hd_isViewLoadedAndVisible]) {
        return self;
    } else {
        HDLogInfo(@"UIViewController (HDKitCore)", @"hd_visibleViewControllerIfExist:，找不到可见的viewController。self = %@, self.view = %@, self.view.window = %@", self, [self isViewLoaded] ? self.view : nil, [self isViewLoaded] ? self.view.window : nil);
        return nil;
    }
}

- (BOOL)hd_isViewLoadedAndVisible {
    return self.isViewLoaded && self.view.hd_visible;
}

- (CGFloat)hd_navigationBarMaxYInViewCoordinator {
    if (!self.isViewLoaded) {
        return 0;
    }

    // 手势返回过程中 self.navigationController 已经不存在了，所以暂时通过遍历 view 层级的方式去获取到 navigationController 的引用
    UINavigationController *navigationController = self.navigationController;
    if (!navigationController) {
        navigationController = self.view.superview.superview.hd_viewController;
        if (![navigationController isKindOfClass:[UINavigationController class]]) {
            navigationController = nil;
        }
    }

    if (!navigationController) {
        return 0;
    }

    UINavigationBar *navigationBar = navigationController.navigationBar;
    CGFloat barMinX = CGRectGetMinX(navigationBar.frame);
    CGFloat barPresentationMinX = CGRectGetMinX(navigationBar.layer.presentationLayer.frame);
    CGFloat superviewX = CGRectGetMinX(self.view.superview.frame);
    CGFloat superviewX2 = CGRectGetMinX(self.view.superview.superview.frame);

    if (self.hd_navigationControllerPoppingInteracted) {
        if (barMinX != 0 && barMinX == barPresentationMinX) {
            // 返回到无 bar 的界面
            return 0;
        } else if (barMinX > 0) {
            if (self.hd_willAppearByInteractivePopGestureRecognizer) {
                // 要手势返回去的那个界面隐藏了 bar
                return 0;
            }
        } else if (barMinX < 0) {
            // 正在手势返回的这个界面隐藏了 bar
            if (!self.hd_willAppearByInteractivePopGestureRecognizer) {
                return 0;
            }
        } else {
            // 正在手势返回的这个界面隐藏了 bar
            if (barPresentationMinX != 0 && !self.hd_willAppearByInteractivePopGestureRecognizer) {
                return 0;
            }
        }
    } else {
        if (barMinX > 0) {
            // 正在 pop 回无 bar 的界面
            if (superviewX2 <= 0) {
                // 即将回到的那个无 bar 的界面
                return 0;
            }
        } else if (barMinX < 0) {
            if (barPresentationMinX < 0) {
                // 从无 bar push 进无 bar 的界面
                return 0;
            }
            // 正在从有 bar 的界面 push 到无 bar 的界面（bar 被推到左边屏幕外，所以是负数）
            if (superviewX >= 0) {
                // 即将进入的那个无 bar 的界面
                return 0;
            }
        } else {
            if (superviewX < 0 && barPresentationMinX != 0) {
                // 无 bar push 进有 bar 的界面时，背后的那个无 bar 的界面
                return 0;
            }
            if (superviewX2 > 0 && barPresentationMinX < 0) {
                // 无 bar pop 回有 bar 的界面时，被 pop 掉的那个无 bar 的界面
                return 0;
            }
        }
    }

    CGRect navigationBarFrameInView = [self.view convertRect:navigationBar.frame fromView:navigationBar.superview];
    CGRect navigationBarFrame = CGRectIntersection(self.view.bounds, navigationBarFrameInView);

    // 两个 rect 如果不存在交集，CGRectIntersection 计算结果可能为非法的 rect，所以这里做个保护
    if (!CGRectIsValidated(navigationBarFrame)) {
        return 0;
    }

    CGFloat result = CGRectGetMaxY(navigationBarFrame);
    return result;
}

- (CGFloat)hd_toolbarSpacingInViewCoordinator {
    if (!self.isViewLoaded) {
        return 0;
    }
    if (!self.navigationController.toolbar || self.navigationController.toolbarHidden) {
        return 0;
    }
    CGRect toolbarFrame = CGRectIntersection(self.view.bounds, [self.view convertRect:self.navigationController.toolbar.frame fromView:self.navigationController.toolbar.superview]);

    // 两个 rect 如果不存在交集，CGRectIntersection 计算结果可能为非法的 rect，所以这里做个保护
    if (!CGRectIsValidated(toolbarFrame)) {
        return 0;
    }

    CGFloat result = CGRectGetHeight(self.view.bounds) - CGRectGetMinY(toolbarFrame);
    return result;
}

- (CGFloat)hd_tabBarSpacingInViewCoordinator {
    if (!self.isViewLoaded) {
        return 0;
    }
    if (!self.tabBarController.tabBar || self.tabBarController.tabBar.hidden) {
        return 0;
    }
    CGRect tabBarFrame = CGRectIntersection(self.view.bounds, [self.view convertRect:self.tabBarController.tabBar.frame fromView:self.tabBarController.tabBar.superview]);

    // 两个 rect 如果不存在交集，CGRectIntersection 计算结果可能为非法的 rect，所以这里做个保护
    if (!CGRectIsValidated(tabBarFrame)) {
        return 0;
    }

    CGFloat result = CGRectGetHeight(self.view.bounds) - CGRectGetMinY(tabBarFrame);
    return result;
}

- (BOOL)hd_prefersStatusBarHidden {
    if (self.childViewControllerForStatusBarHidden) {
        return self.childViewControllerForStatusBarHidden.hd_prefersStatusBarHidden;
    }
    return self.prefersStatusBarHidden;
}

- (UIStatusBarStyle)hd_preferredStatusBarStyle {
    if (self.childViewControllerForStatusBarStyle) {
        return self.childViewControllerForStatusBarStyle.hd_preferredStatusBarStyle;
    }
    return self.preferredStatusBarStyle;
}

- (BOOL)hd_prefersLargeTitleDisplayed {
    if (@available(iOS 11.0, *)) {
        NSAssert(self.navigationController, @"必现在 navigationController 栈内才能正确判断");
        UINavigationBar *navigationBar = self.navigationController.navigationBar;
        if (!navigationBar.prefersLargeTitles) {
            return NO;
        }
        if (self.navigationItem.largeTitleDisplayMode == UINavigationItemLargeTitleDisplayModeAlways) {
            return YES;
        } else if (self.navigationItem.largeTitleDisplayMode == UINavigationItemLargeTitleDisplayModeNever) {
            return NO;
        } else if (self.navigationItem.largeTitleDisplayMode == UINavigationItemLargeTitleDisplayModeAutomatic) {
            if (self.navigationController.childViewControllers.firstObject == self) {
                return YES;
            } else {
                UIViewController *previousViewController = self.navigationController.childViewControllers[[self.navigationController.childViewControllers indexOfObject:self] - 1];
                return previousViewController.hd_prefersLargeTitleDisplayed == YES;
            }
        }
    }
    return NO;
}

- (void)dismissAnimated:(BOOL)animated completion:(void (^__nullable)(void))completion {
    if (self.presentingViewController) {
        if (self.presentingViewController.presentedViewController == self) {
            [self dismissViewControllerAnimated:YES completion:completion];
        } else {
            // 判断有没有导航控制器
            UINavigationController *navigationController = self.navigationController;
            if (navigationController) {
                // 判断是不是只有一个
                if (navigationController.viewControllers.count <= 1) {
                    [self dismissViewControllerAnimated:YES completion:completion];
                } else {
                    [navigationController popViewControllerAnimated:YES];
                    !completion ?: completion();
                }
            } else {
                [self dismissViewControllerAnimated:YES completion:completion];
            }
        }
    } else {
        // 判断有没有导航控制器
        UINavigationController *navigationController = self.navigationController;
        if (navigationController) {
            if (navigationController.viewControllers.count > 1) {
                [self.navigationController popViewControllerAnimated:YES];
                !completion ?: completion();
            } else {
                // 到顶
                UITabBarController *tabBarController = navigationController.tabBarController;
                if (tabBarController && tabBarController.navigationController) {
                    if (tabBarController.navigationController.viewControllers.count > 1) {
                        [tabBarController.navigationController popViewControllerAnimated:YES];
                        !completion ?: completion();
                    } else {
                        [tabBarController.navigationController dismissViewControllerAnimated:YES completion:completion];
                    }
                } else {
                    [tabBarController dismissViewControllerAnimated:YES completion:completion];
                }
            }
        } else {
            [self dismissViewControllerAnimated:YES completion:completion];
        }
    }
}

- (BOOL)isLastVCInNavController {
    if (!self.navigationController) return false;

    return self.navigationController.viewControllers.lastObject == self;
}
@end

@implementation UIViewController (Data)

HDSynthesizeIdCopyProperty(hd_didAppearAndLoadDataBlock, setHd_didAppearAndLoadDataBlock);

+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        ExtendImplementationOfVoidMethodWithSingleArgument([UIViewController class], @selector(viewDidAppear:), BOOL, ^(UIViewController *selfObject, BOOL animated) {
            if (selfObject.hd_didAppearAndLoadDataBlock && selfObject.hd_dataLoaded) {
                selfObject.hd_didAppearAndLoadDataBlock();
                selfObject.hd_didAppearAndLoadDataBlock = nil;
            }
        });
    });
}

static char kAssociatedObjectKey_dataLoaded;
- (void)setHd_dataLoaded:(BOOL)hd_dataLoaded {
    objc_setAssociatedObject(self, &kAssociatedObjectKey_dataLoaded, @(hd_dataLoaded), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    if (self.hd_didAppearAndLoadDataBlock && hd_dataLoaded && self.hd_visibleState >= HDViewControllerDidAppear) {
        self.hd_didAppearAndLoadDataBlock();
        self.hd_didAppearAndLoadDataBlock = nil;
    }
}

- (BOOL)isHd_dataLoaded {
    return [((NSNumber *)objc_getAssociatedObject(self, &kAssociatedObjectKey_dataLoaded)) boolValue];
}

@end

@implementation UIViewController (Runtime)

- (BOOL)hd_hasOverrideUIKitMethod:(SEL)selector {
    // 排序依照 Xcode Interface Builder 里的控件排序，但保证子类在父类前面
    NSMutableArray<Class> *viewControllerSuperclasses = [[NSMutableArray alloc] initWithObjects:
                                                                                    [UIImagePickerController class],
                                                                                    [UINavigationController class],
                                                                                    [UITableViewController class],
                                                                                    [UICollectionViewController class],
                                                                                    [UITabBarController class],
                                                                                    [UISplitViewController class],
                                                                                    [UIPageViewController class],
                                                                                    [UIViewController class],
                                                                                    nil];

    if (NSClassFromString(@"UIAlertController")) {
        [viewControllerSuperclasses addObject:[UIAlertController class]];
    }
    if (NSClassFromString(@"UISearchController")) {
        [viewControllerSuperclasses addObject:[UISearchController class]];
    }
    for (NSInteger i = 0, l = viewControllerSuperclasses.count; i < l; i++) {
        Class superclass = viewControllerSuperclasses[i];
        if ([self hd_hasOverrideMethod:selector ofSuperclass:superclass]) {
            return YES;
        }
    }
    return NO;
}

@end

@implementation UIViewController (RotateDeviceOrientation)

+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        // 实现 AutomaticallyRotateDeviceOrientation 开关的功能
        ExtendImplementationOfVoidMethodWithSingleArgument([UIViewController class], @selector(viewWillAppear:), BOOL, ^(UIViewController *selfObject, BOOL animated) {
            // if (!AutomaticallyRotateDeviceOrientation) {
            // return;
            // }

            // 某些情况下的 UIViewController 不具备决定设备方向的权利，具体请看
            if (![selfObject hd_shouldForceRotateDeviceOrientation]) {
                BOOL isRootViewController = [selfObject isViewLoaded] && selfObject.view.window.rootViewController == selfObject;
                BOOL isChildViewController = [selfObject.tabBarController.viewControllers containsObject:selfObject] || [selfObject.navigationController.viewControllers containsObject:selfObject] || [selfObject.splitViewController.viewControllers containsObject:selfObject];
                BOOL hasRightsOfRotateDeviceOrientaion = isRootViewController || isChildViewController;
                if (!hasRightsOfRotateDeviceOrientaion) {
                    return;
                }
            }

            UIInterfaceOrientation statusBarOrientation = UIApplication.sharedApplication.statusBarOrientation;
            UIDeviceOrientation deviceOrientationBeforeChangingByHelper = [HDHelper sharedInstance].orientationBeforeChangingByHelper;
            BOOL shouldConsiderBeforeChanging = deviceOrientationBeforeChangingByHelper != UIDeviceOrientationUnknown;
            UIDeviceOrientation deviceOrientation = [UIDevice currentDevice].orientation;

            // 虽然这两者的 unknow 值是相同的，但在启动 App 时可能只有其中一个是 unknown
            if (statusBarOrientation == UIInterfaceOrientationUnknown || deviceOrientation == UIDeviceOrientationUnknown) return;

            // 如果当前设备方向和界面支持的方向不一致，则主动进行旋转
            UIDeviceOrientation deviceOrientationToRotate = [HDHelper interfaceOrientationMask:selfObject.supportedInterfaceOrientations containsDeviceOrientation:deviceOrientation] ? deviceOrientation : [HDHelper deviceOrientationWithInterfaceOrientationMask:selfObject.supportedInterfaceOrientations];

            // 之前没用私有接口修改过，那就按最标准的方式去旋转
            if (!shouldConsiderBeforeChanging) {
                if ([HDHelper rotateToDeviceOrientation:deviceOrientationToRotate]) {
                    [HDHelper sharedInstance].orientationBeforeChangingByHelper = deviceOrientation;
                } else {
                    [HDHelper sharedInstance].orientationBeforeChangingByHelper = UIDeviceOrientationUnknown;
                }
                return;
            }

            // 用私有接口修改过方向，但下一个界面和当前界面方向不相同，则要把修改前记录下来的那个设备方向考虑进来
            deviceOrientationToRotate = [HDHelper interfaceOrientationMask:selfObject.supportedInterfaceOrientations containsDeviceOrientation:deviceOrientationBeforeChangingByHelper] ? deviceOrientationBeforeChangingByHelper : [HDHelper deviceOrientationWithInterfaceOrientationMask:selfObject.supportedInterfaceOrientations];
            [HDHelper rotateToDeviceOrientation:deviceOrientationToRotate];
        });
    });
}

- (BOOL)hd_shouldForceRotateDeviceOrientation {
    return NO;
}

@end

@implementation UIViewController (HDNavigationController)

HDSynthesizeBOOLProperty(hd_navigationControllerPopGestureRecognizerChanging, setHd_navigationControllerPopGestureRecognizerChanging);
HDSynthesizeBOOLProperty(hd_poppingByInteractivePopGestureRecognizer, setHd_poppingByInteractivePopGestureRecognizer);
HDSynthesizeBOOLProperty(hd_willAppearByInteractivePopGestureRecognizer, setHd_willAppearByInteractivePopGestureRecognizer);

- (BOOL)hd_navigationControllerPoppingInteracted {
    return self.hd_poppingByInteractivePopGestureRecognizer || self.hd_willAppearByInteractivePopGestureRecognizer;
}

- (void)hd_animateAlongsideTransition:(void (^__nullable)(id<UIViewControllerTransitionCoordinatorContext> context))animation
                           completion:(void (^__nullable)(id<UIViewControllerTransitionCoordinatorContext> context))completion {
    if (self.transitionCoordinator) {
        BOOL animationQueuedToRun = [self.transitionCoordinator animateAlongsideTransition:animation completion:completion];
        // 某些情况下传给 animateAlongsideTransition 的 animation 不会被执行，这时候要自己手动调用一下
        // 但即便如此，completion 也会在动画结束后才被调用，因此这样写不会导致 completion 比 animation block 先调用
        // 某些情况包含：从 B 手势返回 A 的过程中，取消手势，animation 不会被调用
        if (!animationQueuedToRun && animation) {
            animation(nil);
        }
    } else {
        if (animation) animation(nil);
        if (completion) completion(nil);
    }
}

@end

@implementation HDHelper (ViewController)

+ (nullable UIViewController *)visibleViewController {
    UIViewController *rootViewController = UIApplication.sharedApplication.delegate.window.rootViewController;
    UIViewController *visibleViewController = [rootViewController hd_visibleViewControllerIfExist];
    return visibleViewController;
}
@end

// 为了 UIViewController 适配 iOS 11 下出现不透明的 tabBar 时底部 inset 错误的问题而创建的 Category
@interface UITabBar (NavigationController)

@end

@implementation UITabBar (NavigationController)

+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (@available(iOS 11, *)) {

            OverrideImplementation([UITabBar class], @selector(setHidden:), ^id(__unsafe_unretained Class originClass, SEL originCMD, IMP (^originalIMPProvider)(void)) {
                return ^(UITabBar *selfObject, BOOL hidden) {
                    BOOL shouldNotify = selfObject.hidden != hidden;

                    // call super
                    void (*originSelectorIMP)(id, SEL, BOOL);
                    originSelectorIMP = (void (*)(id, SEL, BOOL))originalIMPProvider();
                    originSelectorIMP(selfObject, originCMD, hidden);

                    if (shouldNotify) {
                        [[NSNotificationCenter defaultCenter] postNotificationName:HDTabBarStyleChangedNotification object:selfObject];
                    }
                };
            });

            OverrideImplementation([UITabBar class], @selector(setBackgroundImage:), ^id(__unsafe_unretained Class originClass, SEL originCMD, IMP (^originalIMPProvider)(void)) {
                return ^(UITabBar *selfObject, UIImage *backgroundImage) {
                    BOOL shouldNotify = ![selfObject.backgroundImage isEqual:backgroundImage];

                    // call super
                    void (*originSelectorIMP)(id, SEL, UIImage *);
                    originSelectorIMP = (void (*)(id, SEL, UIImage *))originalIMPProvider();
                    originSelectorIMP(selfObject, originCMD, backgroundImage);

                    if (shouldNotify) {
                        [[NSNotificationCenter defaultCenter] postNotificationName:HDTabBarStyleChangedNotification object:selfObject];
                    }
                };
            });

            OverrideImplementation([UITabBar class], @selector(setTranslucent:), ^id(__unsafe_unretained Class originClass, SEL originCMD, IMP (^originalIMPProvider)(void)) {
                return ^(UITabBar *selfObject, BOOL translucent) {
                    BOOL shouldNotify = selfObject.translucent != translucent;

                    // call super
                    void (*originSelectorIMP)(id, SEL, BOOL);
                    originSelectorIMP = (void (*)(id, SEL, BOOL))originalIMPProvider();
                    originSelectorIMP(selfObject, originCMD, translucent);

                    if (shouldNotify) {
                        [[NSNotificationCenter defaultCenter] postNotificationName:HDTabBarStyleChangedNotification object:selfObject];
                    }
                };
            });

            OverrideImplementation([UITabBar class], @selector(setFrame:), ^id(__unsafe_unretained Class originClass, SEL originCMD, IMP (^originalIMPProvider)(void)) {
                return ^(UITabBar *selfObject, CGRect frame) {
                    BOOL shouldNotify = CGRectGetMinY(selfObject.frame) != CGRectGetMinY(frame);

                    // call super
                    void (*originSelectorIMP)(id, SEL, CGRect);
                    originSelectorIMP = (void (*)(id, SEL, CGRect))originalIMPProvider();
                    originSelectorIMP(selfObject, originCMD, frame);

                    if (shouldNotify) {
                        [[NSNotificationCenter defaultCenter] postNotificationName:HDTabBarStyleChangedNotification object:selfObject];
                    }
                };
            });
        }
    });
}

@end
