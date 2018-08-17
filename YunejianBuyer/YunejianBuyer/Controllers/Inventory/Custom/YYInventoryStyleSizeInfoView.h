//
//  YYInventoryStyleSizeInfoView.h
//  YunejianBuyer
//
//  Created by Apple on 16/9/2.
//  Copyright © 2016年 Apple. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "YYOrderSizeModel.h"
@interface YYInventoryStyleSizeInfoView : UIView<UITextFieldDelegate>
@property (nonatomic,strong) UILabel *sizeNameLabel;
@property (nonatomic,strong) UITextField *numInput;
@property (nonatomic,strong) UILabel *totalNumLabel;

@property (nonatomic,assign) BOOL isModifyNow;
//@property (nonatomic,assign) NSInteger index;
@property (nonatomic,strong)NSIndexPath *indexPath;
@property (nonatomic,weak)id<YYTableCellDelegate> delegate;
@property (nonatomic,strong) YYOrderSizeModel *orderSizeModel;
-(void)updateUI;
@end
