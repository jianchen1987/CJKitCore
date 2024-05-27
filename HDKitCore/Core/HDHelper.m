//
//  HDHelper.m
//  HDKitCore
//
//  Created by VanJay on 2019/9/5.
//  Copyright © 2019 chaos network technology. All rights reserved.
//

#import "HDHelper.h"
#import "HDCommonDefines.h"
#import "NSArray+HDKitCore.h"
#import "NSBundle+HDKitCore.h"
#import "NSNumber+HDKitCore.h"
#import "NSObject+HDKitCore.h"
#import "NSString+HDKitCore.h"
#import "UIImage+HDKitCore.h"
#import <AVFoundation/AVFoundation.h>
#import <sys/utsname.h>
#import "HDAssociatedObjectHelper.h"

@implementation HDHelper
+ (instancetype)sharedInstance {
    static dispatch_once_t onceToken;
    static HDHelper *instance = nil;
    dispatch_once(&onceToken, ^{
        instance = [[super allocWithZone:NULL] init];
    });
    return instance;
}

+ (id)allocWithZone:(struct _NSZone *)zone {
    return [self sharedInstance];
}

- (void)dealloc {
    // HDHelper 若干个分类里有用到消息监听，所以在 dealloc 的时候注销一下
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}
@end

@implementation HDHelper (AudioSession)

+ (void)redirectAudioRouteWithSpeaker:(BOOL)speaker temporary:(BOOL)temporary {
    if (![[AVAudioSession sharedInstance].category isEqualToString:AVAudioSessionCategoryPlayAndRecord]) {
        return;
    }
    if (temporary) {
        [[AVAudioSession sharedInstance] overrideOutputAudioPort:speaker ? AVAudioSessionPortOverrideSpeaker : AVAudioSessionPortOverrideNone error:nil];
    } else {
        [[AVAudioSession sharedInstance] setCategory:[AVAudioSession sharedInstance].category withOptions:speaker ? AVAudioSessionCategoryOptionDefaultToSpeaker : 0 error:nil];
    }
}

+ (void)setAudioSessionCategory:(nullable NSString *)category {

    // 如果不属于系统category，返回
    if (category != AVAudioSessionCategoryAmbient &&
        category != AVAudioSessionCategorySoloAmbient &&
        category != AVAudioSessionCategoryPlayback &&
        category != AVAudioSessionCategoryRecord &&
        category != AVAudioSessionCategoryPlayAndRecord &&
        category != AVAudioSessionCategoryAudioProcessing) {
        return;
    }

    [[AVAudioSession sharedInstance] setCategory:category error:nil];
}

+ (UInt32)categoryForLowVersionWithCategory:(NSString *)category {
    if ([category isEqualToString:AVAudioSessionCategoryAmbient]) {
        return kAudioSessionCategory_AmbientSound;
    }
    if ([category isEqualToString:AVAudioSessionCategorySoloAmbient]) {
        return kAudioSessionCategory_SoloAmbientSound;
    }
    if ([category isEqualToString:AVAudioSessionCategoryPlayback]) {
        return kAudioSessionCategory_MediaPlayback;
    }
    if ([category isEqualToString:AVAudioSessionCategoryRecord]) {
        return kAudioSessionCategory_RecordAudio;
    }
    if ([category isEqualToString:AVAudioSessionCategoryPlayAndRecord]) {
        return kAudioSessionCategory_PlayAndRecord;
    }
    if ([category isEqualToString:AVAudioSessionCategoryAudioProcessing]) {
        return kAudioSessionCategory_AudioProcessing;
    }
    return kAudioSessionCategory_AmbientSound;
}

@end

@implementation HDHelper (UIGraphic)

static CGFloat pixelOne = -1.0f;
+ (CGFloat)pixelOne {
    if (pixelOne < 0) {
        pixelOne = 1 / [[UIScreen mainScreen] scale];
    }
    return pixelOne;
}

+ (void)inspectContextSize:(CGSize)size {
    if (!CGSizeIsValidated(size)) {
        NSAssert(NO, @"CGPostError, %@:%d %s, 非法的size：%@\n%@", [[NSString stringWithUTF8String:__FILE__] lastPathComponent], __LINE__, __PRETTY_FUNCTION__, NSStringFromCGSize(size), [NSThread callStackSymbols]);
    }
}

