//
//  YYIndexViewController.m
//  YunejianBuyer
//
//  Created by yyj on 2017/8/8.
//  Copyright © 2017年 Apple. All rights reserved.
//

#import "YYIndexViewController.h"

#import "YYNavigationBarViewController.h"
#import "YYCartDetailViewController.h"
#import "YYIndexBannerDetailViewController.h"
#import "YYOrderListViewController.h"
#import "YYBrandHomePageViewController.h"
#import "YYOrderingDetailViewController.h"
#import "YYBrandSeriesViewController.h"
#import "YYOrderingListViewController.h"
#import "YYMainViewController.h"
#import "YYVisibleContactInfoViewController.h"
#import "YYMessageDetailViewController.h"
#import "YYConnAddViewController.h"
#import <JavaScriptCore/JavaScriptCore.h>

#import "YYIndexTableHeadView.h"
#import "YYIndexOrderingNoDataCell.h"
#import "YYUserOrderCell.h"
#import "YYIndexSectionHeadCell.h"
#import "YYIndexOrderingPageCell.h"
#import "YYIndexRecommendationBrandCell.h"
#import "YYHotSeriesCardCell.h"
#import "YYIndexNoDataCell.h"
#import "YYIndexVerifyCell.h"
#import "YYIndexHotBrandCell.h"
#import "YYMessageButton.h"

#import "MBProgressHUD.h"

#import "YYBrandHomeInfoModel.h"
#import "YYIndexManageModel.h"
#import "YYScanFunctionModel.h"
#import "YYSeriesInfoModel.h"
#import "YYInventoryBoardModel.h"
#import "YYHotDesignerBrandsModel.h"
#import "YYHotDesignerBrandsSeriesModel.h"
#import "YYIndexApi.h"
#import "YYOpusApi.h"
#import "YYOrderingApi.h"
#import "AppDelegate.h"
#import <MJRefresh.h>
#import "YYUser.h"
#import "YYUserApi.h"
#import "YYConnApi.h"

#import "YYQRCode.h"

#define NoDataCellHeight 250

#define IndexOrderCellHeight 71

#define IndexOrderingCellHeight 194 + 17
#define IndexOrderingCellNoDataHeight 165

#define IndexVerifyCellHeight 317
#define IndexPendingCellHeight 250

#define IndexHotBrandCellHeight 316
#define IndexHotBrandNoSeriesCellHeight 114

#define IndexSectionHeadOrder 50
#define IndexSectionHeadOrdering 60
#define IndexSectionHeadVerify 10
#define IndexSectionHeadHotBrand 60

@interface YYIndexViewController ()<UITableViewDelegate,UITableViewDataSource>

@property (nonatomic, strong) YYNavigationBarViewController *navigationBarViewController;

@property (nonatomic,strong) UITableView *tableView;
@property (nonatomic,strong) YYIndexTableHeadView *headView;

@property (nonatomic,strong) YYMessageButton *messageButton;

@property (nonatomic,strong) YYIndexManageModel *indexManageModel;

@property (nonatomic,assign) BOOL isHeadRefresh;
@property (nonatomic,assign) NSInteger requestCount;

@property (nonatomic,assign) CGPoint contentOffset;

@property (nonatomic,assign) BOOL isFirstLoad;

@end

@implementation YYIndexViewController

#pragma mark - --------------生命周期--------------
- (void)viewDidLoad {
    [super viewDidLoad];
    [self SomePrepare];
    [self UIConfig];
    [self RequestData];
}
-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    if(_indexManageModel){
        if(!_isFirstLoad){
            [self headerWithRefreshingActionIsShowHud:NO];
        }else{
            _isFirstLoad = NO;
        }
    }
}
#pragma mark - --------------SomePrepare--------------
- (void)SomePrepare
{
    [self PrepareData];
    [self PrepareUI];
}
- (void)PrepareData{
    //初始化
    _isFirstLoad = YES;

    _indexManageModel = [YYIndexManageModel initModel];

    _requestCount = 0;

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationDidBecomeActiveAction) name:kApplicationDidBecomeActive object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(unreadMsgAmountChangeNotification:) name:UnreadMsgAmountChangeNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(userCheckStatusChangeNotification:) name:UserCheckStatusChangeNotification object:nil];

    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    [appDelegate checkNoticeCount];
    [[YYUser currentUser] updateUserCheckStatus];
}

