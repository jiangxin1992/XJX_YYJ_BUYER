//
//  YYChooseStyleViewController.m
//  YunejianBuyer
//
//  Created by yyj on 2017/7/5.
//  Copyright © 2017年 Apple. All rights reserved.
//

#import "YYChooseStyleViewController.h"

#import "UIImage+YYImage.h"
#import <AFNetworking/AFNetworkReachabilityManager.h>
#import "AppDelegate.h"
#import "YYUser.h"
#import "MBProgressHUD.h"
#import "UserDefaultsMacro.h"
#import <MJRefresh.h>
#import "YYMessageButton.h"
#import "MLInputDodger.h"

#import "YYChooseStyleCell.h"
#import "YYChooseStyleHeadView.h"
#import "YYChooseStyleListView.h"
#import "YYCompleteInformationView.h"
#import "YYChooseStyleSlideView.h"

#import "YYCartDetailViewController.h"
#import "YYChooseStyleSearchViewController.h"
#import "YYVisibleContactInfoViewController.h"
#import "YYMainViewController.h"

#import "YYChooseStyleReqModel.h"
#import "YYChooseStyleListModel.h"
#import "YYChooseStyleModel.h"
#import "YYConClass.h"
#import "YYChooseStyleApi.h"
#import "YYConnApi.h"
#import "YYUserApi.h"
#import "YYStyleOneColorModel.h"

#define YY_TABBAR_HEIGHT 78
#define YY_NAVBAR_HEIGHT 20

#define YY_COLLECTION_HEADERVIEW_HEIGHT 85//headview height
#define YY_COLLECTION_HEADERVIEW_VERIFY_HEIGHT 45//headview height
#define YY_COLLECTION_PAGESZIE 20

#define YY_ANIMATE_DURATION 0.2 //动画持续时间
#define YY_ANIMATE_BOUNDARY_OffSET 45 //动画触发offset边界
#define YY_ANIMATE_OffSET 90 //触发动画偏移量

@interface YYChooseStyleViewController ()<UICollectionViewDelegate, UICollectionViewDataSource>

@property (strong, nonatomic) UICollectionView *collectionView;

@property (strong, nonatomic) YYChooseStyleReqModel *reqModel;//用于管理，当前的筛选状态

@property (strong, nonatomic) YYConClass *connClass;//类型model

@property (strong, nonatomic) YYPageInfoModel *currentPageInfo;
@property (nonatomic,strong) UIView *noDataView;
@property (nonatomic,strong) YYCompleteInformationView *completeInformationView;
@property (nonatomic,strong) NSMutableArray *styleListArray;

//关于动画
@property (nonatomic,assign) CGFloat start_offset;
@property (nonatomic,assign) CGFloat changing_offset;
@property (nonatomic,assign) BOOL isAnimation;
@property (nonatomic,strong) YYChooseStyleHeadView *tempHeadView;
@property (nonatomic,assign) CGRect tempHeadViewAppearRect;
@property (nonatomic,assign) CGRect tempHeadViewDisappearRect;
@property (nonatomic,assign) CGRect tempHeadViewTotalDisappearRect;
@property (nonatomic,assign) BOOL isOffsetIncrease;

@property (nonatomic,strong) YYChooseStyleListView *chooseStyleListView;

@property (nonatomic,assign) BOOL canSetNormalState;

@property (nonatomic,strong) YYChooseStyleSlideView *chooseStyleSlideView;

@property (nonatomic,strong) UICollectionViewFlowLayout *collectionLayout;

@end

@implementation YYChooseStyleViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self SomePrepare];
    [self UIConfig];
    [self RequestClassData];
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    if(_collectionView){
        [_collectionView reloadData];
    }
    // 进入埋点
    [MobClick beginLogPageView:kYYPageChooseStyle];

    if(self.styleListArray && self.styleListArray.count == 0){
        [self headerWithRefreshingAction];
    }
}

