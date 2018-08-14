//
//  YYChooseStyleCell.m
//  YunejianBuyer
//
//  Created by yyj on 2017/7/5.
//  Copyright © 2017年 Apple. All rights reserved.
//

#import "YYChooseStyleCell.h"

#import "SCGIFImageView.h"
#import "UIImageView+CornerRadius.h"

@interface YYChooseStyleCell()

@property (nonatomic,strong) SCGIFImageView *brandImg;

@property (nonatomic,strong) UILabel *brandNameLabel;

@property (nonatomic,strong) UILabel *styleNameLabel;

@property (nonatomic,strong) UILabel *wholesaleLabel;

@property (nonatomic,strong) UILabel *retailLabel;


@end

@implementation YYChooseStyleCell

- (instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if(self){
        UIView *_backView = [UIView getCustomViewWithColor:_define_white_color];
        [self.contentView addSubview:_backView];
        [_backView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.mas_equalTo(self.contentView);
        }];
        _backView.layer.masksToBounds = YES;
        _backView.layer.cornerRadius = 5;
        
        _brandImg = [[SCGIFImageView alloc] init];
        [_backView addSubview:_brandImg];
        _brandImg.userInteractionEnabled = YES;
        _brandImg.backgroundColor = [UIColor colorWithHex:@"F8F8F8"];
        CGFloat cellW = (SCREEN_WIDTH - 12*2 - 10)/2.0f;
        //    CGFloat cellH = 266;
        CGFloat cellH = cellW - 10;
        [_brandImg mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.top.mas_equalTo(5);
            make.right.mas_equalTo(-5);
            make.height.mas_equalTo(cellH);
        }];
        _brandImg.contentMode = UIViewContentModeScaleAspectFit;
        _brandImg.layer.masksToBounds = YES;
        _brandImg.layer.cornerRadius = 3;
        
        
        _brandNameLabel = [UILabel getLabelWithAlignment:0 WithTitle:nil WithFont:13.0f WithTextColor:nil WithSpacing:0];
        [_backView addSubview:_brandNameLabel];
        [_brandNameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(5);
            make.right.mas_equalTo(-5);
            make.top.mas_equalTo(_brandImg.mas_bottom).with.offset(6);
        }];
        
        _styleNameLabel = [UILabel getLabelWithAlignment:0 WithTitle:nil WithFont:12.0f WithTextColor:[UIColor colorWithHex:@"919191"] WithSpacing:0];
        [_backView addSubview:_styleNameLabel];
        [_styleNameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(5);
            make.right.mas_equalTo(-5);
            make.top.mas_equalTo(_brandNameLabel.mas_bottom).with.offset(2);
        }];
        
        UIView *lineView = [UIView getCustomViewWithColor:[UIColor colorWithHex:@"F0F0F0"]];
        [_backView addSubview:lineView];
        [lineView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(5);
            make.right.mas_equalTo(-5);
            make.height.mas_equalTo(1);
            make.top.mas_equalTo(_styleNameLabel.mas_bottom).with.offset(6);
        }];
        
        
        _wholesaleLabel = [UILabel getLabelWithAlignment:0 WithTitle:nil WithFont:12.0f WithTextColor:nil WithSpacing:0];
        [_backView addSubview:_wholesaleLabel];
        [_wholesaleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(5);
            make.right.mas_equalTo(-5);
            make.top.mas_equalTo(lineView.mas_bottom).with.offset(6);
        }];
        
        _retailLabel = [UILabel getLabelWithAlignment:0 WithTitle:nil WithFont:12.0f WithTextColor:[UIColor colorWithHex:@"919191"] WithSpacing:0];
        [_backView addSubview:_retailLabel];
        [_retailLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(5);
            make.right.mas_equalTo(-5);
            make.top.mas_equalTo(_wholesaleLabel.mas_bottom).with.offset(2);
        }];
        
    }
    return self;
}

-(void)updateUI{
    if(_styleModel){
        sd_downloadWebImageWithRelativePath(YES, _styleModel.albumImg, _brandImg, kBuyerCardImage, UIViewContentModeScaleAspectFit);
        _brandNameLabel.text = _styleModel.brandName;
        _styleNameLabel.text = _styleModel.styleName;
        NSString *tradePrice = replaceMoneyFlag([NSString stringWithFormat:@"%@ ￥%0.2f",NSLocalizedString(@"批发价",nil),[_styleModel.tradePrice floatValue]],[_styleModel.curType integerValue]);
        NSString *retailPrice = replaceMoneyFlag([NSString stringWithFormat:@"%@ ￥%0.2f",NSLocalizedString(@"零售价",nil),[_styleModel.retailPrice floatValue]],[_styleModel.curType integerValue]);
        _wholesaleLabel.text = tradePrice;
        _retailLabel.text = retailPrice;
    }else{
        sd_downloadWebImageWithRelativePath(YES, @"", _brandImg, kBuyerCardImage, UIViewContentModeScaleAspectFit);
        _brandNameLabel.text = @"";
        _styleNameLabel.text = @"";
        _wholesaleLabel.text = @"";
        _retailLabel.text = @"";
    }
}

@end
