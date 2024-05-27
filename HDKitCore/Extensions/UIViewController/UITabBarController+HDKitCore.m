//
//  UITabBarController+HDKitCore.m
//  HDKitCore
//
//  Created by VanJay on 2019/8/20.
//  Copyright © 2019 chaos network technology. All rights reserved.
//

#import "HDAssociatedObjectHelper.h"
#import "UITabBarController+HDKitCore.h"

@interface UITabBarController ()
@property (nonatomic, copy) TabBarVCDidAppearSelectIndexHandler __nullable didAppearSelectIndexHandler;
@property (nonatomic, assign) NSInteger willSelectIndex;   ///< 记录将要选中的索引
@property (nonatomic, assign) BOOL hasSetWillSelectIndex;  ///< 是否已经设置过将要选中的索引
@end

@implementation UITabBarController (HDKitCore)

#pragma mark - getters and setters
HDSynthesizeIdCopyProperty(didAppearSelectIndexHandler, setDidAppearSelectIndexHandler);
HDSynthesizeBOOLProperty(hasSetWillSelectIndex, setHasSetWillSelectIndex);

- (void)setWillSelectIndex:(NSInteger)willSelectIndex {
    [self willChangeValueForKey:@"willSelectIndex"];
    objc_setAssociatedObject(self, @selector(willSelectIndex), [NSNumber numberWithInteger:willSelectIndex], OBJC_ASSOCIATION_ASSIGN);
    [self didChangeValueForKey:@"willSelectIndex"];

    self.hasSetWillSelectIndex = true;
}

- (NSInteger)willSelectIndex {
    return [objc_getAssociatedObject(self, _cmd) integerValue];
}

#pragma mark - public methods
- (void)addTransitionAnimationForWillSelectIndex:(NSInteger)willSelectIndex duration:(NSTimeInterval)duration {
    CATransition *animation = [CATransition animation];
    animation.duration = duration;
    animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    animation.type = kCATransitionPush;
    if (self.selectedIndex > willSelectIndex) {
        animation.subtype = kCATransitionFromLeft;
    } else {
        animation.subtype = kCATransitionFromRight;
    }
    [[[self valueForKey:@"_viewControllerTransitionView"] layer] addAnimation:animation forKey:@"animation"];
}

- (void)setTabBarVCDidAppearSelectIndexHandler:(TabBarVCDidAppearSelectIndexHandler __nullable)didAppearSelectIndexHandler {
    self.didAppearSelectIndexHandler = didAppearSelectIndexHandler;
}

- (void)setTabBarVCDidAppearSelectIndexHandler:(TabBarVCDidAppearSelectIndexHandler __nullable)didAppearSelectIndexHandler willSelectindex:(NSUInteger)willSelectindex {
    self.didAppearSelectIndexHandler = didAppearSelectIndexHandler;
    self.willSelectIndex = willSelectindex;
}

- (void)performDidAppearSelectIndexHandler {
    // 双重保护
    if (self.hasSetWillSelectIndex && self.willSelectIndex >= 0 && self.willSelectIndex < self.viewControllers.count) {
        self.selectedIndex = self.willSelectIndex;
        // 执行完就重置，保证只能执行一次
        self.willSelectIndex = -1;
    }

    if (self.didAppearSelectIndexHandler) {
        self.didAppearSelectIndexHandler();
        // 清空防止重复执行，保证一次回调设置只能执行一次
        self.didAppearSelectIndexHandler = nil;
    }
}
@end
