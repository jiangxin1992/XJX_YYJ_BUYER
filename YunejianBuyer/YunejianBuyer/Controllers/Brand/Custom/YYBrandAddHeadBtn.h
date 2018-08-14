//
//  YYBrandAddHeadBtn.h
//  YunejianBuyer
//
//  Created by yyj on 2017/4/13.
//  Copyright © 2017年 Apple. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "YYConPeopleClass.h"
#import "YYConSuitClass.h"
#import "YYConNewBrandItemModel.h"

@interface YYBrandAddHeadBtn : UIButton

@property (strong, nonatomic) YYConPeopleClass *peopleClass;
@property (strong, nonatomic) YYConSuitClass *suitClass;
@property (strong, nonatomic) YYConNewBrandItemModel *itemModel;

+(YYBrandAddHeadBtn *)getCustomTitleBtnWithAlignment:(NSInteger )_alignment WithFont:(CGFloat )_font WithSpacing:(CGFloat )_spacing WithNormalTitle:(NSString *)_normalTitle WithNormalColor:(UIColor *)_normalColor WithSelectedTitle:(NSString *)_selectedTitle WithSelectedColor:(UIColor *)_selectedColor;
+(YYBrandAddHeadBtn *)getCustomBtn;

@end
