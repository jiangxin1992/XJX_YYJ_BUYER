//
//  YYNewConnDesignerListModel.h
//  YunejianBuyer
//
//  Created by yyj on 2017/11/9.
//  Copyright © 2017年 Apple. All rights reserved.
//

#import <JSONModel/JSONModel.h>

#import "YYPageInfoModel.h"
#import "YYHotDesignerBrandsModel.h"

@interface YYNewConnDesignerListModel : JSONModel

@property (strong, nonatomic) NSArray<YYHotDesignerBrandsModel,Optional, ConvertOnDemand>* result;
@property (strong, nonatomic) YYPageInfoModel <Optional>*pageInfo;

@end
