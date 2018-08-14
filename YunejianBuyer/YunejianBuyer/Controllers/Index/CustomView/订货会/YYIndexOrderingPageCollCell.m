//
//  YYIndexOrderingPageCollCell.m
//  YunejianBuyer
//
//  Created by yyj on 2017/9/21.
//  Copyright © 2017年 Apple. All rights reserved.
//

#import "YYIndexOrderingPageCollCell.h"

#import "SCGIFImageView.h"

#import "YYOrderingListItemModel.h"

@interface YYIndexOrderingPageCollCell()

@property (strong ,nonatomic) SCGIFImageView *orderingImageView;
@property (strong ,nonatomic) UILabel *statusLabel;
@property (strong ,nonatomic) UILabel *nameLabel;
@property (strong ,nonatomic) UILabel *timeLabel;

@end

@implementation YYIndexOrderingPageCollCell

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
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
-(void)PrepareUI{}
#pragma mark - UIConfig
-(void)UIConfig{
    _orderingImageView = [[SCGIFImageView alloc] init];
    [self.contentView addSubview:_orderingImageView];
    [_orderingImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(self.contentView);
    }];
    _orderingImageView.contentMode = UIViewContentModeScaleAspectFill;
    _orderingImageView.clipsToBounds = YES;
    _orderingImageView.layer.masksToBounds = YES;
    _orderingImageView.layer.cornerRadius = 3.0f;

    UIView *mengban = [UIView getCustomViewWithColor:[_define_black_color colorWithAlphaComponent:0.3]];
    [_orderingImageView addSubview:mengban];
    [mengban mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(_orderingImageView);
    }];
    mengban.layer.masksToBounds = YES;
    mengban.layer.cornerRadius = 3.0f;

    _statusLabel = [UILabel getLabelWithAlignment:1 WithTitle:nil WithFont:12.0f WithTextColor:_define_white_color WithSpacing:0];
    [mengban addSubview:_statusLabel];
    _statusLabel.layer.masksToBounds = YES;
    _statusLabel.layer.cornerRadius = 3.0f;
    [_statusLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(90);
        make.height.mas_equalTo(25);
        make.top.mas_equalTo(5);
        make.right.mas_equalTo(-5);
    }];

    _nameLabel = [UILabel getLabelWithAlignment:1 WithTitle:nil WithFont:17.0f WithTextColor:_define_white_color WithSpacing:0];
    [mengban addSubview:_nameLabel];
    _nameLabel.font = [UIFont boldSystemFontOfSize:17.0f];
    [_nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(16);
        make.right.mas_equalTo(-16);
        make.bottom.mas_equalTo(mengban.mas_centerY).with.offset(0);
    }];

    _timeLabel = [UILabel getLabelWithAlignment:1 WithTitle:nil WithFont:13.0f WithTextColor:_define_white_color WithSpacing:0];
    [mengban addSubview:_timeLabel];
    [_timeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(16);
        make.right.mas_equalTo(-16);
        make.top.mas_equalTo(mengban.mas_centerY).with.offset(0);
    }];

}
#pragma mark - SomeAction
-(void)updateUI{
    if(_listItemModel){
        _orderingImageView.hidden = NO;
        sd_downloadWebImageWithRelativePath(NO, _listItemModel.poster, _orderingImageView, kLookBookImage,1);
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
        _orderingImageView.hidden = YES;
    }
}

@end
