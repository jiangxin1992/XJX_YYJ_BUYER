//
//  YYIndexViewController.m
//  YunejianBuyer
//
//  Created by yyj on 2017/8/8.
//  Copyright © 2017年 Apple. All rights reserved.
//

#import "YYIndexViewController.h"

// c文件 —> 系统文件（c文件在前）

// 控制器
#import "YYMainViewController.h"
#import "YYOrderListViewController.h"
#import "YYCartDetailViewController.h"
#import "YYOrderingListViewController.h"
#import "YYOrderingDetailViewController.h"
#import "YYIndexBannerDetailViewController.h"
#import "YYVisibleContactInfoViewController.h"

// 自定义视图
#import "YYNavView.h"
#import "MBProgressHUD.h"
#import "YYMessageButton.h"
#import "YYIndexTableView.h"
#import "YYIndexTableHeadView.h"

// 接口

// 分类

// 自定义类和三方类（ cocoapods类 > model > 工具类 > 其他）
#import "YYQRCode.h"

#import "YYUser.h"
#import "YYBannerModel.h"
#import "YYIndexViewLogic.h"
#import "YYStyleInfoModel.h"
#import "YYScanFunctionModel.h"
#import "YYBrandHomeInfoModel.h"
#import "YYStyleOneColorModel.h"
#import "YYSeriesInfoDetailModel.h"
#import "YYHotDesignerBrandsModel.h"
#import "YYUntreatedMsgAmountModel.h"
#import "YYHotDesignerBrandsSeriesModel.h"

#import "AppDelegate.h"

@interface YYIndexViewController ()<YYIndexViewProtocol>

@property (nonatomic, strong) MBProgressHUD *hud;

@property (nonatomic, strong) YYNavView *navView;
@property (nonatomic, strong) YYIndexTableView *tableView;
@property (nonatomic, strong) UIButton *sweepYardButton;
@property (nonatomic, strong) YYQRCodeController *QRCode;
@property (nonatomic, strong) YYMessageButton *messageButton;

@property (nonatomic, strong) YYIndexViewLogic *indexViewLogic;

@end

@implementation YYIndexViewController
#pragma mark - --------------Life Cycle--------------
- (void)viewDidLoad {
    [super viewDidLoad];
    [self SomePrepare];
    [self UIConfig];
    [self RequestData];
}
-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    if(_indexViewLogic){
        if(!_indexViewLogic.isFirstLoad){
            [self headerWithRefreshingActionIsShowHud:NO];
        }else{
            _indexViewLogic.isFirstLoad = NO;
        }
    }
}
- (void)viewWillLayoutSubviews{

    [_sweepYardButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(kStatusBarHeight);
        make.bottom.mas_equalTo(-1);
        make.width.mas_equalTo(50);
        make.left.mas_equalTo(0);
    }];

    [_messageButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(kStatusBarHeight);
        make.bottom.mas_equalTo(-1);
        make.right.mas_equalTo(0);
        make.width.mas_equalTo(50);
    }];

    [_tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.navView.mas_bottom).with.offset(0);
        make.left.right.bottom.mas_equalTo(0);
    }];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}
#pragma mark - --------------SomePrepare--------------
- (void)SomePrepare
{
    [self PrepareData];
    [self PrepareUI];
}
- (void)PrepareData{

    _indexViewLogic = [[YYIndexViewLogic alloc] init];
    _indexViewLogic.delegate = self;

    [_indexViewLogic checkNoticeCount];
    [[YYUser currentUser] updateUserCheckStatus];

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(applicationDidBecomeActiveAction:)
                                                 name:kApplicationDidBecomeActive
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(unreadMsgAmountChangeNotification:)
                                                 name:UnreadMsgAmountChangeNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(userCheckStatusChangeNotification:)
                                                 name:UserCheckStatusChangeNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(messageCountChanged:)
                                                 name:UnreadMsgAmountChangeNotification
                                               object:nil];
}

