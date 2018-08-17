//
//  YYIndexApi.m
//  YunejianBuyer
//
//  Created by yyj on 2017/8/8.
//  Copyright © 2017年 Apple. All rights reserved.
//

#import "YYIndexApi.h"

#import "YYHttpHeaderManager.h"

#import "YYRequestHelp.h"
#import "RequestMacro.h"
#import "UserDefaultsMacro.h"

@implementation YYIndexApi

+ (void)getBannerListWithBlock:(void (^)(YYRspStatusAndMessage *rspStatusAndMessage, NSArray *returnArr, NSError *error))block{

    NSString *requestURL = [[[NSUserDefaults standardUserDefaults] objectForKey:kLastYYServerURL] stringByAppendingString:kBannerList];
    NSDictionary *dic = [YYHttpHeaderManager buildHeadderWithAction:kBannerList params:nil];

    [YYRequestHelp GET:dic requestUrl:requestURL requestCount:0 requestBody:nil andBlock:^(YYRspStatusAndMessage *rspStatusAndMessage,id responseObject, NSError *error, id httpResponse) {
        if (!error) {
            NSArray *tempArr = [[YYBannerModel arrayOfModelsFromDictionaries:responseObject error:nil] copy];
            block(rspStatusAndMessage,tempArr,error);
        }else{
            block(rspStatusAndMessage,nil,error);
        }
    }];
}

+ (void)getRecommendDesignerBrandsWithPlatform:(NSString *)platform andBlock:(void (^)(YYRspStatusAndMessage *rspStatusAndMessage, NSArray *returnArr, NSError *error))block{

    NSString *requestURL = [[[NSUserDefaults standardUserDefaults] objectForKey:kLastYYServerURL] stringByAppendingString:KRecommendDesignerBrands];
    NSDictionary *dic = [YYHttpHeaderManager buildHeadderWithAction:KRecommendDesignerBrands params:nil];

    NSDictionary *parameters = @{@"clientType":platform};
    NSData *body = [parameters mj_JSONData];

    [YYRequestHelp GET:dic requestUrl:requestURL requestCount:0 requestBody:body andBlock:^(YYRspStatusAndMessage *rspStatusAndMessage,id responseObject, NSError *error, id httpResponse) {
        if (!error) {
            NSArray *tempArr = [[YYRecommendDesignerBrandsModel arrayOfModelsFromDictionaries:responseObject error:nil] copy];
            block(rspStatusAndMessage,tempArr,error);
        }else{
            block(rspStatusAndMessage,nil,error);
        }
    }];
}

+ (void)getLatestSeriesListPageIndex:(int)pageIndex pageSize:(int)pageSize andBlock:(void (^)(YYRspStatusAndMessage *rspStatusAndMessage, YYLatestSeriesListModel *latestSeriesListModel, NSError *error))block{

    NSString *requestURL = [[[NSUserDefaults standardUserDefaults] objectForKey:kLastYYServerURL] stringByAppendingString:KLatestSeries];
    NSDictionary *dic = [YYHttpHeaderManager buildHeadderWithAction:KLatestSeries params:nil];

    NSDictionary *parameters = @{@"pageIndex":@(pageIndex),@"pageSize":@(pageSize)};
    NSData *body = [parameters mj_JSONData];

    [YYRequestHelp GET:dic requestUrl:requestURL requestCount:0 requestBody:body andBlock:^(YYRspStatusAndMessage *rspStatusAndMessage,id responseObject, NSError *error, id httpResponse) {
        if (!error) {
            YYLatestSeriesListModel *listModel = [[YYLatestSeriesListModel alloc] initWithDictionary:responseObject error:nil];
            block(rspStatusAndMessage,listModel,error);
        }else{
            block(rspStatusAndMessage,nil,error);
        }
    }];
}

+ (void)getHotBrandsListWithBlock:(void (^)(YYRspStatusAndMessage *rspStatusAndMessage, NSArray *hotList, NSError *error))block{

    NSString *requestURL = [[[NSUserDefaults standardUserDefaults] objectForKey:kLastYYServerURL] stringByAppendingString:KRecommendBrands];
    NSDictionary *dic = [YYHttpHeaderManager buildHeadderWithAction:KRecommendBrands params:nil];

    [YYRequestHelp GET:dic requestUrl:requestURL requestCount:0 requestBody:nil andBlock:^(YYRspStatusAndMessage *rspStatusAndMessage,id responseObject, NSError *error, id httpResponse) {
        if (!error) {
            NSArray *tempArr = [[YYHotDesignerBrandsModel arrayOfModelsFromDictionaries:responseObject error:nil] copy];
            block(rspStatusAndMessage,tempArr,error);
        }else{
            block(rspStatusAndMessage,nil,error);
        }
    }];
}
@end
