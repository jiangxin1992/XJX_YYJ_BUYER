//
//  YYChooseStyleModuleSlideView.h
//  YunejianBuyer
//
//  Created by yyj on 2017/7/10.
//  Copyright © 2017年 Apple. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "YYConClass.h"
#import "YYChooseStyleReqModel.h"

typedef NS_ENUM(NSInteger, YYChooseStyleModuleSlideViewType) {
    YYChooseStyleModuleSlideViewTypeRecommendation = 0,//选款
    YYChooseStyleModuleSlideViewTypePeople,//人群
    YYChooseStyleModuleSlideViewTypeSuit,//品类
    YYChooseStyleModuleSlideViewTypeSeason,//季
    YYChooseStyleModuleSlideViewTypeCurType//批发价范围
};

@interface YYChooseStyleModuleSlideView : UIView

-(instancetype)initWithConClass:(YYConClass *)conClass WithReqModel:(YYChooseStyleReqModel *)reqModel WithChooseStyleModuleSlideViewType:(YYChooseStyleModuleSlideViewType )chooseStyleModuleSlideViewType HaveDownLine:(BOOL )haveDownLine;

@property (nonatomic,strong) YYConClass *conClass;

@property (strong, nonatomic) YYChooseStyleReqModel *reqModel;

@property (nonatomic,assign) YYChooseStyleModuleSlideViewType chooseStyleModuleSlideViewType;

@property (nonatomic,assign) BOOL haveDownLine;

@property (nonatomic,copy) void (^chooseStyleModuleSlideBlock)(NSString *type);

-(void)clearSliderSelect;

@end
