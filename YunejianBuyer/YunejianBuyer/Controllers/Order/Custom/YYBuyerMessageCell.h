//
//  YYBuyerMessageCell.h
//  Yunejian
//
//  Created by yyj on 15/8/21.
//  Copyright (c) 2015年 yyj. All rights reserved.
//

#import <UIKit/UIKit.h>

@class YYOrderInfoModel;

@interface YYBuyerMessageCell : UITableViewCell

@property (nonatomic, strong) YYOrderInfoModel *currentYYOrderInfoModel;

@property (nonatomic, weak) id<YYTableCellDelegate> delegate;
@property (nonatomic, strong) NSIndexPath *indexPath;

- (void)updateUI;

@end
