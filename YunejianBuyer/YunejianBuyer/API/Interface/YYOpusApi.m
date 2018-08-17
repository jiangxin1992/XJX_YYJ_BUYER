//
//  YYOpusApi.m
//  Yunejian
//
//  Created by yyj on 15/7/23.
//  Copyright (c) 2015年 yyj. All rights reserved.
//

#import "YYOpusApi.h"

// c文件 —> 系统文件（c文件在前）

// 控制器

// 自定义视图

// 接口

// 分类

// 自定义类和三方类（ cocoapods类 > model > 工具类 > 其他）
#import "RequestMacro.h"
#import "YYRequestHelp.h"
#import "YYHttpHeaderManager.h"

#import "YYStyleInfoModel.h"
#import "YYUserStyleListModel.h"
#import "YYOpusStyleListModel.h"
#import "YYUserSeriesListModel.h"
#import "YYOpusSeriesListModel.h"
#import "YYSeriesInfoDetailModel.h"

@implementation YYOpusApi

/**
 *
 * 系列收藏列表
 *
 */
+ (void)getSeriesCollectListByPageIndex:(int)pageIndex pageSize:(int)pageSize andBlock:(void (^)(YYRspStatusAndMessage *rspStatusAndMessage,YYUserSeriesListModel *seriesListModel,NSError *error))block
{
    // get URL
    NSString *requestURL = [[[NSUserDefaults standardUserDefaults] objectForKey:kLastYYServerURL] stringByAppendingString:kCollectionSeriesList];
    NSDictionary *dic = [YYHttpHeaderManager buildHeadderWithAction:kCollectionSeriesList params:nil];

    NSDictionary *parameters = @{@"pageIndex":@(pageIndex),@"pageSize":@(pageSize)};
    NSData *body = [parameters mj_JSONData];

    [YYRequestHelp GET:dic requestUrl:requestURL requestCount:0 requestBody:body andBlock:^(YYRspStatusAndMessage *rspStatusAndMessage,id responseObject, NSError *error, id httpResponse) {
        if (!error
            && responseObject) {
            YYUserSeriesListModel *seriesListModel = [[YYUserSeriesListModel alloc] initWithDictionary:responseObject error:nil];
            block(rspStatusAndMessage,seriesListModel,error);
            
        }else{
            block(rspStatusAndMessage,nil,error);
        }
        
    }];
}
/**
 *
 * 款式收藏列表
 *
 */
+ (void)getStyleCollectListByPageIndex:(int)pageIndex pageSize:(int)pageSize andBlock:(void (^)(YYRspStatusAndMessage *rspStatusAndMessage,YYUserStyleListModel *styleListModel,NSError *error))block
{
    // get URL
    NSString *requestURL = [[[NSUserDefaults standardUserDefaults] objectForKey:kLastYYServerURL] stringByAppendingString:kCollectionStyleList];
    NSDictionary *dic = [YYHttpHeaderManager buildHeadderWithAction:kCollectionStyleList params:nil];

    NSDictionary *parameters = @{@"pageIndex":@(pageIndex),@"pageSize":@(pageSize)};
    NSData *body = [parameters mj_JSONData];

    [YYRequestHelp POST:dic requestUrl:requestURL requestCount:0 requestBody:body andBlock:^(YYRspStatusAndMessage *rspStatusAndMessage,id responseObject, NSError *error, id httpResponse) {
        if (!error
            && responseObject) {
            YYUserStyleListModel *styleListModel = [[YYUserStyleListModel alloc] initWithDictionary:responseObject error:nil];
            block(rspStatusAndMessage,styleListModel,error);
            
        }else{
            block(rspStatusAndMessage,nil,error);
        }
        
    }];
}

/**
 *
 * 收藏/取消收藏 系列
 *
 */
