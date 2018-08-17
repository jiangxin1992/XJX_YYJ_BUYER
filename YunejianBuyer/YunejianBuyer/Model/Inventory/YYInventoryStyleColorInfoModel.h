//
//  YYInventoryStyleColorInfoModel.h
//  YunejianBuyer
//
//  Created by Apple on 16/8/26.
//  Copyright © 2016年 Apple. All rights reserved.
//

#import "JSONModel.h"
#import "YYOrderSizeModel.h"
#import "YYInventoryOneColorModel.h"
@interface YYInventoryStyleColorInfoModel : JSONModel
@property (strong, nonatomic) NSArray<YYInventoryOneColorModel, Optional,ConvertOnDemand>* colors;
@property (strong, nonatomic) NSArray<YYOrderSizeModel, Optional,ConvertOnDemand>* sizes;
@end
