//
//  YYIndexBannerDetailViewController.h
//  YunejianBuyer
//
//  Created by yyj on 2017/8/10.
//  Copyright © 2017年 Apple. All rights reserved.
//

#import <UIKit/UIKit.h>

@class YYBannerModel;

@interface YYIndexBannerDetailViewController : UIViewController

@property (nonatomic, strong) YYBannerModel *bannerModel;

@property (nonatomic, strong) CancelButtonClicked cancelButtonClicked;

@end
