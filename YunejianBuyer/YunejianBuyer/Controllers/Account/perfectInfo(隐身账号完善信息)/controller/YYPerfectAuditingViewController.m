//
//  YYPerfectAuditingViewController.m
//  YunejianBuyer
//
//  Created by chuanjun sun on 2017/10/24.
//  Copyright © 2017年 Apple. All rights reserved.
//

#import "YYPerfectAuditingViewController.h"

@interface YYPerfectAuditingViewController ()<UIGestureRecognizerDelegate>

@end

@implementation YYPerfectAuditingViewController

#pragma mark - --------------生命周期--------------
- (void)viewDidLoad {
    [super viewDidLoad];
    [self SomePrepare];
}

#pragma mark - --------------SomePrepare--------------
- (void)SomePrepare
{
    [self PrepareData];
    [self PrepareUI];
}

- (void)PrepareData{

}

#pragma mark - --------------系统代理----------------------


#pragma mark - --------------自定义代理/block----------------------


#pragma mark - --------------自定义响应----------------------
- (void)cancelButtonClick{
    // 通知？ 发送后刷新UI
    NSArray *pushVCAry=[self.navigationController viewControllers];

    //下面的pushVCAry.count-3 是让我回到视图1中去
    UIViewController *popVC=[pushVCAry objectAtIndex:pushVCAry.count-3];

    [self.navigationController popToViewController:popVC animated:NO];

    [[NSNotificationCenter defaultCenter] postNotificationName:VisibleInfoPostIsOk object:nil userInfo:nil];
}

#pragma mark - --------------自定义方法----------------------


#pragma mark - --------------UI----------------------
// 创建子控件
- (void)PrepareUI{
    // 此界面应当禁止侧滑返回
    id traget = self.navigationController.interactivePopGestureRecognizer.delegate;
    UIPanGestureRecognizer * pan = [[UIPanGestureRecognizer alloc]initWithTarget:traget action:nil];
    [self.view addGestureRecognizer:pan];


    self.view.backgroundColor = _define_white_color;
    [self CreateNavView];

    UIImageView *tipImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"PerfectInfo_auditing"]];
    [self.view addSubview:tipImageView];
    [tipImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(160.5 + (kIPhoneX?24.0f:0));
        make.centerX.mas_equalTo(self.view.mas_centerX);
        make.width.mas_equalTo(98.5);
        make.height.mas_equalTo(86.5);
    }];

    UILabel *titleLabel = [[UILabel alloc] init];
    titleLabel.textAlignment = NSTextAlignmentCenter;
    titleLabel.text =NSLocalizedString(@"身份审核中", nil);
    titleLabel.textColor = _define_black_color;
    titleLabel.font = [UIFont systemFontOfSize:16];
    [self.view addSubview:titleLabel];

    [titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(tipImageView.mas_bottom).mas_offset(14);
        make.left.right.mas_equalTo(0);
        make.height.mas_equalTo(23);
    }];

    UILabel *detailLabel = [[UILabel alloc] init];
    detailLabel.textAlignment = NSTextAlignmentCenter;
    detailLabel.text =NSLocalizedString(@"买手店身份审核中，请耐心等待2-3个工作日", nil);
    detailLabel.textColor = [UIColor colorWithHex:@"AFAFAF"];
    detailLabel.font = [UIFont systemFontOfSize:13];
    [self.view addSubview:detailLabel];

    [detailLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(titleLabel.mas_bottom).offset(12);
        make.left.right.mas_equalTo(0);
        make.height.mas_equalTo(24);
    }];

    UIButton *cancelButton = [[UIButton alloc] init];
    cancelButton.backgroundColor = _define_black_color;
    cancelButton.titleLabel.font = [UIFont systemFontOfSize:16];

    [cancelButton setTitle:NSLocalizedString(@"返回", nil) forState:UIControlStateNormal];
    [cancelButton setTitleColor:_define_white_color forState:UIControlStateNormal];
    [cancelButton addTarget:self action:@selector(cancelButtonClick) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:cancelButton];

    [cancelButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(detailLabel.mas_bottom).offset(51);
        make.left.mas_equalTo(32.5);
        make.right.mas_equalTo(-32.5);
        make.height.mas_equalTo(44);
    }];
}

//创建导航栏
-(void)CreateNavView{

    UILabel *titleLabel = [[UILabel alloc] init];
    titleLabel.text = NSLocalizedString(@"买手身份验证",nil);
    titleLabel.font = [UIFont systemFontOfSize:17];
    titleLabel.textColor = _define_black_color;
    titleLabel.backgroundColor = _define_white_color;
    titleLabel.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:titleLabel];
    [titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.mas_topLayoutGuideBottom).with.offset(0);
        make.left.right.mas_equalTo(0);
        make.height.mas_equalTo(44);
    }];

    UIView *line = [[UIView alloc] init];
    line.backgroundColor = [UIColor colorWithHex:@"C9C9C9"];
    [self.view addSubview:line];
    [line mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.mas_equalTo(0);
        make.top.mas_equalTo(titleLabel.mas_bottom);
        make.height.mas_equalTo(0.5);
    }];

}
#pragma mark - --------------other----------------------

@end
