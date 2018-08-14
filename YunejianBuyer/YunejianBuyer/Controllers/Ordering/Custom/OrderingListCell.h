//
//  OrderingListCell.h
//  YunejianBuyer
//
//  Created by yyj on 2017/5/31.
//  Copyright © 2017年 Apple. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "YYOrderingListItemModel.h"

typedef NS_ENUM(NSInteger, EOrderingListCellType)
{
    EOrderingListCellTypeList,//订货会列表
    EOrderingListCellTypeIndex//首页订货会cell
};

@interface OrderingListCell : UITableViewCell

//发布会cell model
@property (nonatomic,strong)YYOrderingListItemModel *listItemModel;

@property (nonatomic,assign)BOOL haveData;

//@property (nonatomic,assign)BOOL haveTopBlankView;
@property (nonatomic,assign) EOrderingListCellType cellType;

@end
