//
//  YYUserInfoCell.h
//  Yunejian
//
//  Created by yyj on 15/7/16.
//  Copyright (c) 2015年 yyj. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "YYUserInfo.h"


typedef NS_ENUM(NSInteger, ShowType) {
    ShowTypeEmail = 60000,
    ShowTypePassword = 60003,
    ShowTypeBuyer = 60004,
    ShowTypeSeller = 60005,
    ShowTypeAddress = 60006,
    ShowTypeCity = 60007,
    ShowTypeHome = 60008,
    ShowTypeOrdering = 60009,
    ShowTypeCollection = 60010,
    ShowTypeSetting = 60011,
    ShowTypeCopBrands = 60013
};



typedef void (^ModifyButtonClicked)(YYUserInfo *userInfo, ShowType currentShowType);
//typedef void (^SwitchClicked)(YYSeller *seller,BOOL isOn);

@interface YYUserInfoCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIButton *modifyButton;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *valueLabelTrailing;

//@property (weak, nonatomic) IBOutlet UISwitch *statusSwitch;
//@property (weak, nonatomic) IBOutlet UILabel *tipLabel;

@property(nonatomic,strong)YYUserInfo *userInfo;
//@property(nonatomic,strong)YYSeller *seller;

@property(nonatomic,strong)ModifyButtonClicked modifyButtonClicked;
//@property(nonatomic,strong)SwitchClicked switchClicked;

- (void)updateUIWithShowType:(ShowType )showType;
- (void)setLabelStatus:(float)alpha;

-(void)hideBottomLine:(BOOL)isHide;
@end
