//
//  YYInventoryStyleDemandModel.h
//  YunejianBuyer
//
//  Created by Apple on 16/8/26.
//  Copyright © 2016年 Apple. All rights reserved.
//

#import "JSONModel.h"
#import "YYInventoryOneColorModel.h"
@interface YYInventoryStyleDemandModel : JSONModel
@property (strong, nonatomic) NSNumber <Optional>*designerId;//":18,
@property (strong, nonatomic) NSNumber <Optional>*styleId;//":1221,
@property (strong, nonatomic) NSArray<YYInventoryOneColorModel, Optional,ConvertOnDemand>* colors;

@end
