//
//  AliPayHelper.h
//
//
//  Created by 毛灵辉 on 15/8/4.
//  Copyright (c) 2015年 yourentang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AppDelegate.h"
#import "YYRspStatusAndMessage.h"
@interface AliPayHelper : NSObject
// 先调这个方法来获取服务器的数据
+ (void)requestWithParamsData:(NSData *)data andBlock:(void (^)(YYRspStatusAndMessage *rspStatusAndMessage,NSDictionary *order,NSError *error))block;

// 再调这个方法来调起支付宝
// 参数：一，调用- (void)requestWithParamsData:(NSData *)data
// completion:(httpCompletionBlock)completion
// errorBlock:(httpCompletionBlock)errorBlock 所返回来的参数
// resultNumber 有以下几种状态：
+ (void)alixPayWithResponse:(NSDictionary *)response
                 completion:(void (^)(void))completion;

// 在appdelegate中调用
+ (void)handleOpenURL:(NSURL *)url application:(AppDelegate *)application;
@end
