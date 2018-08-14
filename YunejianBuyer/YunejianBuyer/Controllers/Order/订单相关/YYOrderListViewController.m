//
//  YYOrderListViewController.m
//  Yunejian
//
//  Created by Apple on 15/8/17.
//  Copyright (c) 2015年 yyj. All rights reserved.
//

#import "YYOrderListViewController.h"

// c文件 —> 系统文件（c文件在前）

// 控制器
#import "YYOrderDetailViewController.h"
#import "YYCustomCellTableViewController.h"
#import "YYOrderListTableViewController.h"

// 自定义视图
#import "MBProgressHUD.h"
#import "YYOrderNormalListCell.h"
#import "YYMessageButton.h"
#import "YYYellowPanelManage.h"
#import "YYMenuPopView.h"
#import "TitlePagerView.h"

// 接口
#import "YYOrderApi.h"

// 分类
#import "UIImage+Tint.h"

// 自定义类和三方类（ cocoapods类 > model > 工具类 > 其他）
#import <MJRefresh.h>

#import "YYUser.h"
#import "YYOrderListModel.h"
#import "YYOrderListItemModel.h"
#import "YYUntreatedMsgAmountModel.h"

#import "AppDelegate.h"

#define kOrderPageSize 5

@interface YYOrderListViewController ()<UITableViewDataSource,UITableViewDelegate,YYTableCellDelegate,UITextFieldDelegate,TitlePagerViewDelegate,ViewPagerDataSource, ViewPagerDelegate>

@property (weak, nonatomic) IBOutlet UIButton *backButton;

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UITextField *searchField;
@property (weak, nonatomic) IBOutlet UIView *searchView;
@property (nonatomic, assign) BOOL isSearchView;
@property (nonatomic, copy) NSString *searchFieldStr;

@property (weak, nonatomic) IBOutlet UIView *tabBarView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *searchViewTopLayoutConstraint;

@property (nonatomic, strong) UIScrollView *pagingTitleScrollView;
@property (nonatomic, strong) TitlePagerView *pagingTitleView;

@property (weak, nonatomic) IBOutlet YYMessageButton *messageButton;

@property (nonatomic, strong) YYPageInfoModel *currentPageInfo;
@property (nonatomic, strong) NSMutableArray *orderListArray;

@property (nonatomic, strong) NSMutableArray *localNoteArray;
@property (nonatomic, strong) NSMutableArray *searchNoteArray;//搜索历史记录
@property (weak, nonatomic) IBOutlet UIView *pageingView;

@property (nonatomic, assign) NSInteger currentOrderType;//订单类型，0，正常（默认值）；1，已取消
@property (nonatomic, assign) NSInteger currentPayType;//0 1
@property (nonatomic, strong) UIView *noDataView;

@property (nonatomic, strong) YYOrderListTableViewController *orderListTableVC_All;//全部订单
@property (nonatomic, strong) YYOrderListTableViewController *orderListTableVC_NEGOTIATION;//已下单
@property (nonatomic, strong) YYOrderListTableViewController *orderListTableVC_NEGOTIATION_DONE;//已确认
@property (nonatomic, strong) YYOrderListTableViewController *orderListTableVC_MANUFACTURE;//已生产
@property (nonatomic, strong) YYOrderListTableViewController *orderListTableVC_DELIVERING;//发货中
@property (nonatomic, strong) YYOrderListTableViewController *orderListTableVC_DELIVERY;//已发货
@property (nonatomic, strong) YYOrderListTableViewController *orderListTableVC_RECEIVED;//已收货

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *tableViewTopLayout;

@property (nonatomic, assign) BOOL detailViewBackFlag;//详情页返回

@property (weak, nonatomic) IBOutlet UIButton *tabBtn;

@property (nonatomic, strong) NSArray *tabBtnsData;

@property (nonatomic, strong) NSArray *titleArray;

@end

@implementation YYOrderListViewController
#pragma mark - --------------生命周期--------------
- (void)viewDidLoad {
    [super viewDidLoad];
    [self SomePrepare];
    [self UIConfig];
}
- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];

    if(self.detailViewBackFlag){
        self.detailViewBackFlag = NO;
    }else{
        [self reloadCurrentTableData:YES];
    }
    // 进入埋点
    [MobClick beginLogPageView:kYYPageOrderList];
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    if(self.pagingTitleView){
        if(self.pagingTitleView.isInAnimation){
            self.pagingTitleView.isInAnimation = NO;
        }
    }
    // 退出埋点
    [MobClick endLogPageView:kYYPageOrderList];
}

- (void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
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
    _searchFieldStr = @"";
    self.orderListArray = [[NSMutableArray alloc] initWithCapacity:0];
    _tabBtnsData = @[NSLocalizedString(@"所有订单",nil)
                     ,NSLocalizedString(@"已取消",nil)];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(messageCountChanged:) name:UnreadMsgAmountChangeNotification object:nil];
}
- (void)PrepareUI{

    self.searchField.delegate = self;

    self.dataSource = self;
    self.delegate = self;

    self.backButton.hidden = self.isMainView;
    self.tableView.hidden = YES;

    self.currentPayType = -1;
    self.manualLoadData = YES;

    if(IsPhone6_gt){
        self.searchField.font = [UIFont systemFontOfSize:14.0f];
    }else{
        self.searchField.font = [UIFont systemFontOfSize:12.0f];
    }

    [self setTabBtnState];
    [self reloadDataWithIndex:_currentIndex];
    [self viewControllerAtIndex:_currentIndex];

}

