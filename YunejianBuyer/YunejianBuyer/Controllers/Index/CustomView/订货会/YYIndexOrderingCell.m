//
//  OrderingListCell.m
//  YunejianBuyer
//
//  Created by yyj on 2017/5/31.
//  Copyright © 2017年 Apple. All rights reserved.
//

#import "YYIndexOrderingCell.h"

#import "SCGIFImageView.h"
#import "YYNoDataView.h"

#import "UIImage+Tint.h"

@interface YYIndexOrderingCell()

@property (strong ,nonatomic) UIButton *backView;
@property (strong ,nonatomic) SCGIFImageView *orderingImageView;
@property (strong ,nonatomic) UILabel *statusLabel;
@property (strong ,nonatomic) UILabel *nameLabel;
@property (strong ,nonatomic) UILabel *timeLabel;

@property (strong ,nonatomic) UIButton *moreOrderingButton;

@property (nonatomic,strong) UIView *noIntroductionDataView;

@property(nonatomic,copy) void (^indexOrderingBlock)(NSString *type,YYOrderingListItemModel *listItemModel);

@end

@implementation YYIndexOrderingCell

#pragma mark - --------------生命周期--------------
-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier WithBlock:(void(^)(NSString *type,YYOrderingListItemModel *listItemModel))block{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if(self){
        _indexOrderingBlock = block;
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
-(void)PrepareData
{
}
-(void)PrepareUI
{
    self.contentView.backgroundColor = [UIColor colorWithHex:@"f8f8f8"];
}
#pragma mark - UIConfig
-(void)UIConfig{

    _backView = [UIButton getCustomBtn];
    [self.contentView addSubview:_backView];
    [_backView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(17);
        make.right.mas_equalTo(-17);
        make.top.mas_equalTo(10);
        make.height.mas_equalTo(276);
    }];
    _backView.backgroundColor = _define_white_color;
    [_backView addTarget:self action:@selector(cardClick) forControlEvents:UIControlEventTouchUpInside];

    _orderingImageView = [[SCGIFImageView alloc] init];
    _orderingImageView.contentMode = UIViewContentModeScaleAspectFill;
    [_backView addSubview:_orderingImageView];
    _orderingImageView.clipsToBounds = YES;
    [_orderingImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(16);
        make.left.mas_equalTo(16);
        make.right.mas_equalTo(-16);
        make.height.mas_equalTo(194);
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
    [_backView addSubview:_nameLabel];
    _nameLabel.font = [UIFont boldSystemFontOfSize:16.0f];
    [_nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(17);
        make.right.mas_equalTo(-17);
        make.top.mas_equalTo(_orderingImageView.mas_bottom).with.offset(10);
    }];

    _timeLabel = [UILabel getLabelWithAlignment:1 WithTitle:nil WithFont:13.0f WithTextColor:[UIColor colorWithHex:@"919191"] WithSpacing:0];
    [_backView addSubview:_timeLabel];
    [_timeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(17);
        make.right.mas_equalTo(-17);
        make.top.mas_equalTo(_nameLabel.mas_bottom).with.offset(4);
    }];

    _moreOrderingButton = [UIButton getCustomBtn];
    [self.contentView addSubview:_moreOrderingButton];
    [_moreOrderingButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(self.contentView);
        make.height.mas_equalTo(20);
        make.top.mas_equalTo(_backView.mas_bottom).with.offset(16);
    }];
    [_moreOrderingButton setEnlargeEdgeWithTop:10 right:40 bottom:10 left:40];
    [_moreOrderingButton addTarget:self action:@selector(moreOrdering) forControlEvents:UIControlEventTouchUpInside];

    UILabel *titleLabel = [UILabel getLabelWithAlignment:0 WithTitle:NSLocalizedString(@"查看更多订货会",nil) WithFont:13.0f WithTextColor:[UIColor colorWithHex:@"919191"] WithSpacing:0];
    [_moreOrderingButton addSubview:titleLabel];
    [titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(0);
        make.centerY.mas_equalTo(_moreOrderingButton);
    }];

    UIImageView *rightIcon = [UIImageView getCustomImg];
    [_moreOrderingButton addSubview:rightIcon];
    [rightIcon mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(titleLabel.mas_right).with.offset(2);
        make.centerY.mas_equalTo(titleLabel);
        make.width.mas_equalTo(5);
        make.height.mas_equalTo(10);
        make.right.mas_equalTo(0);
    }];
    [rightIcon setImage:[[UIImage imageNamed:@"right_icon"] imageWithTintColor:[UIColor colorWithHex:@"919191"]]];
    rightIcon.contentMode = UIViewContentModeScaleToFill;

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

#pragma mark - --------------自定义响应----------------------
-(void)moreOrdering{
    if(_indexOrderingBlock){
        _indexOrderingBlock(@"more_ordering",nil);
    }
}
-(void)cardClick{
    if(_indexOrderingBlock){
        _indexOrderingBlock(@"card_click",_listItemModel);
    }
}

#pragma mark - --------------自定义方法----------------------
-(void)setListItemModel:(YYOrderingListItemModel *)listItemModel{
    _listItemModel = listItemModel;
    if(_haveData){
        _noIntroductionDataView.hidden = YES;
        _backView.hidden = NO;
        _moreOrderingButton.hidden = !_isLastOrdering;

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
        _timeLabel.text = [[NSString alloc] initWithFormat:@"%@-%@",getShowDateByFormatAndTimeInterval(@"yyyy.MM.dd",[_listItemModel.startDate stringValue]),getShowDateByFormatAndTimeInterval(@"yyyy.MM.dd",[_listItemModel.endDate stringValue])];
    }else{
        _noIntroductionDataView.hidden = NO;
        _backView.hidden = YES;
        _moreOrderingButton.hidden = YES;
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
