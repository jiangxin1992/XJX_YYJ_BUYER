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

@property (strong, nonatomic) NSNumber <Optional>*sizeId;//尺寸ID
@property (strong, nonatomic) NSNumber <Optional>*amount;//该尺寸的购买数量

@property (strong, nonatomic) NSString <Optional>*name;//不一定会传值（补货里用到）
@property (strong, nonatomic) NSString <Optional>*sortId;
@property (nonatomic, strong) NSNumber <Optional>*stock;//库存
@end
