
//
//  HDFrameLayoutMaker.m
//  HDKitCore
//
//  Created by VanJay on 2019/4/20.
//  Copyright © 2019 chaos network technology. All rights reserved.
//

#import "HDFrameLayoutMaker.h"
#import "CALayer+HDFrameLayout.h"
#import "HDFrameLayoutUtils.h"
#import "UIView+HDFrameLayout.h"

typedef NS_ENUM(NSInteger, HDFrameLayoutMakerType) {
    HDFrameLayoutMakerTypeHorizontal = 0,
    HDFrameLayoutMakerTypeVertical,
    HDFrameLayoutMakerTypeOrigin,
    HDFrameLayoutMakerTypeSize,
    HDFrameLayoutMakerTypeCenter
};

static NSString *const kHDFrameLayoutKeyDefault = @"kHDFrameLayoutKeyDefault";
static NSString *const kHDFrameLayoutKeyWidth = @"kHDFrameLayoutKeyWidth";
static NSString *const kHDFrameLayoutKeyHeight = @"kHDFrameLayoutKeyHeight";
static NSString *const kHDFrameLayoutKeyLeft = @"kHDFrameLayoutKeyLeft";
static NSString *const kHDFrameLayoutKeyRight = @"kHDFrameLayoutKeyRight";
static NSString *const kHDFrameLayoutKeyTop = @"kHDFrameLayoutKeyTop";
static NSString *const kHDFrameLayoutKeyBottom = @"kHDFrameLayoutKeyBottom";
static NSString *const kHDFrameLayoutKeyCenterX = @"kHDFrameLayoutKeyCenterX";
static NSString *const kHDFrameLayoutKeyCenterY = @"kHDFrameLayoutKeyCenterY";
static NSString *const kHDFrameLayoutKeyOrigin = @"kHDFrameLayoutKeyOrigin";
static NSString *const kHDFrameLayoutKeySize = @"kHDFrameLayoutKeySize";
static NSString *const kHDFrameLayoutKeyCenter = @"kHDFrameLayoutKeyCenter";

@interface HDFrameLayoutMaker ()

@property (nonatomic, strong) UIView *view;
@property (nonatomic, strong) CALayer *layer;
@property (nonatomic, copy) NSString *key;

@property (nonatomic, assign) HDFrameLayoutMakerType type;
@property (nonatomic, strong) NSMutableDictionary *layoutHorizontal;
@property (nonatomic, strong) NSMutableDictionary *layoutVertical;

@property (nonatomic, assign) CGFloat frameWidth;
@property (nonatomic, assign) CGFloat frameHeight;
@property (nonatomic, assign) CGFloat frameLeft;
@property (nonatomic, assign) CGFloat frameRight;
@property (nonatomic, assign) CGFloat frameTop;
@property (nonatomic, assign) CGFloat frameBottom;
@property (nonatomic, assign) CGFloat frameCenterX;
@property (nonatomic, assign) CGFloat frameCenterY;
@property (nonatomic, assign) CGPoint frameOrigin;
@property (nonatomic, assign) CGSize frameSize;

@end

@implementation HDFrameLayoutMaker
- (instancetype)initWithView:(UIView *)view {
    self = [super init];
    if (self) {
        self.view = view;
        [self setup];
    }
    return self;
}

- (instancetype)initWithLayer:(CALayer *)layer {
    self = [super init];
    if (self) {
        self.layer = layer;
        [self setup];
    }
    return self;
}

- (void)setup {

    self.key = kHDFrameLayoutKeyDefault;

    self.frameWidth = -0.1f;
    self.frameHeight = -0.1f;

    self.frameCenterX = -0.1f;
    self.frameCenterY = -0.1f;

    self.layoutHorizontal = [[NSMutableDictionary alloc] initWithCapacity:0];
    self.layoutVertical = [[NSMutableDictionary alloc] initWithCapacity:0];
}

- (HDFrameLayoutMaker *)width {
    self.key = kHDFrameLayoutKeyWidth;
    self.type = HDFrameLayoutMakerTypeHorizontal;
    return self;
}

- (HDFrameLayoutMaker *)height {
    self.key = kHDFrameLayoutKeyHeight;
    self.type = HDFrameLayoutMakerTypeVertical;
    return self;
}

- (HDFrameLayoutMaker *)left {
    self.key = kHDFrameLayoutKeyLeft;
    self.type = HDFrameLayoutMakerTypeHorizontal;
    return self;
}

- (HDFrameLayoutMaker *)right {
    self.key = kHDFrameLayoutKeyRight;
    self.type = HDFrameLayoutMakerTypeHorizontal;
    return self;
}

- (HDFrameLayoutMaker *)top {
    self.key = kHDFrameLayoutKeyTop;
    self.type = HDFrameLayoutMakerTypeVertical;
    return self;
}

