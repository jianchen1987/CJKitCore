//
//  UIScrollView+HDKitCore.h
//  HDKitCore
//
//  Created by VanJay on 2019/6/17.
//  Copyright © 2019 chaos network technology. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void (^EndScrollingHandler)(void);

NS_ASSUME_NONNULL_BEGIN

/// UIScrollView 忽略响应的坐标区间
@interface UIScrollViewIgnoreSpaceModel : NSObject
@property (nonatomic, assign) CGFloat minX;  ///< 最小 X 坐标
@property (nonatomic, assign) CGFloat maxX;  ///< 最大 X 坐标
@property (nonatomic, assign) CGFloat minY;  ///< 最小 Y 坐标
@property (nonatomic, assign) CGFloat maxY;  ///< 最大 Y 坐标

+ (instancetype)ignoreSpaceWithMinX:(CGFloat)minX maxX:(CGFloat)maxX minY:(CGFloat)minY maxY:(CGFloat)maxY;
- (instancetype)initWithMinX:(CGFloat)minX maxX:(CGFloat)maxX minY:(CGFloat)minY maxY:(CGFloat)maxY;
@end

@interface UIScrollView (HDKitCore)
@property (nonatomic, copy) NSArray<Class> *conflictedClass;                 ///< 手势冲突的类
@property (nonatomic, strong) UIScrollViewIgnoreSpaceModel *hd_ignoreSpace;  ///< 忽略响应的坐标区间
@property (nonatomic, assign) BOOL convertPointToEachPage;                   ///< 是否相对于每一页转换点坐标

/// 设置忽略响应的坐标区间
/// @param ignoreSpace 忽略响应的坐标区间
/// @param convertPointToEachPage 是否相对于每一页转换点坐标
- (void)setIgnoreSpace:(UIScrollViewIgnoreSpaceModel *)ignoreSpace convertPointToEachPage:(BOOL)convertPointToEachPage;

@property (nonatomic, assign) BOOL isScrolling;  ///< 是否正在滚动

/// 注册滚动结束的回调
/// @param handler 回调
/// @param key key
- (void)registerEndScrollinghandler:(EndScrollingHandler)handler withKey:(NSString *)key;

/// 触发滚动结束的回调
- (void)invokeEndScrollingHandler;
@end

NS_ASSUME_NONNULL_END
