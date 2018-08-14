//
//  YYOrderSizeModel.h
//  Yunejian
//
//  Created by yyj on 15/8/6.
//  Copyright (c) 2015年 yyj. All rights reserved.
//

#import "JSONModel.h"

@protocol YYOrderSizeModel @end

@interface YYOrderSizeModel : JSONModel

@property (nonatomic, strong) NSNumber <Optional>*sizeId;//尺寸ID
@property (nonatomic, strong) NSNumber <Optional>*amount;//该尺寸的购买数量

@property (nonatomic, strong) NSString <Optional>*name;//不一定会传值（补货里用到）
@property (nonatomic, strong) NSString <Optional>*sortId;
@property (nonatomic, strong) NSNumber <Optional>*stock;//库存
@property (nonatomic, strong) NSNumber <Optional>*received;//确认收货数
@property (nonatomic, strong) NSNumber <Optional>*prevAmount;//原单的尺码订购件数

@end
