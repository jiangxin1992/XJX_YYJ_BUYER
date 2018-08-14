//
//  YYChooseStyleReqModel.h
//  YunejianBuyer
//
//  Created by yyj on 2017/7/5.
//  Copyright © 2017年 Apple. All rights reserved.
//

#import <JSONModel/JSONModel.h>

@interface YYChooseStyleReqModel : JSONModel

/** 货期 | 手机端使用: -2 货期未选 -1 货期; 1 期货; 0 现货*/
@property (strong, nonatomic) NSNumber <Optional>*recommendation;
/** 推荐类型 | -1 全部; 2 可订款; 3 鉴赏款*/
@property (strong, nonatomic) NSNumber <Optional>*recommendationType;
/** 年份字段(来自季)*/
@property (strong, nonatomic) NSNumber <Optional>*year;
/** season分类(来自季)*/
@property (strong, nonatomic) NSString <Optional>*seasonCat;
/** season和季节的关系(来自季)*/
@property (strong, nonatomic) NSString <Optional>*relation;
/** 最小零售价*/
@property (strong, nonatomic) NSNumber <Optional>*retailPriceMin;
/** 最大零售价*/
@property (strong, nonatomic) NSNumber <Optional>*retailPriceMax;
/** 按款式名、品牌名、设计师名称搜索*/
@property (strong, nonatomic) NSString <Optional>*query;
/** 品类*/
@property (strong, nonatomic) NSString <Optional>*suitIds;
/** 人群*/
@property (strong, nonatomic) NSString <Optional>*peopleIds;
/** 排序类型: ASC 升序; DESC 降序*/
@property (strong, nonatomic) NSString <Optional>*sortType;
/** 排序字段: TIME 按时间排序; HOT 按热度排序; PRICE 按价格排序*/
@property (strong, nonatomic) NSString <Optional>*sortField;
/** 按币种搜索:-1未选; 0人民币; 1 欧元; 2 英镑; 3 美元*/
@property (strong, nonatomic) NSNumber <Optional>*curType;

-(NSDictionary *)getRequestParamsStringWithPageIndex:(int)pageIndex pageSize:(int)pageSize;

///** 货期 | 手机端使用: -2 货期未选 -1 货期; 1 期货; 0 现货*/
//@property (strong, nonatomic) NSNumber <Optional>*recommendation;
-(NSString *)getRecommendationDES;

-(NSArray *)getRecommendationDESArrIsTitle:(BOOL )isTitle;

///** 排序类型: ASC 升序; DESC 降序*/
//@property (strong, nonatomic) NSString <Optional>*sortType;
///** 排序字段: TIME 按时间排序; HOT 按热度排序; PRICE 按价格排序*/
//@property (strong, nonatomic) NSString <Optional>*sortField;
-(NSString *)getSortDES;

-(NSArray *)getSortDESArr;

//筛选是否有选择过
-(BOOL)isScreeningChange;

-(void)clearSliderData;

-(NSString *)getMoneyFlag;
@end