#pragma mark - --------------UIConfig----------------------
-(void)UIConfig{
    [self initMessageButton];
    [self createPagingTitleView];
    [self createNoDataView];
}
-(void)initMessageButton{
    [_messageButton initButton:@""];
    [self messageCountChanged:nil];
    [_messageButton addTarget:self action:@selector(messageButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
}
-(void)createPagingTitleView{

    _titleArray = @[NSLocalizedString(@"全部",nil),NSLocalizedString(@"已下单",nil),NSLocalizedString(@"已确认",nil),NSLocalizedString(@"已生产",nil),NSLocalizedString(@"发货中",nil),NSLocalizedString(@"已发货",nil),NSLocalizedString(@"已收货",nil)];
    if (!_pagingTitleView) {

        CGFloat titleFont = 0.0;
        if([LanguageManager isEnglishLanguage]){
            if(kIPhone6Plus){
                titleFont = 14.0f;
            }else if(IsPhone6_gt){
                titleFont = 13.0f;
            }else{
                titleFont = 11.0f;
            }
        }else{
            titleFont = 14.0f;
        }

        self.pagingTitleView = [[TitlePagerView alloc] init];
        [self.pageingView addSubview:self.pagingTitleView];
        self.pagingTitleView.backgroundColor = [UIColor clearColor];
        self.pagingTitleView.font = [UIFont systemFontOfSize:titleFont];
        self.pagingTitleView.dynamicTitlePagerViewTitleSpace = 26.0f;
        [self.pagingTitleView addObjects:_titleArray];
        self.pagingTitleView.delegate = self;
        self.pagingTitleView.isInAnimation = NO;

        //获取单个item的宽度
        CGFloat actualWidth = [self getActualItemWidth:_titleArray];

        //获取整个pageview的宽度
        CGFloat pagingTitleViewWidth =  actualWidth * [_titleArray count] + self.pagingTitleView.dynamicTitlePagerViewTitleSpace * ([_titleArray count] -1);

        _pagingTitleScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 4, SCREEN_WIDTH, 40)];
        [self.pageingView addSubview:_pagingTitleScrollView];
        _pagingTitleScrollView.showsVerticalScrollIndicator = NO;
        _pagingTitleScrollView.showsHorizontalScrollIndicator = NO;

        [_pagingTitleScrollView addSubview:self.pagingTitleView];
        self.pagingTitleView.frame = CGRectMake(17, 0, pagingTitleViewWidth, 40);

        _pagingTitleScrollView.contentSize = CGSizeMake(pagingTitleViewWidth + 17*2, 40);
    }

    [self updateSliderViewOffset:_currentIndex];

    [self.pagingTitleView adjustTitleViewByIndexNew:_currentIndex];
}
-(void)updateSliderViewOffset:(NSInteger)currentIndex{
    if(![NSArray isNilOrEmpty:_titleArray]){
        WeakSelf(ws);
        //获取单个item的宽度
        CGFloat actualWidth = [self getActualItemWidth:_titleArray];

        CGFloat mj_offsetX = self.pagingTitleScrollView.mj_offsetX;
        NSLog(@"mj_offsetX = %lf",self.pagingTitleScrollView.mj_offsetX);
        NSLog(@"SCREEN_WIDTH = %lf",SCREEN_WIDTH);

        CGFloat need_min_x = (currentIndex ? 17 : 0) + actualWidth * currentIndex + self.pagingTitleView.dynamicTitlePagerViewTitleSpace * (currentIndex > 1 ? (currentIndex - 1) : 0);
        CGFloat need_max_x = 17 + actualWidth * (currentIndex + 1) + self.pagingTitleView.dynamicTitlePagerViewTitleSpace * currentIndex;

        if(need_min_x < mj_offsetX){
            //往右动画
            [UIView animateWithDuration:0.5 animations:^{
                ws.pagingTitleScrollView.mj_offsetX = need_min_x;
            } completion:nil];
        }else if(need_max_x > SCREEN_WIDTH + mj_offsetX){
            //往左动画
            CGFloat contentOffset_x = currentIndex == 6 ? (need_max_x + 17.0f) : (need_max_x + 26.0f);
            CGFloat changeOffset_x = contentOffset_x - SCREEN_WIDTH;
            [UIView animateWithDuration:0.5 animations:^{
                ws.pagingTitleScrollView.mj_offsetX = changeOffset_x;
            } completion:nil];
        }
    }
}
-(void)createNoDataView{
    if(!_noDataView){
        self.noDataView = addNoDataView_phone(self.view, [NSString stringWithFormat:@"%@|icon:noorder_icon",NSLocalizedString(@"暂无相关订单哦~",nil)],nil,nil);
        _noDataView.hidden = YES;
    }
}
//全部
- (UIViewController *)createOrderListTableVC_All {
    WeakSelf(ws);
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"OrderDetail" bundle:[NSBundle mainBundle]];
    self.orderListTableVC_All = [storyboard instantiateViewControllerWithIdentifier:@"YYOrderListTableViewController"];
    self.orderListTableVC_All.curentOrderStatus = @"-1";
    self.orderListTableVC_All.currentOrderType = _currentOrderType;
    self.orderListTableVC_All.delegate = self;
    [self.orderListTableVC_All setViewDidAppearBlock:^{
        [ws updateSliderViewOffset:0];
    }];
    return self.orderListTableVC_All;
}
//已下单
- (UIViewController *)createOrderListTableVC_NEGOTIATION {
    WeakSelf(ws);
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"OrderDetail" bundle:[NSBundle mainBundle]];
    self.orderListTableVC_NEGOTIATION = [storyboard instantiateViewControllerWithIdentifier:@"YYOrderListTableViewController"];
    self.orderListTableVC_NEGOTIATION.curentOrderStatus = @"4";
    self.orderListTableVC_All.currentOrderType = _currentOrderType;
    self.orderListTableVC_NEGOTIATION.delegate = self;
    [self.orderListTableVC_NEGOTIATION setViewDidAppearBlock:^{
        [ws updateSliderViewOffset:1];
    }];
    return self.orderListTableVC_NEGOTIATION;
}
//已确定
- (UIViewController *)createOrderListTableVC_NEGOTIATION_DONE {
    WeakSelf(ws);
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"OrderDetail" bundle:[NSBundle mainBundle]];
    self.orderListTableVC_NEGOTIATION_DONE = [storyboard instantiateViewControllerWithIdentifier:@"YYOrderListTableViewController"];
    self.orderListTableVC_NEGOTIATION_DONE.curentOrderStatus = @"5,6";
    self.orderListTableVC_All.currentOrderType = _currentOrderType;
    self.orderListTableVC_NEGOTIATION_DONE.delegate = self;
    [self.orderListTableVC_NEGOTIATION_DONE setViewDidAppearBlock:^{
        [ws updateSliderViewOffset:2];
    }];
    return self.orderListTableVC_NEGOTIATION_DONE;
}
//已生产
- (UIViewController *)createOrderListTableVC_MANUFACTURE {
    WeakSelf(ws);
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"OrderDetail" bundle:[NSBundle mainBundle]];
    self.orderListTableVC_MANUFACTURE = [storyboard instantiateViewControllerWithIdentifier:@"YYOrderListTableViewController"];
    self.orderListTableVC_MANUFACTURE.curentOrderStatus = @"7";
    self.orderListTableVC_All.currentOrderType = _currentOrderType;
    self.orderListTableVC_MANUFACTURE.delegate = self;
    [self.orderListTableVC_MANUFACTURE setViewDidAppearBlock:^{
        [ws updateSliderViewOffset:3];
    }];
    return self.orderListTableVC_MANUFACTURE;
}
//发货中
-(UIViewController *)createOrderListTableVC_DELIVERING{
    WeakSelf(ws);
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"OrderDetail" bundle:[NSBundle mainBundle]];
    self.orderListTableVC_DELIVERING = [storyboard instantiateViewControllerWithIdentifier:@"YYOrderListTableViewController"];
    self.orderListTableVC_DELIVERING.curentOrderStatus = @"15";
    self.orderListTableVC_All.currentOrderType = _currentOrderType;
    self.orderListTableVC_DELIVERING.delegate = self;
    [self.orderListTableVC_DELIVERING setViewDidAppearBlock:^{
        [ws updateSliderViewOffset:4];
    }];
    return self.orderListTableVC_DELIVERING;
}
//已发货
- (UIViewController *)createOrderListTableVC_DELIVERY {
    WeakSelf(ws);
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"OrderDetail" bundle:[NSBundle mainBundle]];
    self.orderListTableVC_DELIVERY = [storyboard instantiateViewControllerWithIdentifier:@"YYOrderListTableViewController"];
    self.orderListTableVC_DELIVERY.curentOrderStatus = @"8";
    self.orderListTableVC_All.currentOrderType = _currentOrderType;
    self.orderListTableVC_DELIVERY.delegate = self;
    [self.orderListTableVC_DELIVERY setViewDidAppearBlock:^{
        [ws updateSliderViewOffset:5];
    }];
    return self.orderListTableVC_DELIVERY;
}
//已收货
- (UIViewController *)createOrderListTableVC_RECEIVED {
    WeakSelf(ws);
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"OrderDetail" bundle:[NSBundle mainBundle]];
    self.orderListTableVC_RECEIVED = [storyboard instantiateViewControllerWithIdentifier:@"YYOrderListTableViewController"];
    self.orderListTableVC_RECEIVED.curentOrderStatus = @"9";
    self.orderListTableVC_All.currentOrderType = _currentOrderType;
    self.orderListTableVC_RECEIVED.delegate = self;
    [self.orderListTableVC_RECEIVED setViewDidAppearBlock:^{
        [ws updateSliderViewOffset:6];
    }];
    return self.orderListTableVC_RECEIVED;
}
#pragma mark - --------------请求数据----------------------
- (void)loadOrderListFromServerByPageIndex:(int)pageIndex endRefreshing:(BOOL)endrefreshing{
    WeakSelf(ws);

    __block BOOL blockEndrefreshing = endrefreshing;
    NSString *trueCurrentOrderType = _currentOrderType == 1 ? @"10,11":@"-1";
    [YYOrderApi getOrderInfoListWithPayType:_currentPayType
                                  orderStatus:trueCurrentOrderType
                                     queryStr:_searchFieldStr
                                    pageIndex:pageIndex
                                     pageSize:kOrderPageSize
                                     andBlock:^(YYRspStatusAndMessage *rspStatusAndMessage, YYOrderListModel *orderListModel, NSError *error){
                                         if (rspStatusAndMessage.status == YYReqStatusCode100) {
                                             if (pageIndex == 1) {
                                                 [ws.orderListArray removeAllObjects];
                                             }
                                             ws.currentPageInfo = orderListModel.pageInfo;

                                             if (orderListModel && orderListModel.result
                                                 && [orderListModel.result count] > 0){
                                                 [ws.orderListArray addObjectsFromArray:orderListModel.result];
                                             }
                                         }

                                         [ws addSearchNote];

                                         if(blockEndrefreshing){
                                             [self.tableView.mj_header endRefreshing];
                                             [self.tableView.mj_footer endRefreshing];
                                         }

                                         [ws reloadTableData];

                                         [MBProgressHUD hideAllHUDsForView:ws.view animated:YES];
                                     }];
}


