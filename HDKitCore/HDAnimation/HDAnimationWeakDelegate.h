//
//  HDAnimationWeakDelegate.h
//  HDKitCore
//
//  Created by Chaos on 2021/5/17.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@protocol HDAnimationWeakDelegate <NSObject>

@optional
- (void)animationDidStart:(CAAnimation *)anim;
- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag;

@end

@interface HDAnimationWeakDelegateManager : NSObject <CAAnimationDelegate>

@property (weak, nonatomic) id<HDAnimationWeakDelegate> delegate;

@end

NS_ASSUME_NONNULL_END
