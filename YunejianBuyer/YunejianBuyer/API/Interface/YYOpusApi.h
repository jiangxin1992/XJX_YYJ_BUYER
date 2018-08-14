//
//  YYOpusApi.h
//  Yunejian
//
//  Created by yyj on 15/7/23.
//  Copyright (c) 2015年 yyj. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "YYRspStatusAndMessage.h"

@class YYOpusSeriesListModel,YYOpusStyleListModel,YYStyleInfoModel,YYSeriesInfoDetailModel,YYUserStyleListModel,YYUserSeriesListModel;

@interface YYOpusApi : NSObject

/**
 *
 * 系列收藏列表
 *
 */
+ (void)getSeriesCollectListByPageIndex:(int)pageIndex pageSize:(int)pageSize andBlock:(void (^)(YYRspStatusAndMessage *rspStatusAndMessage,YYUserSeriesListModel *seriesListModel,NSError *error))block;
/**
 *
 * 款式收藏列表
 *
 */
+ (void)getStyleCollectListByPageIndex:(int)pageIndex pageSize:(int)pageSize andBlock:(void (^)(YYRspStatusAndMessage *rspStatusAndMessage,YYUserStyleListModel *styleListModel,NSError *error))block;
/**
 *
 * 收藏/取消收藏 系列
 *
 */
+ (void)updateSeriesCollectStateBySeriesId:(long)seriesId isCollect:(BOOL )isCollect andBlock:(void (^)(YYRspStatusAndMessage *rspStatusAndMessage,NSError *error))block;

/**
 *
 * 收藏/取消收藏 款式
 *
 */
+ (void)updateStyleCollectStateByStyleId:(long)styleId isCollect:(BOOL )isCollect andBlock:(void (^)(YYRspStatusAndMessage *rspStatusAndMessage,NSError *error))block;


/**
 *
 * 获取设计师系列列表
 *
 */
+ (void)getSeriesListWithId:(int)designerId pageIndex:(int)pageIndex pageSize:(int)pageSize andBlock:(void (^)(YYRspStatusAndMessage *rspStatusAndMessage,YYOpusSeriesListModel *opusSeriesListModel,NSError *error))block;

/**
 *
 * 获取款式详情
 *
 */
+ (void)getStyleInfoByStyleId:(long)styleId orderCode:(NSString*) orderCode andBlock:(void (^)(YYRspStatusAndMessage *rspStatusAndMessage,YYStyleInfoModel *styleInfoModel,NSError *error))block;

/**
 *
 * 获取设计师订单可用系列列表
 *
 */
+ (void)getSeriesListWithOrderCode:(NSString*)orderCode pageIndex:(int)pageIndex pageSize:(int)pageSize andBlock:(void (^)(YYRspStatusAndMessage *rspStatusAndMessage,YYOpusSeriesListModel *opusSeriesListModel,NSError *error))block;

/**
 *
 * 买手修改订单可用的款式
 *
 */
+ (void)getStyleListWithOrderCode:(NSString*)orderCode seriesId:(long)seriesId orderBy:(NSString *)orderBy queryStr:(NSString *)queryStr pageIndex:(int)pageIndex pageSize:(int)pageSize andBlock:(void (^)(YYRspStatusAndMessage *rspStatusAndMessage,YYOpusStyleListModel *opusStyleListModel,NSError *error))block;


/**
 *
 *合作设计师的系列列表
 *
 */
+ (void)getConnSeriesListWithId:(int)designerId pageIndex:(int)pageIndex pageSize:(int)pageSize andBlock:(void (^)(YYRspStatusAndMessage *rspStatusAndMessage,YYOpusSeriesListModel *opusSeriesListModel,NSError *error))block;


/**
 *
 *合作设计师系列详情
 *
 */
+ (void)getConnSeriesInfoWithId:(NSInteger )designerId seriesId:(NSInteger )seriesId andBlock:(void (^)(YYRspStatusAndMessage *rspStatusAndMessage,YYSeriesInfoDetailModel *infoDetailModel,NSError *error))block;

/**
 *
 * 合作设计师款式列表（带搜索）
 *
 */
+ (void)getConnStyleListWithDesignerId:(NSInteger )designerId seriesId:(NSInteger )seriesId orderBy:(NSString *)orderBy queryStr:(NSString *)queryStr pageIndex:(NSInteger )pageIndex pageSize:(NSInteger )pageSize andBlock:(void (^)(YYRspStatusAndMessage *rspStatusAndMessage,YYOpusStyleListModel *opusStyleListModel,NSError *error))block;

/**
 *
 * 更改系列权限
 *
 */
+ (void)updateSeriesAuthType:(long)seriesId authType:(NSInteger)authType andBlock:(void (^)(YYRspStatusAndMessage *rspStatusAndMessage,NSError *error))block;

/**
 *
 *设计师系列详情
 *
 */
+ (void)getSeriesInfo:(NSInteger )seriesId andBlock:(void (^)(YYRspStatusAndMessage *rspStatusAndMessage,YYSeriesInfoDetailModel *infoDetailModel,NSError *error))block;

@end