- (void)viewDidAppear:(BOOL)animated{
    // 每次进入应当判断，不然无法更新
    [self CreateOrUpdateCompleteInformationView];
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    // 退出埋点
    [MobClick endLogPageView:kYYPageChooseStyle];
}

#pragma mark - SomePrepare
-(void)SomePrepare
{
    [self PrepareData];
    [self PrepareUI];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(unreadMsgAmountChangeNotification:) name:UnreadMsgAmountChangeNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(userCheckStatusChangeNotification:) name:UserCheckStatusChangeNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationDidBecomeActiveAction) name:kApplicationDidBecomeActive object:nil];
    
}
-(void)applicationDidBecomeActiveAction{
    if(self.styleListArray && self.styleListArray.count == 0){
        [self headerWithRefreshingAction];
    }
}
- (void)unreadMsgAmountChangeNotification:(NSNotification *)notification{
    if(self.tempHeadView){
        self.tempHeadView.reqModel = self.reqModel;
        [self.tempHeadView setNormalState];
    }
    [_collectionView reloadData];
}
- (void)userCheckStatusChangeNotification:(NSNotification *)notification{
    [self CreateOrUpdateCompleteInformationView];
}
-(void)PrepareData{
    _start_offset = 0.0f;
    _changing_offset = 0.0f;
    _isAnimation = NO;
    _styleListArray = [[NSMutableArray alloc] init];
    _tempHeadViewAppearRect = CGRectMake(0, 0, SCREEN_WIDTH, YY_COLLECTION_HEADERVIEW_HEIGHT);
    _tempHeadViewDisappearRect = CGRectMake(0, -45, SCREEN_WIDTH, YY_COLLECTION_HEADERVIEW_HEIGHT);
    _tempHeadViewTotalDisappearRect = CGRectMake(0, -YY_COLLECTION_HEADERVIEW_HEIGHT, SCREEN_WIDTH, YY_COLLECTION_HEADERVIEW_HEIGHT);
    _isOffsetIncrease = NO;
    _canSetNormalState = NO;
    [self InitializationReqModel];
}
-(void)PrepareUI{
//    self.automaticallyAdjustsScrollViewInsets = NO;
    self.view.shiftHeightAsDodgeViewForMLInputDodger = 40.0f;
    [self.view registerAsDodgeViewForMLInputDodger];
    self.view.backgroundColor = _define_white_color;
}
#pragma mark - UIConfig
-(void)UIConfig{
    // 列表
    [self CreateCollectionView];
    // 下拉刷新
    [self addHeader];
    // 上拉加载
    [self addFooter];
    [self CreateTempHeadView];
    [self CreateNoDataView];
    
    [self CreateOrUpdateCompleteInformationView];
}
-(void)CreateOrUpdateCompleteInformationView{
    if(!_completeInformationView){
        WeakSelf(ws);
        _completeInformationView = [[YYCompleteInformationView alloc] initWithBlock:^(NSString *type) {
            if([type isEqualToString:@"fillInformation"]){
                // 完善资料
                [ws fillInformation];
            }
        }];

        [self.view addSubview:_completeInformationView];
        [_completeInformationView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(140);
            make.left.right.mas_equalTo(0);
        }];
    }
    [_completeInformationView updateUI];

    // 变化 主要步骤， 这些改变都是在创建控件时设置的，并且做了懒加载处理，就是说创建后不能修改了，导致其他界面进入时只有隐藏账号入口隐藏 ↖。collection没有变化，
    // 加入此逻辑会在每次进入此界面时判断，刷新。 66666
    if([[YYUser currentUser] hasPermissionsToVisit]){
        _collectionView.backgroundColor =  [UIColor colorWithHex:@"F8F8F8"];
        _collectionView.scrollEnabled = YES;
        _completeInformationView.hidden = YES;
        _tempHeadView.hidden = NO;
        _collectionLayout.headerReferenceSize = CGSizeMake(SCREEN_WIDTH, YY_COLLECTION_HEADERVIEW_HEIGHT);
        
    }else{
        _collectionView.backgroundColor =  _define_white_color;
        _collectionView.scrollEnabled = NO;
        _completeInformationView.hidden = NO;
        _tempHeadView.hidden = YES;
        _collectionLayout.headerReferenceSize = CGSizeMake(SCREEN_WIDTH, YY_COLLECTION_HEADERVIEW_VERIFY_HEIGHT);
    }
}
-(void)CreateNoDataView{
    self.noDataView = addNoDataView_phone(self.view,[[NSString alloc] initWithFormat:@"%@|icon:noStyleData_icon", NSLocalizedString(@"该分类下暂无款式",nil)],@"919191",@"noStyleData_icon");
    self.noDataView.hidden = YES;
}
-(void )CreateCollectionView{
    if (!_collectionView) {
        //        6
        UIView *topview = [UIView getCustomViewWithColor:_define_white_color];
        [self.view addSubview:topview];
        [topview mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.right.top.mas_equalTo(0);
            make.height.mas_equalTo(0);
        }];

        _collectionLayout = [self getCollectionViewLayout];
        _collectionView = [[UICollectionView alloc]initWithFrame:CGRectZero collectionViewLayout:_collectionLayout];
        [self.view addSubview:_collectionView];
        [_collectionView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.right.bottom.mas_equalTo(0);
            make.top.mas_equalTo(topview.mas_bottom).with.offset(0);
        }];
        _collectionView.delegate = self;
        _collectionView.dataSource = self;
        _collectionView.showsVerticalScrollIndicator = NO;
        [_collectionView registerClass:[YYChooseStyleCell class] forCellWithReuseIdentifier:@"YYChooseStyleCell"];
        [_collectionView registerClass:[YYChooseStyleHeadView class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"YYChooseStyleHeadView"];
        _collectionView.scrollEnabled = [[YYUser currentUser] hasPermissionsToVisit];
        if([[YYUser currentUser] hasPermissionsToVisit]){
            _collectionView.backgroundColor =  [UIColor colorWithHex:@"F8F8F8"];
        }else{
            _collectionView.backgroundColor =  _define_white_color;
        }
    }
}

