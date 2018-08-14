//
//  YYOrderMessageOperateViewController.h
//  YunejianBuyer
//
//  Created by Apple on 16/8/18.
//  Copyright © 2016年 Apple. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "YYOrderMessageConfirmInfoModel.h"

@interface YYOrderMessageOperateViewController : UIViewController

@property (nonatomic, strong) YellowPabelCallBack modifySuccess;
@property (nonatomic, strong) CancelButtonClicked cancelButtonClicked;
@property (nonatomic, strong) YYOrderMessageConfirmInfoModel *confirmInfoModel;

@end
