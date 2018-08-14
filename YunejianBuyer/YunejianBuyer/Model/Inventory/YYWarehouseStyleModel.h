//
//  YYWarehouseStyleModel.h
//  YunejianBuyer
//
//  Created by Victor on 2018/7/20.
//  Copyright © 2018年 Apple. All rights reserved.
//

#import <JSONModel/JSONModel.h>
#import "YYWarehouseSizeModel.h"

@protocol YYWarehouseStyleModel @end

@interface YYWarehouseStyleModel : JSONModel

@property (nonatomic, strong) NSString <Optional>*brandName;
@property (nonatomic, strong) NSString <Optional>*styleName;
@property (nonatomic, strong) NSString <Optional>*styleCode;
@property (nonatomic, strong) NSNumber <Optional>*styleId;
@property (nonatomic, strong) NSString <Optional>*styleImg;
@property (nonatomic, strong) NSNumber <Optional>*colorId;
@property (nonatomic, strong) NSString <Optional>*colorName;
@property (nonatomic, strong) NSString <Optional>*colorValue;
@property (nonatomic, strong) NSNumber <Optional>*designerId;
@property (nonatomic, strong) NSArray <YYWarehouseSizeModel, Optional, ConvertOnDemand>*sizes;

@end
