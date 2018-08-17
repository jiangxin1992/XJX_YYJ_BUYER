//
//  YYInventorySubmitStyleColorSizeCell.h
//  YunejianBuyer
//
//  Created by Apple on 16/9/1.
//  Copyright © 2016年 Apple. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "YYShoppingStyleSizeInputView.h"
#import "YYInventoryStyleModel.h"
#import "YYInventoryOneColorModel.h"
#import "SCGIFImageView.h"
@interface YYInventorySubmitStyleColorSizeCell : UITableViewCell
@property (weak, nonatomic) IBOutlet SCGIFImageView *clothColorImage;

@property (nonatomic, strong) YYInventoryOneColorModel *colorModel;
@property (nonatomic, strong)  NSArray<YYOrderSizeModel> *sizeArr;
@property(nonatomic,copy)NSIndexPath * indexPath;
@property (nonatomic,weak)id<YYTableCellDelegate> delegate;

@property (nonatomic,strong) NSMutableArray *sizeInputArray;

-(void)updateUI;
-(void)setLineStyle:(NSInteger)isLast;
@end
