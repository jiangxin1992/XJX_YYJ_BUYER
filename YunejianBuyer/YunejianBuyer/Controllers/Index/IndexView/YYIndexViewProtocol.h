//
//  YYIndexViewProtocol.h
//  YunejianBuyer
//
//  Created by yyj on 2018/8/24.
//  Copyright © 2018年 Apple. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, YYLogicAPIType)
{
    YYLogicAPITypeBannerList,        //获取首页banner
    YYLogicAPITypeOrderingList,      //获取首页订货会列表
    YYLogicAPITypeHotDesignerBrands, //获取热门品牌列表
    YYLogicAPITypeDesignerHomeInfo,  //获取banner对应的设计师信息
    YYLogicAPITypeConnInvite,        //修改当前用户与品牌的关联状态 添加
    YYLogicAPITypeSeriesDetail,      //获取系列详情
    YYLogicAPITypeSweepToStyleInfo,  //获取款式信息
};

@protocol YYIndexViewProtocol <NSObject>

- (void)requestDataCompletedWithType:(YYLogicAPIType)logicAPIType;//success

@optional

- (void)requestDataErrorWithType:(YYLogicAPIType)logicAPIType WithError:(NSError *)error;//unsuccess response

- (void)requestDataFailureWithType:(YYLogicAPIType)logicAPIType;//maybe network error

@end
