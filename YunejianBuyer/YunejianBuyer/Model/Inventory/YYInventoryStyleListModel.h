//
//  YYInventoryStyleListModel.h
//  YunejianBuyer
//
//  Created by Apple on 16/8/26.
//  Copyright © 2016年 Apple. All rights reserved.
//

#import "JSONModel.h"
#import "YYInventoryStyleDetailModel.h"
#import "YYPageInfoModel.h"
@interface YYInventoryStyleListModel : JSONModel
@property (strong, nonatomic) NSArray<YYInventoryStyleDetailModel,Optional, ConvertOnDemand>* result;
@property (strong, nonatomic) YYPageInfoModel <Optional>*pageInfo;
@end
