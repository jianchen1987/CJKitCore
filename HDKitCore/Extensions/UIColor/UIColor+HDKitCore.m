//
//  UIColor+HDKitCore.m
//  HDKitCore
//
//  Created by VanJay on 2018/6/26.
//  Copyright © 2019 chaos network technology. All rights reserved.
//

#import "NSString+HDKitCore.h"
#import "UIColor+HDKitCore.h"

NSString *const HDCGColorOriginalColorBindKey = @"HDCGColorOriginalColorBindKey";

@implementation UIColor (RGBA)
- (RGBA)rgba {
    CGColorRef color = self.CGColor;
    RGBA rgba;

    CGColorSpaceRef colorSpaceRef = CGColorGetColorSpace(color);
    CGColorSpaceModel colorSpaceModel = CGColorSpaceGetModel(colorSpaceRef);
    const CGFloat *colorComponents = CGColorGetComponents(color);
    size_t colorComponentCount = CGColorGetNumberOfComponents(color);

    switch (colorSpaceModel) {
        case kCGColorSpaceModelMonochrome: {
            assert(colorComponentCount == 2);
            rgba = (RGBA){
                .r = colorComponents[0],
                .g = colorComponents[0],
                .b = colorComponents[0],
                .a = colorComponents[1]};
            break;
        }

        case kCGColorSpaceModelRGB: {
            assert(colorComponentCount == 4);
            rgba = (RGBA){
                .r = colorComponents[0],
                .g = colorComponents[1],
                .b = colorComponents[2],
                .a = colorComponents[3]};
            break;
        }

        default: {
            rgba = (RGBA){0, 0, 0, 0};
            break;
        }
    }

    return rgba;
}
@end

@implementation UIColor (HDKitCore)

+ (UIColor *)hd_colorWithHexString:(NSString *)hexString {
    if (hexString.length <= 0) return nil;

    NSString *colorString = [[hexString stringByReplacingOccurrencesOfString:@"#" withString:@""] uppercaseString];
    // 去除空格
    colorString = [colorString stringByReplacingOccurrencesOfString:@" " withString:@""];
    CGFloat alpha, red, blue, green;
    switch ([colorString length]) {
        case 3:  // #RGB
            alpha = 1.0f;
            red = [self colorComponentFrom:colorString start:0 length:1];
            green = [self colorComponentFrom:colorString start:1 length:1];
            blue = [self colorComponentFrom:colorString start:2 length:1];
            break;
        case 4:  // #ARGB
            alpha = [self colorComponentFrom:colorString start:0 length:1];
            red = [self colorComponentFrom:colorString start:1 length:1];
            green = [self colorComponentFrom:colorString start:2 length:1];
            blue = [self colorComponentFrom:colorString start:3 length:1];
            break;
        case 6:  // #RRGGBB
            alpha = 1.0f;
            red = [self colorComponentFrom:colorString start:0 length:2];
            green = [self colorComponentFrom:colorString start:2 length:2];
            blue = [self colorComponentFrom:colorString start:4 length:2];
            break;
        case 8:  // #AARRGGBB
            alpha = [self colorComponentFrom:colorString start:0 length:2];
            red = [self colorComponentFrom:colorString start:2 length:2];
            green = [self colorComponentFrom:colorString start:4 length:2];
            blue = [self colorComponentFrom:colorString start:6 length:2];
            break;
        default: {
            //            NSAssert(NO, @"Color value %@ is invalid. It should be a hex value of the form #RBG, #ARGB, #RRGGBB, or #AARRGGBB", hexString);
            return nil;
        } break;
    }
    return [UIColor colorWithRed:red green:green blue:blue alpha:alpha];
}

- (NSString *)hd_hexString {
    NSInteger alpha = self.hd_alpha * 255;
    NSInteger red = self.hd_red * 255;
    NSInteger green = self.hd_green * 255;
    NSInteger blue = self.hd_blue * 255;
    return [[NSString stringWithFormat:@"#%@%@%@%@",
                                       [self alignColorHexStringLength:[NSString hd_hexStringWithInteger:alpha]],
                                       [self alignColorHexStringLength:[NSString hd_hexStringWithInteger:red]],
                                       [self alignColorHexStringLength:[NSString hd_hexStringWithInteger:green]],
                                       [self alignColorHexStringLength:[NSString hd_hexStringWithInteger:blue]]] lowercaseString];
}

// 对于色值只有单位数的，在前面补一个0，例如“F”会补齐为“0F”
- (NSString *)alignColorHexStringLength:(NSString *)hexString {
    return hexString.length < 2 ? [@"0" stringByAppendingString:hexString] : hexString;
}

+ (CGFloat)colorComponentFrom:(NSString *)string start:(NSUInteger)start length:(NSUInteger)length {
    NSString *substring = [string substringWithRange:NSMakeRange(start, length)];
    NSString *fullHex = length == 2 ? substring : [NSString stringWithFormat:@"%@%@", substring, substring];
    unsigned hexComponent;
    [[NSScanner scannerWithString:fullHex] scanHexInt:&hexComponent];
    return hexComponent / 255.0;
}

- (CGFloat)hd_red {
    CGFloat r;
    if ([self getRed:&r green:0 blue:0 alpha:0]) {
        return r;
    }
    return 0;
}

- (CGFloat)hd_green {
    CGFloat g;
    if ([self getRed:0 green:&g blue:0 alpha:0]) {
        return g;
    }
    return 0;
}

- (CGFloat)hd_blue {
    CGFloat b;
    if ([self getRed:0 green:0 blue:&b alpha:0]) {
        return b;
    }
    return 0;
}

