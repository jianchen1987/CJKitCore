//
//  HDViewController.m
//  HDKitCore
//
//  Created by wangwanjie on 03/23/2020.
//  Copyright (c) 2020 wangwanjie. All rights reserved.
//

#import "HDViewController.h"
#import "HDTextViewViewController.h"
#import <HDKitCore/HDKitCore.h>

@interface HDViewController ()
@end

@implementation HDViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.view.backgroundColor = UIColor.whiteColor;
}

- (void)checkRegularExpression {
    // 正则校验
    BOOL isValidPassword = @"qwe12".hd_isValidPassword;
    BOOL isValidPassword2 = @"qwe123".hd_isValidPassword;
    BOOL isValidPassword3 = @"qwe.:,".hd_isValidPassword;
    BOOL isValidPassword4 = @"123!@#".hd_isValidPassword;
    BOOL isValidPassword5 = @"q123!@#".hd_isValidPassword;
    BOOL isValidPassword6 = @"Q123!@#".hd_isValidPassword;
    BOOL isValidPassword7 = @"2123!,,,,,....".hd_isValidPassword;

    BOOL isValidEmail = @"2222@cc.com".hd_isValidEmail;
    BOOL isValidEmail1 = @"2222@cc_.com".hd_isValidEmail;
    BOOL isValidEmail2 = @"2222@cc-.com".hd_isValidEmail;
    BOOL isValidEmail3 = @"2222@cc+.com".hd_isValidEmail;
    BOOL isValidEmail4 = @"2222cc_.com".hd_isValidEmail;
}

#pragma mark - override
- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self.navigationController pushViewController:HDTextViewViewController.new animated:true];
}
@end
