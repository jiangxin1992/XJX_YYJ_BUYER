//
//  YYAuditingApi.m
//  YunejianBuyer
//
//  Created by chuanjun sun on 2017/10/26.
//  Copyright © 2017年 Apple. All rights reserved.
//

#import "YYAuditingApi.h"

#import "YYRequestHelp.h"
#import "YYHttpHeaderManager.h"

@implementation YYAuditingApi
/**
 * 查询基本信息
 */
+ (void)getInvisibleAndBlock:(void (^)(YYRspStatusAndMessage *rspStatusAndMessage, NSDictionary *dict, NSError *error))block{
    // get URL
    NSString *requestURL = [[[NSUserDefaults standardUserDefaults] objectForKey:kLastYYServerURL] stringByAppendingString:KGetInvisibleInfo];
    // 传入的值都没用
    NSDictionary *dic = [YYHttpHeaderManager buildHeadderWithAction:KGetInvisibleInfo params:nil];

    NSDictionary *parameters = @{@"platform":@"IOS"};
    NSData *body = [parameters mj_JSONData];

    [YYRequestHelp GET:dic requestUrl:requestURL requestCount:0 requestBody:body andBlock:^(YYRspStatusAndMessage *rspStatusAndMessage, id responseObject, NSError *error, id httpResponse) {
        if (block) {
            block(rspStatusAndMessage, responseObject, error);
        }
    }];
}

+ (void)postInvisibleWithModel:(YYPerfectInfoModel *)model AndBlock:(void (^)(YYRspStatusAndMessage *, NSError *))block{
    // get URL
    NSString *requestURL = [[[NSUserDefaults standardUserDefaults] objectForKey:kLastYYServerURL] stringByAppendingString:KPostInvisibleInfo];
    // 传入的值都没用
    NSDictionary *dic = [YYHttpHeaderManager buildHeadderWithAction:KPostInvisibleInfo params:nil];
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithDictionary:dic];
    [dict setValue:@"application/json" forKey:@"Content-Type"];

    NSData *jsondata = [[model mj_JSONObject] mj_JSONData];

    [YYRequestHelp POST:dict requestUrl:requestURL requestCount:0 requestBody:jsondata andBlock:^(YYRspStatusAndMessage *rspStatusAndMessage, id responseObject, NSError *error, id httpResponse) {
        if (block) {
            block(rspStatusAndMessage, error);
        }
    }];

}


@end
