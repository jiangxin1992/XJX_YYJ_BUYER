//
//  YYInventoryApi.m
//  YunejianBuyer
//
//  Created by Apple on 16/8/26.
//  Copyright © 2016年 Apple. All rights reserved.
//

#import "YYInventoryApi.h"
#import "YYRequestHelp.h"
#import "RequestMacro.h"
#import "UserDefaultsMacro.h"
#import "YYHttpHeaderManager.h"
#import "AppDelegate.h"

@implementation YYInventoryApi
//买手店获取合作品牌
+ (void)getBrandsWithBlock:(void (^)(YYRspStatusAndMessage *rspStatusAndMessage,YYInventoryBrandListModel *brandsModel,NSError *error))block{
    // get URL
    NSString *requestURL = [[[NSUserDefaults standardUserDefaults] objectForKey:kLastYYServerURL] stringByAppendingString:kInventoryBrands];
    NSDictionary *dic = [YYHttpHeaderManager buildHeadderWithAction:kInventoryBrands params:nil];

    [YYRequestHelp POST:dic requestUrl:requestURL requestCount:0 requestBody:nil andBlock:^(YYRspStatusAndMessage *rspStatusAndMessage,id responseObject, NSError *error, id httpResponse) {
        if (!error) {
            YYInventoryBrandListModel * brandList = [[YYInventoryBrandListModel alloc] initWithDictionary:responseObject error:nil];
            block(rspStatusAndMessage,brandList,error);
        }else{
            block(rspStatusAndMessage,nil,error);
        }
    }];
}

//买手店下过单的款式
+ (void)getOrderStyles:(NSString *)designerIds query:(NSString*)query  pageIndex:(int)pageIndex pageSize:(int)pageSize adnBlock:(void (^)(YYRspStatusAndMessage *rspStatusAndMessage,YYInventoryOrderStylesModel *stylesModel,NSError *error))block{
    // get URL
    NSString *requestURL = [[[NSUserDefaults standardUserDefaults] objectForKey:kLastYYServerURL] stringByAppendingString:kInventoryOrderStyles];
    NSDictionary *dic = [YYHttpHeaderManager buildHeadderWithAction:kInventoryOrderStyles params:nil];

    NSDictionary *parameters = @{@"designerIds":designerIds,@"query":query,@"pageIndex":@(pageIndex),@"pageSize":@(pageSize)};
    NSData *body = [parameters mj_JSONData];

    [YYRequestHelp POST:dic requestUrl:requestURL requestCount:0 requestBody:body andBlock:^(YYRspStatusAndMessage *rspStatusAndMessage,id responseObject, NSError *error, id httpResponse) {
        if (!error) {
            YYInventoryOrderStylesModel * styleList = [[YYInventoryOrderStylesModel alloc] initWithDictionary:responseObject error:nil];
            block(rspStatusAndMessage,styleList,error);
        }else{
            block(rspStatusAndMessage,nil,error);
        }
    }];
}

//获取款式颜色及尺码信息
+ (void)getStyleColorInfo:(NSInteger )styleId colorIds:(NSString*)colorIds type:(NSString *)type adnBlock:(void (^)(YYRspStatusAndMessage *rspStatusAndMessage,YYInventoryStyleColorInfoModel *infoModel,NSError *error))block{
    // get URL
    NSString *requestURL = [[[NSUserDefaults standardUserDefaults] objectForKey:kLastYYServerURL] stringByAppendingString:kInventoryStyleColorInfo];
    NSDictionary *dic = [YYHttpHeaderManager buildHeadderWithAction:kInventoryStyleColorInfo params:nil];

    NSDictionary *parameters = @{@"styleId":@(styleId),@"colorIds":colorIds,@"type":type};
    NSData *body = [parameters mj_JSONData];

    [YYRequestHelp POST:dic requestUrl:requestURL requestCount:0 requestBody:body andBlock:^(YYRspStatusAndMessage *rspStatusAndMessage,id responseObject, NSError *error, id httpResponse) {
        if (!error) {
            YYInventoryStyleColorInfoModel * styleinfo = [[YYInventoryStyleColorInfoModel alloc] initWithDictionary:responseObject error:nil];
            block(rspStatusAndMessage,styleinfo,error);
        }else{
            block(rspStatusAndMessage,nil,error);
        }
    }];
}

