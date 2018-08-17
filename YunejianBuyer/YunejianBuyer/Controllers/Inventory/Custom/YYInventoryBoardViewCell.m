//
//  YYInventoryBoardViewCell.m
//  YunejianBuyer
//
//  Created by Apple on 16/9/1.
//  Copyright © 2016年 Apple. All rights reserved.
//

#import "YYInventoryBoardViewCell.h"

#import "YYInventoryStyleSizeInfoView.h"

static NSInteger SizeViewCOnatinerTag = 10000;

@implementation YYInventoryBoardViewCell{
    NSInteger tmpTopMagin;
    NSInteger tmpSizeViewNum;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    _addStoreBtn.hidden = YES;
    _hasStoreBtn.hidden = YES;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

-(void)updateUI{
    
    if([LanguageManager isEnglishLanguage]){
        [_addStoreBtn.titleLabel setFont:[UIFont systemFontOfSize:13.0f]];
        [_hasStoreBtn.titleLabel setFont:[UIFont systemFontOfSize:12.0f]];
    }else{
        [_addStoreBtn.titleLabel setFont:[UIFont systemFontOfSize:15.0f]];
        [_hasStoreBtn.titleLabel setFont:[UIFont systemFontOfSize:14.0f]];
    }
    
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    if(_boardModel && _boardModel.albumImg != nil){
        sd_downloadWebImageWithRelativePath(NO, _boardModel.albumImg, _styleImageView, kStyleCover, 0);
    }else{
        sd_downloadWebImageWithRelativePath(NO, @"", _styleImageView, kStyleCover, 0);
    }
    _styleImageView.layer.borderColor = [UIColor colorWithHex:@"efefef"].CGColor;
    _styleImageView.layer.borderWidth = 1;
    _styleImageView.layer.cornerRadius = 2.5;
    _styleImageView.layer.masksToBounds = YES;
    
    if([_boardModel.hasRead integerValue]){
        _unReadFlagView.hidden = YES;
    }else{
        _unReadFlagView.hidden = NO;
        _unReadFlagView.layer.cornerRadius = 4;
        _unReadFlagView.layer.masksToBounds = YES;
    }
    
    _updateTimerLabel.text = [NSString stringWithFormat:@"%@ %@",NSLocalizedString(@"更新时间",nil),getShowDateByFormatAndTimeInterval(@"yyyy/MM/dd HH:mm",[_boardModel.modified stringValue])];
    _brandNameLabel.text = _boardModel.brandName;
    _styleNameLabel.text = _boardModel.styleName;
    //_hasStoreBtn.userInteractionEnabled = NO;
    if([_boardModel.hasInventory integerValue]){
        _addStoreBtn.hidden = YES;
        _hasStoreBtn.hidden = NO;
        _hasStoreBtn.layer.cornerRadius = 2.5;
        _hasStoreBtn.layer.borderColor = [UIColor colorWithHex:@"d3d3d3"].CGColor;
        _hasStoreBtn.layer.borderWidth = 1;
    }else{
        _addStoreBtn.layer.borderColor = [UIColor blackColor].CGColor;
        _addStoreBtn.layer.borderWidth = 1;
        _addStoreBtn.layer.cornerRadius = 2.5;
        _addStoreBtn.layer.masksToBounds = YES;
        _addStoreBtn.hidden = NO;
        _hasStoreBtn.hidden = YES;
    }
    _colorNameLabel.text = _boardModel.colorName;
    _colorImage.layer.borderColor = [UIColor colorWithHex:@"efefef"].CGColor;
    _colorImage.layer.borderWidth = 1;
    NSString *colorValue = _boardModel.colorValue;
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
    
    tmpSizeViewNum = 0;
    tmpTopMagin = 18;
    NSArray<YYOrderSizeModel> *sizes = _boardModel.sizes;//[_boardModel.sizes sortedArrayUsingDescriptors:@[ [NSSortDescriptor sortDescriptorWithKey:@"sortId" ascending:YES]]];
    if (sizes && [sizes count] > 0) {
        for (int i=0; i<[sizes count]; i++) {
            YYOrderSizeModel *sizeModel = [sizes objectAtIndex:i];
            [self addAlineView:sizeModel andLineIndex:i];
        }
    }
    NSArray *tmpArr = [_sizeLabelContainer subviews];
    NSInteger count = [tmpArr count];
    for (NSInteger i = tmpSizeViewNum; i < count; i++) {
        UIView *sizeInfoView = [_sizeLabelContainer viewWithTag:(SizeViewCOnatinerTag+i)];
        if([sizeInfoView isKindOfClass:[YYInventoryStyleSizeInfoView class]]){
            sizeInfoView.hidden = YES;
            [sizeInfoView removeFromSuperview];
        }
    }
}

- (void)addAlineView:(YYOrderSizeModel *)sizeModel andLineIndex:(int)lineIndex{
    int item_width = SCREEN_WIDTH;
    int item_height = 25;
    int top_magin = 8;
    NSInteger tmpAmount = 0;
    tmpAmount = [sizeModel.amount intValue];

    YYInventoryStyleSizeInfoView *sizeInfoView = [_sizeLabelContainer viewWithTag:(SizeViewCOnatinerTag+tmpSizeViewNum)];
    if(sizeInfoView != nil){
        sizeInfoView.hidden = NO;
        [sizeInfoView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(@(tmpTopMagin));
            make.left.mas_equalTo(@(0));
            make.width.mas_equalTo(item_width);
            make.height.mas_equalTo(@(item_height));
        }];
    }else{
        sizeInfoView = [[YYInventoryStyleSizeInfoView alloc] init];
        sizeInfoView.tag = (SizeViewCOnatinerTag+tmpSizeViewNum);
        [_sizeLabelContainer addSubview:sizeInfoView];
        [sizeInfoView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(@(tmpTopMagin));
            make.left.mas_equalTo(@(0));
            make.width.mas_equalTo(item_width);
            make.height.mas_equalTo(@(item_height));
        }];
    }
    tmpAmount = MAX(0,tmpAmount);
    sizeInfoView.orderSizeModel = sizeModel;
    sizeInfoView.isModifyNow = NO;
    sizeInfoView.indexPath = [NSIndexPath indexPathForRow:0 inSection:lineIndex];
    sizeInfoView.delegate = self;
    [sizeInfoView updateUI];
    
    
    tmpTopMagin += top_magin+item_height;
    tmpSizeViewNum ++;
}
-(void)btnClick:(NSInteger)row section:(NSInteger)section andParmas:(NSArray *)parma{
    if (self.delegate) {
        NSIndexPath *sizeIndexPath = [NSIndexPath indexPathForRow:row inSection:section];
        NSString *num = [parma objectAtIndex:0];
        [self.delegate btnClick:_indexPath.row section:_indexPath.section andParmas:@[@"editStyleNum",sizeIndexPath,num]];
    }
}

- (IBAction)addStoreBtnHandler:(id)sender {
    if (self.delegate) {
        [self.delegate btnClick:_indexPath.row section:_indexPath.section andParmas:@[@"styleStore"]];
    }
}

- (IBAction)showStyleInfo:(id)sender {
    if (self.delegate) {
        [self.delegate btnClick:_indexPath.row section:_indexPath.section andParmas:@[@"styleInfo"]];
    }
}

+(float)cellHeigh:(NSInteger)sizes{
    if(sizes > 1){
        float sizeHeight = (sizes -1)*(25 + 8)+3;
        return 196+sizeHeight;
    }
    return 196;
}

@end
