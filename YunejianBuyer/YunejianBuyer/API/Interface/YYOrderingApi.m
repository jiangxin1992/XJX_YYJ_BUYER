//
//  YYOrderingApi.m
//  YunejianBuyer
//
//  Created by yyj on 2017/5/31.
//  Copyright © 2017年 Apple. All rights reserved.
//

#import "YYOrderingApi.h"

// c文件 —> 系统文件（c文件在前）

// 控制器

// 自定义视图

// 接口

// 分类

// 自定义类和三方类（ cocoapods类 > model > 工具类 > 其他）
#import "RequestMacro.h"
#import "YYRequestHelp.h"
#import "YYHttpHeaderManager.h"

#import "YYOrderingListModel.h"
#import "YYOrderingHistoryListModel.h"

@implementation YYOrderingApi

+ (void)getOrderingListandBlock:(void (^)(YYRspStatusAndMessage *rspStatusAndMessage,YYOrderingListModel *orderingListModel,NSError *error))block{
    // get URL
    NSString *requestURL = [[[NSUserDefaults standardUserDefaults] objectForKey:kLastYYServerURL] stringByAppendingString:KOrderingList];
    NSDictionary *dic = [YYHttpHeaderManager buildHeadderWithAction:KOrderingList params:nil];

    NSDictionary *parameters = @{@"status":@"PUBLISHED",@"pageIndex":@(1),@"pageSize":@(1000)};
    NSData *body = [parameters mj_JSONData];

    [YYRequestHelp GET:dic requestUrl:requestURL requestCount:0 requestBody:body andBlock:^(YYRspStatusAndMessage *rspStatusAndMessage,id responseObject, NSError *error, id httpResponse) {
        if (!error && responseObject) {
            YYOrderingListModel *listModel = [[YYOrderingListModel alloc] initWithDictionary:responseObject error:nil];
            block(rspStatusAndMessage,listModel,error);
        }else{
            block(rspStatusAndMessage,nil,error);
        }
    }];
}

+ (void)getIndexOrderingListWithBlock:(void (^)(YYRspStatusAndMessage *rspStatusAndMessage,YYOrderingListModel *orderingListModel,NSError *error))block{
    // get URL
    NSString *requestURL = [[[NSUserDefaults standardUserDefaults] objectForKey:kLastYYServerURL] stringByAppendingString:KOrderingListIndex];
    NSDictionary *dic = [YYHttpHeaderManager buildHeadderWithAction:KOrderingListIndex params:nil];

    NSDictionary *parameters = @{@"status":@"PUBLISHED",@"pageIndex":@(1)};
    NSData *body = [parameters mj_JSONData];

    [YYRequestHelp GET:dic requestUrl:requestURL requestCount:0 requestBody:body andBlock:^(YYRspStatusAndMessage *rspStatusAndMessage,id responseObject, NSError *error, id httpResponse) {
        if (!error && responseObject) {
            YYOrderingListModel *listModel = [[YYOrderingListModel alloc] initWithDictionary:responseObject error:nil];
            block(rspStatusAndMessage,listModel,error);
        }else{
            block(rspStatusAndMessage,nil,error);
        }
    }];
}

+(void)getOrderingHistoryListPageIndex:(int)pageIndex pageSize:(int)pageSize andBlock:(void (^)(YYRspStatusAndMessage *, YYOrderingHistoryListModel *, NSError *))block{

    NSString *requestURL = [[[NSUserDefaults standardUserDefaults] objectForKey:kLastYYServerURL] stringByAppendingString:KOrderingHistoryList];
    NSDictionary *dic = [YYHttpHeaderManager buildHeadderWithAction:KOrderingHistoryList params:nil];

    NSDictionary *parameters = @{@"pageIndex":@(pageIndex),@"pageSize":@(pageSize)};
    NSData *body = [parameters mj_JSONData];
    
    [YYRequestHelp GET:dic requestUrl:requestURL requestCount:0 requestBody:body andBlock:^(YYRspStatusAndMessage *rspStatusAndMessage,id responseObject, NSError *error, id httpResponse) {
        if (!error) {
            YYOrderingHistoryListModel * chatList = [[YYOrderingHistoryListModel alloc] initWithDictionary:responseObject error:nil];
            block(rspStatusAndMessage,chatList,error);
        }else{
            block(rspStatusAndMessage,nil,error);
        }
    }];
}

//取消预约
+ (void)CancelOrderingWithID:(int)orderingID andBlock:(void (^)(YYRspStatusAndMessage *rspStatusAndMessage,NSError *error))block{
    NSString *requestURL = [[[NSUserDefaults standardUserDefaults] objectForKey:kLastYYServerURL] stringByAppendingString:KOrderingCancel];
    NSDictionary *dic = [YYHttpHeaderManager buildHeadderWithAction:KOrderingCancel params:nil];

    NSDictionary *parameters = @{@"applyId":@(orderingID)};
    NSData *body = [parameters mj_JSONData];

    [YYRequestHelp POST:dic requestUrl:requestURL requestCount:0 requestBody:body andBlock:^(YYRspStatusAndMessage *rspStatusAndMessage,id responseObject, NSError *error, id httpResponse) {
        if (!error) {
            block(rspStatusAndMessage,error);
        }else{
            block(rspStatusAndMessage,error);
        }
    }];
}

