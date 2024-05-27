//
//  UIButton+Block.h
//  HDKitCore
//
//  Created by VanJay on 2019/9/26.
//  Copyright © 2019 chaos network technology. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void (^ButtonBlock)(UIButton *_Nonnull btn);

NS_ASSUME_NONNULL_BEGIN

@interface UIButton (Block)
/**
 *  button 添加点击事件
 *
 *  @param block 点击回调
 */
- (void)addTouchUpInsideHandler:(ButtonBlock)block;

/**
 *  button 添加事件
 *
 *  @param block 时间回调
 *  @param controlEvents 点击的方式
 */
- (void)addEventHandler:(ButtonBlock)block forControlEvents:(UIControlEvents)controlEvents;
@end

NS_ASSUME_NONNULL_END
