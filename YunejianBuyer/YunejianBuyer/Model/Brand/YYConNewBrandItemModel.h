//
//  YYConNewBrandItemModel.h
//  YunejianBuyer
//
//  Created by yyj on 2017/4/12.
//  Copyright © 2017年 Apple. All rights reserved.
//

#import <JSONModel/JSONModel.h>

@protocol YYConNewBrandItemModel @end

@interface YYConNewBrandItemModel : JSONModel

@property (strong, nonatomic) NSNumber <Optional>*brandId;
@property (strong, nonatomic) NSString <Optional>*brandName;
@property (strong, nonatomic) NSNumber <Optional>*designerId;
@property (strong, nonatomic) NSString <Optional>*logo;
@property (strong, nonatomic) NSString <Optional>*designerName;
@property (strong, nonatomic) NSString <Optional>*email;

@end
