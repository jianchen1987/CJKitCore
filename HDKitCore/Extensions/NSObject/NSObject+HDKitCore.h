//
//  NSObject+HDKitCore.h
//  HDKitCore
//
//  Created by VanJay on 2019/9/5.
//  Copyright © 2019 chaos network technology. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <objc/runtime.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSObject (HDKitCore)

/**
 判断当前类是否有重写某个父类的指定方法

 @param selector 要判断的方法
 @param superclass 要比较的父类，必须是当前类的某个 superclass
 @return YES 表示子类有重写了父类方法，NO 表示没有重写（异常情况也返回 NO，例如当前类与指定的类并非父子关系、父类本身也无法响应指定的方法）
 */
- (BOOL)hd_hasOverrideMethod:(SEL)selector ofSuperclass:(Class)superclass;

/**
 判断指定的类是否有重写某个父类的指定方法

 @param selector 要判断的方法
 @param superclass 要比较的父类，必须是当前类的某个 superclass
 @return YES 表示子类有重写了父类方法，NO 表示没有重写（异常情况也返回 NO，例如当前类与指定的类并非父子关系、父类本身也无法响应指定的方法）
 */
+ (BOOL)hd_hasOverrideMethod:(SEL)selector forClass:(Class)aClass ofSuperclass:(Class)superclass;

/**
 对 super 发送消息

 @param aSelector 要发送的消息
 @return 消息执行后的结果
 @link http://stackoverflow.com/questions/14635024/using-objc-msgsendsuper-to-invoke-a-class-method @/link
 */
- (nullable id)hd_performSelectorToSuperclass:(SEL)aSelector;

/**
 对 super 发送消息

 @param aSelector 要发送的消息
 @param object 作为参数传过去
 @return 消息执行后的结果
 @link http://stackoverflow.com/questions/14635024/using-objc-msgsendsuper-to-invoke-a-class-method @/link
 */
- (nullable id)hd_performSelectorToSuperclass:(SEL)aSelector withObject:(nullable id)object;

/**
 *  调用一个无参数、返回值类型为非对象的 selector。如果返回值类型为对象，请直接使用系统的 performSelector: 方法。
 *  @param selector 要被调用的方法名
 *  @param returnValue selector 的返回值的指针地址，请先定义一个变量再将其指针地址传进来，例如 &result
 *
 *  @code
 *  CGFloat alpha;
 *  [view hd_performSelector:@selector(alpha) withPrimitiveReturnValue:&alpha];
 *  @endcode
 */
- (void)hd_performSelector:(SEL)selector withPrimitiveReturnValue:(nullable void *)returnValue;

/**
 *  调用一个带参数的 selector，参数类型支持对象和非对象，也没有数量限制。返回值为对象或者 void。
 *  @param selector 要被调用的方法名
 *  @param firstArgument 参数列表，请传参数的指针地址，支持多个参数
 *  @return 方法的返回值，如果该方法返回类型为 void，则会返回 nil，如果返回类型为对象，则返回该对象。
 *
 *  @code
 *  id target = xxx;
 *  SEL action = xxx;
 *  UIControlEvents events = xxx;
 *  [control hd_performSelector:@selector(addTarget:action:forControlEvents:) withArguments:&target, &action, &events, nil];
 *  @endcode
 */
- (nullable id)hd_performSelector:(SEL)selector withArguments:(nullable void *)firstArgument, ...;

/**
 *  调用一个返回值类型为非对象且带参数的 selector，参数类型支持对象和非对象，也没有数量限制。
 *
 *  @param selector 要被调用的方法名
 *  @param returnValue selector 的返回值的指针地址
 *  @param firstArgument 参数列表，请传参数的指针地址，支持多个参数
 *
 *  @code
 *  CGPoint point = xxx;
 *  UIEvent *event = xxx;
 *  BOOL isInside;
 *  [view hd_performSelector:@selector(pointInside:withEvent:) withPrimitiveReturnValue:&isInside arguments:&point, &event, nil];
 *  @endcode
 */
- (void)hd_performSelector:(SEL)selector withPrimitiveReturnValue:(nullable void *)returnValue arguments:(nullable void *)firstArgument, ...;

/**
 使用 block 遍历指定 class 的所有成员变量（也即 _xxx 那种），不包含 property 对应的 _property 成员变量，也不包含 superclasses 里定义的变量

 @param block 用于遍历的 block
 */
- (void)hd_enumrateIvarsUsingBlock:(void (^)(Ivar ivar, NSString *ivarDescription))block;

/**
 使用 block 遍历指定 class 的所有成员变量（也即 _xxx 那种），不包含 property 对应的 _property 成员变量

 @param aClass 指定的 class
 @param includingInherited 是否要包含由继承链带过来的 ivars
 @param block  用于遍历的 block
 */
+ (void)hd_enumrateIvarsOfClass:(Class)aClass includingInherited:(BOOL)includingInherited usingBlock:(void (^)(Ivar ivar, NSString *ivarDescription))block;

/**
 使用 block 遍历指定 class 的所有属性，不包含 superclasses 里定义的 property

 @param block 用于遍历的 block
 */
