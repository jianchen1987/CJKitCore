//
//  HDPodAsset.m
//  HDServiceKit
//
//  Created by VanJay on 03/06/2020.
//  Copyright © 2019 chaos network technology. All rights reserved.
//

#import "HDPodAsset.h"

@implementation HDPodAsset

+ (NSString *)pathForFilename:(NSString *)filename pod:(NSString *)podName {
    NSString *bundlePath = [self bundlePathForPod:podName];
    if (!bundlePath) {
        return nil;
    }

    NSBundle *bundle = [NSBundle bundleWithPath:bundlePath];
    NSString *extension = [filename pathExtension];
    NSString *withoutExtension = [[filename lastPathComponent] stringByDeletingPathExtension];
    NSString *path = [bundle pathForResource:withoutExtension ofType:extension];

    return path;
}

+ (NSString *)stringForFilename:(NSString *)filename pod:(NSString *)podName {
    NSString *bundlePath = [self bundlePathForPod:podName];
    if (!bundlePath) {
        return nil;
    }

    NSBundle *bundle = [NSBundle bundleWithPath:bundlePath];
    NSString *extension = [filename pathExtension];
    NSString *withoutExtension = [[filename lastPathComponent] stringByDeletingPathExtension];
    NSString *path = [bundle pathForResource:withoutExtension ofType:extension];

    if (path) {
        return [NSString stringWithContentsOfFile:path
                                         encoding:NSUTF8StringEncoding
                                            error:nil];
    }
    return nil;
}

+ (NSData *)dataForFilename:(NSString *)filename pod:(NSString *)podName {
    NSString *bundlePath = [self bundlePathForPod:podName];
    if (!bundlePath) {
        return nil;
    }

    NSBundle *bundle = [NSBundle bundleWithPath:bundlePath];
    NSString *extension = [filename pathExtension];
    NSString *withoutExtension = [[filename lastPathComponent] stringByDeletingPathExtension];
    NSString *path = [bundle pathForResource:withoutExtension ofType:extension];

    if (path) {
        return [NSData dataWithContentsOfFile:path options:0 error:nil];
    }
    return nil;
}

+ (NSArray *)assetsInPod:(NSString *)podName {
    NSBundle *bundle = [self bundleContainsPod:podName];
    if (!bundle) {
        return nil;
    }

    NSString *bundleRoot = [bundle bundlePath];
    NSArray *paths = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:bundleRoot error:nil];
    return paths;
}

+ (NSBundle *)bundleForPod:(NSString *)podName {
    NSString *bundlePath = [self bundlePathForPod:podName];
    if (bundlePath) {
        return [NSBundle bundleWithPath:bundlePath];
    }

    // some pods do not use "resource_bundles"
    // please check the pod's podspec
    return nil;
}

#pragma mark - private

+ (NSArray *)recursivePathsForResourcesOfType:(NSString *)type name:(NSString *)name inDirectory:(NSString *)directoryPath {

    NSMutableArray *filePaths = [[NSMutableArray alloc] init];
    NSDirectoryEnumerator *enumerator = [[NSFileManager defaultManager] enumeratorAtPath:directoryPath];

    NSString *filePath;

    while ((filePath = [enumerator nextObject]) != nil) {
        if (!type || [[filePath pathExtension] isEqualToString:type]) {
            if (!name || [[[filePath lastPathComponent] stringByDeletingPathExtension] isEqualToString:name]) {
                [filePaths addObject:[directoryPath stringByAppendingPathComponent:filePath]];
            }
        }
    }

    return filePaths;
}

+ (NSBundle *)bundleContainsPod:(NSString *)podName {
    // search all bundles
    for (NSBundle *bundle in [NSBundle allBundles]) {
        NSString *bundlePath = [bundle pathForResource:podName ofType:@"bundle"];
        if (bundlePath) {
            return bundle;
        }
    }

    // search all frameworks
    for (NSBundle *bundle in [NSBundle allFrameworks]) {
        NSString *bundlePath = [bundle pathForResource:podName ofType:@"bundle"];
        if (bundlePath) {
            return bundle;
        }
    }

    // some pods do not use "resource_bundles"
    // please check the pod's podspec
    return nil;
}

+ (NSString *)bundlePathForPod:(NSString *)podName {
    // search all bundles
    for (NSBundle *bundle in [NSBundle allBundles]) {
        NSString *bundlePath = [bundle pathForResource:podName ofType:@"bundle"];
        if (bundlePath) {
            return bundlePath;
        }
    }

    // search all frameworks
    for (NSBundle *bundle in [NSBundle allFrameworks]) {
        NSString *bundlePath = [bundle pathForResource:podName ofType:@"bundle"];
        if (bundlePath) {
            return bundlePath;
        }
    }
    // some pods do not use "resource_bundles"
    // please check the pod's podspec
    return nil;
}

@end
