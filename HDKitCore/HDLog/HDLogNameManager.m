//
//  HDLogNameManager.m
//  HDKitCore
//
//  Created by VanJay on 2019/12/30.
//  Copyright © 2019 chaos network technology. All rights reserved.
//

#import "HDLogNameManager.h"
#import "HDLogger.h"

NSString *const HDLoggerAllNamesKeyInUserDefaults = @"HDLoggerAllNamesKeyInUserDefaults";

@interface HDLogNameManager ()

@property (nonatomic, strong) NSMutableDictionary<NSString *, NSNumber *> *mutableAllNames;
@property (nonatomic, assign) BOOL didInitialize;
@end

@implementation HDLogNameManager

- (instancetype)init {
    if (self = [super init]) {
        self.mutableAllNames = [[NSMutableDictionary alloc] init];

        NSDictionary<NSString *, NSNumber *> *allLogNames = [[NSUserDefaults standardUserDefaults] dictionaryForKey:HDLoggerAllNamesKeyInUserDefaults];
        for (NSString *logName in allLogNames) {
            [self setEnabled:allLogNames[logName].boolValue forLogName:logName];
        }

        // 初始化时从 NSUserDefaults 里获取值的过程，不希望触发 delegate，所以加这个标志位
        self.didInitialize = YES;
    }
    return self;
}

- (NSDictionary<NSString *, NSNumber *> *)allNames {
    if (self.mutableAllNames.count) {
        return [self.mutableAllNames copy];
    }
    return nil;
}

- (BOOL)containsLogName:(NSString *)logName {
    if (logName.length > 0) {
        return !!self.mutableAllNames[logName];
    }
    return NO;
}

- (void)setEnabled:(BOOL)enabled forLogName:(NSString *)logName {
    if (logName.length > 0) {
        self.mutableAllNames[logName] = @(enabled);

        if (!self.didInitialize) return;

        [self synchronizeUserDefaults];

        if ([[HDLogger sharedInstance].delegate respondsToSelector:@selector(logName:didChangeEnabled:)]) {
            [[HDLogger sharedInstance].delegate logName:logName didChangeEnabled:enabled];
        }
    }
}

- (BOOL)enabledForLogName:(NSString *)logName {
    if (logName.length > 0) {
        if ([self containsLogName:logName]) {
            return [self.mutableAllNames[logName] boolValue];
        }
    }
    return YES;
}

- (void)removeLogName:(NSString *)logName {
    if (logName.length > 0) {
        [self.mutableAllNames removeObjectForKey:logName];

        if (!self.didInitialize) return;

        [self synchronizeUserDefaults];

        if ([[HDLogger sharedInstance].delegate respondsToSelector:@selector(HDLogNameDidRemove:)]) {
            [[HDLogger sharedInstance].delegate HDLogNameDidRemove:logName];
        }
    }
}

- (void)removeAllNames {
    BOOL shouldCallDelegate = self.didInitialize && [[HDLogger sharedInstance].delegate respondsToSelector:@selector(HDLogNameDidRemove:)];
    NSDictionary<NSString *, NSNumber *> *allNames = nil;
    if (shouldCallDelegate) {
        allNames = self.allNames;
    }

    [self.mutableAllNames removeAllObjects];

    [self synchronizeUserDefaults];

    if (shouldCallDelegate) {
        for (NSString *logName in allNames.allKeys) {
            [[HDLogger sharedInstance].delegate HDLogNameDidRemove:logName];
        }
    }
}

- (void)synchronizeUserDefaults {
    [[NSUserDefaults standardUserDefaults] setObject:self.allNames forKey:HDLoggerAllNamesKeyInUserDefaults];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

@end
