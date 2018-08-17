//
//  YYInventoryBrandModel.h
//  YunejianBuyer
//
//  Created by Apple on 16/8/26.
//  Copyright © 2016年 Apple. All rights reserved.
//

#import "JSONModel.h"
@protocol YYInventoryBrandModel @end
@interface YYInventoryBrandModel : JSONModel
@property (strong, nonatomic) NSString <Optional>*brandName;//": "DDD的style",
@property (strong, nonatomic) NSNumber <Optional>*designerId;//": 2
@property (strong, nonatomic) NSString <Optional>*contactName;//":"Cloud",
@property (strong, nonatomic) NSString <Optional>*logo;//":"http://source.yunejian.com/ufile/20160712/5e44ccd602274ac086d757d9f45bc45c"

@end
