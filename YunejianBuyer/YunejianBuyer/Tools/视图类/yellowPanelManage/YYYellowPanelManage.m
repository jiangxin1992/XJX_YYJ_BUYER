//
//  YYYellowPanelManage.m
//  Yunejian
//
//  Created by Apple on 15/11/27.
//  Copyright © 2015年 yyj. All rights reserved.
//

#import "YYYellowPanelManage.h"

// c文件 —> 系统文件（c文件在前）

// 控制器
#import "YYOrderAddMoneyLogController.h"
#import "YYAlertViewController.h"
#import "YYOrderAddressListController.h"
#import "YYOrderStatusRequestCloseViewController.h"
#import "YYOrderAppendViewController.h"
#import "YYOrderMessageOperateViewController.h"

// 自定义视图
#import "YYBrandInfoView.h"

// 接口

// 分类
#import "YYUserApi.h"
#import "YYOrderApi.h"

// 自定义类和三方类（ cocoapods类 > model > 工具类 > 其他）
#import "YYOrderStyleModel.h"
#import "YYOrderInfoModel.h"
#import "YYHomePageModel.h"
#import "YYPaymentNoteListModel.h"

#import "AppDelegate.h"

@interface YYYellowPanelManage ()

@property (nonatomic,strong) UIView *parentView;

@property (nonatomic,strong) YYOrderAddMoneyLogController *moneyLogViewContorller;
@property (nonatomic,strong) YYAlertViewController *alertViewController;
@property (nonatomic,strong) YYOrderAddressListController *buyerAddressListController;
@property (nonatomic,strong) YYDiscountViewController *discountViewController;
@property (nonatomic,strong) YYUserCheckAlertViewController *userCheckAlertViewController;
@property (nonatomic,strong) YYOrderStatusRequestCloseViewController *orderStatusRequestCloseViewController;
@property (nonatomic,strong) YYHelpPanelViewController *helpPanelViewController;
@property (nonatomic,strong) YYOrderAppendViewController *orderAppendViewController;
@property (nonatomic,strong) YYOrderMessageOperateViewController *orderMessageOperateViewController;

@end


@implementation YYYellowPanelManage

static YYYellowPanelManage *instance = nil;

+(id)allocWithZone:(struct _NSZone *)zone{
    static dispatch_once_t predicate;
    dispatch_once(&predicate, ^{
        instance = [super allocWithZone:zone];
    });
    return instance;
}

+ (YYYellowPanelManage *)instance
{
    
    if (!instance) {
        instance = [[self alloc] init];
    }
    
    return instance;
}
-(void)showOrderAddMoneyLogPanel:(NSString *)storyboardName andIdentifier:(NSString *)identifier orderCode:(NSString*)orderCode params:(NSArray*)params totalMoney:(double)totalMoney moneyType:(NSInteger)moneyType parentView:(UIViewController *)specialParentView andCallBack:(void (^)(NSString *orderCode, NSNumber *totalPercent))callback{

    WeakSelf(ws);
    [YYOrderApi getPaymentNoteList:orderCode andBlock:^(YYRspStatusAndMessage *rspStatusAndMessage, YYPaymentNoteListModel *paymentNoteList, NSError *error) {

        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:storyboardName bundle:[NSBundle mainBundle]];
        ws.moneyLogViewContorller = [storyboard instantiateViewControllerWithIdentifier:identifier];
        ws.moneyLogViewContorller.totalMoney = totalMoney;
        ws.moneyLogViewContorller.paymentNoteList = paymentNoteList;
        ws.moneyLogViewContorller.moneyType = moneyType;
        ws.moneyLogViewContorller.orderCode = orderCode;
        if(params){
            if([params count] >=1)
                ws.moneyLogViewContorller.brandLogo = [params objectAtIndex:0];
            if([params count] >=2)
                ws.moneyLogViewContorller.designerId = [[params objectAtIndex:1] integerValue];
        }
        __block UIViewController *blockParentViewController = specialParentView;
        [self.moneyLogViewContorller setCancelButtonClicked:^(){
            [blockParentViewController.navigationController popViewControllerAnimated:YES];
        }];
        [self.moneyLogViewContorller setModifySuccess:^(NSString *orderCode, NSNumber *totalPercent) {
            callback(orderCode,totalPercent);
            [blockParentViewController.navigationController popViewControllerAnimated:YES];
        }];
        [specialParentView.navigationController pushViewController:ws.moneyLogViewContorller animated:YES];
    }];
}

