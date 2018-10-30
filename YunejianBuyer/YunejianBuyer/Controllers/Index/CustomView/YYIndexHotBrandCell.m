//
//  YYIndexHotBrandCell.m
//  YunejianBuyer
//
//  Created by yyj on 2017/11/7.
//  Copyright © 2017年 Apple. All rights reserved.
//

#import "YYIndexHotBrandCell.h"

// c文件 —> 系统文件（c文件在前）

// 控制器

// 自定义视图
#import "SCGIFButtonView.h"
#import "SCGIFImageView.h"

// 接口

// 分类
#import "UIImage+Tint.h"

// 自定义类和三方类（ cocoapods类 > model > 工具类 > 其他）
#import <YYText.h>
#import <SDWebImageManager.h>

#import "YYHotDesignerBrandsModel.h"

@interface YYIndexHotBrandCell()

@property (nonatomic,strong) UIView *backCardView;

@property (nonatomic,strong) SCGIFButtonView *leftSeriesBtn;
@property (nonatomic,strong) SCGIFButtonView *rightSeriesBtn;
@property (nonatomic,strong) SCGIFButtonView *oneSeriesBtn;

@property (nonatomic,strong) UIButton *brandView;
@property (nonatomic,strong) SCGIFImageView *iconImg;
@property (nonatomic,strong) UILabel *brandNameLabel;
@property (nonatomic,strong) UILabel *brandIntroduceLabel;
//@property (nonatomic,strong) UILabel *brandDesLabel;
@property (nonatomic,strong) YYLabel *brandDesLabel;

@property (nonatomic,strong) UIButton *connectStatusBtn;

@property (nonatomic,assign) BOOL isNoSeries;

@property (nonatomic,strong) UIButton *moreBrandButton;

@property(nonatomic,copy) void (^hotBrandCellBlock)(NSString *type,YYHotDesignerBrandsModel *hotDesignerBrandsModel,YYHotDesignerBrandsSeriesModel *seriesModel);

@end

@implementation YYIndexHotBrandCell

