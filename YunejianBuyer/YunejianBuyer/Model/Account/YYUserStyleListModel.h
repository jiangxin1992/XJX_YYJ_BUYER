//
//  YYUserStyleListModel.h
//  YunejianBuyer
//
//  Created by yyj on 2017/7/15.
//  Copyright © 2017年 Apple. All rights reserved.
//

#import <JSONModel/JSONModel.h>

#import "YYUserStyleModel.h"
#import "YYPageInfoModel.h"

@interface YYUserStyleListModel : JSONModel

@property (strong, nonatomic) NSArray<YYUserStyleModel, Optional,ConvertOnDemand>* result;
@property (strong, nonatomic) YYPageInfoModel <Optional>*pageInfo;

@end