+ (void)inspectContextIfInvalidatedInDebugMode:(CGContextRef)context {
    if (!context) {
        // crash了就找zhoon或者molice
        NSAssert(NO, @"CGPostError, %@:%d %s, 非法的context：%@\n%@", [[NSString stringWithUTF8String:__FILE__] lastPathComponent], __LINE__, __PRETTY_FUNCTION__, context, [NSThread callStackSymbols]);
    }
}

+ (BOOL)inspectContextIfInvalidatedInReleaseMode:(CGContextRef)context {
    if (context) {
        return YES;
    }
    return NO;
}

@end

@implementation HDHelper (Device)

+ (NSString *)deviceModel {
    if ([self isSimulator]) {
        // Simulator doesn't return the identifier for the actual physical model, but returns it as an environment variable
        // 模拟器不返回物理机器信息，但会通过环境变量的方式返回
        return [NSString stringWithFormat:@"%s", getenv("SIMULATOR_MODEL_IDENTIFIER")];
    }

    // See https://www.theiphonewiki.com/wiki/Models for identifiers
    struct utsname systemInfo;
    uname(&systemInfo);
    return [NSString stringWithCString:systemInfo.machine encoding:NSUTF8StringEncoding];
}

static NSInteger isIPad = -1;
+ (BOOL)isIPad {
    if (isIPad < 0) {
        // [[[UIDevice currentDevice] model] isEqualToString:@"iPad"] 无法判断模拟器 iPad，所以改为以下方式
        isIPad = UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad ? 1 : 0;
    }
    return isIPad > 0;
}

static NSInteger isIPod = -1;
+ (BOOL)isIPod {
    if (isIPod < 0) {
        NSString *string = [[UIDevice currentDevice] model];
        isIPod = [string rangeOfString:@"iPod touch"].location != NSNotFound ? 1 : 0;
    }
    return isIPod > 0;
}

static NSInteger isIPhone = -1;
+ (BOOL)isIPhone {
    if (isIPhone < 0) {
        NSString *string = [[UIDevice currentDevice] model];
        isIPhone = [string rangeOfString:@"iPhone"].location != NSNotFound ? 1 : 0;
    }
    return isIPhone > 0;
}

static NSInteger isSimulator = -1;
+ (BOOL)isSimulator {
    if (isSimulator < 0) {
#if TARGET_OS_SIMULATOR
        isSimulator = 1;
#else
        isSimulator = 0;
#endif
    }
    return isSimulator > 0;
}

static NSInteger isNotchedScreen = -1;
+ (BOOL)isNotchedScreen {
    if (@available(iOS 11, *)) {
        if (isNotchedScreen < 0) {
            if (@available(iOS 12.0, *)) {
                /*
                 检测方式解释/测试要点：
                 1. iOS 11 与 iOS 12 可能行为不同，所以要分别测试。
                 2. 与触发 [HDHelper isNotchedScreen] 方法时的进程有关，例如 [NSObject performSelectorOnMainThread:withObject:waitUntilDone:NO] 就会导致较多的异常。
                 3. iOS 12 下，在非第2点里提到的情况下，iPhone、iPad 均可通过 UIScreen -_peripheryInsets 方法的返回值区分，但如果满足了第2点，则 iPad 无法使用这个方法，这种情况下要依赖第4点。
                 4. iOS 12 下，不管是否满足第2点，不管是什么设备类型，均可以通过一个满屏的 UIWindow 的 rootViewController.view.frame.origin.y 的值来区分，如果是非全面屏，这个值必定为20，如果是全面屏，则可能是24或44等不同的值。但由于创建 UIWindow、UIViewController 等均属于较大消耗，所以只在前面的步骤无法区分的情况下才会使用第4点。
                 5. 对于第4点，经测试与当前设备的方向、是否有勾选 project 里的 General - Hide status bar、当前是否处于来电模式的状态栏这些都没关系。
                 */
                SEL peripheryInsetsSelector = NSSelectorFromString([NSString stringWithFormat:@"_%@%@", @"periphery", @"Insets"]);
                UIEdgeInsets peripheryInsets = UIEdgeInsetsZero;
                [[UIScreen mainScreen] hd_performSelector:peripheryInsetsSelector withPrimitiveReturnValue:&peripheryInsets];
                if (peripheryInsets.bottom <= 0) {
                    UIWindow *window = [[UIWindow alloc] initWithFrame:UIScreen.mainScreen.bounds];
                    peripheryInsets = window.safeAreaInsets;
                    if (peripheryInsets.bottom <= 0) {
                        UIViewController *viewController = [UIViewController new];
                        window.rootViewController = viewController;
                        if (CGRectGetMinY(viewController.view.frame) > 20) {
                            peripheryInsets.bottom = 1;
                        }
                    }
                }
                isNotchedScreen = peripheryInsets.bottom > 0 ? 1 : 0;
            } else {
                isNotchedScreen = [HDHelper is58InchScreen] ? 1 : 0;
            }
        }
    } else {
        isNotchedScreen = 0;
    }
    return isNotchedScreen > 0;
}

