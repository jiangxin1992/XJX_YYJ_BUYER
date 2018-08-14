//
//  YYLatestSeriesModel.h
//  YunejianBuyer
//
//  Created by yyj on 2017/8/8.
//  Copyright © 2017年 Apple. All rights reserved.
//

#import <JSONModel/JSONModel.h>

@protocol YYLatestSeriesModel @end

@interface YYLatestSeriesModel : JSONModel

/** 系列封面 */
@property (strong, nonatomic) NSString <Optional>*albumImg;
/** 品牌名称 */
@property (strong, nonatomic) NSString <Optional>*brandName;
/** 价格区间高值 */
@property (strong, nonatomic) NSNumber <Optional>*high;
/** 价格区间低值 */
@property (strong, nonatomic) NSNumber <Optional>*low;
/** 0：单币种，1：多币种 */
@property (strong, nonatomic) NSNumber <Optional>*mutiCurType;
/** 系列id */
@property (strong, nonatomic) NSNumber <Optional>*seriesId;
/** 系列名称 */
@property (strong, nonatomic) NSString <Optional>*seriesName;
/** 款式数量 */
@property (strong, nonatomic) NSNumber <Optional>*styleAmount;
/** 品牌 logo */
@property (strong, nonatomic) NSString <Optional>*logoPath;
/** 设计师名 */
@property (strong, nonatomic) NSString <Optional>*designerName;
/** 设计师email */
@property (strong, nonatomic) NSString <Optional>*email;
/** 设计师id */
@property (strong, nonatomic) NSNumber <Optional>*designerId;

@end
