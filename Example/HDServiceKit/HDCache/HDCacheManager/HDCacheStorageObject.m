//
//  HDCacheStorageObject.m
//  HDServiceKit
//
//  Created by VanJay on 2019/8/24.
//  Copyright © 2019 chaos network technology. All rights reserved.
//

#import "HDCacheStorageObject.h"
#import "NSJSONSerialization+HDCache.h"
#import "NSString+HDCache.h"
#import <YYModel/YYModel.h>

@interface HDCacheStorageObject ()

@property (nonatomic, copy, readwrite) NSString *storageString;
@property (nonatomic, strong) NSMutableDictionary *storageOptions;

@end

@implementation HDCacheStorageObject

- (instancetype)initWithObject:(id)object {
    if (self = [self init]) {
        NSDictionary *dictionary = [self dictionaryWithObject:object];
        NSString *objectString = [NSJSONSerialization
            hdCache_stringWithJSONObject:dictionary
                                 options:NSJSONWritingPrettyPrinted
                                   error:nil];
        self.storageString = [objectString hdCache_AESEncryptAndBase64Encode];
    }
    return self;
}

- (id)storageObject {
    // AES解密
    NSString *objectString =
        [self.storageString hdCache_AESDecryptAndBase64Decode];
    NSDictionary *dictionary = [NSJSONSerialization
        hdCache_objectWithJSONString:objectString
                             options:NSJSONReadingAllowFragments
                               error:nil];
    return [self storageObjectWithDictionary:dictionary];
}

- (id)storageObjectWithDictionary:(NSDictionary *)dictionary {
    __block id returnObject = nil;
    [dictionary enumerateKeysAndObjectsUsingBlock:^(NSString *className, id obj,
                                                    BOOL *stop) {
        Class cls = NSClassFromString(className);
        if ([cls isSubclassOfClass:[NSString class]]) {
            returnObject = [NSMutableString stringWithString:obj];
        } else if ([cls isSubclassOfClass:[NSURL class]]) {
            returnObject = [NSURL URLWithString:obj];
        } else if ([cls isSubclassOfClass:[NSNumber class]]) {
            NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
            returnObject = [numberFormatter numberFromString:obj];
        } else if ([cls isSubclassOfClass:[NSData class]]) {
            returnObject = [obj dataUsingEncoding:NSUTF8StringEncoding];
        } else if ([cls isSubclassOfClass:[NSDictionary class]]) {
            __block NSMutableDictionary *mutDictionary =
                [NSMutableDictionary dictionary];
            [((NSDictionary *)obj) enumerateKeysAndObjectsUsingBlock:^(id key, id obj,
                                                                       BOOL *stop) {
                id tmpObject = [self storageObjectWithDictionary:obj];
                if (tmpObject)
                    [mutDictionary setObject:tmpObject forKey:key];
            }];
            returnObject =
                [NSMutableDictionary dictionaryWithDictionary:mutDictionary];
        } else if ([cls isSubclassOfClass:[NSArray class]]) {
            __block NSMutableArray *mutArray = [NSMutableArray array];
            [((NSArray *)obj) enumerateObjectsUsingBlock:^(id obj, NSUInteger idx,
                                                           BOOL *stop) {
                id tmpObject = [self storageObjectWithDictionary:obj];
                if (tmpObject)
                    [mutArray addObject:tmpObject];
            }];
            returnObject = [NSMutableArray arrayWithArray:mutArray];
        } else if ([cls isSubclassOfClass:[NSNull class]]) {
            returnObject = [NSNull null];
        } else if ([cls isSubclassOfClass:[NSObject class]]) {
            NSDictionary *dictionary = [NSJSONSerialization
                hdCache_objectWithJSONString:obj
                                     options:NSJSONReadingAllowFragments
                                       error:nil];
            returnObject = [cls yy_modelWithDictionary:dictionary];
        } else {
            // TODO:更多的类型
        }
    }];
    return returnObject;
}

