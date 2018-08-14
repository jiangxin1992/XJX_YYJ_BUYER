//
//  YYRegisterTableConnBrandCell.h
//  YunejianBuyer
//
//  Created by Victor on 2017/12/26.
//  Copyright © 2017年 Apple. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "YYTableViewCellInfoModel.h"

@interface YYRegisterTableConnBrandCell : UITableViewCell

@property(nonatomic,strong) UITapGestureRecognizer *tap;
@property(nonatomic,weak)id<YYRegisterTableCellDelegate> delegate;
@property(nonatomic,copy)NSIndexPath * indexPath;

-(void)updateCellInfo:(YYTableViewCellInfoModel *)info;

@end
