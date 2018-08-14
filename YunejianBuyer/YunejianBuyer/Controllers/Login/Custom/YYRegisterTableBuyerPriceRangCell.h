//
//  YYRegisterTableBuyerPriceRangCell.h
//  YunejianBuyer
//
//  Created by Victor on 2017/12/26.
//  Copyright © 2017年 Apple. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "YYTableViewCellInfoModel.h"

@interface YYRegisterTableBuyerPriceRangeInfoModel : NSObject

@property (nonatomic, assign) NSInteger ismust;
@property (nonatomic, strong) NSString *minPriceTitle;
@property (nonatomic, strong) NSString *maxPriceTItle;
@property (nonatomic, strong) NSString *minPriceValue;
@property (nonatomic, strong) NSString *maxPriceValue;
@property (nonatomic, strong) NSString *minPricePlaceholder;
@property (nonatomic, strong) NSString *maxPricePlaceholder;

-(NSArray *)getParamStr;

@end

@interface YYRegisterTableBuyerPriceRangCell : UITableViewCell

@property(nonatomic,weak)id<YYRegisterTableCellDelegate> delegate;
@property(nonatomic,copy)NSIndexPath * indexPath;
@property(nonatomic,strong) UITapGestureRecognizer *tap;

-(void)updateCellInfo:(YYRegisterTableBuyerPriceRangeInfoModel *)info;

@end