-(void)loadOrderListItem:(NSIndexPath *)index{
    if(self.tableView.hidden){
        YYOrderListTableViewController *tableViewController = (YYOrderListTableViewController *)[self viewControllerAtIndex:_currentIndex];
        if(tableViewController != nil){
            [tableViewController reloadListItem:index.row];
        }
    }else{
        NSInteger row=index.row;
        __block YYOrderListItemModel *blockorderListItemModel = [_orderListArray objectAtIndex:row];
        [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        WeakSelf(ws);
        [YYOrderApi getOrderInfoListItemWithOrderCode:blockorderListItemModel.orderCode andBlock:^(YYRspStatusAndMessage *rspStatusAndMessage, YYOrderListItemModel *orderListItemModel, NSError *error) {
            [MBProgressHUD hideAllHUDsForView:ws.view animated:YES];
            if(rspStatusAndMessage.status == YYReqStatusCode100 && [blockorderListItemModel.orderCode isEqualToString:orderListItemModel.orderCode]){
                [ws.orderListArray replaceObjectAtIndex:row withObject:orderListItemModel];
                [ws reloadTableData];
            }
        }];
    }
}

#pragma mark - --------------Setter----------------------
- (void)setCurrentIndex:(NSInteger)index {
    if(self.currentOrderType == 0){
        if(self.pagingTitleView){
            [self.pagingTitleView adjustTitleViewByIndexNew:index];
        }
        _currentIndex = index;
    }
}
-(void)setIsMainView:(BOOL)isMainView{
    _isMainView = isMainView;
    _backButton.hidden = _isMainView;
}
-(void)setTabBtnState{
    NSString *btnTxt = [_tabBtnsData objectAtIndex:_currentOrderType];
    [self.tabBtn setTitle:btnTxt forState:UIControlStateNormal];
    [self.tabBtn setImage:[UIImage imageNamed:@"down"] forState:UIControlStateNormal];
    CGSize seriesNameTextSize =[btnTxt sizeWithAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:18.0f]}];
    CGSize imageSize = [UIImage imageNamed:@"down"].size;
    float labelWidth = seriesNameTextSize.width;
    float imageWith = imageSize.width;
    self.tabBtn.imageEdgeInsets = UIEdgeInsetsMake(0, labelWidth, 0, -labelWidth);
    self.tabBtn.titleEdgeInsets = UIEdgeInsetsMake(0, -imageWith-5, 0, imageWith+5);

    if(_currentOrderType != 0){
        _pageingView.hidden = YES;
        _tableViewTopLayout.constant = 45;
    }else{
        _pageingView.hidden = NO;
        _tableViewTopLayout.constant = 89;
    }
}

