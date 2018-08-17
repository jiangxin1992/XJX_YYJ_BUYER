//
//  YYInventoryOneColorModel.h
//  YunejianBuyer
//
//  Created by Apple on 16/9/1.
//  Copyright © 2016年 Apple. All rights reserved.
//

#import "JSONModel.h"
#import "YYOrderSizeModel.h"

@protocol YYInventoryOneColorModel @end
@interface YYInventoryOneColorModel : JSONModel
@property (strong, nonatomic) NSNumber <Optional>*colorId;//颜色ID
@property (strong, nonatomic) NSString <Optional>*name;//颜色名称
@property (strong, nonatomic) NSString <Optional>*value;//颜色值，如果以#开头，是16进制色值，否则是图片相对地址

//该款颜色，所购买的尺寸情况
@property (strong, nonatomic) NSArray<YYOrderSizeModel, Optional,ConvertOnDemand>* sizeAmounts;
@end
