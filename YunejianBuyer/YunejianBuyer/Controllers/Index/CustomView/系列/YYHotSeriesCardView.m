//
//  YYHotSeriesCardView.m
//  YunejianBuyer
//
//  Created by yyj on 2017/9/22.
//  Copyright © 2017年 Apple. All rights reserved.
//

#import "YYHotSeriesCardView.h"

#import "SCGIFButtonView.h"
#import "SCGIFImageView.h"

#import "YYLatestSeriesModel.h"

@interface YYHotSeriesCardView()

@property (nonatomic,strong) UIButton *brandClickButton;

@property (nonatomic,strong) SCGIFImageView *headIcon;
@property (nonatomic,strong) UILabel *brandNameLabel;
@property (nonatomic,strong) UILabel *designerNameLabel;

@property (nonatomic,strong) SCGIFButtonView *cardClickButton;

@end

@implementation YYHotSeriesCardView
#pragma mark - 生命周期
-(instancetype)init{
    self = [super init];
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

    _brandClickButton = [UIButton getCustomBtn];
    [self addSubview:_brandClickButton];
    [_brandClickButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.top.mas_equalTo(0);
        make.height.mas_equalTo(55);
    }];
    [_brandClickButton addTarget:self action:@selector(brandClick) forControlEvents:UIControlEventTouchUpInside];

    _headIcon = [[SCGIFImageView alloc] init];
    [_brandClickButton addSubview:_headIcon];
    [_headIcon mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(5);
        make.centerY.mas_equalTo(0);
        make.width.height.mas_equalTo(34);
    }];
    _headIcon.layer.masksToBounds = YES;
    _headIcon.layer.borderColor = [[UIColor colorWithHex:kDefaultImageColor] CGColor];
    _headIcon.layer.borderWidth = 1;
    _headIcon.layer.cornerRadius = 17.0f;
    _headIcon.contentMode = UIViewContentModeScaleAspectFit;
    _headIcon.clipsToBounds = YES;

    _designerNameLabel = [UILabel getLabelWithAlignment:0 WithTitle:nil WithFont:11.0f WithTextColor:[UIColor colorWithHex:@"919191"] WithSpacing:0];
    [_brandClickButton addSubview:_designerNameLabel];
    [_designerNameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(_headIcon.mas_right).with.offset(10);
        make.top.mas_equalTo(_brandClickButton.mas_centerY).with.offset(0);
        make.right.mas_equalTo(-8);
    }];

    _brandNameLabel = [UILabel getLabelWithAlignment:0 WithTitle:nil WithFont:12.0f WithTextColor:nil WithSpacing:0];
    [_brandClickButton addSubview:_brandNameLabel];
    [_brandNameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(_headIcon.mas_right).with.offset(10);
        make.bottom.mas_equalTo(_brandClickButton.mas_centerY).with.offset(0);
        make.right.mas_equalTo(-8);
    }];

    _cardClickButton = [[SCGIFButtonView alloc] init];
    [self addSubview:_cardClickButton];
    [_cardClickButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.mas_equalTo(0);
        make.top.mas_equalTo(_brandClickButton.mas_bottom).with.offset(0);
        make.bottom.mas_equalTo(0);
    }];
    [_cardClickButton addTarget:self action:@selector(cardClick) forControlEvents:UIControlEventTouchUpInside];
    _cardClickButton.imageView.contentMode = UIViewContentModeScaleAspectFill;
    _cardClickButton.clipsToBounds = YES;
}

//#pragma mark - --------------请求数据----------------------
//-(void)RequestData{}

#pragma mark - --------------自定义响应----------------------
-(void)brandClick{
    if(_seriesCardBlock){
        _seriesCardBlock(@"brand_click",_seriesModel);
    }
}
-(void)cardClick{
    if(_seriesCardBlock){
        _seriesCardBlock(@"card_click",_seriesModel);
    }
}
#pragma mark - --------------自定义方法----------------------
-(void)updateUI{
    if(_seriesModel){
        _brandClickButton.hidden = NO;
        _cardClickButton.hidden = NO;

        sd_downloadWebImageWithRelativePath(NO, _seriesModel.logoPath, _headIcon, kLogoCover, 0);
        _brandNameLabel.text = _seriesModel.brandName;
        _designerNameLabel.text = _seriesModel.designerName;


        [_brandClickButton mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.left.right.top.mas_equalTo(0);
            make.height.mas_equalTo(60);
        }];

        sd_downloadWebImageWithRelativePath(YES, _seriesModel.albumImg, _cardClickButton, kStyleCover, UIViewContentModeScaleAspectFill);

    }else{
        _brandClickButton.hidden = YES;
        _cardClickButton.hidden = YES;
    }
}

#pragma mark - --------------other----------------------

@end