+ (void)updateSeriesCollectStateBySeriesId:(long)seriesId isCollect:(BOOL )isCollect andBlock:(void (^)(YYRspStatusAndMessage *rspStatusAndMessage,NSError *error))block{
    NSString *appentUrl = @"";
    if(isCollect){
        //收藏
        appentUrl = kAddSeries;
    }else{
        //取消收藏
        appentUrl = kRemoveSeries;
    }
    
    NSString *requestURL = [[[NSUserDefaults standardUserDefaults] objectForKey:kLastYYServerURL] stringByAppendingString:appentUrl];
    NSDictionary *dic = [YYHttpHeaderManager buildHeadderWithAction:appentUrl params:nil];

    NSDictionary *parameters = @{@"seriesId":@(seriesId)};
    NSData *body = [parameters mj_JSONData];

    [YYRequestHelp POST:dic requestUrl:requestURL requestCount:0 requestBody:body andBlock:^(YYRspStatusAndMessage *rspStatusAndMessage,id responseObject, NSError *error, id httpResponse) {
        if (!error) {
            block(rspStatusAndMessage,error);
        }else{
            block(rspStatusAndMessage,error);
        }
    }];
}

/**
 *
 * 收藏/取消收藏 款式
 *
 */
+ (void)updateStyleCollectStateByStyleId:(long)styleId isCollect:(BOOL )isCollect andBlock:(void (^)(YYRspStatusAndMessage *rspStatusAndMessage,NSError *error))block{
    NSString *appentUrl = @"";
    if(isCollect){
        //收藏
        appentUrl = kAddStyle;
    }else{
        //取消收藏
        appentUrl = kRemoveStyle;
    }
    
    NSString *requestURL = [[[NSUserDefaults standardUserDefaults] objectForKey:kLastYYServerURL] stringByAppendingString:appentUrl];
    NSDictionary *dic = [YYHttpHeaderManager buildHeadderWithAction:appentUrl params:nil];

    NSDictionary *parameters = @{@"styleId":@(styleId)};
    NSData *body = [parameters mj_JSONData];

    [YYRequestHelp POST:dic requestUrl:requestURL requestCount:0 requestBody:body andBlock:^(YYRspStatusAndMessage *rspStatusAndMessage,id responseObject, NSError *error, id httpResponse) {
        if (!error) {
            block(rspStatusAndMessage,error);
        }else{
            block(rspStatusAndMessage,error);
        }
    }];
}

/**
 *
 * 获取设计师系列列表
 *
 */
+ (void)getSeriesListWithId:(int)designerId pageIndex:(int)pageIndex pageSize:(int)pageSize andBlock:(void (^)(YYRspStatusAndMessage *rspStatusAndMessage,YYOpusSeriesListModel *opusSeriesListModel,NSError *error))block{
    // get URL
    NSString *requestURL = [[[NSUserDefaults standardUserDefaults] objectForKey:kLastYYServerURL] stringByAppendingString:kSeriesList_buyer];
    NSDictionary *dic = [YYHttpHeaderManager buildHeadderWithAction:kSeriesList_buyer params:nil];

    NSDictionary *parameters = @{@"designerId":@(designerId),@"pageIndex":@(pageIndex),@"pageSize":@(pageSize),@"withDraft":@"false"};
    NSData *body = [parameters mj_JSONData];

    [YYRequestHelp POST:dic requestUrl:requestURL requestCount:0 requestBody:body andBlock:^(YYRspStatusAndMessage *rspStatusAndMessage,id responseObject, NSError *error, id httpResponse) {
        if (!error
            && responseObject) {
            YYOpusSeriesListModel *opusSeriesListModel = [[YYOpusSeriesListModel alloc] initWithDictionary:responseObject error:nil];
            block(rspStatusAndMessage,opusSeriesListModel,error);
            
        }else{
            block(rspStatusAndMessage,nil,error);
        }
        
    }];
}

/**
 *
 * 获取款式详情
 *
 */
