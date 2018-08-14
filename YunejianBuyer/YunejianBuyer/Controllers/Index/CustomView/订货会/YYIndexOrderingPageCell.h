//
//  YYIndexOrderingPageCell.h
//  YunejianBuyer
//
//  Created by yyj on 2017/9/21.
//  Copyright © 2017年 Apple. All rights reserved.
//

#import <UIKit/UIKit.h>

@class YYOrderingListModel,YYOrderingListItemModel;

@interface YYIndexOrderingPageCell : UITableViewCell

-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier WithBlock:(void(^)(NSString *type,YYOrderingListItemModel *listItemModel))block;

//订货会cell model
@property (nonatomic,strong) YYOrderingListModel *orderingListModel;

-(void)updateUI;

@end
