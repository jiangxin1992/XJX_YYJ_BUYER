//
//  YYOrderListViewController.h
//  Yunejian
//
//  Created by Apple on 15/8/17.
//  Copyright (c) 2015年 yyj. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "ViewPagerController.h"

@interface YYOrderListViewController : ViewPagerController

@property (nonatomic, strong) CancelButtonClicked cancelButtonClicked;

@property (nonatomic, assign) NSInteger currentIndex;//当前第几页

@property (nonatomic, assign) BOOL isMainView;//是否在主页（main）视图

@end
