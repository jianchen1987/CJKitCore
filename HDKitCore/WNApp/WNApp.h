//
//  WNApp.h
//  HDKitCore
//
//  Created by seeu on 2022/3/17.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface WNApp : NSObject

///< appid
@property (nonatomic, copy, readonly) NSString *appId;
@property (nonatomic, copy, readonly) NSString *secrectKey;
@property (nonatomic, copy, readonly) NSString *privateKey;

- (instancetype)init __attribute__((unavailable("Use +[appWithAppId:secrectKey:privateKey:] instead.")));

+ (instancetype)appWithAppId:(NSString *)appId secrectKey:(NSString *)secrectKey privateKey:(NSString *)pKey;

@end

NS_ASSUME_NONNULL_END
