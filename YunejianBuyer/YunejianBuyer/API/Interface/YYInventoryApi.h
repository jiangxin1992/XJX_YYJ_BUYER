//
//  YYInventoryApi.h
//  YunejianBuyer
//
//  Created by Apple on 16/8/26.
//  Copyright © 2016年 Apple. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "YYRspStatusAndMessage.h"
#import "YYInventoryBrandListModel.h"
#import "YYInventoryOrderStylesModel.h"
#import "YYInventoryStyleColorInfoModel.h"
#import "YYInventoryBoardListModel.h"
#import "YYInventoryStyleListModel.h"
@interface YYInventoryApi : NSObject
//买手店获取合作品牌
+ (void)getBrandsWithBlock:(void (^)(YYRspStatusAndMessage *rspStatusAndMessage,YYInventoryBrandListModel *brandsModel,NSError *error))block;
//买手店下过单的款式
+ (void)getOrderStyles:(NSString *)designerIds query:(NSString*)query  pageIndex:(int)pageIndex pageSize:(int)pageSize adnBlock:(void (^)(YYRspStatusAndMessage *rspStatusAndMessage,YYInventoryOrderStylesModel *stylesModel,NSError *error))block;
//获取款式颜色及尺码信息
+ (void)getStyleColorInfo:(NSInteger )styleId colorIds:(NSString*)colorIds type:(NSString *)type adnBlock:(void (^)(YYRspStatusAndMessage *rspStatusAndMessage,YYInventoryStyleColorInfoModel *infoModel,NSError *error))block;
//标记消息为已读
+(void)markAsReadOnMsg:(NSString *)msgIds adnBlock:(void (^)(YYRspStatusAndMessage *rspStatusAndMessage,NSError *error))block;
//买手店补货公告
+ (void)getBoardList:(NSString *)designerIds month:(NSInteger)month pageIndex:(int)pageIndex pageSize:(int)pageSize queryStr:(NSString *)queryStr  adnBlock:(void (^)(YYRspStatusAndMessage *rspStatusAndMessage,YYInventoryBoardListModel *boardsModel,NSError *error))block;
//发布补货需求
+(void)addDemand:(NSData *)modelData adnBlock:(void (^)(YYRspStatusAndMessage *rspStatusAndMessage,NSError *error))block;
//发布库存信息
+(void)addStore:(NSData *)modelData adnBlock:(void (^)(YYRspStatusAndMessage *rspStatusAndMessage,NSError *error))block;
//买手店我的补货列表
+ (void)getDemandList:(NSString *)designerIds month:(NSInteger)month pageIndex:(int)pageIndex pageSize:(int)pageSize queryStr:(NSString *)queryStr  adnBlock:(void (^)(YYRspStatusAndMessage *rspStatusAndMessage,YYInventoryStyleListModel *listModel,NSError *error))block;
//我的库存列表
+ (void)getStoreList:(NSString *)designerIds month:(NSInteger)month pageIndex:(int)pageIndex pageSize:(int)pageSize queryStr:(NSString *)queryStr  adnBlock:(void (^)(YYRspStatusAndMessage *rspStatusAndMessage,YYInventoryStyleListModel *listModel,NSError *error))block;
//删除我的补货
+(void)deleteDemand:(NSInteger)demandId adnBlock:(void (^)(YYRspStatusAndMessage *rspStatusAndMessage,NSError *error))block;
//删除单个我的库存
+(void)deleteStore:(NSInteger)storeId adnBlock:(void (^)(YYRspStatusAndMessage *rspStatusAndMessage,NSError *error))block;
//修改补货需求
+(void)modifyDemand:(NSInteger)demandId amount:(NSInteger)amount adnBlock:(void (^)(YYRspStatusAndMessage *rspStatusAndMessage,NSError *error))block;
//修改我有库存
+(void)modifyStore:(NSInteger)storeId amount:(NSInteger)amount adnBlock:(void (^)(YYRspStatusAndMessage *rspStatusAndMessage,NSError *error))block;

@end
