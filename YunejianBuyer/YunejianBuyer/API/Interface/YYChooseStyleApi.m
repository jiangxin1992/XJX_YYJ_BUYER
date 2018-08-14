//
//  YYChooseStyleApi.m
//  YunejianBuyer
//
//  Created by yyj on 2017/7/5.
//  Copyright © 2017年 Apple. All rights reserved.
//

#import "YYChooseStyleApi.h"

// c文件 —> 系统文件（c文件在前）

// 控制器

// 自定义视图

// 接口

// 分类

// 自定义类和三方类（ cocoapods类 > model > 工具类 > 其他）
#import "RequestMacro.h"
#import "YYRequestHelp.h"
#import "YYHttpHeaderManager.h"

#import "YYChooseStyleReqModel.h"
#import "YYChooseStyleListModel.h"

@implementation YYChooseStyleApi

//获取款式列表
+ (void)getOrderingListWithReqModel:(YYChooseStyleReqModel *)reqModel pageIndex:(int)pageIndex pageSize:(int)pageSize andBlock:(void (^)(YYRspStatusAndMessage *rspStatusAndMessage,YYChooseStyleListModel *chooseStyleListModel,NSError *error))block{
    // get URL
    NSString *requestURL = [[[NSUserDefaults standardUserDefaults] objectForKey:kLastYYServerURL] stringByAppendingString:kChooseStyleList];
    NSDictionary *dic = [YYHttpHeaderManager buildHeadderWithAction:kChooseStyleList params:nil];

    NSDictionary *parameters = [reqModel getRequestParamsStringWithPageIndex:pageIndex pageSize:pageSize];
    NSData *body = [parameters mj_JSONData];
    
    [YYRequestHelp POST:dic requestUrl:requestURL requestCount:0 requestBody:body andBlock:^(YYRspStatusAndMessage *rspStatusAndMessage,id responseObject, NSError *error, id httpResponse) {
        if (!error
            && responseObject) {
            YYChooseStyleListModel *chooseStyleListModel = [[YYChooseStyleListModel alloc] initWithDictionary:responseObject error:nil];
            block(rspStatusAndMessage,chooseStyleListModel,error);
            
        }else{
            block(rspStatusAndMessage,nil,error);
        }
        
    }];
}

@end
