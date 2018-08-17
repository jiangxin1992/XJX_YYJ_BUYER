//
//  YYInventoryOrderStylesModel.h
//  YunejianBuyer
//
//  Created by Apple on 16/8/26.
//  Copyright © 2016年 Apple. All rights reserved.
//

#import "JSONModel.h"
#import "YYInventoryStyleModel.h"
#import "YYPageInfoModel.h"
@interface YYInventoryOrderStylesModel : JSONModel
@property (strong, nonatomic) NSArray<YYInventoryStyleModel,Optional, ConvertOnDemand>* result;
@property (strong, nonatomic) YYPageInfoModel <Optional>*pageInfo;

@end
