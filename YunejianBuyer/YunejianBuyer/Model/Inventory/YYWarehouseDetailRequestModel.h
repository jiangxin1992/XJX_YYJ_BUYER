//
//  YYWarehouseDetailRequestModel.h
//  YunejianBuyer
//
//  Created by Victor on 2018/7/24.
//  Copyright © 2018年 Apple. All rights reserved.
//

#import <JSONModel/JSONModel.h>

@interface YYWarehouseDetailRequestModel : JSONModel

@property (nonatomic, strong) NSString <Optional>*incomingBill;
@property (nonatomic, strong) NSNumber <Optional>*purchaseOrderId;

@end