- (void)PrepareUI{
    self.view.backgroundColor = _define_white_color;

    //创建导航栏
    self.navView = [[YYNavView alloc] initWithTitle:nil WithSuperView:self.view haveStatusView:YES];
    [self.navView setNavTitleImage:[UIImage imageNamed:@"index_nav_head"]];
    [self.navView hidesBackButton];

    [self.navView addSubview:self.sweepYardButton];

    [self.navView addSubview:self.messageButton];
    [self messageCountChanged:nil];

}

#pragma mark - --------------UIConfig----------------------
-(void)UIConfig{
    [self.view addSubview:self.tableView];
}

#pragma mark - --------------Request----------------------
//错误的时候不提示。仅仅在刷新的时候取消小菊花
-(void)RequestData{
    // 进入刷新状态就会回调这个Block
    [self headerWithRefreshingActionIsShowHud:YES];
}
-(void)headerWithRefreshingActionIsShowHud:(BOOL )isShowHud{
    if(isShowHud){
        [self.hud showAnimated:YES];
    }
    self.indexViewLogic.isHeadRefresh = YES;
    self.indexViewLogic.requestCount = 0;
    if([[YYUser currentUser] hasPermissionsToVisit]){
        [self.indexViewLogic loadBannerInfo];
        [self.indexViewLogic loadIndexOrderingInfo];
        [self.indexViewLogic loadHotBrandsList];
    }else{
        [self.indexViewLogic loadBannerInfo];
    }
}
#pragma mark - --------------SystemDelegate----------------------


#pragma mark - --------------CustomDelegate----------------------
#pragma mark logicDelegate
-(void)requestDataCompletedWithType:(YYLogicAPIType)logicAPIType{
    if(logicAPIType == YYLogicAPITypeBannerList){//获取首页banner

        [self updateStatusAfterMainRequestEnd];

    }else if(logicAPIType == YYLogicAPITypeOrderingList){//获取首页订货会列表

        [self updateStatusAfterMainRequestEnd];

    }else if(logicAPIType == YYLogicAPITypeHotDesignerBrands){//获取热门品牌列表

        [self updateStatusAfterMainRequestEnd];

    }else if(logicAPIType == YYLogicAPITypeDesignerHomeInfo){//获取banner对应的设计师信息

        [self enterDesignerBrandsHomePageWithModel:[_indexViewLogic.bannerDesignerHomeInfoModel toHotDesignerBrandsModel]];

    }else if(logicAPIType == YYLogicAPITypeConnInvite){//修改当前用户与品牌的关联状态 添加

        [YYToast showToastWithTitle:NSLocalizedString(@"已向品牌发送合作邀请",nil) andDuration:kAlertToastDuration];
        [_tableView reloadTableData];

    }else if(logicAPIType == YYLogicAPITypeSeriesDetail){//获取系列详情

        [self PushSeriesDetailView];

    }else if(logicAPIType == YYLogicAPITypeSweepToStyleInfo){//获取款式信息

        [self.hud hideAnimated:YES];
        [_QRCode dismissController];
        if(_indexViewLogic.styleInfoModel){
            AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
            YYStyleOneColorModel *infoModel = [_indexViewLogic.styleInfoModel transformToStyleOneColorModel];
            [appDelegate showStyleInfoViewController:infoModel parentViewController:self];
        }

    }
}
-(void)requestDataErrorWithType:(YYLogicAPIType)logicAPIType WithError:(NSError *)error{
    if(logicAPIType == YYLogicAPITypeBannerList){//获取首页banner

        [self updateStatusAfterMainRequestEnd];

    }else if(logicAPIType == YYLogicAPITypeOrderingList){//获取首页订货会列表

        [self updateStatusAfterMainRequestEnd];

    }else if(logicAPIType == YYLogicAPITypeHotDesignerBrands){//获取热门品牌列表

        [self updateStatusAfterMainRequestEnd];

    }else if(logicAPIType == YYLogicAPITypeDesignerHomeInfo){//获取banner对应的设计师信息

    }else if(logicAPIType == YYLogicAPITypeConnInvite){//修改当前用户与品牌的关联状态 添加

    }else if(logicAPIType == YYLogicAPITypeSeriesDetail){//获取系列详情

    }else if(logicAPIType == YYLogicAPITypeSweepToStyleInfo){//获取款式信息

        [self.hud hideAnimated:YES];
        [_QRCode toast:NSLocalizedString(@"您没有查看此款式的权限",nil) collback:^(YYQRCodeController *code) {
            [_QRCode scanningAgain];
        }];

    }
}

