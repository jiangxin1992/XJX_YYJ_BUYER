//
//  YYWarehouseRecordModel.h
//  YunejianBuyer
//
//  Created by Victor on 2018/7/19.
//  Copyright © 2018年 Apple. All rights reserved.
//

#import <JSONModel/JSONModel.h>
#import "YYWarehouseStyleModel.h"

@protocol YYWarehouseRecordModel @end

@interface YYWarehouseRecordModel : JSONModel

@property (nonatomic, strong) NSString <Optional>*incomingBill;
@property (nonatomic, strong) NSString <Optional>*incomingType;
@property (nonatomic, strong) NSString <Optional>*warehouseName;
@property (nonatomic, strong) NSString <Optional>*creatorName;
@property (nonatomic, strong) NSNumber <Optional>*itemCount;
@property (nonatomic, strong) NSNumber <Optional>*createdTime;
@property (nonatomic, strong) NSNumber <Optional>*purchaseOrderId;
@property (nonatomic, strong) NSArray <YYWarehouseStyleModel, Optional, ConvertOnDemand>*incomingSubBos;

@property (nonatomic, strong) NSString <Ignore>*incomingName;

+ (NSString *)getIncomingTypeForName:(NSString *)incomingName;
+ (NSString *)getIncomingNameForType:(NSString *)incomingType;

@end
