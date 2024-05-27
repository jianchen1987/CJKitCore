//
//  HDLogger.m
//  HDKitCore
//
//  Created by VanJay on 2019/12/30.
//  Copyright © 2019 chaos network technology. All rights reserved.
//

#import "HDLogger.h"
#import "HDLogItem.h"
#import "HDLogNameManager.h"

@interface HDLogger ()
@property (nonatomic, strong) NSDateFormatter *dateFormatter;  ///< dateFormatter
@end

@implementation HDLogger

+ (instancetype)sharedInstance {
    static dispatch_once_t onceToken;
    static HDLogger *instance = nil;
    dispatch_once(&onceToken, ^{
        instance = [[super allocWithZone:NULL] init];
    });
    return instance;
}

+ (id)allocWithZone:(struct _NSZone *)zone {
    return [self sharedInstance];
}

- (instancetype)init {
    if (self = [super init]) {
        self.logNameManager = [[HDLogNameManager alloc] init];
    }
    return self;
}

- (NSString *_Nullable)printLogWithFile:(const char *)file line:(int)line func:(const char *)func logItem:(HDLogItem *)logItem {
    // 禁用了某个 name 则直接退出
    if (!logItem.enabled) return nil;

    if ([self.delegate respondsToSelector:@selector(printLogWithFile:line:func:logItem:defaultString:)]) {

        NSString *fileString = [NSString stringWithFormat:@"%s", file];
        NSString *funcString = [NSString stringWithFormat:@"%s", func];
        NSString *defaultString = [NSString stringWithFormat:@"%@:%@ | %@", funcString, @(line), logItem];

        return [self.delegate printLogWithFile:fileString line:line func:funcString logItem:logItem defaultString:defaultString];
    } else {
        NSString *timeStr = [self.dateFormatter stringFromDate:[NSDate date]];
        NSString *fileName = [[NSString stringWithUTF8String:file] lastPathComponent];
        NSString *str = [NSString stringWithFormat:@"%@:%d | %@ | %@ | %@\n", fileName, line, timeStr, logItem.levelDisplayString, logItem.logString];

        fprintf(stderr, "%s", str.UTF8String);
        return str;
    }
}

- (NSDateFormatter *)dateFormatter {
    if (!_dateFormatter) {
        _dateFormatter = [[NSDateFormatter alloc] init];
        [_dateFormatter setDateStyle:NSDateFormatterMediumStyle];
        [_dateFormatter setTimeStyle:NSDateFormatterShortStyle];
        [_dateFormatter setDateFormat:@"HH:mm:ss"];
    }
    return _dateFormatter;
}
@end
