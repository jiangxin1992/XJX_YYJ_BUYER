//
//  YYSeriesListViewCell.m
//  Yunejian
//
//  Created by Apple on 15/12/4.
//  Copyright © 2015年 yyj. All rights reserved.
//

#import "YYSeriesListViewCell.h"

@implementation YYSeriesListViewCell
-(void)updateUI{
    self.layer.cornerRadius = 5;
    _coverImageView.layer.cornerRadius = 5;
    _coverImageView.layer.masksToBounds = YES;
    if (_seriesModel != nil) {
        _nameLabel.text = _seriesModel.name;
        _styleAmountLabel.text = [NSString stringWithFormat:NSLocalizedString(@"%@ 款",nil),[_seriesModel.styleAmount stringValue]];
        //_seasonLabel.text = [NSString stringWithFormat:@"Season:%@",_seriesModel.season];
        //_supplyTimeLabel.text = [NSString stringWithFormat:@"发货日期:%@-%@",getShowDateByFormatAndTimeInterval(@"yyyy/MM/dd",[_seriesModel.supplyStartTime stringValue]),getShowDateByFormatAndTimeInterval(@"yyyy/MM/dd",[_seriesModel.supplyEndTime stringValue])];
        _orderDueTimeLabel.text = [NSString stringWithFormat:NSLocalizedString(@"最晚下单：%@",nil),getShowDateByFormatAndTimeInterval(@"yyyy/MM/dd",_seriesModel.orderDueTime)];
        _coverImageView.contentMode = UIViewContentModeScaleAspectFit;
        sd_downloadWebImageWithRelativePath(YES, _seriesModel.albumImg, _coverImageView, kStyleCover, UIViewContentModeScaleAspectFit);
    }else{
        _nameLabel.text = @"";
        _styleAmountLabel.text = [NSString stringWithFormat:NSLocalizedString(@"%@ 款",nil),@"0"];
        //_seasonLabel.text = [NSString stringWithFormat:@"Season:%@",@""];
        //_supplyTimeLabel.text = [NSString stringWithFormat:@"发货日期:%@-%@",@"",@""];
        _orderDueTimeLabel.text = [NSString stringWithFormat:NSLocalizedString(@"最晚下单：%@",nil),@""];
//        sd_downloadWebImageWithRelativePath(NO, @"", _coverImageView, kStyleCover, 0);
        sd_downloadWebImageWithRelativePath(YES, @"", _coverImageView, kStyleCover,UIViewContentModeScaleAspectFit);
    }
}
@end
