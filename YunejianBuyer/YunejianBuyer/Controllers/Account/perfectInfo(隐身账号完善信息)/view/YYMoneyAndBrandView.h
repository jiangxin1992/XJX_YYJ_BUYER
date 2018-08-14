//
//  YYMoneyAndBrandView.h
//  YunejianBuyer
//
//  Created by chuanjun sun on 2017/10/27.
//  Copyright © 2017年 Apple. All rights reserved.
//

#import <UIKit/UIKit.h>

@class YYMoneyAndBrandView;
@protocol YYMoneyAndBrandViewDelegate<NSObject>

@optional

/**
 输入的回调

 @param view 本身
 @param tag 代表哪一个输入，0 最低价, 1 最高价, 2～7 品牌1～6 ,8 其他品牌
 @param content 输入的内容
 */
- (void)YYMoneyAndBrandView:(YYMoneyAndBrandView *)view inputTag:(NSInteger)tag content:(NSString *)content;

@end

@interface YYMoneyAndBrandView : UIView
/** 代理 */
@property (nonatomic, weak) id<YYMoneyAndBrandViewDelegate> delegate;
@end
