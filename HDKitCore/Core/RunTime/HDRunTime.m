//
//  HDRunTime.m
//  HDKitCore
//
//  Created by VanJay on 2019/12/30.
//  Copyright © 2019 chaos network technology. All rights reserved.
//

#import "HDRunTime.h"
#include <mach-o/dyld.h>
#include <mach-o/getsect.h>

@interface NSString (_internal)
- (NSString *)internal_capitalizedString;
@end

@implementation NSString (_internal)
- (NSString *)internal_capitalizedString {
    if (self.length)
        return [NSString stringWithFormat:@"%@%@", [self substringToIndex:1].uppercaseString, [self substringFromIndex:1]].copy;
    return nil;
}
@end

#ifndef setterWithGetter
/**
 根据给定的 getter selector 获取对应的 setter selector
 @param getter 目标 getter selector
 @return 对应的 setter selector
 */
CG_INLINE SEL
setterWithGetter(SEL getter) {
    NSString *getterString = NSStringFromSelector(getter);
    NSMutableString *setterString = [[NSMutableString alloc] initWithString:@"set"];
    [setterString appendString:getterString.internal_capitalizedString];
    [setterString appendString:@":"];
    SEL setter = NSSelectorFromString(setterString);
    return setter;
}
#endif

@implementation HDPropertyDescriptor

+ (instancetype)descriptorWithProperty:(objc_property_t)property {
    HDPropertyDescriptor *descriptor = [[HDPropertyDescriptor alloc] init];
    NSString *propertyName = [NSString stringWithUTF8String:property_getName(property)];
    descriptor.name = propertyName;

    // getter
    char *getterChar = property_copyAttributeValue(property, "G");
    descriptor.getter = NSSelectorFromString(getterChar != NULL ? [NSString stringWithUTF8String:getterChar] : propertyName);
    if (getterChar != NULL) {
        free(getterChar);
    }

    // setter
    char *setterChar = property_copyAttributeValue(property, "S");
    NSString *setterString = setterChar != NULL ? [NSString stringWithUTF8String:setterChar] : NSStringFromSelector(setterWithGetter(NSSelectorFromString(propertyName)));
    descriptor.setter = NSSelectorFromString(setterString);
    if (setterChar != NULL) {
        free(setterChar);
    }

    // atomic/nonatomic
    char *attrValue_N = property_copyAttributeValue(property, "N");
    BOOL isAtomic = (attrValue_N == NULL);
    descriptor.isAtomic = isAtomic;
    descriptor.isNonatomic = !isAtomic;
    if (attrValue_N != NULL) {
        free(attrValue_N);
    }

    // assign/weak/strong/copy
    char *attrValue_isCopy = property_copyAttributeValue(property, "C");
    char *attrValue_isStrong = property_copyAttributeValue(property, "&");
    char *attrValue_isWeak = property_copyAttributeValue(property, "W");
    BOOL isCopy = attrValue_isCopy != NULL;
    BOOL isStrong = attrValue_isStrong != NULL;
    BOOL isWeak = attrValue_isWeak != NULL;
    if (attrValue_isCopy != NULL) {
        free(attrValue_isCopy);
    }
    if (attrValue_isStrong != NULL) {
        free(attrValue_isStrong);
    }
    if (attrValue_isWeak != NULL) {
        free(attrValue_isWeak);
    }
    descriptor.isCopy = isCopy;
    descriptor.isStrong = isStrong;
    descriptor.isWeak = isWeak;
    descriptor.isAssign = !isCopy && !isStrong && !isWeak;

    // readonly/readwrite
    char *attrValue_isReadonly = property_copyAttributeValue(property, "R");
    BOOL isReadonly = (attrValue_isReadonly != NULL);
    if (attrValue_isReadonly != NULL) {
        free(attrValue_isReadonly);
    }
    descriptor.isReadonly = isReadonly;
    descriptor.isReadwrite = !isReadonly;

    // type
    char *type = property_copyAttributeValue(property, "T");
    descriptor.type = [HDPropertyDescriptor typeWithEncodeString:[NSString stringWithUTF8String:type]];
    if (type != NULL) {
        free(type);
    }

    return descriptor;
}

