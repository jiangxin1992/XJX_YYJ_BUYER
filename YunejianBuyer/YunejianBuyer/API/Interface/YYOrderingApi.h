//
//  YYOrderingApi.h
//  YunejianBuyer
//
//  Created by yyj on 2017/5/31.
//  Copyright © 2017年 Apple. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "YYRspStatusAndMessage.h"

@class YYOrderingListModel,YYOrderingHistoryListModel;

@interface YYOrderingApi : NSObject

//获取订货会列表
+ (void)getOrderingListandBlock:(void (^)(YYRspStatusAndMessage *rspStatusAndMessage,YYOrderingListModel *orderingListModel,NSError *error))block;
+ (void)getIndexOrderingListWithBlock:(void (^)(YYRspStatusAndMessage *rspStatusAndMessage,YYOrderingListModel *orderingListModel,NSError *error))block;
//获取我的预约
+ (void)getOrderingHistoryListPageIndex:(int)pageIndex pageSize:(int)pageSize andBlock:(void (^)(YYRspStatusAndMessage *rspStatusAndMessage,YYOrderingHistoryListModel *orderingListModel,NSError *error))block;

//取消预约
+ (void)CancelOrderingWithID:(int)orderingID andBlock:(void (^)(YYRspStatusAndMessage *rspStatusAndMessage,NSError *error))block;

//删除预约
+ (void)DeleteOrderingWithID:(int)orderingID andBlock:(void (^)(YYRspStatusAndMessage *rspStatusAndMessage,NSError *error))block;

//清空订货会消息
+ (void)clearAppointmentUnreadMessageWithBlock:(void (^)(YYRspStatusAndMessage *rspStatusAndMessage,NSError *error))block;

//获取预约申请状态变更消息
+ (void)getAppointmentStatusChangeMessageCountWithBlock:(void (^)(YYRspStatusAndMessage *rspStatusAndMessage,NSInteger unreadAppointmentStatusMsgAmount, NSError *error))block;

//删除预约申请消息
+ (void)DeleteAppointmentStatusChangeMessageWithBlock:(void (^)(YYRspStatusAndMessage *rspStatusAndMessage,NSError *error))block;

//判断买手是否有访问某系列权限
+ (void )isSeriesPubToBuyerWithSeriesId:(NSInteger )seriesId WithBlock:(void (^)(YYRspStatusAndMessage *rspStatusAndMessage,BOOL isSeriesPubToBuyer, NSError *error))block;

@end
