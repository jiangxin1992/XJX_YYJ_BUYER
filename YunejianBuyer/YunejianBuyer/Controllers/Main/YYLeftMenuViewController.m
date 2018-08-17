//
//  YYLeftMenuViewController.m
//  Yunejian
//
//  Created by yyj on 15/7/8.
//  Copyright (c) 2015年 yyj. All rights reserved.
//

#import "YYLeftMenuViewController.h"

// c文件 —> 系统文件（c文件在前）

// 控制器

// 自定义视图

// 接口

// 分类
#import "UIImage+YYImage.h"
#import "UIView+UpdateAutoLayoutConstraints.h"

// 自定义类和三方类（ cocoapods类 > model > 工具类 > 其他）
#import "YYUser.h"
#import "YYUntreatedMsgAmountModel.h"
#import "AppDelegate.h"
#import "YYGuideHandler.h"

static const NSInteger buttonTagOffset = 50000;

#define kNormalImageByIndex @"leftMenuButtonIndex_%ld_normal.png"
#define kSelectedImageByIndex @"leftMenuButtonIndex_%ld_selected.png"


#define kBrandNormaolImageName @"leftMenuButtonBrand_normal.png"
#define kBrandSelectedImageName @"leftMenuButtonBrand_selected.png"

@interface YYLeftMenuViewController ()

@property(nonatomic,strong) UIButton *currentSelectedButton;

@property (weak, nonatomic) IBOutlet UIButton *leftMenuButton_0;
@property (weak, nonatomic) IBOutlet UIButton *leftMenuButton_1;
@property (weak, nonatomic) IBOutlet UIButton *leftMenuButton_2;
@property (weak, nonatomic) IBOutlet UIButton *leftMenuButton_3;
@property (weak, nonatomic) IBOutlet UIButton *leftMenuButton_4;
@property (weak, nonatomic) IBOutlet UIButton *leftMenuButton_5;

@property (nonatomic, strong) UILabel *userUnreadMsg;
@property (nonatomic, strong) NSArray *menuButtons;

@end

@implementation YYLeftMenuViewController;
#pragma mark - --------------生命周期--------------
- (void)viewDidLoad {
    [super viewDidLoad];
    [self SomePrepare];

    [self initAndHiddenSomeButton];
    [self initUserUnreadMsg];
//    [self initIndexUnreadMsg];
    [self updateUserUnreadMsg];

    self.currentSelectedButton = _leftMenuButton_0;
    [self updateSelectedButton:_currentSelectedButton];
}

#pragma mark - --------------SomePrepare--------------
-(void)SomePrepare
{
    [self PrepareData];
    [self PrepareUI];
}

-(void)PrepareData{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(unreadMsgAmountStatusChange:) name:UnreadMsgAmountStatusChangeNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(unreadMsgAmountChangeNotification) name:UnreadMsgAmountChangeNotification object:nil];
}
- (void)unreadMsgAmountStatusChange:(NSNotification *)notification{
    [self updateUserUnreadMsg];
}
-(void)unreadMsgAmountChangeNotification{
    //消息数量变化
    [self updateUserUnreadMsg];
}
-(void)PrepareUI{}

#pragma mark - --------------UIConfig----------------------
-(void)initUserUnreadMsg{
    UIButton *userButton = nil;
    for (UIButton *menuButton in self.menuButtons) {
        if (menuButton.tag == LeftMenuButtonTypeAccount) {
            userButton = menuButton;
        }
    }
    if (userButton) {
        _userUnreadMsg = [UILabel getLabelWithAlignment:1 WithTitle:nil WithFont:11.0f WithTextColor:_define_white_color WithSpacing:0];
        [userButton addSubview:_userUnreadMsg];
        [_userUnreadMsg mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(10);
            make.width.height.mas_equalTo(14);
            make.centerX.mas_equalTo(userButton).with.offset(12);
        }];
        _userUnreadMsg.backgroundColor = [UIColor colorWithHex:@"EF4E31"];
        _userUnreadMsg.layer.masksToBounds = YES;
        _userUnreadMsg.layer.cornerRadius = 7;
        _userUnreadMsg.hidden = YES;
    }
}

