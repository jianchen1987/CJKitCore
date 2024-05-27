//
//  UIScrollView+HDKitCore.m
//  HDKitCore
//
//  Created by VanJay on 2019/6/17.
//  Copyright © 2019 chaos network technology. All rights reserved.
//

#import "HDAssociatedObjectHelper.h"
#import "UIScrollView+HDKitCore.h"

@implementation UIScrollViewIgnoreSpaceModel
- (instancetype)init {
    self = [super init];
    if (self) {
        self.minX = -1;
        self.maxX = -1;
        self.minY = -1;
        self.maxY = -1;
    }
    return self;
}

+ (instancetype)ignoreSpaceWithMinX:(CGFloat)minX maxX:(CGFloat)maxX minY:(CGFloat)minY maxY:(CGFloat)maxY {
    return [[self alloc] initWithMinX:minX maxX:maxX minY:minY maxY:maxY];
}

- (instancetype)initWithMinX:(CGFloat)minX maxX:(CGFloat)maxX minY:(CGFloat)minY maxY:(CGFloat)maxY {
    if (self = [super init]) {
        self.minX = minX;
        self.maxX = maxX;
        self.minY = minY;
        self.maxY = maxY;
    }
    return self;
}
@end

@interface UIScrollView ()
@property (nonatomic, strong) NSMutableDictionary<NSString *, EndScrollingHandler> *endScrollingHandlers;  ///< 回调集合
@end

@implementation UIScrollView (HDKitCore)
- (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event {
    UIScrollViewIgnoreSpaceModel *ignoreSpaceObj = self.hd_ignoreSpace;

    if (!ignoreSpaceObj) return [super pointInside:point withEvent:event];

    // 加上 insets 得距离
    UIEdgeInsets inset = self.contentInset;

    // 是否要转换点相对于屏幕
    CGPoint convertedPoint = point;
    if (self.convertPointToEachPage) {
        convertedPoint.x = (NSInteger)point.x % (NSInteger)CGRectGetWidth(self.frame);
        convertedPoint.y = (NSInteger)point.x % (NSInteger)CGRectGetHeight(self.frame);
    }
    CGFloat pointX = convertedPoint.x + inset.left, pointY = convertedPoint.y + inset.top;
    BOOL shouldPointXIgnored = false, shouldPointYIgnored = false;
    BOOL isMinXGreaterThanMaxX = true, isMinYGreaterThanMaxY = true;
    if (ignoreSpaceObj.minX >= 0 && ignoreSpaceObj.maxX >= 0) {
        if (ignoreSpaceObj.maxX > ignoreSpaceObj.minX) {
            shouldPointXIgnored = pointX >= ignoreSpaceObj.minX && pointX <= ignoreSpaceObj.maxX;
        } else {
            isMinXGreaterThanMaxX = false;
        }
    }
    if (ignoreSpaceObj.minY >= 0 && ignoreSpaceObj.maxY >= 0) {
        if (ignoreSpaceObj.maxY > ignoreSpaceObj.minY) {
            shouldPointYIgnored = pointY >= ignoreSpaceObj.minY && pointY <= ignoreSpaceObj.maxY;
        } else {
            isMinYGreaterThanMaxY = false;
        }
    }

    if (shouldPointXIgnored && !isMinYGreaterThanMaxY) {
        shouldPointYIgnored = true;
    }
    if (shouldPointYIgnored && !isMinXGreaterThanMaxX) {
        shouldPointXIgnored = true;
    }

    if (shouldPointXIgnored && shouldPointYIgnored) return false;
    return [super pointInside:point withEvent:event];
}

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
    UIView *view = [super hitTest:point withEvent:event];

    if (self.conflictedClass.count > 0) {
        for (Class cls in self.conflictedClass) {
            if ([view.superview isMemberOfClass:cls]) {
                self.scrollEnabled = NO;
            } else {
                self.scrollEnabled = YES;
            }
        }
    }

    return view;
}

#pragma mark - public methods
- (void)registerEndScrollinghandler:(EndScrollingHandler)handler withKey:(NSString *)key {
    if (!key || ![key isKindOfClass:NSString.class] || key.length <= 0) return;

    [self.endScrollingHandlers setObject:handler forKey:key];
}

/// 触发滚动结束的回调
- (void)invokeEndScrollingHandler {

    for (EndScrollingHandler handler in self.endScrollingHandlers.allValues) {
        !handler ?: handler();
    }
}

#pragma mark - public methods
- (void)setIgnoreSpace:(UIScrollViewIgnoreSpaceModel *)ignoreSpace convertPointToEachPage:(BOOL)convertPointToEachPage {
    self.hd_ignoreSpace = ignoreSpace;
    self.convertPointToEachPage = convertPointToEachPage;
}

#pragma mark - getters and setters
HDSynthesizeIdStrongProperty(hd_ignoreSpace, setHd_ignoreSpace);
HDSynthesizeIdCopyProperty(conflictedClass, setConflictedClass);
HDSynthesizeBOOLProperty(convertPointToEachPage, setConvertPointToEachPage);

- (void)setIsScrolling:(BOOL)isScrolling {

    if (self.isScrolling == isScrolling) return;

    [self willChangeValueForKey:@"isScrolling"];
    objc_setAssociatedObject(self, @selector(isScrolling), @(isScrolling), OBJC_ASSOCIATION_ASSIGN);
    [self didChangeValueForKey:@"isScrolling"];

    if (!isScrolling) {
        [self invokeEndScrollingHandler];
    }
}

- (BOOL)isScrolling {
    return [objc_getAssociatedObject(self, _cmd) boolValue];
}

- (NSMutableDictionary<NSString *, EndScrollingHandler> *)endScrollingHandlers {
    NSMutableDictionary *table = objc_getAssociatedObject(self, _cmd);
    if (!table) {
        table = [NSMutableDictionary dictionary];

        [self willChangeValueForKey:@"endScrollingHandlers"];
        objc_setAssociatedObject(self, _cmd, table, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        [self didChangeValueForKey:@"endScrollingHandlers"];
    }
    return table;
}
@end
