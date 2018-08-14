//
//  YYOrderingHistoryListItemModel.h
//  YunejianBuyer
//
//  Created by yyj on 2017/6/2.
//  Copyright © 2017年 Apple. All rights reserved.
//

#import <JSONModel/JSONModel.h>

@protocol YYOrderingHistoryListItemModel @end

@interface YYOrderingHistoryListItemModel : JSONModel

//地址
@property (nonatomic,strong) NSString *address;
//申请日期
@property (nonatomic,strong) NSNumber *applyTime;
//订货会ID
@property (nonatomic,strong) NSNumber *appointmentId;
//预约的ID
@property (nonatomic,strong) NSNumber *id;
//订货会名称
@property (nonatomic,strong) NSString *name;
//封面
@property (nonatomic,strong) NSString *poster;
//营业时间
@property (nonatomic,strong) NSString *range;
//营业类型
@property (nonatomic,strong) NSString *rangeType;
//申请订货会 选择去的日期 手机用selecedDateLong
@property (nonatomic,strong) NSString *selecedDate;
@property (nonatomic,strong) NSNumber *selecedDateLong;
//状态T
//TO_BE_VERIFIED,// 待审核
//VERIFIED,// 预约成功
//REJECTED,// 预约失败
//INVALIDATED,// 已失效
//CANCELLED,// 已取消
@property (nonatomic,copy) NSString *status;

@property (strong, nonatomic) NSString <Optional>*coordinate;//经纬度 "30.3876845271,120.2960415788"

@property (strong, nonatomic) NSString <Optional>*coordinateBaidu;//经纬度 "30.3876845271,120.2960415788" 百度

@end
