//
//  HDAssociatedObjectHelper.h
//  HDKitCore
//
//  Created by VanJay on 2019/12/30.
//  Copyright © 2019 chaos network technology. All rights reserved.
//

#ifndef HDAssociatedObjectHelper_h
#define HDAssociatedObjectHelper_h

#import "HDCommonDefines.h"
#import "HDWeakObjectContainer.h"
#import "NSNumber+HDKitCore.h"
#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <objc/runtime.h>

/**
 以下系列宏用于在 Category 里添加 property 时，可以在 @implementation 里一句代码完成 getter/setter 的声明。暂不支持在 getter/setter 里添加自定义的逻辑，需要自定义的情况请继续使用 Code Snippet 生成的代码。
 使用方式：
 @code
 @interface NSObject (CategoryName)
 @property(nonatomic, strong) type *strongObj;
 @property(nonatomic, weak) type *weakObj;
 @property(nonatomic, assign) CGRect rectValue;
 @end
 
 @implementation NSObject (CategoryName)
 
 // 注意 setter 不需要带冒号
 HDSynthesizeIdStrongProperty(strongObj, setStrongObj)
 HDSynthesizeIdWeakProperty(weakObj, setWeakObj)
 HDSynthesizeCGRectProperty(rectValue, setRectValue)
 
 @end
 @endcode
 */

// clang-format off

#pragma mark - Meta Marcos

