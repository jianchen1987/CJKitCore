//
//  HDWeakTimer.h
//  HDKitCore
//
//  Created by VanJay on 16/1/3.
//  Copyright © 2019 chaos network technology. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void (^HDTimerHandler)(id userInfo);

@interface HDWeakTimer : NSObject

/**
 *  创建一个不会强引用self的定时器
 */
+ (NSTimer *)scheduledTimerWithTimeInterval:(NSTimeInterval)interval
                                     target:(id)aTarget
                                   selector:(SEL)aSelector
                                   userInfo:(id)userInfo
                                    repeats:(BOOL)repeats;

/**
 *  创建一个在BLOCK执行目标事件的定时器
 */
+ (NSTimer *)scheduledTimerWithTimeInterval:(NSTimeInterval)interval
                                      block:(HDTimerHandler)block
                                   userInfo:(id)userInfo
                                    repeats:(BOOL)repeats;

@end
