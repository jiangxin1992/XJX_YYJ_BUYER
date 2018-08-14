//
//  YYBrandVerifyView.h
//  YunejianBuyer
//
//  Created by yyj on 2017/10/26.
//  Copyright © 2017年 Apple. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface YYBrandVerifyView : UIView

-(instancetype)initWithSuperView:(UIView *)superView;

-(void)updateUI;

@property (nonatomic,copy) void (^verifyBlock)(NSString *type);

@end