//标记消息为已读
+(void)markAsReadOnMsg:(NSString *)msgIds adnBlock:(void (^)(YYRspStatusAndMessage *rspStatusAndMessage,NSError *error))block{
    // get URL
    NSString *requestURL = [[[NSUserDefaults standardUserDefaults] objectForKey:kLastYYServerURL] stringByAppendingString:kInventoryMarkAsRead];
    NSDictionary *dic = [YYHttpHeaderManager buildHeadderWithAction:kInventoryMarkAsRead params:nil];

    NSDictionary *parameters = nil;
    if(![NSString isNilOrEmpty:msgIds]){
        parameters = @{@"msgIds":msgIds};
    }else{
        parameters = @{@"msgIds":@"",@"clearAll":@"true"};
    }
    NSData *body = [parameters mj_JSONData];
    [YYRequestHelp POST:dic requestUrl:requestURL requestCount:0 requestBody:body andBlock:^(YYRspStatusAndMessage *rspStatusAndMessage,id responseObject, NSError *error, id httpResponse) {
        if (!error) {
            if(block){
                block(rspStatusAndMessage,error);
            }else{
                AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
                if(appDelegate.unreadInventoryAmount > 0){
                    appDelegate.unreadInventoryAmount = 0;
                    [[NSNotificationCenter defaultCenter] postNotificationName:UnreadMsgAmountChangeNotification object:nil userInfo:nil];
                }

            }
        }else{
            if(block)
            block(rspStatusAndMessage,error);
        }
    }];
}

//买手店补货公告
+ (void)getBoardList:(NSString *)designerIds month:(NSInteger)month pageIndex:(int)pageIndex pageSize:(int)pageSize queryStr:(NSString *)queryStr  adnBlock:(void (^)(YYRspStatusAndMessage *rspStatusAndMessage,YYInventoryBoardListModel *boardsModel,NSError *error))block{
    // get URL
    NSString *requestURL = [[[NSUserDefaults standardUserDefaults] objectForKey:kLastYYServerURL] stringByAppendingString:kInventoryBoard];
    NSDictionary *dic = [YYHttpHeaderManager buildHeadderWithAction:kInventoryBoard params:nil];

    NSMutableDictionary *mutParameters = [[NSMutableDictionary alloc] init];
    [mutParameters setObject:@(pageIndex) forKey:@"pageIndex"];
    [mutParameters setObject:@(pageSize) forKey:@"pageSize"];
    if(![NSString isNilOrEmpty:queryStr]){
        [mutParameters setObject:queryStr forKey:@"query"];
    }
    NSDictionary *parameters = [mutParameters copy];
    NSData *body = [parameters mj_JSONData];

    [YYRequestHelp POST:dic requestUrl:requestURL requestCount:0 requestBody:body andBlock:^(YYRspStatusAndMessage *rspStatusAndMessage,id responseObject, NSError *error, id httpResponse) {
        if (!error) {
            YYInventoryBoardListModel * boardList = [[YYInventoryBoardListModel alloc] initWithDictionary:responseObject error:nil];
            block(rspStatusAndMessage,boardList,error);
        }else{
            block(rspStatusAndMessage,nil,error);
        }
    }];
}

