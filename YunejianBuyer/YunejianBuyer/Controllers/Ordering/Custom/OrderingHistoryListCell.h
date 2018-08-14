//
//  OrderingHistoryListCell.h
//  YunejianBuyer
//
//  Created by yyj on 2017/6/2.
//  Copyright © 2017年 Apple. All rights reserved.
//

#import <UIKit/UIKit.h>


#import "YYOrderingHistoryListItemModel.h"

@interface OrderingHistoryListCell : UITableViewCell

-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier WithBlock:(void(^)(NSString *type,NSIndexPath *indexPath))block;

@property (nonatomic,assign) BOOL haveData;

@property (nonatomic,strong) YYOrderingHistoryListItemModel *listItemModel;

@property (nonatomic,strong) NSIndexPath *indexPath;

@end
