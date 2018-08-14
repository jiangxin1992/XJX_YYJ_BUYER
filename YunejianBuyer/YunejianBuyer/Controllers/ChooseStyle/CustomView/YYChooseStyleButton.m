//
//  YYChooseStyleButton.m
//  YunejianBuyer
//
//  Created by yyj on 2017/7/7.
//  Copyright © 2017年 Apple. All rights reserved.
//

#import "YYChooseStyleButton.h"

@interface YYChooseStyleButton()

@property (nonatomic,strong) UIView *backView;
@property (nonatomic,strong) UILabel *contentTitleLabel;
@property (nonatomic,strong) UIImageView *contentImageView;

@end

@implementation YYChooseStyleButton
#pragma mark - INIT
+(YYChooseStyleButton *)getCustomBtnWithStyleType:(YYChooseStyleButtonStyle )chooseStyleType{
    YYChooseStyleButton *chooseStyleButton = [YYChooseStyleButton buttonWithType:UIButtonTypeCustom];
    chooseStyleButton.chooseStyleType = chooseStyleType;
    
    chooseStyleButton.backView = [UIView getCustomViewWithColor:nil];
    [chooseStyleButton addSubview:chooseStyleButton.backView];
    chooseStyleButton.backView.userInteractionEnabled = NO;
    [chooseStyleButton.backView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.bottom.mas_equalTo(0);
        make.centerX.mas_equalTo(chooseStyleButton);
    }];
    
    chooseStyleButton.contentTitleLabel = [UILabel getLabelWithAlignment:0 WithTitle:nil WithFont:14.0f WithTextColor:nil WithSpacing:0];
    [chooseStyleButton.backView addSubview:chooseStyleButton.contentTitleLabel];
    [chooseStyleButton.contentTitleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.top.bottom.mas_equalTo(0);
    }];
    
    chooseStyleButton.contentImageView = [UIImageView getCustomImg];
    [chooseStyleButton.backView addSubview:chooseStyleButton.contentImageView];
    [chooseStyleButton.contentImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(chooseStyleButton.contentTitleLabel.mas_right).with.offset(8);
        make.centerY.mas_equalTo(chooseStyleButton);
        make.width.mas_equalTo(10);
        make.height.mas_equalTo(11);
        make.right.mas_equalTo(0);
    }];
    
    return chooseStyleButton;
}
#pragma mark - updateUI
-(void)updateUI{
    if(_reqModel){
        
        NSString *contentStr = [self getContentStr];
        self.contentTitleLabel.text = contentStr;
        
        self.contentTitleLabel.textColor = [self getContentColor];
        
        NSString *imageStr = [self getImageStr];
        self.contentImageView.image = [UIImage imageNamed:imageStr];
    }
}
#pragma mark - SomeAction
-(UIColor *)getContentColor{
    BOOL isNormalColor = YES;
    
    if(self.chooseStyleType == YYChooseStyleButtonStyleSort){
        isNormalColor = NO;
    }else if(self.chooseStyleType == YYChooseStyleButtonStyleRecommendation){
        if(self.chooseStypeIsSelect){
            if([self.reqModel.recommendation integerValue] == -2 || [self.reqModel.recommendation integerValue] == -1){
                isNormalColor = YES;
            }else{
                isNormalColor = NO;
            }
        }else{
            if([self.reqModel.recommendation integerValue] == -2 || [self.reqModel.recommendation integerValue] == -1){
                isNormalColor = YES;
            }else{
                isNormalColor = NO;
            }
        }
        
    }else if(self.chooseStyleType == YYChooseStyleButtonStyleScreening){
        BOOL isScreeningChange = [self.reqModel isScreeningChange];
        if(isScreeningChange){
            isNormalColor = NO;
        }else{
            isNormalColor = YES;
        }
    }
    return isNormalColor?[UIColor colorWithHex:@"919191"]:[UIColor colorWithHex:@"ED6498"];
}
-(NSString *)getContentStr{
    NSString *contentStr = @"";
    if(self.chooseStyleType == YYChooseStyleButtonStyleSort){
        contentStr = [self.reqModel getSortDES];
    }else if(self.chooseStyleType == YYChooseStyleButtonStyleRecommendation){
        contentStr = [self.reqModel getRecommendationDES];
    }else if(self.chooseStyleType == YYChooseStyleButtonStyleScreening){
        contentStr = NSLocalizedString(@"筛选",nil);
    }
    return contentStr;
}
-(NSString *)getImageStr{
    NSString *imageStr = @"";
    
    if(self.chooseStyleType == YYChooseStyleButtonStyleSort){
        if(self.chooseStypeIsSelect){
            imageStr = @"ChooseStype_Up_Select";
        }else{
            imageStr = @"ChooseStype_Down_Select";
        }
    }else if(self.chooseStyleType == YYChooseStyleButtonStyleRecommendation){
        if(self.chooseStypeIsSelect){
            if([self.reqModel.recommendation integerValue] == -2 || [self.reqModel.recommendation integerValue] == -1){
                imageStr = @"ChooseStype_Up_Normal";
            }else{
                imageStr = @"ChooseStype_Up_Select";
            }
        }else{
            if([self.reqModel.recommendation integerValue] == -2 || [self.reqModel.recommendation integerValue] == -1){
                imageStr = @"ChooseStype_Down_Normal";
            }else{
                imageStr = @"ChooseStype_Down_Select";
            }
        }
        
    }else if(self.chooseStyleType == YYChooseStyleButtonStyleScreening){
        BOOL isScreeningChange = [self.reqModel isScreeningChange];
        if(isScreeningChange){
            imageStr = @"ChooseStype_Screening_Select";
        }else{
            imageStr = @"ChooseStype_Screening_Normal";
        }
    }
    return imageStr;
}

@end
