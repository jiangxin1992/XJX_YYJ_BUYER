//
//  YYWarehousingDetailViewController.h
//  YunejianBuyer
//
//  Created by Victor on 2018/7/4.
//  Copyright © 2018年 Apple. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "YYWarehouseRecordModel.h"

@interface YYWarehousingDetailViewController : UIViewController

@property (nonatomic, assign) BOOL isEXwarehouse;
@property (nonatomic, strong) YYWarehouseRecordModel *recordModel;

@end
