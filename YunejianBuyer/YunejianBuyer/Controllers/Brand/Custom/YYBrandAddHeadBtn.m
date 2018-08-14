//
//  YYBrandAddHeadBtn.m
//  YunejianBuyer
//
//  Created by yyj on 2017/4/13.
//  Copyright © 2017年 Apple. All rights reserved.
//

#import "YYBrandAddHeadBtn.h"

@implementation YYBrandAddHeadBtn

+(YYBrandAddHeadBtn *)getCustomTitleBtnWithAlignment:(NSInteger )_alignment WithFont:(CGFloat )_font WithSpacing:(CGFloat )_spacing WithNormalTitle:(NSString *)_normalTitle WithNormalColor:(UIColor *)_normalColor WithSelectedTitle:(NSString *)_selectedTitle WithSelectedColor:(UIColor *)_selectedColor
{
    YYBrandAddHeadBtn *btn=[YYBrandAddHeadBtn buttonWithType:UIButtonTypeCustom];
    
    if(_normalTitle)
    {
        [btn setTitle:_normalTitle forState:UIControlStateNormal];
    }
    if(_normalColor)
    {
        [btn setTitleColor:_normalColor forState:UIControlStateNormal];
    }else
    {
        [btn setTitleColor:_define_black_color forState:UIControlStateNormal];
    }
    
    if(_selectedTitle)
    {
        [btn setTitle:_selectedTitle forState:UIControlStateSelected];
    }
    
    if(_selectedColor)
    {
        [btn setTitleColor:_selectedColor forState:UIControlStateSelected];
    }else
    {
        [btn setTitleColor:_define_black_color forState:UIControlStateSelected];
    }
    
    btn.contentHorizontalAlignment=_alignment;
    if(_font)
    {
        btn.titleLabel.font=getFont(_font);
    }
    
    return btn;
}
+(YYBrandAddHeadBtn *)getCustomBtn
{
    return [YYBrandAddHeadBtn buttonWithType:UIButtonTypeCustom];
}

@end