-(void)showYellowAlertPanel:(NSString *)storyboardName andIdentifier:(NSString *)identifier title:(NSString*)title msg:(NSString*)msg btn:(NSString*)btnStr align:(NSTextAlignment)textAlignment andCallBack:(YellowPabelCallBack)callback{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:storyboardName bundle:[NSBundle mainBundle]];
    self.alertViewController= [storyboard instantiateViewControllerWithIdentifier:identifier];
    self.alertViewController.textAlignment = textAlignment;
    self.alertViewController.titelStr = title;
    self.alertViewController.msgStr = msg;
    self.alertViewController.btnStr = btnStr;
    self.alertViewController.widthConstraintsValue = 620;
    WeakSelf(ws);
    UIView *showView = self.alertViewController.view;
    __weak UIView *weakShowView = showView;
    [self.alertViewController setCancelButtonClicked:^(NSString *value){
        if([value isEqualToString:@"makesure"]){
            callback(nil);
        }
        removeFromSuperviewUseUseAnimateAndDeallocViewController(weakShowView,ws.alertViewController);
    }];
    [self addToWindow:self.alertViewController parentView:nil];

}

-(void)showSamllYellowAlertPanel:(NSString *)storyboardName andIdentifier:(NSString *)identifier title:(NSString*)title msg:(NSString*)msg btn:(NSString*)btnStr align:(NSTextAlignment)textAlignment parentView:(UIView *)specialParentView  andCallBack:(YellowPabelCallBack)callback{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:storyboardName bundle:[NSBundle mainBundle]];
    self.alertViewController= [storyboard instantiateViewControllerWithIdentifier:identifier];
    self.alertViewController.textAlignment = textAlignment;
    self.alertViewController.titelStr = title;
    self.alertViewController.msgStr = msg;
    self.alertViewController.btnStr = btnStr;
    self.alertViewController.widthConstraintsValue = MIN(325, SCREEN_WIDTH-30);
    WeakSelf(ws);
    UIView *showView = self.alertViewController.view;
    __weak UIView *weakShowView = showView;
    [self.alertViewController setCancelButtonClicked:^(NSString *value){
        if([value isEqualToString:@"makesure"]){
            callback(nil);
        }
        removeFromSuperviewUseUseAnimateAndDeallocViewController(weakShowView,ws.alertViewController);
    }];
    [self addToWindow:self.alertViewController parentView:nil];
    
}

-(void)showOrderBuyerAddressListPanel:(NSString *)storyboardName andIdentifier:(NSString *)identifier needUnDefineBuyer:(NSInteger)needUnDefineBuyer parentView:(UIView *)specialParentView andCallBack:(YellowPabelCallBack)callback{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:storyboardName bundle:[NSBundle mainBundle]];
    self.buyerAddressListController = [storyboard instantiateViewControllerWithIdentifier:identifier];
    self.buyerAddressListController.needUnDefineBuyer = needUnDefineBuyer;
    WeakSelf(ws);
    UIView *showView = self.buyerAddressListController.view;
    __weak UIView *weakShowView = showView;
    [self.buyerAddressListController setCancelButtonClicked:^(){
        removeFromSuperviewUseUseAnimateAndDeallocViewController(weakShowView,ws.buyerAddressListController);
    }];
    [self.buyerAddressListController setMakeSureButtonClicked:^(NSString* name,YYBuyerModel *infoModel){
        removeFromSuperviewUseUseAnimateAndDeallocViewController(weakShowView,ws.buyerAddressListController);
        if(infoModel){
            callback(@[name,infoModel]);
        }else{
            callback(@[name]);
        }
    }];
    [self addToWindow:self.buyerAddressListController parentView:specialParentView];
}

-(void)showStyleDiscountPanel:(NSString *)storyboardName andIdentifier:(NSString *)identifier
                        type:(DiscountType)type
                        orderStyleModel:(YYOrderStyleModel *)orderStyleModel orderInfoModel:(YYOrderInfoModel *)orderInfoModel
                        AndSeriesId:(long)seriesId
                        originalPrice:(float)originalPrice
                        finalPrice:(float)finalPrice parentView:(UIView *)specialParentView andCallBack:(YellowPabelCallBack)callback{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:storyboardName bundle:[NSBundle mainBundle]];
    self.discountViewController = [storyboard instantiateViewControllerWithIdentifier:identifier];
    self.discountViewController.currentDiscountType = type;
    self.discountViewController.orderStyleModel = orderStyleModel;
    self.discountViewController.currentYYOrderInfoModel =orderInfoModel;
    self.discountViewController.seriesId = seriesId;    
    self.discountViewController.originalTotalPrice = originalPrice;
    self.discountViewController.finalTotalPrice = finalPrice;
    WeakSelf(ws);
    UIView *showView = self.discountViewController.view;
    __weak UIView *weakShowView = showView;
    [self.discountViewController setCancelButtonClicked:^(){
        removeFromSuperviewUseUseAnimateAndDeallocViewController(weakShowView,ws.discountViewController);
    }];
    [self.discountViewController setModifySuccess:^(){
        removeFromSuperviewUseUseAnimateAndDeallocViewController(weakShowView,ws.discountViewController);
        callback(nil);
    }];
    [self addToWindow:self.discountViewController parentView:specialParentView];
}