+ (BOOL)isRegularScreen {
    return [self isIPad] || (!isDeviceZoomedMode && ([self is65InchScreen] || [self is61InchScreen] || [self is55InchScreen]));
}

static NSInteger is65InchScreen = -1;
+ (BOOL)is65InchScreen {
    if (is65InchScreen < 0) {
        // Since iPhone XS Max and iPhone XR share the same resolution, we have to distinguish them using the model identifiers
        // 由于 iPhone XS Max 和 iPhone XR 的屏幕宽高是一致的，我们通过机器 Identifier 加以区别
        is65InchScreen = (kDeviceWidth == self.screenSizeFor65Inch.width && kDeviceHeight == self.screenSizeFor65Inch.height && ([[HDHelper deviceModel] isEqualToString:@"iPhone11,4"] || [[HDHelper deviceModel] isEqualToString:@"iPhone11,6"])) ? 1 : 0;
    }
    return is65InchScreen > 0;
}

static NSInteger is61InchScreen = -1;
+ (BOOL)is61InchScreen {
    if (is61InchScreen < 0) {
        is61InchScreen = (kDeviceWidth == self.screenSizeFor61Inch.width && kDeviceHeight == self.screenSizeFor61Inch.height && [[HDHelper deviceModel] isEqualToString:@"iPhone11,8"]) ? 1 : 0;
    }
    return is61InchScreen > 0;
}

static NSInteger is58InchScreen = -1;
+ (BOOL)is58InchScreen {
    if (is58InchScreen < 0) {
        // Both iPhone XS and iPhone X share the same actual screen sizes, so no need to compare identifiers
        // iPhone XS 和 iPhone X 的物理尺寸是一致的，因此无需比较机器 Identifier
        is58InchScreen = (kDeviceWidth == self.screenSizeFor58Inch.width && kDeviceHeight == self.screenSizeFor58Inch.height) ? 1 : 0;
    }
    return is58InchScreen > 0;
}

static NSInteger is55InchScreen = -1;
+ (BOOL)is55InchScreen {
    if (is55InchScreen < 0) {
        is55InchScreen = (kDeviceWidth == self.screenSizeFor55Inch.width && kDeviceHeight == self.screenSizeFor55Inch.height) ? 1 : 0;
    }
    return is55InchScreen > 0;
}

static NSInteger is47InchScreen = -1;
+ (BOOL)is47InchScreen {
    if (is47InchScreen < 0) {
        is47InchScreen = (kDeviceWidth == self.screenSizeFor47Inch.width && kDeviceHeight == self.screenSizeFor47Inch.height) ? 1 : 0;
    }
    return is47InchScreen > 0;
}

static NSInteger is40InchScreen = -1;
+ (BOOL)is40InchScreen {
    if (is40InchScreen < 0) {
        is40InchScreen = (kDeviceWidth == self.screenSizeFor40Inch.width && kDeviceHeight == self.screenSizeFor40Inch.height) ? 1 : 0;
    }
    return is40InchScreen > 0;
}

static NSInteger is35InchScreen = -1;
+ (BOOL)is35InchScreen {
    if (is35InchScreen < 0) {
        is35InchScreen = (kDeviceWidth == self.screenSizeFor35Inch.width && kDeviceHeight == self.screenSizeFor35Inch.height) ? 1 : 0;
    }
    return is35InchScreen > 0;
}

+ (CGSize)screenSizeFor65Inch {
    return CGSizeMake(414, 896);
}

+ (CGSize)screenSizeFor61Inch {
    return CGSizeMake(414, 896);
}

+ (CGSize)screenSizeFor58Inch {
    return CGSizeMake(375, 812);
}