//发布补货需求
+(void)addDemand:(NSData *)modelData adnBlock:(void (^)(YYRspStatusAndMessage *rspStatusAndMessage,NSError *error))block{
    // get URL
    NSString *requestURL = [[[NSUserDefaults standardUserDefaults] objectForKey:kLastYYServerURL] stringByAppendingString:kInventoryDemand];
    NSDictionary *dic = [YYHttpHeaderManager buildHeadderWithAction:kInventoryDemand params:nil];

    [YYRequestHelp POST:dic requestUrl:requestURL requestCount:0 requestBody:modelData andBlock:^(YYRspStatusAndMessage *rspStatusAndMessage,id responseObject, NSError *error, id httpResponse) {
        if (!error) {
            block(rspStatusAndMessage,error);
        }else{
            block(rspStatusAndMessage,error);
        }
    }];
}
//发布库存信息
+(void)addStore:(NSData *)modelData adnBlock:(void (^)(YYRspStatusAndMessage *rspStatusAndMessage,NSError *error))block{
    // get URL
    NSString *requestURL = [[[NSUserDefaults standardUserDefaults] objectForKey:kLastYYServerURL] stringByAppendingString:kInventoryStore];
    NSDictionary *dic = [YYHttpHeaderManager buildHeadderWithAction:kInventoryStore params:nil];

    [YYRequestHelp POST:dic requestUrl:requestURL requestCount:0 requestBody:modelData andBlock:^(YYRspStatusAndMessage *rspStatusAndMessage,id responseObject, NSError *error, id httpResponse) {
        if (!error) {
            block(rspStatusAndMessage,error);
        }else{
            block(rspStatusAndMessage,error);
        }
    }];
}

//买手店我的补货列表
+ (void)getDemandList:(NSString *)designerIds month:(NSInteger)month pageIndex:(int)pageIndex pageSize:(int)pageSize queryStr:(NSString *)queryStr  adnBlock:(void (^)(YYRspStatusAndMessage *rspStatusAndMessage,YYInventoryStyleListModel *listModel,NSError *error))block{
    // get URL
    NSString *requestURL = [[[NSUserDefaults standardUserDefaults] objectForKey:kLastYYServerURL] stringByAppendingString:kInventoryDemandList];
    NSDictionary *dic = [YYHttpHeaderManager buildHeadderWithAction:kInventoryDemandList params:nil];

    NSMutableDictionary *mutParameters = [[NSMutableDictionary alloc] init];
    [mutParameters setObject:@(pageIndex) forKey:@"pageIndex"];
    [mutParameters setObject:@(pageSize) forKey:@"pageSize"];
    if(![NSString isNilOrEmpty:queryStr]){
        [mutParameters setObject:queryStr forKey:@"query"];
    }

    NSDictionary *parameters = [mutParameters copy];
    NSData *body = [parameters mj_JSONData];

    [YYRequestHelp POST:dic requestUrl:requestURL requestCount:0 requestBody:body andBlock:^(YYRspStatusAndMessage *rspStatusAndMessage,id responseObject, NSError *error, id httpResponse) {
        if (!error) {
            YYInventoryStyleListModel * listmodel = [[YYInventoryStyleListModel alloc] initWithDictionary:responseObject error:nil];
            block(rspStatusAndMessage,listmodel,error);
        }else{
            block(rspStatusAndMessage,nil,error);
        }
    }];
}

//我的库存列表
+ (void)getStoreList:(NSString *)designerIds month:(NSInteger)month pageIndex:(int)pageIndex pageSize:(int)pageSize queryStr:(NSString *)queryStr  adnBlock:(void (^)(YYRspStatusAndMessage *rspStatusAndMessage,YYInventoryStyleListModel *listModel,NSError *error))block{
    // get URL
    NSString *requestURL = [[[NSUserDefaults standardUserDefaults] objectForKey:kLastYYServerURL] stringByAppendingString:kInventoryStoreList];
    NSDictionary *dic = [YYHttpHeaderManager buildHeadderWithAction:kInventoryStoreList params:nil];

    NSMutableDictionary *mutParameters = [[NSMutableDictionary alloc] init];
    [mutParameters setObject:@(pageIndex) forKey:@"pageIndex"];
    [mutParameters setObject:@(pageSize) forKey:@"pageSize"];
    if(![NSString isNilOrEmpty:queryStr]){
        [mutParameters setObject:queryStr forKey:@"query"];
    }

    NSDictionary *parameters = [mutParameters copy];
    NSData *body = [parameters mj_JSONData];

    [YYRequestHelp POST:dic requestUrl:requestURL requestCount:0 requestBody:body andBlock:^(YYRspStatusAndMessage *rspStatusAndMessage,id responseObject, NSError *error, id httpResponse) {
        if (!error) {
            YYInventoryStyleListModel * listmodel = [[YYInventoryStyleListModel alloc] initWithDictionary:responseObject error:nil];
            block(rspStatusAndMessage,listmodel,error);
        }else{
            block(rspStatusAndMessage,nil,error);
        }
    }];
}

