//
//  UITableView+HD.h
//  HDKitCore
//
//  Created by VanJay on 2019/12/30.
//  Copyright © 2019 chaos network technology. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UITableView (HDKitCore)

/// 删除指定行
/// @param index 行
/// @param animated 是否带动画
- (void)hd_deleteDataAtIndex:(NSInteger)index animated:(BOOL)animated;

/// 删除某些行
/// @param indexPaths 行数组
/// @param animated 是否带动画
- (void)hd_deleteDataAtIndexPaths:(NSArray<NSIndexPath *> *)indexPaths animated:(BOOL)animated;

/// 刷新某行
/// @param index 行
/// @param animated 是否带动画
- (void)hd_reloadDataAtIndex:(NSInteger)index animated:(BOOL)animated;

/// 刷新某些行
/// @param indexPaths 行数组
/// @param animated 是否带动画
- (void)hd_reloadDataAtIndexPaths:(NSArray<NSIndexPath *> *)indexPaths animated:(BOOL)animated;

/// 所有行数
- (NSInteger)hd_totalDataCount;

/// 是否有数据
- (BOOL)hd_hasData;

/**
 等同于 UITableView 自 iOS 11 开始新增的同名方法，但兼容 iOS 11 以下的系统使用。

 @param updates insert/delete/reload/move calls
 @param completion completion callback
 */
- (void)hd_performBatchUpdates:(void(NS_NOESCAPE ^ _Nullable)(void))updates completion:(void (^_Nullable)(BOOL finished))completion;
@end

NS_ASSUME_NONNULL_END
