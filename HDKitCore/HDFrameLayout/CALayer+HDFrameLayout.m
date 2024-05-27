//
//  CALayer+HDFrameLayout.m
//  HDKitCore
//
//  Created by VanJay on 2019/10/30.
//  Copyright © 2019 chaos network technology. All rights reserved.
//

#import "CALayer+HDFrameLayout.h"

@implementation CALayer (HDFrameLayout)

- (CGFloat)hd_left {
    return self.frame.origin.x;
}

- (void)setHd_left:(CGFloat)x {
    CGRect frame = self.frame;
    frame.origin.x = x;
    self.frame = frame;
}

- (CGFloat)hd_top {
    return self.frame.origin.y;
}

- (void)setHd_top:(CGFloat)y {
    CGRect frame = self.frame;
    frame.origin.y = y;
    self.frame = frame;
}

- (CGFloat)hd_right {
    return self.frame.origin.x + self.frame.size.width;
}

- (void)setHd_right:(CGFloat)right {
    CGRect frame = self.frame;
    frame.origin.x = right - frame.size.width;
    self.frame = frame;
}

- (CGFloat)hd_bottom {
    return self.frame.origin.y + self.frame.size.height;
}

- (void)setHd_bottom:(CGFloat)bottom {
    CGRect frame = self.frame;
    frame.origin.y = bottom - frame.size.height;
    self.frame = frame;
}

- (CGFloat)hd_centerX {
    return self.position.x;
}

- (void)setHd_centerX:(CGFloat)centerX {
    self.position = CGPointMake(centerX, self.position.y);
}

- (CGFloat)hd_centerY {
    return self.position.y;
}

- (void)setHd_centerY:(CGFloat)centerY {
    self.position = CGPointMake(self.position.x, centerY);
}

- (CGFloat)hd_width {
    return self.frame.size.width;
}

- (void)setHd_width:(CGFloat)width {
    CGRect frame = self.frame;
    frame.size.width = width;
    self.frame = frame;
}

- (CGFloat)hd_height {
    return self.frame.size.height;
}

- (void)setHd_height:(CGFloat)height {
    CGRect frame = self.frame;
    frame.size.height = height;
    self.frame = frame;
}

- (CGPoint)hd_origin {
    return self.frame.origin;
}

- (void)setHd_origin:(CGPoint)origin {
    CGRect frame = self.frame;
    frame.origin = origin;
    self.frame = frame;
}

- (CGSize)hd_size {
    return self.frame.size;
}

- (void)setHd_size:(CGSize)size {
    CGRect frame = self.frame;
    frame.size = size;
    self.frame = frame;
}

- (void)hd_makeFrameLayout:(void (^)(HDFrameLayoutMaker *make))block {
    HDFrameLayoutMaker *make = [[HDFrameLayoutMaker alloc] initWithLayer:self];
    block(make);
    [make renderLayerFrame];
}
@end
