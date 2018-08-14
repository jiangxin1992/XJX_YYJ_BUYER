//
//  YYChooseStyleModel.h
//  YunejianBuyer
//
//  Created by yyj on 2017/7/5.
//  Copyright © 2017年 Apple. All rights reserved.
//

#import <JSONModel/JSONModel.h>
#import "YYColorModel.h"

@protocol YYChooseStyleModel @end

@interface YYChooseStyleModel : JSONModel

/** 款式图片*/
@property (strong, nonatomic) NSString <Optional>* albumImg;
/** 品牌logo地址*/
@property (strong, nonatomic) NSString <Optional>* brandLogo;
/** 品牌名称*/
@property (strong, nonatomic) NSString <Optional>* brandName;
/** 颜色数组*/
@property (strong, nonatomic) NSArray <Optional,ConvertOnDemand,YYColorModel>* colors;
/** 设计师ID*/
@property (strong, nonatomic) NSNumber <Optional>* designerId;
/** 零售价*/
@property (strong, nonatomic) NSNumber <Optional>* retailPrice;
/** 系列ID*/
@property (strong, nonatomic) NSNumber <Optional>* seriesId;
/** 系列名称*/
@property (strong, nonatomic) NSString <Optional>* seriesName;
/** 收藏数*/
@property (strong, nonatomic) NSNumber <Optional>* stars;
/** 款式ID*/
@property (strong, nonatomic) NSNumber <Optional>* styleId;
/** 款式名称*/
@property (strong, nonatomic) NSString <Optional>* styleName;
/** 批发价*/
@property (strong, nonatomic) NSNumber <Optional>* tradePrice;
/** 按币种搜索:0人民币; 1 欧元; 2 英镑; 3 美元*/
@property (strong, nonatomic) NSNumber <Optional>*curType;

@end