+ (CGSize)screenSizeFor55Inch {
    return CGSizeMake(414, 736);
}

+ (CGSize)screenSizeFor47Inch {
    return CGSizeMake(375, 667);
}

+ (CGSize)screenSizeFor40Inch {
    return CGSizeMake(320, 568);
}

+ (CGSize)screenSizeFor35Inch {
    return CGSizeMake(320, 480);
}

static CGFloat preferredLayoutWidth = -1;
+ (CGFloat)preferredLayoutAsSimilarScreenWidthForIPad {
    if (preferredLayoutWidth < 0) {
        NSArray<NSNumber *> *widths = @[@([self screenSizeFor65Inch].width),
                                        @([self screenSizeFor58Inch].width),
                                        @([self screenSizeFor40Inch].width)];
        preferredLayoutWidth = kScreenWidth;
        UIWindow *window = [UIApplication sharedApplication].delegate.window ?: [[UIWindow alloc] init];  // iOS 9 及以上的系统，新 init 出来的 window 自动被设置为当前 App 的宽度
        CGFloat windowWidth = CGRectGetWidth(window.bounds);
        for (NSInteger i = 0; i < widths.count; i++) {
            if (windowWidth <= widths[i].hd_CGFloatValue) {
                preferredLayoutWidth = widths[i].hd_CGFloatValue;
                continue;
            }
        }
    }
    return preferredLayoutWidth;
}

+ (UIEdgeInsets)safeAreaInsetsForDeviceWithNotch {
    if (![self isNotchedScreen]) {
        return UIEdgeInsetsZero;
    }

    if ([self isIPad]) {
        return UIEdgeInsetsMake(0, 0, 20, 0);
    }

    UIInterfaceOrientation orientation = [[UIApplication sharedApplication] statusBarOrientation];

    switch (orientation) {
        case UIInterfaceOrientationPortrait:
            return UIEdgeInsetsMake(44, 0, 34, 0);

        case UIInterfaceOrientationPortraitUpsideDown:
            return UIEdgeInsetsMake(34, 0, 44, 0);

        case UIInterfaceOrientationLandscapeLeft:
        case UIInterfaceOrientationLandscapeRight:
            return UIEdgeInsetsMake(0, 44, 21, 44);

        case UIInterfaceOrientationUnknown:
        default:
            return UIEdgeInsetsMake(44, 0, 34, 0);
    }
}

static NSInteger isHighPerformanceDevice = -1;
+ (BOOL)isHighPerformanceDevice {
    if (isHighPerformanceDevice < 0) {
        NSString *model = [HDHelper deviceModel];
        NSString *identifier = [model hd_stringMatchedByPattern:@"\\d+"];
        NSInteger version = identifier.integerValue;
        if (iS_iPad) {
            isHighPerformanceDevice = version >= 5 ? 1 : 0;  // iPad Air 2
        } else {
            isHighPerformanceDevice = version >= 10 ? 1 : 0;  // iPhone 8
        }
    }
    return isHighPerformanceDevice > 0;
}

+ (BOOL)isZoomedMode {
    if (!iS_iPhone) {
        return NO;
    }

    CGFloat nativeScale = UIScreen.mainScreen.nativeScale;
    CGFloat scale = UIScreen.mainScreen.scale;

    // 对于所有的 Plus 系列 iPhone，屏幕物理像素低于软件层面的渲染像素，不管标准模式还是放大模式，nativeScale 均小于 scale，所以需要特殊处理才能准确区分放大模式
    // https://www.paintcodeapp.com/news/ultimate-guide-to-iphone-resolutions
    BOOL shouldBeDownsampledDevice = CGSizeEqualToSize(UIScreen.mainScreen.nativeBounds.size, CGSizeMake(1080, 1920));
    if (shouldBeDownsampledDevice) {
        scale /= 1.15;
    }

    return nativeScale > scale;
}

- (void)handleAppSizeWillChange:(NSNotification *)notification {
    preferredLayoutWidth = -1;
}

+ (CGSize)applicationSize {
    /// applicationFrame 在 iPad 下返回的 size 要比 window 实际的 size 小，这个差值体现在 origin 上，所以用 origin + size 修正得到正确的大小。
    BeginIgnoreDeprecatedWarning
        CGRect applicationFrame = [UIScreen mainScreen].applicationFrame;
    EndIgnoreDeprecatedWarning return CGSizeMake(applicationFrame.size.width + applicationFrame.origin.x, applicationFrame.size.height + applicationFrame.origin.y);
}