#pragma mark - --------------系统代理----------------------
#pragma mark -UITableViewDelegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if(self.isSearchView){
        return [_searchNoteArray count];
    }else{
        return [_orderListArray count];
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = nil;
    if(self.isSearchView){
        static NSString *CellIdentifier = @"YYOrderListSearchNoteCell";
        UITableViewCell *noteCell = [self.tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if(noteCell == nil){
            noteCell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        }
        UIImageView *flagImg = [noteCell.contentView viewWithTag:10002];
        UIImage *img = [[UIImage imageNamed:@"searchflag_img"] imageWithTintColor:[UIColor colorWithHex:@"919191"] ];
        flagImg.image = img;
        NSArray *obj = [_searchNoteArray objectAtIndex:indexPath.row];
        UILabel *titleLabel = [noteCell.contentView viewWithTag:10001];
        titleLabel.text = [obj objectAtIndex:0];
        if(indexPath.row % 2 == 0){
            noteCell.contentView.backgroundColor = [UIColor whiteColor];
        }else{
            noteCell.contentView.backgroundColor = [UIColor colorWithHex:@"f8f8f8"];
        }
        UIButton *deleteBtn = [noteCell.contentView viewWithTag:10003];
        deleteBtn.alpha = 1000+indexPath.row;
        [deleteBtn addTarget:self action:@selector(deleteSearchNote:) forControlEvents:UIControlEventTouchUpInside];
        cell = noteCell;
    }else{
        static NSString *CellIdentifier = @"YYOrderNormalListCell";
        YYOrderNormalListCell *tempCell =  [_tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if(!tempCell){
            UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"OrderDetail" bundle:[NSBundle mainBundle]];
            YYCustomCellTableViewController *customCellTableViewController = [storyboard instantiateViewControllerWithIdentifier:@"YYCustomCellTableViewController"];
            tempCell = [customCellTableViewController.tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        }

        YYOrderListItemModel *orderListItemModel = [_orderListArray objectAtIndex:indexPath.row];
        tempCell.currentOrderListItemModel = orderListItemModel;

        [tempCell updateUI];
        tempCell.delegate = self;
        tempCell.indexPath = indexPath;

        cell = tempCell;
    }
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if(self.isSearchView){
        return 50;
    }else{
        YYOrderListItemModel *orderListItemModel = [_orderListArray objectAtIndex:indexPath.row];
        if([_orderListArray count] == (indexPath.row+1)){
            return 211;
        }
        return [YYOrderNormalListCell cellHeight:orderListItemModel];
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if(self.isSearchView){
        NSArray *obj = [_searchNoteArray objectAtIndex:indexPath.row];
        self.searchFieldStr =  [obj objectAtIndex:0];
        self.searchField.text = self.searchFieldStr;
        _isSearchView = NO;
        [self loadOrderListFromServerByPageIndex:1 endRefreshing:NO];
    }else{
        YYOrderListItemModel *orderListItemModel = [_orderListArray objectAtIndex:indexPath.row];
        [self showOrderDetailViewWithListItemModel:orderListItemModel indexPath:indexPath];
    }
}

#pragma mark -ViewPagerDataSource
- (NSUInteger)numberOfTabsForViewPager:(ViewPagerController *)viewPager {
    return 7;
}

- (UIViewController *)viewPager:(ViewPagerController *)viewPager contentViewControllerForTabAtIndex:(NSUInteger)index {
    if (index == 0) {
        return [self createOrderListTableVC_All];
    } else if (index == 1) {
        return [self createOrderListTableVC_NEGOTIATION];
    } else if (index == 2) {
        return [self createOrderListTableVC_NEGOTIATION_DONE];
    } else if (index == 3) {
        return [self createOrderListTableVC_MANUFACTURE];
    }else if  (index == 4) {
        return [self createOrderListTableVC_DELIVERING];
    } else if (index == 5) {
        return [self createOrderListTableVC_DELIVERY];
    } else if (index == 6) {
        return [self createOrderListTableVC_RECEIVED];
    }
    return 0;
}
#pragma mark -UIScrollViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    //只有所有的时候允许她左右滑
    if(self.tableView.hidden == NO){
        return;
    }
    CGFloat contentOffsetX = scrollView.contentOffset.x;

    if (self.currentIndex != 0 && contentOffsetX <= SCREEN_WIDTH * 3) {
        contentOffsetX += SCREEN_WIDTH * self.currentIndex;
    }

    [self.pagingTitleView updatePageIndicatorPosition:contentOffsetX];
}
#pragma mark -UITextFieldDelegate
- (void)textFieldDidEndEditing:(UITextField *)textField{
    [[NSNotificationCenter defaultCenter]removeObserver:self name:UITextFieldTextDidChangeNotification object:_searchField];
}

-(void) textFieldDidBeginEditing:(UITextField *)textField{
    _isSearchView = YES;
    [self reloadTableData];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(textFieldDidChange:) name:UITextFieldTextDidChangeNotification object:_searchField];
}

- (void)textFieldDidChange:(NSNotification *)note{
    NSString *toBeString = _searchField.text;
    NSString *lang = [[UIApplication sharedApplication] textInputMode].primaryLanguage; // 键盘输入模式
    NSString *str = @"";
    if ([lang isEqualToString:@"zh-Hans"]) { // 简体中文输入，包括简体拼音，健体五笔，简体手写
        UITextRange *selectedRange = [_searchField markedTextRange];
        //高亮部分
        UITextPosition *position = [_searchField positionFromPosition:selectedRange.start offset:0];
        //已输入的文字进行字数统计和限制
        if (!position) {
            str = toBeString;
        }else{
            return ;
        }
    }
    else{
        str = toBeString;
    }
    if(![str isEqualToString:@""]){
        _searchFieldStr = str;
        _isSearchView = YES;

        _localNoteArray = [NSKeyedUnarchiver unarchiveObjectWithFile:getOrderSearchNoteStorePath()];
        _searchNoteArray = [[NSMutableArray alloc] init];
        for (NSArray *note in _localNoteArray) {
            if([note[0] containsString:str]){
                [_searchNoteArray addObject:note];
            }
        }
        [self reloadTableData];
    }else{
        _searchFieldStr = @"";
    }
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    if(![_searchFieldStr isEqualToString:@""]){
        _isSearchView = NO;
        [_searchField resignFirstResponder];
        [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        [self loadOrderListFromServerByPageIndex:1 endRefreshing:NO];
        return YES;
    }
    return NO;
}
#pragma mark - --------------自定义代理/block----------------------
#pragma mark -YYTableCellDelegate
-(void)btnClick:(NSInteger)row section:(NSInteger)section andParmas:(NSArray *)parmas{
    NSString *type = [parmas objectAtIndex:0];
    NSObject *obj = nil;
    if(self.tableView.hidden){
        obj = [parmas objectAtIndex:1];
    }else{
        obj =[_orderListArray objectAtIndex:row];
    }
    if ([obj isKindOfClass:[YYOrderListItemModel class]]) {
        YYOrderListItemModel *orderListItemModel = (YYOrderListItemModel *)obj;

        if([type isEqualToString:@"paylog"]){

            //添加收款记录
            [self addPaylogRecordWithListItemModel:orderListItemModel];

        }else if([type isEqualToString:@"status"]){

            //已发货
            NSIndexPath *indexPath =  [NSIndexPath indexPathForRow:row inSection:section];
            [self updateTransStatusWithListItemModel:orderListItemModel indexPath:indexPath];

        }else if([type isEqualToString:@"delete"]){

            //删除订单
            [self deleteOrderWithListItemModel:orderListItemModel];

        }else if([type isEqualToString:@"reBuildOrder"]){

            //重新建立订单  跳转之前要加个验证
             NSIndexPath *indexPath =  [NSIndexPath indexPathForRow:row inSection:section];
            [self reBuildOrderWithListItemModel:orderListItemModel indexPath:indexPath];

        }else if([type isEqualToString:@"cancelReqClose"]){

            //撤销申请
            NSIndexPath *indexPath =  [NSIndexPath indexPathForRow:row inSection:section];
            [self cancelReqCloseWithListItemModel:orderListItemModel indexPath:indexPath];

        }else if([type isEqualToString:@"refuseReqClose"]){

            //我方交易继续
            NSIndexPath *indexPath =  [NSIndexPath indexPathForRow:row inSection:section];
            [self refuseReqCloseWithListItemModel:orderListItemModel indexPath:indexPath];

        }else if([type isEqualToString:@"agreeReqClose"]){

            //同意关闭交易
            NSIndexPath *indexPath =  [NSIndexPath indexPathForRow:row inSection:section];
            [self agreeReqCloseWithListItemModel:orderListItemModel indexPath:indexPath];

        }else if ([type isEqualToString:@"modifyOrder"]){

            //修改订单
            NSIndexPath *indexPath =  [NSIndexPath indexPathForRow:row inSection:section];
            [self modifyOrderWithListItemModel:orderListItemModel indexPath:indexPath];

        }else if ([type isEqualToString:@"confirmOrder"]){

            //确认订单
            NSIndexPath *indexPath =  [NSIndexPath indexPathForRow:row inSection:section];
            [self confirmOrderWithListItemModel:orderListItemModel indexPath:indexPath];

        }else if ([type isEqualToString:@"refuseOrder"]){

            //拒绝确认
            NSIndexPath *indexPath =  [NSIndexPath indexPathForRow:row inSection:section];
            [self refuseOrderWithListItemModel:orderListItemModel indexPath:indexPath];

        }else if ([type isEqualToString:@"cancelOrder"]){

            //取消订单
            NSIndexPath *indexPath =  [NSIndexPath indexPathForRow:row inSection:section];
            [self cancelOrderWithListItemModel:orderListItemModel indexPath:indexPath];

        }else if ([type isEqualToString:@"closeOrder"]){
            
            //取消订单
            NSIndexPath *indexPath =  [NSIndexPath indexPathForRow:row inSection:section];
            [self closeOrderWithListItemModel:orderListItemModel indexPath:indexPath];

        }else if([type isEqualToString:@"orderDetail"]){

            //进入订单详情
            NSIndexPath *indexPath =  [NSIndexPath indexPathForRow:row inSection:section];
            [self showOrderDetailViewWithListItemModel:orderListItemModel indexPath:indexPath];

        }else if([type isEqualToString:@"brandInfo"]){

            //进入设计师详情页
            [self showBrandInfoViewWithListItemModel:orderListItemModel];

        }
    }
}
#pragma mark -YYTableCellDelegate-Method
//添加收款记录

-(void)addPaylogRecordWithListItemModel:(YYOrderListItemModel *)orderListItemModel{

    WeakSelf(ws);
    if([orderListItemModel.payNote floatValue] != 100.f){

        BOOL isNeedRefund = NO;
        if([orderListItemModel.payNote floatValue] > 100.f){
            isNeedRefund = YES;
        }

        self.detailViewBackFlag = YES;

        NSString *brandLogo = [NSString isNilOrEmpty:orderListItemModel.brandLogo] ? @"" : orderListItemModel.brandLogo;
        NSInteger designerId = orderListItemModel.designerId ? [orderListItemModel.designerId integerValue] : 0;

        [[YYYellowPanelManage instance] showOrderAddMoneyLogPanel:@"Order" andIdentifier:@"YYOrderAddMoneyLogController" orderCode:orderListItemModel.orderCode params:@[brandLogo,@(designerId)] totalMoney:[orderListItemModel.finalTotalPrice doubleValue] moneyType:[orderListItemModel.curType integerValue] isNeedRefund:isNeedRefund parentView:self andCallBack:^(NSString *orderCode, NSNumber *totalPercent) {

            orderListItemModel.payNote = totalPercent;
            if(ws.tableView.hidden){
                [ws reloadCurrentTableData:NO];
            }else{
                [ws.tableView reloadData];
            }

        }];
    }
}
//updateTrans 已发货
-(void)updateTransStatusWithListItemModel:(YYOrderListItemModel *)orderListItemModel indexPath:(NSIndexPath *)indexPath{

    WeakSelf(ws);

    self.detailViewBackFlag = YES;

    NSInteger tranStatus = getOrderTransStatus(orderListItemModel.designerTransStatus, orderListItemModel.buyerTransStatus);
    NSInteger nextTransStatus = getOrderNextStatus(tranStatus,[orderListItemModel.connectStatus integerValue]);
    NSString *oprateStr = getOrderStatusBtnName_buyer(nextTransStatus);

    CMAlertView *alertView = [[CMAlertView alloc] initWithTitle:[NSString stringWithFormat:NSLocalizedString(@"%@吗？",nil),oprateStr] message:nil needwarn:NO delegate:nil cancelButtonTitle:NSLocalizedString(@"取消",nil) otherButtonTitles:@[[NSString stringWithFormat:@"%@|000000",oprateStr]]];
    [alertView setAlertViewBlock:^(NSInteger selectedIndex){
        if (selectedIndex == 1) {
            [YYOrderApi updateTransStatus:orderListItemModel.orderCode statusCode:nextTransStatus andBlock:^(YYRspStatusAndMessage *rspStatusAndMessage, NSError *error) {
                if(rspStatusAndMessage.status == YYReqStatusCode100){
                    [ws loadOrderListItem:indexPath];
                }
            }];
        }
    }];
    [alertView show];

}
//删除订单
-(void)deleteOrderWithListItemModel:(YYOrderListItemModel *)orderListItemModel{

    WeakSelf(ws);

    CMAlertView *alertView = [[CMAlertView alloc] initWithTitle:NSLocalizedString(@"确定要删除订单吗？",nil) message:nil needwarn:NO delegate:nil cancelButtonTitle:NSLocalizedString(@"取消",nil) otherButtonTitles:@[NSLocalizedString(@"删除订单",nil)]];
    [alertView setAlertViewBlock:^(NSInteger selectedIndex){
        if (selectedIndex == 1) {
            [YYOrderApi updateOrderWithOrderCode:orderListItemModel.orderCode opType:3 andBlock:^(YYRspStatusAndMessage *rspStatusAndMessage, NSError *error) {
                if (rspStatusAndMessage.status == YYReqStatusCode100) {
                    [YYToast showToastWithTitle:NSLocalizedString(@"删除订单成功",nil)  andDuration:kAlertToastDuration];
                    if(ws.tableView.hidden){
                        [ws reloadCurrentTableData:YES];
                    }else{
                        [ws loadOrderListFromServerByPageIndex:1 endRefreshing:NO];
                    }
                }
            }];
        }
    }];
    [alertView show];

}
//重新建立订单
-(void)reBuildOrderWithListItemModel:(YYOrderListItemModel *)orderListItemModel indexPath:(NSIndexPath *)indexPath{
    [YYOrderApi getOrderByOrderCode:orderListItemModel.orderCode isForReBuildOrder:YES andBlock:^(YYRspStatusAndMessage *rspStatusAndMessage, YYOrderInfoModel *orderInfoModel, NSError *error) {
        AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
        if (rspStatusAndMessage.status == YYReqStatusCode100) {
            orderInfoModel.orderCode = nil;
            orderInfoModel.realBuyerId = 0;
            orderInfoModel.buyerEmail = @"";
            orderInfoModel.buyerName = @"";
            orderInfoModel.payApp = @"";
            orderInfoModel.deliveryChoose = @"";
            orderInfoModel.businessCard = @"";
            orderInfoModel.designerOrderStatus = [[NSNumber alloc] initWithInt:YYOrderCode_NEGOTIATION];
            orderInfoModel.buyerOrderStatus = [[NSNumber alloc] initWithInt:YYOrderCode_NEGOTIATION];
            orderInfoModel.orderConnStatus = @(YYOrderConnStatusUnconfirmed);
            orderInfoModel.orderCreateTime = nil;
            [appDelegate showBuildOrderViewController:orderInfoModel parent:self isCreatOrder:YES isReBuildOrder:YES isAppendOrder:NO modifySuccess:^(){
                [[NSNotificationCenter defaultCenter] postNotificationName:kShowOrderListNotification object:nil];
            }];
        }else{
            [YYToast showToastWithView:appDelegate.mainViewController.view title:rspStatusAndMessage.message andDuration:kAlertToastDuration];
        }
    }];
}
//撤销申请
-(void)cancelReqCloseWithListItemModel:(YYOrderListItemModel *)orderListItemModel indexPath:(NSIndexPath *)indexPath{
    WeakSelf(ws);
    self.detailViewBackFlag = YES;
    CMAlertView *alertView = [[CMAlertView alloc] initWithTitle:NSLocalizedString(@"是否确认撤销“取消订单”申请？",nil) message:nil needwarn:NO delegate:nil cancelButtonTitle:NSLocalizedString(@"否",nil) otherButtonTitles:@[NSLocalizedString(@"是",nil)]];
    [alertView setAlertViewBlock:^(NSInteger selectedIndex){
        if (selectedIndex == 1) {
            [YYOrderApi revokeOrderCloseRequest:orderListItemModel.orderCode andBlock:^(YYRspStatusAndMessage *rspStatusAndMessage, NSError *error) {
                if(rspStatusAndMessage.status == YYReqStatusCode100){
                    [ws loadOrderListItem:indexPath];
                }
                [YYToast showToastWithTitle:rspStatusAndMessage.message andDuration:kAlertToastDuration];
            }];
        }
    }];
    [alertView show];
}
//我方交易继续
-(void)refuseReqCloseWithListItemModel:(YYOrderListItemModel *)orderListItemModel indexPath:(NSIndexPath *)indexPath{
    WeakSelf(ws);
    self.detailViewBackFlag = YES;
    CMAlertView *alertView = [[CMAlertView alloc] initWithTitle:NSLocalizedString(@"确认拒绝已取消申请",nil) message:nil needwarn:NO delegate:nil cancelButtonTitle:NSLocalizedString(@"取消",nil) otherButtonTitles:@[NSLocalizedString(@"确认",nil)]];
    [alertView setAlertViewBlock:^(NSInteger selectedIndex){
        if (selectedIndex == 1) {
            [YYOrderApi dealOrderCloseRequest:orderListItemModel.orderCode isAgree:@"false" andBlock:^(YYRspStatusAndMessage *rspStatusAndMessage, NSError *error) {
                if(rspStatusAndMessage.status == YYReqStatusCode100){
                    [ws loadOrderListItem:indexPath];
                }
                [YYToast showToastWithTitle:rspStatusAndMessage.message andDuration:kAlertToastDuration];
            }];
        }
    }];
    [alertView show];
}
//同意关闭交易
-(void)agreeReqCloseWithListItemModel:(YYOrderListItemModel *)orderListItemModel indexPath:(NSIndexPath *)indexPath{

    WeakSelf(ws);

    self.detailViewBackFlag = YES;
    CMAlertView *alertView = [[CMAlertView alloc] initWithTitle:NSLocalizedString(@"确认同意已取消申请",nil) message:nil needwarn:NO delegate:nil cancelButtonTitle:NSLocalizedString(@"取消",nil) otherButtonTitles:@[NSLocalizedString(@"确认",nil)]];
    [alertView setAlertViewBlock:^(NSInteger selectedIndex){
        if (selectedIndex == 1) {
            [YYOrderApi dealOrderCloseRequest:orderListItemModel.orderCode isAgree:@"true" andBlock:^(YYRspStatusAndMessage *rspStatusAndMessage, NSError *error) {
                if(rspStatusAndMessage.status == YYReqStatusCode100){
                    [ws loadOrderListItem:indexPath];
                }
                [YYToast showToastWithTitle:rspStatusAndMessage.message andDuration:kAlertToastDuration];
            }];
        }
    }];
    [alertView show];

}
//修改订单
-(void)modifyOrderWithListItemModel:(YYOrderListItemModel *)orderListItemModel indexPath:(NSIndexPath *)indexPath{

    WeakSelf(ws);

    self.detailViewBackFlag = YES;

    [YYOrderApi getOrderByOrderCode:orderListItemModel.orderCode isForReBuildOrder:NO andBlock:^(YYRspStatusAndMessage *rspStatusAndMessage, YYOrderInfoModel *orderInfoModel, NSError *error) {
        AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
        if (rspStatusAndMessage.status == YYReqStatusCode100) {

            [appDelegate showBuildOrderViewController:orderInfoModel parent:self isCreatOrder:NO isReBuildOrder:NO isAppendOrder:NO modifySuccess:^(){
                [ws loadOrderListItem:indexPath];
            }];
        }else{
            [YYToast showToastWithView:appDelegate.mainViewController.view title:rspStatusAndMessage.message andDuration:kAlertToastDuration];
        }
    }];

}
//确认订单
-(void)confirmOrderWithListItemModel:(YYOrderListItemModel *)orderListItemModel indexPath:(NSIndexPath *)indexPath{
    NSLog(@"confirmOrder");
    WeakSelf(ws);
    CMAlertView *alertView = [[CMAlertView alloc] initWithTitle:NSLocalizedString(@"确认此订单？", nil) message:NSLocalizedString(@"确认后将无法修改订单，是否确认该订单？",nil) needwarn:NO delegate:nil cancelButtonTitle:NSLocalizedString(@"取消",nil) otherButtonTitles:@[NSLocalizedString(@"确认",nil)]];
    [alertView setAlertViewBlock:^(NSInteger selectedIndex){
        if (selectedIndex == 1) {
            [YYOrderApi confirmOrderByOrderCode:orderListItemModel.orderCode andBlock:^(YYRspStatusAndMessage *rspStatusAndMessage, NSError *error) {
                if(rspStatusAndMessage.status == YYReqStatusCode100){
                    [ws loadOrderListItem:indexPath];
                    [YYToast showToastWithTitle:NSLocalizedString(@"订单已确认", nil) andDuration:kAlertToastDuration];
                }
            }];
        }
    }];
    [alertView show];
}
//拒绝确认订单
-(void)refuseOrderWithListItemModel:(YYOrderListItemModel *)orderListItemModel indexPath:(NSIndexPath *)indexPath{
    NSLog(@"refuseOrder");
    WeakSelf(ws);
    CMAlertView *alertView = [[CMAlertView alloc] initRefuseOrderReasonWithTitle:NSLocalizedString(@"请填写拒绝原因", nil) message:nil otherButtonTitles:@[NSLocalizedString(@"提交",nil)]];
    [alertView setAlertViewSubmitBlock:^(NSString *reson) {
        NSLog(@"准备提交");
        [YYOrderApi refuseOrderByOrderCode:orderListItemModel.orderCode reason:reson andBlock:^(YYRspStatusAndMessage *rspStatusAndMessage, NSError *error) {
            if(rspStatusAndMessage.status == YYReqStatusCode100){
                [ws loadOrderListItem:indexPath];
                [YYToast showToastWithTitle:NSLocalizedString(@"已提交", nil) andDuration:kAlertToastDuration];
            }
        }];
    }];
    [alertView show];
}
//取消订单
-(void)cancelOrderWithListItemModel:(YYOrderListItemModel *)orderListItemModel indexPath:(NSIndexPath *)indexPath{
    WeakSelf(ws);
    CMAlertView *alertView =nil;
    if([orderListItemModel.isAppend integerValue] == 1){
        alertView = [[CMAlertView alloc] initWithTitle:NSLocalizedString(@"取消此订单？",nil) message:NSLocalizedString(@"这是一个追单订单，操作取消订单后，该追单与原始订单解除绑定。",nil) needwarn:NO delegate:nil cancelButtonTitle:NSLocalizedString(@"保留订单",nil) otherButtonTitles:@[NSLocalizedString(@"取消订单_short",nil)]];

    }else{
        alertView = [[CMAlertView alloc] initWithTitle:NSLocalizedString(@"取消此订单？",nil) message:NSLocalizedString(@"订单取消后，可在“已取消”的订单中找到该订单",nil) needwarn:NO delegate:nil cancelButtonTitle:NSLocalizedString(@"保留订单",nil) otherButtonTitles:@[NSLocalizedString(@"取消订单_short",nil)]];
    }
    [alertView setAlertViewBlock:^(NSInteger selectedIndex){
        if (selectedIndex == 1) {

            [YYOrderApi updateOrderWithOrderCode:orderListItemModel.orderCode opType:1 andBlock:^(YYRspStatusAndMessage *rspStatusAndMessage, NSError *error) {
                if (rspStatusAndMessage.status == YYReqStatusCode100) {
                    [ws loadOrderListItem:indexPath];
                    [YYToast showToastWithView:ws.view title:NSLocalizedString(@"取消订单成功",nil)  andDuration:kAlertToastDuration];
                }
            }];
        }
    }];

    [alertView show];
}
//进入设计师详情页
-(void)showBrandInfoViewWithListItemModel:(YYOrderListItemModel*)orderListItemModel{

    if(orderListItemModel && orderListItemModel.brandName && orderListItemModel.brandLogo){
        AppDelegate *appdelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
        NSString *brandName = orderListItemModel.brandName;
        NSString *logoPath = orderListItemModel.brandLogo;
        self.detailViewBackFlag = YES;
        [appdelegate showBrandInfoViewController:orderListItemModel.designerId WithBrandName:brandName WithLogoPath:logoPath parentViewController:self WithHomePageBlock:nil WithSelectedValue:nil];
    }

}
//进入订单详情
-(void)showOrderDetailViewWithListItemModel:(YYOrderListItemModel *)orderListItemModel indexPath:(NSIndexPath *)indexPath{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"OrderDetail" bundle:[NSBundle mainBundle]];
    YYOrderDetailViewController *orderDetailViewController = [storyboard instantiateViewControllerWithIdentifier:@"YYOrderDetailViewController"];
    NSString *orderCode = orderListItemModel.orderCode;
    orderDetailViewController.currentOrderCode = orderCode;
    orderDetailViewController.currentOrderLogo = orderListItemModel.brandLogo;
    orderDetailViewController.currentOrderConnStatus = [orderListItemModel.connectStatus integerValue];
    WeakSelf(ws);
    __block NSIndexPath *blockindexPath = indexPath;
    [orderDetailViewController setCancelButtonClicked:^(){
        ws.detailViewBackFlag = YES;
        [ws loadOrderListItem:blockindexPath];
    }];
    [self.navigationController pushViewController:orderDetailViewController animated:YES];
}
//取消订单
-(void)closeOrderWithListItemModel:(YYOrderListItemModel *)orderListItemModel indexPath:(NSIndexPath *)indexPath{

    WeakSelf(ws);
    __block NSString *blockOrderCode = orderListItemModel.orderCode;
    __block NSInteger blockIsOrderClose = 0;//0代表为未关闭  1代表关闭

    __block BOOL _inRunLoop = true;
    NSInteger _currentOrderConnStatus = [orderListItemModel.connectStatus integerValue];
    if(_currentOrderConnStatus == YYOrderConnStatusLinked){
        [YYOrderApi getOrderCloseStatus:orderListItemModel.orderCode andBlock:^(YYRspStatusAndMessage *rspStatusAndMessage, NSInteger isclose, NSError *error) {
            blockIsOrderClose = isclose;
            _inRunLoop = false;
        }];
    }else{
        if(_currentOrderConnStatus == YYOrderConnStatusUnconfirmed || _currentOrderConnStatus == YYOrderConnStatusNotFound){
            blockIsOrderClose = 1;
        }
        _inRunLoop = false;
    }
    while (_inRunLoop) {
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantFuture]];
    }
    if (blockIsOrderClose == 0){
        YYOrderInfoModel *orderInfoModel = [[YYOrderInfoModel alloc] init];
        orderInfoModel.isAppend = orderListItemModel.isAppend;
        [[YYYellowPanelManage instance] showOrderStatusRequestClosePanelWidthParentView:self.view currentYYOrderInfoModel:orderInfoModel andCallBack:^(NSArray *value) {
            [YYOrderApi setOrderCloseRequest:blockOrderCode andBlock:^(YYRspStatusAndMessage *rspStatusAndMessage,  NSError *error) {
                if(rspStatusAndMessage.status == YYReqStatusCode100){
                    [ws loadOrderListItem:indexPath];
                    [YYToast showToastWithView:ws.view title:NSLocalizedString(@"订单已取消",nil)  andDuration:kAlertToastDuration];
                }else{
                    [YYToast showToastWithView:ws.view title:rspStatusAndMessage.message andDuration:kAlertToastDuration];
                }

            }];
        }];
    }else{
        CMAlertView *alertView = [[CMAlertView alloc] initWithTitle:NSLocalizedString(@"确认要取消交易吗？",nil) message:nil needwarn:NO delegate:nil cancelButtonTitle:NSLocalizedString(@"关闭",nil) otherButtonTitles:@[NSLocalizedString(@"取消",nil)]];
        alertView.specialParentView = self.view;
        [alertView setAlertViewBlock:^(NSInteger selectedIndex){
            if (selectedIndex == 1) {
                [YYOrderApi closeOrder:orderListItemModel.orderCode andBlock:^(YYRspStatusAndMessage *rspStatusAndMessage,  NSError *error) {
                    if(rspStatusAndMessage.status == YYReqStatusCode100){
                        [ws loadOrderListItem:indexPath];
                        [YYToast showToastWithView:ws.view title:NSLocalizedString(@"订单已取消",nil)  andDuration:kAlertToastDuration];
                    }else{
                        [YYToast showToastWithView:ws.view title:rspStatusAndMessage.message andDuration:kAlertToastDuration];
                    }
                }];
            }
        }];
        [alertView show];
    }

}
#pragma mark -TitlePagerViewDelegate
- (void)didTouchBWTitle:(NSUInteger)index {

    if(self.pagingTitleView){

        if(!self.pagingTitleView.isInAnimation){

            UIPageViewControllerNavigationDirection direction;

            if (self.currentIndex == index) {
                return;
            }

            self.pagingTitleView.isInAnimation = YES;

            if (index > self.currentIndex) {
                direction = UIPageViewControllerNavigationDirectionForward;
            } else {
                direction = UIPageViewControllerNavigationDirectionReverse;
            }

            UIViewController *viewController = [self viewControllerAtIndex:index];

            if (viewController) {
                __weak typeof(self) weakself = self;
                [self.pageViewController setViewControllers:@[viewController] direction:direction animated:YES completion:^(BOOL finished) {
                    weakself.pagingTitleView.isInAnimation = NO;
                    weakself.currentIndex = index;
                }];
            }else{
                self.pagingTitleView.isInAnimation = NO;
            }
        }
    }
}

