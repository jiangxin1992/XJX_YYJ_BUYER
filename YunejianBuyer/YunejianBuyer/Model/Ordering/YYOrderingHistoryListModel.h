//
//  YYOrderingHistoryListModel.h
//  YunejianBuyer
//
//  Created by yyj on 2017/6/2.
//  Copyright © 2017年 Apple. All rights reserved.
//

#import <JSONModel/JSONModel.h>

#import "YYPageInfoModel.h"
#import "YYOrderingHistoryListItemModel.h"

@interface YYOrderingHistoryListModel : JSONModel

@property (strong, nonatomic) NSArray<YYOrderingHistoryListItemModel, Optional,ConvertOnDemand>* result;
@property (strong, nonatomic) YYPageInfoModel <Optional>*pageInfo;

@end
