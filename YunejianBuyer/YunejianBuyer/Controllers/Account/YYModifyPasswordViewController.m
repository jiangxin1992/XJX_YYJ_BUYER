//
//  YYModifyPasswordViewController.m
//  Yunejian
//
//  Created by yyj on 15/7/14.
//  Copyright (c) 2015年 yyj. All rights reserved.
//

// c文件 —> 系统文件（c文件在前）

// 控制器
#import "YYModifyPasswordViewController.h"

// 自定义视图
#import "YYNavView.h"

// 接口
#import "YYUserApi.h"

// 分类

// 自定义类和三方类（ cocoapods类 > model > 工具类 > 其他）
#import "YYRspStatusAndMessage.h"

@interface YYModifyPasswordViewController ()<UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UITextField *oldPasswordField;
@property (weak, nonatomic) IBOutlet UITextField *nowPasswordField;
@property (weak, nonatomic) IBOutlet UITextField *confirmPasswordField;
@property (weak, nonatomic) IBOutlet UIView *containerView;
@property (weak, nonatomic) IBOutlet UIButton *saveBtn;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *oldPwdWidthLayout;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *newstPwdWidthLayout1;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *confirmPwdWidthLayout;

@property (nonatomic, strong) YYNavView *navView;

@end

@implementation YYModifyPasswordViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    if([LanguageManager isEnglishLanguage]){
        _oldPwdWidthLayout.constant = 95;
        _newstPwdWidthLayout1.constant = 95;
        _confirmPwdWidthLayout.constant = 95;
    }else{
        _oldPwdWidthLayout.constant = 65;
        _newstPwdWidthLayout1.constant = 65;
        _confirmPwdWidthLayout.constant = 65;
    }
    
    // Do any additional setup after loading the view.
    self.navView = [[YYNavView alloc] initWithTitle:NSLocalizedString(@"密码",nil) WithSuperView:self.view haveStatusView:YES];
    WeakSelf(ws);
    self.navView.goBackBlock = ^{
        [ws goBack];
    };
    
    _saveBtn.layer.cornerRadius = 2.5;
    _saveBtn.layer.masksToBounds = YES;
    
    _oldPasswordField.delegate = self;
    _nowPasswordField.delegate = self;
    _confirmPasswordField.delegate = self;
    
    //popWindowAddBgView(self.view);
    
    [_oldPasswordField becomeFirstResponder];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    // 进入埋点
    [MobClick beginLogPageView:kYYPageModifyPassword];
}

#pragma mark - 自定义响应

- (void)goBack {
    [self cancelClicked:nil];
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    // 退出埋点
    [MobClick endLogPageView:kYYPageModifyPassword];
}

- (IBAction)cancelClicked:(id)sender{
    if (_cancelButtonClicked) {
        _cancelButtonClicked();
    }
}

- (IBAction)saveClicked:(id)sender{
    NSString *old = trimWhitespaceOfStr(_oldPasswordField.text);
    NSString *now = trimWhitespaceOfStr(_nowPasswordField.text);
    NSString *confirm = trimWhitespaceOfStr(_confirmPasswordField.text);
    
    if (! old || [old length] == 0) {
        
        [YYToast showToastWithTitle:NSLocalizedString(@"请输入原来的密码",nil) andDuration:kAlertToastDuration];
        return;
    }
    
    
    if (! now || [now length] == 0) {
        [YYToast showToastWithTitle:NSLocalizedString(@"请输入新密码！",nil) andDuration:kAlertToastDuration];
        return;
    }
    
    if (! confirm || [confirm length] == 0) {
        [YYToast showToastWithTitle:NSLocalizedString(@"请输入确认密码！",nil) andDuration:kAlertToastDuration];
        return;
    }
    
    if (![now isEqualToString:confirm]) {
        [YYToast showToastWithTitle:NSLocalizedString(@"新密码和确认密码不一致！",nil) andDuration:kAlertToastDuration];
        return;
    }
    
    [YYUserApi passwdUpdateWithOldPassword:md5(old) nowPassword:md5(now) andBlock:^(YYRspStatusAndMessage *rspStatusAndMessage, NSError *error) {
        if (rspStatusAndMessage.status == YYReqStatusCode100) {
            [YYToast showToastWithTitle:NSLocalizedString(@"密码修改成功！",nil) andDuration:kAlertToastDuration];
            if (_modifySuccess) {
                _modifySuccess();
            }
        }else{
           [YYToast showToastWithTitle:rspStatusAndMessage.message andDuration:kAlertToastDuration];
        }
    }];
    
}


#pragma mark - Other

@end
