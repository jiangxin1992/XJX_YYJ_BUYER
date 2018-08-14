//
//  YYUserSeriesListModel.h
//  YunejianBuyer
//
//  Created by yyj on 2017/7/15.
//  Copyright © 2017年 Apple. All rights reserved.
//

#import <JSONModel/JSONModel.h>

#import "YYUserSeriesModel.h"
#import "YYPageInfoModel.h"

@interface YYUserSeriesListModel : JSONModel

@property (strong, nonatomic) NSArray<YYUserSeriesModel, Optional,ConvertOnDemand>* result;
@property (strong, nonatomic) YYPageInfoModel <Optional>*pageInfo;

@end
