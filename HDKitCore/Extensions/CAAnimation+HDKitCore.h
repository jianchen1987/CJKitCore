//
//  CAAnimation+HDKitCore.h
//  HDKitCore
//
//  Created by VanJay on 16/4/12.
//  Copyright © 2019 chaos network technology. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>

@interface CAAnimation (HDKitCore)
/**
 *  为图层添加动画
 *
 *  @param time        动画时长
 *  @param repeatCount 重复次数
 *  @param keyPath     keyPath
 *  @param fromValue   初始值
 *  @param toValue     结束直
 */
+ (CABasicAnimation *)animationWithDuration:(float)time repeatCount:(float)repeatCount keyPath:(NSString *)keyPath fromValue:(id)fromValue toValue:(id)toValue;
/**
 *  创建CASpringAnimation动画
 *
 *  @param keyPath         关键路径
 *  @param mass            质量越大，惯性越大
 *  @param damping         越大停止越快
 *  @param stiffness       越大运动越快
 *  @param initialVelocity 速率为正数时，速度方向与运动方向一致，速率为负数时，速度方向与运动方向相反
 *  @param fromValue       开始值
 *  @param toValue         结束值
 */
+ (CASpringAnimation *)springAnimationWithKeyPath:(NSString *)keyPath mass:(CGFloat)mass damping:(CGFloat)damping stiffness:(CGFloat)stiffness initialVelocity:(CGFloat)initialVelocity fromValue:(id)fromValue toValue:(id)toValue API_AVAILABLE(ios(9.0));

/**
 缩放动画

 @param duration 时长
 @param repeatCount 次数
 @param fromValue 起始值
 @param toValue 结束值
 */
+ (CABasicAnimation *)scaleAnimationWithDuration:(NSTimeInterval)duration repeatCount:(NSInteger)repeatCount fromValue:(id)fromValue toValue:(id)toValue;

/**
 重力效果弹跳

 @param duration 时长
 */
- (CAKeyframeAnimation *)gravityElasticAnimationWithDuration:(NSTimeInterval)duration;
@end
