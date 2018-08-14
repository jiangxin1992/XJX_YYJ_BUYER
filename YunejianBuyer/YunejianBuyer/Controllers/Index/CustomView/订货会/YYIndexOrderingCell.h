//
//  OrderingListCell.h
//  YunejianBuyer
//
//  Created by yyj on 2017/5/31.
//  Copyright © 2017年 Apple. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "YYOrderingListItemModel.h"

@interface YYIndexOrderingCell : UITableViewCell

-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier WithBlock:(void(^)(NSString *type,YYOrderingListItemModel *listItemModel))block;

//发布会cell model
@property (nonatomic,strong) YYOrderingListItemModel *listItemModel;

@property (nonatomic,assign) BOOL haveData;

@property (nonatomic,assign) BOOL isLastOrdering;

@end