-(UICollectionViewFlowLayout *)getCollectionViewLayout{
    UICollectionViewFlowLayout *templayout = [[UICollectionViewFlowLayout alloc] init];
    CGFloat cellW = (SCREEN_WIDTH - 12*2 - 10)/2.0f;
    //    CGFloat cellH = 266;
    CGFloat cellH = (cellW - 10) + 106;
    templayout.itemSize = CGSizeMake(cellW, cellH);
    templayout.footerReferenceSize = CGSizeZero;
    if([[YYUser currentUser] hasPermissionsToVisit]){
        templayout.headerReferenceSize = CGSizeMake(SCREEN_WIDTH, YY_COLLECTION_HEADERVIEW_HEIGHT);
    }else{
        templayout.headerReferenceSize = CGSizeMake(SCREEN_WIDTH, YY_COLLECTION_HEADERVIEW_VERIFY_HEIGHT);
    }
    templayout.sectionInset = UIEdgeInsetsMake(12, 12, 12, 12);
    templayout.minimumInteritemSpacing = 10.0f;
    templayout.minimumLineSpacing = 15.0f;
    return templayout;
}

- (void)addHeader{
    WeakSelf(ws);
    // 添加下拉刷新头部控件
    MJRefreshNormalHeader *header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        // 进入刷新状态就会回调这个Block
        [ws headerWithRefreshingAction];
    }];
    self.collectionView.mj_header = header;
    header.lastUpdatedTimeLabel.hidden = YES;
    if([[YYUser currentUser] hasPermissionsToVisit]){
        [self.collectionView.mj_header beginRefreshing];
    }
}
-(void)headerWithRefreshingAction{
    if ([YYCurrentNetworkSpace isNetwork]){
        [self loadDataByPageIndex:1];
    }else{
        [self.collectionView.mj_header endRefreshingWithCompletionBlock:^{
            [self.collectionView setContentOffset:CGPointMake(0, 0) animated:YES];
        }];
        [YYToast showToastWithTitle:kNetworkIsOfflineTips andDuration:kAlertToastDuration];
    }
}
- (void)addFooter
{
    WeakSelf(ws);
    // 添加上拉刷新尾部控件
    self.collectionView.mj_footer = [MJRefreshBackNormalFooter footerWithRefreshingBlock:^{
        // 进入刷新状态就会回调这个Block

        if (![YYCurrentNetworkSpace isNetwork]) {
            [YYToast showToastWithTitle:kNetworkIsOfflineTips andDuration:kAlertToastDuration];
            [ws.collectionView.mj_footer endRefreshing];
            return;
        }

        if( [ws.styleListArray count] > 0 && ws.currentPageInfo
           && !ws.currentPageInfo.isLastPage){
            [ws loadDataByPageIndex:[ws.currentPageInfo.pageIndex intValue]+1];
            return;
        }

        [ws.collectionView.mj_footer endRefreshing];
    }];
}
-(void)CreateTempHeadView{
    if(!_tempHeadView){
        WeakSelf(ws);
        _tempHeadView = [[YYChooseStyleHeadView alloc] initWithFrame:_tempHeadViewAppearRect];
        [self.view addSubview:_tempHeadView];
        _tempHeadView.reqModel = _reqModel;
        _tempHeadView.headStyle = YYChooseStyleHeadCustom;
        [_tempHeadView updateUI];
        [_tempHeadView setChooseStyleBlock:^(NSString *type,YYChooseStyleButtonStyle chooseStyleButtonStyle){
            [ws ChooseStyleBlockWithType:type WithChooseStyleButtonStyle:chooseStyleButtonStyle];
        }];
        [self setAnimationTotaldisappear];
        if([[YYUser currentUser] hasPermissionsToVisit]){
            _tempHeadView.hidden = NO;
        }else{
            _tempHeadView.hidden = YES;
        }
    }
}



