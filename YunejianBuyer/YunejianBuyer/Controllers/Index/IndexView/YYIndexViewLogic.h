//
//  YYIndexViewLogic.h
//  YunejianBuyer
//
//  Created by yyj on 2018/8/24.
//  Copyright © 2018年 Apple. All rights reserved.
//

#import "YYBaseLogic.h"

#import "YYIndexViewProtocol.h"

@class YYOrderingListModel,YYBrandHomeInfoModel,YYHotDesignerBrandsModel,YYSeriesInfoDetailModel,YYStyleInfoModel;

@interface YYIndexViewLogic : YYBaseLogic

/** banner列表 */
@property (nonatomic, strong) NSArray *bannerListModelArray;
/** YCO 订货会 */
@property (nonatomic, strong) YYOrderingListModel *orderingListModel;
/** 热门品牌 */
@property (nonatomic, strong) NSArray *hotDesignerBrandsModelArray;

//数据请求有没有成功过 用于判断当前视图状态
@property (nonatomic, assign) BOOL bannerListHaveBeenSuccessful;
@property (nonatomic, assign) BOOL orderingListHaveBeenSuccessful;
@property (nonatomic, assign) BOOL hotDesignerBrandsHaveBeenSuccessful;

@property (nonatomic, assign) NSInteger requestCount;
@property (nonatomic, assign) BOOL isHeadRefresh;
@property (nonatomic, assign) BOOL isFirstLoad;

@property (nonatomic, weak) id<YYIndexViewProtocol> delegate;

/**
 YYIndexViewController 是否允许渲染
 * 三类数据都曾获取成功过，才允许渲染
 */
-(BOOL)isAllowRendering;

/**
 更新一下未读消息
 */
-(void)checkNoticeCount;

/**
 获取首页banner
 */
-(void)loadBannerInfo;

/**
 获取首页订货会列表
 */
-(void)loadIndexOrderingInfo;

/**
 获取热门品牌列表
 */
-(void)loadHotBrandsList;

/**
 获取banner对应的设计师信息
 */
-(void)getDesignerHomeInfoWithDesignerId:(NSInteger)designerId;

@property (nonatomic, strong) YYBrandHomeInfoModel *bannerDesignerHomeInfoModel;

/**
 修改当前用户与品牌的关联状态 添加
 */
-(void)connInviteByDesignerBrandsModel:(YYHotDesignerBrandsModel *)hotDesignerBrandsModel;

/**
 获取系列详情
 */
-(void)getConnSeriesInfoWithDesignerId:(NSInteger)designerId WithSeriesID:(NSInteger)seriesId;

@property (nonatomic, strong) YYSeriesInfoDetailModel *seriesInfoModel;

/**
 获取款式信息
 */
-(void)getStyleInfoByStyleId:(NSInteger)styleId;

@property (nonatomic, strong) YYStyleInfoModel *styleInfoModel;

@end
