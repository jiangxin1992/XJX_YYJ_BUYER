//
//  YYSwitchView.h
//  YunejianBuyer
//
//  Created by yyj on 2017/7/14.
//  Copyright © 2017年 Apple. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface YYSwitchView : UIView

-(instancetype)initWithTitleArr:(NSArray *)titleArr WithSelectIndex:(NSInteger )selectIndex WithBlock:(void (^)(NSString *type,NSInteger index))switchBlock;

@property (nonatomic,assign) NSInteger selectIndex;

@property (nonatomic,copy) void(^switchBlock)(NSString *type,NSInteger index);

@end
