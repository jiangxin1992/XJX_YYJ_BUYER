//
//  YYHotSeriesCardView.h
//  YunejianBuyer
//
//  Created by yyj on 2017/9/22.
//  Copyright © 2017年 Apple. All rights reserved.
//

#import <UIKit/UIKit.h>

@class YYLatestSeriesModel;

@interface YYHotSeriesCardView : UIView

@property (nonatomic,strong) YYLatestSeriesModel *seriesModel;

@property(nonatomic,copy) void (^seriesCardBlock)(NSString *type,YYLatestSeriesModel *seriesModel);

-(void)updateUI;

@end
