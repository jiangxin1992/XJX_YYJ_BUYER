//
//  YYUserStyleCollectionCell.m
//  YunejianBuyer
//
//  Created by yyj on 2017/7/14.
//  Copyright © 2017年 Apple. All rights reserved.
//

#import "YYUserStyleCollectionCell.h"

#import "YYUserStyleModel.h"
#import "SCGIFImageView.h"
#import "YYNoDataView.h"

#import "UIView+Extension.h"
#import "UITableView+Extension.h"
#import "Function.h"

@interface YYUserStyleCollectionCell()

@property (nonatomic,strong) UIView *backView;

@property (nonatomic,strong) SCGIFImageView *styleImg;

@property (nonatomic,strong) UILabel *styleNameLabel;

@property (nonatomic,strong) UILabel *brandNameLabel;

@property (nonatomic,strong) UILabel *wholesaleLabel;

@property (nonatomic,strong) UIView *maskView;

@property (nonatomic,strong) UILabel *invalidLabel;

@property (nonatomic,strong) UIView *noIntroductionDataView;

@end

@implementation YYUserStyleCollectionCell

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
    
    _styleImg = [[SCGIFImageView alloc] init];
    [_backView addSubview:_styleImg];
    _styleImg.backgroundColor = [UIColor colorWithHex:@"f8f8f8"];
    _styleImg.contentMode = UIViewContentModeScaleAspectFit;
    [_styleImg mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(5);
        make.centerY.mas_equalTo(_backView);
        make.width.height.mas_equalTo(90);
    }];
    _styleImg.layer.masksToBounds = YES;
    _styleImg.layer.cornerRadius = 3.0f;
    
    _styleNameLabel = [UILabel getLabelWithAlignment:0 WithTitle:nil WithFont:14.0f WithTextColor:nil WithSpacing:0];
    _styleNameLabel.numberOfLines = 2;
    [_backView addSubview:_styleNameLabel];
    [_styleNameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(10);
        make.left.mas_equalTo(_styleImg.mas_right).with.offset(12);
        make.right.mas_equalTo(-12);
    }];
    
    
    _brandNameLabel = [UILabel getLabelWithAlignment:0 WithTitle:nil WithFont:12.0f WithTextColor:[UIColor colorWithHex:@"919191"] WithSpacing:0];
    [_backView addSubview:_brandNameLabel];
    [_brandNameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(_styleNameLabel.mas_bottom).with.offset(3);
        make.left.mas_equalTo(_styleImg.mas_right).with.offset(12);
        make.right.mas_equalTo(-12);
    }];
    
    _wholesaleLabel = [UILabel getLabelWithAlignment:0 WithTitle:nil WithFont:13.0f WithTextColor:[UIColor colorWithHex:@"ed6498"] WithSpacing:0];
    [_backView addSubview:_wholesaleLabel];
    [_wholesaleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(_brandNameLabel.mas_bottom).with.offset(2);
        make.left.mas_equalTo(_styleImg.mas_right).with.offset(12);
        make.right.mas_equalTo(-12);
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
        
        _noIntroductionDataView = (YYNoDataView *)addNoDataView_phone(self.contentView,[NSString stringWithFormat:@"%@|icon:nodata_collection",NSLocalizedString(@"还没有收藏的款式",nil)],@"000000",@"nodata_collection");
        
        NSString *fillStr = NSLocalizedString(@"赶紧去逛一逛，发现喜欢的款式吧" ,nil);
        NSString *colorStr = NSLocalizedString(@"逛一逛",nil);
        UILabel *tipLabel = [UILabel getLabelWithAlignment:1 WithTitle:nil WithFont:13.0f WithTextColor:[UIColor colorWithHex:@"919191"] WithSpacing:0];
        [_noIntroductionDataView addSubview:tipLabel];
        NSMutableAttributedString *string = [[NSMutableAttributedString alloc] initWithString:NSLocalizedString(@"赶紧去逛一逛，发现喜欢的款式吧" ,nil)];
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
    if(_styleCellBlock){
        _styleCellBlock(@"go_styleview");
    }
}
-(void)updateUI{
    if(_haveData){
        _noIntroductionDataView.hidden = YES;
        _backView.backgroundColor = _define_white_color;
        _styleImg.hidden = NO;
        _styleNameLabel.hidden = NO;
        _brandNameLabel.hidden = NO;
        _wholesaleLabel.hidden = NO;
        
        sd_downloadWebImageWithRelativePath(NO, _styleModel.albumImg, _styleImg, kLogoCover, 0);
        _styleNameLabel.text = _styleModel.styleName;
//        _styleNameLabel.text = @"先来看斗牛犬宝宝的一般表现，它们似乎对镜子里的自己很好奇又有一点怕怕的，不停进行试探攻击。结果嘛，啥也咬不到，白忙活儿一场。有的狗宝宝比较勇敢，不断向前；有的胆小的很，结果被自己吓跑了，哈哈";
        _brandNameLabel.text = _styleModel.brandName;
        
        NSString *wholesaleStr = replaceMoneyFlag([NSString stringWithFormat:@"%@ ￥%0.2f",NSLocalizedString(@"批发价",nil),[_styleModel.tradePrice floatValue]],[_styleModel.curType integerValue]);
        NSMutableAttributedString *attributedStr = [[NSMutableAttributedString alloc] initWithString: wholesaleStr];
        NSRange range = [wholesaleStr rangeOfString:NSLocalizedString(@"批发价",nil)];
        if (range.location != NSNotFound) {
            [attributedStr addAttribute:  NSForegroundColorAttributeName value:_define_black_color range:range];
        }
        _wholesaleLabel.attributedText = attributedStr;
        
        if([_styleModel.status integerValue]){
            _maskView.hidden = NO;
            _invalidLabel.hidden = NO;
        }else{
            _maskView.hidden = YES;
            _invalidLabel.hidden = YES;
        }
        
    }else{
        _noIntroductionDataView.hidden = NO;
        _backView.backgroundColor = [UIColor clearColor];
        _styleImg.hidden = YES;
        _styleNameLabel.hidden = YES;
        _brandNameLabel.hidden = YES;
        _wholesaleLabel.hidden = YES;
        _maskView.hidden = YES;
        _invalidLabel.hidden = YES;
        
        sd_downloadWebImageWithRelativePath(NO, @"", _styleImg, kLogoCover, 0);
        _styleNameLabel.text = @"";
        _brandNameLabel.text = @"";
        _wholesaleLabel.text = @"";
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