#pragma mark - --------------自定义响应----------------------
- (IBAction)showTabUI:(id)sender {
    UIViewController *parent = [UIApplication sharedApplication].keyWindow.rootViewController;
    NSInteger menuUIWidth = 142;
    NSInteger menuUIHeight = 95;
    CGPoint p = [_tabBtn convertPoint:CGPointMake(0, 0) toView:parent.view];
    WeakSelf(ws);
    _searchFieldStr = @"";

    [YYMenuPopView addPellTableViewSelectWithWindowFrame:CGRectMake( p.x + (CGRectGetWidth(_tabBtn.frame)-menuUIWidth)/2, p.y+CGRectGetHeight(_tabBtn.frame), menuUIWidth, menuUIHeight) selectData:_tabBtnsData images:@[@"",@"",@""] action:^(NSInteger index) {
        if(index > -1){
            ws.currentOrderType = index;
            if(index == 0){
                //允许左右滑
                self.cannotSlide = NO;
            }else{
                //禁止左右滑
                self.cannotSlide = YES;
            }
            [ws setTabBtnState];
            [ws startHeaderBeginRefreshing];
        }else{
            [ws.tabBtn setImage:[UIImage imageNamed:@"down"] forState:UIControlStateNormal];
        }
    } animated:YES arrowImage:YES arrowPositionInfo:@[@(menuUIWidth/2)]];

}
- (void)messageButtonClicked:(id)sender {
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    [appDelegate showMessageView:nil parentViewController:self];
}

