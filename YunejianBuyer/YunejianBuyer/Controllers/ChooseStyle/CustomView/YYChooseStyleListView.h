//
//  YYChooseStyleListView.h
//  YunejianBuyer
//
//  Created by yyj on 2017/7/9.
//  Copyright © 2017年 Apple. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "YYChooseStyleReqModel.h"
#import "YYChooseStyleButton.h"

@interface YYChooseStyleListView : UIView

@property (nonatomic,strong) YYChooseStyleReqModel *reqModel;
@property (nonatomic,assign) YYChooseStyleButtonStyle chooseStyleButtonStyle;

- (instancetype)initWithFrame:(CGRect)frame WithChooseStyleListType:(YYChooseStyleButtonStyle )chooseStyleButtonStyle WithChooseStyleReqModel:(YYChooseStyleReqModel *)reqModel;

@property (nonatomic,copy) void (^chooseStyleListBlock)(NSString *type);

-(void)closeAtion;

@end
