//
//  YYOrderNormalListCell.h
//  Yunejian
//
//  Created by Apple on 15/8/17.
//  Copyright (c) 2015年 yyj. All rights reserved.
//

#import <UIKit/UIKit.h>

@class YYOrderListItemModel;

@interface YYOrderNormalListCell : UITableViewCell

@property (nonatomic, strong) YYOrderListItemModel *currentOrderListItemModel;

@property (weak,nonatomic) id<YYTableCellDelegate>  delegate;

@property (nonatomic, strong) NSIndexPath *indexPath;

-(void)updateUI;

-(void)updateOrderConnStatusUI;

-(void)updateorderPayUI;

+(float)cellHeight:(YYOrderListItemModel *)orderListItemModel;

@end
