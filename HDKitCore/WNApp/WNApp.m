//
//  WNApp.m
//  HDKitCore
//
//  Created by seeu on 2022/3/17.
//

#import "WNApp.h"

@interface WNApp ()

@property (nonatomic, copy) NSString *appId;
@property (nonatomic, copy) NSString *secrectKey;
@property (nonatomic, copy) NSString *privateKey;

@end

@implementation WNApp

+ (instancetype)appWithAppId:(NSString *)appId secrectKey:(NSString *)secrectKey privateKey:(NSString *)pKey {
    WNApp *app = [[WNApp alloc] init];
    if (app) {
        app.appId = appId;
        app.secrectKey = secrectKey;
        app.privateKey = pKey;
    }
    return app;
}

@end
