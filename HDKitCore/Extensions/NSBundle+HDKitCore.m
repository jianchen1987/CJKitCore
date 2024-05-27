//
//  NSBundle+HDKitCore.m
//  HDKitCore
//
//  Created by VanJay on 2020/5/11.
//

#import "NSBundle+HDKitCore.h"

@implementation NSBundle (HDKitCore)
+ (NSBundle *)hd_kitCoreHDKitCoreResources {
    static NSBundle *resourceBundle = nil;
    return [self kitCore_bundleWithStaticResourceBundle:resourceBundle bundleName:@"HDKitCoreResources"];
}

+ (NSBundle *)hd_bundleInFramework:(NSString *)frameworkName bundleName:(NSString *)bundleName {
    NSBundle *mainBundle = [NSBundle mainBundle];
    NSString *resourceBundlePath = [mainBundle pathForResource:[NSString stringWithFormat:@"Frameworks/%@.framework/%@", frameworkName, bundleName] ofType:@"bundle"];
    if (!resourceBundlePath) {
        resourceBundlePath = [mainBundle pathForResource:bundleName ofType:@"bundle"];
    }
    return [NSBundle bundleWithPath:resourceBundlePath] ?: mainBundle;
}

#pragma mark - private methods
+ (NSBundle *)kitCore_bundleWithStaticResourceBundle:(NSBundle *)resourceBundle bundleName:(NSString *)name {
    if (!resourceBundle) {
        NSBundle *mainBundle = [NSBundle mainBundle];
        NSString *resourcePath = [mainBundle pathForResource:[NSString stringWithFormat:@"Frameworks/HDKitCore.framework/%@", name] ofType:@"bundle"];
        if (!resourcePath) {
            resourcePath = [mainBundle pathForResource:name ofType:@"bundle"];
        }
        resourceBundle = [NSBundle bundleWithPath:resourcePath] ?: mainBundle;
    }
    return resourceBundle;
}
@end
