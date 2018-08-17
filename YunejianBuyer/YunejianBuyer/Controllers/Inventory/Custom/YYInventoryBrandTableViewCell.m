//
//  YYInventoryBrandTableViewCell.m
//  YunejianBuyer
//
//  Created by Apple on 16/9/1.
//  Copyright © 2016年 Apple. All rights reserved.
//

#import "YYInventoryBrandTableViewCell.h"

@implementation YYInventoryBrandTableViewCell

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
    if(_brandInfoModel && _brandInfoModel.logo != nil){
        sd_downloadWebImageWithRelativePath(NO, _brandInfoModel.logo, _logoImageView, kLogoCover, 0);
    }else{
        sd_downloadWebImageWithRelativePath(NO, @"", _logoImageView, kLogoCover, 0);
    }
    _logoImageView.layer.borderColor = [UIColor colorWithHex:@"efefef"].CGColor;
    _logoImageView.layer.borderWidth = 2;
    _logoImageView.layer.cornerRadius = 25;
    _logoImageView.layer.masksToBounds = YES;
//
    _brandNameLabel.text = _brandInfoModel.brandName;
    _emailLabel.text = _brandInfoModel.contactName;
}
@end
