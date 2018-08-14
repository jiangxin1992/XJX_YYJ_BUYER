//
//  YYAccountUserInfoCell.m
//  YunejianBuyer
//
//  Created by yyj on 2017/8/15.
//  Copyright © 2017年 Apple. All rights reserved.
//

#import "YYAccountUserInfoCell.h"

#import "SCGIFButtonView.h"

#import "YYUserInfo.h"
#import "YYUser.h"

@interface YYAccountUserInfoCell()

@property (nonatomic,strong) SCGIFButtonView *headView;
@property (nonatomic,strong) UILabel *cellTitleLabel;
@property (nonatomic,strong) UILabel *cellTipLabel;

@end

@implementation YYAccountUserInfoCell

#pragma mark - --------------生命周期--------------
-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if(self){
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
- (void)PrepareUI{}

#pragma mark - --------------UIConfig----------------------
-(void)UIConfig{

    WeakSelf(ws);

    UIView *downLine = [UIView getCustomViewWithColor:[UIColor colorWithHex:@"EFEFEF"]];
    [self.contentView addSubview:downLine];
    [downLine mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.bottom.mas_equalTo(0);
        make.height.mas_equalTo(1);
    }];

    UIImageView *rightArrow = [UIImageView getImgWithImageStr:@"right_icon"];
    [self.contentView addSubview:rightArrow];
    [rightArrow mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(-17);
        make.centerY.mas_equalTo(self.contentView);
        make.width.mas_equalTo(8);
        make.height.mas_equalTo(15);
    }];
    rightArrow.contentMode = UIViewContentModeScaleAspectFit;

    _cellTitleLabel = [UILabel getLabelWithAlignment:0 WithTitle:nil WithFont:14.0f WithTextColor:nil WithSpacing:0];
    [self.contentView addSubview:_cellTitleLabel];
    [_cellTitleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(17);
        make.top.mas_equalTo(0);
        make.bottom.mas_equalTo(downLine.mas_top).with.offset(0);
        make.width.mas_equalTo(150);
    }];

    _cellTipLabel = [UILabel getLabelWithAlignment:2 WithTitle:nil WithFont:14.0f WithTextColor:nil WithSpacing:0];
    [self.contentView addSubview:_cellTipLabel];
    [_cellTipLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(-34);
        make.top.mas_equalTo(0);
        make.bottom.mas_equalTo(downLine.mas_top).with.offset(0);
        make.left.mas_equalTo(ws.cellTitleLabel).with.offset(10);
    }];


    _headView = [[SCGIFButtonView alloc] init];
    [self.contentView addSubview:_headView];
    [_headView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(-36);
        make.centerY.mas_equalTo(self.contentView);
        make.width.height.mas_equalTo(50);
    }];
    _headView.userInteractionEnabled = NO;
    _headView.layer.masksToBounds = YES;
    _headView.layer.cornerRadius = 25;
    _headView.layer.borderColor = [[UIColor colorWithHex:@"EFEFEF"] CGColor];
    _headView.layer.borderWidth = 1.0f;
    _headView.imageView.contentMode = UIViewContentModeScaleAspectFit;
}

//#pragma mark - --------------请求数据----------------------
//#pragma mark - --------------自定义响应----------------------
#pragma mark - --------------自定义方法----------------------
-(void)UpdateUI{
    if(_UserInfoType == AccountUserInfoTypeUsername){
        _cellTipLabel.hidden = NO;
        _headView.hidden = YES;

        _cellTitleLabel.text = NSLocalizedString(@"用户名",nil);
        _cellTipLabel.text = _userInfo.username;

    }else if(_UserInfoType == AccountUserInfoTypePhone){
        _cellTipLabel.hidden = NO;
        _headView.hidden = YES;

        _cellTitleLabel.text = NSLocalizedString(@"电话",nil);
        _cellTipLabel.text = _userInfo.phone;

    }else if(_UserInfoType == AccountUserInfoTypeUserHead){
        _cellTipLabel.hidden = YES;
        _headView.hidden = NO;

        _cellTitleLabel.text = NSLocalizedString(@"头像",nil);
        _cellTipLabel.text = @"";

        YYUser *user = [YYUser currentUser];
        sd_downloadWebImageWithRelativePath(NO, user.logo, _headView, kLogoCover,1);
    }
}

#pragma mark - --------------other----------------------
- (void)awakeFromNib {
    [super awakeFromNib];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}

@end
