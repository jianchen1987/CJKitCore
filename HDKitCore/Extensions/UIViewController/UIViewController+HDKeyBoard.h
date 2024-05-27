//
//  UIViewController+HDKeyBoard.h
//  HDKitCore
//
//  Created by VanJay on 2019/11/6.
//  Copyright © 2019 chaos network technology. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIViewController (HDKeyBoard)
/// 是否开启，由于 hook 的是 viewDidLoad 方法，设置此属性请写在 [super viewDidLoad] 之前
@property (nonatomic, assign) BOOL hd_enableKeyboardRespond;
/** 根据键盘来移动的控件（可选项），默认是 self.view 改变 origin.y 来移动 */
@property (nonatomic, strong) UIView *hd_needMoveView;
/** 控件所移动的总距离（只读）*/
@property (nonatomic, assign, readonly) CGFloat hd_moveDistance;
/** 焦点所在的控件相对窗口的最低点（只读）*/
@property (nonatomic, assign, readonly) CGFloat hd_currentEditViewBottom;
/** 焦点所在的控件 */
@property (nonatomic, strong) UIView *hd_currentEditView;
@end
