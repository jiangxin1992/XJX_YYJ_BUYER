//
//  YYDetailContentBrandViewCell.m
//  YunejianBuyer
//
//  Created by yyj on 2017/7/12.
//  Copyright © 2017年 Apple. All rights reserved.
//

#import "YYDetailContentBrandViewCell.h"

#import "regular.h"
#import "SCGIFImageView.h"

#import "SCGIFImageView.h"
#import "YYStyleInfoModel.h"

@interface YYDetailContentBrandViewCell ()

@property (nonatomic,strong) UIView *headView;
@property (nonatomic,strong) UIButton *contentDetailView;

@property (nonatomic,strong) SCGIFImageView *brandIcon;
@property (nonatomic,strong) UILabel *brandNameLabel;
@property (nonatomic,strong) UILabel *designerNameLabel;
@property (nonatomic,strong) UILabel *brandDesLabel;

@end

@implementation YYDetailContentBrandViewCell
#pragma mark - INIT
-(id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier WithBlock:(void(^)(NSString *type))block
{
    self=[super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if(self)
    {
        _block = block;
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
    self.backgroundColor = _define_white_color;
}
#pragma mark - UIConfig
-(void)UIConfig{
    [self CreateHeadView];
    [self CreateContentView];
}
-(void)CreateHeadView{
    _headView = [UIView getCustomViewWithColor:nil];
    [self.contentView addSubview:_headView];
    [_headView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.top.mas_equalTo(0);
        make.height.mas_equalTo(46);
    }];
    
    UIView *lineView = [UIView getCustomViewWithColor:[UIColor colorWithHex:@"EFEFEF"]];
    [_headView addSubview:lineView];
    [lineView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.bottom.mas_equalTo(0);
        make.height.mas_equalTo(1);
    }];
    
    UILabel *titleLabel = [UILabel getLabelWithAlignment:0 WithTitle:NSLocalizedString(@"品牌",nil) WithFont:15.0f WithTextColor:nil WithSpacing:0];
    [_headView addSubview:titleLabel];
    [titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(_headView);
        make.bottom.mas_equalTo(lineView.mas_top).with.offset(0);
        make.top.mas_equalTo(0);
    }];
}
-(void)CreateContentView{
    _contentDetailView = [UIButton getCustomBtn];
    [self.contentView addSubview:_contentDetailView];
    [_contentDetailView addTarget:self action:@selector(enterDesigner) forControlEvents:UIControlEventTouchUpInside];
    [_contentDetailView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.mas_equalTo(0);
        make.top.mas_equalTo(_headView.mas_bottom).with.offset(0);
        make.bottom.mas_equalTo(0);
    }];
    
    _brandIcon = [[SCGIFImageView alloc] init];
    [_contentDetailView addSubview:_brandIcon];
    _brandIcon.contentMode = UIViewContentModeScaleAspectFit;
    setBorderCustom(_brandIcon, 1, [UIColor colorWithHex:@"EFEFEF"]);
    _brandIcon.layer.cornerRadius = 25.0f;
    [_brandIcon mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(20);
        make.left.mas_equalTo(17);
        make.height.width.mas_equalTo(50);
    }];
    
    _brandNameLabel = [UILabel getLabelWithAlignment:0 WithTitle:nil WithFont:14.0f WithTextColor:nil WithSpacing:0];
    [_contentDetailView addSubview:_brandNameLabel];
    [_brandNameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(_brandIcon.mas_right).with.offset(13);
        make.right.mas_equalTo(0);
        make.bottom.mas_equalTo(_brandIcon.mas_centerY).with.offset(-2);
    }];
    
    _designerNameLabel = [UILabel getLabelWithAlignment:0 WithTitle:nil WithFont:13.0f WithTextColor:[UIColor colorWithHex:@"919191"] WithSpacing:0];
    [_contentDetailView addSubview:_designerNameLabel];
    [_designerNameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(_brandIcon.mas_right).with.offset(13);
        make.right.mas_equalTo(0);
        make.top.mas_equalTo(_brandIcon.mas_centerY).with.offset(2);
    }];
    
    _brandDesLabel = [UILabel getLabelWithAlignment:0 WithTitle:nil WithFont:13.0f WithTextColor:nil WithSpacing:0];
    [_contentDetailView addSubview:_brandDesLabel];
    _brandDesLabel.numberOfLines = 2;
    [_brandDesLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(17);
        make.right.mas_equalTo(-17);
        make.top.mas_equalTo(_brandIcon.mas_bottom).with.offset(18);
    }];
    
    UIView *doneView = [UIView getCustomViewWithColor:[UIColor colorWithHex:@"f8f8f8"]];
    [_contentDetailView addSubview:doneView];
    [doneView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.left.bottom.mas_equalTo(0);
        make.height.mas_equalTo(10);
    }];
    
    UIView *lineView = [UIView getCustomViewWithColor:[UIColor colorWithHex:@"EFEFEF"]];
    [_contentDetailView addSubview:lineView];
    [lineView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.left.mas_equalTo(0);
        make.height.mas_equalTo(1);
        make.bottom.mas_equalTo(doneView.mas_top).with.offset(0);
    }];
}
-(void)enterDesigner{
    if(_block){
        _block(@"enter_designer");
    }
}
#pragma mark - updateUI
-(void)updateUI{
    if(_headView){
        if(_styleInfoModel){
            sd_downloadWebImageWithRelativePath(NO, _styleInfoModel.style.designerBrandLogo, _brandIcon, kLogoCover, 0);
            _brandNameLabel.text = _styleInfoModel.style.designerBrandName;
            _designerNameLabel.text = _styleInfoModel.style.designerName;
            _brandDesLabel.text = _styleInfoModel.style.brandDescription;
        }else{
            sd_downloadWebImageWithRelativePath(NO, @"", _brandIcon, kLogoCover, 0);
            _brandNameLabel.text = @"";
            _designerNameLabel.text = @"";
            _brandDesLabel.text = @"";
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
