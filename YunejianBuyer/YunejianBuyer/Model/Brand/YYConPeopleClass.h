//
//  YYConnPeople.h
//  YunejianBuyer
//
//  Created by yyj on 2017/4/12.
//  Copyright © 2017年 Apple. All rights reserved.
//

#import <JSONModel/JSONModel.h>
@protocol YYConPeopleClass @end
@interface YYConPeopleClass : JSONModel

@property (strong, nonatomic) NSString <Optional>*name;
@property (strong, nonatomic) NSArray <Optional, ConvertOnDemand>*peopleIds;//

@end