+ (void)getStyleInfoByStyleId:(long)styleId orderCode:(NSString*)orderCode andBlock:(void (^)(YYRspStatusAndMessage *rspStatusAndMessage,YYStyleInfoModel *styleInfoModel,NSError *error))block{
    // get URL
    NSString *requestURL = [[[NSUserDefaults standardUserDefaults] objectForKey:kLastYYServerURL] stringByAppendingString:kStyleInfo];
    NSDictionary *dic = [YYHttpHeaderManager buildHeadderWithAction:kStyleInfo params:nil];

    NSMutableDictionary *mutParameters = [[NSMutableDictionary alloc] init];
    [mutParameters setObject:@(styleId) forKey:@"styleId"];
    if(orderCode){
        [mutParameters setObject:orderCode forKey:@"orderCode"];
    }else{
    }
    NSDictionary *parameters = [mutParameters copy];
    NSData *body = [parameters mj_JSONData];

    [YYRequestHelp POST:dic requestUrl:requestURL requestCount:0 requestBody:body andBlock:^(YYRspStatusAndMessage *rspStatusAndMessage,id responseObject, NSError *error, id httpResponse) {
        if (!error
            && responseObject) {
            YYStyleInfoModel *styleInfoModel = [[YYStyleInfoModel alloc] initWithDictionary:responseObject error:nil];
            styleInfoModel.style.styleDescription = [responseObject valueForKeyPath:@"style.description"];
            block(rspStatusAndMessage,styleInfoModel,error);
            
        }else{
            block(rspStatusAndMessage,nil,error);
        }
        
    }];
}

/**
 *
 * 获取设计师系列列表
 *
 */
+ (void)getSeriesListWithOrderCode:(NSString*)orderCode pageIndex:(int)pageIndex pageSize:(int)pageSize andBlock:(void (^)(YYRspStatusAndMessage *rspStatusAndMessage,YYOpusSeriesListModel *opusSeriesListModel,NSError *error))block{
    // get URL
    NSString *requestURL = [[[NSUserDefaults standardUserDefaults] objectForKey:kLastYYServerURL] stringByAppendingString:kBuyerAvailableSeries];
    NSDictionary *dic = [YYHttpHeaderManager buildHeadderWithAction:kBuyerAvailableSeries params:nil];

    NSDictionary *parameters = @{@"orderCode":orderCode,@"pageIndex":@(pageIndex),@"pageSize":@(pageSize),@"withDraft":@"false"};
    NSData *body = [parameters mj_JSONData];

    [YYRequestHelp POST:dic requestUrl:requestURL requestCount:0 requestBody:body andBlock:^(YYRspStatusAndMessage *rspStatusAndMessage,id responseObject, NSError *error, id httpResponse) {
        if (!error
            && responseObject) {
            YYOpusSeriesListModel *opusSeriesListModel = [[YYOpusSeriesListModel alloc] initWithDictionary:responseObject error:nil];
            block(rspStatusAndMessage,opusSeriesListModel,error);
            
        }else{
            block(rspStatusAndMessage,nil,error);
        }
        
    }];
}

/**
 *
 * 买手修改订单可用的款式
 *
 */
+ (void)getStyleListWithOrderCode:(NSString*)orderCode seriesId:(long)seriesId orderBy:(NSString *)orderBy queryStr:(NSString *)queryStr pageIndex:(int)pageIndex pageSize:(int)pageSize andBlock:(void (^)(YYRspStatusAndMessage *rspStatusAndMessage,YYOpusStyleListModel *opusStyleListModel,NSError *error))block{
    // get URL
    NSString *requestURL = [[[NSUserDefaults standardUserDefaults] objectForKey:kLastYYServerURL] stringByAppendingString:kBuyerAvailableStyles];
    NSDictionary *dic = [YYHttpHeaderManager buildHeadderWithAction:kBuyerAvailableStyles params:nil];

    NSMutableDictionary *mutParameters = [[NSMutableDictionary alloc] init];

    [mutParameters setObject:orderCode forKey:@"orderCode"];
    [mutParameters setObject:@(pageIndex) forKey:@"pageIndex"];
    [mutParameters setObject:@(pageSize) forKey:@"pageSize"];

    if (seriesId > 0) {
        [mutParameters setObject:@(seriesId) forKey:@"seriesId"];
    }
    
    if (orderBy
        && [orderBy length] > 0) {
        [mutParameters setObject:orderBy forKey:@"orderBy"];
    }
    
    if(![queryStr isEqualToString:@""]){
        [mutParameters setObject:queryStr forKey:@"queryStr"];
    }

    NSDictionary *parameters = [mutParameters copy];
    NSData *body = [parameters mj_JSONData];

    [YYRequestHelp POST:dic requestUrl:requestURL requestCount:0 requestBody:body andBlock:^(YYRspStatusAndMessage *rspStatusAndMessage,id responseObject, NSError *error, id httpResponse) {
        if (!error
            && responseObject) {
            YYOpusStyleListModel *opusStyleListModel = [[YYOpusStyleListModel alloc] initWithDictionary:responseObject error:nil];
            block(rspStatusAndMessage,opusStyleListModel,error);
            
        }else{
            block(rspStatusAndMessage,nil,error);
        }
        
    }];
}