- (void)messageCountChanged:(NSNotification *)notification{
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    [appDelegate.untreatedMsgAmountModel setUnreadMessageAmount:_messageButton];
}
- (IBAction)showSearchView:(id)sender {
    if (_searchView.hidden == YES) {
        _pageingView.hidden = YES;
        _tableViewTopLayout.constant = 45;
        _searchView.hidden = NO;
        _searchField.text = nil;
        _searchFieldStr = @"";
        _searchView.alpha = 0.0;
        _searchViewTopLayoutConstraint.constant = -44;
        [_searchView layoutIfNeeded];
        self.tableView.hidden = NO;
        [UIView animateWithDuration:0.3 animations:^{
            _searchView.alpha = 1.0;
            _searchViewTopLayoutConstraint.constant = 0;
            [_searchView layoutIfNeeded];
        } completion:^(BOOL finished) {
            [_searchField becomeFirstResponder];
            self.isSearchView = YES;
            self.tableView.hidden = NO;
            self.noDataView.hidden = YES;
            _searchNoteArray = [NSKeyedUnarchiver unarchiveObjectWithFile:getOrderSearchNoteStorePath()];
            [self.tableView reloadData];
        }];
    }
}
- (IBAction)hideSearchView:(id)sender {
    if ( _searchView.hidden == NO) {
        if(_currentOrderType == 0){
            _pageingView.hidden = NO;
            _tableViewTopLayout.constant = 89;
        }
        _searchFieldStr = @"";
        _searchView.alpha = 1.0;
        _searchViewTopLayoutConstraint.constant = 0;
        [_searchView layoutIfNeeded];
        [UIView animateWithDuration:0.3 animations:^{
            _searchView.alpha = 0.0;
            _searchViewTopLayoutConstraint.constant = -44;
            [_searchView layoutIfNeeded];
        } completion:^(BOOL finished) {
            _searchView.hidden = YES;
            [_searchField resignFirstResponder];
            self.isSearchView = NO;
            self.searchNoteArray = nil;
            self.tableView.hidden = YES;
            [self.orderListArray removeAllObjects];
            self.noDataView.hidden = YES;
        }];
    }
}
- (IBAction)backAction:(id)sender {
    if(_cancelButtonClicked){
        _cancelButtonClicked();
    }
}
-(void)deleteSearchNote:(id)sender{
    UIButton *btn = sender;
    NSInteger row = btn.alpha - 1000;
    NSString *date = [[_searchNoteArray objectAtIndex:row] objectAtIndex:0];
    for (NSArray *note in self.localNoteArray) {
        if([note[0] isEqualToString:date]){
            [self.localNoteArray removeObject:note];
            break;
        }
    }
    BOOL iskeyedarchiver= [NSKeyedArchiver archiveRootObject:self.localNoteArray toFile:getOrderSearchNoteStorePath()];
    if(iskeyedarchiver){
        NSLog(@"archive success ");
        [_searchNoteArray removeObjectAtIndex:row];
        [self.tableView reloadData];
    }
}
#pragma mark - --------------自定义方法----------------------