#pragma mark - RequestData
- (void)loadDataByPageIndex:(int)pageIndex{
    WeakSelf(ws);
    
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];

    [YYChooseStyleApi getOrderingListWithReqModel:_reqModel pageIndex:pageIndex pageSize:YY_COLLECTION_PAGESZIE andBlock:^(YYRspStatusAndMessage *rspStatusAndMessage, YYChooseStyleListModel *chooseStyleListModel, NSError *error) {
        if (rspStatusAndMessage.status == YYReqStatusCode100 && chooseStyleListModel.result
            && [chooseStyleListModel.result count] > 0) {
            ws.currentPageInfo = chooseStyleListModel.pageInfo;
            if (ws.currentPageInfo== nil || ws.currentPageInfo.isFirstPage) {
                [ws.styleListArray removeAllObjects];
            }
            [ws.styleListArray addObjectsFromArray:chooseStyleListModel.result];
        }else{

            if(chooseStyleListModel.result){
                if(!chooseStyleListModel.result.count){
                    ws.currentPageInfo = chooseStyleListModel.pageInfo;
                    if (ws.currentPageInfo== nil || ws.currentPageInfo.isFirstPage) {
                        [ws.styleListArray removeAllObjects];
                    }
                }
            }
        }
        [MBProgressHUD hideAllHUDsForView:ws.view animated:YES];
        if (rspStatusAndMessage.status != YYReqStatusCode100) {
            [YYToast showToastWithTitle:rspStatusAndMessage.message  andDuration:kAlertToastDuration];
        }
        [ws reloadCollectionViewData];
    }];
}

