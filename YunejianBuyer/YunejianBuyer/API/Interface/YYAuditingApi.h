//
//  YYAuditingApi.h
//  YunejianBuyer
//
//  Created by chuanjun sun on 2017/10/26.
//  Copyright © 2017年 Apple. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "YYRspStatusAndMessage.h"
#import "YYPerfectInfoModel.h"

@interface YYAuditingApi : NSObject

/**
 查询基本信息

 @param block 返回
 */
+ (void)getInvisibleAndBlock:(void (^)(YYRspStatusAndMessage *rspStatusAndMessage, NSDictionary *dict, NSError *error))block;

/**
 上传信息

 @param model 信息内容模型
 @param block 返回
 */
+ (void)postInvisibleWithModel:(YYPerfectInfoModel *)model AndBlock:(void (^)(YYRspStatusAndMessage *rspStatusAndMessage, NSError *error))block;
@end
