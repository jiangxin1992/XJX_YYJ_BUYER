//
//  YYHotDesignerBrandsModel.h
//  YunejianBuyer
//
//  Created by yyj on 2017/11/7.
//  Copyright © 2017年 Apple. All rights reserved.
//

#import <JSONModel/JSONModel.h>

@protocol YYHotDesignerBrandsModel @end

#import "YYHotDesignerBrandsSeriesModel.h"

@interface YYHotDesignerBrandsModel : JSONModel

/** 款式数量 */
@property (strong, nonatomic) NSNumber <Optional>*styleCount;
/** 品牌下的系列信息 */
@property (strong, nonatomic) NSArray <YYHotDesignerBrandsSeriesModel,Optional, ConvertOnDemand>*seriesBoList;
/** 系列数量 */
@property (strong, nonatomic) NSNumber <Optional>*seriesCount;
/** 当前用户与该品牌的关联状态  -1 没有关系  0 我已发送邀请，对方未处理  1 已为好友 2 对方已发出邀请，我未处理*/
@property (strong, nonatomic) NSNumber <Optional>*connectStatus;
/** 品牌简介 */
@property (strong, nonatomic) NSString <Optional>*brandDescription;
/** 品牌邮箱 */
@property (strong, nonatomic) NSString <Optional>*email;
/** 品牌名 */
@property (strong, nonatomic) NSString <Optional>*brandName;
/** 品牌logo */
@property (strong, nonatomic) NSString <Optional>*logo;
/** 品牌id */
@property (strong, nonatomic) NSNumber <Optional>*designerId;

@property (strong, nonatomic) NSNumber <Optional>*seriesBoListNum;

@end
