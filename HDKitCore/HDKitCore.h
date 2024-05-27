//
//  HDKitCore.h
//  HDKitCore
//
//  Created by VanJay on 2020/2/26.
//  Copyright © 2020 VanJay. All rights reserved.
//  This file is generated automatically.

#ifndef HDKitCore_h
#define HDKitCore_h

#import <UIKit/UIKit.h>

/// 版本号
static NSString *const HDKitCore_VERSION = @"1.4.14";

#if __has_include("KVOController.h")
#import "KVOController.h"
#endif

#if __has_include("FBKVOController.h")
#import "FBKVOController.h"
#endif

#if __has_include("FBKVOController+HDKitCore.h")
#import "FBKVOController+HDKitCore.h"
#endif

#if __has_include("NSObject+FBKVOController.h")
#import "NSObject+FBKVOController.h"
#endif

#if __has_include("HDDispatchMainQueueSafe.h")
#import "HDDispatchMainQueueSafe.h"
#endif

#if __has_include("HDWeakObjectContainer.h")
#import "HDWeakObjectContainer.h"
#endif

#if __has_include("HDHelperFunction.h")
#import "HDHelperFunction.h"
#endif

#if __has_include("HDCommonDefines.h")
#import "HDCommonDefines.h"
#endif

#if __has_include("HDHelper.h")
#import "HDHelper.h"
#endif

#if __has_include("HDAssociatedObjectHelper.h")
#import "HDAssociatedObjectHelper.h"
#endif

#if __has_include("HDUIHelperDefines.h")
#import "HDUIHelperDefines.h"
#endif

#if __has_include("HDRunTime.h")
#import "HDRunTime.h"
#endif

#if __has_include("NSObject+HDMultipleDelegates.h")
#import "NSObject+HDMultipleDelegates.h"
#endif

#if __has_include("HDMultipleDelegates.h")
#import "HDMultipleDelegates.h"
#endif

#if __has_include("HDWeakTimer.h")
#import "HDWeakTimer.h"
#endif

#if __has_include("HDFunctionThrottle.h")
#import "HDFunctionThrottle.h"
#endif

#if __has_include("HDAnimationWeakDelegate.h")
#import "HDAnimationWeakDelegate.h"
#endif

#if __has_include("UITableView+HDKitCore.h")
#import "UITableView+HDKitCore.h"
#endif

#if __has_include("NSNumber+HDKitCore.h")
#import "NSNumber+HDKitCore.h"
#endif

#if __has_include("NSCharacterSet+HDKitCore.h")
#import "NSCharacterSet+HDKitCore.h"
#endif

#if __has_include("NSMethodSignature+HDKitCore.h")
#import "NSMethodSignature+HDKitCore.h"
#endif

#if __has_include("UILabel+HDKitCore.h")
#import "UILabel+HDKitCore.h"
#endif

#if __has_include("NSBundle+HDKitCore.h")
#import "NSBundle+HDKitCore.h"
#endif

#if __has_include("UITextField+HDKitCore.h")
#import "UITextField+HDKitCore.h"
#endif

#if __has_include("NSParagraphStyle+HDKitCore.h")
#import "NSParagraphStyle+HDKitCore.h"
#endif

#if __has_include("CALayer+HDKitCore.h")
#import "CALayer+HDKitCore.h"
#endif

#if __has_include("UICollectionView+HDKitCore.h")
#import "UICollectionView+HDKitCore.h"
#endif

#if __has_include("CAAnimation+HDKitCore.h")
#import "CAAnimation+HDKitCore.h"
#endif

#if __has_include("NSPointerArray+HDKitCore.h")
#import "NSPointerArray+HDKitCore.h"
#endif

#if __has_include("UIInterface+HDKitCore.h")
#import "UIInterface+HDKitCore.h"
#endif

#if __has_include("UIScrollView+HDKitCore.h")
#import "UIScrollView+HDKitCore.h"
#endif

