//
//  YYConnApi.h
//  Yunejian
//
//  Created by Apple on 15/12/1.
//  Copyright © 2015年 yyj. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "YYRspStatusAndMessage.h"
#import "YYConnBuyerListModel.h"
#import "YYConnBrandInfoListModel.h"
#import "YYConnDesignerListModel.h"
#import "YYNewConnDesignerListModel.h"
#import "YYBuyerListModel.h"
#import "YYConClass.h"
#import "YYConNewBrandModel.h"
@interface YYConnApi : NSObject
//设计师添加买手店(买手添加设计师)
+ (void)invite:(NSInteger )guestId andBlock:(void (^)(YYRspStatusAndMessage *rspStatusAndMessage,NSError *error))block;
//设计师合作的买手店（所有）
+ (void)getConnBuyers:(NSInteger)status pageIndex:(int)pageIndex pageSize:(int)pageSize andBlock:(void (^)(YYRspStatusAndMessage *rspStatusAndMessage,YYConnBuyerListModel *listModel,NSError *error))block;
//设计师对买手合作关系的操作（原设计师移除与买手店的合作关系接口） 1->同意邀请	2->拒绝邀请	3->移除合作
+ (void)OprateConnWithBuyer:(NSInteger)buyerId status:(NSInteger)status andBlock:(void (^)(YYRspStatusAndMessage *rspStatusAndMessage,NSError *error))block;
//对设计师的邀请请求操作
+ (void)OprateConnWithDesignerBrand:(NSInteger)designerId status:(NSInteger)status andBlock:(void (^)(YYRspStatusAndMessage *rspStatusAndMessage,NSError *error))block;
//正在被邀请的品牌(收到的邀请<设计师品牌列表>)1 买手店的所有合作品牌2
+ (void)getConnBrands:(NSInteger)type andPageIndex:(NSInteger )pageIndex andBlock:(void (^)(YYRspStatusAndMessage *rspStatusAndMessage,YYConnBrandInfoListModel *listModel,NSError *error))block;
//买手店按条件查询所有设计师(带分页,)
+ (void)queryDesignerWithQueryStr:(NSString *)queryStr pageIndex:(int)pageIndex pageSize:(int)pageSize andBlock:(void (^)(YYRspStatusAndMessage *rspStatusAndMessage,YYConnDesignerListModel *designerListModel,NSError *error))block;
+ (void)queryDesignerWithQueryStr:(NSString *)queryStr WithSuitIds:(NSString *)suitIds WithPeopleIds:(NSString *)peopleIds pageIndex:(int)pageIndex pageSize:(int)pageSize andBlock:(void (^)(YYRspStatusAndMessage *rspStatusAndMessage,YYNewConnDesignerListModel *designerListModel,NSError *error))block;
//获取分类
+(void)getConBrandClassWithBlock:(void (^)(YYRspStatusAndMessage *rspStatusAndMessage,YYConClass *connClass,NSError *error))block;
//获取最新入驻品牌
+(void)getConNewBrandWithBlock:(void (^)(YYRspStatusAndMessage *rspStatusAndMessage,YYConNewBrandModel *newBrandModel,NSError *error))block;
//设计师按条件查询所有买手店(带分页,目前邀请状态)
+(void) queryConnBuyer:(NSString *)queryStr andBlock:(void(^)(YYRspStatusAndMessage *rspStatusAndMessage,YYBuyerListModel *buyerList,NSError *error))block;
//查询最新入驻品牌是否有更新
+ (void)hasNewBrandsWithBlock:(void (^)(YYRspStatusAndMessage *rspStatusAndMessage,BOOL hasNewBrands ,NSError *error))block;
//清除最新入驻品牌的消息
+ (void)clearNewBrands;
@end
