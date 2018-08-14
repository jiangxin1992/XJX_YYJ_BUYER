//
//  YYDueBrandsModel.h
//  YunejianBuyer
//
//  Created by yyj on 2017/8/8.
//  Copyright © 2017年 Apple. All rights reserved.
//
//首页最晚下单日model
#import <JSONModel/JSONModel.h>

@protocol YYDueBrandsModel @end

@interface YYDueBrandsModel : JSONModel

/** 品牌名称 */
@property (strong, nonatomic) NSString <Optional>*brandName;
/** 系列名称，为 null 时表示是多系列 */
@property (strong, nonatomic) NSString <Optional>*seriesName;
/** 设计师 id */
@property (strong, nonatomic) NSNumber <Optional>*designerId;
/** 剩余天数 */
@property (strong, nonatomic) NSNumber <Optional>*daysLeft;
/** 系列个数 */
@property (strong, nonatomic) NSNumber <Optional>*seriesCount;
/** 品牌logo */
@property (strong, nonatomic) NSString <Optional>*brandLogo;
/** 设计师email */
@property (strong, nonatomic) NSString <Optional>*email;

@end