-(void)addToWindow:(UIViewController *)controller parentView:(UIView *)specialParentView {

    if(specialParentView != nil){
        self.parentView = specialParentView;
    }else{
        UIViewController *rootViewController = [UIApplication sharedApplication].keyWindow.rootViewController;
        self.parentView = rootViewController.view;
    }
    UIView *showView = controller.view;
    [self.parentView addSubview:showView];
    [showView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(self.parentView);
    }];
    addAnimateWhenAddSubview(showView);
}

-(void)showYellowUserCheckAlertPanel:(NSString *)storyboardName andIdentifier:(NSString *)identifier checkStyle:(ECheckStyle )checkStyle andCallBack:(YellowPabelCallBack)callback{

    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:storyboardName bundle:[NSBundle mainBundle]];
    self.userCheckAlertViewController = [storyboard instantiateViewControllerWithIdentifier:identifier];

    self.userCheckAlertViewController.checkStyle = checkStyle;

    WeakSelf(ws);
    UIView *showView = self.userCheckAlertViewController.view;
    showView.backgroundColor = [UIColor colorWithWhite:1 alpha:0.5];
    __weak UIView *weakShowView = showView;

    [self.userCheckAlertViewController setCancelButtonClicked:^{
        [weakShowView removeFromSuperview];
        ws.userCheckAlertViewController = nil;
        [[NSNotificationCenter defaultCenter] postNotificationName:kNeedLoginNotification object:nil];
    }];

    [self.userCheckAlertViewController setModifySuccess:^(){
        removeFromSuperviewUseUseAnimateAndDeallocViewController(weakShowView,ws.userCheckAlertViewController);
        callback(nil);
    }];
    [self addToWindow:self.userCheckAlertViewController parentView:nil];

    [self.userCheckAlertViewController UpdateUI];
}

-(void)showOrderStatusRequestClosePanelWidthParentView:(UIView *)specialParentView currentYYOrderInfoModel:(YYOrderInfoModel *)currentYYOrderInfoModel andCallBack:(YellowPabelCallBack)callback{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"OrderDetail" bundle:[NSBundle mainBundle]];
    self.orderStatusRequestCloseViewController = [storyboard instantiateViewControllerWithIdentifier:@"YYOrderStatusRequestCloseViewController"];
    self.orderStatusRequestCloseViewController.currentYYOrderInfoModel =  currentYYOrderInfoModel;
    WeakSelf(ws);
    UIView *showView = self.orderStatusRequestCloseViewController.view;
    __weak UIView *weakShowView = showView;
    [self.orderStatusRequestCloseViewController setCancelButtonClicked:^(){
        removeFromSuperviewUseUseAnimateAndDeallocViewController(weakShowView,ws.discountViewController);
    }];
    [self.orderStatusRequestCloseViewController setModifySuccess:^(){
        removeFromSuperviewUseUseAnimateAndDeallocViewController(weakShowView,ws.discountViewController);
        callback(nil);
    }];
    [self addToWindow:self.orderStatusRequestCloseViewController parentView:specialParentView];
}

