//
//  YYWarehouseRecordResponse.h
//  YunejianBuyer
//
//  Created by Victor on 2018/7/19.
//  Copyright © 2018年 Apple. All rights reserved.
//

#import <JSONModel/JSONModel.h>
#import "YYPageInfoModel.h"
#import "YYWarehouseRecordModel.h"

@interface YYWarehouseRecordResponse : JSONModel

@property (nonatomic, strong) YYPageInfoModel <Optional>*pageInfo;
@property (nonatomic, strong) NSArray <YYWarehouseRecordModel, Optional>*result;

@end
