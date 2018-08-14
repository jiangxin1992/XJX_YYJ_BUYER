//
//  YYSalesManModel.h
//  Yunejian
//
//  Created by yyj on 15/7/15.
//  Copyright (c) 2015年 yyj. All rights reserved.
//

#import "JSONModel.h"

@protocol YYSalesManModel @end

@interface YYSalesManModel : JSONModel

@property (strong, nonatomic) NSNumber <Optional>*salesmanId;
@property (strong, nonatomic) NSString <Optional>*name;
@property (strong, nonatomic) NSString <Optional>*email;
@property (strong, nonatomic) NSNumber <Optional>*status;

@end
