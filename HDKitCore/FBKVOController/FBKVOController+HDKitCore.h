//
//  FBKVOController+HDKitCore.h
//  HDKitCore
//
//  Created by VanJay on 2019/4/29.
//  Copyright © 2019 chaos network technology. All rights reserved.
//

#import "KVOController.h"

NS_ASSUME_NONNULL_BEGIN

@interface FBKVOController (HDKitCore)
- (void)hd_observe:(nullable id)object keyPath:(NSString *_Nullable)keyPath block:(FBKVONotificationBlock _Nullable)block;

- (void)hd_observe:(nullable id)object keyPath:(NSString *_Nullable)keyPath action:(SEL _Nullable)action;
@end

NS_ASSUME_NONNULL_END
