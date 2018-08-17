//
//  YYOrderStatusCell.h
//  Yunejian
//
//  Created by Apple on 15/11/25.
//  Copyright © 2015年 yyj. All rights reserved.
//

#import <UIKit/UIKit.h>

@class YYOrderInfoModel,YYOrderTransStatusModel;

@interface YYOrderStatusCell : UITableViewCell

@property (nonatomic, strong) YYOrderInfoModel *currentYYOrderInfoModel;
@property (nonatomic, strong) YYOrderTransStatusModel *currentYYOrderTransStatusModel;
@property (nonatomic, weak) id<YYTableCellDelegate>  delegate;
@property (nonatomic, strong) NSIndexPath *indexPath;

-(void)updateUI;

+(float)cellHeight:(NSInteger)tranStatus;

@end