//删除我的补货
+(void)deleteDemand:(NSInteger)demandId adnBlock:(void (^)(YYRspStatusAndMessage *rspStatusAndMessage,NSError *error))block{
    NSString *requestURL = [[[NSUserDefaults standardUserDefaults] objectForKey:kLastYYServerURL] stringByAppendingString:kInventoryDeleteDemand];
    NSDictionary *dic = [YYHttpHeaderManager buildHeadderWithAction:kInventoryDeleteDemand params:nil];

    NSDictionary *parameters = @{@"id":@(demandId)};
    NSData *body = [parameters mj_JSONData];

    [YYRequestHelp POST:dic requestUrl:requestURL requestCount:0 requestBody:body andBlock:^(YYRspStatusAndMessage *rspStatusAndMessage,id responseObject, NSError *error, id httpResponse) {
        if (!error) {
            block(rspStatusAndMessage,error);
        }else{
            block(rspStatusAndMessage,error);
        }
    }];
}
//删除单个我的库存
+(void)deleteStore:(NSInteger)storeId adnBlock:(void (^)(YYRspStatusAndMessage *rspStatusAndMessage,NSError *error))block{
    NSString *requestURL = [[[NSUserDefaults standardUserDefaults] objectForKey:kLastYYServerURL] stringByAppendingString:kInventoryDeleteStore];
    NSDictionary *dic = [YYHttpHeaderManager buildHeadderWithAction:kInventoryDeleteStore params:nil];

    NSDictionary *parameters = @{@"id":@(storeId)};
    NSData *body = [parameters mj_JSONData];

    [YYRequestHelp POST:dic requestUrl:requestURL requestCount:0 requestBody:body andBlock:^(YYRspStatusAndMessage *rspStatusAndMessage,id responseObject, NSError *error, id httpResponse) {
        if (!error) {
            block(rspStatusAndMessage,error);
        }else{
            block(rspStatusAndMessage,error);
        }
    }];
}

//修改补货需求
+(void)modifyDemand:(NSInteger)demandId amount:(NSInteger)amount adnBlock:(void (^)(YYRspStatusAndMessage *rspStatusAndMessage,NSError *error))block{
    NSString *requestURL = [[[NSUserDefaults standardUserDefaults] objectForKey:kLastYYServerURL] stringByAppendingString:kInventoryModifyDemand];
    NSDictionary *dic = [YYHttpHeaderManager buildHeadderWithAction:kInventoryModifyDemand params:nil];

    NSDictionary *parameters = @{@"id":@(demandId),@"amount":@(amount)};
    NSData *body = [parameters mj_JSONData];

    [YYRequestHelp POST:dic requestUrl:requestURL requestCount:0 requestBody:body andBlock:^(YYRspStatusAndMessage *rspStatusAndMessage,id responseObject, NSError *error, id httpResponse) {
        if (!error) {
            block(rspStatusAndMessage,error);
        }else{
            block(rspStatusAndMessage,error);
        }
    }];
}
//修改我有库存
+(void)modifyStore:(NSInteger)storeId amount:(NSInteger)amount adnBlock:(void (^)(YYRspStatusAndMessage *rspStatusAndMessage,NSError *error))block{
    NSString *requestURL = [[[NSUserDefaults standardUserDefaults] objectForKey:kLastYYServerURL] stringByAppendingString:kInventoryModifyStore];
    NSDictionary *dic = [YYHttpHeaderManager buildHeadderWithAction:kInventoryModifyStore params:nil];

    NSDictionary *parameters = @{@"id":@(storeId),@"amount":@(amount)};
    NSData *body = [parameters mj_JSONData];

    [YYRequestHelp POST:dic requestUrl:requestURL requestCount:0 requestBody:body andBlock:^(YYRspStatusAndMessage *rspStatusAndMessage,id responseObject, NSError *error, id httpResponse) {
        if (!error) {
            block(rspStatusAndMessage,error);
        }else{
            block(rspStatusAndMessage,error);
        }
    }];
}
@end
