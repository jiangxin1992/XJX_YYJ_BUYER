//
//  YYHelpPanelViewController.h
//  yunejianDesigner
//
//  Created by Apple on 16/7/7.
//  Copyright © 2016年 Apple. All rights reserved.
//

#import <UIKit/UIKit.h>
typedef NS_ENUM(NSInteger, HelpPanelType) {
    HelpPanelTypeTax = 1,
    HelpPanelTypeAliPay = 2
};

@interface YYHelpPanelViewController : UIViewController
@property(nonatomic,strong) CancelButtonClicked cancelButtonClicked;
@property(nonatomic,assign) HelpPanelType helpPanelType;

@end
