//
//  YYOrderingListModel.h
//  YunejianBuyer
//
//  Created by yyj on 2017/5/31.
//  Copyright © 2017年 Apple. All rights reserved.
//

#import <JSONModel/JSONModel.h>

#import "YYPageInfoModel.h"
#import "YYOrderingListItemModel.h"

@interface YYOrderingListModel : JSONModel
@property (strong, nonatomic) NSArray<YYOrderingListItemModel, Optional,ConvertOnDemand>* result;
@property (strong, nonatomic) YYPageInfoModel <Optional>*pageInfo;

@end