/**
 *
 *合作设计师的系列列表
 *
 */
+ (void)getConnSeriesListWithId:(int)designerId pageIndex:(int)pageIndex pageSize:(int)pageSize andBlock:(void (^)(YYRspStatusAndMessage *rspStatusAndMessage,YYOpusSeriesListModel *opusSeriesListModel,NSError *error))block{
    // get URL
    NSString *requestURL = [[[NSUserDefaults standardUserDefaults] objectForKey:kLastYYServerURL] stringByAppendingString:kConnSeriesList];
    NSDictionary *dic = [YYHttpHeaderManager buildHeadderWithAction:kConnSeriesList params:nil];

    NSDictionary *parameters = @{@"designerId":@(designerId),@"pageIndex":@(pageIndex),@"pageSize":@(pageSize),@"withDraft":@"false"};
    NSData *body = [parameters mj_JSONData];

    [YYRequestHelp POST:dic requestUrl:requestURL requestCount:0 requestBody:body andBlock:^(YYRspStatusAndMessage *rspStatusAndMessage,id responseObject, NSError *error, id httpResponse) {
        if (!error
            && responseObject) {
            YYOpusSeriesListModel *opusSeriesListModel = [[YYOpusSeriesListModel alloc] initWithDictionary:responseObject error:nil];
            block(rspStatusAndMessage,opusSeriesListModel,error);
            
        }else{
            block(rspStatusAndMessage,nil,error);
        }
        
    }];
}

/**
 *
 *合作设计师系列详情
 *
 */
+ (void)getConnSeriesInfoWithId:(NSInteger )designerId seriesId:(NSInteger )seriesId andBlock:(void (^)(YYRspStatusAndMessage *rspStatusAndMessage,YYSeriesInfoDetailModel *infoDetailModel,NSError *error))block{
    // get URL
    NSString *requestURL = [[[NSUserDefaults standardUserDefaults] objectForKey:kLastYYServerURL] stringByAppendingString:kConnSeriesInfo_buyer];
    NSDictionary *dic = [YYHttpHeaderManager buildHeadderWithAction:kConnSeriesInfo_buyer params:nil];

    NSDictionary *parameters = @{@"designerId":@(designerId),@"seriesId":@(seriesId)};
    NSData *body = [parameters mj_JSONData];

    [YYRequestHelp POST:dic requestUrl:requestURL requestCount:0 requestBody:body andBlock:^(YYRspStatusAndMessage *rspStatusAndMessage,id responseObject, NSError *error, id httpResponse) {
        if (!error
            && responseObject) {
            NSError *error = nil;
            YYSeriesInfoDetailModel *infoDetailModel = [[YYSeriesInfoDetailModel alloc] initWithDictionary:responseObject error:nil];
            infoDetailModel.brandDescription = [[responseObject objectForKey:@"series"] objectForKey:@"description"];
            if(![[responseObject objectForKey:@"lookBookId"] isKindOfClass:[NSNull class]]){
                infoDetailModel.series.lookBookId = [responseObject objectForKey:@"lookBookId"];
            }
            block(rspStatusAndMessage,infoDetailModel,error);
        }else{
            block(rspStatusAndMessage,nil,error);
        }
        
    }];
}

/**
 *
 * 合作设计师款式列表（带搜索）
 *
 */