/// 判断是否是刘海屏
+ (BOOL)hd_navigationBarIsNotchedScreen{
    return [self hd_safeDistanceBottom] > 0;
}
/// 顶部安全区高度
+ (CGFloat)hd_safeDistanceTop {
    if (@available(iOS 11.0, *)) {
        UIWindow *window = [UIApplication sharedApplication].delegate.window;
        return window.safeAreaInsets.top;
    }
    return 0;
}

/// 底部安全区高度
+ (CGFloat)hd_safeDistanceBottom {
    if (@available(iOS 11.0, *)) {
        UIWindow *window = [UIApplication sharedApplication].delegate.window;
        return window.safeAreaInsets.bottom;
    }
    return 0;
}


/// 顶部状态栏高度（包括安全区）
+ (CGFloat)hd_statusBarHeight {
    if (@available(iOS 13.0, *)) {
        NSSet *set = [UIApplication sharedApplication].connectedScenes;
        UIWindowScene *windowScene = [set anyObject];
        UIStatusBarManager *statusBarManager = windowScene.statusBarManager;
        return statusBarManager.statusBarFrame.size.height;
    } else {
        return [UIApplication sharedApplication].statusBarFrame.size.height;
    }
}

/// 导航栏高度
+ (CGFloat)hd_navigationBarHeight {
    return 44.0f;
}

/// 状态栏+导航栏的高度
+ (CGFloat)hd_navigationFullHeight {
    return [self hd_statusBarHeight] + [self hd_navigationBarHeight];
}

/// 底部导航栏高度
+ (CGFloat)hd_tabBarHeight {
    return 49.0f;
}

/// 底部导航栏高度（包括安全区）
+ (CGFloat)hd_tabBarFullHeight {
    return [self hd_statusBarHeight] + [self hd_safeDistanceBottom];
}

@end

@implementation HDHelper (SystemVersion)

+ (NSInteger)numbericOSVersion {
    NSString *OSVersion = [[UIDevice currentDevice] systemVersion];
    NSArray *OSVersionArr = [OSVersion componentsSeparatedByString:@"."];

    NSInteger numbericOSVersion = 0;
    NSInteger pos = 0;

    while ([OSVersionArr count] > pos && pos < 3) {
        numbericOSVersion += ([[OSVersionArr objectAtIndex:pos] integerValue] * pow(10, (4 - pos * 2)));
        pos++;
    }

    return numbericOSVersion;
}

+ (NSComparisonResult)compareSystemVersion:(NSString *)currentVersion toVersion:(NSString *)targetVersion {
    NSArray *currentVersionArr = [currentVersion componentsSeparatedByString:@"."];
    NSArray *targetVersionArr = [targetVersion componentsSeparatedByString:@"."];

    NSInteger pos = 0;

    while ([currentVersionArr count] > pos || [targetVersionArr count] > pos) {
        NSInteger v1 = [currentVersionArr count] > pos ? [[currentVersionArr objectAtIndex:pos] integerValue] : 0;
        NSInteger v2 = [targetVersionArr count] > pos ? [[targetVersionArr objectAtIndex:pos] integerValue] : 0;
        if (v1 < v2) {
            return NSOrderedAscending;
        } else if (v1 > v2) {
            return NSOrderedDescending;
        }
        pos++;
    }

    return NSOrderedSame;
}

+ (BOOL)isCurrentSystemAtLeastVersion:(NSString *)targetVersion {
    return [HDHelper compareSystemVersion:[[UIDevice currentDevice] systemVersion] toVersion:targetVersion] == NSOrderedSame || [HDHelper compareSystemVersion:[[UIDevice currentDevice] systemVersion] toVersion:targetVersion] == NSOrderedDescending;
}

+ (BOOL)isCurrentSystemLowerThanVersion:(NSString *)targetVersion {
    return [HDHelper compareSystemVersion:[[UIDevice currentDevice] systemVersion] toVersion:targetVersion] == NSOrderedAscending;
}

@end

@implementation HDHelper (Image)