-(void)RequestClassData{
    WeakSelf(ws);
    [YYConnApi getConBrandClassWithBlock:^(YYRspStatusAndMessage *rspStatusAndMessage, YYConClass *connClass, NSError *error) {
        if (rspStatusAndMessage.status == YYReqStatusCode100){
            ws.connClass = connClass;
            [self removeAllSuitTypes];
        }
        [MBProgressHUD hideAllHUDsForView:ws.view animated:YES];
        if (rspStatusAndMessage.status != YYReqStatusCode100) {
            [YYToast showToastWithTitle:rspStatusAndMessage.message  andDuration:kAlertToastDuration];
        }
    }];
}
-(void)removeAllSuitTypes{
    if(_connClass){
        if(_connClass.suitTypes && _connClass.suitTypes.count > 0){
            NSMutableArray *tempArr = [[NSMutableArray alloc] init];
            for (YYConSuitClass *suitClass in _connClass.suitTypes) {
                if([suitClass.id integerValue] != -1){
                    [tempArr addObject:suitClass];
                }
            }
            _connClass.suitTypes = [tempArr copy];
        }
    }
}
#pragma mark - SomeAction
//完善资料
-(void)fillInformation{
    NSLog(@"fillInformation");
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
        [self CreateOrUpdateCompleteInformationView];
        //更新用户审核状态
        [[YYUser currentUser] updateUserCheckStatus];
    }];
}