#pragma mark - --------------生命周期--------------
-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier WithBlock:(void(^)(NSString *type,YYHotDesignerBrandsModel *hotDesignerBrandsModel,YYHotDesignerBrandsSeriesModel *seriesModel))block{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if(self){
        _hotBrandCellBlock = block;
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
- (void)PrepareData{
    _leftSeriesBtn = [[SCGIFButtonView alloc] init];
    [_leftSeriesBtn setAdjustsImageWhenHighlighted:NO];
    _rightSeriesBtn = [[SCGIFButtonView alloc] init];
    [_rightSeriesBtn setAdjustsImageWhenHighlighted:NO];

    _brandNameLabel = [UILabel getLabelWithAlignment:0 WithTitle:nil WithFont:13.0f WithTextColor:nil WithSpacing:0];
    _brandIntroduceLabel = [UILabel getLabelWithAlignment:0 WithTitle:nil WithFont:10.0f WithTextColor:[UIColor colorWithHex:@"919191"] WithSpacing:0];

    _isNoSeries = NO;
}
- (void)PrepareUI{}

#pragma mark - --------------UIConfig----------------------
-(void)UIConfig{
    _backCardView = [UIView getCustomViewWithColor:nil];
    [self.contentView addSubview:_backCardView];
    [_backCardView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(0);
        make.left.mas_equalTo(13);
        make.right.mas_equalTo(-13);
        make.bottom.mas_equalTo(-20);
    }];
    setBorderCustom(_backCardView, 1, [UIColor colorWithHex:@"EFEFEF"]);
    _backCardView.layer.cornerRadius = 3.0f;

    NSArray *tempArr = @[_leftSeriesBtn,_rightSeriesBtn];
    UIView *lastView = nil;
    for (int i = 0; i < tempArr.count; i++) {
        SCGIFButtonView *tempBtn = tempArr[i];
        [_backCardView addSubview:tempBtn];
        [tempBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.height.mas_equalTo(192);
            make.top.mas_equalTo(10);
            if(lastView){
                make.left.mas_equalTo(lastView.mas_right).with.offset(8);
                make.width.mas_equalTo(lastView);
                make.right.mas_equalTo(-10);
            }else{
                make.left.mas_equalTo(10);
            }
        }];
        tempBtn.tag = 100 + i;
        tempBtn.clipsToBounds = YES;
        tempBtn.contentMode = UIViewContentModeScaleAspectFill;
        [tempBtn addTarget:self action:@selector(seriesClick:) forControlEvents:UIControlEventTouchUpInside];
        lastView = tempBtn;
    }
    
    _oneSeriesBtn = [[SCGIFButtonView alloc] init];
    [_backCardView addSubview:_oneSeriesBtn];
    [_oneSeriesBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(10);
        make.right.mas_equalTo(-10);
        make.height.mas_equalTo(192);
        make.top.mas_equalTo(10);
    }];
    [_oneSeriesBtn setAdjustsImageWhenHighlighted:NO];
    _oneSeriesBtn.tag = 99;
    _oneSeriesBtn.clipsToBounds = YES;
    _oneSeriesBtn.contentMode = UIViewContentModeScaleAspectFill;
    [_oneSeriesBtn addTarget:self action:@selector(seriesClick:) forControlEvents:UIControlEventTouchUpInside];

    _brandView = [UIButton getCustomBtn];
    [_backCardView addSubview:_brandView];
    [_brandView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.bottom.mas_equalTo(0);
        make.top.mas_equalTo(207);
    }];

    [_brandView addTarget:self action:@selector(brandViewClick) forControlEvents:UIControlEventTouchUpInside];

    _iconImg = [[SCGIFImageView alloc] init];
    [_brandView addSubview:_iconImg];
    [_iconImg mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(10);
        make.top.mas_equalTo(5);
        make.width.height.mas_equalTo(34);
    }];
    _iconImg.contentMode = UIViewContentModeScaleAspectFit;
    _iconImg.layer.masksToBounds = YES;
    _iconImg.layer.borderColor = [[UIColor colorWithHex:@"EFEFEF"] CGColor];
    _iconImg.layer.borderWidth = 1;
    _iconImg.layer.cornerRadius = 17;

    _connectStatusBtn = [UIButton getCustomBtn];
    [_brandView addSubview:_connectStatusBtn];
    [_connectStatusBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.top.mas_equalTo(0);
        make.width.height.mas_equalTo(44);
    }];
    _connectStatusBtn.userInteractionEnabled = YES;
    [_connectStatusBtn addTarget:self action:@selector(connectStatusClick) forControlEvents:UIControlEventTouchUpInside];

    NSArray *tempLabelArr = @[_brandNameLabel,_brandIntroduceLabel];
    UIView *lastLabelView = nil;
    for (UILabel *label in tempLabelArr) {
        [_brandView addSubview:label];
        [label mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(_iconImg.mas_right).with.offset(10);
            make.right.mas_equalTo(_connectStatusBtn.mas_left).with.offset(-5);
            if(lastLabelView){
                make.top.mas_equalTo(_iconImg.mas_centerY).with.offset(0.5);
            }else{
                make.bottom.mas_equalTo(_iconImg.mas_centerY).with.offset(-0.5);
            }
        }];
        lastLabelView = label;
    }

