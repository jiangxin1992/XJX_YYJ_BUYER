//
//  YYCartStyleSizeInfoView.h
//  YunejianBuyer
//
//  Created by Apple on 16/3/5.
//  Copyright © 2016年 Apple. All rights reserved.
//

#import <UIKit/UIKit.h>

@class YYOrderOneColorModel,YYOrderSizeModel;

@interface YYCartStyleSizeInfoView : UIView<UITextFieldDelegate>

@property (nonatomic,strong) UILabel *sizeNameLabel;

@property (nonatomic,assign) BOOL isModifyNow;
@property (nonatomic,strong) NSIndexPath *indexPath;
@property (nonatomic,weak) id<YYTableCellDelegate> delegate;
@property (nonatomic,strong) YYOrderOneColorModel *orderOneColorModel;
@property (nonatomic,strong) YYOrderSizeModel *orderSizeModel;
@property (nonatomic, strong) YYOrderStyleModel *orderStyleMedel;


@property (nonatomic, strong) NSNumber *isColorSelect;//是否锁定color

-(void)updateUI;

-(void)setInputBoxHide:(BOOL)ishide;

@end

