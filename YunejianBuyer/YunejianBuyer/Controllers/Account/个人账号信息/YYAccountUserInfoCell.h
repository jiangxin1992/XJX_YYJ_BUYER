//
//  YYAccountUserInfoCell.h
//  YunejianBuyer
//
//  Created by yyj on 2017/8/15.
//  Copyright © 2017年 Apple. All rights reserved.
//

#import <UIKit/UIKit.h>

@class YYUserInfo;

typedef NS_ENUM(NSInteger, AccountUserInfoType) {
    AccountUserInfoTypeUsername,
    AccountUserInfoTypePhone,
    AccountUserInfoTypeUserHead
};

@interface YYAccountUserInfoCell : UITableViewCell

@property (nonatomic,assign) AccountUserInfoType UserInfoType;

@property(nonatomic,strong) YYUserInfo *userInfo;

-(void)UpdateUI;

@end