#define _HDSynthesizeId(_getterName, _setterName, _policy) \
_Pragma("clang diagnostic push") _Pragma(ClangWarningConcat("-Wmismatched-parameter-types")) _Pragma(ClangWarningConcat("-Wmismatched-return-types"))\
static char kAssociatedObjectKey_##_getterName;\
- (void)_setterName:(id)_getterName {\
    objc_setAssociatedObject(self, &kAssociatedObjectKey_##_getterName, _getterName, OBJC_ASSOCIATION_##_policy##_NONATOMIC);\
}\
\
- (id)_getterName {\
    return objc_getAssociatedObject(self, &kAssociatedObjectKey_##_getterName);\
}\
_Pragma("clang diagnostic pop")

#define _HDSynthesizeWeakId(_getterName, _setterName) \
_Pragma("clang diagnostic push") _Pragma(ClangWarningConcat("-Wmismatched-parameter-types")) _Pragma(ClangWarningConcat("-Wmismatched-return-types"))\
static char kAssociatedObjectKey_##_getterName;\
- (void)_setterName:(id)_getterName {\
    objc_setAssociatedObject(self, &kAssociatedObjectKey_##_getterName, [[HDWeakObjectContainer alloc] initWithObject:_getterName], OBJC_ASSOCIATION_RETAIN_NONATOMIC);\
}\
\
- (id)_getterName {\
    return ((HDWeakObjectContainer *)objc_getAssociatedObject(self, &kAssociatedObjectKey_##_getterName)).object;\
}\
_Pragma("clang diagnostic pop")

#define _HDSynthesizeNonObject(_getterName, _setterName, _type, valueInitializer, valueGetter) \
_Pragma("clang diagnostic push") _Pragma(ClangWarningConcat("-Wmismatched-parameter-types")) _Pragma(ClangWarningConcat("-Wmismatched-return-types"))\
static char kAssociatedObjectKey_##_getterName;\
- (void)_setterName:(_type)_getterName {\
    objc_setAssociatedObject(self, &kAssociatedObjectKey_##_getterName, [NSNumber valueInitializer:_getterName], OBJC_ASSOCIATION_RETAIN_NONATOMIC);\
}\
\
- (_type)_getterName {\
    return [((NSNumber *)objc_getAssociatedObject(self, &kAssociatedObjectKey_##_getterName)) valueGetter];\
}\
_Pragma("clang diagnostic pop")


#pragma mark - Object Marcos

/// @property(nonatomic, strong) id xxx
#define HDSynthesizeIdStrongProperty(_getterName, _setterName) _HDSynthesizeId(_getterName, _setterName, RETAIN)

/// @property(nonatomic, weak) id xxx
#define HDSynthesizeIdWeakProperty(_getterName, _setterName) _HDSynthesizeWeakId(_getterName, _setterName)

/// @property(nonatomic, copy) id xxx
#define HDSynthesizeIdCopyProperty(_getterName, _setterName) _HDSynthesizeId(_getterName, _setterName, COPY)


#pragma mark - NonObject Marcos

/// @property(nonatomic, assign) Int xxx
#define HDSynthesizeIntProperty(_getterName, _setterName) _HDSynthesizeNonObject(_getterName, _setterName, int, numberWithInt, intValue)

/// @property(nonatomic, assign) unsigned int xxx
#define HDSynthesizeUnsignedIntProperty(_getterName, _setterName) _HDSynthesizeNonObject(_getterName, _setterName, unsigned int, numberWithUnsignedInt, unsignedIntValue)

/// @property(nonatomic, assign) float xxx
#define HDSynthesizeFloatProperty(_getterName, _setterName) _HDSynthesizeNonObject(_getterName, _setterName, float, numberWithFloat, floatValue)

/// @property(nonatomic, assign) double xxx
#define HDSynthesizeDoubleProperty(_getterName, _setterName) _HDSynthesizeNonObject(_getterName, _setterName, double, numberWithDouble, doubleValue)

/// @property(nonatomic, assign) BOOL xxx
#define HDSynthesizeBOOLProperty(_getterName, _setterName) _HDSynthesizeNonObject(_getterName, _setterName, BOOL, numberWithBool, boolValue)

/// @property(nonatomic, assign) NSInteger xxx
#define HDSynthesizeNSIntegerProperty(_getterName, _setterName) _HDSynthesizeNonObject(_getterName, _setterName, NSInteger, numberWithInteger, integerValue)

/// @property(nonatomic, assign) NSUInteger xxx
#define HDSynthesizeNSUIntegerProperty(_getterName, _setterName) _HDSynthesizeNonObject(_getterName, _setterName, NSUInteger, numberWithUnsignedInteger, unsignedIntegerValue)

/// @property(nonatomic, assign) CGFloat xxx
#define HDSynthesizeCGFloatProperty(_getterName, _setterName) _HDSynthesizeNonObject(_getterName, _setterName, CGFloat, numberWithDouble, hd_CGFloatValue)

/// @property(nonatomic, assign) CGPoint xxx
#define HDSynthesizeCGPointProperty(_getterName, _setterName) _HDSynthesizeNonObject(_getterName, _setterName, CGPoint, valueWithCGPoint, CGPointValue)

/// @property(nonatomic, assign) CGSize xxx
#define HDSynthesizeCGSizeProperty(_getterName, _setterName) _HDSynthesizeNonObject(_getterName, _setterName, CGSize, valueWithCGSize, CGSizeValue)

/// @property(nonatomic, assign) CGRect xxx
#define HDSynthesizeCGRectProperty(_getterName, _setterName) _HDSynthesizeNonObject(_getterName, _setterName, CGRect, valueWithCGRect, CGRectValue)

/// @property(nonatomic, assign) UIEdgeInsets xxx
#define HDSynthesizeUIEdgeInsetsProperty(_getterName, _setterName) _HDSynthesizeNonObject(_getterName, _setterName, UIEdgeInsets, valueWithUIEdgeInsets, UIEdgeInsetsValue)

/// @property(nonatomic, assign) CGVector xxx
#define HDSynthesizeCGVectorProperty(_getterName, _setterName) _HDSynthesizeNonObject(_getterName, _setterName, CGVector, valueWithCGVector, CGVectorValue)

/// @property(nonatomic, assign) CGAffineTransform xxx
#define HDSynthesizeCGAffineTransformProperty(_getterName, _setterName) _HDSynthesizeNonObject(_getterName, _setterName, CGAffineTransform, valueWithCGAffineTransform, CGAffineTransformValue)

/// @property(nonatomic, assign) NSDirectionalEdgeInsets xxx
#define HDSynthesizeNSDirectionalEdgeInsetsProperty(_getterName, _setterName) _HDSynthesizeNonObject(_getterName, _setterName, NSDirectionalEdgeInsets, valueWithDirectionalEdgeInsets, NSDirectionalEdgeInsetsValue)

/// @property(nonatomic, assign) UIOffset xxx
#define HDSynthesizeUIOffsetProperty(_getterName, _setterName) _HDSynthesizeNonObject(_getterName, _setterName, UIOffset, valueWithUIOffset, UIOffsetValue)


#endif /* HDAssociatedObjectHelper_h */

// clang-format on