- (void)PrepareUI{
    self.view.backgroundColor = [UIColor colorWithHex:@"f8f8f8"];
    //创建导航栏
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]];
    _navigationBarViewController = [storyboard instantiateViewControllerWithIdentifier:@"YYNavigationBarViewController"];
    _navigationBarViewController.previousTitle = nil;
    _navigationBarViewController.nowTitle = nil;
    _navigationBarViewController.imageTitle = @"index_nav_head";
    _navigationBarViewController.isGoBackHide = YES;
    [self.view addSubview:_navigationBarViewController.view];
    [_navigationBarViewController updateUI];
    [_navigationBarViewController.view mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.top.mas_equalTo(0);
        make.height.mas_equalTo(kNavigationBarHeight);
    }];

    UIButton *sweepYardButton = [UIButton getCustomImgBtnWithImageStr:@"scan_button_icon" WithSelectedImageStr:nil];
    [_navigationBarViewController.view addSubview:sweepYardButton];
    [sweepYardButton addTarget:self action:@selector(sweepYardButtonClicked) forControlEvents:UIControlEventTouchUpInside];
    [sweepYardButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(0);
        make.bottom.mas_equalTo(-1);
        make.width.mas_equalTo(50);
        make.left.mas_equalTo(0);
    }];

    _messageButton = [[YYMessageButton alloc] init];
    [_navigationBarViewController.view addSubview:_messageButton];
    [_messageButton addTarget:self action:@selector(messageButtonClicked) forControlEvents:UIControlEventTouchUpInside];
    [_messageButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(0);
        make.bottom.mas_equalTo(-1);
        make.right.mas_equalTo(0);
        make.width.mas_equalTo(50);
    }];

    [_messageButton initButton:@""];
    [self updateMessageCount];

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(messageCountChanged:)
                                                 name:UnreadMsgAmountChangeNotification
                                               object:nil];
}

#pragma mark - --------------UIConfig----------------------
-(void)UIConfig{
    [self CreateTableView];
    [self addHeader];
}

-(void)CreateTableView
{
    _tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStyleGrouped];
    [self.view addSubview:_tableView];
    //    消除分割线
    _tableView.backgroundColor = [UIColor colorWithHex:@"f8f8f8"];
    _tableView.separatorStyle=UITableViewCellSeparatorStyleNone;
    _tableView.delegate=self;
    _tableView.dataSource=self;
    [_tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(_navigationBarViewController.view.mas_bottom).with.offset(0);
        make.left.right.bottom.mas_equalTo(0);
    }];

}
//MJRefresh
- (void)addHeader
{
    WeakSelf(ws);
    // 添加下拉刷新头部控件
    MJRefreshNormalHeader *header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        // 进入刷新状态就会回调这个Block
        [ws headerWithRefreshingActionIsShowHud:YES];
        AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
        [appDelegate checkNoticeCount];
        [[YYUser currentUser] updateUserCheckStatus];
    }];
    self.tableView.mj_header = header;
    self.tableView.mj_header.automaticallyChangeAlpha = YES;
    header.lastUpdatedTimeLabel.hidden = YES;
}
-(void)CreateOrUpdateTableHeadView{
    if([_indexManageModel isAllowRendering]){
        if(!_headView){
            WeakSelf(ws);
            _headView = [[YYIndexTableHeadView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 214) WithBlock:^(NSString *type,NSInteger index) {
                if([type isEqualToString:@"banner_click"]){
                    // 点击banner
                    [ws clickBannerWithIndex:index];
                }
            }];
            _tableView.tableHeaderView = _headView;
        }
        _headView.bannerListModelArray = _indexManageModel.bannerListModelArray;
        [_headView updateUI];
    }
}

