//
//  YYWarehouseListModel.h
//  YunejianBuyer
//
//  Created by Victor on 2018/7/19.
//  Copyright © 2018年 Apple. All rights reserved.
//

#import <JSONModel/JSONModel.h>

@interface YYWarehouseListModel : JSONModel

@property (nonatomic, strong) NSNumber <Optional>*warehouseId;
@property (nonatomic, strong) NSString <Optional>*warehouseName;
@end
