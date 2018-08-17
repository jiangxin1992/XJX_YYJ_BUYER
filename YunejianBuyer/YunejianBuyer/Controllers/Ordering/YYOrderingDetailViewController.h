//
//  YYOrderingDetailViewController.h
//  YunejianBuyer
//
//  Created by yyj on 2017/6/1.
//  Copyright © 2017年 Apple. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "YYOrderingListItemModel.h"

@interface YYOrderingDetailViewController : UIViewController

@property (nonatomic, strong) YYOrderingListItemModel *orderingModel;

@property (nonatomic, strong) CancelButtonClicked cancelButtonClicked;

@end