#pragma mark - --------------请求数据----------------------
//错误的时候不提示。仅仅在刷新的时候取消小菊花
-(void)RequestData{
    // 进入刷新状态就会回调这个Block
    [self headerWithRefreshingActionIsShowHud:YES];
}
-(void)headRefreshRequest{
    if([[YYUser currentUser] hasPermissionsToVisit]){
        [self loadBannerInfo];
        [self loadIndexOrderingInfo];
        [self loadHotBrandsList];
    }else{
        [self loadBannerInfo];
    }
}
//获取首页banner
-(void)loadBannerInfo{
    WeakSelf(ws);
    //获取首页banner
    [YYIndexApi getBannerListWithBlock:^(YYRspStatusAndMessage *rspStatusAndMessage, NSArray *returnArr, NSError *error) {
        _requestCount ++;
        if(!_indexManageModel.bannerDataHaveBeenSuccessful){
            _indexManageModel.bannerDataHaveBeenSuccessful = YES;
        }
        if(rspStatusAndMessage.status == kCode100){
            ws.indexManageModel.bannerListModelArray = returnArr;
        }
        [ws reloadTableView];
    }];
}
//获取首页订货会列表
-(void)loadIndexOrderingInfo{
    WeakSelf(ws);
    //获取首页订货会列表
    [YYOrderingApi getIndexOrderingListWithBlock:^(YYRspStatusAndMessage *rspStatusAndMessage, YYOrderingListModel *orderingListModel, NSError *error) {
        _requestCount ++;
        if(!_indexManageModel.orderingDataHaveBeenSuccessful){
            _indexManageModel.orderingDataHaveBeenSuccessful = YES;
        }
        if(rspStatusAndMessage.status == kCode100){
            ws.indexManageModel.orderingListModel = orderingListModel;
        }
        [ws reloadTableView];
    }];
}
//获取热门品牌列表
-(void)loadHotBrandsList{
    WeakSelf(ws);
    //获取首页订货会列表
    [YYIndexApi getHotBrandsListWithBlock:^(YYRspStatusAndMessage *rspStatusAndMessage, NSArray *hotList, NSError *error) {
        _requestCount ++;
        if(!_indexManageModel.hotDesignerBrandsDataHaveBeenSuccessful){
            _indexManageModel.hotDesignerBrandsDataHaveBeenSuccessful = YES;
        }
        if(rspStatusAndMessage.status == kCode100){
            for (YYHotDesignerBrandsModel *brandModel in hotList) {
                if([brandModel.seriesBoList isNilOrEmpty]){
                    brandModel.seriesBoListNum = @(0);
                }else{
                    brandModel.seriesBoListNum = @(brandModel.seriesBoList.count);
                }
            }
            ws.indexManageModel.hotDesignerBrandsModelArray = hotList;
        }
        [ws reloadTableView];
    }];
}
#pragma mark - --------------系统代理----------------------
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    if([_indexManageModel isAllowRendering]){
        if([[YYUser currentUser] hasPermissionsToVisit]){
            return 3;
        }else{
            return 2;
        }
    }
    return 1;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if([_indexManageModel isAllowRendering]){
        if([[YYUser currentUser] hasPermissionsToVisit]){
            if(section == 2){
                if(_indexManageModel.hotDesignerBrandsModelArray && _indexManageModel.hotDesignerBrandsModelArray.count > 0){
                    NSInteger returnCount = _indexManageModel.hotDesignerBrandsModelArray.count;
                    return returnCount;
                }
                return 0;
            }
        }
    }
    return 1;
}
-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return [self getHeadViewHeightInSection:section];
}
-(CGFloat )getHeadViewHeightInSection:(NSInteger)section{
    if([_indexManageModel isAllowRendering]){
        if(section == 0){
            return IndexSectionHeadOrder;
        }else if(section == 1){
            if([[YYUser currentUser] hasPermissionsToVisit]){
                return IndexSectionHeadOrdering;
            }else{
                return IndexSectionHeadVerify;
            }
        }else if(section == 2){
            return IndexSectionHeadHotBrand;
        }
    }
    return 0.01;
}
-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    if([_indexManageModel isAllowRendering] && (section == 0 || section == 1 || section == 2)){
        YYIndexSectionHeadCell *cell = [[YYIndexSectionHeadCell alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, [self getHeadViewHeightInSection:section])];
        if(section == 0){
            cell.sectionHeadType = EIndexSectionHeadOrder;
            cell.titleIsCenter = YES;
            cell.topLineIsHide = YES;
            cell.moreBtnIsShow = YES;
        }else if(section == 1){
            if([[YYUser currentUser] hasPermissionsToVisit]){
                cell.sectionHeadType = EIndexSectionHeadOrdering;
                cell.titleIsCenter = YES;
                cell.topLineIsHide = NO;
                cell.moreBtnIsShow = YES;
            }else{
                cell.sectionHeadType = EIndexSectionHeadVerify;
                cell.titleIsCenter = YES;
                cell.topLineIsHide = NO;
                cell.moreBtnIsShow = NO;
            }
        }else if(section == 2){
            cell.sectionHeadType = EIndexSectionHeadHot;
            cell.titleIsCenter = YES;
            cell.topLineIsHide = NO;
            cell.moreBtnIsShow = YES;
        }
        [cell setIndexSectionHeadBlock:^(NSString *type){
            if([type isEqualToString:@"more"]){
                if(cell.sectionHeadType == EIndexSectionHeadOrdering){
                    //更多订货会
                    [self showOrderingListView];
                }else if(cell.sectionHeadType == EIndexSectionHeadOrder){
                    //更多订单
                    [self showOrderView:type];
                }else if(cell.sectionHeadType == EIndexSectionHeadHot){
                    //查看更多品牌
                    [self scanMoreBrands];
                }
            }
        }];
        [cell updateUI];
        return cell;
    }
    UIView *view = [UIView getCustomViewWithColor:nil];
    return view;
}
-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return 0.01;
}