+ (UIImage *)placeholderImageWithBgColor:(UIColor *__nullable)bgColor cornerRadius:(CGFloat)radius size:(CGSize)size logoImage:(UIImage *__nullable)logoImage logoSize:(CGSize)logoSize {
    return [self placeholderImageWithBgColor:bgColor cornerRadius:radius size:size logoImage:logoImage logoSize:logoSize logo2CointainerWidthRate:0.4];
}

+ (UIImage *)placeholderImageWithBgColor:(UIColor *__nullable)bgColor cornerRadius:(CGFloat)radius size:(CGSize)size logoImage:(UIImage *__nullable)logoImage logoSize:(CGSize)logoSize logo2CointainerWidthRate:(CGFloat)logo2CointainerWidthRate {

    bgColor = bgColor ?: HexColor(0xE4E5EA);

    // 背景图
    UIImage *bgImage = [UIImage hd_imageWithColor:bgColor size:size cornerRadius:radius];

    // logo
    logoImage = logoImage ?: [UIImage imageNamed:@"logo_white" inBundle:[NSBundle hd_kitCoreHDKitCoreResources] compatibleWithTraitCollection:nil];

    // logo 原图高宽比例
    CGFloat scale = logoImage.size.height / logoImage.size.width;

    // logo 尺寸
    logoSize = CGSizeIsEmpty(logoSize) ? CGSizeMake(size.width * logo2CointainerWidthRate, size.width * logo2CointainerWidthRate * scale) : logoSize;

    // 缩放 logo，生成指定大小的 logo 图片
    logoImage = [logoImage hd_imageResizedWithScreenScaleInLimitedSize:logoSize];

    // 计算绘制点
    CGPoint point = CGPointMake((bgImage.size.width - logoSize.width) * 0.5, (bgImage.size.height - logoSize.height) * 0.5);

    // 合成
    UIImage *mergedImage = [bgImage hd_imageWithImageAbove:logoImage atPoint:point];

    return mergedImage;
}

+ (UIImage *)placeholderImageWithCornerRadius:(CGFloat)radius size:(CGSize)size {
    return [self placeholderImageWithBgColor:nil cornerRadius:radius size:size logoImage:nil logoSize:CGSizeZero];
}

+ (UIImage *)placeholderImageWithBgColor:(UIColor *__nullable)bgColor cornerRadius:(CGFloat)radius size:(CGSize)size {
    return [self placeholderImageWithBgColor:bgColor cornerRadius:radius size:size logoImage:nil logoSize:CGSizeZero];
}

+ (UIImage *)placeholderImageWithCornerRadius:(CGFloat)radius size:(CGSize)size logoSize:(CGSize)logoSize {
    return [self placeholderImageWithBgColor:nil cornerRadius:radius size:size logoImage:nil logoSize:logoSize];
}

+ (UIImage *)placeholderImageWithCornerRadius:(CGFloat)radius size:(CGSize)size logoWidth:(CGFloat)logoWidth {
    return [self placeholderImageWithBgColor:nil cornerRadius:radius size:size logoImage:nil logoSize:CGSizeMake(logoWidth, logoWidth * 72 / 72.0)];
}

+ (UIImage *)placeholderImageWithSize:(CGSize)size logoWidth:(CGFloat)logoWidth {
    CGSize logoSize = CGSizeMake(logoWidth, logoWidth * 72 / 72.0);
    return [self placeholderImageWithBgColor:nil cornerRadius:5 size:size logoImage:nil logoSize:logoSize];
}

+ (UIImage *)placeholderImageWithSize:(CGSize)size {
    return [self placeholderImageWithBgColor:nil cornerRadius:5 size:size];
}

+ (UIImage *)circlePlaceholderImage {
    return [self placeholderImageWithCornerRadius:30 size:CGSizeMake(60, 60)];
}

+ (UIImage *)placeholderImage {
    return [self placeholderImageWithSize:CGSizeMake(60, 60)];
}
@end

@implementation HDHelper (Font)
+ (__kindof NSString *)narrowestFontName {
    NSArray<NSString *> *familyNames = [UIFont familyNames];
    NSArray<NSArray<NSString *> *> *allFontNames = [familyNames mapObjectsUsingBlock:^id _Nonnull(NSString *_Nonnull family, NSUInteger idx) {
        return [UIFont fontNamesForFamilyName:family];
    }];
    NSString *string = @"example string";
    __block CGFloat minimumWidth = CGFLOAT_MAX;
    __block NSString *minimumFontName;
    [allFontNames hd_enumerateNestedArrayWithBlock:^(NSString *_Nonnull fontName, BOOL *_Nonnull stop) {
        UILabel *label = UILabel.new;
        label.text = string;
        label.font = [UIFont fontWithName:fontName size:11];
        CGSize size = [label sizeThatFits:CGSizeMake(CGFLOAT_MAX, CGFLOAT_MAX)];
        if (size.width < minimumWidth) {
            minimumWidth = size.width;
            minimumFontName = fontName;
        }
    }];
    return minimumFontName;
}


