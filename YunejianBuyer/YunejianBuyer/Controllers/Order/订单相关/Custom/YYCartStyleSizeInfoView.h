//
//  YYCartStyleSizeInfoView.h
//  YunejianBuyer
//
//  Created by Apple on 16/3/5.
//  Copyright © 2016年 Apple. All rights reserved.
//

#import <UIKit/UIKit.h>

@class YYOrderOneColorModel,YYOrderSizeModel, YYWarehouseStyleModel, YYWarehouseSizeModel;

typedef NS_ENUM(NSUInteger, YYNewStyle) {
    YYNewStyleNormal,
    YYNewStyleInventory,    //商品库存
    YYNewStyleWarehousingRecord,  //入库记录
    YYNewStyleEXwarehousingRecord,  //出库记录
    YYNewStylePackageDetail //包裹详情
};

@interface YYCartStyleSizeInfoView : UIView<UITextFieldDelegate>

@property (nonatomic, strong) UILabel *sizeNameLabel;

@property (nonatomic, assign) BOOL hiddenColor;
@property (nonatomic, assign) BOOL isModifyNow;
@property (nonatomic, assign) YYNewStyle style;
@property (nonatomic, strong) NSIndexPath *indexPath;
@property (nonatomic, weak) id<YYTableCellDelegate> delegate;
@property (nonatomic, strong) YYOrderOneColorModel *orderOneColorModel;
@property (nonatomic, strong) YYOrderSizeModel *orderSizeModel;
@property (nonatomic, strong) YYOrderStyleModel *orderStyleMedel;
@property (nonatomic, strong) YYWarehouseStyleModel *warehouseStyleModel;
@property (nonatomic, strong) YYWarehouseSizeModel *warehouseSizeModel;

@property (nonatomic, strong) NSNumber *isColorSelect;//是否锁定color

@property (nonatomic, assign) BOOL isReceived;//是否显示确认收货

-(void)updateUI;

-(void)setInputBoxHide:(BOOL)ishide;

@end

