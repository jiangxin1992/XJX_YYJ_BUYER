//
//  YYUserSeriesCollectionCell.m
//  YunejianBuyer
//
//  Created by yyj on 2017/7/14.
//  Copyright © 2017年 Apple. All rights reserved.
//

#import "YYUserSeriesCollectionCell.h"

#import "YYUserSeriesModel.h"
#import "SCGIFImageView.h"
#import "YYNoDataView.h"

@interface YYUserSeriesCollectionCell()

@property (nonatomic,strong) UIView *backView;

@property (nonatomic,strong) SCGIFImageView *seriesImg;

@property (nonatomic,strong) UILabel *styleSizeLabel;

@property (nonatomic,strong) UILabel *seriesNameLabel;

@property (nonatomic,strong) UILabel *brandNameLabel;

@property (nonatomic,strong) UILabel *wholesaleLabel;

@property (nonatomic,strong) UIView *maskView;

@property (nonatomic,strong) UILabel *invalidLabel;

@property (nonatomic,strong) UIView *noIntroductionDataView;

@end

@implementation YYUserSeriesCollectionCell

#pragma mark - INIT

-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if(self){
        [self SomePrepare];
        [self UIConfig];
    }
    return self;
}

#pragma mark - SomePrepare
-(void)SomePrepare
{
    [self PrepareData];
    [self PrepareUI];
}
-(void)PrepareData{}
-(void)PrepareUI{
    self.contentView.backgroundColor = [UIColor colorWithHex:@"f8f8f8"];
}

#pragma mark - UIConfig

