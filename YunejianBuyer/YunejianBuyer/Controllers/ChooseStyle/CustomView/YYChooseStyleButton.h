//
//  YYChooseStyleButton.h
//  YunejianBuyer
//
//  Created by yyj on 2017/7/7.
//  Copyright © 2017年 Apple. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "YYChooseStyleReqModel.h"

typedef NS_ENUM(NSInteger, YYChooseStyleButtonStyle) {
    YYChooseStyleButtonStyleSort = 0,
    YYChooseStyleButtonStyleRecommendation,
    YYChooseStyleButtonStyleScreening
};
//注意控制内容长度,不然会超出
@interface YYChooseStyleButton : UIButton

+(YYChooseStyleButton *)getCustomBtnWithStyleType:(YYChooseStyleButtonStyle )chooseStyleType;

@property (nonatomic,assign)YYChooseStyleButtonStyle chooseStyleType;

@property (nonatomic,strong)YYChooseStyleReqModel *reqModel;

@property (nonatomic,assign)BOOL chooseStypeIsSelect;

-(void)updateUI;



@end
