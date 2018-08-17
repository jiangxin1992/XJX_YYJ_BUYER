//
//  YYWarehouseRequestModel.h
//  YunejianBuyer
//
//  Created by Victor on 2018/7/19.
//  Copyright © 2018年 Apple. All rights reserved.
//

#import "YYPageRequestModel.h"

@interface YYWarehouseRequestModel : YYPageRequestModel

@property (nonatomic, strong) NSString <Optional>*styleName;
@property (nonatomic, strong) NSString <Optional>*source;
@property (nonatomic, strong) NSString <Optional>*incomingBill;
@property (nonatomic, strong) NSNumber <Optional>*warehouseId;
@property (nonatomic, strong) NSNumber <Optional>*startTime;
@property (nonatomic, strong) NSNumber <Optional>*endTime;

@end
