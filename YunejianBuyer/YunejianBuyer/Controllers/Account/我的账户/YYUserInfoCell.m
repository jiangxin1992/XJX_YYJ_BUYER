//
//  YYUserInfoCell.m
//  Yunejian
//
//  Created by yyj on 15/7/16.
//  Copyright (c) 2015年 yyj. All rights reserved.
//

#import "YYUserInfoCell.h"

#import "YYUser.h"
#import "AppDelegate.h"
#import "UIView+UpdateAutoLayoutConstraints.h"

@interface YYUserInfoCell ()


@property (weak, nonatomic) IBOutlet UILabel *keyLabel;
@property (weak, nonatomic) IBOutlet UILabel *valueLabel;
@property (weak, nonatomic) IBOutlet UIButton *infoIconImage;
@property (weak, nonatomic) IBOutlet UIView *bottomLine;
@property (weak, nonatomic) IBOutlet UIImageView *newimage;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *ValueLabelWidthLayout;
@property (weak, nonatomic) IBOutlet UILabel *unreadLabel;


@property (nonatomic,assign)ShowType currentShowType;

@end

@implementation YYUserInfoCell

- (IBAction)buttonClicked:(id)sender{
    if (_modifyButtonClicked) {
        _modifyButtonClicked(_userInfo,_currentShowType);
    }
}

- (void)updateReadState{
    NSString *CFBundleVersion = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"];
    if([CFBundleVersion integerValue] == 19)
    {
        _newimage.hidden = [YYUser getNewsReadStateWithType:2];
    }else
    {
        _newimage.hidden = YES;
    }
}
- (IBAction)switchClicked:(id)sender{
   // UISwitch *tempSwitch = (UISwitch *)sender;
    //BOOL isOn = tempSwitch.isOn;
    //if (_switchClicked) {
    //    _switchClicked(_seller,isOn);
    //}
}

- (void)setLabelStatus:(float)alpha{
    self.keyLabel.alpha = alpha;
    self.valueLabel.alpha = alpha;
}



