//
//  CAAnimation+HDKitCore.m
//  HDKitCore
//
//  Created by VanJay on 16/4/12.
//  Copyright © 2019 chaos network technology. All rights reserved.
//

#import "CAAnimation+HDKitCore.h"

@implementation CAAnimation (HDKitCore)
+ (CABasicAnimation *)animationWithDuration:(float)time repeatCount:(float)repeatCount keyPath:(NSString *)keyPath fromValue:(id)fromValue toValue:(id)toValue {
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:keyPath];
    if (fromValue) {
        animation.fromValue = fromValue;
    }
    animation.toValue = toValue;
    animation.autoreverses = NO;
    animation.duration = time;
    animation.repeatCount = repeatCount;
    animation.removedOnCompletion = NO;
    animation.fillMode = kCAFillModeForwards;
    animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    return animation;
}

+ (CASpringAnimation *)springAnimationWithKeyPath:(NSString *)keyPath mass:(CGFloat)mass damping:(CGFloat)damping stiffness:(CGFloat)stiffness initialVelocity:(CGFloat)initialVelocity fromValue:(id)fromValue toValue:(id)toValue {

    CASpringAnimation *springAnimation = [CASpringAnimation animationWithKeyPath:keyPath];
    springAnimation.mass = mass;
    springAnimation.damping = damping;
    springAnimation.stiffness = stiffness;
    springAnimation.initialVelocity = initialVelocity;
    springAnimation.duration = springAnimation.settlingDuration;
    springAnimation.fromValue = fromValue;
    springAnimation.toValue = toValue;

    springAnimation.removedOnCompletion = NO;
    springAnimation.fillMode = kCAFillModeForwards;

    return springAnimation;
}

+ (CABasicAnimation *)scaleAnimationWithDuration:(NSTimeInterval)duration repeatCount:(NSInteger)repeatCount fromValue:(id)fromValue toValue:(id)toValue {
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
    animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    animation.duration = duration;
    animation.repeatCount = repeatCount;
    animation.removedOnCompletion = YES;
    animation.autoreverses = YES;
    animation.fromValue = fromValue;
    animation.toValue = toValue;
    return animation;
}

- (CAKeyframeAnimation *)gravityElasticAnimationWithDuration:(NSTimeInterval)duration {
    CAKeyframeAnimation *animation = [CAKeyframeAnimation animationWithKeyPath:@"transform.translation.y"];
    animation.values = @[@0.0, @-4.15, @-7.26, @-9.34, @-10.37, @-9.34, @-7.26, @-4.15, @0.0, @2.0, @-2.9, @-4.94, @-6.11, @-6.42, @-5.86, @-4.44, @-2.16, @0.0];
    animation.duration = duration;
    animation.beginTime = CACurrentMediaTime();
    animation.removedOnCompletion = YES;
    return animation;
}
@end
