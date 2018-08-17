//
//  YYInventoryApi.m
//  YunejianBuyer
//r
//  Created by Victor on 2018/7/19.
//  Copyright © 2018年 Apple. All rights reserved.
//

#import "YYInventoryApi.h"
#import "RequestMacro.h"
#import "YYRequestHelp.h"
#import "YYHttpHeaderManager.h"
#import "YYWarehouseListModel.h"

@implementation YYInventoryApi

//获取仓库列表
+ (void)getWarehouseListWithBlock:(void (^)(YYRspStatusAndMessage *rspStatusAndMessage, NSArray *warehouseList, NSError *error))block {
    NSString *requestURL = [[[NSUserDefaults standardUserDefaults] objectForKey:kLastYYServerURL] stringByAppendingString:kWarehouseList];
    NSDictionary *dic = [YYHttpHeaderManager buildHeadderWithAction:kWarehouseList params:nil];
    
    [YYRequestHelp GET:dic requestUrl:requestURL requestCount:0 requestBody:nil andBlock:^(YYRspStatusAndMessage *rspStatusAndMessage,id responseObject, NSError *error, id httpResponse) {
        if (!error) {
            NSArray *response = [YYWarehouseListModel arrayOfModelsFromDictionaries:responseObject error:nil];
            block(rspStatusAndMessage, response, error);
        }else{
            block(rspStatusAndMessage,nil,error);
        }
    }];
}

//获取入库记录
+ (void)getWarehouseRecordByRequest:(YYWarehouseRequestModel *)request andBlock:(void (^)(YYRspStatusAndMessage *rspStatusAndMessage, YYWarehouseRecordResponse *response, NSError *error))block {
    NSString *requestURL = [[[NSUserDefaults standardUserDefaults] objectForKey:kLastYYServerURL] stringByAppendingString:kWarehouseRecord];
    NSDictionary *dic = [YYHttpHeaderManager buildHeadderWithAction:kWarehouseRecord params:nil];
    NSData *body = [request mj_JSONData];
    
    [YYRequestHelp GET:dic requestUrl:requestURL requestCount:0 requestBody:body andBlock:^(YYRspStatusAndMessage *rspStatusAndMessage,id responseObject, NSError *error, id httpResponse) {
        if (!error) {
            YYWarehouseRecordResponse *response = [[YYWarehouseRecordResponse alloc] initWithDictionary:responseObject error:nil];
            block(rspStatusAndMessage, response, error);
        }else{
            block(rspStatusAndMessage,nil,error);
        }
    }];
}

//获取入库详情
+ (void)getWarehouseDetailsByRequest:(YYWarehouseDetailRequestModel *)request andBlock:(void (^)(YYRspStatusAndMessage *rspStatusAndMessage, YYWarehouseRecordModel *response, NSError *error))block {
    NSString *requestURL = [[[NSUserDefaults standardUserDefaults] objectForKey:kLastYYServerURL] stringByAppendingString:kWarehouseDetails];
    NSDictionary *dic = [YYHttpHeaderManager buildHeadderWithAction:kWarehouseDetails params:nil];
    NSData *body = [request mj_JSONData];
    
    [YYRequestHelp GET:dic requestUrl:requestURL requestCount:0 requestBody:body andBlock:^(YYRspStatusAndMessage *rspStatusAndMessage,id responseObject, NSError *error, id httpResponse) {
        if (!error) {
            YYWarehouseRecordModel *response = [[YYWarehouseRecordModel alloc] initWithDictionary:responseObject error:nil];
            block(rspStatusAndMessage, response, error);
        }else{
            block(rspStatusAndMessage,nil,error);
        }
    }];
}

@end
