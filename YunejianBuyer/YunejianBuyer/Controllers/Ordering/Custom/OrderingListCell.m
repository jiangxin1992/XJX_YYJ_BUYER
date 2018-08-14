//
//  OrderingListCell.m
//  YunejianBuyer
//
//  Created by yyj on 2017/5/31.
//  Copyright © 2017年 Apple. All rights reserved.
//

#import "OrderingListCell.h"

#import "SCGIFImageView.h"
#import "YYNoDataView.h"

@interface OrderingListCell()

@property (strong,nonatomic) UIView *topLine;

@property (strong ,nonatomic) SCGIFImageView *orderingImageView;
@property (strong ,nonatomic) UILabel *statusLabel;
@property (strong ,nonatomic) UILabel *nameLabel;
@property (strong ,nonatomic) UILabel *timeLabel;
@property (strong ,nonatomic) UILabel *localLabel;

@property (nonatomic,strong) UIView *noIntroductionDataView;

@end

@implementation OrderingListCell


/**
 * 初始化
 */
-(id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(nullable NSString *)reuseIdentifier{
    self=[super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if(self)
    {
        [self SomePrepare];
        [self UIConfig];
    }
    return self;
}
#pragma mark - SomePrepare
#pragma mark - SomePrepare
-(void)SomePrepare
{
    [self PrepareData];
    [self PrepareUI];
}
-(void)PrepareData
{
}
-(void)PrepareUI
{
    self.contentView.backgroundColor=_define_white_color;
}
#pragma mark - UIConfig
-(void)UIConfig{

    _topLine = [UIView getCustomViewWithColor:[UIColor colorWithHex:@"EFEFEF"]];
    [self.contentView addSubview:_topLine];
    [_topLine mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(0);
        make.left.right.mas_equalTo(0);
        make.height.mas_equalTo(1);
    }];

    _orderingImageView = [[SCGIFImageView alloc] init];
    _orderingImageView.contentMode = UIViewContentModeScaleAspectFill;
    [self.contentView addSubview:_orderingImageView];
    _orderingImageView.clipsToBounds = YES;
    [_orderingImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.mas_equalTo(0);
        make.top.mas_equalTo(11);
        make.height.mas_equalTo(205);
    }];
    
    _statusLabel = [UILabel getLabelWithAlignment:1 WithTitle:nil WithFont:13.0f WithTextColor:_define_white_color WithSpacing:0];
    [_orderingImageView addSubview:_statusLabel];
    _statusLabel.layer.masksToBounds = YES;
    _statusLabel.layer.cornerRadius = 3.0f;
    [_statusLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(100);
        make.height.mas_equalTo(30);
        make.top.mas_equalTo(4);
        make.right.mas_equalTo(-4);
    }];
    
    _nameLabel = [UILabel getLabelWithAlignment:1 WithTitle:nil WithFont:16.0f WithTextColor:nil WithSpacing:0];
    [self.contentView addSubview:_nameLabel];
    _nameLabel.font = [UIFont boldSystemFontOfSize:16.0f];
    [_nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(17);
        make.right.mas_equalTo(-17);
        make.top.mas_equalTo(_orderingImageView.mas_bottom).with.offset(8.0f);
    }];
    
    _timeLabel = [UILabel getLabelWithAlignment:1 WithTitle:nil WithFont:13.0f WithTextColor:[UIColor colorWithHex:@"919191"] WithSpacing:0];
    [self.contentView addSubview:_timeLabel];
    [_timeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(17);
        make.right.mas_equalTo(-17);
        make.top.mas_equalTo(_nameLabel.mas_bottom).with.offset(4.0f);
    }];
    
    _localLabel = [UILabel getLabelWithAlignment:1 WithTitle:nil WithFont:13.0f WithTextColor:[UIColor colorWithHex:@"919191"] WithSpacing:0];
    [self.contentView addSubview:_localLabel];
    [_localLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(17);
        make.right.mas_equalTo(-17);
        make.top.mas_equalTo(_timeLabel.mas_bottom).with.offset(4.0f);
    }];
    
    [self CreateNoDataView];
}
-(void)CreateNoDataView
{
    if(!_noIntroductionDataView)
    {
        _noIntroductionDataView = (YYNoDataView *)addNoDataView_phone(self.contentView,[NSString stringWithFormat:@"%@|icon:ordering_nodata",NSLocalizedString(@"暂无可预约的订货会/n敬请期待",nil)],kDefaultTitleColor_phone,@"ordering_nodata");
    }
    [self.contentView addSubview:_noIntroductionDataView];
    [_noIntroductionDataView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.left.bottom.right.mas_equalTo(0);
        make.top.mas_equalTo(100);
    }];
    _noIntroductionDataView.hidden = YES;
}
-(void)setListItemModel:(YYOrderingListItemModel *)listItemModel{
    _listItemModel = listItemModel;
    if(_haveData){
        _noIntroductionDataView.hidden = YES;
        _orderingImageView.hidden = NO;
        _statusLabel.hidden = NO;
        _nameLabel.hidden = NO;
        _timeLabel.hidden = NO;

        if(_cellType == EOrderingListCellTypeList){
            //列表
            _topLine.hidden = YES;
            _localLabel.hidden = NO;
        }else{
            //首页
            _topLine.hidden = NO;
            _localLabel.hidden = YES;
        }
        [_orderingImageView mas_updateConstraints:^(MASConstraintMaker *make) {
            if(_cellType == EOrderingListCellTypeList){
                //列表
                make.top.mas_equalTo(0);
                make.left.right.mas_equalTo(0);
                make.height.mas_equalTo(205);
            }else{
                //首页
                make.top.mas_equalTo(11);
                make.left.mas_equalTo(17);
                make.right.mas_equalTo(-17);
                make.height.mas_equalTo(187);
            }

        }];

        sd_downloadWebImageWithRelativePath(YES, _listItemModel.poster, _orderingImageView, kLookBookImage,UIViewContentModeScaleAspectFill);
        if([_listItemModel.status isEqualToString:@"ING"]){
            //可预约
            _statusLabel.backgroundColor = [UIColor colorWithHex:@"58C776"];
            _statusLabel.text = NSLocalizedString(@"预约开放中",nil);
        }else{
            //已结束
            _statusLabel.backgroundColor = [UIColor colorWithHex:@"D3D3D3"];
            _statusLabel.text = NSLocalizedString(@"预约已结束",nil);
        }
        _nameLabel.text = _listItemModel.name;
        _timeLabel.text = [[NSString alloc] initWithFormat:@"%@-%@  %@",getShowDateByFormatAndTimeInterval(@"yyyy.MM.dd",[_listItemModel.startDate stringValue]),getShowDateByFormatAndTimeInterval(@"yyyy.MM.dd",[_listItemModel.endDate stringValue]),_listItemModel.rangeTime];
    
        _localLabel.text = _listItemModel.city;

    }else{
        _noIntroductionDataView.hidden = NO;
        _orderingImageView.hidden = YES;
        _statusLabel.hidden = YES;
        _nameLabel.hidden = YES;
        _timeLabel.hidden = YES;
        _localLabel.hidden = YES;
        _topLine.hidden = YES;
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
