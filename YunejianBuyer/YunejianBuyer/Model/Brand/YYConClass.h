//
//  YYConnClass.h
//  YunejianBuyer
//
//  Created by yyj on 2017/4/12.
//  Copyright © 2017年 Apple. All rights reserved.
//

#import <JSONModel/JSONModel.h>

#import "YYConPeopleClass.h"
#import "YYConSuitClass.h"
#import "YYConSeasonsClass.h"

@interface YYConClass : JSONModel

@property (strong, nonatomic) NSArray<YYConPeopleClass,Optional, ConvertOnDemand>* peopleTypes;
@property (strong, nonatomic) NSArray<YYConSuitClass,Optional, ConvertOnDemand>* suitTypes;
@property (strong, nonatomic) NSArray<YYConSeasonsClass,Optional, ConvertOnDemand>* seasons;

@end
