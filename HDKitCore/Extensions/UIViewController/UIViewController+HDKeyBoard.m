//
//  UIViewController+HDKeyBoard.m
//  HDKitCore
//
//  Created by VanJay on 2019/11/6.
//  Copyright © 2019 chaos network technology. All rights reserved.
//

#import "HDAssociatedObjectHelper.h"
#import "NSObject+HD_Swizzle.h"
#import "UIViewController+HDKeyBoard.h"

/// 建立中间处理对象， dealloc 时移除通知监听
@interface UIViewControllerKeyboardObseverMediator : NSObject
@property (nonatomic, copy) void (^keyboardWillShowBlock)(NSNotification *notification);
@property (nonatomic, copy) void (^keyboardWillHideBlock)(NSNotification *notification);
@property (nonatomic, copy) void (^keyboardFrameWillChangeBlock)(NSNotification *notification);
@end

@implementation UIViewControllerKeyboardObseverMediator
- (void)dealloc {
    [self resignNotifications];
}

#pragma mark - notification
- (void)keyboardWillShow:(NSNotification *)notification {
    !self.keyboardWillShowBlock ?: self.keyboardWillShowBlock(notification);
}

- (void)keyboardWillHide:(NSNotification *)notification {
    !self.keyboardWillHideBlock ?: self.keyboardWillHideBlock(notification);
}

- (void)keyboardFrameWillChange:(NSNotification *)notification {
    !self.keyboardFrameWillChangeBlock ?: self.keyboardFrameWillChangeBlock(notification);
}

#pragma mark - resign Notification
- (void)resignNotifications {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardDidChangeFrameNotification object:nil];
}
@end

@interface UIViewController ()
/// 观察者
@property (nonatomic, strong) UIViewControllerKeyboardObseverMediator *keyboardObseverMediator;
@end

@implementation UIViewController (HDKeyBoard)

+ (void)load {
    [self hd_swizzleInstanceMethod:@selector(viewDidLoad) withMethod:@selector(hd_keyboardViewDidLoad)];
}

- (void)hd_keyboardViewDidLoad {

    [self hd_keyboardViewDidLoad];

    if (!self.hd_enableKeyboardRespond) return;

    self.keyboardObseverMediator = UIViewControllerKeyboardObseverMediator.new;
    [self registerNotifications];

    __weak __typeof(self) weakSelf = self;
    self.keyboardObseverMediator.keyboardWillShowBlock = ^(NSNotification *notification) {
        __strong __typeof(weakSelf) self = weakSelf;
        [self keyboardWillShow:notification];
    };
    self.keyboardObseverMediator.keyboardWillHideBlock = ^(NSNotification *notification) {
        __strong __typeof(weakSelf) self = weakSelf;
        [self keyboardWillHide:notification];
    };
    self.keyboardObseverMediator.keyboardFrameWillChangeBlock = ^(NSNotification *notification) {
        __strong __typeof(weakSelf) self = weakSelf;
        [self keyboardFrameWillChange:notification];
    };
}

- (void)registerNotifications {
    // 处理键盘相关
    [[NSNotificationCenter defaultCenter] addObserver:self.keyboardObseverMediator selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self.keyboardObseverMediator selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self.keyboardObseverMediator selector:@selector(keyboardFrameWillChange:) name:UIKeyboardDidChangeFrameNotification object:nil];
}

#pragma mark - calculate
- (void)calculateCurrentEditViewBottomAndBindMoveView {
    UIView *editingView = self.private_hd_currentEditView;
    UIWindow *window = self.hd_keyWindow;
    CGRect viewRectToKeyWindow = [editingView convertRect:editingView.bounds toView:window];
    CGFloat bottom = CGRectGetMaxY(viewRectToKeyWindow);
    self.hd_currentEditViewBottom = bottom;

    if (!self.hd_needMoveView) {
        self.hd_needMoveView = self.view;
    }
}

- (UIView *)private_hd_currentEditView {
    UIView *currentEditView;
    if (self.hd_currentEditView) {
        currentEditView = self.hd_currentEditView;
    } else {
        currentEditView = [self findCurrentEditViewInView:self.view];
    }
    return currentEditView;
}

- (UIView *)findCurrentEditViewInView:(UIView *)view {
    for (UIView *childView in view.subviews) {
        if ([childView respondsToSelector:@selector(isFirstResponder)] && [childView isFirstResponder]) {
            return childView;
        }
        UIView *result = [self findCurrentEditViewInView:childView];
        if (result) {
            return result;
        }
    }
    return nil;
}