- (CGFloat)hd_alpha {
    CGFloat a;
    if ([self getRed:0 green:0 blue:0 alpha:&a]) {
        return a;
    }
    return 0;
}

- (CGFloat)hd_hue {
    CGFloat h;
    if ([self getHue:&h saturation:0 brightness:0 alpha:0]) {
        return h;
    }
    return 0;
}

- (CGFloat)hd_saturation {
    CGFloat s;
    if ([self getHue:0 saturation:&s brightness:0 alpha:0]) {
        return s;
    }
    return 0;
}

- (CGFloat)hd_brightness {
    CGFloat b;
    if ([self getHue:0 saturation:0 brightness:&b alpha:0]) {
        return b;
    }
    return 0;
}

- (UIColor *)hd_colorWithoutAlpha {
    CGFloat r;
    CGFloat g;
    CGFloat b;
    if ([self getRed:&r green:&g blue:&b alpha:0]) {
        return [UIColor colorWithRed:r green:g blue:b alpha:1];
    } else {
        return nil;
    }
}

- (UIColor *)hd_colorWithAlpha:(CGFloat)alpha backgroundColor:(UIColor *)backgroundColor {
    return [UIColor hd_colorWithBackendColor:backgroundColor frontColor:[self colorWithAlphaComponent:alpha]];
}

- (UIColor *)hd_colorWithAlphaAddedToWhite:(CGFloat)alpha {
    return [self hd_colorWithAlpha:alpha backgroundColor:UIColor.whiteColor];
}

- (UIColor *)hd_transitionToColor:(UIColor *)toColor progress:(CGFloat)progress {
    return [UIColor hd_colorFromColor:self toColor:toColor progress:progress];
}

- (BOOL)hd_colorIsDark {
    CGFloat red = 0.0, green = 0.0, blue = 0.0;
    if ([self getRed:&red green:&green blue:&blue alpha:0]) {
        float referenceValue = 0.411;
        float colorDelta = ((red * 0.299) + (green * 0.587) + (blue * 0.114));

        return 1.0 - colorDelta > referenceValue;
    }
    return YES;
}

- (UIColor *)hd_inverseColor {
    const CGFloat *componentColors = CGColorGetComponents(self.CGColor);
    UIColor *newColor = [[UIColor alloc] initWithRed:(1.0 - componentColors[0])
                                               green:(1.0 - componentColors[1])
                                                blue:(1.0 - componentColors[2])
                                               alpha:componentColors[3]];
    return newColor;
}

- (BOOL)hd_isSystemTintColor {
    return [self isEqual:[UIColor hd_systemTintColor]];
}

+ (UIColor *)hd_systemTintColor {
    static UIColor *systemTintColor = nil;
    if (!systemTintColor) {
        UIView *view = [[UIView alloc] init];
        systemTintColor = view.tintColor;
    }
    return systemTintColor;
}

+ (UIColor *)hd_colorWithBackendColor:(UIColor *)backendColor frontColor:(UIColor *)frontColor {
    CGFloat bgAlpha = [backendColor hd_alpha];
    CGFloat bgRed = [backendColor hd_red];
    CGFloat bgGreen = [backendColor hd_green];
    CGFloat bgBlue = [backendColor hd_blue];

    CGFloat frAlpha = [frontColor hd_alpha];
    CGFloat frRed = [frontColor hd_red];
    CGFloat frGreen = [frontColor hd_green];
    CGFloat frBlue = [frontColor hd_blue];

    CGFloat resultAlpha = frAlpha + bgAlpha * (1 - frAlpha);
    CGFloat resultRed = (frRed * frAlpha + bgRed * bgAlpha * (1 - frAlpha)) / resultAlpha;
    CGFloat resultGreen = (frGreen * frAlpha + bgGreen * bgAlpha * (1 - frAlpha)) / resultAlpha;
    CGFloat resultBlue = (frBlue * frAlpha + bgBlue * bgAlpha * (1 - frAlpha)) / resultAlpha;
    return [UIColor colorWithRed:resultRed green:resultGreen blue:resultBlue alpha:resultAlpha];
}

+ (UIColor *)hd_colorFromColor:(UIColor *)fromColor toColor:(UIColor *)toColor progress:(CGFloat)progress {
    progress = MIN(progress, 1.0f);
    CGFloat fromRed = fromColor.hd_red;
    CGFloat fromGreen = fromColor.hd_green;
    CGFloat fromBlue = fromColor.hd_blue;
    CGFloat fromAlpha = fromColor.hd_alpha;

    CGFloat toRed = toColor.hd_red;
    CGFloat toGreen = toColor.hd_green;
    CGFloat toBlue = toColor.hd_blue;
    CGFloat toAlpha = toColor.hd_alpha;

    CGFloat finalRed = fromRed + (toRed - fromRed) * progress;
    CGFloat finalGreen = fromGreen + (toGreen - fromGreen) * progress;
    CGFloat finalBlue = fromBlue + (toBlue - fromBlue) * progress;
    CGFloat finalAlpha = fromAlpha + (toAlpha - fromAlpha) * progress;

    return [UIColor colorWithRed:finalRed green:finalGreen blue:finalBlue alpha:finalAlpha];
}

+ (UIColor *)hd_randomColor {
    CGFloat red = (arc4random() % 255 / 255.0);
    CGFloat green = (arc4random() % 255 / 255.0);
    CGFloat blue = (arc4random() % 255 / 255.0);
    return [UIColor colorWithRed:red green:green blue:blue alpha:1.0];
}
@end
