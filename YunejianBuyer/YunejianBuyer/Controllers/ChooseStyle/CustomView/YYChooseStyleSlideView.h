//
//  YYChooseStyleSlideView.h
//  YunejianBuyer
//
//  Created by yyj on 2017/7/10.
//  Copyright © 2017年 Apple. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "YYConClass.h"
#import "YYChooseStyleReqModel.h"

@interface YYChooseStyleSlideView : UIView

@property (strong, nonatomic) YYConClass *connClass;//类型model
@property (strong, nonatomic) YYChooseStyleReqModel *reqModel;

@property (nonatomic,copy) void (^chooseStyleSlideBlock)(NSString *type);

- (instancetype)initWithFrame:(CGRect)frame WithConClass:(YYConClass *)connClass WithReqModel:(YYChooseStyleReqModel *)reqModel;

-(void)slideShowAnimation;
-(void)slideHideAnimation;

@end
