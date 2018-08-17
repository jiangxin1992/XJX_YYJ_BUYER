//
//  YYChooseStyleApi.h
//  YunejianBuyer
//
//  Created by yyj on 2017/7/5.
//  Copyright © 2017年 Apple. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "YYRspStatusAndMessage.h"

@class YYChooseStyleListModel,YYChooseStyleReqModel;

@interface YYChooseStyleApi : NSObject

//获取款式列表
+ (void)getOrderingListWithReqModel:(YYChooseStyleReqModel *)reqModel pageIndex:(int)pageIndex pageSize:(int)pageSize andBlock:(void (^)(YYRspStatusAndMessage *rspStatusAndMessage,YYChooseStyleListModel *chooseStyleListModel,NSError *error))block;

@end
