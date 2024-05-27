//
//  HDLogItem.m
//  HDKitCore
//
//  Created by VanJay on 2019/12/30.
//  Copyright © 2019 chaos network technology. All rights reserved.
//

#import "HDLogItem.h"
#import "HDLogNameManager.h"
#import "HDLogger.h"

@implementation HDLogItem

+ (instancetype)logItemWithLevel:(HDLogLevel)level name:(NSString *)name logString:(NSString *)logString, ... {
    HDLogItem *logItem = [[HDLogItem alloc] init];
    logItem.level = level;
    logItem.name = name;

    HDLogNameManager *logNameManager = [HDLogger sharedInstance].logNameManager;
    if ([logNameManager containsLogName:name]) {
        logItem.enabled = [logNameManager enabledForLogName:name];
    } else {
        [logNameManager setEnabled:YES forLogName:name];
        logItem.enabled = YES;
    }

    va_list args;
    va_start(args, logString);
    logItem.logString = [[NSString alloc] initWithFormat:logString arguments:args];
    va_end(args);

    return logItem;
}

- (instancetype)init {
    if (self = [super init]) {
        self.enabled = YES;
    }
    return self;
}

- (NSString *)levelDisplayString {
    switch (self.level) {
        case HDLogLevelInfo:
            return @"⏱";
        case HDLogLevelWarn:
            return @"⚠️";
        case HDLogLevelErr:
            return @"🆘";
        default:
            return @"🐞";
    }
}

- (NSString *)description {
    return [NSString stringWithFormat:@"%@ | %@ | %@", self.levelDisplayString, self.name.length > 0 ? self.name : @"Default", self.logString];
}

@end
