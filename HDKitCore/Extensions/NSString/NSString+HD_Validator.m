//
//  NSString+HD_Validator.m
//  HDKitCore
//
//  Created by VanJay on 2019/4/29.
//  Copyright © 2019 chaos network technology. All rights reserved.
//

#import "NSString+HD_Validator.h"

@implementation NSString (HD_Validator)
- (BOOL)hd_doesContainChinese {
    for (int i = 0; i < [self length]; i++) {
        int a = [self characterAtIndex:i];
        if (a > 0x4e00 && a < 0x9fff) {
            return YES;
        }
    }
    return NO;
}

- (BOOL)hd_isPureInt {
    NSScanner *scan = [NSScanner scannerWithString:self];
    int val;
    return [scan scanInt:&val] && [scan isAtEnd];
}

- (BOOL)hd_isPureFloat {
    NSScanner *scan = [NSScanner scannerWithString:self];
    float val;
    return [scan scanFloat:&val] && [scan isAtEnd];
}

- (BOOL)hd_isValidMobile {
    NSString *phoneRegex = @"^1[345789]\\d{9}$";
    NSPredicate *phoneTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", phoneRegex];
    return [phoneTest evaluateWithObject:self];
}

- (BOOL)hd_isPureDigitCharacters {
    NSString *string = [self stringByTrimmingCharactersInSet:[NSCharacterSet decimalDigitCharacterSet]];
    if (string.length > 0) return NO;

    return YES;
}

- (BOOL)hd_isValidCharacterOrNumber {
    // 编写正则表达式：只能是数字或英文，或两者都存在
    NSString *regex = @"^[a-z0-9A-Z]*$";
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regex];
    return [predicate evaluateWithObject:self];
}

- (BOOL)hd_isValidEmail {

    // ^(\\w)+(\\.\\w+)*@(\\w)+((\\.\\w{2,3}){1,3})$
    // [A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}
    // ^[a-zA-Z0-9_-]+@[a-zA-Z0-9_-]+(\\.[a-zA-Z0-9_-]+)+$
    // @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}"

    BOOL isValid = NO;
    if (self.length <= 320) {
        NSString *regex = @"[A-Z0-9a-z._-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}";
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regex];
        isValid = [predicate evaluateWithObject:self];
    }
    return isValid;
}

- (BOOL)hd_isValidPassword {
    return [self hd_isValidPasswordWithSpecialCharacters:@"!@#$%^&*,.()_+=;:?" minLength:6 maxLength:20];
}

- (BOOL)hd_isValidPasswordIgnoreLength {
    return [self hd_isValidPasswordWithSpecialCharacters:@"!@#$%^&*,.()_+=;:?" minLength:2 maxLength:99];
}

- (BOOL)hd_isValidPasswordWithSpecialCharacters:(NSString *)specialCharacters minLength:(NSUInteger)minLength maxLength:(NSUInteger)maxLength {
    BOOL isValid = NO;
    if (self.length >= minLength && self.length <= maxLength) {
        // 数字条件
        NSRegularExpression *numberRE = [NSRegularExpression regularExpressionWithPattern:@"[0-9]" options:NSRegularExpressionCaseInsensitive error:nil];

        // 符合数字条件的有几个
        NSUInteger countOfNumber = [numberRE numberOfMatchesInString:self
                                                             options:NSMatchingReportProgress
                                                               range:NSMakeRange(0, self.length)];

        // 字母条件
        NSRegularExpression *letterRE = [NSRegularExpression regularExpressionWithPattern:@"[A-Za-z]" options:NSRegularExpressionCaseInsensitive error:nil];

        // 符合字母条件的有几个
        NSUInteger countOfLetter = [letterRE numberOfMatchesInString:self
                                                             options:NSMatchingReportProgress
                                                               range:NSMakeRange(0, self.length)];

        // 特殊字符条件
        NSString *pattern = [NSString stringWithFormat:@"[%@]", specialCharacters];
        NSRegularExpression *specialCharactersRE = [NSRegularExpression regularExpressionWithPattern:pattern options:NSRegularExpressionCaseInsensitive error:nil];

        // 符合特殊字符的有几个
        NSUInteger countOfSpecialCharacters = [specialCharactersRE numberOfMatchesInString:self
                                                                                   options:NSMatchingReportProgress
                                                                                     range:NSMakeRange(0, self.length)];

        NSUInteger validExpressionCount = 0;
        if (countOfNumber >= 1) {
            validExpressionCount += 1;
        }
        if (countOfLetter >= 1) {
            validExpressionCount += 1;
        }
        if (countOfSpecialCharacters >= 1) {
            validExpressionCount += 1;
        }
        // 至少有两种
        isValid = validExpressionCount >= 2;
    }
    return isValid;
}

- (BOOL)hd_matches:(NSString *)regex {
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regex];
    return [predicate evaluateWithObject:self];
}
@end