-(void)InitializationReqModel{
    _reqModel = [[YYChooseStyleReqModel alloc] init];
    _reqModel.sortType = @"DESC";
    _reqModel.sortField = @"MISC";
    _reqModel.recommendation = @(-2);
    _reqModel.recommendationType = @(-1);
    _reqModel.curType = @(-1);
}
-(void)ChooseStyleBlockWithType:(NSString *)type WithChooseStyleButtonStyle:(YYChooseStyleButtonStyle )chooseStyleButtonStyle{
    NSLog(@"type=%@",type);
    if([type isEqualToString:@"set_normal"]){
        //收回
        [self listSetNormalWithType:type WithChooseStyleButtonStyle:chooseStyleButtonStyle];
    }else if([type isEqualToString:@"set_select"]){
        //展开
        [self listSetSelectWithType:type WithChooseStyleButtonStyle:chooseStyleButtonStyle];
    }else if([type isEqualToString:@"enter_message"]){
        //进入消息
        [self messageButtonClicked];
    }else if([type isEqualToString:@"enter_shopping"]){
        //进入购物车
        [self shoppingCarButtonClicked];
    }else if([type isEqualToString:@"search"]){
        //搜索
        [self startSearch];
    }
}
//刷新界面
- (void)reloadCollectionViewData{
    [self.collectionView.mj_header endRefreshingWithCompletionBlock:^{
        [self.collectionView setContentOffset:CGPointMake(0, 0) animated:YES];
    }];
    if(_collectionLayout){
        if([[YYUser currentUser] hasPermissionsToVisit]){
            _collectionLayout.headerReferenceSize = CGSizeMake(SCREEN_WIDTH, YY_COLLECTION_HEADERVIEW_HEIGHT);
        }else{
            _collectionLayout.headerReferenceSize = CGSizeMake(SCREEN_WIDTH, YY_COLLECTION_HEADERVIEW_VERIFY_HEIGHT);
        }
    }
    [self.collectionView.mj_footer endRefreshing];
    [self.collectionView reloadData];

    _tempHeadView.hidden = ![[YYUser currentUser] hasPermissionsToVisit];

    [self CreateOrUpdateCompleteInformationView];

    if([[YYUser currentUser] hasPermissionsToVisit]){
        _collectionView.backgroundColor =  [UIColor colorWithHex:@"F8F8F8"];
    }else{
        _collectionView.backgroundColor =  _define_white_color;
    }
    _collectionView.scrollEnabled = [[YYUser currentUser] hasPermissionsToVisit];
    if(self.collectionView.mj_header){
        self.collectionView.mj_header.hidden = ![[YYUser currentUser] hasPermissionsToVisit];
    }
    if(self.collectionView.mj_footer){
        self.collectionView.mj_footer.hidden = ![[YYUser currentUser] hasPermissionsToVisit];
    }
    if([[YYUser currentUser] hasPermissionsToVisit]){
        if (!self.styleListArray || [self.styleListArray count ]==0) {
            self.noDataView.hidden = NO;
        }else{
            self.noDataView.hidden = YES;
        }
    }else{
        self.noDataView.hidden = YES;
    }

}
-(void)startSearch{
    YYChooseStyleSearchViewController *searchView = [[YYChooseStyleSearchViewController alloc] init];
    searchView.reqModel = _reqModel;
    [self.navigationController pushViewController:searchView animated:NO];
}
-(void)listSetSelectWithType:(NSString *)type WithChooseStyleButtonStyle:(YYChooseStyleButtonStyle )chooseStyleButtonStyle{
    if(_connClass){
        if(chooseStyleButtonStyle == YYChooseStyleButtonStyleSort || chooseStyleButtonStyle == YYChooseStyleButtonStyleRecommendation){
            if(!_isAnimation){
                WeakSelf(ws);
                if(_chooseStyleListView){
                    //移除ListView
                    [_chooseStyleListView removeFromSuperview];
                    _chooseStyleListView = nil;
                }
                CGFloat _y_p = [self getListViewY];
                _chooseStyleListView = [[YYChooseStyleListView alloc] initWithFrame:CGRectMake(0, _y_p, SCREEN_WIDTH, SCREEN_HEIGHT-_y_p) WithChooseStyleListType:chooseStyleButtonStyle WithChooseStyleReqModel:_reqModel];
                [_chooseStyleListView setChooseStyleListBlock:^(NSString *type){
                    //                close/choose_done/disappear
                    //移除ListView
                    [ws.chooseStyleListView removeFromSuperview];
                    ws.chooseStyleListView = nil;
                    //更新headView
                    if(ws.tempHeadView){
                        ws.tempHeadView.reqModel = ws.reqModel;
                        [ws.tempHeadView setNormalState];
                    }
                    ws.canSetNormalState = YES;
                    [ws.collectionView reloadData];
                    
                    //重新加载数据
                    if([type isEqualToString:@"choose_done"]){
                        
                        [ws loadDataByPageIndex:1];
                        [ws.collectionView setContentOffset:CGPointMake(0,0) animated:YES];

                    }
                    
                }];
                [self.view addSubview:_chooseStyleListView];
            }
        }
    }
}
-(void)listSetNormalWithType:(NSString *)type WithChooseStyleButtonStyle:(YYChooseStyleButtonStyle )chooseStyleButtonStyle{
    if(_connClass){
        if(chooseStyleButtonStyle == YYChooseStyleButtonStyleSort || chooseStyleButtonStyle == YYChooseStyleButtonStyleRecommendation){
            if(_chooseStyleListView){
                [_chooseStyleListView closeAtion];
            }
        }else{
            WeakSelf(ws);
            if(!_isAnimation){
                //下拉收回 移除ListView
                if(_chooseStyleListView){
                    [_chooseStyleListView removeFromSuperview];
                    _chooseStyleListView = nil;
                }
                
                if(!_chooseStyleSlideView){
                    // 创建
                    _chooseStyleSlideView = [[YYChooseStyleSlideView alloc] initWithFrame:CGRectZero WithConClass:_connClass WithReqModel:_reqModel];
                    [self.view addSubview:_chooseStyleSlideView];
                    [_chooseStyleSlideView mas_makeConstraints:^(MASConstraintMaker *make) {
                        make.right.left.bottom.top.mas_equalTo(0);
                    }];
                    [_chooseStyleSlideView setChooseStyleSlideBlock:^(NSString *type){
                        //更新headView
                        [ws.chooseStyleListView removeFromSuperview];
                        ws.chooseStyleListView = nil;
                        //更新headView
                        if(ws.tempHeadView){
                            ws.tempHeadView.reqModel = ws.reqModel;
                            [ws.tempHeadView setNormalState];
                        }
                        ws.canSetNormalState = YES;
                        [ws.collectionView reloadData];
                        
                        if([type isEqualToString:@"disappear"]){
                            //只是让她消失就可以了
                            [ws.chooseStyleSlideView slideHideAnimation];
                        }else if([type isEqualToString:@"update"]){
                            [ws loadDataByPageIndex:1];
                            [ws.collectionView setContentOffset:CGPointMake(0,0) animated:YES];

                        }
                    }];
                }else{
                    //出现
                    [_chooseStyleSlideView slideShowAnimation];
                }
            }
        }
    }
}
-(CGFloat)getListViewY{
    
    if(_collectionView.contentOffset.y < YY_ANIMATE_BOUNDARY_OffSET){
        return YY_COLLECTION_HEADERVIEW_HEIGHT - _collectionView.contentOffset.y;
    }else{
        if(_tempHeadView){
            if(_tempHeadView.viewStyle == YYChooseStyleHeadViewAppear){
                return YY_COLLECTION_HEADERVIEW_HEIGHT;
            }else if(_tempHeadView.viewStyle == YYChooseStyleHeadViewDisappear){
                return YY_COLLECTION_HEADERVIEW_HEIGHT-YY_ANIMATE_BOUNDARY_OffSET;
            }
        }
    }
    return 0;
}

