//
//  YYHotSeriesCardCell.h
//  YunejianBuyer
//
//  Created by yyj on 2017/9/21.
//  Copyright © 2017年 Apple. All rights reserved.
//

#import <UIKit/UIKit.h>

@class YYLatestSeriesModel;

@interface YYHotSeriesCardCell : UITableViewCell

-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier WithBlock:(void(^)(NSString *type,YYLatestSeriesModel *latestSeriesModel))block;

@property (nonatomic,strong) YYLatestSeriesModel *leftSeriesModel;

@property (nonatomic,strong) YYLatestSeriesModel *rightSeriesModel;

-(void)updateUI;

@end
