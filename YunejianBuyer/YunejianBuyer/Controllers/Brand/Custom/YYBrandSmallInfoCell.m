//
//  YYBrandSmallInfoCell.m
//  YunejianBuyer
//
//  Created by yyj on 2017/4/12.
//  Copyright © 2017年 Apple. All rights reserved.
//

#import "YYBrandSmallInfoCell.h"

#import "SCGIFImageView.h"
#import "UIImageView+CornerRadius.h"

@interface YYBrandSmallInfoCell()

@property (nonatomic,strong) SCGIFImageView *brandImg;
@property (nonatomic,strong) SCGIFImageView *brandICON;
@property (nonatomic,strong) UILabel *brandNameLabel;

@end

@implementation YYBrandSmallInfoCell

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
        [_brandImg mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.top.mas_equalTo(5);
            make.right.mas_equalTo(-5);
            make.height.mas_equalTo(160);
        }];
        _brandImg.contentMode = UIViewContentModeScaleAspectFit;
        _brandImg.layer.masksToBounds = YES;
        _brandImg.layer.cornerRadius = 3;
        
        
        _brandICON = [[SCGIFImageView alloc] init];
        [_backView addSubview:_brandICON];
        _brandICON.backgroundColor = _define_white_color;
        [_brandICON mas_makeConstraints:^(MASConstraintMaker *make) {
//            make.top.mas_equalTo(129);
            make.centerX.mas_equalTo(_backView);
            make.centerY.mas_equalTo(_brandImg.mas_bottom).with.offset(0);
            make.width.height.mas_equalTo(60);
        }];
        _brandICON.contentMode = UIViewContentModeScaleAspectFit;
        setBorderCustom(_brandICON, 2, [UIColor colorWithHex:@"F8F8F8"]);
        _brandICON.layer.cornerRadius = 30;
        
        _brandNameLabel = [UILabel getLabelWithAlignment:1 WithTitle:nil WithFont:13.0f WithTextColor:nil WithSpacing:0];
        [_backView addSubview:_brandNameLabel];
        _brandNameLabel.adjustsFontSizeToFitWidth = YES;
        [_brandNameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(5);
            make.right.mas_equalTo(-5);
            make.top.mas_equalTo(200);
        }];
        
    }
    return self;
}
//-(void)setDesignerModel:(YYConnDesignerModel *)designerModel{
//    _designerModel=designerModel;
//    if(_designerModel){
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
//            sd_downloadWebImageWithRelativePath(YES, @"", _brandImg, kStyleDetailCover, UIViewContentModeScaleAspectFit);
//        }
//        _brandNameLabel.text = [[NSString alloc] initWithFormat:@"%@/%@",_designerModel.brandName,_designerModel.designerName];
//    }else{
//        sd_downloadWebImageWithRelativePath(NO, @"", _brandICON, kLogoCover, 0);
//        sd_downloadWebImageWithRelativePath(YES, @"", _brandImg, kStyleDetailCover, UIViewContentModeScaleAspectFit);
//        _brandNameLabel.text = @"";
//    }
//}
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
        
        _brandNameLabel.text = [[NSString alloc] initWithFormat:@"%@/%@",_designerModel.brandName,_designerModel.designerName];
    }else{
        sd_downloadWebImageWithRelativePath(NO, @"", _brandICON, kLogoCover, 0);
        sd_downloadWebImageWithRelativePath(YES, @"", _brandImg, kBuyerCardImage, UIViewContentModeScaleAspectFit);
        _brandNameLabel.text = @"";
    }
}
@end

