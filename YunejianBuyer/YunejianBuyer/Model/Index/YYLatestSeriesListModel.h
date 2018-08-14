//
//  YYLatestSeriesListModel.h
//  YunejianBuyer
//
//  Created by yyj on 2017/8/8.
//  Copyright © 2017年 Apple. All rights reserved.
//

#import <JSONModel/JSONModel.h>

#import "YYLatestSeriesModel.h"
#import "YYPageInfoModel.h"

@interface YYLatestSeriesListModel : JSONModel

@property (strong, nonatomic) NSArray <YYLatestSeriesModel,Optional, ConvertOnDemand>*result;
@property (strong, nonatomic) YYPageInfoModel <Optional>*pageInfo;

@end