-(void)showBrandInfoView:(YYHomePageModel *)homePageModel orderCode:(NSString *)orderCode designerId:(NSInteger)designerId{
    YYBrandInfoView *brandInfoView = nil;
    NSArray *views = [[NSBundle mainBundle] loadNibNamed:@"YYBrandInfoView" owner:nil options:nil];
    Class  targetClass = NSClassFromString(@"YYBrandInfoView");
    for (UIView *view in views) {
        if ([view isMemberOfClass:targetClass]) {
            brandInfoView =  (YYBrandInfoView *)view;

            break;
        }
    }
    if(brandInfoView == nil){
        return;
    }
    if(homePageModel != nil && homePageModel.brandIntroduction != nil){
        NSString *phone = (homePageModel.brandIntroduction.phone?homePageModel.brandIntroduction.phone:@"");
        NSString *email = (homePageModel.brandIntroduction.email?homePageModel.brandIntroduction.email:@"");
        NSString *qq = (homePageModel.brandIntroduction.qq?homePageModel.brandIntroduction.qq:@"");
        NSString *weixin = (homePageModel.brandIntroduction.weixin?homePageModel.brandIntroduction.weixin:@"");
        [brandInfoView updateUI:@[phone,email,qq,weixin]];
    }else{
        __block YYBrandInfoView *blockBrandInfoView = brandInfoView;
        [YYUserApi getOrderDesignerInfoBrandInfo:orderCode designerId:designerId andBlock:^(YYRspStatusAndMessage *rspStatusAndMessage, YYHomePageModel *homePageModel, NSError *error) {
            if(rspStatusAndMessage.status == kCode100 && blockBrandInfoView != nil){
                NSString *phone = (homePageModel.brandIntroduction.phone?homePageModel.brandIntroduction.phone:@"");
                NSString *email = (homePageModel.brandIntroduction.email?homePageModel.brandIntroduction.email:@"");
                NSString *qq = (homePageModel.brandIntroduction.qq?homePageModel.brandIntroduction.qq:@"");
                NSString *weixin = (homePageModel.brandIntroduction.weixin?homePageModel.brandIntroduction.weixin:@"");
                [blockBrandInfoView updateUI:@[phone,email,qq,weixin]];
            }
        }];
    }
    
    NSInteger infoUIWidth = CGRectGetWidth(brandInfoView.frame);
    NSInteger infoUIHeight = CGRectGetHeight(brandInfoView.frame);
    CMAlertView *alertView = [[CMAlertView alloc] initWithViews:@[brandInfoView] imageFrame:CGRectMake(0, 0, infoUIWidth, infoUIHeight) bgClose:NO];
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    alertView.specialParentView = appDelegate.mainViewController.topViewController.view;
    alertView.backgroundColor = [UIColor clearColor];
    [alertView show];
}

-(void)showhelpPanelWidthParentView:(UIView *)specialParentView  helpPanelType:(HelpPanelType)helpPanelType andCallBack:(YellowPabelCallBack)callback{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]];
    self.helpPanelViewController = [storyboard instantiateViewControllerWithIdentifier:@"YYHelpPanelViewController"];
    self.helpPanelViewController.helpPanelType = helpPanelType;
    WeakSelf(ws);
    UIView *showView = self.helpPanelViewController.view;
    __weak UIView *weakShowView = showView;
    [self.helpPanelViewController setCancelButtonClicked:^(){
        removeFromSuperviewUseUseAnimateAndDeallocViewController(weakShowView,ws.helpPanelViewController);
    }];
    [self addToWindow:self.helpPanelViewController parentView:specialParentView];
    
}
-(void)showOrderAppendViewWidthParentView:(UIViewController *)specialParentView info:(NSArray*)info andCallBack:(YellowPabelCallBack)callback{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"OrderDetail" bundle:[NSBundle mainBundle]];
    self.orderAppendViewController = [storyboard instantiateViewControllerWithIdentifier:@"YYOrderAppendViewController"];
    self.orderAppendViewController.ordreCode = [info objectAtIndex:0];
    __block UIViewController *blockParentViewController = specialParentView;
    [self.orderAppendViewController setCancelButtonClicked:^(){
        [blockParentViewController.navigationController popViewControllerAnimated:YES];
    }];
    [self.orderAppendViewController setModifySuccess:^(NSArray *value){
        [blockParentViewController.navigationController popViewControllerAnimated:NO];
        callback(value);
    }];
    [specialParentView.navigationController pushViewController:self.orderAppendViewController animated:YES];
    
}

-(void)showOrderMessageOperateViewWidthParentView:(UIView *)specialParentView info:(YYOrderMessageConfirmInfoModel*)info andCallBack:(YellowPabelCallBack)callback{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Order" bundle:[NSBundle mainBundle]];
    self.orderMessageOperateViewController = [storyboard instantiateViewControllerWithIdentifier:@"YYOrderMessageOperateViewController"];
    self.orderMessageOperateViewController.confirmInfoModel = info ;
    WeakSelf(ws);
    UIView *showView = self.orderMessageOperateViewController.view;
    __weak UIView *weakShowView = showView;
    [self.orderMessageOperateViewController setCancelButtonClicked:^(){
        removeFromSuperviewUseUseAnimateAndDeallocViewController(weakShowView,ws.discountViewController);
    }];
    [self.orderMessageOperateViewController  setModifySuccess:^(NSArray *value){
        removeFromSuperviewUseUseAnimateAndDeallocViewController(weakShowView,ws.discountViewController);
        callback(value);
    }];
    [self addToWindow:self.orderMessageOperateViewController parentView:specialParentView];

}
@end
