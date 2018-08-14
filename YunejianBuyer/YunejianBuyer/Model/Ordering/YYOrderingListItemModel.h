//
//  YYOrderingListItemModel.h
//  YunejianBuyer
//
//  Created by yyj on 2017/5/31.
//  Copyright © 2017年 Apple. All rights reserved.
//

#import <JSONModel/JSONModel.h>

@protocol YYOrderingListItemModel @end

@interface YYOrderingListItemModel : JSONModel

@property (strong, nonatomic) NSString <Optional>*city;//城市
@property (strong, nonatomic) NSNumber <Optional>*startDate;//开始时间
@property (strong, nonatomic) NSNumber <Optional>*endDate;//结束时间
@property (strong, nonatomic) NSNumber <Optional>*id;//":1,
@property (strong, nonatomic) NSString <Optional>*name;//订货会名称
@property (strong, nonatomic) NSString <Optional>*poster;//封面
@property (strong, nonatomic) NSString <Optional>*range;//营业时间 web用的 移动端不建议用
@property (strong, nonatomic) NSString <Optional>*rangeTime;//营业时间 移动端用的
@property (strong, nonatomic) NSString <Optional>*rangeType;//营业类型
@property (strong, nonatomic) NSString <Optional>*status;//当前状态
@property (strong, nonatomic) NSString <Optional>*address;//地址
@property (strong, nonatomic) NSString <Optional>*coordinate;//经纬度 "30.3876845271,120.2960415788" 高德
@property (strong, nonatomic) NSString <Optional>*coordinateBaidu;//经纬度 "30.3876845271,120.2960415788" 百度


@end
