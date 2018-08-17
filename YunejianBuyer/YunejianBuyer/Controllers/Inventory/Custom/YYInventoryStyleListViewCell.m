//
//  YYInventoryStyleListViewCell.m
//  YunejianBuyer
//
//  Created by Apple on 16/9/2.
//  Copyright © 2016年 Apple. All rights reserved.
//

#import "YYInventoryStyleListViewCell.h"

#import "YYInventoryStyleSizeInfoView.h"
#import "YYOrderSizeModel.h"

@implementation YYInventoryStyleListViewCell

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
    if(_styleModel && _styleModel.albumImg != nil){
        sd_downloadWebImageWithRelativePath(NO, _styleModel.albumImg, _styleImageView, kStyleCover, 0);
    }else{
        sd_downloadWebImageWithRelativePath(NO, @"", _styleImageView, kStyleCover, 0);
    }
    _styleImageView.layer.borderColor = [UIColor colorWithHex:@"efefef"].CGColor;
    _styleImageView.layer.borderWidth = 1;
    _styleImageView.layer.cornerRadius = 2.5;
    _styleImageView.layer.masksToBounds = YES;
    
    _updateTimerLabel.text = [NSString stringWithFormat:@"%@",getShowDateByFormatAndTimeInterval(@"yyyy/MM/dd HH:mm",[_styleModel.created stringValue])];
    _brandNameLabel.text = _styleModel.brandName;
    _styleNameLabel.text = _styleModel.styleName;

    _colorNameLabel.text = _styleModel.colorName;
    
    _colorImage.layer.borderColor = [UIColor colorWithHex:@"efefef"].CGColor;
    _colorImage.layer.borderWidth = 1;
    NSString *colorValue = _styleModel.colorValue;
    if (colorValue) {
        if ([colorValue hasPrefix:@"#"] && [colorValue length] == 7) {
            //16进制的色值
            UIColor *color = [UIColor colorWithHex:[colorValue substringFromIndex:1]];
            [_colorImage setImage:[UIColor createImageWithColor:color]];
        }else{
            //图片
            NSString *imageRelativePath = colorValue;
            if(imageRelativePath)
                sd_downloadWebImageWithRelativePath(NO, imageRelativePath, _colorImage, kStyleColorImageCover, 0);
        }
    }
    if([_styleModel.status integerValue]){
        _resloveFlagBtn.hidden = NO;
        _deleteBtn.hidden = YES;
        _editBtn.hidden = YES;
        _finishBtn.hidden = YES;
    }else{
        _resloveFlagBtn.hidden = YES;
        if(_isModifyNow){
            _deleteBtn.hidden = YES;
            _editBtn.hidden = YES;
            _finishBtn.hidden = NO;
        }else{
            _deleteBtn.hidden = NO;
            _editBtn.hidden = NO;
            _finishBtn.hidden = YES;
        }
    }

    
    YYOrderSizeModel *sizeModel = [[YYOrderSizeModel alloc] init];
    sizeModel.sizeId = _styleModel.sizeId;
    sizeModel.amount = _styleModel.amount;
    sizeModel.name = _styleModel.sizeName;
    _styleSizeInfoView.orderSizeModel = sizeModel;
    _styleSizeInfoView.isModifyNow = _isModifyNow;
    _styleSizeInfoView.indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
    _styleSizeInfoView.delegate = self;
    [_styleSizeInfoView updateUI];
}

-(void)btnClick:(NSInteger)row section:(NSInteger)section andParmas:(NSArray *)parma{
    if (self.delegate) {
        NSString *num = [parma objectAtIndex:0];
        [self.delegate btnClick:_indexPath.row section:_indexPath.section andParmas:@[@"editStyleNum",num]];
    }
}

- (IBAction)editBtnHandler:(id)sender {
    if (self.delegate) {
        [self.delegate btnClick:_indexPath.row section:_indexPath.section andParmas:@[@"editStatus",@""]];
    }
}
- (IBAction)finishBtnHandler:(id)sender {
    if (self.delegate) {
        [self.delegate btnClick:_indexPath.row section:_indexPath.section andParmas:@[@"editStatus",@"update"]];
    }
}

- (IBAction)deleteBtnHandler:(id)sender {
    
    if (self.delegate) {
        [self.delegate btnClick:_indexPath.row section:_indexPath.section andParmas:@[@"deleteStyle"]];
    }
}

@end
