//
//  YYBrandAddHeadView.h
//  YunejianBuyer
//
//  Created by yyj on 2017/4/12.
//  Copyright © 2017年 Apple. All rights reserved.
//

#import <UIKit/UIKit.h>

@class YYConClass;
//@class YYConClass,YYConNewBrandModel,YYConNewBrandItemModel;

@interface YYBrandAddHeadView : UICollectionReusableView

@property (nonatomic,strong) YYConClass *connClass;
//@property (nonatomic,strong) YYConNewBrandModel *newbrandModel;

/** 切换人群 回调*/
@property (nonatomic,copy) void (^blockPeople)(NSInteger index);
/** 切换suit 回调 */
@property (nonatomic,copy) void (^blockSuit)(NSInteger index);
/** 点击newbrand 回调*/
//@property (nonatomic,copy) void (^blockBrand)(YYConNewBrandItemModel *itemModel);

@property (nonatomic,assign) NSInteger peopleSelectIndex;

@property (nonatomic,assign) NSInteger suitSelectIndex;

@end
