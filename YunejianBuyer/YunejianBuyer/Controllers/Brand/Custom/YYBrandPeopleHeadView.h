//
//  YYBrandPeopleHeadView.h
//  YunejianBuyer
//
//  Created by yyj on 2017/4/13.
//  Copyright © 2017年 Apple. All rights reserved.
//

#import <UIKit/UIKit.h>

@class YYConClass;

typedef NS_ENUM(NSInteger, YYBrandPeopleHeadViewStyle) {
    YYBrandPeopleHeadViewAppear = 0,//出现状态
    YYBrandPeopleHeadViewDisappear,//消失状态
};

@interface YYBrandPeopleHeadView : UIButton

@property (nonatomic,strong) YYConClass *connClass;

/** 切换人群 回调*/
@property (nonatomic,copy) void (^blockPeople)(NSInteger index);
/** 切换suit 回调 */
@property (nonatomic,copy) void (^blockSuit)(NSInteger index);

@property (nonatomic,assign) NSInteger peopleSelectIndex;

@property (nonatomic,assign) NSInteger suitSelectIndex;

@property (nonatomic,assign) YYBrandPeopleHeadViewStyle viewStyle;

@end