- (NSDictionary *)dictionaryWithObject:(id)object {
    // 把object转成字符串dictionary，保存方便
    NSString *objectKey = NSStringFromClass([object class]);
    NSMutableDictionary *dictionary = [NSMutableDictionary dictionary];
    if ([object isKindOfClass:[NSString class]]) {
        [dictionary setValue:object forKey:objectKey];
    } else if ([object isKindOfClass:[NSURL class]]) {
        [dictionary setValue:((NSURL *)object).absoluteString forKey:objectKey];
    } else if ([object isKindOfClass:[NSNumber class]]) {
        [dictionary setValue:((NSNumber *)object).stringValue forKey:objectKey];
    } else if ([object isKindOfClass:[NSData class]]) {
        NSString *dataString = [[NSString alloc] initWithData:object
                                                     encoding:NSUTF8StringEncoding];
        [dictionary setValue:dataString forKey:objectKey];
    } else if ([object isKindOfClass:[NSDictionary class]]) {
        __block NSMutableDictionary *objectDictionary =
            [NSMutableDictionary dictionary];
        [((NSDictionary *)object) enumerateKeysAndObjectsUsingBlock:^(
                                      id key, id obj, BOOL *stop) {
            NSDictionary *objDictionary = [self dictionaryWithObject:obj];
            [objectDictionary setValue:objDictionary forKey:key];
        }];
        [dictionary setValue:objectDictionary forKey:objectKey];
    } else if ([object isKindOfClass:[NSArray class]]) {
        __block NSMutableArray *objectArray = [NSMutableArray array];
        [((NSArray *)object) enumerateObjectsUsingBlock:^(id obj, NSUInteger idx,
                                                          BOOL *stop) {
            NSDictionary *objDictionary = [self dictionaryWithObject:obj];
            [objectArray addObject:objDictionary];
        }];
        [dictionary setValue:objectArray forKey:objectKey];
    } else if ([object isKindOfClass:[NSNull class]]) {
        [dictionary setValue:@"" forKey:objectKey];
    } else if ([object isKindOfClass:[NSObject class]]) {

        NSDictionary *dict = [object yy_modelToJSONObject];

        NSString *objectString = [NSJSONSerialization
            hdCache_stringWithJSONObject:dict
                                 options:NSJSONWritingPrettyPrinted
                                   error:nil];
        [dictionary setValue:objectString forKey:objectKey];
    } else {
        // TODO:更多的类型
    }
    return dictionary;
}

#pragma mark -
- (NSMutableDictionary *)storageOptions {
    return _storageOptions ?: ({ _storageOptions = NSMutableDictionary.new; });
}

- (NSString *)objectIdentifier {
    return _objectIdentifier
        ?: ({ _objectIdentifier = [self.storageString hdCache_md5]; });
}

- (HDCacheStorageObjectTimeOutInterval)storageIntervalType {
    if (self.timeoutInterval > 0) {
        return HDCacheStorageObjectIntervalTiming;
    } else if (self.timeoutInterval < 0) {
        return HDCacheStorageObjectIntervalAllTime;
    } else {
        return HDCacheStorageObjectIntervalDefault;
    }
}

#pragma mark - NSCoding
- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:self.storageString forKey:@"storageString"];
    [aCoder encodeObject:self.objectIdentifier forKey:@"objectIdentifier"];
    [aCoder encodeObject:@(self.timeoutInterval) forKey:@"timeoutInterval"];
    [aCoder encodeObject:self.storageOptions forKey:@"storageOptions"];
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    if (self = [self init]) {
        self.storageString = [aDecoder decodeObjectForKey:@"storageString"];
        self.objectIdentifier = [aDecoder decodeObjectForKey:@"objectIdentifier"];
        self.timeoutInterval = (NSTimeInterval)[
            [aDecoder decodeObjectForKey:@"timeoutInterval"] doubleValue];
        self.storageOptions = [aDecoder decodeObjectForKey:@"storageOptions"];
    }
    return self;
}

@end
