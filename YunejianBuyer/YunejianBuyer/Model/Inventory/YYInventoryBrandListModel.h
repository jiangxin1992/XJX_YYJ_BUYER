//
//  YYInventoryBrandListModel.h
//  YunejianBuyer
//
//  Created by Apple on 16/8/26.
//  Copyright © 2016年 Apple. All rights reserved.
//

#import "JSONModel.h"
#import "YYInventoryBrandModel.h"

@interface YYInventoryBrandListModel : JSONModel
@property (strong, nonatomic) NSArray<YYInventoryBrandModel,Optional, ConvertOnDemand>* result;

@end