-(void)requestDataFailureWithType:(YYLogicAPIType)logicAPIType{
    if(logicAPIType == YYLogicAPITypeBannerList){//获取首页banner

        [self updateStatusAfterMainRequestEnd];

    }else if(logicAPIType == YYLogicAPITypeOrderingList){//获取首页订货会列表

        [self updateStatusAfterMainRequestEnd];

    }else if(logicAPIType == YYLogicAPITypeHotDesignerBrands){//获取热门品牌列表

        [self updateStatusAfterMainRequestEnd];

    }else if(logicAPIType == YYLogicAPITypeDesignerHomeInfo){//获取banner对应的设计师信息

    }else if(logicAPIType == YYLogicAPITypeConnInvite){//修改当前用户与品牌的关联状态 添加

    }else if(logicAPIType == YYLogicAPITypeSeriesDetail){//获取系列详情

    }else if(logicAPIType == YYLogicAPITypeSweepToStyleInfo){//获取款式信息

        [self.hud hideAnimated:YES];
        [_QRCode toast:kNetworkIsOfflineTips collback:^(YYQRCodeController *code) {
            [_QRCode scanningAgain];
        }];

    }
}

#pragma mark - --------------Event Response----------------------
#pragma mark 下拉刷新
-(void)headerWithRefreshingStart{
    [self headerWithRefreshingActionIsShowHud:YES];
    [_indexViewLogic checkNoticeCount];
    [[YYUser currentUser] updateUserCheckStatus];
}
#pragma mark 查看更多品牌
-(void)scanMoreBrands{
    [[NSNotificationCenter defaultCenter] postNotificationName:kShowBrandListNotification object:nil userInfo:nil];
}
#pragma mark 完善资料
-(void)fillInformation{
    //完善后回调，更新状态。并reload
    YYVisibleContactInfoViewController *visibleContactInfoViewController = [[YYVisibleContactInfoViewController alloc] init];
    [self.navigationController pushViewController:visibleContactInfoViewController animated:YES];
    [visibleContactInfoViewController setGoBack:^{
        //返回
        for (UIViewController *temp in self.navigationController.viewControllers) {
            if ([temp isKindOfClass:[YYMainViewController class]]) {
                [self.navigationController popToViewController:temp animated:YES];
            }
        }
        //刷新该界面审核状态
        [_tableView reloadTableData];
        //更新用户审核状态
        [[YYUser currentUser] updateUserCheckStatus];
    }];
}
#pragma mark 查看更多订单
-(void)showOrderViewAtIndex:(NSInteger)pageIndex{
    WeakSelf(ws);

    UIStoryboard *orderStoryboard = [UIStoryboard storyboardWithName:@"OrderDetail" bundle:[NSBundle mainBundle]];
    YYOrderListViewController *orderListViewController = [orderStoryboard instantiateViewControllerWithIdentifier:@"YYOrderListViewController"];
    orderListViewController.currentIndex = pageIndex;

    [orderListViewController setCancelButtonClicked:^(){
        [ws.navigationController popViewControllerAnimated:YES];
    }];
    [self.navigationController pushViewController:orderListViewController animated:YES];
}
#pragma mark 跳转banner详情页
-(void)clickBannerWithIndex:(NSInteger )index{

    YYBannerModel *banner = _indexViewLogic.bannerListModelArray[index];

    //判断是否是特殊处理
    if([banner.type isEqualToString:@"LINK"]){
        if(![NSString isNilOrEmpty:banner.link]){
            if([banner.link hasPrefix:@"enter_brandHomePage"]){
                //跳转设计师详情页
                NSArray *tempArr = [banner.link componentsSeparatedByString:@"&"];
                if(tempArr.count > 1){
                    NSString *designerid_str = tempArr[1];
                    NSArray *tempArr1 = [designerid_str componentsSeparatedByString:@"="];
                    if(tempArr1.count > 1){
                        NSInteger designerId = [tempArr1[1] integerValue];
                        //跳转设计师主页（获取设计师信息是跳转的请提）
                        [_indexViewLogic getDesignerHomeInfoWithDesignerId:designerId];
                        return;
                    }
                }
            }else if([banner.link hasPrefix:@"enter_seriesDetail"]){
                //跳转系列详情页
                NSArray *tempArr = [banner.link componentsSeparatedByString:@"&"];
                if(tempArr.count > 2){

                    NSInteger designerid = 0;
                    NSInteger seriesid = 0;
                    BOOL has_designerid = NO;
                    BOOL has_seriesid = NO;

                    NSString *designerid_str = tempArr[1];
                    NSArray *tempArr1 = [designerid_str componentsSeparatedByString:@"="];
                    if(tempArr1.count > 1){
                        designerid = [tempArr1[1] integerValue];
                        has_designerid = YES;
                    }

                    NSString *seriesid_str = tempArr[2];
                    NSArray *tempArr2 = [seriesid_str componentsSeparatedByString:@"="];
                    if(tempArr2.count > 1){
                        seriesid = [tempArr2[1] integerValue];
                        has_seriesid = YES;
                    }

                    if(has_designerid && has_seriesid){
                        //进入系列详情(获取系列详情是跳转的前提)
                        [_indexViewLogic getConnSeriesInfoWithDesignerId:designerid WithSeriesID:seriesid];
                        return;
                    }
                }
            }
        }
    }

    //不是特殊处理，就跳转到banner详情页
    YYIndexBannerDetailViewController *indexBannerDetailViewController = [[YYIndexBannerDetailViewController alloc] init];
    indexBannerDetailViewController.bannerModel = banner;
    [indexBannerDetailViewController setCancelButtonClicked:^(){
        [self.navigationController popViewControllerAnimated:YES];
    }];
    [self.navigationController pushViewController:indexBannerDetailViewController animated:YES];
}
#pragma mark 跳转系列详情页 先获取系列详情
-(void)PushSeriesDetailView{
    if(_indexViewLogic.seriesInfoModel){
        AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
        NSString *brandName = [NSString isNilOrEmpty:_indexViewLogic.seriesInfoModel.brandName]?@"":_indexViewLogic.seriesInfoModel.brandName;
        NSString *brandLogo = [NSString isNilOrEmpty:_indexViewLogic.seriesInfoModel.series.designerBrandLogo]?@"":_indexViewLogic.seriesInfoModel.series.designerBrandLogo;
        [appDelegate showSeriesInfoViewController:_indexViewLogic.seriesInfoModel.series.designerId seriesId:_indexViewLogic.seriesInfoModel.series.id designerInfo:@[brandName,brandLogo] parentViewController:self];
    }
}
#pragma mark 查看更多订货会
-(void)showOrderingListView{
    WeakSelf(ws);
    YYOrderingListViewController *orderingListViewController = [[YYOrderingListViewController alloc] init];
    [orderingListViewController setCancelButtonClicked:^(){
        [ws.navigationController popViewControllerAnimated:YES];
    }];
    [self.navigationController pushViewController:orderingListViewController animated:YES];
}
#pragma mark 进入订货会详情
-(void)clickOrderingCellWithModel:(YYOrderingListItemModel *)orderingListModel{
    WeakSelf(ws);
    YYOrderingDetailViewController *orderingDetailView = [[YYOrderingDetailViewController alloc] init];
    orderingDetailView.orderingModel = orderingListModel;
    [orderingDetailView setCancelButtonClicked:^(){
        [ws.navigationController popViewControllerAnimated:YES];
    }];
    [self.navigationController pushViewController:orderingDetailView animated:YES];
}
#pragma mark 进入品牌主页
-(void)enterDesignerBrandsHomePageWithModel:(YYHotDesignerBrandsModel *)hotDesignerBrandsModel{

    AppDelegate *appdelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    NSString *brandName = hotDesignerBrandsModel.brandName;
    NSString *logoPath = hotDesignerBrandsModel.logo;
    [appdelegate showBrandInfoViewController:hotDesignerBrandsModel.designerId WithBrandName:brandName WithLogoPath:logoPath parentViewController:self WithHomePageBlock:nil WithSelectedValue:nil];

}
#pragma mark 进入消息
-(void)messageButtonClicked{
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    [appDelegate showMessageView:nil parentViewController:self];
}
#pragma mark 进入购物车
-(void)shoppingCarButtonClicked{
    WeakSelf(ws);
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Order" bundle:[NSBundle mainBundle]];
    YYCartDetailViewController *cartVC = [storyboard instantiateViewControllerWithIdentifier:@"YYCartDetailViewController"];
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:cartVC];
    nav.navigationBar.hidden = YES;

    [cartVC setGoBackButtonClicked:^(){
        [ws dismissViewControllerAnimated:YES completion:nil];
    }];

    [cartVC setToOrderList:^(){
        [ws dismissViewControllerAnimated:NO completion:^{
            //如果购物车为空了，进入订单列表界面
            [[NSNotificationCenter defaultCenter] postNotificationName:kShowOrderListNotification object:nil];
        }];
    }];

    [self presentViewController:nav animated:YES completion:nil];
}
#pragma mark 扫码
-(void)sweepYardButtonClicked{
    _QRCode = [YYQRCodeController QRCodeSuccessMessageBlock:^(YYQRCodeController *code, NSString *messageString) {
        NSData *JSONData = [messageString dataUsingEncoding:NSUTF8StringEncoding];
        NSDictionary *responseJSON = [NSJSONSerialization JSONObjectWithData:JSONData options:NSJSONReadingMutableLeaves error:nil];
        //扫码回调
        YYScanFunctionModel *scanModel = [[YYScanFunctionModel alloc] init];
        scanModel.env = responseJSON[@"env"];// @"TEST";
        scanModel.type = responseJSON[@"type"];// @"STYLE";
        scanModel.id = responseJSON[@"id"]; // @"2690";
        //判断环境
        if([scanModel isRightEnvironment]){
            if([scanModel.type isEqualToString:@"STYLE"]){
                //扫码款式类型处理
                [self sweepYardStyleTypeAction:scanModel code:code];
            }
        }else{
            [code toast:NSLocalizedString(@"您没有查看此款式的权限",nil) collback:^(YYQRCodeController *code) {
                [code scanningAgain];
            }];
        }
    }];

    [self presentViewController:_QRCode animated:YES completion:nil];
}