- (void)updateUIWithShowType:(ShowType )showType{
    
    if ([YYCurrentNetworkSpace isNetwork]
        && _userInfo) {
        _modifyButton.enabled = YES;
        [_modifyButton setTitleColor:[UIColor colorWithHex:@"47a3dc"] forState:UIControlStateNormal];
    }else{
        _modifyButton.enabled = NO;
        [_modifyButton setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
    }
    _unreadLabel.hidden = YES;
    
 //   _statusSwitch.transform = CGAffineTransformMakeScale(1, 0.9);
    _newimage.hidden = YES;
    _modifyButton.titleLabel.textAlignment = NSTextAlignmentRight;
    _modifyButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
    _modifyButton.contentEdgeInsets = UIEdgeInsetsMake(0,0, 0, 10);
    //_tipLabel.text = @"";
    if (showType == ShowTypeSeller) {
        //if (!_seller) {
            return;
        //}
    }else{
        if (!_userInfo) {
            return;
        }
    }
    
    self.currentShowType = showType;
    _modifyButton.hidden = NO;
    _valueLabelTrailing.constant = 37;
    switch (showType) {
        case ShowTypeEmail:{
            [_infoIconImage setImage:[UIImage imageNamed:@"infoemail_icon"] forState:UIControlStateNormal];
            _keyLabel.text = NSLocalizedString(@"登录邮箱",nil);
            _valueLabel.text = _userInfo.email;
            _modifyButton.hidden = YES;
            _valueLabelTrailing.constant = 13;
        }
            break;
        case ShowTypePassword:{
            [_infoIconImage setImage:[UIImage imageNamed:@"infopwd_icon"] forState:UIControlStateNormal];

            _keyLabel.text = NSLocalizedString(@"密码",nil);
            _valueLabel.text =  NSLocalizedString(@"修改密码",nil);
        }
            break;
        case ShowTypeBuyer:{
            _keyLabel.text = NSLocalizedString(@"买手店",nil);
            _valueLabel.text = _userInfo.brandName;
        }
            break;
        case ShowTypeAddress:{
            [_infoIconImage setImage:[UIImage imageNamed:@"infoaddress_icon"] forState:UIControlStateNormal];
            _keyLabel.text = NSLocalizedString(@"收件地址",nil);
            _valueLabel.text = NSLocalizedString(@"管理收件地址_short",nil);
        }
            break;
        case ShowTypeCity:{
            [_infoIconImage setImage:[UIImage imageNamed:@"infoposition_icon"] forState:UIControlStateNormal];
            _keyLabel.text = NSLocalizedString(@"所在地",nil);
            
            NSString *_nation = [LanguageManager isEnglishLanguage]?_userInfo.nationEn:_userInfo.nation;
            NSString *_province = [LanguageManager isEnglishLanguage]?_userInfo.provinceEn:_userInfo.province;
            NSString *_city = [LanguageManager isEnglishLanguage]?_userInfo.cityEn:_userInfo.city;
            _valueLabel.text = [[NSString alloc] initWithFormat:NSLocalizedString(@"%@ %@%@",nil),_nation,_province,_city];

        }
            break;
        case ShowTypeHome:{
            [_infoIconImage setImage:[UIImage imageNamed:@"home_icon"] forState:UIControlStateNormal];
            _keyLabel.text = NSLocalizedString(@"我的买手店主页",nil);
            _valueLabel.text = @"";
            [self updateReadState];
        }
            break;
        case ShowTypeOrdering:{
            [_infoIconImage setImage:[UIImage imageNamed:@"user_ordering_icon"] forState:UIControlStateNormal];
            _keyLabel.text = NSLocalizedString(@"我的预约",nil);
            _valueLabel.text = @"";
            AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
            [self updateLabelNumber:_unreadLabel nowNumber:appDelegate.unreadAppointmentStatusMsgAmount];
        }
            break;
        case ShowTypeCollection:{
            [_infoIconImage setImage:[UIImage imageNamed:@"user_collection"] forState:UIControlStateNormal];
            _keyLabel.text = NSLocalizedString(@"我的收藏",nil);
            _valueLabel.text = @"";
        }
            break;
        case ShowTypeCopBrands:{
            [_infoIconImage setImage:[UIImage imageNamed:@"user_copbrands"] forState:UIControlStateNormal];
            _keyLabel.text = NSLocalizedString(@"我的合作品牌",nil);
            _valueLabel.text = @"";
        }
            break;
        case ShowTypeInventory:{
            [_infoIconImage setImage:[UIImage imageNamed:@"user_inventory"] forState:UIControlStateNormal];
            _keyLabel.text = NSLocalizedString(@"库存调拨",nil);
            _valueLabel.text = @"";
            AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
            [self updateLabelNumber:_unreadLabel nowNumber:appDelegate.unreadInventoryAmount];
        }
            break;
        case ShowTypeSetting:{
            [_infoIconImage setImage:[UIImage imageNamed:@"user_setting"] forState:UIControlStateNormal];
            _keyLabel.text = NSLocalizedString(@"设置",nil);
            _valueLabel.text = @"";
        }
            break;
        case ShowTypeSeller:{

        }
            break;
        default:
            break;
    }
    _ValueLabelWidthLayout.constant = SCREEN_WIDTH - 50 - _valueLabelTrailing.constant - getWidthWithHeight(20, _keyLabel.text, [UIFont systemFontOfSize:14.0f]) - 20;
    
}
- (void)updateLabelNumber:(UILabel *)numLabel nowNumber:(NSInteger)value{
    //nowNumber = @"99";
    numLabel.layer.anchorPoint = CGPointMake(0.5, 0.5);
    float numFontSize = 15;
    NSString *nowNumber = [NSString stringWithFormat:@"%ld",(long)value];
    if (value > 0) {
        numLabel.layer.cornerRadius = numFontSize/2;
        numLabel.layer.masksToBounds = YES;
        CGSize numTxtSize = [nowNumber sizeWithAttributes:@{NSFontAttributeName:[UIFont boldSystemFontOfSize:11]}];
        NSInteger numTxtWidth = numTxtSize.width;
        if ([nowNumber length] >= 3) {
            numLabel.text = @"···";//[NSString stringWithFormat:@"%@",nowNumber];
        }else{
            numTxtWidth += numFontSize/2;
            numLabel.text = nowNumber;
        }
        numLabel.hidden = NO;
        numTxtWidth = MAX(numTxtWidth, numFontSize);
        [numLabel setConstraintConstant:numTxtWidth forAttribute:NSLayoutAttributeWidth];
        [numLabel setConstraintConstant:numFontSize forAttribute:NSLayoutAttributeHeight];
        
    }else{
        numLabel.hidden = YES;
        float dotSize = 7;
        numLabel.layer.cornerRadius = dotSize/2;
        numLabel.layer.masksToBounds = YES;
        [numLabel setConstraintConstant:dotSize forAttribute:NSLayoutAttributeWidth];
        [numLabel setConstraintConstant:dotSize forAttribute:NSLayoutAttributeHeight];
    }
}
-(void)hideBottomLine:(BOOL)isHide{
    _bottomLine.hidden = isHide;
}
@end