+ (void)getConnStyleListWithDesignerId:(NSInteger )designerId seriesId:(NSInteger )seriesId orderBy:(NSString *)orderBy queryStr:(NSString *)queryStr pageIndex:(NSInteger )pageIndex pageSize:(NSInteger )pageSize andBlock:(void (^)(YYRspStatusAndMessage *rspStatusAndMessage,YYOpusStyleListModel *opusStyleListModel,NSError *error))block{
    // get URL
    NSString *requestURL = [[[NSUserDefaults standardUserDefaults] objectForKey:kLastYYServerURL] stringByAppendingString:kConnStyleList_buyer];
    NSDictionary *dic = [YYHttpHeaderManager buildHeadderWithAction:kConnStyleList_buyer params:nil];

    NSMutableDictionary *mutParameters = [[NSMutableDictionary alloc] init];

    [mutParameters setObject:@(designerId) forKey:@"designerId"];
    [mutParameters setObject:@(pageIndex) forKey:@"pageIndex"];
    [mutParameters setObject:@(pageSize) forKey:@"pageSize"];

    if (seriesId > 0) {
        [mutParameters setObject:@(seriesId) forKey:@"seriesId"];
    }
    
    if (orderBy
        && [orderBy length] > 0) {
        [mutParameters setObject:orderBy forKey:@"orderBy"];
    }
    
    if(![queryStr isEqualToString:@""]){
        [mutParameters setObject:queryStr forKey:@"queryStr"];
    }

    NSDictionary *parameters = [mutParameters copy];
    NSData *body = [parameters mj_JSONData];

    [YYRequestHelp POST:dic requestUrl:requestURL requestCount:0 requestBody:body andBlock:^(YYRspStatusAndMessage *rspStatusAndMessage,id responseObject, NSError *error, id httpResponse) {
        if (!error
            && responseObject) {
            YYOpusStyleListModel *opusStyleListModel = [[YYOpusStyleListModel alloc] initWithDictionary:responseObject error:nil];
            block(rspStatusAndMessage,opusStyleListModel,error);
            
        }else{
            block(rspStatusAndMessage,nil,error);
        }
        
    }];

}

/**
 *
 * 更改系列权限
 *
 */
+ (void)updateSeriesAuthType:(long)seriesId authType:(NSInteger)authType andBlock:(void (^)(YYRspStatusAndMessage *rspStatusAndMessage,NSError *error))block{
    // get URL
    NSString *requestURL = [[[NSUserDefaults standardUserDefaults] objectForKey:kLastYYServerURL] stringByAppendingString:kUpdateSeriesAuthType_buyer];
    NSDictionary *dic = [YYHttpHeaderManager buildHeadderWithAction:kUpdateSeriesAuthType_buyer params:nil];

    NSDictionary *parameters = @{@"seriesId":@(seriesId),@"authType":@(authType)};
    NSData *body = [parameters mj_JSONData];

    [YYRequestHelp POST:dic requestUrl:requestURL requestCount:0 requestBody:body andBlock:^(YYRspStatusAndMessage *rspStatusAndMessage,id responseObject, NSError *error, id httpResponse) {
        if (!error
            && responseObject) {
            
            block(rspStatusAndMessage,error);
            
        }else{
            block(rspStatusAndMessage,error);
        }
        
    }];
}

/**
 *
 *设计师系列详情
 *
 */
+ (void)getSeriesInfo:(NSInteger )seriesId andBlock:(void (^)(YYRspStatusAndMessage *rspStatusAndMessage,YYSeriesInfoDetailModel *infoDetailModel,NSError *error))block{
    // get URL
    NSString *requestURL = [[[NSUserDefaults standardUserDefaults] objectForKey:kLastYYServerURL] stringByAppendingString:kSeriesInfo_buyer];
    NSDictionary *dic = [YYHttpHeaderManager buildHeadderWithAction:kSeriesInfo_buyer params:nil];

    NSDictionary *parameters = @{@"seriesId":@(seriesId)};
    NSData *body = [parameters mj_JSONData];

    [YYRequestHelp POST:dic requestUrl:requestURL requestCount:0 requestBody:body andBlock:^(YYRspStatusAndMessage *rspStatusAndMessage,id responseObject, NSError *error, id httpResponse) {
        if (!error
            && responseObject) {
            YYSeriesInfoDetailModel *infoDetailModel = [[YYSeriesInfoDetailModel alloc] initWithDictionary:responseObject error:nil];
            infoDetailModel.brandDescription = [[responseObject objectForKey:@"series"] objectForKey:@"description"];
            block(rspStatusAndMessage,infoDetailModel,error);
        }else{
            block(rspStatusAndMessage,nil,error);
        }
        
    }];
}

@end