- (NSString *)description {
    NSMutableString *result = [[NSMutableString alloc] init];
    [result appendString:@"@property("];
    if (self.isNonatomic) [result appendString:@"nonatomic, "];
    [result appendString:self.isAssign ? @"assign" : (self.isWeak ? @"weak" : (self.isStrong ? @"strong" : @"copy"))];
    if (self.isReadonly) [result appendString:@", readonly"];
    if (![NSStringFromSelector(self.getter) isEqualToString:self.name]) [result appendFormat:@", getter=%@", NSStringFromSelector(self.getter)];
    if (self.setter != setterWithGetter(NSSelectorFromString(self.name))) [result appendFormat:@", setter=%@", NSStringFromSelector(self.setter)];
    [result appendString:@") "];
    [result appendString:self.type];
    [result appendString:@" "];
    [result appendString:self.name];
    [result appendString:@";"];
    return result.copy;
}

#define _DetectTypeAndReturn(_type) \
    if (strncmp(@encode(_type), typeEncoding, strlen(@encode(_type))) == 0) return @ #_type;

+ (NSString *)typeWithEncodeString:(NSString *)encodeString {
    if ([encodeString containsString:@"@\""]) {
        NSString *result = [encodeString substringWithRange:NSMakeRange(2, encodeString.length - 2 - 1)];
        if ([result containsString:@"<"] && [result containsString:@">"]) {
            // protocol
            if ([result hasPrefix:@"<"]) {
                // id pointer
                return [NSString stringWithFormat:@"id%@", result];
            }
        }
        // class
        return [NSString stringWithFormat:@"%@ *", result];
    }

    // clang-format off
    const char *typeEncoding = encodeString.UTF8String;
    _DetectTypeAndReturn(NSInteger)
    _DetectTypeAndReturn(NSUInteger)
    _DetectTypeAndReturn(int)
    _DetectTypeAndReturn(short)
    _DetectTypeAndReturn(long)
    _DetectTypeAndReturn(long long)
    _DetectTypeAndReturn(char)
    _DetectTypeAndReturn(unsigned char)
    _DetectTypeAndReturn(unsigned int)
    _DetectTypeAndReturn(unsigned short)
    _DetectTypeAndReturn(unsigned long)
    _DetectTypeAndReturn(unsigned long long)
    _DetectTypeAndReturn(CGFloat)
    _DetectTypeAndReturn(float)
    _DetectTypeAndReturn(double)
    _DetectTypeAndReturn(void)
    _DetectTypeAndReturn(char *)
    _DetectTypeAndReturn(id)
    _DetectTypeAndReturn(Class)
    _DetectTypeAndReturn(SEL)
    _DetectTypeAndReturn(BOOL)

    return encodeString;
    // clang-format on
}

@end

#ifndef __LP64__
typedef struct mach_header headerType;
#else
typedef struct mach_header_64 headerType;
#endif

static BOOL strendswith(const char *str, const char *suffix) {
    if (!str || !suffix) return NO;
    size_t lenstr = strlen(str);
    size_t lensuffix = strlen(suffix);
    if (lensuffix > lenstr) return NO;
    return strncmp(str + lenstr - lensuffix, suffix, lensuffix) == 0;
}

static const headerType *getProjectImageHeader() {
    const uint32_t imageCount = _dyld_image_count();
    const char *target_image_name = ((NSString *)[[NSBundle mainBundle] objectForInfoDictionaryKey:(NSString *)kCFBundleExecutableKey]).UTF8String;
    if (!target_image_name || strlen(target_image_name) <= 0) return nil;
    const headerType *target_image_header = 0;
    for (uint32_t i = 0; i < imageCount; i++) {
        const char *image_name = _dyld_get_image_name(i);  // name 是一串完整的文件路径，以 image 名结尾
        if (strendswith(image_name, target_image_name)) {
            target_image_header = (headerType *)_dyld_get_image_header(i);
            break;
        }
    }
    return target_image_header;
}

// from https://github.com/opensource-apple/objc4/blob/master/runtime/objc-file.mm
static classref_t *getDataSection(const headerType *machHeader, const char *sectname, size_t *outCount) {
    if (!machHeader) return nil;

    unsigned long byteCount = 0;
    classref_t *data = (classref_t *)getsectiondata(machHeader, "__DATA", sectname, &byteCount);
    if (!data) {
        data = (classref_t *)getsectiondata(machHeader, "__DATA_CONST", sectname, &byteCount);
    }
    if (!data) {
        data = (classref_t *)getsectiondata(machHeader, "__DATA_DIRTY", sectname, &byteCount);
    }
    if (outCount) *outCount = byteCount / sizeof(classref_t);
    return data;
}

int hd_getProjectClassList(classref_t **classes) {
    size_t count = 0;
    if (!!classes) {
        *classes = getDataSection(getProjectImageHeader(), "__objc_classlist", &count);
    } else {
        getDataSection(getProjectImageHeader(), "__objc_classlist", &count);
    }
    return (int)count;
}
