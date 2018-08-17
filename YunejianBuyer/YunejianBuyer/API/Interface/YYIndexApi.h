//
//  YYIndexApi.h
//  YunejianBuyer
//
//  Created by yyj on 2017/8/8.
//  Copyright © 2017年 Apple. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "YYRspStatusAndMessage.h"

#import "YYLatestSeriesListModel.h"
#import "YYRecommendDesignerBrandsModel.h"
#import "YYDueBrandsModel.h"
#import "YYHotDesignerBrandsModel.h"
#import "YYBannerModel.h"

@interface YYIndexApi : NSObject

/**
 获取首页banner list

 @param block ..
 */
+ (void)getBannerListWithBlock:(void (^)(YYRspStatusAndMessage *rspStatusAndMessage, NSArray *returnArr, NSError *error))block;

/**
  获取首页推荐品牌 list

 @param platform buyer brand pad
 @param block ..
 */
+ (void)getRecommendDesignerBrandsWithPlatform:(NSString *)platform andBlock:(void (^)(YYRspStatusAndMessage *rspStatusAndMessage, NSArray *returnArr, NSError *error))block;

/**
 获取首页最新系列 list

 @param block ..
 */
+ (void)getLatestSeriesListPageIndex:(int)pageIndex pageSize:(int)pageSize andBlock:(void (^)(YYRspStatusAndMessage *rspStatusAndMessage, YYLatestSeriesListModel *latestSeriesListModel, NSError *error))block;

/**
 获取热门品牌列表 list

 @param block ...
 */
+ (void)getHotBrandsListWithBlock:(void (^)(YYRspStatusAndMessage *rspStatusAndMessage, NSArray *hotList, NSError *error))block;

@end
