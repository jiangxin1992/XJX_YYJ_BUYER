//
//  YYConNewBrandModel.h
//  YunejianBuyer
//
//  Created by yyj on 2017/4/12.
//  Copyright © 2017年 Apple. All rights reserved.
//

#import <JSONModel/JSONModel.h>

#import "YYConNewBrandItemModel.h"

@interface YYConNewBrandModel : JSONModel

@property (strong, nonatomic) NSArray<YYConNewBrandItemModel,Optional, ConvertOnDemand>* result;

@end