//获取款式信息 并跳转款式页面
-(void)sweepYardStyleTypeAction:(YYScanFunctionModel *)scanModel code:(YYQRCodeController *)code{

    [self.hud showAnimated:YES];
    [_indexViewLogic getStyleInfoByStyleId:[scanModel.id longLongValue]];

}
#pragma mark 未读消息变化监听 回调
- (void)unreadMsgAmountChangeNotification:(NSNotification *)notification{
    [_tableView reloadTableData];
}
- (void)userCheckStatusChangeNotification:(NSNotification *)notification{
    [_tableView reloadTableData];
}
-(void)applicationDidBecomeActiveAction:(NSNotification *)notification{
    if([[YYUser currentUser] hasPermissionsToVisit]){
        if(_indexViewLogic){
            [self headerWithRefreshingActionIsShowHud:YES];
        }
    }else{
        if(_indexViewLogic){
            [self headerWithRefreshingActionIsShowHud:YES];
        }
    }
}
- (void)messageCountChanged:(NSNotification *)notification{
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    [appDelegate.untreatedMsgAmountModel setUnreadMessageAmount:_messageButton];
}
#pragma mark - --------------Private Methods----------------------
-(void)updateStatusAfterMainRequestEnd{
    //三次都到了 放开那个fresh 菊花
    BOOL canReload = YES;
    if(_indexViewLogic.isHeadRefresh){
        NSInteger limitNum = [[YYUser currentUser] hasPermissionsToVisit]?3:1;
        if(_indexViewLogic.requestCount < limitNum){
            canReload = NO;
        }
    }

    if(canReload){
        [self.hud hideAnimated:YES];
        [self.tableView endRefreshing];
        _indexViewLogic.isHeadRefresh = NO;
        _indexViewLogic.requestCount = 0;
        [_tableView reloadTableData];
    }
}
#pragma mark - --------------Getter/Setter Methods----------------------
#pragma mark UI Setter
-(YYIndexTableView *)tableView{
    if(!_tableView){
        WeakSelf(ws);
        _tableView = [[YYIndexTableView alloc] initWithFrame:CGRectZero style:UITableViewStyleGrouped];
        [_tableView setIndexTableViewBlock:^(YYIndexTableViewUserActionType type, NSInteger index, YYOrderingListItemModel *orderingListItemModel, YYHotDesignerBrandsModel *hotDesignerBrandsModel, YYHotDesignerBrandsSeriesModel *seriesModel) {
            if(type == YYIndexTableViewUserActionTypeMoreOrdering){
                //查看更多订货会
                [ws showOrderingListView];
            }else if(type == YYIndexTableViewUserActionTypeMoreOrder){
                //查看更多订单
                [ws showOrderViewAtIndex:index];
            }else if(type == YYIndexTableViewUserActionTypeMoreBrandByPush){
                //查看更多品牌 push
                [ws scanMoreBrands];
            }else if(type == YYIndexTableViewUserActionTypeMoreBrandByNot){
                //查看更多品牌 not
                [[NSNotificationCenter defaultCenter] postNotificationName:kShowStyleNotification object:nil];
            }else if(type == YYIndexTableViewUserActionTypeEnterOrderingDetail){
                //进入订货会详情
                [ws clickOrderingCellWithModel:orderingListItemModel];
            }else if(type == YYIndexTableViewUserActionTypeFillInformation){
                //进入完善资料页面
                [ws fillInformation];
            }else if(type == YYIndexTableViewUserActionTypeEnterDesignerHomePage){
                //进入品牌主页
                [ws enterDesignerBrandsHomePageWithModel:hotDesignerBrandsModel];
            }else if(type == YYIndexTableViewUserActionTypeEnterSeriesDetail){
                //进入系列详情(获取系列详情是跳转的前提)
                [ws.indexViewLogic getConnSeriesInfoWithDesignerId:[seriesModel.designerId integerValue] WithSeriesID:[seriesModel.id integerValue]];
            }else if(type == YYIndexTableViewUserActionTypeChangeStatus){
                //修改当前用户与品牌的关联状态
                [ws.indexViewLogic connInviteByDesignerBrandsModel:hotDesignerBrandsModel];
            }else if(type == YYIndexTableViewUserActionTypeEnterIndexBannerDetail){
                //跳转banner详情页
                [ws clickBannerWithIndex:index];
            }
        }];
        //下拉刷新
        [_tableView setHeaderWithRefreshingBlock:^{
            [ws headerWithRefreshingStart];
        }];
    }
    _tableView.indexViewLogic = _indexViewLogic;
    return _tableView;
}
-(UIButton *)sweepYardButton{
    if(!_sweepYardButton){
        _sweepYardButton = [UIButton getCustomImgBtnWithImageStr:@"scan_button_icon" WithSelectedImageStr:nil];
        [_sweepYardButton addTarget:self action:@selector(sweepYardButtonClicked) forControlEvents:UIControlEventTouchUpInside];
    }
    return _sweepYardButton;
}
-(YYMessageButton *)messageButton{
    if(!_messageButton){
        _messageButton = [[YYMessageButton alloc] init];
        [_messageButton addTarget:self action:@selector(messageButtonClicked) forControlEvents:UIControlEventTouchUpInside];
        [_messageButton initButton:@""];
    }
    return _messageButton;
}
-(MBProgressHUD *)hud{
    if(!_hud){
        _hud = [[MBProgressHUD alloc] initWithView:self.view];
        [self.view addSubview:_hud];
    }
    return _hud;
}
@end
