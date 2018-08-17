//
//  YYYellowPanelManage.h
//  Yunejian
//
//  Created by Apple on 15/11/27.
//  Copyright © 2015年 yyj. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#import "YYDiscountViewController.h"
#import "YYHelpPanelViewController.h"
#import "YYUserCheckAlertViewController.h"

@class YYOrderStyleModel,YYOrderInfoModel,YYHomePageModel,YYOrderMessageConfirmInfoModel,YYOrderAddMoneyLogController,YYAlertViewController,YYOrderAddressListController,YYDiscountViewController,YYUserCheckAlertViewController,YYOrderStatusRequestCloseViewController,YYHelpPanelViewController,YYOrderAppendViewController,YYOrderMessageOperateViewController;

@interface YYYellowPanelManage : NSObject

+ (YYYellowPanelManage *)instance;

-(void)showOrderAddMoneyLogPanel:(NSString *)storyboardName andIdentifier:(NSString *)identifier orderCode:(NSString*)orderCode params:(NSArray*)params totalMoney:(double)totalMoney moneyType:(NSInteger)moneyType isNeedRefund:(BOOL)isNeedRefund parentView:(UIViewController *)specialParentView andCallBack:(void (^)(NSString *orderCode, NSNumber *totalPercent))callback;
-(void)showYellowAlertPanel:(NSString *)storyboardName andIdentifier:(NSString *)identifier title:(NSString*)title msg:(NSString*)msg btn:(NSString*)btnStr align:(NSTextAlignment)textAlignment andCallBack:(YellowPabelCallBack)callback;
-(void)showSamllYellowAlertPanel:(NSString *)storyboardName andIdentifier:(NSString *)identifier title:(NSString*)title msg:(NSString*)msg btn:(NSString*)btnStr align:(NSTextAlignment)textAlignment parentView:(UIView *)specialParentView andCallBack:(YellowPabelCallBack)callback;
-(void)showOrderBuyerAddressListPanel:(NSString *)storyboardName andIdentifier:(NSString *)identifier needUnDefineBuyer:(NSInteger)needUnDefineBuyer parentView:(UIView *)specialParentView andCallBack:(YellowPabelCallBack)callback;
-(void)showStyleDiscountPanel:(NSString *)storyboardName andIdentifier:(NSString *)identifier type:(DiscountType)type orderStyleModel:(YYOrderStyleModel *)orderStyleModel orderInfoModel:(YYOrderInfoModel *)orderInfoModel
        AndSeriesId:(long)seriesId originalPrice:(float)originalPrice finalPrice:(float)finalPrice parentView:(UIView *)specialParentView andCallBack:(YellowPabelCallBack)callback;
-(void)showYellowUserCheckAlertPanel:(NSString *)storyboardName andIdentifier:(NSString *)identifier checkStyle:(ECheckStyle )checkStyle andCallBack:(YellowPabelCallBack)callback;
-(void)showOrderStatusRequestClosePanelWidthParentView:(UIView *)specialParentView currentYYOrderInfoModel:(YYOrderInfoModel *)currentYYOrderInfoModel andCallBack:(YellowPabelCallBack)callback;
-(void)showBrandInfoView:(YYHomePageModel *)homePageModel orderCode:(NSString *)orderCode designerId:(NSInteger)designerId;
-(void)showhelpPanelWidthParentView:(UIView *)specialParentView  helpPanelType:(HelpPanelType)helpPanelType andCallBack:(YellowPabelCallBack)callback;
-(void)showOrderAppendViewWidthParentView:(UIViewController *)specialParentView info:(NSArray*)info andCallBack:(YellowPabelCallBack)callback;
-(void)showOrderMessageOperateViewWidthParentView:(UIView *)specialParentView info:(YYOrderMessageConfirmInfoModel*)info andCallBack:(YellowPabelCallBack)callback;

@end
