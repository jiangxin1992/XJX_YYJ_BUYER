//
//  OrderingHistoryListCell.m
//  YunejianBuyer
//
//  Created by yyj on 2017/6/2.
//  Copyright © 2017年 Apple. All rights reserved.
//

#import "OrderingHistoryListCell.h"
#import "SCGIFImageView.h"
#import "YYNoDataView.h"

@interface OrderingHistoryListCell()

@property (strong,nonatomic) UIView *statusView;
@property (strong,nonatomic) UILabel *statusLabel;

@property (strong,nonatomic) UIView *contentInfoView;
@property (strong ,nonatomic) SCGIFImageView *orderingImageView;
@property (strong,nonatomic) UILabel *orderingNameLabel;
@property (strong,nonatomic) UILabel *orderingSelecedTimeTitleLabel;
@property (strong,nonatomic) UILabel *orderingSelecedTimeLabel;
@property (strong,nonatomic) UILabel *orderingLocTitleLabel;
@property (strong,nonatomic) UILabel *orderingLocLabel;

@property (strong,nonatomic) UIView *actionView;
@property (strong,nonatomic) UILabel *applyTimeLabel;
@property (strong,nonatomic) UIButton *applyButton;

@property (nonatomic,strong) UIView *noIntroductionDataView;

@property(nonatomic,copy) void (^applyBlock)(NSString *type,NSIndexPath *indexPath);

@end


@implementation OrderingHistoryListCell

/**
 * 初始化
 */
