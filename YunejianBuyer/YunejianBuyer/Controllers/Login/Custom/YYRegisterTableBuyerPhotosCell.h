//
//  YYRegisterTableBuyerPhotosCell.h
//  YunejianBuyer
//
//  Created by Victor on 2017/12/26.
//  Copyright © 2017年 Apple. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "YYTableViewCellInfoModel.h"

@interface YYRegisterTableBuyerPhotosCell : UITableViewCell

@property(nonatomic,weak)id<YYRegisterTableCellDelegate> delegate;
@property(nonatomic,copy)NSIndexPath * indexPath;

-(void)updateParamInfo:(YYTableViewCellInfoModel *)info;
-(void)updateCellInfo:(NSArray *)info;

+(float)cellHeight:(NSInteger)count;

@end
