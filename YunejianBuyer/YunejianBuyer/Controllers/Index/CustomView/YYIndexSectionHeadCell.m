//
//  YYIndexSectionHeadCell.m
//  YunejianBuyer
//
//  Created by yyj on 2017/8/9.
//  Copyright © 2017年 Apple. All rights reserved.
//

#import "YYIndexSectionHeadCell.h"

#import "UIImage+Tint.h"

@interface YYIndexSectionHeadCell ()

@property (nonatomic,strong) UIView *topLine;

@property (nonatomic,strong) UILabel *titleLabel;

@property (nonatomic,strong) UIView *intervalView;

@property (nonatomic,strong) UIButton *moreBtn;

@end

@implementation YYIndexSectionHeadCell

#pragma mark - --------------生命周期--------------
//-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
//    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
//    if(self){
//        [self SomePrepare];
//        [self UIConfig];
//    }
//    return self;
//}

-(instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
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
- (void)PrepareUI{
    self.backgroundColor = _define_white_color;
}

#pragma mark - --------------UIConfig----------------------
-(void)UIConfig{
    _topLine = [UIView getCustomViewWithColor:[UIColor colorWithHex:@"EFEFEF"]];
    [self addSubview:_topLine];
    [_topLine mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.top.mas_equalTo(0);
        make.height.mas_equalTo(1);
    }];

    UIView *backView = [UIView getCustomViewWithColor:_define_white_color];
    [self addSubview:backView];
    [backView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.mas_equalTo(0);
        make.bottom.mas_equalTo(0);
        make.top.mas_equalTo(_topLine.mas_bottom).with.offset(0);
    }];
    backView.backgroundColor = _define_white_color;

    _intervalView = [UIView getCustomViewWithColor:[UIColor colorWithHex:@"f8f8f8"]];
    [backView addSubview:_intervalView];
    [_intervalView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.top.mas_equalTo(0);
        make.height.mas_equalTo(10);
    }];

    _titleLabel = [UILabel getLabelWithAlignment:0 WithTitle:nil WithFont:14.0f WithTextColor:[UIColor colorWithHex:@"646464"] WithSpacing:0];
    [backView addSubview:_titleLabel];
    [_titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(17);
        make.right.mas_equalTo(-17);
        make.bottom.mas_equalTo(0);
        make.top.mas_equalTo(_intervalView.mas_bottom).with.offset(0);
    }];

    _moreBtn = [UIButton getCustomBtn];
    [backView addSubview:_moreBtn];
    [_moreBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(-17);
        make.centerY.mas_equalTo(_titleLabel);
        make.height.mas_equalTo(30);
    }];
    [_moreBtn addTarget:self action:@selector(moreAction) forControlEvents:UIControlEventTouchUpInside];

    UIImageView *moreImg = [UIImageView getCustomImg];
    [_moreBtn addSubview:moreImg];
    [moreImg mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(0);
        make.centerY.mas_equalTo(0);
        make.width.mas_equalTo(5);
        make.height.mas_equalTo(10);
    }];
    moreImg.image = [[UIImage imageNamed:@"right_arrow_big_icon"] imageWithTintColor:[UIColor colorWithHex:@"919191"]];
    moreImg.contentMode = UIViewContentModeScaleToFill;

    UILabel *moreTitleLabel = [UILabel getLabelWithAlignment:2 WithTitle:NSLocalizedString(@"查看更多",nil) WithFont:11.0f WithTextColor:[UIColor colorWithHex:@"919191"] WithSpacing:0];
    [_moreBtn addSubview:moreTitleLabel];
    [moreTitleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(moreImg.mas_left).with.offset(-3);
        make.top.bottom.mas_equalTo(0);
        make.left.mas_equalTo(0);
    }];

}

//#pragma mark - --------------请求数据----------------------
#pragma mark - --------------自定义响应----------------------
-(void)moreAction{
    if(_indexSectionHeadBlock){
        _indexSectionHeadBlock(@"more");
    }
}
#pragma mark - --------------自定义方法----------------------
-(void)updateUI{
    if(_sectionHeadType == EIndexSectionHeadRecommendationBrand){
        _titleLabel.text = NSLocalizedString(@"推荐品牌",nil);
    }else if(_sectionHeadType == EIndexSectionHeadLatestSeries){
        _titleLabel.text = NSLocalizedString(@"热门系列",nil);
    }else if (_sectionHeadType == EIndexSectionHeadOrdering){
        _titleLabel.text = NSLocalizedString(@"YCO 订货会",nil);
    }else if (_sectionHeadType == EIndexSectionHeadOrder){
        _titleLabel.text = NSLocalizedString(@"我的订单",nil);
    }else if (_sectionHeadType == EIndexSectionHeadHot){
        _titleLabel.text = NSLocalizedString(@"热门品牌",nil);
    }else{
        _titleLabel.text = @"";
    }
    
    if(_titleIsCenter){
        [_titleLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(17);
            make.right.mas_equalTo(-17);
            make.bottom.mas_equalTo(0);
            make.top.mas_equalTo(_intervalView.mas_bottom).with.offset(0);
        }];
    }else{
        [_titleLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(17);
            make.right.mas_equalTo(-17);
            make.bottom.mas_equalTo(0);
        }];
    }

    [_intervalView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(_topLineIsHide?0:10);
    }];
    _moreBtn.hidden = !_moreBtnIsShow;
}

#pragma mark - --------------other----------------------
- (void)awakeFromNib {
    [super awakeFromNib];
}


@end
