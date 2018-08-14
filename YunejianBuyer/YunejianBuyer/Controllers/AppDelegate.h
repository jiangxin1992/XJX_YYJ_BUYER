//
//  AppDelegate.h
//  Yunejian
//
//  Created by yyj on 15/7/3.
//  Copyright (c) 2015年 yyj. All rights reserved.
//

#import <UIKit/UIKit.h>

@class YYOpusSeriesModel,YYOrderStyleModel,YYOrderOneInfoModel,YYInventoryBoardModel,YYOrderInfoModel,YYOpusStyleModel,YYBrandSeriesToCartTempModel,YYStyleOneColorModel,YYUntreatedMsgAmountModel;

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (nonatomic, strong) UIWindow *window;
@property (nonatomic, assign) NSInteger leftMenuIndex;//跳转tabIndex
@property (nonatomic, strong) NSString *openURLInfo;//跳转url跳转信息
@property (nonatomic, assign) CGFloat keyBoardHeight;
@property (nonatomic, assign) BOOL keyBoardIsShowNow;

@property (nonatomic, strong) YYUntreatedMsgAmountModel *untreatedMsgAmountModel;

@property (nonatomic, strong) NSMutableDictionary *connDesignerInfoMap;//购物车品牌关键map
@property (atomic, strong) NSMutableArray *cartDesignerIdArray;//购物车品牌关键数组
@property (nonatomic, strong) YYOrderInfoModel *cartModel;//购物车对象
@property (nonatomic, strong) NSMutableArray *seriesArray;//系列数组

@property (nonatomic, strong) YYOrderInfoModel *orderModel;//订单对象，修改订单中的添加款式要用到
@property (nonatomic, strong) NSMutableArray *orderSeriesArray;//订单系列数组，修改订单中的添加款式要用到
@property (nonatomic, strong) YYOrderInfoModel *currentYYOrderInfoModel;//修改订单临时数据

@property (nonatomic, strong) UINavigationController *mainViewController;//首页视图

@property (nonatomic) bool inRunLoop;
@property (nonatomic, strong) NSThread* myThread;

/**
 清空本地购物车
 */
- (void)clearBuyCar;

/**
 初始化或更新(brandName和brandLogo)购物车信息

 @param info 存放系列对应的brandName,logoPath...
 */
- (void)initOrUpdateShoppingCarInfo:(NSNumber *)designerId designerInfo:(NSArray*)info;

/**
 清空本地购物车（指定设计师下的）

 @param designerId ...
 */
- (void)clearBuyCarWidthDesingerId:(NSString *)designerId;

/**
 清空delegate下的临时数据
 */
- (void)delegateTempDataClear;

/**
 获取用户未读消息数量，并更新
 */
- (void)checkNoticeCount;

/**
 获取未读的预约消息数量，并更新
 */
- (void)checkAppointmentNoticeCount;

/**
 根据index更新首页的模块视图

 @param index ...
 */
- (void)reloadRootViewController:(NSInteger)index;

/**
 进入主页
 */
- (void)enterMainIndexPage;

/**
 进入登录页面
 */
- (void)enterLoginPage;


/**
  进入系列详情

 @param designerId ...
 @param seriesId ...
 @param info 存放系列对应的brandName,logoPath...
 @param viewController ...
 */
-(void)showSeriesInfoViewController:(NSNumber*)designerId seriesId:(NSNumber*)seriesId designerInfo:(NSArray*)info parentViewController:(UIViewController*)viewController;

- (void)showBuildOrderViewController:(YYOrderInfoModel *)orderInfoModel parent:(UIViewController *)parentViewController isCreatOrder:(Boolean)isCreatOrder isReBuildOrder:(Boolean)isReBuildOrder isAppendOrder:(Boolean)isAppendOrder modifySuccess:(ModifySuccess)modifySuccess;
- (void)showBrandInfoViewController:(NSNumber*)designerId WithBrandName:(NSString *)brandName WithLogoPath:(NSString *)logoPath parentViewController:(UIViewController*)viewController WithHomePageBlock:(void(^)(NSString *type,NSNumber *connectStatus))homeblock WithSelectedValue:(void(^)(NSArray *value))valueblock;
- (void)showStyleInfoViewController:(YYOrderInfoModel *)infoModel oneInfoModel:(YYOrderOneInfoModel *)oneInfoModel orderStyleModel:(YYOrderStyleModel *)styleModel parentViewController:(UIViewController*)viewController;
- (void)showStyleInfoViewController:(YYStyleOneColorModel *)infoModel parentViewController:(UIViewController*)viewController;
- (void)showShoppingView:(BOOL )isModifyOrder styleInfoModel:(id )styleInfoModel seriesModel:(id)seriesModel opusStyleModel:(YYOpusStyleModel *)opusStyleModel currentYYOrderInfoModel:(YYOrderInfoModel *)currentYYOrderInfoModel parentView:(UIView *)parentView fromBrandSeriesView:(BOOL )isFromSeries WithBlock:(void (^)(YYBrandSeriesToCartTempModel *brandSeriesToCardTempModel))block;
- (void)showMessageView:(NSArray*)info parentViewController:(UIViewController*)viewController;

@end

