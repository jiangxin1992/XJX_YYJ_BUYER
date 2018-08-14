//
//  YYRegisterTableIntroduceCell.h
//  YunejianBuyer
//
//  Created by Victor on 2017/12/26.
//  Copyright © 2017年 Apple. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "YYTableViewCellInfoModel.h"

@interface YYRegisterTableIntroduceCell : UITableViewCell

@property(nonatomic,weak)id<YYRegisterTableCellDelegate> delegate;
@property(nonatomic,copy)NSIndexPath * indexPath;

@property(nonatomic,strong) UITapGestureRecognizer *tap;
@property (nonatomic, assign)NSInteger maxLength; //允许最大的输入个数,默认是一个很大的数

-(void)updateCellInfo:(YYTableViewCellInfoModel *)info;

@end
