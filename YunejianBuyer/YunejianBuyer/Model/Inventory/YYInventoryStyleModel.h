//
//  YYInventoryStyleModel.h
//  YunejianBuyer
//
//  Created by Apple on 16/8/26.
//  Copyright © 2016年 Apple. All rights reserved.
//

#import "JSONModel.h"
@protocol YYInventoryStyleModel @end
@interface YYInventoryStyleModel : JSONModel
@property (strong, nonatomic) NSString <Optional>*albumImg;//": "http://source.yunejian.com/ufile/20160707/cf4a07f8631647838c12ed80640d72ba",
@property (strong, nonatomic) NSString <Optional>*colorIds;//": "1515",
@property (strong, nonatomic) NSNumber <Optional>*designerId;//": "6556,6558,6570",
@property (strong, nonatomic) NSString <Optional>*seriesName;//": "2017 秋冬/AW",
@property (strong, nonatomic) NSString <Optional>*styleCode;//": "WOB507W",
@property (strong, nonatomic) NSNumber <Optional>*styleId;//": 1221,
@property (strong, nonatomic) NSString <Optional>*styleName;//": "简约大气风衣"



@end