-(void)UIConfig{
    _backView = [UIView getCustomViewWithColor:_define_white_color];
    [self.contentView addSubview:_backView];
    [_backView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(13);
        make.right.mas_equalTo(-13);
        make.top.mas_equalTo(0);
        make.bottom.mas_equalTo(-7);
    }];
    _backView.layer.masksToBounds = YES;
    _backView.layer.cornerRadius = 5.0f;
    
    _seriesImg = [[SCGIFImageView alloc] init];
    [_backView addSubview:_seriesImg];
    _seriesImg.backgroundColor = [UIColor colorWithHex:@"f8f8f8"];
    _seriesImg.contentMode = UIViewContentModeScaleAspectFit;
    [_seriesImg mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(5);
        make.centerY.mas_equalTo(_backView);
        make.width.height.mas_equalTo(110);
    }];
    _seriesImg.layer.masksToBounds = YES;
    _seriesImg.layer.cornerRadius = 3.0f;
    
    UIView *styleSizeView = [UIView getCustomViewWithColor:nil];
    [_seriesImg addSubview:styleSizeView];
    styleSizeView.backgroundColor = [_define_black_color colorWithAlphaComponent:0.3];
    [styleSizeView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.bottom.right.mas_equalTo(0);
        make.height.mas_equalTo(20);
    }];
    styleSizeView.layer.masksToBounds = YES;
    styleSizeView.layer.cornerRadius = 3.0f;
    
    _styleSizeLabel = [UILabel getLabelWithAlignment:2 WithTitle:nil WithFont:12.0f WithTextColor:_define_white_color WithSpacing:0];
    [styleSizeView addSubview:_styleSizeLabel];
    [_styleSizeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.bottom.top.mas_equalTo(0);
        make.right.mas_equalTo(-4);
    }];
    
    
    _seriesNameLabel = [UILabel getLabelWithAlignment:0 WithTitle:nil WithFont:14.0f WithTextColor:nil WithSpacing:0];
    _seriesNameLabel.numberOfLines = 2;
    [_backView addSubview:_seriesNameLabel];
    [_seriesNameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(10);
        make.left.mas_equalTo(_seriesImg.mas_right).with.offset(12);
        make.right.mas_equalTo(-12);
    }];
    
    _brandNameLabel = [UILabel getLabelWithAlignment:0 WithTitle:nil WithFont:12.0f WithTextColor:[UIColor colorWithHex:@"919191"] WithSpacing:0];
    [_backView addSubview:_brandNameLabel];
    [_brandNameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(_seriesNameLabel.mas_bottom).with.offset(3);
        make.left.mas_equalTo(_seriesImg.mas_right).with.offset(12);
        make.right.mas_equalTo(-12);
    }];
    
    _wholesaleLabel = [UILabel getLabelWithAlignment:0 WithTitle:nil WithFont:13.0f WithTextColor:nil WithSpacing:0];
    [_backView addSubview:_wholesaleLabel];
    _wholesaleLabel.adjustsFontSizeToFitWidth = YES;
    [_wholesaleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(_seriesImg.mas_right).with.offset(12);
        make.right.mas_equalTo(-12);
        make.top.mas_equalTo(_seriesImg.mas_bottom).with.offset(-20);
    }];
    
    _maskView = [UIView getCustomViewWithColor:nil];
    [_backView addSubview:_maskView];
    _maskView.backgroundColor = [_define_white_color colorWithAlphaComponent:0.5];
    [_maskView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(_backView);
    }];
    _maskView.layer.masksToBounds = YES;
    _maskView.layer.cornerRadius = 5.0f;
    _maskView.hidden = YES;
    
    _invalidLabel = [UILabel getLabelWithAlignment:1 WithTitle:NSLocalizedString(@"失效",nil) WithFont:12.0f WithTextColor:_define_white_color WithSpacing:0];
    [self.contentView addSubview:_invalidLabel];
    _invalidLabel.backgroundColor = _define_black_color;
    [_invalidLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(13);
        make.top.mas_equalTo(0);
        make.width.mas_equalTo(40);
        make.height.mas_equalTo(20);
    }];
    _invalidLabel.layer.masksToBounds = YES;
    _invalidLabel.layer.cornerRadius = 3.0f;
    _invalidLabel.hidden = YES;
    
    [self CreateNoDataView];

}
-(void)CreateNoDataView
{
    if(!_noIntroductionDataView)
    {
        //        暂无预约记录
        //        马上去预约参加 YCO SYSTEM 线下订货会
        
        _noIntroductionDataView = (YYNoDataView *)addNoDataView_phone(self.contentView,[NSString stringWithFormat:@"%@|icon:nodata_collection",NSLocalizedString(@"还没有收藏的系列",nil)],@"000000",@"nodata_collection");
        
        NSString *fillStr = NSLocalizedString(@"赶紧去逛一逛，发现喜欢的系列吧" ,nil);
        NSString *colorStr = NSLocalizedString(@"逛一逛",nil);
        UILabel *tipLabel = [UILabel getLabelWithAlignment:1 WithTitle:nil WithFont:13.0f WithTextColor:[UIColor colorWithHex:@"919191"] WithSpacing:0];
        [_noIntroductionDataView addSubview:tipLabel];
        NSMutableAttributedString *string = [[NSMutableAttributedString alloc] initWithString:NSLocalizedString(@"赶紧去逛一逛，发现喜欢的系列吧" ,nil)];
        NSRange range = [fillStr rangeOfString:colorStr];
        [string addAttribute:NSForegroundColorAttributeName value:[UIColor colorWithHex:@"47A3DC"] range:range];
        tipLabel.attributedText = string;
        tipLabel.userInteractionEnabled = YES;
        [tipLabel addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(goToOrderingView)]];
        [tipLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(17);
            make.right.mas_equalTo(-17);
            make.bottom.mas_equalTo(-20);
            make.height.mas_equalTo(40);
        }];
    }
    [self.contentView addSubview:_noIntroductionDataView];
    [_noIntroductionDataView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.left.bottom.right.mas_equalTo(0);
        make.top.mas_equalTo(100);
    }];
    _noIntroductionDataView.hidden = YES;
}
#pragma mark - SomeAction
-(void)goToOrderingView{
    if(_seriesCellBlock){
        _seriesCellBlock(@"go_seriesview");
    }
}
-(void)updateUI{
    if(_haveData){
        _noIntroductionDataView.hidden = YES;
        _backView.backgroundColor = _define_white_color;
        _seriesImg.hidden = NO;
        _seriesNameLabel.hidden = NO;
        _brandNameLabel.hidden = NO;
        _wholesaleLabel.hidden = NO;
        sd_downloadWebImageWithRelativePath(NO, _seriesModel.albumImg, _seriesImg, kLogoCover, 0);
        _seriesNameLabel.text = _seriesModel.seriesName;
        _brandNameLabel.text = _seriesModel.brandName;
        
        NSString *wholesaleStr = nil;
        if([_seriesModel.curType integerValue] == -1){
            wholesaleStr = NSLocalizedString(@"零售价范围：多币种", nil);
        }else{
            wholesaleStr = replaceMoneyFlag([NSString stringWithFormat:@"%@￥%0.2f - %0.2f",NSLocalizedString(@"零售价范围：",nil),[_seriesModel.minRetailPrice floatValue],[_seriesModel.maxRetailPrice floatValue]],[_seriesModel.curType integerValue]);
        }
        
        _wholesaleLabel.text = wholesaleStr;
        _styleSizeLabel.text = [[NSString alloc] initWithFormat:NSLocalizedString(@"%@款", nil),[_seriesModel.styleSize stringValue] ];
        if([_seriesModel.status integerValue]){
            _maskView.hidden = NO;
            _invalidLabel.hidden = NO;
        }else{
            _maskView.hidden = YES;
            _invalidLabel.hidden = YES;
        }
        
    }else{
        _noIntroductionDataView.hidden = NO;
        _backView.backgroundColor = [UIColor clearColor];
        _seriesImg.hidden = YES;
        _seriesNameLabel.hidden = YES;
        _brandNameLabel.hidden = YES;
        _wholesaleLabel.hidden = YES;
        _maskView.hidden = YES;
        _invalidLabel.hidden = YES;
        
        sd_downloadWebImageWithRelativePath(NO, @"", _seriesImg, kLogoCover, 0);
        _seriesNameLabel.text = @"";
        _brandNameLabel.text = @"";
        _wholesaleLabel.text = @"";
        _styleSizeLabel.text = @"";
        
    }
}
#pragma mark - Other

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}

@end
