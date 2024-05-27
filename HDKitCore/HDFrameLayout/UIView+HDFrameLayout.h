//
//  UIView+HDFrameLayout.h
//  HDKitCore
//
//  Created by VanJay on 2019/4/20.
//  Copyright © 2019 chaos network technology. All rights reserved.
//

#import "HDFrameLayoutMaker.h"
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIView (HDFrameLayout)
@property (nonatomic, assign) CGFloat left;
@property (nonatomic, assign) CGFloat right;
@property (nonatomic, assign) CGFloat top;
@property (nonatomic, assign) CGFloat bottom;
@property (nonatomic, assign) CGFloat centerX;
@property (nonatomic, assign) CGFloat centerY;
@property (nonatomic, assign) CGPoint origin;
@property (nonatomic, assign) CGFloat width;
@property (nonatomic, assign) CGFloat height;
@property (nonatomic, assign) CGSize size;

- (void)hd_makeFrameLayout:(void (^)(HDFrameLayoutMaker *make))block;
@end

NS_ASSUME_NONNULL_END
