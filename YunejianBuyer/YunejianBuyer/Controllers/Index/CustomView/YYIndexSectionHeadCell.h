//
//  YYIndexSectionHeadCell.h
//  YunejianBuyer
//
//  Created by yyj on 2017/8/9.
//  Copyright © 2017年 Apple. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, EIndexSectionHeadType)
{
    EIndexSectionHeadRecommendationBrand,
    EIndexSectionHeadLatestSeries,
    EIndexSectionHeadOrdering,
    EIndexSectionHeadOrder,
    EIndexSectionHeadVerify,//完善资料/审核中
    EIndexSectionHeadHot//热门品牌
};

@interface YYIndexSectionHeadCell : UIView

//-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier;
-(instancetype)initWithFrame:(CGRect)frame;

/** 类型 */
@property (nonatomic,assign) EIndexSectionHeadType sectionHeadType;

@property (nonatomic,assign) BOOL topLineIsHide;

@property (nonatomic,assign) BOOL moreBtnIsShow;

@property (nonatomic,assign) BOOL titleIsCenter;

@property(nonatomic,copy) void (^indexSectionHeadBlock)(NSString *type);

-(void)updateUI;

@end