-(UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section{
    UIView *footer = [[UIView alloc] init];
    footer.backgroundColor = _define_white_color;
    return footer;
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if([_indexManageModel isAllowRendering]){
        if(indexPath.section == 0){
            return IndexOrderCellHeight;
        }else if(indexPath.section == 1){
            if([[YYUser currentUser] hasPermissionsToVisit]){
                if(_indexManageModel.orderingListModel && _indexManageModel.orderingListModel.result.count > 0){
                    return IndexOrderingCellHeight;
                }else{
                    return IndexOrderingCellNoDataHeight;
                }
            }else{
                YYUser *user = [YYUser currentUser];
                NSInteger checkStatus = [user.checkStatus integerValue];
                if(checkStatus == 1 || checkStatus == 4){
                    return IndexVerifyCellHeight;
                }else if(checkStatus == 2){
                    return IndexPendingCellHeight;
                }else{
                    return IndexPendingCellHeight;
                }
                return IndexVerifyCellHeight;
            }
        }else if(indexPath.section == 2){
            return [self getHotCellHeightWithIndexPath:indexPath];
        }
    }
    return NoDataCellHeight;//显示那个nodata
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    WeakSelf(ws);
    if([_indexManageModel isAllowRendering]){
        if(indexPath.section == 0){
            static NSString *cellid=@"YYUserOrderCell";
            YYUserOrderCell *userOrderCell=[_tableView dequeueReusableCellWithIdentifier:cellid];
            if(!userOrderCell)
            {
                userOrderCell=[[YYUserOrderCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellid WithBlock:^(NSString *type) {
                    if([type isEqualToString:@"order_ordered"]){
                        //已下单
                        [self showOrderView:type];
                    }else if([type isEqualToString:@"order_confirmed"]){
                        //已确认
                        [self showOrderView:type];
                    }else if([type isEqualToString:@"order_produced"]){
                        //已生产
                        [self showOrderView:type];
                    }else if([type isEqualToString:@"order_delivered"]){
                        //已发货
                        [self showOrderView:type];
                    }else if([type isEqualToString:@"order_received"]){
                        //已收货
                        [self showOrderView:type];
                    }
                }];
                userOrderCell.selectionStyle = UITableViewCellSelectionStyleNone;
            }
            [userOrderCell updateUI];
            return userOrderCell;
        }else if(indexPath.section == 1){
            if([[YYUser currentUser] hasPermissionsToVisit]){
                if(_indexManageModel.orderingListModel && _indexManageModel.orderingListModel.result.count > 0){
                    static NSString *cellid=@"YYIndexOrderingPageCell";
                    YYIndexOrderingPageCell *cell=[tableView dequeueReusableCellWithIdentifier:cellid];
                    if(!cell)
                    {
                        cell=[[YYIndexOrderingPageCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellid WithBlock:^(NSString *type,YYOrderingListItemModel *listItemModel) {
                            if([type isEqualToString:@"card_click"]){
                                [ws clickOrderingCellWithModel:listItemModel];
                            }
                        }];
                        cell.selectionStyle = UITableViewCellSelectionStyleNone;
                    }
                    cell.orderingListModel = _indexManageModel.orderingListModel;
                    [cell updateUI];
                    return cell;
                }else{
                    static NSString *cellid=@"YYIndexOrderingNoDataCell";
                    YYIndexOrderingNoDataCell *cell=[tableView dequeueReusableCellWithIdentifier:cellid];
                    if(!cell)
                    {
                        cell=[[YYIndexOrderingNoDataCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellid WithBlock:nil];
                        cell.selectionStyle = UITableViewCellSelectionStyleNone;
                    }
                    return cell;
                }
            }else{

                static NSString *cellid=@"YYIndexVerifyCell";
                YYIndexVerifyCell *cell=[tableView dequeueReusableCellWithIdentifier:cellid];
                if(!cell)
                {
                    cell=[[YYIndexVerifyCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellid WithBlock:^(NSString *type) {
                        if([type isEqualToString:@"fillInformation"]){
                            //完善资料
                            [ws fillInformation];
                        }
                    }];
                    cell.selectionStyle = UITableViewCellSelectionStyleNone;
                }
                [cell updateUI];
                return cell;
            }
        }else if(indexPath.section == 2){
            static NSString *cellid=@"YYIndexHotBrandCell";
            YYIndexHotBrandCell *cell=[tableView dequeueReusableCellWithIdentifier:cellid];
            if(!cell)
            {
                cell = [[YYIndexHotBrandCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellid WithBlock:^(NSString *type,YYHotDesignerBrandsModel *hotDesignerBrandsModel,YYHotDesignerBrandsSeriesModel *seriesModel) {
                    if([type isEqualToString:@"enter_brand"]){
                        //进入品牌主页
                        NSLog(@"enter_brand");

                        YYRecommendDesignerBrandsModel *tempModel = [[YYRecommendDesignerBrandsModel alloc] init];
                        tempModel.designerId = hotDesignerBrandsModel.designerId;
                        tempModel.brandName = hotDesignerBrandsModel.brandName;
                        tempModel.logoPath = hotDesignerBrandsModel.logo;

                        [ws enterDesignerBrandsHomePageWithModel:tempModel];

                    }else if([type isEqualToString:@"enter_series"]){
                        //进入系列详情
                        NSLog(@"enter_series");

                        [ws PushSeriesDetailViewWithDesignerID:[seriesModel.designerId integerValue] WithSeriesID:[seriesModel.id integerValue]];

                    }else if([type isEqualToString:@"change_status"]){
                        //修改当前用户与品牌的关联状态
                        NSLog(@"change_status");
                        [self showOprateView:hotDesignerBrandsModel];
                    }else if([type isEqualToString:@"more_brand"]){
                        //查看更多品牌
                        NSLog(@"more_brand");
                        [[NSNotificationCenter defaultCenter] postNotificationName:kShowStyleNotification object:nil];
                    }
                }];
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
            }
            if(indexPath.row == _indexManageModel.hotDesignerBrandsModelArray.count - 1){
                cell.isLastCell = YES;
            }else{
                cell.isLastCell = NO;
            }
            cell.hotDesignerBrandsModel = _indexManageModel.hotDesignerBrandsModelArray[indexPath.row];
            [cell updateUI];
            return cell;
        }
    }
    static NSString *cellid = @"YYIndexNoDataCell";
    YYIndexNoDataCell *cell = [_tableView dequeueReusableCellWithIdentifier:cellid];
    if(!cell)
    {
        cell = [[YYIndexNoDataCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellid];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    return cell;
}
-(CGFloat )getHotCellHeightWithIndexPath:(NSIndexPath *)indexPath{
    if(![_indexManageModel.hotDesignerBrandsModelArray isNilOrEmpty]){
        if(_indexManageModel.hotDesignerBrandsModelArray.count > indexPath.row){
            YYHotDesignerBrandsModel *brandsModel = _indexManageModel.hotDesignerBrandsModelArray[indexPath.row];
            if(![brandsModel.seriesBoList isNilOrEmpty]){
                if(indexPath.row == _indexManageModel.hotDesignerBrandsModelArray.count - 1){
                    return IndexHotBrandCellHeight + 30;
                }else{
                    return IndexHotBrandCellHeight;
                }
            }else{
                return IndexHotBrandNoSeriesCellHeight;
            }
        }
    }
    return 0;
}
//#pragma mark - --------------自定义代理/block----------------------


#pragma mark - --------------自定义响应----------------------

//修改当前用户与品牌的关联状态
-(void)showOprateView:(YYHotDesignerBrandsModel *)hotDesignerBrandsModel{
    WeakSelf(ws);
    if(hotDesignerBrandsModel && [hotDesignerBrandsModel.connectStatus integerValue] == kConnStatus){
        [YYConnApi invite:[hotDesignerBrandsModel.designerId integerValue] andBlock:^(YYRspStatusAndMessage *rspStatusAndMessage, NSError *error) {
            if(rspStatusAndMessage.status == kCode100){
                hotDesignerBrandsModel.connectStatus = 0;
                [YYToast showToastWithTitle:NSLocalizedString(@"已向品牌发送合作邀请",nil) andDuration:kAlertToastDuration];
                [ws reloadTableData];
            }
        }];
    }
}

//查看更多品牌
-(void)scanMoreBrands{
    [[NSNotificationCenter defaultCenter] postNotificationName:kShowBrandListNotification object:nil userInfo:nil];
}
//未读消息变化监听 回调
- (void)unreadMsgAmountChangeNotification:(NSNotification *)notification{
//    [self reloadTableData];
//    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0];  // tableView的分类，便于使用，想使用collection直接写便可
//    [_tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
    [self reloadTableData];
}
- (void)userCheckStatusChangeNotification:(NSNotification *)notification{
    [self reloadTableData];
}
//完善资料
-(void)fillInformation{
    NSLog(@"fillInformation");
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
        [self reloadTableData];
        //更新用户审核状态
        [[YYUser currentUser] updateUserCheckStatus];
    }];
}
//跳转更多订单界面
-(void)showOrderView:(NSString *)type{
    WeakSelf(ws);

    UIStoryboard *orderStoryboard = [UIStoryboard storyboardWithName:@"OrderDetail" bundle:[NSBundle mainBundle]];
    YYOrderListViewController *orderListViewController = [orderStoryboard instantiateViewControllerWithIdentifier:@"YYOrderListViewController"];
    orderListViewController.isFromIndex = YES;
    orderListViewController.currentIndex = 0;
    if([type isEqualToString:@"more_order"]){
        //    更多订单
        orderListViewController.currentIndex = 0;
    }else if([type isEqualToString:@"order_ordered"]){
        //    已下单
        orderListViewController.currentIndex = 1;
    }else if([type isEqualToString:@"order_confirmed"]){
        //    已确认
        orderListViewController.currentIndex = 2;
    }else if([type isEqualToString:@"order_produced"]){
        //    已生产
        orderListViewController.currentIndex = 3;
    }else if([type isEqualToString:@"order_delivered"]){
        //    已发货
        orderListViewController.currentIndex = 4;
    }else if([type isEqualToString:@"order_received"]){
        //    已收货
        orderListViewController.currentIndex = 5;
    }

    [orderListViewController setCancelButtonClicked:^(){
        [ws.navigationController popViewControllerAnimated:YES];
    }];
    [self.navigationController pushViewController:orderListViewController animated:YES];
}
//  banner点击 跳转到banner详情页
-(void)clickBannerWithIndex:(NSInteger )index{

    YYBannerModel *banner = _indexManageModel.bannerListModelArray[index];

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
                        NSInteger designerid = [tempArr1[1] integerValue];
                        [self pushBrandHomePageWithDesignerID:designerid];
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
                        [self PushSeriesDetailViewWithDesignerID:designerid WithSeriesID:seriesid];
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
//跳转品牌详情页
-(void)pushBrandHomePageWithDesignerID:(NSInteger )designerId{

    [YYUserApi getDesignerHomeInfo:[[NSString alloc] initWithFormat:@"%ld",designerId] andBlock:^(YYRspStatusAndMessage *rspStatusAndMessage, YYBrandHomeInfoModel *infoModel, NSError *error) {
        if(rspStatusAndMessage.status == kCode100){
            AppDelegate *appdelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
            NSString *brandName = infoModel.brandName;
            NSString *logoPath = infoModel.logoPath;
            [appdelegate showBrandInfoViewController:[NSNumber numberWithInteger:designerId] WithBrandName:brandName WithLogoPath:logoPath parentViewController:self WithHomePageBlock:nil WithSelectedValue:nil];
        }
    }];
}
//跳转系列详情页 要先判断权限
-(void)PushSeriesDetailViewWithDesignerID:(NSInteger )designerId WithSeriesID:(NSInteger )seriesId{
    //信息全
    [YYOpusApi getConnSeriesInfoWithId:designerId seriesId:seriesId andBlock:^(YYRspStatusAndMessage *rspStatusAndMessage, YYSeriesInfoDetailModel *infoDetailModel, NSError *error) {
        if (rspStatusAndMessage.status == kCode100) {

            NSString *brandName = [NSString isNilOrEmpty:infoDetailModel.series.designerBrandName]?@"":infoDetailModel.series.designerBrandName;
            NSString *brandLogo = [NSString isNilOrEmpty:infoDetailModel.series.designerBrandLogo]?@"":infoDetailModel.series.designerBrandLogo;
            AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
            [appDelegate showSeriesInfoViewController:@(designerId) seriesId:@(seriesId) designerInfo:@[brandName,brandLogo] parentViewController:self];

        }
    }];
}
//  查看更多订货会
-(void)showOrderingListView{
    WeakSelf(ws);
    YYOrderingListViewController *orderingListViewController = [[YYOrderingListViewController alloc] init];
    [orderingListViewController setCancelButtonClicked:^(){
        [ws.navigationController popViewControllerAnimated:YES];
    }];
    [self.navigationController pushViewController:orderingListViewController animated:YES];
}
//  点击订货会cell
-(void)clickOrderingCellWithModel:(YYOrderingListItemModel *)orderingListModel{
    WeakSelf(ws);
    YYOrderingDetailViewController *orderingDetailView = [[YYOrderingDetailViewController alloc] init];
    orderingDetailView.orderingModel = orderingListModel;
    [orderingDetailView setCancelButtonClicked:^(){
        [ws.navigationController popViewControllerAnimated:YES];
    }];
    [self.navigationController pushViewController:orderingDetailView animated:YES];
}
//  进入品牌主页
-(void)enterDesignerBrandsHomePageWithModel:(YYRecommendDesignerBrandsModel *)recommendDesignerBrandsModel{

    AppDelegate *appdelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    NSString *brandName = recommendDesignerBrandsModel.brandName;
    NSString *logoPath = recommendDesignerBrandsModel.logoPath;
    [appdelegate showBrandInfoViewController:recommendDesignerBrandsModel.designerId WithBrandName:brandName WithLogoPath:logoPath parentViewController:self WithHomePageBlock:nil WithSelectedValue:nil];
    
}

//进入消息
-(void)messageButtonClicked{
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    [appDelegate showMessageView:nil parentViewController:self];
}
//进入购物车
-(void)shoppingCarButtonClicked{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Order" bundle:[NSBundle mainBundle]];
    YYCartDetailViewController *cartVC = [storyboard instantiateViewControllerWithIdentifier:@"YYCartDetailViewController"];
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:cartVC];
    nav.navigationBar.hidden = YES;

    WeakSelf(ws);
    [cartVC setGoBackButtonClicked:^(){
        [ws dismissViewControllerAnimated:YES completion:^{
            //刷新购物车图标数据
            //            [weakSelf.collectionView reloadData];
        }];
    }];

    [cartVC setToOrderList:^(){
        [ws dismissViewControllerAnimated:NO completion:^{
            //如果购物车为空了，进入订单列表界面
            [[NSNotificationCenter defaultCenter] postNotificationName:kShowOrderListNotification object:nil];
        }];
    }];

    [self presentViewController:nav animated:YES completion:nil];
}
#pragma mark - 扫码
-(void)sweepYardButtonClicked{
    YYQRCodeController *QRCode = [YYQRCodeController QRCodeSuccessMessageBlock:^(YYQRCodeController *code, NSString *messageString) {
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

    [self presentViewController:QRCode animated:YES completion:nil];
}

-(void)sweepYardStyleTypeAction:(YYScanFunctionModel *)scanModel code:(YYQRCodeController *)code{
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [YYOpusApi getStyleInfoByStyleId:[scanModel.id longLongValue] orderCode:nil andBlock:^(YYRspStatusAndMessage *rspStatusAndMessage, YYStyleInfoModel *styleInfoModel, NSError *error) {
        [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
        if(rspStatusAndMessage){
            if (rspStatusAndMessage.status == kCode100) {
                [code dismissController];
                //表示有权限访问，跳转款式详情页
                if(styleInfoModel){
                    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
                    YYInventoryBoardModel *infoModel = [styleInfoModel transformToInventoryBoardModel];
                    [appDelegate showStyleInfoViewController:infoModel parentViewController:self];
                }
            }else{
                [code toast:NSLocalizedString(@"您没有查看此款式的权限",nil) collback:^(YYQRCodeController *code) {
                    [code scanningAgain];
                }];
            }
        }else{
            [code toast:kNetworkIsOfflineTips collback:^(YYQRCodeController *code) {
                [code scanningAgain];
            }];
        }
    }];
}
#pragma mark - --------------自定义方法----------------------
-(void)updateMessageCount{
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    NSInteger msgAmount = appDelegate.unreadOrderNotifyMsgAmount + appDelegate.unreadConnNotifyMsgAmount + appDelegate.unreadPersonalMsgAmount;

    if(msgAmount > 0 || appDelegate.unreadNewsAmount >0){
        if(msgAmount > 0 ){
            [_messageButton updateButtonNumber:[NSString stringWithFormat:@"%ld",(long)msgAmount]];
        }else{
            [_messageButton updateButtonNumber:@"dot"];
        }
    }else{
        [_messageButton updateButtonNumber:@""];
    }
}

- (void)messageCountChanged:(NSNotification *)notification{
    [self updateMessageCount];
}
-(void)reloadTableData{
    [_tableView reloadData];
}
-(void)reloadTableView{
    //四次都到了 放开那个fresh 菊花
    if(_isHeadRefresh){
        NSInteger limitNum = 1;
        if([[YYUser currentUser] hasPermissionsToVisit]){
            limitNum = 3;
        }
        if(_requestCount >= limitNum){
            [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
            [self.tableView.mj_header endRefreshing];
            _isHeadRefresh = NO;
            _requestCount = 0;
            if(self.tableView){
                [self reloadTableData];
                [self CreateOrUpdateTableHeadView];
            }
        }
    }else{
        [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
        [self.tableView.mj_header endRefreshing];
        _isHeadRefresh = NO;
        _requestCount = 0;
        if(self.tableView){
            [self reloadTableData];
            [self CreateOrUpdateTableHeadView];
        }
    }
}
-(void)applicationDidBecomeActiveAction{
    if([[YYUser currentUser] hasPermissionsToVisit]){
        if(_indexManageModel){
            [self headerWithRefreshingActionIsShowHud:YES];
        }
    }else{
        if(_indexManageModel){
            [self headerWithRefreshingActionIsShowHud:YES];
        }
    }
}
-(void)headerWithRefreshingActionIsShowHud:(BOOL )isShowHud{
    if(isShowHud){
        [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    }
    self.isHeadRefresh = YES;
    self.requestCount = 0;
    [self headRefreshRequest];
}
#pragma mark - --------------other----------------------

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
