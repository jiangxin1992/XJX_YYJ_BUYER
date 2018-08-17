//
//  YYInventoryApi.h
//  YunejianBuyer
//
//  Created by Victor on 2018/7/19.
//  Copyright © 2018年 Apple. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "YYRspStatusAndMessage.h"
#import "YYWarehouseRequestModel.h"
#import "YYWarehouseDetailRequestModel.h"
#import "YYWarehouseRecordResponse.h"

@interface YYInventoryApi : NSObject

//获取仓库列表
+ (void)getWarehouseListWithBlock:(void (^)(YYRspStatusAndMessage *rspStatusAndMessage, NSArray *warehouseList, NSError *error))block;

//获取入库记录
+ (void)getWarehouseRecordByRequest:(YYWarehouseRequestModel *)request andBlock:(void (^)(YYRspStatusAndMessage *rspStatusAndMessage, YYWarehouseRecordResponse *response, NSError *error))block;

//获取入库详情
+ (void)getWarehouseDetailsByRequest:(YYWarehouseDetailRequestModel *)request andBlock:(void (^)(YYRspStatusAndMessage *rspStatusAndMessage, YYWarehouseRecordModel *response, NSError *error))block;

@end