- (HDFrameLayoutMaker *)bottom {
    self.key = kHDFrameLayoutKeyBottom;
    self.type = HDFrameLayoutMakerTypeVertical;
    return self;
}

- (HDFrameLayoutMaker *)centerX {
    self.key = kHDFrameLayoutKeyCenterX;
    self.type = HDFrameLayoutMakerTypeHorizontal;
    return self;
}

- (HDFrameLayoutMaker *)centerY {
    self.key = kHDFrameLayoutKeyCenterY;
    self.type = HDFrameLayoutMakerTypeVertical;
    return self;
}

- (HDFrameLayoutMaker *)origin {
    self.key = kHDFrameLayoutKeyOrigin;
    self.type = HDFrameLayoutMakerTypeOrigin;
    return self;
}

- (HDFrameLayoutMaker *)size {
    self.key = kHDFrameLayoutKeySize;
    self.type = HDFrameLayoutMakerTypeSize;
    return self;
}

- (HDFrameLayoutMaker *)center {
    self.key = kHDFrameLayoutKeyCenter;
    self.type = HDFrameLayoutMakerTypeCenter;
    return self;
}

- (HDFrameLayoutMaker * (^)(id to))equalTo {
    return [self hd_equalTo];
}

- (HDFrameLayoutMaker * (^)(id to))hd_equalTo {
    return ^id(id value) {
        switch (self.type) {
            case HDFrameLayoutMakerTypeHorizontal:
                [self.layoutHorizontal setValue:value forKey:self.key];
                break;
            case HDFrameLayoutMakerTypeVertical:
                [self.layoutVertical setValue:value forKey:self.key];
                break;
            case HDFrameLayoutMakerTypeOrigin: {
                NSValue *pointValue = WJBox(value);
                CGPoint point = pointValue.CGPointValue;
                [self.layoutHorizontal setValue:@(point.x) forKey:kHDFrameLayoutKeyLeft];
                [self.layoutVertical setValue:@(point.y) forKey:kHDFrameLayoutKeyTop];
                break;
            }
            case HDFrameLayoutMakerTypeSize: {
                NSValue *sizeValue = WJBox(value);
                CGSize size = sizeValue.CGSizeValue;
                [self.layoutHorizontal setValue:@(size.width) forKey:kHDFrameLayoutKeyWidth];
                [self.layoutVertical setValue:@(size.height) forKey:kHDFrameLayoutKeyHeight];
                break;
            }
            case HDFrameLayoutMakerTypeCenter: {
                NSValue *pointValue = WJBox(value);
                CGPoint point = pointValue.CGPointValue;
                [self.layoutHorizontal setValue:@(point.x) forKey:kHDFrameLayoutKeyCenterX];
                [self.layoutVertical setValue:@(point.y) forKey:kHDFrameLayoutKeyCenterY];
                break;
            }
            default:
                break;
        }

        return self;
    };
}

- (HDFrameLayoutMaker * (^)(CGFloat))valueEqualTo {
    return ^id(CGFloat value) {
        switch (self.type) {
            case HDFrameLayoutMakerTypeHorizontal:
                [self.layoutHorizontal setValue:@(value) forKey:self.key];
                break;
            case HDFrameLayoutMakerTypeVertical:
                [self.layoutVertical setValue:@(value) forKey:self.key];
                break;
            default:
                break;
        }

        return self;
    };
}

- (HDFrameLayoutMaker * (^)(CGPoint to))originEqualTo {
    return ^id(CGPoint value) {
        [self.layoutHorizontal setValue:@(value.x) forKey:kHDFrameLayoutKeyLeft];
        [self.layoutVertical setValue:@(value.y) forKey:kHDFrameLayoutKeyTop];
        return self;
    };
}

- (HDFrameLayoutMaker * (^)(CGSize to))sizeEqualTo {
    return ^id(CGSize value) {
        [self.layoutHorizontal setValue:@(value.width) forKey:kHDFrameLayoutKeyWidth];
        [self.layoutVertical setValue:@(value.height) forKey:kHDFrameLayoutKeyHeight];
        return self;
    };
}

- (HDFrameLayoutMaker * (^)(CGPoint to))centerEqualTo {
    return ^id(CGPoint value) {
        [self.layoutHorizontal setValue:@(value.x) forKey:kHDFrameLayoutKeyCenterX];
        [self.layoutVertical setValue:@(value.y) forKey:kHDFrameLayoutKeyCenterY];
        return self;
    };
}

- (HDFrameLayoutMaker * (^)(CGFloat offset))offset {
    return [self hd_offset];
}

- (HDFrameLayoutMaker *_Nonnull (^)(CGFloat))hd_offset {
    return ^id(CGFloat offset) {
        NSMutableDictionary *tempDictionary;

        switch (self.type) {
            case HDFrameLayoutMakerTypeHorizontal:
                tempDictionary = self.layoutHorizontal;
                break;
            case HDFrameLayoutMakerTypeVertical:
                tempDictionary = self.layoutVertical;
                break;
            default:
                break;
        }

        if (self.type == HDFrameLayoutMakerTypeHorizontal || self.type == HDFrameLayoutMakerTypeVertical) {
            CGFloat value = [[tempDictionary objectForKey:self.key] floatValue] + offset;
            [tempDictionary setValue:@(value) forKey:self.key];
        }
        return self;
    };
}