- (void)hd_enumratePropertiesUsingBlock:(void (^)(objc_property_t property, NSString *propertyName))block;

/**
 使用 block 遍历指定 class 的所有属性

 @param aClass 指定的 class
 @param includingInherited 是否要包含由继承链带过来的 property
 @param block 用于遍历的 block
 @see https://developer.apple.com/library/archive/documentation/Cocoa/Conceptual/ObjCRuntimeGuide/Articles/ocrtPropertyIntrospection.html#//apple_ref/doc/uid/TP40008048-CH101-SW1
 */
+ (void)hd_enumratePropertiesOfClass:(Class)aClass includingInherited:(BOOL)includingInherited usingBlock:(void (^)(objc_property_t property, NSString *propertyName))block;

/**
 使用 block 遍历当前实例的所有方法，不包含 superclasses 里定义的 method
 */
- (void)hd_enumrateInstanceMethodsUsingBlock:(void (^)(Method method, SEL selector))block;

/**
 使用 block 遍历指定的某个类的实例方法
 @param aClass   指定的 class
 @param includingInherited 是否要包含由继承链带过来的 method
 @param block    用于遍历的 block
 */
+ (void)hd_enumrateInstanceMethodsOfClass:(Class)aClass includingInherited:(BOOL)includingInherited usingBlock:(void (^)(Method method, SEL selector))block;

/**
 遍历某个 protocol 里的所有方法

 @param protocol 要遍历的 protocol，例如 \@protocol(xxx)
 @param block 遍历过程中调用的 block
 */
+ (void)hd_enumerateProtocolMethods:(Protocol *)protocol usingBlock:(void (^)(SEL selector))block;

@property (nonatomic, strong) id hd_associatedObject;  ///< 关联对象
@end

@interface NSObject (Debug)

/// 获取当前对象的所有 @property、方法，父类的方法也会分别列出
- (NSString *)hd_methodList;

/// 获取当前对象的所有 @property、方法，不包含父类的
- (NSString *)hd_shortMethodList;

/// 获取当前对象的所有 Ivar 变量
- (NSString *)hd_ivarList;
@end

@interface NSObject (HD_DataBind)

/**
 给对象绑定上另一个对象以供后续取出使用，如果 object 传入 nil 则会清除该 key 之前绑定的对象

 @attention 被绑定的对象会被 strong 强引用
 @note 内部是使用 objc_setAssociatedObject / objc_getAssociatedObject 来实现

 @code
 - (UITableViewCell *)cellForIndexPath:(NSIndexPath *)indexPath {
 // 1）在这里给 button 绑定上 indexPath 对象
 [cell hd_bindObject:indexPath forKey:@"indexPath"];
 }

 - (void)didTapButton:(UIButton *)button {
 // 2）在这里取出被点击的 button 的 indexPath 对象
 NSIndexPath *indexPathTapped = [button hd_getBoundObjectForKey:@"indexPath"];
 }
 @endcode
 */
- (void)hd_bindObject:(nullable id)object forKey:(NSString *)key;

/**
 给对象绑定上另一个对象以供后续取出使用，但相比于 hd_bindObject:forKey:，该方法不会 strong 强引用传入的 object
 */
- (void)hd_bindObjectWeakly:(nullable id)object forKey:(NSString *)key;

/**
 取出之前使用 bind 方法绑定的对象
 */
- (nullable id)hd_getBoundObjectForKey:(NSString *)key;

/**
 给对象绑定上一个 double 值以供后续取出使用
 */
- (void)hd_bindDouble:(double)doubleValue forKey:(NSString *)key;

/**
 取出之前用 bindDouble:forKey: 绑定的值
 */
- (double)hd_getBoundDoubleForKey:(NSString *)key;

/**
 给对象绑定上一个 BOOL 值以供后续取出使用
 */
- (void)hd_bindBOOL:(BOOL)boolValue forKey:(NSString *)key;

/**
 取出之前用 bindBOOL:forKey: 绑定的值
 */
- (BOOL)hd_getBoundBOOLForKey:(NSString *)key;

/**
 给对象绑定上一个 long 值以供后续取出使用
 */
- (void)hd_bindLong:(long)longValue forKey:(NSString *)key;

/**
 取出之前用 bindLong:forKey: 绑定的值
 */
- (long)hd_getBoundLongForKey:(NSString *)key;

/**
 移除之前使用 bind 方法绑定的对象
 */
- (void)hd_clearBindingForKey:(NSString *)key;

/**
 移除之前使用 bind 方法绑定的所有对象
 */
- (void)hd_clearAllBinding;

/**
 返回当前有绑定对象存在的所有的 key 的数组，如果不存在任何 key，则返回一个空数组
 @note 数组中元素的顺序是随机的
 */
- (NSArray<NSString *> *)hd_allBindingKeys;

/**
 返回是否设置了某个 key
 */
- (BOOL)hd_hasBindingKey:(NSString *)key;

@end

@interface NSObject (HD_Dealloc)

/**
 object销毁前会调用这个block
 */
@property (nullable, nonatomic, copy) void (^hd_objectDeallocBlock)(void);
@end

NS_ASSUME_NONNULL_END
