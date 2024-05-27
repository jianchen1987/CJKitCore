//
//  NSString+HD_Validator.h
//  HDKitCore
//
//  Created by VanJay on 2019/4/29.
//  Copyright © 2019 chaos network technology. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSString (HD_Validator)
/// 检测字符串是否包含中文
- (BOOL)hd_doesContainChinese;

/// 整形
- (BOOL)hd_isPureInt;

/// 浮点型
- (BOOL)hd_isPureFloat;

/// 有效的手机号码
- (BOOL)hd_isValidMobile;

/// 纯数字
- (BOOL)hd_isPureDigitCharacters;

/// 字符串为字母或者数字
- (BOOL)hd_isValidCharacterOrNumber;

/// 邮箱是否有效
- (BOOL)hd_isValidEmail;

/// 密码是否有效
/// 支持的特殊字符格式：!@#$%^&*()_+=;:?
/// 对密码复杂度进行校验，至少要为数字、字母或特殊字符组合
/// 密码支持长度，6-20 位
- (BOOL)hd_isValidPassword;

/// 密码是否有效
/// 支持的特殊字符格式：!@#$%^&*()_+=;:?
/// 对密码复杂度进行校验，至少要为数字、字母或特殊字符组合
/// 密码支持长度，2-99 位
- (BOOL)hd_isValidPasswordIgnoreLength;
/// 密码是否有效
/// @param specialCharacters 支持的特殊字符
/// @param minLength 最短长度
/// @param maxLength 最大长度
- (BOOL)hd_isValidPasswordWithSpecialCharacters:(NSString *)specialCharacters minLength:(NSUInteger)minLength maxLength:(NSUInteger)maxLength;

/// 判断字符串是否匹配正则
/// @param regex 正则表达式
- (BOOL)hd_matches:(NSString *)regex;
@end

NS_ASSUME_NONNULL_END