-(void)startHeaderBeginRefreshing{
    if(_currentIndex == 0){
        if(_orderListTableVC_All){
            _orderListTableVC_All.currentOrderType = _currentOrderType;
            if(_currentOrderType != 0){
                _orderListTableVC_All.tableViewTopLayout.constant = 45;
            }else{
                _orderListTableVC_All.tableViewTopLayout.constant = 89;
            }
            [_orderListTableVC_All startHeaderBeginRefreshing];
        }
    }else if(_currentIndex == 1){
        if(_orderListTableVC_NEGOTIATION){
            _orderListTableVC_NEGOTIATION.currentOrderType = _currentOrderType;
            if(_currentOrderType != 0){
                _orderListTableVC_NEGOTIATION.tableViewTopLayout.constant = 45;
            }else{
                _orderListTableVC_NEGOTIATION.tableViewTopLayout.constant = 89;
            }
            [_orderListTableVC_NEGOTIATION startHeaderBeginRefreshing];
        }
    }else if(_currentIndex == 2){
        if(_orderListTableVC_NEGOTIATION_DONE){
            _orderListTableVC_NEGOTIATION_DONE.currentOrderType = _currentOrderType;
            if(_currentOrderType != 0){
                _orderListTableVC_NEGOTIATION_DONE.tableViewTopLayout.constant = 45;
            }else{
                _orderListTableVC_NEGOTIATION_DONE.tableViewTopLayout.constant = 89;
            }
            [_orderListTableVC_NEGOTIATION_DONE startHeaderBeginRefreshing];
        }
    }else if(_currentIndex == 3){
        if(_orderListTableVC_MANUFACTURE){
            _orderListTableVC_MANUFACTURE.currentOrderType = _currentOrderType;
            if(_currentOrderType != 0){
                _orderListTableVC_MANUFACTURE.tableViewTopLayout.constant = 45;
            }else{
                _orderListTableVC_MANUFACTURE.tableViewTopLayout.constant = 89;
            }
            [_orderListTableVC_MANUFACTURE startHeaderBeginRefreshing];
        }
    }else if(_currentIndex == 4){
        if(_orderListTableVC_DELIVERING){
            _orderListTableVC_DELIVERING.currentOrderType = _currentOrderType;
            if(_currentOrderType != 0){
                _orderListTableVC_DELIVERING.tableViewTopLayout.constant = 45;
            }else{
                _orderListTableVC_DELIVERING.tableViewTopLayout.constant = 89;
            }
            [_orderListTableVC_DELIVERING startHeaderBeginRefreshing];
        }
    }else if(_currentIndex == 5){
        if(_orderListTableVC_DELIVERY){
            _orderListTableVC_DELIVERY.currentOrderType = _currentOrderType;
            if(_currentOrderType != 0){
                _orderListTableVC_DELIVERY.tableViewTopLayout.constant = 45;
            }else{
                _orderListTableVC_DELIVERY.tableViewTopLayout.constant = 89;
            }
            [_orderListTableVC_DELIVERY startHeaderBeginRefreshing];
        }
    }else if(_currentIndex == 6){
        if(_orderListTableVC_RECEIVED){
            _orderListTableVC_RECEIVED.currentOrderType = _currentOrderType;
            if(_currentOrderType != 0){
                _orderListTableVC_RECEIVED.tableViewTopLayout.constant = 45;
            }else{
                _orderListTableVC_RECEIVED.tableViewTopLayout.constant = 89;
            }
            [_orderListTableVC_RECEIVED startHeaderBeginRefreshing];
        }
    }
}
-(CGFloat)getActualItemWidth:(NSArray *)titleArray{
    CGFloat actualWidth = 0.f;
    if(_pagingTitleView){
        //获取单个item的宽度
        CGFloat pagingTitleViewItemWidth = [TitlePagerView getMaxTitleWidthFromArray:titleArray withFont:self.pagingTitleView.font];

        CGFloat suitableWidth = 17.0f;
        NSInteger suitableCount = 0;
        for (int i = 0; i < titleArray.count; i++) {
            suitableWidth += pagingTitleViewItemWidth;
            if(suitableWidth > SCREEN_WIDTH){
                break;
            }else{
                suitableCount++;
                suitableWidth += self.pagingTitleView.dynamicTitlePagerViewTitleSpace;
            }
        }

        actualWidth = (SCREEN_WIDTH - 17.0f - self.pagingTitleView.dynamicTitlePagerViewTitleSpace*(suitableCount - 1))/(suitableCount - 0.5);
    }
    return actualWidth;
}
-(void)reloadCurrentTableData:(BOOL)newData{
    YYOrderListTableViewController *tableViewController = (YYOrderListTableViewController *)[self viewControllerAtIndex:_currentIndex];
    if(tableViewController != nil){
        [tableViewController relaodTableData:newData];
    }
}


-(void)reloadTableData{
    if(self.isSearchView){
        self.noDataView.hidden = YES;
    }else{
        if ([self.orderListArray count] <= 0) {
            self.noDataView.hidden = NO;
        }else{
            self.noDataView.hidden = YES;
        }
    }
    [self.tableView reloadData];

}

-(void)addSearchNote{
    if(![NSString isNilOrEmpty:self.searchFieldStr]){
        if(self.localNoteArray ==nil){
            self.localNoteArray = [[NSMutableArray alloc] init];
        }

        BOOL isContains = YES;
        for (NSArray *note in self.localNoteArray) {
            if([note[0] isEqualToString:self.searchFieldStr]){
                isContains = NO;
                break;
            }
        }
        if(isContains){
            if([self.localNoteArray count] > 20){
                [self.localNoteArray removeObjectAtIndex:0];
            }
            [self.localNoteArray addObject:@[self.searchFieldStr,@"ordercode"]];
        }
        BOOL iskeyedarchiver= [NSKeyedArchiver archiveRootObject:self.localNoteArray toFile:getOrderSearchNoteStorePath()];
        if(iskeyedarchiver){
            NSLog(@"archive success ");
        }
    }
}
#pragma mark - --------------other----------------------

@end