-(void)messageButtonClicked{
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    [appDelegate showMessageView:nil parentViewController:self];
}
-(void)shoppingCarButtonClicked{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Order" bundle:[NSBundle mainBundle]];
    YYCartDetailViewController *cartVC = [storyboard instantiateViewControllerWithIdentifier:@"YYCartDetailViewController"];
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:cartVC];
    nav.navigationBar.hidden = YES;
    
    WeakSelf(ws);
    [cartVC setGoBackButtonClicked:^(){
        [ws dismissViewControllerAnimated:YES completion:^{
            //刷新购物车图标数据
            [ws.collectionView reloadData];
        }];
    }];
    
    [cartVC setToOrderList:^(){
        [ws dismissViewControllerAnimated:NO completion:^{
            //如果购物车为空了，进入订单列表界面
            [[NSNotificationCenter defaultCenter] postNotificationName:kShowOrderListNotification object:nil];
            //}
        }];
    }];
    
    [self presentViewController:nav animated:YES completion:nil];
}
#pragma mark - 动画相关
//导航栏的动画显示与隐藏
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
//    NSLog(@"scrollViewWillBeginDragging = %lf",scrollView.contentOffset.y);
    [self updateStartOffset];
}
- (void)scrollViewDidScroll:(UIScrollView *)scrollView;
{
//    NSLog(@"scrollViewDidScroll = %lf",scrollView.contentOffset.y);
    
    CGFloat boundary_offset = _tempHeadView.viewStyle == YYChooseStyleHeadViewAppear ? 0 : YY_ANIMATE_BOUNDARY_OffSET;
    
    //更新start_offset
    CGFloat offset_y = scrollView.contentOffset.y;
    BOOL isOffsetIncrease_Temp = NO;
    CGFloat changeOffset = offset_y - _changing_offset;
    
    if(changeOffset > 0){
        isOffsetIncrease_Temp = YES;
    }else{
        isOffsetIncrease_Temp = NO;
    }
    
    if(_isOffsetIncrease != isOffsetIncrease_Temp){
        [self updateStartOffset];
    }
    
    if(_start_offset < boundary_offset && offset_y >= boundary_offset){
        [_tempHeadView setViewStyle:YYChooseStyleHeadViewDisappear];
        _tempHeadView.frame = _tempHeadViewDisappearRect;
        _isAnimation = NO;
        [self updateStartOffset];
    }
    
    _isOffsetIncrease = isOffsetIncrease_Temp;
    _changing_offset = offset_y;
    
    //动画
    if(_changing_offset < boundary_offset){
        [self setAnimationTotaldisappear];
    }else{
        CGFloat changeOffsetByStart = _start_offset - _changing_offset;
        if(changeOffsetByStart >= YY_ANIMATE_OffSET){
            [self setAnimationAppear];
        }else if(changeOffsetByStart <= -YY_ANIMATE_OffSET){
            [self setAnimationDisappear];
        }
    }
}
-(void)updateStartOffset{
    _start_offset = _collectionView.contentOffset.y;
}
-(void)setAnimationAppear{
    //不在动画中 并且y位置正确
    if(!_isAnimation && _tempHeadView && _tempHeadView.frame.origin.y == -45){
        _isAnimation = YES;
        [_tempHeadView setViewStyle:YYChooseStyleHeadViewAppear];
        [UIView animateWithDuration:YY_ANIMATE_DURATION animations:^{
            _tempHeadView.frame = _tempHeadViewAppearRect;
        } completion:^(BOOL finished) {
            _isAnimation = NO;
            [self updateStartOffset];
        }];
    }
}
-(void)setAnimationDisappear{
    //不在动画中 并且y位置正确
    if(!_isAnimation && _tempHeadView && _tempHeadView.frame.origin.y == 0){
        _isAnimation = YES;
        [UIView animateWithDuration:YY_ANIMATE_DURATION animations:^{
            _tempHeadView.frame = _tempHeadViewDisappearRect;
        } completion:^(BOOL finished) {
            [_tempHeadView setViewStyle:YYChooseStyleHeadViewDisappear];
            _isAnimation = NO;
            [self updateStartOffset];
        }];
    }
}
-(void)setAnimationTotaldisappear{
    if(_tempHeadView && !_tempHeadView.hidden){
        [_tempHeadView setViewStyle:YYChooseStyleHeadViewTotalDisappear];
        _tempHeadView.frame = _tempHeadViewTotalDisappearRect;
    }
}
#pragma mark - UICollectionViewDataSource
//返回section个数
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    if([[YYUser currentUser] hasPermissionsToVisit]){
        if(_styleListArray){
            if(_styleListArray.count){
                return [_styleListArray count];
            }
        }
    }
    return 0;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    YYChooseStyleModel *styleModel = nil;
    if ([_styleListArray count] > indexPath.row) {
        styleModel = [_styleListArray objectAtIndex:indexPath.row];
    }
    YYChooseStyleCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"YYChooseStyleCell" forIndexPath:indexPath];
    cell.styleModel = styleModel;
    [cell updateUI];
    return cell;
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath{
    if([kind isEqualToString:@"UICollectionElementKindSectionHeader"]){
        WeakSelf(ws);
        YYChooseStyleHeadView *headerView = [collectionView dequeueReusableSupplementaryViewOfKind:kind withReuseIdentifier:@"YYChooseStyleHeadView" forIndexPath:indexPath];
        headerView.reqModel = _reqModel;
        headerView.headStyle = YYChooseStyleHeadReuse;
        [headerView updateUI];
        [headerView setChooseStyleBlock:^(NSString *type,YYChooseStyleButtonStyle chooseStyleButtonStyle){
            [ws ChooseStyleBlockWithType:type WithChooseStyleButtonStyle:chooseStyleButtonStyle];
        }];
        if(_canSetNormalState){
            [headerView setNormalState];
            _canSetNormalState = NO;
        }
        return headerView;
    }
    UICollectionReusableView *headerView = [collectionView dequeueReusableSupplementaryViewOfKind:kind withReuseIdentifier:@"UICollectionReusableView" forIndexPath:indexPath];
    return headerView;
}
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    YYChooseStyleModel *chooseStyleModel = self.styleListArray[indexPath.row];
    //跳转对应页面
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    YYStyleOneColorModel *infoModel = [self modelTransformByChooseStyleModel:chooseStyleModel];
    [appDelegate showStyleInfoViewController:infoModel parentViewController:self];
}

-(YYStyleOneColorModel *)modelTransformByChooseStyleModel:(YYChooseStyleModel *)chooseStyleModel{
    YYStyleOneColorModel *infoModel = [[YYStyleOneColorModel alloc] init];
    infoModel.designerId = chooseStyleModel.designerId;
    infoModel.brandName = chooseStyleModel.brandName;
    infoModel.brandLogo = chooseStyleModel.brandLogo;
    infoModel.seriesName = chooseStyleModel.seriesName;
    infoModel.albumImg = chooseStyleModel.albumImg;
    infoModel.styleName = chooseStyleModel.styleName;
    infoModel.styleId = chooseStyleModel.styleId;
    return infoModel;
}

#pragma mark - Other

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
