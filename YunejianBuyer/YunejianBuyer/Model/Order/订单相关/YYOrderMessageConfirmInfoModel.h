//
//  YYOrderMessageConfirmInfoModel.h
//  YunejianBuyer
//
//  Created by Apple on 16/8/19.
//  Copyright © 2016年 Apple. All rights reserved.
//

#import "JSONModel.h"

@interface YYOrderMessageConfirmInfoModel : JSONModel
@property (strong, nonatomic) NSString <Optional>*appendOrderCode;//":"",
@property (strong, nonatomic) NSString <Optional>*appendOrderConnStatus;//":null,
@property (strong, nonatomic) NSNumber <Optional>*itemAmount;//":11,
@property (strong, nonatomic) NSString <Optional>*logoPath;//":"http://source.yunejian.com/ufile/20160712/83d3ecb0abdf474abc41eba49c81a13c",
@property (strong, nonatomic) NSString <Optional>*orderCode;//":"11410477717641",
@property (strong, nonatomic) NSNumber <Optional>*orderCreateTime;//":1471341478000,
@property (strong, nonatomic) NSString <Optional>*originOrderCode;//":"",
@property (strong, nonatomic) NSString <Optional>*originOrderConnStatus;//":null,
@property (strong, nonatomic) NSNumber <Optional>*status;//":1,
@property (strong, nonatomic) NSNumber <Optional>*styleAmount;//":1,
@property (strong, nonatomic) NSNumber <Optional>*totalPrice;//":0.11
@property (strong, nonatomic) NSString <Optional>*brandName;//":0.11
@property (strong, nonatomic) NSNumber <Optional>*curType;//":0.11
@end
