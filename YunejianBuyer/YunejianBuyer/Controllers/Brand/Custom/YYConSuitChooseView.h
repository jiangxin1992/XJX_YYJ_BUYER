//
//  YYConSuitChooseView.h
//  YunejianBuyer
//
//  Created by yyj on 2017/4/13.
//  Copyright © 2017年 Apple. All rights reserved.
//

#import <UIKit/UIKit.h>

@class YYConClass;

@interface YYConSuitChooseView : UIView

@property (nonatomic,strong) YYConClass *connClass;

/** 切换人群 回调*/
@property (nonatomic,copy) void (^blockSuit)(NSInteger index);

/** 隐藏 */
@property (nonatomic,copy) void (^blockHide)();

@property (nonatomic,assign) NSInteger suitSelectIndex;

@end
