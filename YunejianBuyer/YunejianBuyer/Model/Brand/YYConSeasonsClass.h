//
//  YYConSeasonsClass.h
//  YunejianBuyer
//
//  Created by yyj on 2017/7/5.
//  Copyright © 2017年 Apple. All rights reserved.
//

#import <JSONModel/JSONModel.h>

@protocol YYConSeasonsClass @end

@interface YYConSeasonsClass : JSONModel

@property (strong, nonatomic) NSString <Optional>*name;
@property (strong, nonatomic) NSString <Optional>*nameEn;
@property (strong, nonatomic) NSString <Optional>*relation;
@property (strong, nonatomic) NSString <Optional>*seasonCat;
@property (strong, nonatomic) NSNumber <Optional>*year;

-(NSString *)getShowName;

@end
