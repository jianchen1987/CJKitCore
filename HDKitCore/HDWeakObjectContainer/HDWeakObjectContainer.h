//
//  HDWeakObjectContainer.h
//  HDKitCore
//
//  Created by VanJay on 2019/12/30.
//  Copyright © 2019 chaos network technology. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface HDWeakObjectContainer : NSObject

/// 将一个 object 包装到一个 HDWeakObjectContainer 里
- (instancetype)initWithObject:(id)object;

/// 获取原始对象 object，如果 object 已被释放则该属性返回 nil
@property (nonatomic, weak) id object;
@end

NS_ASSUME_NONNULL_END
