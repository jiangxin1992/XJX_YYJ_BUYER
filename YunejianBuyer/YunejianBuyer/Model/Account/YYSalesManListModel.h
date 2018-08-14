//
//  YYSalesManListModel.h
//  Yunejian
//
//  Created by yyj on 15/7/15.
//  Copyright (c) 2015年 yyj. All rights reserved.
//

#import "JSONModel.h"
#import "YYSalesManModel.h"

@interface YYSalesManListModel : JSONModel

@property (strong, nonatomic) NSArray<YYSalesManModel,Optional, ConvertOnDemand>* result;

@end
