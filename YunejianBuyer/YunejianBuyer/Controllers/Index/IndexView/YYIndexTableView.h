//
//  YYIndexTableView.h
//  YunejianBuyer
//
//  Created by yyj on 2018/8/24.
//  Copyright © 2018年 Apple. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, YYIndexTableViewUserActionType)
{
    YYIndexTableViewUserActionTypeMoreOrdering,//查看更多订货会
    YYIndexTableViewUserActionTypeMoreOrder,//查看更多订单 index
    YYIndexTableViewUserActionTypeMoreBrandByPush,//查看更多品牌 push
    YYIndexTableViewUserActionTypeMoreBrandByNot,//查看更多品牌 not
    YYIndexTableViewUserActionTypeEnterOrderingDetail,//进入订货会详情 YYOrderingListItemModel
    YYIndexTableViewUserActionTypeFillInformation,//进入完善资料页面
    YYIndexTableViewUserActionTypeEnterDesignerHomePage,//进入品牌主页 YYRecommendDesignerBrandsModel
    YYIndexTableViewUserActionTypeEnterSeriesDetail,//进入系列详情 designerId seriesID
    YYIndexTableViewUserActionTypeChangeStatus,//修改当前用户与品牌的关联状态
    YYIndexTableViewUserActionTypeEnterIndexBannerDetail//跳转banner详情页
};

@class YYIndexViewLogic,YYOrderingListItemModel,YYHotDesignerBrandsModel,YYHotDesignerBrandsSeriesModel;

@interface YYIndexTableView : UITableView

@property (nonatomic, strong) YYIndexViewLogic *indexViewLogic;

/**
 * type YYIndexTableViewUserActionType
 * orderIndex                    ----> YYIndexTableViewUserActionTypeMoreOrder//查看更多订单 | YYIndexTableViewUserActionTypeEnterIndexBannerDetail//跳转banner详情页
 * orderingListItemModel         ----> YYIndexTableViewUserActionTypeEnterOrderingDetail//进入订货会详情
 * YYHotDesignerBrandsModel      ----> YYIndexTableViewUserActionTypeEnterDesignerHomePage//进入品牌主页 | YYIndexTableViewUserActionTypeChangeStatus//修改当前用户与品牌的关联状态
 * seriesModel                   ----> YYIndexTableViewUserActionTypeEnterSeriesDetail//进入系列详情
 */
@property (nonatomic, copy) void (^indexTableViewBlock)(YYIndexTableViewUserActionType type, NSInteger index, YYOrderingListItemModel *orderingListItemModel, YYHotDesignerBrandsModel *hotDesignerBrandsModel, YYHotDesignerBrandsSeriesModel *seriesModel);

@property (nonatomic, copy) void (^headerWithRefreshingBlock)(void);

/**
 reload/update
 */
-(void)reloadTableData;

/**
 停止下拉或加载
 */
-(void)endRefreshing;

@end
