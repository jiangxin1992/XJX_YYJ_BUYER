//
//  YYUserSeriesCollectionCell.h
//  YunejianBuyer
//
//  Created by yyj on 2017/7/14.
//  Copyright © 2017年 Apple. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MGSwipeTableCell.h>
#import <MGSwipeButton.h>

@class YYUserSeriesModel;

@interface YYUserSeriesCollectionCell : MGSwipeTableCell

@property (nonatomic,strong) YYUserSeriesModel *seriesModel;

@property (nonatomic,assign) BOOL haveData;

@property (nonatomic,copy) void (^seriesCellBlock)(NSString *type);

-(void)updateUI;

@end