- (void)initAndHiddenSomeButton{
    YYUser *user = [YYUser currentUser];
    NSInteger btnsCount = user.stockEnable ? 5 : 4;
    NSInteger btnWidth = SCREEN_WIDTH/btnsCount;

    [self initButtonIcon:self.leftMenuButton_0 tag:LeftMenuButtonTypeIndex];
    [self initButtonIcon:self.leftMenuButton_1 tag:LeftMenuButtonTypeAddBrand];
    [self initButtonIcon:self.leftMenuButton_2 tag:LeftMenuButtonTypeOrder];
    
    if (user.stockEnable) {
        [self initButtonIcon:self.leftMenuButton_3 tag:LeftMenuButtonTypeInventory];
        [self initButtonIcon:self.leftMenuButton_4 tag:LeftMenuButtonTypeAccount];
        
        [self.leftMenuButton_4 setConstraintConstant:btnWidth forAttribute:NSLayoutAttributeWidth];
    }else {
        [self initButtonIcon:self.leftMenuButton_3 tag:LeftMenuButtonTypeAccount];
        
        [self.leftMenuButton_4 hideByWidth:YES];
    }
    [self.leftMenuButton_0 setConstraintConstant:btnWidth forAttribute:NSLayoutAttributeWidth];
    [self.leftMenuButton_1 setConstraintConstant:btnWidth forAttribute:NSLayoutAttributeWidth];
    [self.leftMenuButton_2 setConstraintConstant:btnWidth forAttribute:NSLayoutAttributeWidth];
    [self.leftMenuButton_3 setConstraintConstant:btnWidth forAttribute:NSLayoutAttributeWidth];
    [self.leftMenuButton_5 hideByWidth:YES];
    self.menuButtons = @[self.leftMenuButton_0, self.leftMenuButton_1, self.leftMenuButton_2, self.leftMenuButton_3, self.leftMenuButton_4, self.leftMenuButton_5];

    [self.view updateSizes];

}
-(void)initButtonIcon:(UIButton *)button tag:(NSInteger)tag{
    button.tag = tag;
    NSString *btnStr = [self getPageName:tag];

    NSString *normal_image_name = [NSString stringWithFormat:kNormalImageByIndex,button.tag-buttonTagOffset];
    NSString *selected_image_name = [NSString stringWithFormat:kSelectedImageByIndex,button.tag-buttonTagOffset];

    [button setImage:[UIImage imageNamed:normal_image_name] forState:UIControlStateNormal];
    [button setImage:[UIImage imageNamed:selected_image_name] forState:UIControlStateHighlighted];

    [button setTitleColor:[UIColor colorWithHex:@"7d7d7d"] forState:UIControlStateNormal];
    [button setTitle:btnStr forState:UIControlStateNormal];
    [button.titleLabel setFont:[UIFont systemFontOfSize:12]];

    CGSize txtSize= [btnStr sizeWithAttributes:@{NSFontAttributeName:button.titleLabel.font} ];

    float imageWith = button.imageView.image.size.width;
    float imageHeight = button.imageView.image.size.height;
    float labelWidth = txtSize.width;
    float labelHeight = txtSize.height;
    CGFloat imageOffsetX = (imageWith + labelWidth) / 2 - imageWith / 2;
    CGFloat imageOffsetY = imageHeight / 2;

    button.imageEdgeInsets = UIEdgeInsetsMake(-imageOffsetY, imageOffsetX, imageOffsetY, -imageOffsetX);
    CGFloat labelOffsetX = (imageWith + labelWidth / 2) - (imageWith + labelWidth) / 2;
    CGFloat labelOffsetY = labelHeight / 2;
    button.titleEdgeInsets = UIEdgeInsetsMake(labelOffsetY, -labelOffsetX, -labelOffsetY, labelOffsetX);
    button.contentEdgeInsets = UIEdgeInsetsMake(10,-20,-10,-20);
}
//#pragma mark - --------------请求数据----------------------
//-(void)RequestData{}

#pragma mark - --------------系统代理----------------------


#pragma mark - --------------自定义代理/block----------------------


#pragma mark - --------------自定义响应----------------------
- (IBAction)buttonAction:(id)sender{
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    [appDelegate checkNoticeCount];
    [[YYUser currentUser] updateUserCheckStatus];

    UIButton *button = (UIButton *)sender;
    if (button != _currentSelectedButton) {
        [self updateSelectedButton:button];
    }
}

