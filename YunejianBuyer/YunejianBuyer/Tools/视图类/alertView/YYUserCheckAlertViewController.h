//
//  YYUserCheckAlertViewController.h
//  Yunejian
//
//  Created by Apple on 15/12/9.
//  Copyright © 2015年 yyj. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, ECheckStyle)
{
    ECheckStyleNeedSubmit,//待提交材料
    ECheckStyleConfirmOK,//审核通过
    ECheckStyleConfirmReject,//审核拒绝
    ECheckStyleToBeConfirm//待审核
};

@interface YYUserCheckAlertViewController : UIViewController

@property (nonatomic, strong) ModifySuccess modifySuccess;
@property (nonatomic, strong) CancelButtonClicked cancelButtonClicked;

@property (nonatomic, assign) ECheckStyle checkStyle;

-(void)UpdateUI;

@end
