//
//  YYUserStyleModel.h
//  YunejianBuyer
//
//  Created by yyj on 2017/7/14.
//  Copyright © 2017年 Apple. All rights reserved.
//

#import <JSONModel/JSONModel.h>
@protocol YYUserStyleModel @end
@interface YYUserStyleModel : JSONModel

@property (strong, nonatomic) NSString <Optional>*albumImg;
@property (strong, nonatomic) NSString <Optional>*brandLogo;
@property (strong, nonatomic) NSString <Optional>*brandName;
@property (strong, nonatomic) NSNumber <Optional>*collectCount;
@property (strong, nonatomic) NSNumber <Optional>*curType;
@property (strong, nonatomic) NSString <Optional>*retailPrice;
@property (nonatomic, strong) NSNumber <Optional> *tradePrice;
@property (strong, nonatomic) NSString <Optional>*seriesName;
@property (strong, nonatomic) NSNumber <Optional>*status;// 0：正常 1：失效
@property (strong, nonatomic) NSString <Optional>*styleName;
@property (strong, nonatomic) NSNumber <Optional>*seriesId;
@property (strong, nonatomic) NSNumber <Optional>*styleId;
@property (strong, nonatomic) NSNumber <Optional>*designerId;

@end
