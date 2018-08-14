//
//  YYLatestSeriesCardCell.h
//  YunejianBuyer
//
//  Created by yyj on 2017/8/8.
//  Copyright © 2017年 Apple. All rights reserved.
//

#import <UIKit/UIKit.h>

@class YYLatestSeriesModel;

@interface YYLatestSeriesCardCell : UITableViewCell

-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier WithBlock:(void(^)(NSString *type,YYLatestSeriesModel *latestSeriesModel))block;

@property (nonatomic,strong) YYLatestSeriesModel *latestSeriesModel;

@end
