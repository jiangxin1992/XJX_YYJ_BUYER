//
//  YYOrderUseAddressCell.h
//  YunejianBuyer
//
//  Created by Apple on 16/3/21.
//  Copyright © 2016年 Apple. All rights reserved.
//

#import <UIKit/UIKit.h>

@class YYOrderInfoModel,YYOrderBuyerAddress;

typedef void (^OrderTypeButtonClicked)(void);

@interface YYOrderUseAddressCell : UITableViewCell

@property (weak, nonatomic) id<YYTableCellDelegate> delegate;
@property (nonatomic, strong) NSIndexPath *indexPath;
@property (nonatomic, strong) YYOrderBuyerAddress *buyerAddress;//新增地址
@property (nonatomic, strong) YYOrderInfoModel *currentYYOrderInfoModel;
@property (nonatomic, strong) OrderTypeButtonClicked orderTypeButtonClicked;

-(void)updateUI;

@end
