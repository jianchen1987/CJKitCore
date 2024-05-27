//
//  HDTextViewViewController.m
//  HDKitCore_Example
//
//  Created by VanJay on 2020/6/6.
//  Copyright © 2020 wangwanjie. All rights reserved.
//

#import "HDTextViewViewController.h"
#import <HDKitCore/HDKitCore.h>

@interface HDTextViewViewController ()

@end

@implementation HDTextViewViewController

- (void)viewDidLoad {
    self.hd_enableKeyboardRespond = true;
    [super viewDidLoad];

    self.view.backgroundColor = UIColor.whiteColor;

    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 400, self.view.width, self.view.height - 400)];
    view.backgroundColor = UIColor.redColor;
    [self.view addSubview:view];

    self.hd_needMoveView = view;

    UITextView *textField = [UITextView new];
    textField.layer.borderWidth = 1;
    textField.layer.borderColor = UIColor.redColor.CGColor;
    textField.layer.cornerRadius = 5;
    textField.frame = CGRectMake(10, CGRectGetHeight(view.frame) - 80, 100, 50);
    [view addSubview:textField];
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self.view.window endEditing:true];
}
@end
