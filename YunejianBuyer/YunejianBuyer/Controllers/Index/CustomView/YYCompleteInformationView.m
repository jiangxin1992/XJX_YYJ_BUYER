//
//  YYCompleteInformationView.m
//  YunejianBuyer
//
//  Created by yyj on 2017/10/23.
//  Copyright © 2017年 Apple. All rights reserved.
//

#import "YYCompleteInformationView.h"

#import "YYUser.h"

@interface YYCompleteInformationView ()

@property (nonatomic,copy) void (^block)(NSString *type);

//未审核或审核被拒
@property (nonatomic,copy) UIImageView *infoImageView;
@property (nonatomic,copy) UILabel *infoLabel;
@property (nonatomic,copy) UIButton *infoBtn;

//审核中
@property (nonatomic,copy) UIImageView *pendingImageView;
@property (nonatomic,copy) UILabel *pendingTitleLabel;
@property (nonatomic,copy) UILabel *pendingInfoLabel;

@end

@implementation YYCompleteInformationView

-(instancetype)initWithBlock:(void(^)(NSString *type))block{
    self = [super init];
    if(self){
        _block = block;
        [self SomePrepare];
        [self UIConfig];
        [self updateUI];
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
- (void)PrepareUI{}

#pragma mark - --------------UIConfig----------------------
-(void)UIConfig{
    [self CreateInfoView];
    [self CreatePendingView];
}
-(void)CreateInfoView{
    _infoImageView = [UIImageView getImgWithImageStr:@"account_verify"];
    [self addSubview:_infoImageView];
    [_infoImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(43);
        make.right.mas_equalTo(-43);
        make.top.mas_equalTo(0);
        make.height.mas_equalTo(132);
    }];
    _infoImageView.contentMode = UIViewContentModeScaleAspectFit;

    _infoLabel = [UILabel getLabelWithAlignment:1 WithTitle:NSLocalizedString(@"请您完善资料，以便获得正常的使用权限与体验", nil) WithFont:13.0f WithTextColor:[UIColor colorWithHex:@"afafaf"] WithSpacing:0];
    [self addSubview:_infoLabel];
    [_infoLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(17);
        make.right.mas_equalTo(-17);
        make.top.mas_equalTo(_infoImageView.mas_bottom).with.offset(12);
    }];

    _infoBtn = [UIButton getCustomTitleBtnWithAlignment:0 WithFont:16.0f WithSpacing:0 WithNormalTitle:NSLocalizedString(@"完善资料", nil) WithNormalColor:_define_white_color WithSelectedTitle:nil WithSelectedColor:nil];
    [self addSubview:_infoBtn];
    [_infoBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(_infoLabel.mas_bottom).with.offset(40);
        make.left.mas_equalTo(32);
        make.right.mas_equalTo(-32);
        make.height.mas_equalTo(44);
        make.bottom.mas_equalTo(0);
    }];
    _infoBtn.backgroundColor = _define_black_color;
    [_infoBtn addTarget:self action:@selector(fillInformationAction) forControlEvents:UIControlEventTouchUpInside];
}
-(void)CreatePendingView{
    _pendingImageView = [UIImageView getImgWithImageStr:@"account_verify_pending"];
    [self addSubview:_pendingImageView];
    [_pendingImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(self);
        make.top.mas_equalTo(0);
        make.width.mas_equalTo(99);
        make.height.mas_equalTo(87);
    }];
    _pendingImageView.contentMode = UIViewContentModeScaleAspectFit;

    _pendingTitleLabel = [UILabel getLabelWithAlignment:1 WithTitle:NSLocalizedString(@"身份审核中",nil) WithFont:16.0f WithTextColor:_define_black_color WithSpacing:0];
    [self addSubview:_pendingTitleLabel];
    [_pendingTitleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(17);
        make.right.mas_equalTo(-17);
        make.top.mas_equalTo(_pendingImageView.mas_bottom).with.offset(14);
    }];

    _pendingInfoLabel = [UILabel getLabelWithAlignment:1 WithTitle:NSLocalizedString(@"买手店身份审核中，请耐心等待2-3个工作日", nil) WithFont:13.0f WithTextColor:[UIColor colorWithHex:@"afafaf"] WithSpacing:0];
    [self addSubview:_pendingInfoLabel];
    [_pendingInfoLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(17);
        make.right.mas_equalTo(-17);
        make.top.mas_equalTo(_pendingTitleLabel.mas_bottom).with.offset(6);
    }];
}
//#pragma mark - --------------请求数据----------------------

#pragma mark - --------------自定义响应----------------------
-(void)fillInformationAction{
    if(_block){
        _block(@"fillInformation");
    }
}

#pragma mark - --------------自定义方法----------------------
//根据状态更新
-(void)updateUI{
    //1:待提交文件 2:待审核 3:审核通过 4:审核拒绝 5:停止
    if([[YYUser currentUser] hasPermissionsToVisit]){
        [self hideAll];
    }else{
        YYUser *user = [YYUser currentUser];
        NSInteger checkStatus = [user.checkStatus integerValue];
        if(checkStatus == 1 || checkStatus == 4){
            [self hidePendingView];
        }else if(checkStatus == 2){
            [self hideInfoView];
        }else{
            [self hideAll];
        }
    }
}
-(void)hidePendingView{
    _infoImageView.hidden = NO;
    _infoLabel.hidden = NO;
    _infoBtn.hidden = NO;
    _pendingImageView.hidden = YES;
    _pendingTitleLabel.hidden = YES;
    _pendingInfoLabel.hidden = YES;
}
-(void)hideInfoView{
    _infoImageView.hidden = YES;
    _infoLabel.hidden = YES;
    _infoBtn.hidden = YES;
    _pendingImageView.hidden = NO;
    _pendingTitleLabel.hidden = NO;
    _pendingInfoLabel.hidden = NO;
}
-(void)hideAll{
    _infoImageView.hidden = YES;
    _infoLabel.hidden = YES;
    _infoBtn.hidden = YES;
    _pendingImageView.hidden = YES;
    _pendingTitleLabel.hidden = YES;
    _pendingInfoLabel.hidden = YES;
}

@end
