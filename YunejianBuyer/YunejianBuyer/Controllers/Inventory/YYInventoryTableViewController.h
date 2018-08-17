//
//  YYInventoryTableViewController.h
//  YunejianBuyer
//
//  Created by Apple on 16/8/29.
//  Copyright © 2016年 Apple. All rights reserved.
//

#import <UIKit/UIKit.h>
@interface YYInventoryTableViewController : UIViewController
@property(nonatomic,assign) int currentType;//0 补货公告 我的补货 我的库存
@property (weak,nonatomic) id<YYTableCellDelegate>  delegate;

-(void)relaodTableData:(BOOL)newData;
@end
