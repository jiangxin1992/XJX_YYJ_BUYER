//
//  YYInventorySubmitStyleInfoCell.m
//  YunejianBuyer
//
//  Created by Apple on 16/9/1.
//  Copyright © 2016年 Apple. All rights reserved.
//

#import "YYInventorySubmitStyleInfoCell.h"

@implementation YYInventorySubmitStyleInfoCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}
-(void)updateUI{
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    if(_styleInfoModel && _styleInfoModel.albumImg != nil){
        sd_downloadWebImageWithRelativePath(NO, _styleInfoModel.albumImg, _albumImgView, kSeriesCover, 0);
    }else{
        sd_downloadWebImageWithRelativePath(NO, @"", _albumImgView, kSeriesCover, 0);
    }
    _albumImgView.layer.borderColor = [UIColor colorWithHex:@"efefef"].CGColor;
    _albumImgView.layer.borderWidth = 1;
    _albumImgView.layer.cornerRadius = 2.5;
    _albumImgView.layer.masksToBounds = YES;
    
    _seriesNameLabel.text = _styleInfoModel.seriesName;
    _styleNameLabel.text = _styleInfoModel.styleName;
    _styleCodeLabel.text = _styleInfoModel.styleCode;
}
@end