#if __has_include("UITextView+HDKitCore.h")
#import "UITextView+HDKitCore.h"
#endif

#if __has_include("UIBezierPath+HDKitCore.h")
#import "UIBezierPath+HDKitCore.h"
#endif

#if __has_include("UIImage+HDKitCore.h")
#import "UIImage+HDKitCore.h"
#endif

#if __has_include("UIImage+HD_GIF.h")
#import "UIImage+HD_GIF.h"
#endif

#if __has_include("NSString+HD_MD5.h")
#import "NSString+HD_MD5.h"
#endif

#if __has_include("NSData+HD_MD5.h")
#import "NSData+HD_MD5.h"
#endif

#if __has_include("UIButton+EnlargeEdge.h")
#import "UIButton+EnlargeEdge.h"
#endif

#if __has_include("UIButton+Block.h")
#import "UIButton+Block.h"
#endif

#if __has_include("UIColor+HDKitCore.h")
#import "UIColor+HDKitCore.h"
#endif

#if __has_include("UIView+HD_Extension.h")
#import "UIView+HD_Extension.h"
#endif

#if __has_include("UIView+HDKitCore.h")
#import "UIView+HDKitCore.h"
#endif

#if __has_include("NSString+HD_Size.h")
#import "NSString+HD_Size.h"
#endif

#if __has_include("NSString+HD_Validator.h")
#import "NSString+HD_Validator.h"
#endif

#if __has_include("NSString+HDKitCore.h")
#import "NSString+HDKitCore.h"
#endif

#if __has_include("NSString+HD_Util.h")
#import "NSString+HD_Util.h"
#endif

#if __has_include("UIViewController+HDKitCore.h")
#import "UIViewController+HDKitCore.h"
#endif

#if __has_include("UINavigationController+HDKitCore.h")
#import "UINavigationController+HDKitCore.h"
#endif

#if __has_include("UITabBarController+HDKitCore.h")
#import "UITabBarController+HDKitCore.h"
#endif

#if __has_include("UIViewController+HDKeyBoard.h")
#import "UIViewController+HDKeyBoard.h"
#endif

#if __has_include("NSArray+HDKitCore.h")
#import "NSArray+HDKitCore.h"
#endif

#if __has_include("NSObject+HD_Swizzle.h")
#import "NSObject+HD_Swizzle.h"
#endif

#if __has_include("NSObject+HDKitCore.h")
#import "NSObject+HDKitCore.h"
#endif

#if __has_include("NSData+HD_AES.h")
#import "NSData+HD_AES.h"
#endif

#if __has_include("NSString+HD_AES.h")
#import "NSString+HD_AES.h"
#endif

#if __has_include("GTMBase64.h")
#import "GTMBase64.h"
#endif

#if __has_include("GTMDefines.h")
#import "GTMDefines.h"
#endif

#if __has_include("HDAlertQueueManager.h")
#import "HDAlertQueueManager.h"
#endif

#if __has_include("HDFrameLayoutMaker.h")
#import "HDFrameLayoutMaker.h"
#endif

#if __has_include("CALayer+HDFrameLayout.h")
#import "CALayer+HDFrameLayout.h"
#endif

#if __has_include("HDFrameLayoutUtils.h")
#import "HDFrameLayoutUtils.h"
#endif

#if __has_include("HDFrameLayout.h")
#import "HDFrameLayout.h"
#endif

#if __has_include("UIView+HDFrameLayout.h")
#import "UIView+HDFrameLayout.h"
#endif

#if __has_include("HDMediator.h")
#import "HDMediator.h"
#endif

#if __has_include("WNApp.h")
#import "WNApp.h"
#endif

#if __has_include("HDLogItem.h")
#import "HDLogItem.h"
#endif

#if __has_include("HDLogNameManager.h")
#import "HDLogNameManager.h"
#endif

#if __has_include("HDLogger.h")
#import "HDLogger.h"
#endif

#if __has_include("HDLog.h")
#import "HDLog.h"
#endif

#endif /* HDKitCore_h */