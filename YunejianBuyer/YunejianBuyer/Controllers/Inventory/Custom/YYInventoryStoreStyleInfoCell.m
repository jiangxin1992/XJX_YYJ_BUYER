//
//  YYInventoryStoreStyleInfo.m
//  YunejianBuyer
//
//  Created by Apple on 16/9/2.
//  Copyright © 2016年 Apple. All rights reserved.
//

#import "YYInventoryStoreStyleInfoCell.h"

@implementation YYInventoryStoreStyleInfoCell

-(void)updateUI{
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    if(_boardModel && _boardModel.albumImg != nil){
        sd_downloadWebImageWithRelativePath(NO, _boardModel.albumImg, _albumImgView, kSeriesCover, 0);
    }else{
        sd_downloadWebImageWithRelativePath(NO, @"", _albumImgView, kSeriesCover, 0);
    }
    _albumImgView.layer.borderColor = [UIColor colorWithHex:@"efefef"].CGColor;
    _albumImgView.layer.borderWidth = 1;
    _albumImgView.layer.cornerRadius = 2.5;
    _albumImgView.layer.masksToBounds = YES;
    
    if(_boardModel && _boardModel.brandLogo){
        sd_downloadWebImageWithRelativePath(NO, _boardModel.brandLogo, _logoImgView, kLogoCover, 0);

    }else{
        sd_downloadWebImageWithRelativePath(NO, @"", _logoImgView, kLogoCover, 0);
    }
    _logoImgView.layer.borderColor = [UIColor colorWithHex:@"efefef"].CGColor;
    _logoImgView.layer.borderWidth = 1;
    _logoImgView.layer.cornerRadius = 2.5;
    _logoImgView.layer.masksToBounds = YES;
    
    _brandNameLabel.text = _boardModel.brandName;
    _styleNameLabel.text = _boardModel.styleName;
    _styleCodeLabel.text = _boardModel.styleCode;
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
