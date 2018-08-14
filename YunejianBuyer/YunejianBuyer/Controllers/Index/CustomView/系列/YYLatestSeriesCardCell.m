//
//  YYLatestSeriesCardCell.m
//  YunejianBuyer
//
//  Created by yyj on 2017/8/8.
//  Copyright © 2017年 Apple. All rights reserved.
//

#import "YYLatestSeriesCardCell.h"

#import "SCGIFButtonView.h"
#import "SCGIFImageView.h"

#import "YYLatestSeriesModel.h"

@interface YYLatestSeriesCardCell()

@property (nonatomic,strong) UIButton *cardBackView;
@property (nonatomic,strong) SCGIFImageView *coverImg;
@property (nonatomic,strong) UILabel *seriesNameLabel;
@property (nonatomic,strong) UILabel *unitsLabel;

@property (nonatomic,strong) SCGIFButtonView *headIcon;
@property (nonatomic,strong) UILabel *brandNameLabel;
@property (nonatomic,strong) UILabel *designerNameLabel;

@property(nonatomic,copy) void (^latestSeriesCardBlock)(NSString *type,YYLatestSeriesModel *latestSeriesModel);

@end

@implementation YYLatestSeriesCardCell

#pragma mark - --------------生命周期--------------
-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier WithBlock:(void(^)(NSString *type,YYLatestSeriesModel *latestSeriesModel))block{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if(self){
        _latestSeriesCardBlock = block;
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
    self.contentView.backgroundColor = _define_white_color;
}

#pragma mark - --------------UIConfig----------------------
-(void)UIConfig{
    _cardBackView = [UIButton getCustomBtn];
    [self.contentView addSubview:_cardBackView];
    [_cardBackView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(17);
        make.right.mas_equalTo(-17);
        make.top.mas_equalTo(0);
        make.bottom.mas_equalTo(-10);
    }];
    _cardBackView.backgroundColor = _define_white_color;
    [_cardBackView addTarget:self action:@selector(cardClick) forControlEvents:UIControlEventTouchUpInside];
    _cardBackView.layer.masksToBounds = YES;
    _cardBackView.layer.borderColor = [[UIColor colorWithHex:@"EFEFEF"] CGColor];
    _cardBackView.layer.borderWidth = 1;
    _cardBackView.layer.cornerRadius = 3.0f;

    _coverImg = [[SCGIFImageView alloc] init];
    [_cardBackView addSubview:_coverImg];
    [_coverImg mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.top.mas_equalTo(16);
        make.right.mas_equalTo(-16);
        make.height.mas_equalTo(194);
    }];
    _coverImg.contentMode = UIViewContentModeScaleAspectFill;
    _coverImg.clipsToBounds = YES;

    UIView *lineView = [UIView getCustomViewWithColor:[UIColor colorWithHex:@"EFEFEF"]];
    [_cardBackView addSubview:lineView];
    [lineView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.mas_equalTo(-54);
        make.left.right.mas_equalTo(_coverImg);
        make.height.mas_equalTo(1);
    }];

    _seriesNameLabel = [UILabel getLabelWithAlignment:0 WithTitle:nil WithFont:13.0f WithTextColor:nil WithSpacing:0];
    [_cardBackView addSubview:_seriesNameLabel];
    [_seriesNameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(_coverImg);
        make.right.mas_equalTo(-100);
        make.top.mas_equalTo(_coverImg.mas_bottom).with.offset(0);
        make.bottom.mas_equalTo(lineView.mas_top).with.offset(0);
    }];
    _seriesNameLabel.font = [UIFont boldSystemFontOfSize:13.0f];
    _seriesNameLabel.numberOfLines = 2;

    _unitsLabel = [UILabel getLabelWithAlignment:2 WithTitle:nil WithFont:13.0f WithTextColor:nil WithSpacing:0];
    [_cardBackView addSubview:_unitsLabel];
    [_unitsLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(_seriesNameLabel.mas_right).with.offset(0);
        make.right.mas_equalTo(_coverImg);
        make.top.mas_equalTo(_coverImg.mas_bottom).with.offset(0);
        make.bottom.mas_equalTo(lineView.mas_top).with.offset(0);
    }];

    UIButton *downView = [UIButton getCustomBtn];
    [_cardBackView addSubview:downView];
    [downView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(lineView.mas_bottom).with.offset(0);
        make.bottom.left.right.mas_equalTo(0);
    }];
    [downView addTarget:self action:@selector(clickBrand) forControlEvents:UIControlEventTouchUpInside];

    _headIcon = [[SCGIFButtonView alloc] init];
    [downView addSubview:_headIcon];
    [_headIcon mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(_coverImg);
        make.top.mas_equalTo(7);
        make.width.height.mas_equalTo(40);
    }];
    [_headIcon setAdjustsImageWhenHighlighted:NO];
    _headIcon.layer.masksToBounds = YES;
    _headIcon.layer.borderColor = [[UIColor colorWithHex:kDefaultImageColor] CGColor];
    _headIcon.layer.borderWidth = 1;
    _headIcon.layer.cornerRadius = 20.0f;
    _headIcon.imageView.contentMode = UIViewContentModeScaleAspectFit;
    _headIcon.clipsToBounds = YES;
    _headIcon.userInteractionEnabled = NO;

    _brandNameLabel = [UILabel getLabelWithAlignment:0 WithTitle:nil WithFont:11.0f WithTextColor:nil WithSpacing:0];
    [downView addSubview:_brandNameLabel];
    [_brandNameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(_headIcon.mas_right).with.offset(6);
        make.bottom.mas_equalTo(_headIcon.mas_centerY).with.offset(-2);
        make.right.mas_equalTo(-17);
    }];

    _designerNameLabel = [UILabel getLabelWithAlignment:0 WithTitle:nil WithFont:11.0f WithTextColor:[UIColor colorWithHex:@"919191"] WithSpacing:0];
    [downView addSubview:_designerNameLabel];
    [_designerNameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(_brandNameLabel);
        make.top.mas_equalTo(_headIcon.mas_centerY).with.offset(2);
        make.right.mas_equalTo(-17);
    }];
}

//#pragma mark - --------------请求数据----------------------
//-(void)RequestData{}

#pragma mark - --------------自定义响应----------------------
-(void)cardClick{
    if(_latestSeriesCardBlock){
        _latestSeriesCardBlock(@"card_click",_latestSeriesModel);
    }
}
-(void)clickBrand{
    if(_latestSeriesCardBlock){
        _latestSeriesCardBlock(@"brand_click",_latestSeriesModel);
    }
}
#pragma mark - --------------自定义方法----------------------
-(void)setLatestSeriesModel:(YYLatestSeriesModel *)latestSeriesModel{
    _latestSeriesModel = latestSeriesModel;

    sd_downloadWebImageWithRelativePath(YES, _latestSeriesModel.albumImg, _coverImg, kStyleCover, UIViewContentModeScaleAspectFill);
    _seriesNameLabel.text = _latestSeriesModel.seriesName;
    _unitsLabel.text = [[NSString alloc] initWithFormat:NSLocalizedString(@"%@款",nil),[[NSString alloc] initWithFormat:@"%ld",[_latestSeriesModel.styleAmount integerValue]]];

    sd_downloadWebImageWithRelativePath(NO, _latestSeriesModel.logoPath, _headIcon, kLogoCover, 0);
    _brandNameLabel.text = _latestSeriesModel.brandName;
    _designerNameLabel.text = _latestSeriesModel.designerName;
}

#pragma mark - --------------other----------------------
- (void)awakeFromNib {
    [super awakeFromNib];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}

@end
