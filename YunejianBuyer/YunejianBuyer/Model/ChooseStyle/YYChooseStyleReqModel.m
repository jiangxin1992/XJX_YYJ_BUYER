//
//  YYChooseStyleReqModel.m
//  YunejianBuyer
//
//  Created by yyj on 2017/7/5.
//  Copyright © 2017年 Apple. All rights reserved.
//

#import "YYChooseStyleReqModel.h"

@implementation YYChooseStyleReqModel
///** 货期 | 手机端使用: -2 货期未选 -1 货期; 1 期货; 0 现货*/
//@property (strong, nonatomic) NSNumber <Optional>*recommendation;
///** 推荐类型 | -1 全部; 2 可订款; 3 鉴赏款*/
//@property (strong, nonatomic) NSNumber <Optional>*recommendationType;
///** 年份字段(来自季)*/
//@property (strong, nonatomic) NSNumber <Optional>*year;
///** season分类(来自季)*/
//@property (strong, nonatomic) NSString <Optional>*seasonCat;
///** season和季节的关系(来自季)*/
//@property (strong, nonatomic) NSString <Optional>*relation;
///** 最小零售价*/
//@property (strong, nonatomic) NSNumber <Optional>*retailPriceMin;
///** 最大零售价*/
//@property (strong, nonatomic) NSNumber <Optional>*retailPriceMax;
///** 按款式名、品牌名、设计师名称搜索*/
//@property (strong, nonatomic) NSString <Optional>*query;
///** 品类*/
//@property (strong, nonatomic) NSArray <Optional>*suitIds;
///** 人群*/
//@property (strong, nonatomic) NSArray <Optional>*peopleIds;
///** 排序类型: ASC 升序; DESC 降序*/
//@property (strong, nonatomic) NSString <Optional>*sortType;
///** 排序字段: TIME 按时间排序; HOT 按热度排序; PRICE 按价格排序*/
//@property (strong, nonatomic) NSString <Optional>*sortField;
///** 按币种搜索: 1 欧元; 2 英镑; 3 美元*/
//@property (strong, nonatomic) NSNumber <Optional>*curType;
-(NSDictionary *)getRequestParamsStringWithPageIndex:(int)pageIndex pageSize:(int)pageSize{
    //把这些都存到数组里面去
    NSMutableDictionary *mutParameters = [[NSMutableDictionary alloc] init];

    [mutParameters setObject:@(pageIndex) forKey:@"pageIndex"];
    [mutParameters setObject:@(pageSize) forKey:@"pageSize"];

    NSInteger _tempRecommendation = -1;
    if(self.recommendation){
        if([self.recommendation integerValue] == 1 || [self.recommendation integerValue] == 0){
            _tempRecommendation = [self.recommendation integerValue];
        }
    }
    [mutParameters setObject:@(_tempRecommendation) forKey:@"recommendation"];

    NSInteger _tempRecommendationType = -1;
    if(self.recommendationType){
        if([self.recommendationType integerValue] == 2 || [self.recommendationType integerValue] == 3){
            _tempRecommendationType = [self.recommendationType integerValue];
        }
    }
    if(_tempRecommendationType != -1){
        [mutParameters setObject:@(_tempRecommendationType) forKey:@"recommendationType"];
    }
    
    if(self.year){
        if([self.year integerValue] > 0){
            [mutParameters setObject:self.year forKey:@"year"];
        }else{
            [mutParameters setObject:@"" forKey:@"year"];
        }
    }
    
    if(![NSString isNilOrEmpty:self.seasonCat]){
        [mutParameters setObject:self.seasonCat forKey:@"seasonCat"];
    }

    if(![NSString isNilOrEmpty:self.relation]){
        [mutParameters setObject:self.relation forKey:@"relation"];
    }
    
    if(self.retailPriceMin){
        //只存大于0的时候
        if([self.retailPriceMin integerValue] > 0){
            [mutParameters setObject:self.retailPriceMin forKey:@"retailPriceMin"];
        }
    }
    
    if(self.retailPriceMax){
        //只存大于0的时候
        if([self.retailPriceMax integerValue] > 0){
            [mutParameters setObject:self.retailPriceMax forKey:@"retailPriceMax"];
        }
    }
    
    if(![NSString isNilOrEmpty:self.query]){
        [mutParameters setObject:self.query forKey:@"query"];
    }
    
    if(![NSString isNilOrEmpty:self.suitIds]){
        [mutParameters setObject:self.suitIds forKey:@"suitIds"];
    }
    
    if(![NSString isNilOrEmpty:self.peopleIds]){
        [mutParameters setObject:self.peopleIds forKey:@"peopleIds"];
    }

    //ASC 升序; DESC 降序
    NSString *sortType = @"DESC";
    if(![NSString isNilOrEmpty:self.sortType]){
        if([self.sortType isEqualToString:@"DESC"] || [self.sortType isEqualToString:@"ASC"]){
            sortType = self.sortType;
        }
    }
    [mutParameters setObject:sortType forKey:@"sortType"];

    //TIME 按时间排序; HOT 按热度排序; PRICE 按价格排序
    NSString *sortField = @"MISC";
    if(![NSString isNilOrEmpty:self.sortField]){
        if([self.sortField isEqualToString:@"TIME"] || [self.sortField isEqualToString:@"HOT"] || [self.sortField isEqualToString:@"PRICE"] || [self.sortField isEqualToString:@"MISC"] ){
            sortField = self.sortField;
        }
    }
    [mutParameters setObject:sortField forKey:@"sortField"];

    //0 人民币; 1 欧元; 2 英镑; 3 美元
    if(self.curType){
        if([self.curType integerValue] >= 0){
            NSInteger curType = 0;
            if([self.curType integerValue] == 0 || [self.curType integerValue] == 1 || [self.curType integerValue] == 2 || [self.curType integerValue] == 3){
                curType = [self.curType integerValue];
            }
            [mutParameters setObject:@(curType) forKey:@"curType"];
        }
    }
    return [mutParameters copy];
}
///** 货期 | 手机端使用: -2 货期未选 -1 货期; 1 期货; 0 现货*/
//@property (strong, nonatomic) NSNumber <Optional>*recommendation;
-(NSString *)getRecommendationDES{
    if(self){
        NSInteger recommendationValue = [self.recommendation integerValue];
        if(recommendationValue == -2 || recommendationValue == -1){
            return NSLocalizedString(@"货期",nil);
        }else if(recommendationValue == 1){
            return NSLocalizedString(@"期货", nil);
        }else if(recommendationValue == 0){
            return NSLocalizedString(@"现货",nil);
        }
    }
    return @"";
}
-(NSArray *)getRecommendationDESArrIsTitle:(BOOL )isTitle{
    NSArray *returnArr = @[@{@"des":isTitle?NSLocalizedString(@"全部货期",nil):NSLocalizedString(@"货期",nil),@"recommendation":@(-1)}
                         ,@{@"des":NSLocalizedString(@"现货",nil),@"recommendation":@(0)}
                         ,@{@"des":NSLocalizedString(@"期货", nil),@"recommendation":@(1)}
                         ];
    
    return returnArr;
}
///** 排序类型: ASC 升序; DESC 降序*/
//@property (strong, nonatomic) NSString <Optional>*sortType;
///** 排序字段: TIME 按时间排序; HOT 按热度排序; PRICE 按价格排序*/
//@property (strong, nonatomic) NSString <Optional>*sortField;
-(NSString *)getSortDES{
    if(self){
        if([self.sortField isEqualToString:@"MISC"]){
            return NSLocalizedString(@"综合",nil);
        }else if([self.sortField isEqualToString:@"TIME"]){
            return NSLocalizedString(@"最新",nil);
        }else if([self.sortField isEqualToString:@"HOT"]){
            return NSLocalizedString(@"最热",nil);
        }else if([self.sortField isEqualToString:@"PRICE"]){
            if([self.sortType isEqualToString:@"ASC"]){
                return NSLocalizedString(@"价格由低到高" ,nil);
            }else if([self.sortType isEqualToString:@"DESC"]){
                return NSLocalizedString(@"价格由高到低",nil);
            }
        }
    }
    return @"";
}