//    _brandDesLabel = [UILabel getLabelWithAlignment:0 WithTitle:nil WithFont:11 WithTextColor:[UIColor colorWithHex:@"919191"] WithSpacing:0];
    _brandDesLabel = [[YYLabel alloc] init];
    _brandDesLabel.textAlignment = 0;
    _brandDesLabel.font = getFont(11.0f);
    _brandDesLabel.textColor = [UIColor colorWithHex:@"919191"];
    _brandDesLabel.numberOfLines = 0;
    [_brandView addSubview:_brandDesLabel];
    [_brandDesLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(10);
        make.right.mas_equalTo(-10);
        make.bottom.mas_equalTo(0);
        make.top.mas_equalTo(_iconImg.mas_bottom).with.offset(10);
    }];
    _brandDesLabel.numberOfLines = 2;

    _moreBrandButton = [UIButton getCustomBtn];
    [self.contentView addSubview:_moreBrandButton];
    [_moreBrandButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.bottom.mas_equalTo(0);
        make.top.mas_equalTo(_backCardView.mas_bottom).with.offset(0);
    }];
    [_moreBrandButton addTarget:self action:@selector(moreBrandAction) forControlEvents:UIControlEventTouchUpInside];

    UIView *tempView = [UIView getCustomViewWithColor:nil];
    [_moreBrandButton addSubview:tempView];
    [tempView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.bottom.mas_equalTo(0);
        make.centerX.mas_equalTo(_moreBrandButton);
    }];
    tempView.userInteractionEnabled = NO;

    UILabel *moreTitleLabel = [UILabel getLabelWithAlignment:2 WithTitle:NSLocalizedString(@"更多品牌",nil) WithFont:11.0f WithTextColor:[UIColor colorWithHex:@"919191"] WithSpacing:0];
    [tempView addSubview:moreTitleLabel];
    [moreTitleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.bottom.mas_equalTo(0);
        make.left.mas_equalTo(0);
    }];

    UIImageView *moreImg = [UIImageView getCustomImg];
    [tempView addSubview:moreImg];
    [moreImg mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(moreTitleLabel.mas_right).with.offset(5);
        make.centerY.mas_equalTo(0);
        make.right.mas_equalTo(0);
        make.width.mas_equalTo(5);
        make.height.mas_equalTo(10);
    }];
    moreImg.image = [[UIImage imageNamed:@"right_arrow_big_icon"] imageWithTintColor:[UIColor colorWithHex:@"919191"]];
    moreImg.contentMode = UIViewContentModeScaleToFill;
}

//#pragma mark - --------------请求数据----------------------
//-(void)RequestData{}

#pragma mark - --------------自定义响应----------------------
-(void)moreBrandAction{
    if(_hotBrandCellBlock){
        _hotBrandCellBlock(@"more_brand",nil,nil);
    }
}
-(void)brandViewClick{
    if(_hotBrandCellBlock){
        _hotBrandCellBlock(@"enter_brand",_hotDesignerBrandsModel,nil);
    }
}
-(void)seriesClick:(SCGIFButtonView *)button{
    if(_hotBrandCellBlock){
        NSInteger nowIndex = 0;
        if(button.tag < 100){
            nowIndex = 0;
        }else{
            nowIndex = button.tag - 100;
        }
        YYHotDesignerBrandsSeriesModel *seriesModel = _hotDesignerBrandsModel.seriesBoList[nowIndex];
        _hotBrandCellBlock(@"enter_series",_hotDesignerBrandsModel,seriesModel);
    }
}
-(void)connectStatusClick{
    if(_hotBrandCellBlock){
        _hotBrandCellBlock(@"change_status",_hotDesignerBrandsModel,nil);
    }
}

