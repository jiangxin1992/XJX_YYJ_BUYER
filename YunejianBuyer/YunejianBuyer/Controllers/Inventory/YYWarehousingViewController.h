//
//  YYWarehousingViewController.h
//  YunejianBuyer
//
//  Created by Victor on 2018/7/2.
//  Copyright © 2018年 Apple. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, TableViewType) {
    TableViewTypeNone = -1,
    TableViewTypeNormal = 0,
    TableViewTypeWarehouse = 1,//仓库筛选列表
    TableViewTypeOperationType = 2,//操作类型筛选列表
    TableViewTypeTime = 3//时间筛选列表
};

@interface YYWarehousingViewController : UIViewController

@property (nonatomic, strong) UINavigationController *navigationController;
@property (nonatomic, assign) BOOL isEXwarehouse;
@property (nonatomic, strong) NSString *searchFieldText;

- (void)getWarehouseRecord;

@end
