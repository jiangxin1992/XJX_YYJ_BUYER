//
//  YYLeftMenuViewController.h
//  Yunejian
//
//  Created by yyj on 15/7/8.
//  Copyright (c) 2015年 yyj. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, LeftMenuButtonType) {
    LeftMenuButtonTypeIndex = 50000,//首页
    LeftMenuButtonTypeOpus = 50001,//作品
    LeftMenuButtonTypeOrder = 50002,//订单
    LeftMenuButtonTypeAccount = 50003,//我的
    LeftMenuButtonTypeAddBrand = 50004,//品牌广场
    LeftMenuButtonTypeSetting = 50005,//设置
    LeftMenuButtonTypeInventory = 50006,//库存
    LeftMenuButtonTypeIndexChooseStyle = 50007,//选款
};

typedef void (^LeftMenuButtonClicked)(LeftMenuButtonType buttonIndex);

@interface YYLeftMenuViewController : UIViewController

@property (nonatomic, strong) LeftMenuButtonClicked leftMenuButtonClicked;

- (void)setButtonSelectedByButtonIndex:(LeftMenuButtonType)leftMenuButtonIndex;

@end
