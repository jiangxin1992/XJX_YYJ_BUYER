//
//  YYIndexManageModel.h
//  YunejianBuyer
//
//  Created by yyj on 2017/8/8.
//  Copyright © 2017年 Apple. All rights reserved.
//
//首页管理类
#import <Foundation/Foundation.h>

#import "YYBannerModel.h"
#import "YYDueBrandsModel.h"
#import "YYOrderingListModel.h"
#import "YYRecommendDesignerBrandsModel.h"
#import "YYLatestSeriesListModel.h"

@interface YYIndexManageModel : NSObject

/** banner列表 */
@property (strong, nonatomic) NSArray *bannerListModelArray;
/** YCO 订货会 */
@property (nonatomic,strong) YYOrderingListModel *orderingListModel;
/** 热门品牌 */
@property (strong, nonatomic) NSArray *hotDesignerBrandsModelArray;
/** 推荐品牌 */
//@property (strong, nonatomic) NSArray *recommendDesignerBrandsModelArray;

/** 最新系列 */
//@property (strong, nonatomic) YYPageInfoModel *latestSeriesListCurrentPageInfo;
//@property (nonatomic,strong) NSMutableArray *latestSeriesListArray;

//数据请求有没有成功过 用于判断当前视图状态
@property (nonatomic,assign) BOOL bannerDataHaveBeenSuccessful;
@property (nonatomic,assign) BOOL orderingDataHaveBeenSuccessful;
@property (nonatomic,assign) BOOL hotDesignerBrandsDataHaveBeenSuccessful;
//@property (nonatomic,assign) BOOL recommendDesignerBrandsDataHaveBeenSuccessful;
//@property (nonatomic,assign) BOOL latestSeriesDataHaveBeenSuccessful;

/**
 YYIndexViewController 是否允许渲染
 * 三类数据都曾获取成功过，才允许渲染
 */
-(BOOL )isAllowRendering;

/**
 初始化
 */
+(instancetype )initModel;

@end