#pragma mark - Notification
- (BOOL)keyboardWillShow:(NSNotification *)notification {
    if (!self.hd_enableKeyboardRespond) return false;

    [self calculateCurrentEditViewBottomAndBindMoveView];

    CGFloat animationDuration = [[[notification userInfo] objectForKey:UIKeyboardAnimationDurationUserInfoKey] floatValue];
    CGRect keyboardBounds = [[[notification userInfo] objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];

    // 键盘是否挡住输入框，h < 0 则挡住了
    CGFloat h = keyboardBounds.origin.y - self.hd_currentEditViewBottom;
    if (h < 0) {
        [self handleMoveDistance:h animateWithDuration:animationDuration];
    }
    return YES;
}

- (BOOL)keyboardWillHide:(NSNotification *)notification {
    if (!self.hd_enableKeyboardRespond) return false;

    CGFloat animationDuration = [[[notification userInfo] objectForKey:UIKeyboardAnimationDurationUserInfoKey] floatValue];
    [self handleMoveDistance:(-self.hd_moveDistance) animateWithDuration:animationDuration];

    return YES;
}

- (BOOL)keyboardFrameWillChange:(NSNotification *)notification {
    if (!self.hd_enableKeyboardRespond || self.hd_moveDistance == 0) {
        return false;
    }

    CGFloat animationDuration = [[[notification userInfo] objectForKey:UIKeyboardAnimationDurationUserInfoKey] floatValue];
    CGRect keyboardBounds = [[[notification userInfo] objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];

    // 键盘是否挡住输入框，h < 0 则挡住了
    CGFloat h = keyboardBounds.origin.y - (self.hd_currentEditViewBottom + self.hd_moveDistance);
    if (h < 0) {
        [self handleMoveDistance:h animateWithDuration:animationDuration];
    }
    return YES;
}

#pragma mark - Handle
- (void)handleMoveDistance:(CGFloat)distance animateWithDuration:(NSTimeInterval)duration {
    [UIView animateWithDuration:duration
                          delay:0.0
                        options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         [self moveNeedScrollViewDistance:distance];
                         self.hd_moveDistance += distance;
                     }
                     completion:^(BOOL finished){

                     }];
}

- (void)moveNeedScrollViewDistance:(CGFloat)distance {
    UIView *view = self.hd_needMoveView;
    view.frame = CGRectMake(view.frame.origin.x, view.frame.origin.y + distance, view.frame.size.width, view.frame.size.height);
}

#pragma mark - get keyWindow
- (UIWindow *)hd_keyWindow {
    UIView *textFieldView = self.private_hd_currentEditView;
    if (textFieldView.window) {
        return textFieldView.window;
    } else {
        static __weak UIWindow *cachedKeyWindow = nil;
        UIWindow *originalKeyWindow = nil;
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 130000
        if (@available(iOS 13.0, *)) {
            NSSet<UIScene *> *connectedScenes = [UIApplication sharedApplication].connectedScenes;
            for (UIScene *scene in connectedScenes) {
                if (scene.activationState == UISceneActivationStateForegroundActive && [scene isKindOfClass:[UIWindowScene class]]) {
                    UIWindowScene *windowScene = (UIWindowScene *)scene;
                    for (UIWindow *window in windowScene.windows) {
                        if (window.isKeyWindow) {
                            originalKeyWindow = window;
                            break;
                        }
                    }
                }
            }
        } else
#endif
        {
#if __IPHONE_OS_VERSION_MIN_REQUIRED < 130000
            originalKeyWindow = [UIApplication sharedApplication].keyWindow;
#endif
        }
        if (originalKeyWindow) {
            cachedKeyWindow = originalKeyWindow;
        }
        return cachedKeyWindow;
    }
}

#pragma mark - runtime getter && setter
HDSynthesizeBOOLProperty(hd_enableKeyboardRespond, setHd_enableKeyboardRespond);
HDSynthesizeCGFloatProperty(hd_moveDistance, setHd_moveDistance);
HDSynthesizeCGFloatProperty(hd_currentEditViewBottom, setHd_currentEditViewBottom);
HDSynthesizeIdWeakProperty(hd_needMoveView, setHd_needMoveView);
HDSynthesizeIdWeakProperty(hd_currentEditView, setHd_currentEditView);

HDSynthesizeIdStrongProperty(keyboardObseverMediator, setKeyboardObseverMediator);
@end