#pragma mark - --------------自定义方法----------------------
-(void)updateUI{
    NSLog(@"111");

    _moreBrandButton.hidden = !_isLastCell;

    [_backCardView mas_updateConstraints:^(MASConstraintMaker *make) {
        if(_isLastCell){
            make.bottom.mas_equalTo(-55);
        }else{
            make.bottom.mas_equalTo(-20);
        }
    }];

    CURRENTTIME
    NSInteger seriesBoListNum = [_hotDesignerBrandsModel.seriesBoListNum integerValue];
    if(seriesBoListNum == 0){
        //为空
        _leftSeriesBtn.hidden = YES;
        _rightSeriesBtn.hidden = YES;
        _oneSeriesBtn.hidden = YES;
    }else{
        //不为空
        if(seriesBoListNum < 2){
            _leftSeriesBtn.hidden = YES;
            _rightSeriesBtn.hidden = YES;
            _oneSeriesBtn.hidden = NO;
        }else{
            _leftSeriesBtn.hidden = NO;
            _rightSeriesBtn.hidden = NO;
            _oneSeriesBtn.hidden = YES;
        }
    }

    if(!_leftSeriesBtn.hidden){
        YYHotDesignerBrandsSeriesModel *leftSeriesModel = _hotDesignerBrandsModel.seriesBoList[0];
        sd_downloadWebImageWithRelativePath(YES, leftSeriesModel.albumImg, _leftSeriesBtn, kLookBookCover,UIViewContentModeScaleAspectFill);
    }
    if(!_rightSeriesBtn.hidden){
        YYHotDesignerBrandsSeriesModel *rightSeriesModel = _hotDesignerBrandsModel.seriesBoList[1];
        sd_downloadWebImageWithRelativePath(YES, rightSeriesModel.albumImg, _rightSeriesBtn, kLookBookCover,UIViewContentModeScaleAspectFill);
    }
    if(!_oneSeriesBtn.hidden){
        YYHotDesignerBrandsSeriesModel *oneSeriesModel = _hotDesignerBrandsModel.seriesBoList[0];
        sd_downloadWebImageWithRelativePath(YES, oneSeriesModel.albumImg, _oneSeriesBtn, kBuyerCardImage,UIViewContentModeScaleAspectFill);
    }

    if(_leftSeriesBtn.hidden && _rightSeriesBtn.hidden && _oneSeriesBtn.hidden){
        if(!_isNoSeries){
            [_brandView mas_updateConstraints:^(MASConstraintMaker *make) {
                make.left.right.bottom.mas_equalTo(0);
                make.top.mas_equalTo(5);
            }];
            _isNoSeries = YES;
        }
    }else{
        if(_isNoSeries){
            [_brandView mas_updateConstraints:^(MASConstraintMaker *make) {
                make.left.right.bottom.mas_equalTo(0);
                make.top.mas_equalTo(207);
            }];
            _isNoSeries = NO;
        }
    }

    // 异步执行任务创建方法
    sd_downloadWebImageWithRelativePath(NO, _hotDesignerBrandsModel.logo, _iconImg, kLogoCover,UIViewContentModeScaleAspectFit);

    _brandNameLabel.text = _hotDesignerBrandsModel.brandName;
    
    _brandIntroduceLabel.text = [[NSString alloc] initWithFormat: NSLocalizedString(@"%ld 个系列  %ld 个款式",nil),[_hotDesignerBrandsModel.seriesCount integerValue],[_hotDesignerBrandsModel.styleCount integerValue]];

    //关系类型 -1 没有关系  0 我已发送邀请，对方未处理  1 已为好友   2 对方已发出邀请，我未处理
    NSString *connedImg = @"brandadd_icon";
    _connectStatusBtn.userInteractionEnabled = YES;
    NSInteger connectStatus = [_hotDesignerBrandsModel.connectStatus integerValue];
    if(connectStatus == YYUserConnStatusInvite || connectStatus == YYUserConnStatusBeInvited){
        connedImg = @"brandwait_icon";
        _connectStatusBtn.userInteractionEnabled = NO;
    }else if(connectStatus == YYUserConnStatusConnected){
        connedImg = @"conn_cancel_green_icon";
        _connectStatusBtn.userInteractionEnabled = NO;
    }
    [_connectStatusBtn setImage:[UIImage imageNamed:connedImg] forState:UIControlStateNormal];


    NSString *imageUrl = @"https://attachments.tower.im/tower/4ee4779076864896adf3fcceb9572938/?filename=image.png";
    if([NSString isNilOrEmpty:imageUrl]){
        [self updateBrandDesLabelInfo:nil];
    }else{
        SDWebImageManager *manager = [SDWebImageManager sharedManager];
        [manager loadImageWithURL:[NSURL URLWithString:imageUrl] options:SDWebImageRetryFailed|SDWebImageLowPriority progress:nil completed:^(UIImage * _Nullable image, NSData * _Nullable data, NSError * _Nullable error, SDImageCacheType cacheType, BOOL finished, NSURL * _Nullable imageURL) {
            [self updateBrandDesLabelInfo:image];
        }];
    }

    DIFFTIME
    NSLog(@"111");
}
-(void)updateBrandDesLabelInfo:(UIImage *)image{
    NSMutableAttributedString *text = [NSMutableAttributedString new];

    if(image){
        // 嵌入 UIImage
        NSMutableAttributedString *image_attachment = [NSMutableAttributedString yy_attachmentStringWithContent:image contentMode:UIViewContentModeLeft attachmentSize:image.size alignToFont:getFont(11.0f) alignment:YYTextVerticalAlignmentCenter];
        [text appendAttributedString: image_attachment];

    }
    NSMutableAttributedString *des_attachment = [[NSMutableAttributedString alloc] initWithString:_hotDesignerBrandsModel.brandDescription];
    [text appendAttributedString: des_attachment];
    _brandDesLabel.attributedText = text;
    //    _brandDesLabel.text = _hotDesignerBrandsModel.brandDescription;
}
#pragma mark - --------------other----------------------
- (void)awakeFromNib {
    [super awakeFromNib];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}

@end
