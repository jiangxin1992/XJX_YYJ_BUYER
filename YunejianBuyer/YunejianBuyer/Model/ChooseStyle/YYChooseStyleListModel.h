//
//  YYChooseStyleListModel.h
//  YunejianBuyer
//
//  Created by yyj on 2017/7/5.
//  Copyright © 2017年 Apple. All rights reserved.
//

#import <JSONModel/JSONModel.h>

#import "YYChooseStyleModel.h"
#import "YYPageInfoModel.h"

@interface YYChooseStyleListModel : JSONModel

@property (strong, nonatomic) NSArray<YYChooseStyleModel,Optional, ConvertOnDemand>* result;
@property (strong, nonatomic) YYPageInfoModel <Optional>*pageInfo;

@end