//删除预约
+ (void)DeleteOrderingWithID:(int)orderingID andBlock:(void (^)(YYRspStatusAndMessage *rspStatusAndMessage,NSError *error))block{
    NSString *requestURL = [[[NSUserDefaults standardUserDefaults] objectForKey:kLastYYServerURL] stringByAppendingString:KOrderingDelete];
    NSDictionary *dic = [YYHttpHeaderManager buildHeadderWithAction:KOrderingDelete params:nil];

    NSDictionary *parameters = @{@"applyId":@(orderingID)};
    NSData *body = [parameters mj_JSONData];

    [YYRequestHelp POST:dic requestUrl:requestURL requestCount:0 requestBody:body andBlock:^(YYRspStatusAndMessage *rspStatusAndMessage,id responseObject, NSError *error, id httpResponse) {
        if (!error) {
            block(rspStatusAndMessage,error);
        }else{
            block(rspStatusAndMessage,error);
        }
    }];
}
//清空订货会消息
+ (void)clearAppointmentUnreadMessageWithBlock:(void (^)(YYRspStatusAndMessage *rspStatusAndMessage,NSError *error))block{
    NSString *requestURL = [[[NSUserDefaults standardUserDefaults] objectForKey:kLastYYServerURL] stringByAppendingString:KOrderingClear];
    NSDictionary *dic = [YYHttpHeaderManager buildHeadderWithAction:KOrderingClear params:nil];

    [YYRequestHelp POST:dic requestUrl:requestURL requestCount:0 requestBody:nil andBlock:^(YYRspStatusAndMessage *rspStatusAndMessage,id responseObject, NSError *error, id httpResponse) {
        if (!error) {
            block(rspStatusAndMessage,error);
        }else{
            block(rspStatusAndMessage,error);
        }
    }];
}

//获取预约申请状态变更消息
+ (void)getAppointmentStatusChangeMessageCountWithBlock:(void (^)(YYRspStatusAndMessage *rspStatusAndMessage,NSInteger unreadAppointmentStatusMsgAmount, NSError *error))block{
    
    NSString *requestURL = [[[NSUserDefaults standardUserDefaults] objectForKey:kLastYYServerURL] stringByAppendingString:KOrderingStatusCount];
    NSDictionary *dic = [YYHttpHeaderManager buildHeadderWithAction:KOrderingStatusCount params:nil];
    
    [YYRequestHelp GET:dic requestUrl:requestURL requestCount:0 requestBody:nil andBlock:^(YYRspStatusAndMessage *rspStatusAndMessage,id responseObject, NSError *error, id httpResponse) {
        if (!error) {
            NSInteger unreadAppointmentStatusMsgAmount = [[responseObject objectForKey:@"result"] integerValue];
            block(rspStatusAndMessage,unreadAppointmentStatusMsgAmount,error);
        }else{
            block(rspStatusAndMessage,0,error);
        }
    }];
}
//删除预约申请消息
+ (void)DeleteAppointmentStatusChangeMessageWithBlock:(void (^)(YYRspStatusAndMessage *rspStatusAndMessage,NSError *error))block{
    NSString *requestURL = [[[NSUserDefaults standardUserDefaults] objectForKey:kLastYYServerURL] stringByAppendingString:KOrderingStatusCountDelete];
    NSDictionary *dic = [YYHttpHeaderManager buildHeadderWithAction:KOrderingStatusCountDelete params:nil];

    [YYRequestHelp DELETE:dic requestUrl:requestURL requestCount:0 requestBody:nil andBlock:^(YYRspStatusAndMessage *rspStatusAndMessage,id responseObject, NSError *error, id httpResponse) {
        if (!error) {
            block(rspStatusAndMessage,error);
        }else{
            block(rspStatusAndMessage,error);
        }
    }];
}
//判断买手是否有访问某系列权限
+ (void )isSeriesPubToBuyerWithSeriesId:(NSInteger )seriesId WithBlock:(void (^)(YYRspStatusAndMessage *rspStatusAndMessage,BOOL isSeriesPubToBuyer, NSError *error))block{
    // get URL
    NSString *requestURL = [[[NSUserDefaults standardUserDefaults] objectForKey:kLastYYServerURL] stringByAppendingString:kISSeriesPubToBuyer];
    NSDictionary *dic = [YYHttpHeaderManager buildHeadderWithAction:kISSeriesPubToBuyer params:nil];

    NSDictionary *parameters = @{@"seriesId":@(seriesId)};
    NSData *body = [parameters mj_JSONData];

    [YYRequestHelp GET:dic requestUrl:requestURL requestCount:0 requestBody:body andBlock:^(YYRspStatusAndMessage *rspStatusAndMessage,id responseObject, NSError *error, id httpResponse) {
        if (!error && responseObject) {
            BOOL isSeriesPubToBuyer = [responseObject boolValue];
            block(rspStatusAndMessage,isSeriesPubToBuyer,error);
        }else{
            block(rspStatusAndMessage,NO,error);
        }
    }];
}

@end
