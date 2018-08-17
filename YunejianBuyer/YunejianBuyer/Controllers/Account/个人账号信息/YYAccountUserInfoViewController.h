//
//  YYAccountUserInfoViewController.h
//  YunejianBuyer
//
//  Created by yyj on 2017/8/15.
//  Copyright © 2017年 Apple. All rights reserved.
//

#import <UIKit/UIKit.h>

@class YYUserInfo;

@interface YYAccountUserInfoViewController : UIViewController

@property (nonatomic, strong) CancelButtonClicked cancelButtonClicked;

@property (nonatomic, copy) void (^accountUserInfoCellBlock)(NSString *type);

@property (nonatomic, strong) YYUserInfo *userInfo;

- (void)reloadTableView;
@end