@end

@implementation HDHelper (Keyboard)

HDSynthesizeBOOLProperty(keyboardVisible, setKeyboardVisible)
HDSynthesizeCGFloatProperty(lastKeyboardHeight, setLastKeyboardHeight)

- (void)handleKeyboardWillShow:(NSNotification *)notification {
    self.keyboardVisible = YES;
    self.lastKeyboardHeight = [HDHelper keyboardHeightWithNotification:notification];
}

- (void)handleKeyboardWillHide:(NSNotification *)notification {
    self.keyboardVisible = NO;
}

+ (BOOL)isKeyboardVisible {
    BOOL visible = [HDHelper sharedInstance].keyboardVisible;
    return visible;
}

+ (CGFloat)lastKeyboardHeightInApplicationWindowWhenVisible {
    return [HDHelper sharedInstance].lastKeyboardHeight;
}

+ (CGRect)keyboardRectWithNotification:(NSNotification *)notification {
    NSDictionary *userInfo = [notification userInfo];
    CGRect keyboardRect = [[userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    // 注意iOS8以下的系统在横屏时得到的rect，宽度和高度相反了，所以不建议直接通过这个方法获取高度，而是使用<code>keyboardHeightWithNotification:inView:</code>，因为在后者的实现里会将键盘的rect转换坐标系，转换过程就会处理横竖屏旋转问题。
    return keyboardRect;
}

+ (CGFloat)keyboardHeightWithNotification:(NSNotification *)notification {
    return [HDHelper keyboardHeightWithNotification:notification inView:nil];
}

+ (CGFloat)keyboardHeightWithNotification:(nullable NSNotification *)notification inView:(nullable UIView *)view {
    CGRect keyboardRect = [self keyboardRectWithNotification:notification];
    if (@available(iOS 13.0, *)) {
        // iOS 13 分屏键盘 x 不是 0，不知道是系统 BUG 还是故意这样，先这样保护，再观察一下后面的 beta 版本
        if (IS_SPLIT_SCREEN_IPAD && keyboardRect.origin.x > 0) {
            keyboardRect.origin.x = 0;
        }
    }
    if (!view) { return CGRectGetHeight(keyboardRect); }
    CGRect keyboardRectInView = [view convertRect:keyboardRect fromView:view.window];
    CGRect keyboardVisibleRectInView = CGRectIntersection(view.bounds, keyboardRectInView);
    CGFloat resultHeight = CGRectIsValidated(keyboardVisibleRectInView) ? CGRectGetHeight(keyboardVisibleRectInView) : 0;
    return resultHeight;
}

+ (NSTimeInterval)keyboardAnimationDurationWithNotification:(NSNotification *)notification {
    NSDictionary *userInfo = [notification userInfo];
    NSTimeInterval animationDuration = [[userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    return animationDuration;
}

+ (UIViewAnimationCurve)keyboardAnimationCurveWithNotification:(NSNotification *)notification {
    NSDictionary *userInfo = [notification userInfo];
    UIViewAnimationCurve curve = (UIViewAnimationCurve)[[userInfo objectForKey:UIKeyboardAnimationCurveUserInfoKey] integerValue];
    return curve;
}

+ (UIViewAnimationOptions)keyboardAnimationOptionsWithNotification:(NSNotification *)notification {
    UIViewAnimationOptions options = [HDHelper keyboardAnimationCurveWithNotification:notification]<<16;
    return options;
}

@end


@implementation HDHelper (Animation)

+ (void)executeAnimationBlock:(__attribute__((noescape)) void (^)(void))animationBlock completionBlock:(__attribute__((noescape)) void (^)(void))completionBlock {
    if (!animationBlock) return;
    [CATransaction begin];
    [CATransaction setCompletionBlock:completionBlock];
    animationBlock();
    [CATransaction commit];
}

@end
