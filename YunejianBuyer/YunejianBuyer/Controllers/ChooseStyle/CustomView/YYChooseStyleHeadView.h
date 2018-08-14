//
//  YYChooseStyleHeadView.h
//  YunejianBuyer
//
//  Created by yyj on 2017/7/6.
//  Copyright © 2017年 Apple. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "YYChooseStyleButton.h"
#import "YYStylesAndTotalPriceModel.h"

typedef NS_ENUM(NSInteger, YYChooseStyleHeadStyle) {
    YYChooseStyleHeadReuse = 0,//collectionview复用
    YYChooseStyleHeadCustom//自定义视图
};

typedef NS_ENUM(NSInteger, YYChooseStyleHeadViewStyle) {
    YYChooseStyleHeadViewAppear = 0,//出现状态
    YYChooseStyleHeadViewDisappear,//消失状态
    YYChooseStyleHeadViewTotalDisappear//完全消失状态
};

@class YYChooseStyleReqModel;

@interface YYChooseStyleHeadView : UICollectionReusableView

@property (nonatomic,strong) YYChooseStyleReqModel *reqModel;

@property (nonatomic,copy) void (^chooseStyleBlock)(NSString *type,YYChooseStyleButtonStyle chooseStyleButtonStyle);

@property (nonatomic,strong) YYStylesAndTotalPriceModel *stylesAndTotalPriceModel;//总数

@property (nonatomic,assign) YYChooseStyleHeadStyle headStyle;

-(void)updateUI;
-(void)setNormalState;
/**
 * 更新当前视图的view type
 * 出现状态 | 消失状态 | 完全消失状态
 * 对YYChooseStyleHeadStyle_Custom类型才有影响
 */
-(void)setViewStyle:(YYChooseStyleHeadViewStyle)viewStyle;

@property (nonatomic,assign) YYChooseStyleHeadViewStyle viewStyle;


@end
