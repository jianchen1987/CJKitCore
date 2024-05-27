//
//  HDAnimationWeakDelegate.m
//  HDKitCore
//
//  Created by Chaos on 2021/5/17.
//

#import "HDAnimationWeakDelegate.h"

@implementation HDAnimationWeakDelegateManager

- (void)animationDidStart:(CAAnimation *)anim {
    if (_delegate && [_delegate respondsToSelector:@selector(animationDidStart:)]) {
        [_delegate animationDidStart:anim];
    }
}

- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag {
    if (_delegate && [_delegate respondsToSelector:@selector(animationDidStop:finished:)]) {
        [_delegate animationDidStop:anim finished:flag];
    }
}

@end
