//
//  YYFeedbackViewController.m
//  Yunejian
//
//  Created by yyj on 15/7/21.
//  Copyright (c) 2015年 yyj. All rights reserved.
//

// c文件 —> 系统文件（c文件在前）

// 控制器
#import "YYFeedbackViewController.h"

// 自定义视图
#import "YYNavView.h"

// 接口
#import "YYUserApi.h"

// 分类
#import "UIView+UpdateAutoLayoutConstraints.h"

// 自定义类和三方类（ cocoapods类 > model > 工具类 > 其他）
#import "MLInputDodger.h"
#import "YYRspStatusAndMessage.h"
#import "regular.h"

@interface YYFeedbackViewController ()

@property (weak, nonatomic) IBOutlet UITextView *feedbackTextView;
@property (weak, nonatomic) IBOutlet UIView *containerView;
@property (weak, nonatomic) IBOutlet UIButton *saveBtn;
@property (weak, nonatomic) IBOutlet UIView *txtContaier;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *whiteViewHeightLayout;

@property (nonatomic, strong) YYNavView *navView;
@end

@implementation YYFeedbackViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self SomePrepare];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    // 进入埋点
    [MobClick beginLogPageView:kYYPageFeedback];
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    // 退出埋点
    [MobClick endLogPageView:kYYPageFeedback];
}

#pragma mark - SomePrepare
-(void)SomePrepare
{
    [self PrepareData];
    [self PrepareUI];
}

-(void)PrepareData{}

-(void)PrepareUI{
    self.navView = [[YYNavView alloc] initWithTitle:NSLocalizedString(@"建议反馈",nil) WithSuperView:self.view haveStatusView:YES];
    WeakSelf(ws);
    self.navView.goBackBlock = ^{
        [ws goBack];
    };
    
    _txtContaier.layer.cornerRadius = 2.5;
    _txtContaier.layer.borderColor = [UIColor colorWithHex:@"d3d3d3"].CGColor;
    _txtContaier.layer.borderWidth = 1;
    _txtContaier.layer.masksToBounds = YES;
    
    float viewTxtHeight = (SCREEN_WIDTH - 35)*640/680;
    [_txtContaier setConstraintConstant:viewTxtHeight forAttribute:NSLayoutAttributeHeight];
    _saveBtn.layer.cornerRadius = 2.5;
    _saveBtn.layer.masksToBounds = YES;

    _whiteViewHeightLayout.constant = kTabbarAndBottomSafeAreaHeight;
}

#pragma mark - SomeAction
- (void)goBack {
    [self cancelClicked:nil];
}

- (IBAction)cancelClicked:(id)sender{
    if (_cancelButtonClicked) {
        _cancelButtonClicked();
    }
}

- (IBAction)saveClicked:(id)sender{
    
   NSString *feedbackString = trimWhitespaceOfStr(_feedbackTextView.text);
    
    if (! feedbackString || [feedbackString length] == 0) {
        [YYToast showToastWithTitle:NSLocalizedString(@"请输入您的反馈内容",nil) andDuration:kAlertToastDuration];
        return;
    }
    
    [YYUserApi userFeedBack:feedbackString andBlock:^(YYRspStatusAndMessage *rspStatusAndMessage, NSError *error) {
        if (rspStatusAndMessage.status == YYReqStatusCode100) {
            [YYToast showToastWithTitle:NSLocalizedString(@"反馈成功!",nil) andDuration:kAlertToastDuration];
            if (_modifySuccess) {
                _modifySuccess();
            }
        }else{
            [YYToast showToastWithTitle:rspStatusAndMessage.message andDuration:kAlertToastDuration];
        }
    }];
    
}
-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    [regular dismissKeyborad];
}

#pragma mark - Other

@end
