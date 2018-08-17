//
//  YYBrandInfoCell.m
//  YunejianBuyer
//
//  Created by yyj on 2017/4/7.
//  Copyright © 2017年 Apple. All rights reserved.
//

#import "YYBrandInfoCell.h"

#import "SCGIFImageView.h"
#import "UIImageView+CornerRadius.h"

@interface YYBrandInfoCell()

@property (nonatomic,strong) SCGIFImageView *brandImg;

@property (nonatomic,strong) SCGIFImageView *brandICON;
@property (nonatomic,strong) UILabel *brandNameLabel;
@property (nonatomic,strong) UILabel *designerNameLabel;
@property (nonatomic,strong) UIButton *addBtn;
@property (nonatomic,strong) UILabel *brandDescriptionLabel;

@end

@implementation YYBrandInfoCell

- (instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if(self){
        self.contentView.backgroundColor = _define_white_color;
        
        _brandImg = [[SCGIFImageView alloc] init];
        [self.contentView addSubview:_brandImg];
        _brandImg.userInteractionEnabled = YES;
        _brandImg.backgroundColor = [UIColor colorWithHex:@"F8F8F8"];
        [_brandImg mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.right.top.mas_equalTo(0);
            make.height.mas_equalTo(284);
        }];
        _brandImg.contentMode = UIViewContentModeScaleAspectFit;
        
        UIView *_imageBottomView = [UIView getCustomViewWithColor:[_define_white_color colorWithAlphaComponent:0.9]];
        [_brandImg addSubview:_imageBottomView];
        [_imageBottomView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.right.bottom.mas_equalTo(0);
            make.height.mas_equalTo(68);
        }];
        
        _brandICON = [[SCGIFImageView alloc] init];
        [_imageBottomView addSubview:_brandICON];
        _brandICON.backgroundColor = _define_white_color;
        [_brandICON mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(17);
            make.centerY.mas_equalTo(_imageBottomView);
            make.width.height.mas_equalTo(50);
        }];
        _brandICON.contentMode = UIViewContentModeScaleAspectFit;
        setBorderCustom(_brandICON, 2, [UIColor colorWithHex:@"F8F8F8"]);
        _brandICON.layer.cornerRadius = 25;
        
        _brandNameLabel = [UILabel getLabelWithAlignment:0 WithTitle:nil WithFont:14.0f WithTextColor:nil WithSpacing:0];
        [_imageBottomView addSubview:_brandNameLabel];
        [_brandNameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(_brandICON.mas_right).with.offset(8);
            make.bottom.mas_equalTo(_brandICON.mas_centerY).with.offset(0);
            make.right.mas_equalTo(-70);
        }];
        
        _designerNameLabel = [UILabel getLabelWithAlignment:0 WithTitle:nil WithFont:13.0f WithTextColor:[UIColor colorWithHex:@"919191"] WithSpacing:0];
        [_imageBottomView addSubview:_designerNameLabel];
        [_designerNameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(_brandICON.mas_right).with.offset(8);
            make.top.mas_equalTo(_brandICON.mas_centerY).with.offset(0);
            make.right.mas_equalTo(-70);
        }];
        
        _addBtn = [UIButton getCustomImgBtnWithImageStr:@"conn_invite_icon" WithSelectedImageStr:@"conn_inviteing_icon"];
        [_imageBottomView addSubview:_addBtn];
        [_addBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.mas_equalTo(_imageBottomView);
            make.right.mas_equalTo(0);
            make.width.mas_equalTo(70);
            make.height.mas_equalTo(45);
        }];
        _addBtn.selected = NO;
        [_addBtn addTarget:self action:@selector(addBtnHandler) forControlEvents:UIControlEventTouchUpInside];
        
        UIView *_bottomView = [UIView getCustomViewWithColor:_define_white_color];
        [self.contentView addSubview:_bottomView];
        [_bottomView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.right.mas_equalTo(0);
            make.top.mas_equalTo(_brandImg.mas_bottom).with.offset(0);
            make.height.mas_equalTo(80);
        }];
        
        _brandDescriptionLabel = [UILabel getLabelWithAlignment:0 WithTitle:nil WithFont:13.0f WithTextColor:[UIColor colorWithHex:@"919191"] WithSpacing:0];
        [_bottomView addSubview:_brandDescriptionLabel];
        _brandDescriptionLabel.numberOfLines = 0;
        [_brandDescriptionLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(17);
            make.right.mas_equalTo(-17);
            make.top.mas_equalTo(8);
            make.bottom.mas_equalTo(-8);
        }];
    }
    return self;
}
-(void)updateUI{
    if(_designerModel){
        
        sd_downloadWebImageWithRelativePath(NO, _designerModel.logo, _brandICON, kLogoCover, 0);
        
        NSString *imageStr = @"";
        if(_designerModel.indexPicList){
            if(_designerModel.indexPicList.count){
                if(![NSString isNilOrEmpty:_designerModel.indexPicList[0]]){
                    imageStr = _designerModel.indexPicList[0];
                }
            }
        }
        
        sd_downloadWebImageWithRelativePath(YES, imageStr, _brandImg, kBuyerCardImage, UIViewContentModeScaleAspectFit);
        
        _brandNameLabel.text = _designerModel.brandName;
        _designerNameLabel.text = _designerModel.designerName;
        if([_designerModel.connectStatus integerValue] == kConnStatus){
            _addBtn.selected = NO;
        }else{
            _addBtn.selected = YES;
        }
        _brandDescriptionLabel.text = _designerModel.brandDescription;
    }else{
        sd_downloadWebImageWithRelativePath(NO, @"", _brandICON, kLogoCover, 0);
        sd_downloadWebImageWithRelativePath(YES, @"", _brandImg, kBuyerCardImage, UIViewContentModeScaleAspectFit);
        _brandNameLabel.text = @"";
        _designerNameLabel.text = @"";
        _addBtn.selected = NO;
        _brandDescriptionLabel.text = @"";
    }
}
- (void)addBtnHandler{
    if(self.delegate){
        [self.delegate btnClick:_indexPath.row section:_indexPath.section andParmas:@[]];
    }
}
//-(void)setDesignerModel:(YYConnDesignerModel *)designerModel{
//    _designerModel=designerModel;
//    if(_designerModel){
//
//        sd_downloadWebImageWithRelativePath(NO, _designerModel.logo, _brandICON, kLogoCover, 0);
//
//        NSString *imageStr = @"";
//        if(_designerModel.indexPicList){
//            if(_designerModel.indexPicList.count){
//                if(![NSString isNilOrEmpty:_designerModel.indexPicList[0]]){
//                    imageStr = _designerModel.indexPicList[0];
//                }
//            }
//        }
//        if(![NSString isNilOrEmpty:imageStr]){
//            sd_downloadWebImageWithRelativePath(YES, imageStr, _brandImg, kStyleDetailCover, UIViewContentModeScaleAspectFit);
//        }else{
//            sd_downloadWebImageWithRelativePath(YES, @"", _brandImg, kStyleDetailCover,UIViewContentModeScaleAspectFit);
//        }
//
//        _brandNameLabel.text = _designerModel.brandName;
//        _designerNameLabel.text = _designerModel.designerName;
//        if([_designerModel.connectStatus integerValue] == kConnStatus){
//            _addBtn.selected = NO;
//        }else{
//            _addBtn.selected = YES;
//        }
//        _brandDescriptionLabel.text = designerModel.brandDescription;
//    }else{
//        sd_downloadWebImageWithRelativePath(NO, @"", _brandICON, kLogoCover, 0);
//        sd_downloadWebImageWithRelativePath(YES, @"", _brandImg, kStyleDetailCover, UIViewContentModeScaleAspectFit);
//        _brandNameLabel.text = @"";
//        _designerNameLabel.text = @"";
//        _addBtn.selected = NO;
//        _brandDescriptionLabel.text = @"";
//    }
//}
@end
