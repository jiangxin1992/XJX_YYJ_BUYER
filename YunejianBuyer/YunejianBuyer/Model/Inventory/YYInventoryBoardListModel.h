//
//  YYInventoryBoardListModel.h
//  YunejianBuyer
//
//  Created by Apple on 16/8/26.
//  Copyright © 2016年 Apple. All rights reserved.
//

#import "JSONModel.h"
#import "YYInventoryBoardModel.h"
#import "YYPageInfoModel.h"

@interface YYInventoryBoardListModel : JSONModel
@property (strong, nonatomic) NSArray<YYInventoryBoardModel,Optional, ConvertOnDemand>* result;
@property (strong, nonatomic) YYPageInfoModel <Optional>*pageInfo;
@end
