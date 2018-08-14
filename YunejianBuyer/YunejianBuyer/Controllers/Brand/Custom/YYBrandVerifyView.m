//
//  YYBrandVerifyView.m
//  YunejianBuyer
//
//  Created by yyj on 2017/10/26.
//  Copyright © 2017年 Apple. All rights reserved.
//

#import "YYBrandVerifyView.h"

#import "YYUser.h"

@interface YYBrandVerifyView()

@property (nonatomic,strong) UIView *superView;

@property (nonatomic,strong) UILabel *titleLabel;
@property (nonatomic,strong) UILabel *desLabel;
@property (nonatomic,strong) UIButton *verifyButton;

@end

@implementation YYBrandVerifyView

#pragma mark - --------------生命周期--------------
-(instancetype)initWithSuperView:(UIView *)superView{
    self = [super init];
    if(self){
        _superView = superView;
        [self SomePrepare];
        [self UIConfig];
    }
    return self;
}

#pragma mark - --------------SomePrepare--------------
- (void)SomePrepare
{
    [self PrepareData];
    [self PrepareUI];
}
- (void)PrepareData{}
- (void)PrepareUI{
    [_superView addSubview:self];
    [self mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(_superView);
    }];
}

#pragma mark - --------------UIConfig----------------------
-(void)UIConfig{

    UIButton *backView = [UIButton getCustomBtn];
    [self addSubview:backView];
    [backView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(self);
    }];
    backView.backgroundColor = [_define_black_color colorWithAlphaComponent:0.3];
    [backView addTarget:self action:@selector(backClick) forControlEvents:UIControlEventTouchUpInside];

    UIView *blackCardView = [UIView getCustomViewWithColor:_define_white_color];
    [backView addSubview:blackCardView];
    [blackCardView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(25);
        make.right.mas_equalTo(-25);
        make.centerY.mas_equalTo(backView);
    }];
    blackCardView.layer.masksToBounds = YES;
    blackCardView.layer.borderColor = [_define_black_color CGColor];
    blackCardView.layer.borderWidth = 4.0f;
    blackCardView.userInteractionEnabled = YES;
    [blackCardView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(NULLACTION)]];

    _titleLabel = [UILabel getLabelWithAlignment:1 WithTitle:nil WithFont:15.0f WithTextColor:nil WithSpacing:0];
    [blackCardView addSubview:_titleLabel];
    [_titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(17);
        make.right.mas_equalTo(-17);
        make.top.mas_equalTo(38);
    }];

    _desLabel = [UILabel getLabelWithAlignment:1 WithTitle:nil WithFont:13.0f WithTextColor:[UIColor colorWithHex:@"919191"] WithSpacing:0];
    [blackCardView addSubview:_desLabel];
    [_desLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(17);
        make.right.mas_equalTo(-17);
        make.top.mas_equalTo(_titleLabel.mas_bottom).with.offset(9);
        make.bottom.mas_equalTo(-99);
    }];

    _verifyButton = [UIButton getCustomTitleBtnWithAlignment:0 WithFont:14.0f WithSpacing:0 WithNormalTitle:nil WithNormalColor:_define_white_color WithSelectedTitle:nil WithSelectedColor:nil];
    [blackCardView addSubview:_verifyButton];
    [_verifyButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(42);
        make.right.mas_equalTo(-42);
        make.bottom.mas_equalTo(-37);
        make.height.mas_equalTo(38);
    }];
    _verifyButton.backgroundColor = _define_black_color;
    [_verifyButton addTarget:self action:@selector(verifyAction) forControlEvents:UIControlEventTouchUpInside];

}

//#pragma mark - --------------请求数据----------------------
//-(void)RequestData{}

#pragma mark - --------------自定义响应----------------------
-(void)updateUI{
    YYUser *user = [YYUser currentUser];
    NSInteger checkStatus = [user.checkStatus integerValue];
    if(checkStatus == 1 || checkStatus == 4){
        //1:待提交文件 4:审核拒绝
        _titleLabel.text = NSLocalizedString(@"尚未完善资料", nil);
        _desLabel.text = NSLocalizedString(@"请您完善资料，以便获得正常的使用权限与体验", nil);
        _verifyButton.hidden = NO;
        [_verifyButton setTitle:NSLocalizedString(@"点击完善", nil) forState:UIControlStateNormal];
        [_desLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(17);
            make.right.mas_equalTo(-17);
            make.top.mas_equalTo(_titleLabel.mas_bottom).with.offset(9);
            make.bottom.mas_equalTo(-99);
        }];
    }else if(checkStatus == 2){
        //2:待审核
        _titleLabel.text = NSLocalizedString(@"身份审核中", nil);
        _desLabel.text = NSLocalizedString(@"审核通过后，即可查看更多品牌信息", nil);
        _verifyButton.hidden = YES;
        [_desLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(17);
            make.right.mas_equalTo(-17);
            make.top.mas_equalTo(_titleLabel.mas_bottom).with.offset(9);
            make.bottom.mas_equalTo(-38);
        }];
    }
}
-(void)backClick{
    //返回品牌页面
    if(_verifyBlock){
        _verifyBlock(@"return_homepage");
    }
}
-(void)verifyAction{
    if(_verifyBlock){
        _verifyBlock(@"fillInformation");
    }
}

#pragma mark - --------------自定义方法----------------------
-(void)NULLACTION{}

#pragma mark - --------------other----------------------

@end