-(NSArray *)getSortDESArr{
    NSArray *returnArr = @[@{@"des":NSLocalizedString(@"综合",nil),@"sortField":@"MISC",@"sortType":@"DESC"}
                           ,@{@"des":NSLocalizedString(@"最新",nil),@"sortField":@"TIME",@"sortType":@"DESC"}
                           ,@{@"des":NSLocalizedString(@"最热",nil),@"sortField":@"HOT",@"sortType":@"DESC"}
                           ,@{@"des":NSLocalizedString(@"价格由高到低",nil),@"sortField":@"PRICE",@"sortType":@"DESC"}
                           ,@{@"des":NSLocalizedString(@"价格由低到高" ,nil),@"sortField":@"PRICE",@"sortType":@"ASC"}
                           ];
    return returnArr;
}
///** 推荐类型 | -1 全部; 2 可订款; 3 鉴赏款*/
//@property (strong, nonatomic) NSNumber <Optional>*recommendationType;
///** 年份字段(来自季)*/
//@property (strong, nonatomic) NSNumber <Optional>*year;
///** season分类(来自季)*/
//@property (strong, nonatomic) NSString <Optional>*seasonCat;
///** season和季节的关系(来自季)*/
//@property (strong, nonatomic) NSString <Optional>*relation;
///** 最小零售价*/
//@property (strong, nonatomic) NSNumber <Optional>*retailPriceMin;
///** 最大零售价*/
//@property (strong, nonatomic) NSNumber <Optional>*retailPriceMax;
///** 按款式名、品牌名、设计师名称搜索*/
//@property (strong, nonatomic) NSString <Optional>*query;
///** 品类*/
//@property (strong, nonatomic) NSArray <Optional>*suitIds;
///** 人群*/
//@property (strong, nonatomic) NSArray <Optional>*peopleIds;
/** 按币种搜索:-1未选; 0人民币; 1 欧元; 2 英镑; 3 美元*/
//@property (strong, nonatomic) NSNumber <Optional>*curType;
//筛选是否有选择过
-(BOOL)isScreeningChange{
    if(self){
        if([self.recommendationType integerValue] == 2 || [self.recommendationType integerValue] == 3){
            return YES;
        }
        
        if(![NSString isNilOrEmpty:self.relation]){
            return YES;
        }
        
        if([self.retailPriceMin integerValue] > 0 || [self.retailPriceMax integerValue] > 0){
            return YES;
        }
        
        if(![NSString isNilOrEmpty:self.query]){
            return YES;
        }
        
        if(![NSString isNilOrEmpty:self.suitIds]){
            return YES;
        }
        
        if(![NSString isNilOrEmpty:self.peopleIds]){
            return YES;
        }
        
        if([self.curType integerValue] == 0 || [self.curType integerValue] == 1 ||[self.curType integerValue] == 2 || [self.curType integerValue] == 3){
            return YES;
        }
    }
    
    return NO;
}

-(void)clearSliderData{
    if(self){
        self.recommendationType = @(-1);
        self.relation = nil;
        self.seasonCat = nil;
        self.year = @(0);
        self.retailPriceMin = @(-1);
        self.retailPriceMax = @(-1);
        self.suitIds = nil;
        self.peopleIds = nil;
        self.curType = @(-1);
    }
}
/** 按币种搜索:-1未选; 0人民币; 1 欧元; 2 英镑; 3 美元*/
-(NSString *)getMoneyFlag{
    NSString *_currencySign = @"";
    if(self){
        if([self.curType integerValue] >= 0){
            if([self.curType integerValue] == 0){
                _currencySign = @"￥";
            }else if([self.curType integerValue] == 1){
                _currencySign = @"€";
            }else if([self.curType integerValue] == 2){
                _currencySign = @"£";
            }else if([self.curType integerValue] == 3){
                _currencySign = @"$";
            }
        }
    }
    return _currencySign;
}


@end
