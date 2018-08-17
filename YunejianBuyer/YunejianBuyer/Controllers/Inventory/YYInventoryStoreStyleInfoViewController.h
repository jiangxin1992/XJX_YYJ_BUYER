//
//  YYInventoryStoreStyleInfoViewController.h
//  YunejianBuyer
//
//  Created by Apple on 16/9/2.
//  Copyright © 2016年 Apple. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "YYInventoryBoardModel.h"
@interface YYInventoryStoreStyleInfoViewController : UIViewController
@property(nonatomic,strong) CancelButtonClicked cancelButtonClicked;
@property (nonatomic,strong)YYInventoryBoardModel *boardModel;
@end
