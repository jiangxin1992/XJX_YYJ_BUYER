//
//  YYUserSeriesModel.h
//  YunejianBuyer
//
//  Created by yyj on 2017/7/14.
//  Copyright © 2017年 Apple. All rights reserved.
//

#import <JSONModel/JSONModel.h>
@protocol YYUserSeriesModel @end
@interface YYUserSeriesModel : JSONModel

@property (strong, nonatomic) NSString <Optional>*albumImg;
@property (strong, nonatomic) NSString <Optional>*brandLogo;
@property (strong, nonatomic) NSString <Optional>*brandName;
@property (strong, nonatomic) NSNumber <Optional>*collectCount;
@property (strong, nonatomic) NSNumber <Optional>*maxRetailPrice;
@property (strong, nonatomic) NSNumber <Optional>*minRetailPrice;
@property (strong, nonatomic) NSString <Optional>*seriesName;
@property (strong, nonatomic) NSNumber <Optional>*status;// 0：正常 1：失效
@property (strong, nonatomic) NSNumber <Optional>*curType;
@property (strong, nonatomic) NSNumber <Optional>*seriesId;
@property (strong, nonatomic) NSNumber <Optional>*styleSize;
@property (strong, nonatomic) NSNumber <Optional>*designerId;

@end
