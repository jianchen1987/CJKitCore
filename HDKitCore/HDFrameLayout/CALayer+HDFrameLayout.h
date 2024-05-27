//
//  CALayer+HDFrameLayout.h
//  HDKitCore
//
//  Created by VanJay on 2019/10/30.
//  Copyright © 2019 chaos network technology. All rights reserved.
//

#import "HDFrameLayoutMaker.h"
#import <QuartzCore/QuartzCore.h>

NS_ASSUME_NONNULL_BEGIN

@interface CALayer (HDFrameLayout)
@property (nonatomic, assign) CGFloat hd_left;
@property (nonatomic, assign) CGFloat hd_right;
@property (nonatomic, assign) CGFloat hd_top;
@property (nonatomic, assign) CGFloat hd_bottom;
@property (nonatomic, assign) CGFloat hd_centerX;
@property (nonatomic, assign) CGFloat hd_centerY;
@property (nonatomic, assign) CGPoint hd_origin;
@property (nonatomic, assign) CGFloat hd_width;
@property (nonatomic, assign) CGFloat hd_height;
@property (nonatomic, assign) CGSize hd_size;

- (void)hd_makeFrameLayout:(void (^)(HDFrameLayoutMaker *make))block;
@end

NS_ASSUME_NONNULL_END
