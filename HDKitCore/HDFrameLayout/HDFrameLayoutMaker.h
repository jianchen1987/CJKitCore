//
//  HDFrameLayoutMaker.h
//  HDKitCore
//
//  Created by VanJay on 2019/4/20.
//  Copyright © 2019 chaos network technology. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface HDFrameLayoutMaker : NSObject

- (instancetype)initWithView:(UIView *)view;
- (instancetype)initWithLayer:(CALayer *)layer;

/**
 使用此方法参数需包装成 NSValue，使用 @(value) 或者 [NSValue valueWith:xxx] 麻烦，请使用 equalToValue 方法
 */
- (HDFrameLayoutMaker * (^)(id to))equalTo;

/**
 使用此方法参数需包装成 NSValue，使用 @(value) 或者 [NSValue valueWith:xxx] 麻烦，请使用 equalToValue 方法
 */
- (HDFrameLayoutMaker * (^)(id to))hd_equalTo;

/**
 设置除 origin、origin、size 之外的属性
 */
- (HDFrameLayoutMaker * (^)(CGFloat to))valueEqualTo;

/**
 只用来设置 origin
 */
- (HDFrameLayoutMaker * (^)(CGPoint to))originEqualTo;

/**
 只用来设置 size
 */
- (HDFrameLayoutMaker * (^)(CGSize to))sizeEqualTo;

/**
  只用来设置 center
 */
- (HDFrameLayoutMaker * (^)(CGPoint to))centerEqualTo;

/**
 设置偏移，对 origin、size、center 无效
 */
- (HDFrameLayoutMaker * (^)(CGFloat offset))offset;

/**
 设置偏移，对 origin、size、center 无效
 */
- (HDFrameLayoutMaker * (^)(CGFloat offset))hd_offset;

@property (nonatomic, assign) HDFrameLayoutMaker *left;
@property (nonatomic, assign) HDFrameLayoutMaker *right;
@property (nonatomic, assign) HDFrameLayoutMaker *top;
@property (nonatomic, assign) HDFrameLayoutMaker *bottom;
@property (nonatomic, assign) HDFrameLayoutMaker *width;
@property (nonatomic, assign) HDFrameLayoutMaker *height;
@property (nonatomic, assign) HDFrameLayoutMaker *centerX;
@property (nonatomic, assign) HDFrameLayoutMaker *centerY;
@property (nonatomic, assign) HDFrameLayoutMaker *center;
@property (nonatomic, assign) HDFrameLayoutMaker *origin;
@property (nonatomic, assign) HDFrameLayoutMaker *size;

- (void)render;
- (void)renderLayerFrame;

@end

NS_ASSUME_NONNULL_END