- (void)render {

    [self.view sizeToFit];

    id left = [self.layoutHorizontal objectForKey:kHDFrameLayoutKeyLeft];
    id right = [self.layoutHorizontal objectForKey:kHDFrameLayoutKeyRight];
    id width = [self.layoutHorizontal objectForKey:kHDFrameLayoutKeyWidth];
    id centerX = [self.layoutHorizontal objectForKey:kHDFrameLayoutKeyCenterX];

    id top = [self.layoutVertical objectForKey:kHDFrameLayoutKeyTop];
    id bottom = [self.layoutVertical objectForKey:kHDFrameLayoutKeyBottom];
    id height = [self.layoutVertical objectForKey:kHDFrameLayoutKeyHeight];
    id centerY = [self.layoutVertical objectForKey:kHDFrameLayoutKeyCenterY];

    if (left) {
        self.frameLeft = [left floatValue];

        if (width) {
            self.frameWidth = [width floatValue];
        } else if (right) {
            self.frameWidth = [right floatValue] - [left floatValue];
        } else {
        }
    } else if (width) {
        self.frameWidth = [width floatValue];

        if (right) {
            self.frameLeft = [right floatValue] - [width floatValue];
        } else {
        }

    } else if (right) {
        self.frameLeft = [right floatValue] - self.view.width;
    }

    if (top) {
        self.frameTop = [top floatValue];
        if (height) {
            self.frameHeight = [height floatValue];
        } else if (bottom) {
            self.frameHeight = [bottom floatValue] - [top floatValue];
        } else {
        }
    } else if (height) {
        self.frameHeight = [height floatValue];

        if (bottom) {
            self.frameTop = [bottom floatValue] - [height floatValue];
        } else {
        }

    } else if (bottom) {
        self.frameTop = [bottom floatValue] - self.view.height;
    }

    self.view.frame = CGRectMake(self.frameLeft,
                                 self.frameTop,
                                 self.frameWidth > 0 ? self.frameWidth : self.view.width,
                                 self.frameHeight > 0 ? self.frameHeight : self.view.height);

    if (centerX) {
        self.view.centerX = [centerX floatValue];
    }

    if (centerY) {
        self.view.centerY = [centerY floatValue];
    }
}

- (void)renderLayerFrame {

    id left = [self.layoutHorizontal objectForKey:kHDFrameLayoutKeyLeft];
    id right = [self.layoutHorizontal objectForKey:kHDFrameLayoutKeyRight];
    id width = [self.layoutHorizontal objectForKey:kHDFrameLayoutKeyWidth];
    id centerX = [self.layoutHorizontal objectForKey:kHDFrameLayoutKeyCenterX];

    id top = [self.layoutVertical objectForKey:kHDFrameLayoutKeyTop];
    id bottom = [self.layoutVertical objectForKey:kHDFrameLayoutKeyBottom];
    id height = [self.layoutVertical objectForKey:kHDFrameLayoutKeyHeight];
    id centerY = [self.layoutVertical objectForKey:kHDFrameLayoutKeyCenterY];

    if (left) {
        self.frameLeft = [left floatValue];

        if (width) {
            self.frameWidth = [width floatValue];
        } else if (right) {
            self.frameWidth = [right floatValue] - [left floatValue];
        } else {
        }
    } else if (width) {
        self.frameWidth = [width floatValue];

        if (right) {
            self.frameLeft = [right floatValue] - [width floatValue];
        } else {
        }

    } else if (right) {
        self.frameLeft = [right floatValue] - self.layer.hd_width;
    }

    if (top) {
        self.frameTop = [top floatValue];
        if (height) {
            self.frameHeight = [height floatValue];
        } else if (bottom) {
            self.frameHeight = [bottom floatValue] - [top floatValue];
        } else {
        }
    } else if (height) {
        self.frameHeight = [height floatValue];

        if (bottom) {
            self.frameTop = [bottom floatValue] - [height floatValue];
        } else {
        }

    } else if (bottom) {
        self.frameTop = [bottom floatValue] - self.layer.hd_height;
    }

    self.layer.frame = CGRectMake(self.frameLeft,
                                  self.frameTop,
                                  self.frameWidth > 0 ? self.frameWidth : self.layer.hd_width,
                                  self.frameHeight > 0 ? self.frameHeight : self.layer.hd_height);

    if (centerX) {
        self.layer.hd_centerX = [centerX floatValue];
    }

    if (centerY) {
        self.layer.hd_centerY = [centerY floatValue];
    }
}
@end