#pragma mark - --------------自定义方法----------------------
-(NSString *)getPageName:(LeftMenuButtonType )tag{
    if(tag ==LeftMenuButtonTypeIndex){
        return NSLocalizedString(@"首页",nil);
    }else if(tag == LeftMenuButtonTypeOpus){
        return NSLocalizedString(@"作品",nil);
    }else if(tag == LeftMenuButtonTypeOrder){
        return NSLocalizedString(@"订单",nil);
    }else if(tag == LeftMenuButtonTypeAccount){
        return NSLocalizedString(@"我的",nil);
    }else if(tag == LeftMenuButtonTypeAddBrand){
        return NSLocalizedString(@"品牌",nil);
    }else if(tag == LeftMenuButtonTypeSetting){
        return NSLocalizedString(@"设置",nil);
    }else if(tag == LeftMenuButtonTypeIndexChooseStyle){
        return NSLocalizedString(@"选款",nil);
    }else if (tag == LeftMenuButtonTypeInventory) {
        return NSLocalizedString(@"库存", nil);
    }
    return @"";
}
- (void)setButtonSelectedByButtonIndex:(LeftMenuButtonType)leftMenuButtonIndex{
    UIButton *button = (UIButton *)[self.view viewWithTag:leftMenuButtonIndex];
    if (button) {
        [self updateSelectedButton:button];
    }
}
-(void)updateUserUnreadMsg{
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    NSInteger userCount = 0;
    if(appDelegate.untreatedMsgAmountModel.unreadAppointmentStatusMsgAmount > 0){
        userCount++;
    }
    if(userCount > 0){
        _userUnreadMsg.hidden = NO;
        _userUnreadMsg.text = [[NSString alloc] initWithFormat:@"%ld",userCount];
    }else{
        _userUnreadMsg.hidden = YES;
        _userUnreadMsg.text = @"";
    }
}
- (void)updateSelectedButton:(UIButton *)button{
    if (_currentSelectedButton != button) {
        UIButton *oldButton = _currentSelectedButton;
        if (oldButton) {

            NSString *normal_image_name = [NSString stringWithFormat:kNormalImageByIndex,_currentSelectedButton.tag-buttonTagOffset];
            NSString *selected_image_name = [NSString stringWithFormat:kSelectedImageByIndex,_currentSelectedButton.tag-buttonTagOffset];

            [oldButton setImage:[UIImage imageNamed:normal_image_name] forState:UIControlStateNormal];
            [oldButton setImage:[UIImage imageNamed:selected_image_name] forState:UIControlStateHighlighted];
            [oldButton setTitleColor:[UIColor colorWithHex:@"7d7d7d"] forState:UIControlStateNormal];
        }

        UIButton *nowButton = button;
        if (nowButton) {

            NSString *selected_image_name = [NSString stringWithFormat:kSelectedImageByIndex,button.tag-buttonTagOffset];

            [nowButton setImage:[UIImage imageNamed:selected_image_name] forState:UIControlStateNormal];
            [nowButton setImage:[UIImage imageNamed:selected_image_name] forState:UIControlStateHighlighted];
            [nowButton setTitleColor:[UIColor colorWithHex:@"000000"] forState:UIControlStateNormal];

        }

        _currentSelectedButton = button;

    }else{
        UIButton *nowButton = button;
        if (nowButton) {
            NSInteger index = button.tag-buttonTagOffset;
            NSString *selected_image_name = [NSString stringWithFormat:kSelectedImageByIndex,index];

            [nowButton setImage:[UIImage imageNamed:selected_image_name] forState:UIControlStateNormal];
            [nowButton setImage:[UIImage imageNamed:selected_image_name] forState:UIControlStateHighlighted];
            [nowButton setTitleColor:[UIColor colorWithHex:@"000000"] forState:UIControlStateNormal];

        }

    }
    if (self.leftMenuButtonClicked) {
        AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
        appDelegate.leftMenuIndex = _currentSelectedButton.tag;
        self.leftMenuButtonClicked(_currentSelectedButton.tag);
    }
}

#pragma mark - --------------other----------------------

@end