-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier WithBlock:(void(^)(NSString *type,NSIndexPath *indexPath))block{
    self=[super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if(self)
    {
        _applyBlock = block;
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
    self.contentView.backgroundColor=_define_white_color;
}
#pragma mark - UIConfig
-(void)UIConfig{
    
    _statusView = [UIView getCustomViewWithColor:nil];
    [self.contentView addSubview:_statusView];
    [_statusView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.right.mas_equalTo(0);
        make.height.mas_equalTo(40);
    }];
    
    UILabel *_statusTitleLabel = [UILabel getLabelWithAlignment:0 WithTitle:NSLocalizedString(@"申请状态：",nil) WithFont:14.0f WithTextColor:[UIColor colorWithHex:@"919191"] WithSpacing:0];
    [_statusView addSubview:_statusTitleLabel];
    CGFloat _width = getWidthWithHeight(20, NSLocalizedString(@"申请状态：",nil), [UIFont systemFontOfSize:14.0f]);
    [_statusTitleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(17);
        make.top.bottom.mas_equalTo(0);
        make.width.mas_equalTo(_width);
    }];
    

    _statusLabel = [UILabel getLabelWithAlignment:0 WithTitle:nil WithFont:14.0f WithTextColor:nil WithSpacing:0];
    [_statusView addSubview:_statusLabel];
    [_statusLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(_statusTitleLabel.mas_right).with.offset(0);
        make.centerY.mas_equalTo(_statusTitleLabel);
        make.right.mas_equalTo(-17);
    }];
    
    
    UIView *_statusDownLine = [UIView getCustomViewWithColor:[UIColor colorWithHex:@"EFEFEF"]];
    [_statusView addSubview:_statusDownLine];
    [_statusDownLine mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.left.right.mas_equalTo(0);
        make.height.mas_equalTo(1);
    }];
    
    
    UIView *_applyDownView = [UIView getCustomViewWithColor:[UIColor colorWithHex:@"d3d3d3"]];
    [self.contentView addSubview:_applyDownView];
    [_applyDownView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.left.right.mas_equalTo(0);
        make.height.mas_equalTo(1);
    }];
    
    _actionView = [UIView getCustomViewWithColor:nil];
    [self.contentView addSubview:_actionView];
    [_actionView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.mas_equalTo(0);
        make.height.mas_equalTo(50);
        make.bottom.mas_equalTo(_applyDownView.mas_top).with.offset(0);
    }];
    
    _applyButton = [UIButton getCustomTitleBtnWithAlignment:0 WithFont:14.0f WithSpacing:0 WithNormalTitle:nil WithNormalColor:nil WithSelectedTitle:nil WithSelectedColor:nil];
    [_actionView addSubview:_applyButton];
    [_applyButton addTarget:self action:@selector(applyAction) forControlEvents:UIControlEventTouchUpInside];
    _applyButton.layer.masksToBounds = YES;
    _applyButton.layer.borderColor = [[UIColor colorWithHex:@"d3d3d3"] CGColor];
    _applyButton.layer.borderWidth = 1;
    _applyButton.layer.cornerRadius = 3;
    [_applyButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(-17);
        make.centerY.mas_equalTo(_actionView);
        make.width.mas_equalTo(80);
        make.height.mas_equalTo(30);
    }];
    
    _applyTimeLabel = [UILabel getLabelWithAlignment:0 WithTitle:nil WithFont:13.0f WithTextColor:[UIColor colorWithHex:@"919191"] WithSpacing:0];
    [_actionView addSubview:_applyTimeLabel];
    
    _applyTimeLabel.font = [UIFont systemFontOfSize:IsPhone6_gt?13.0f:11.0f];
    [_applyTimeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(17);
        make.centerY.mas_equalTo(_actionView);
        make.right.mas_equalTo(_applyButton.mas_left).with.offset(5);
    }];
    
    
    
    _contentInfoView = [UIView getCustomViewWithColor:nil];
    [self.contentView addSubview:_contentInfoView];
    [_contentInfoView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.mas_equalTo(0);
        make.top.mas_equalTo(_statusView.mas_bottom).with.offset(0);
        make.bottom.mas_equalTo(_actionView.mas_top).with.offset(0);
    }];
    
    _orderingImageView = [[SCGIFImageView alloc] init];
    [_contentInfoView addSubview:_orderingImageView];
    _orderingImageView.contentMode = UIViewContentModeScaleAspectFill;
    _orderingImageView.clipsToBounds = YES;
    [_orderingImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(10);
        make.left.mas_equalTo(17);
        make.height.mas_equalTo(63);
        make.width.mas_equalTo(115);
    }];
    
    _orderingNameLabel = [UILabel getLabelWithAlignment:0 WithTitle:nil WithFont:14.0f WithTextColor:nil WithSpacing:0];
    [_contentInfoView addSubview:_orderingNameLabel];
    _orderingNameLabel.font = [UIFont boldSystemFontOfSize:14.0f];
    _orderingNameLabel.numberOfLines = 2;
    [_orderingNameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(_orderingImageView);
        make.left.mas_equalTo(_orderingImageView.mas_right).with.offset(11);
        make.right.mas_equalTo(-17);
    }];
    
    
    CGFloat _timeWidth = getWidthWithHeight(20, NSLocalizedString(@"时间：",nil), [UIFont systemFontOfSize:12.0f]);
    CGFloat _locWidth = getWidthWithHeight(20, NSLocalizedString(@"地点：",nil), [UIFont systemFontOfSize:12.0f]);
    CGFloat _titleWidth = _locWidth>_timeWidth?_locWidth:_timeWidth;
    
    _orderingSelecedTimeTitleLabel = [UILabel getLabelWithAlignment:0 WithTitle:NSLocalizedString(@"时间：",nil) WithFont:12.0f WithTextColor:nil WithSpacing:0];
    [_contentInfoView addSubview:_orderingSelecedTimeTitleLabel];
    [_orderingSelecedTimeTitleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(17);
        make.top.mas_equalTo(_orderingImageView.mas_bottom).with.offset(8);
        make.width.mas_equalTo(_titleWidth);
    }];
    
    _orderingSelecedTimeLabel = [UILabel getLabelWithAlignment:0 WithTitle:nil WithFont:12.0f WithTextColor:nil WithSpacing:0];
    [_contentInfoView addSubview:_orderingSelecedTimeLabel];
    [_orderingSelecedTimeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(_orderingSelecedTimeTitleLabel.mas_right).with.offset(0);
        make.centerY.mas_equalTo(_orderingSelecedTimeTitleLabel);
        make.right.mas_equalTo(-17);
    }];
    
    
    _orderingLocTitleLabel = [UILabel getLabelWithAlignment:0 WithTitle:NSLocalizedString(@"地点：",nil) WithFont:12.0f WithTextColor:nil WithSpacing:0];
    [_contentInfoView addSubview:_orderingLocTitleLabel];
    [_orderingLocTitleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(17);
        make.top.mas_equalTo(_orderingSelecedTimeTitleLabel.mas_bottom).with.offset(6);
        make.width.mas_equalTo(_titleWidth);
    }];
    
    _orderingLocLabel = [UILabel getLabelWithAlignment:0 WithTitle:nil WithFont:12.0f WithTextColor:nil WithSpacing:0];
    [_contentInfoView addSubview:_orderingLocLabel];
    _orderingLocLabel.numberOfLines = 2;
    [_orderingLocLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(_orderingLocTitleLabel.mas_right).with.offset(0);
        make.top.mas_equalTo(_orderingLocTitleLabel);
        make.right.mas_equalTo(-17);
    }];

    UIView *_contentInfoDownLine = [UIView getCustomViewWithColor:[UIColor colorWithHex:@"EFEFEF"]];
    [_contentInfoView addSubview:_contentInfoDownLine];
    [_contentInfoDownLine mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.bottom.mas_equalTo(0);
        make.height.mas_equalTo(1);
    }];
    
    [self CreateNoDataView];
}
-(void)CreateNoDataView
{
    if(!_noIntroductionDataView)
    {
//        暂无预约记录
//        马上去预约参加 YCO SYSTEM 线下订货会
        
        _noIntroductionDataView = (YYNoDataView *)addNoDataView_phone(self.contentView,[NSString stringWithFormat:@"%@|icon:ordering_nodata",NSLocalizedString(@"暂无预约记录",nil)],@"000000",@"no_ordering_icon");
        
        NSString *fillStr = NSLocalizedString(@"马上去预约参加 YCO SYSTEM 线下订货会" ,nil);
        NSString *colorStr = NSLocalizedString(@" YCO SYSTEM 线下订货会",nil);
        UILabel *tipLabel = [UILabel getLabelWithAlignment:1 WithTitle:nil WithFont:13.0f WithTextColor:[UIColor colorWithHex:@"919191"] WithSpacing:0];
        [_noIntroductionDataView addSubview:tipLabel];
        NSMutableAttributedString *string = [[NSMutableAttributedString alloc] initWithString:NSLocalizedString(@"马上去预约参加 YCO SYSTEM 线下订货会" ,nil)];
        NSRange range = [fillStr rangeOfString:colorStr];
        [string addAttribute:NSForegroundColorAttributeName value:[UIColor colorWithRed:71.0f/255.0f green:163.0f/255.0f blue:220.0f/255.0f alpha:1.000] range:range];
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
#pragma mark - Setter
-(void)setListItemModel:(YYOrderingHistoryListItemModel *)listItemModel{
    _listItemModel = listItemModel;
    if(_haveData){
        _noIntroductionDataView.hidden = YES;
        _statusView.hidden = NO;
        _contentInfoView.hidden = NO;
        _actionView.hidden = NO;

        if([_listItemModel.status isEqualToString:@"TO_BE_VERIFIED"]){
            _statusLabel.text = NSLocalizedString(@"待审核",nil);
            _statusLabel.textColor = [UIColor colorWithHex:@"FFB000"];
            [_applyButton setTitle:NSLocalizedString(@"取消预约_short",nil) forState:UIControlStateNormal];
        }else if([_listItemModel.status isEqualToString:@"VERIFIED"]){
            _statusLabel.text = NSLocalizedString(@"预约成功",nil);
            _statusLabel.textColor = [UIColor colorWithHex:@"58C776"];
            [_applyButton setTitle:NSLocalizedString(@"取消预约_short",nil) forState:UIControlStateNormal];
        }else if([_listItemModel.status isEqualToString:@"REJECTED"]){
            _statusLabel.text = NSLocalizedString(@"预约失败",nil);
            _statusLabel.textColor = [UIColor colorWithHex:@"EF4E31"];
            [_applyButton setTitle:NSLocalizedString(@"删除",nil) forState:UIControlStateNormal];
        }else if([_listItemModel.status isEqualToString:@"INVALIDATED"]){
            _statusLabel.text = NSLocalizedString(@"已失效",nil);
            _statusLabel.textColor = [UIColor colorWithHex:@"919191"];
            [_applyButton setTitle:NSLocalizedString(@"删除",nil) forState:UIControlStateNormal];
        }else if([_listItemModel.status isEqualToString:@"CANCELLED"]){
            _statusLabel.text = NSLocalizedString(@"已取消",nil);
            _statusLabel.textColor = [UIColor colorWithHex:@"EF4E31"];
            [_applyButton setTitle:NSLocalizedString(@"删除",nil) forState:UIControlStateNormal];
        }else{
            _statusLabel.text = @"";
            [_applyButton setTitle:@"" forState:UIControlStateNormal];
        }
        
        sd_downloadWebImageWithRelativePath(YES, _listItemModel.poster, _orderingImageView, kLookBookImage,UIViewContentModeScaleAspectFill);
        
        _orderingNameLabel.text = _listItemModel.name;
        
        _orderingSelecedTimeLabel.text = [[NSString alloc] initWithFormat:@"%@  %@",getShowDateByFormatAndTimeInterval(@"yyyy.MM.dd",[_listItemModel.selecedDateLong stringValue]),_listItemModel.range];
        
        _orderingLocLabel.text = _listItemModel.address;

        _applyTimeLabel.text = [[NSString alloc] initWithFormat:NSLocalizedString(@"申请时间：%@",nil),getShowDateByFormatAndTimeInterval(@"yyyy.MM.dd HH:mm",[_listItemModel.applyTime stringValue])];
        
        if([_listItemModel.status isEqualToString:@"INVALIDATED"]){
            //已失效
            _orderingNameLabel.textColor = [UIColor colorWithHex:@"919191"];
            _orderingSelecedTimeTitleLabel.textColor = [UIColor colorWithHex:@"919191"];
            _orderingSelecedTimeLabel.textColor = [UIColor colorWithHex:@"919191"];
            _orderingLocTitleLabel.textColor = [UIColor colorWithHex:@"919191"];
            _orderingLocLabel.textColor = [UIColor colorWithHex:@"919191"];
            [_applyButton setTitleColor:[UIColor colorWithHex:@"919191"] forState:UIControlStateNormal];
            _orderingImageView.alpha = 0.5;
            
        }else{
            _orderingNameLabel.textColor = _define_black_color;
            _orderingSelecedTimeTitleLabel.textColor = _define_black_color;
            _orderingSelecedTimeLabel.textColor = _define_black_color;
            _orderingLocTitleLabel.textColor = _define_black_color;
            _orderingLocLabel.textColor = _define_black_color;
            [_applyButton setTitleColor:_define_black_color forState:UIControlStateNormal];
            _orderingImageView.alpha = 1;
        }
        
    }else{
        _noIntroductionDataView.hidden = NO;
        _statusView.hidden = YES;
        _contentInfoView.hidden = YES;
        _actionView.hidden = YES;
    }
}
#pragma mark - SomeAction
-(void)goToOrderingView{
    //去订货会列表
    if(_applyBlock){
        _applyBlock(@"ordering_list",_indexPath);
    }
}
-(void)applyAction{
    if([_listItemModel.status isEqualToString:@"TO_BE_VERIFIED"]||[_listItemModel.status isEqualToString:@"VERIFIED"]){
//        取消预约
        if(_applyBlock){
            _applyBlock(@"cancel",_indexPath);
        }
    }else if([_listItemModel.status isEqualToString:@"REJECTED"]||[_listItemModel.status isEqualToString:@"INVALIDATED"]||[_listItemModel.status isEqualToString:@"CANCELLED"]){
//        删除
        if(_applyBlock){
            _applyBlock(@"delete",_indexPath);
        }
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
