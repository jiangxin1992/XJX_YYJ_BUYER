//
//  YYWarehouseSizeModel.h
//  YunejianBuyer
//
//  Created by Victor on 2018/7/20.
//  Copyright © 2018年 Apple. All rights reserved.
//

#import <JSONModel/JSONModel.h>

@protocol YYWarehouseSizeModel @end

@interface YYWarehouseSizeModel : JSONModel

@property (nonatomic, strong) NSString <Optional>*sizeName;
@property (nonatomic, strong) NSNumber <Optional>*sizeId;
@property (nonatomic, strong) NSString <Optional>*exception;
@property (nonatomic, strong) NSString <Optional>*itemExceptionBo;
@property (nonatomic, strong) NSNumber <Optional>*itemReceived;
@property (nonatomic, strong) NSNumber <Optional>*itemSent;
@property (nonatomic, strong) NSString <Optional>*skuKey;
@property (nonatomic, strong) NSNumber <Optional>*unitPrice;

@end
