//
//  YYWarehousingViewController.m
//  YunejianBuyer
//
//  Created by Victor on 2018/7/2.
//  Copyright © 2018年 Apple. All rights reserved.
//
// c文件 —> 系统文件（c文件在前）

// 控制器
#import "YYWarehousingViewController.h"
#import "YYWarehousingDetailViewController.h"
#import "YYInventoryViewController.h"

// 自定义视图
#import "YYInventoryRecordCell.h"
#import "YYPickView.h"

// 接口
#import "YYInventoryApi.h"

// 分类
#import "UIButton+EdgeImageButton.h"

// 自定义类和三方类（ cocoapods类 > model > 工具类 > 其他）
#import <MBProgressHUD.h>
#import <MJRefresh.h>
#import "YYTableViewCellData.h"
#import "YYTableViewCellInfoModel.h"
#import "YYWarehouseListModel.h"

typedef NS_ENUM(NSUInteger, PickViewType) {
    PickViewTypeBegin,
    PickViewTypeEnd
};

@interface YYWarehousingViewController () <UITableViewDataSource, UITableViewDelegate, YYPickViewDelegate>

@property (nonatomic, strong) NSArray *cellDataArrays;
@property (nonatomic, strong) NSArray *filterCellDataArray;
@property (nonatomic, strong) UIView *noDataView;
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) UIView *filterView;
@property (nonatomic, strong) UIButton *warehouseFilterButton;
@property (nonatomic, strong) UIButton *typeFilterButton;
@property (nonatomic, strong) UIButton *timeFilterButton;
@property (nonatomic, strong) UIView *maskView;
@property (nonatomic, strong) UITableView *filterTableView;
@property (nonatomic, strong) YYPickView *datePickView;

@property (nonatomic, strong) NSDate *beginDate;
@property (nonatomic, strong) NSDate *endDate;
@property (nonatomic, strong) NSMutableArray<YYWarehouseRecordModel *>*recordSourceArray;
@property (nonatomic, strong) NSMutableArray<YYWarehouseListModel *> *warehouseSourceArray;
@property (nonatomic, strong) NSArray *typeSourceArray;
@property (nonatomic, assign) NSInteger warehouseSelectIndex;
@property (nonatomic, assign) NSInteger typeSelectIndex;
@property (nonatomic, assign) TableViewType currentType;

@property (nonatomic, strong) YYWarehouseRequestModel *recordRequest;

@end

static CGFloat const FilterViewHeight = 40;

@implementation YYWarehousingViewController

#pragma mark - --------------生命周期--------------
- (void)viewDidLoad {
    [super viewDidLoad];
    [self SomePrepare];
    [self UIConfig];
    [self RequestData];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [MobClick beginLogPageView:kYYInventoryWarehouse];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self hiddenFilterViewUpdate:NO];
    [MobClick endLogPageView:kYYInventoryWarehouse];
}

- (void)setSearchFieldText:(NSString *)searchFieldText {
    _searchFieldText = searchFieldText;
    if (self.recordRequest) {
        self.recordRequest.styleName = searchFieldText;
        self.recordRequest.pageIndex = 1;
    }
}

#pragma mark - --------------SomePrepare--------------
- (void)SomePrepare {
    [self PrepareData];
    [self PrepareUI];
}

- (void)PrepareData {
    self.recordSourceArray = [NSMutableArray array];
    self.warehouseSourceArray = [NSMutableArray array];
    YYWarehouseListModel *model = [[YYWarehouseListModel alloc] init];
    model.warehouseId = nil;
    model.warehouseName = NSLocalizedString(@"所有仓库", nil);
    [self.warehouseSourceArray addObject:model];
    
    self.typeSourceArray = @[@"All", @"PURCHASE", @"SELL_RETURN", @"TRANSFER", @"CHECK_EXCEPTION", @"OTHER_INCOMING"];
    
    self.beginDate = [self getCurrentMonthBeginDate];
    self.endDate = [self getCurrentMonthEndDate];
    self.recordRequest = [[YYWarehouseRequestModel alloc] init];
    self.recordRequest.styleName = self.searchFieldText;
    self.recordRequest.source = nil;
    self.recordRequest.warehouseId = nil;
    self.recordRequest.startTime = [NSNumber numberWithDouble:[self.beginDate timeIntervalSince1970] * 1000];
    self.recordRequest.endTime = [NSNumber numberWithDouble:[self.endDate timeIntervalSince1970] * 1000];
    
    self.currentType = TableViewTypeNone;
    [self buildTableViewDataSourceForTableViewType:TableViewTypeNormal];
}

- (void)PrepareUI {
    [self initFilterView];
    
    self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, kStatusBarAndNavigationBarHeight + 44 + FilterViewHeight, SCREEN_WIDTH, SCREEN_HEIGHT - kStatusBarAndNavigationBarHeight - 44 - FilterViewHeight - kTabbarAndBottomSafeAreaHeight) style:UITableViewStyleGrouped];
    self.tableView.tag = TableViewTypeNormal;
    self.tableView.backgroundColor = [UIColor colorWithHex:@"f8f8f8"];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    [self.view addSubview:self.tableView];
    [self.tableView registerClass:[YYInventoryRecordCell class] forCellReuseIdentifier:NSStringFromClass([YYInventoryRecordCell class])];
    
    self.noDataView = addNoDataView_phone(self.view, [NSString stringWithFormat:@"%@|icon", NSLocalizedString(@"抱歉，没有找到您要搜索的记录", nil)], @"919191", @"no_ordering_icon");
    [self.noDataView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(0);
        make.top.mas_equalTo((kStatusBarAndNavigationBarHeight + 44 + FilterViewHeight + SCREEN_HEIGHT - kTabbarAndBottomSafeAreaHeight) / 2);
    }];
    
    self.filterTableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
    self.filterTableView.backgroundColor = _define_white_color;
    self.filterTableView.tag = TableViewTypeNone;
    self.filterTableView.backgroundColor = _define_white_color;
    self.filterTableView.dataSource = self;
    self.filterTableView.delegate = self;
    [self.view addSubview:self.filterTableView];
    WeakSelf(ws);
    [self.filterTableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(0);
        make.top.mas_equalTo(ws.filterView.mas_bottom);
        make.left.mas_equalTo(0);
        make.right.mas_equalTo(0);
    }];
}

#pragma mark - --------------UIConfig----------------------
-(void)UIConfig {
    [self addHeader];
    [self addFooter];
}

#pragma mark - --------------请求数据----------------------
-(void)RequestData {
    [self getWarehouseList];
    [self getWarehouseRecordByRequest:self.recordRequest inBackground:NO];
}

- (void)getWarehouseList {
    [YYInventoryApi getWarehouseListWithBlock:^(YYRspStatusAndMessage *rspStatusAndMessage, NSArray *warehouseList, NSError *error) {
        if (!error && rspStatusAndMessage.status == YYReqStatusCode100) {
            [self.warehouseSourceArray addObjectsFromArray:warehouseList];
        }
    }];
}

- (void)getWarehouseRecordByRequest:(YYWarehouseRequestModel *)request inBackground:(BOOL)isBackground {
    if (!isBackground) {
        [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    }
    if (self.isEXwarehouse) {
        if (!isBackground) {
            [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
        }
    }else {
        [YYInventoryApi getWarehouseRecordByRequest:request andBlock:^(YYRspStatusAndMessage *rspStatusAndMessage, YYWarehouseRecordResponse *response, NSError *error) {
            if (!isBackground) {
                [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
            }
            [self.tableView.mj_header endRefreshing];
            if (!error && rspStatusAndMessage.status == YYReqStatusCode100) {
                if (response.pageInfo.isFirstPage && response.pageInfo.isLastPage) {
                    [self.tableView.mj_footer endRefreshingWithNoMoreData];
                    [self.recordSourceArray removeAllObjects];
                }else if (response.pageInfo.isFirstPage && !response.pageInfo.isLastPage) {
                    [self.tableView.mj_footer resetNoMoreData];
                    [self.recordSourceArray removeAllObjects];
                }else if (!response.pageInfo.isFirstPage && response.pageInfo.isLastPage) {
                    [self.tableView.mj_footer endRefreshingWithNoMoreData];
                }else if (!response.pageInfo.isFirstPage && !response.pageInfo.isLastPage) {
                    [self.tableView.mj_footer resetNoMoreData];
                }
                [self.recordSourceArray addObjectsFromArray:response.result];
                
                self.noDataView.hidden = [self isHiddenNoDataView];
                [self buildTableViewDataSourceForTableViewType:TableViewTypeNormal];
                [self.tableView reloadData];
            }else {
                [self.tableView.mj_footer endRefreshing];
            }
        }];
    }
}

#pragma mark - --------------系统代理----------------------
#pragma mark - UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    if (tableView.tag == TableViewTypeNormal) {
        return self.cellDataArrays.count;
    }else {
        return 1;
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (tableView.tag == TableViewTypeNormal) {
        return 1;
    }else {
        return self.filterCellDataArray.count;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    YYTableViewCellData *data = nil;
    if (tableView.tag == TableViewTypeNormal) {
        data = self.cellDataArrays[indexPath.section][indexPath.row];
    }else {
        data = self.filterCellDataArray[indexPath.row];
    }
    if ([data.reuseIdentifier isEqualToString:NSStringFromClass([YYInventoryRecordCell class])]) {
        YYInventoryRecordCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([YYInventoryRecordCell class])];
        [cell updateCellWithModel:data.object];
        return cell;
    }else {
        return [data tableView:tableView cellForRowAtIndexPath:indexPath];
    }
}

#pragma mark - UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath {
    YYTableViewCellData *data = nil;
    if (tableView.tag == TableViewTypeNormal) {
        data = self.cellDataArrays[indexPath.section][indexPath.row];
    }else {
        data = self.filterCellDataArray[indexPath.row];
    }
    return [data tableView:tableView estimatedHeightForRowAtIndexPath:indexPath];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    YYTableViewCellData *data = nil;
    if (tableView.tag == TableViewTypeNormal) {
        data = self.cellDataArrays[indexPath.section][indexPath.row];
    }else {
        data = self.filterCellDataArray[indexPath.row];
    }
    return [data tableView:tableView heightForRowAtIndexPath:indexPath];
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if (tableView.tag == TableViewTypeNormal) {
        return 5;
    }else {
        return 0.1;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    if (tableView.tag == TableViewTypeNormal) {
        return 5;
    }else {
        return 0.1;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    YYTableViewCellData *data = nil;
    if (tableView.tag == TableViewTypeNormal) {
        data = self.cellDataArrays[indexPath.section][indexPath.row];
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
    }else if (tableView.tag == TableViewTypeTime) {
        data = self.filterCellDataArray[indexPath.row];
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
    }else {
        data = self.filterCellDataArray[indexPath.row];
    }
    [data tableView:tableView didSelectRowAtIndexPath:indexPath];
}

#pragma mark - --------------自定义代理/block----------------------
#pragma mark - YYPickViewDelegate
-(void)toobarDonBtnHaveClick:(YYPickView *)pickView resultString:(NSString *)resultString {
    NSDate *date = [pickView getSelectedDate];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd"];
    NSString *dateTimeStr = [dateFormatter stringFromDate:date];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    
    if (pickView.tag == PickViewTypeBegin) {
        self.beginDate = [dateFormatter dateFromString:[NSString stringWithFormat:@"%@ 00:00:00", dateTimeStr]];
        if ([self.beginDate compare:self.endDate] == NSOrderedDescending) {
            self.endDate = [dateFormatter dateFromString:[NSString stringWithFormat:@"%@ 23:59:59", dateTimeStr]];
        }
        [self.filterTableView reloadData];
    }else if (pickView.tag == PickViewTypeEnd) {
        self.endDate = [dateFormatter dateFromString:[NSString stringWithFormat:@"%@ 23:59:59", dateTimeStr]];
        [self.filterTableView reloadData];
    }
    [self updateFilterView];
}

#pragma mark - --------------自定义响应----------------------
/**显示移除遮罩层**/
- (void)showMaskViewTopPin:(CGFloat)pin {
    if (!self.maskView) {
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hiddenFilterViewUpdate:)];
        self.maskView = [[UIView alloc] init];
        self.maskView.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.3];
        [self.maskView addGestureRecognizer:tap];
        UIViewController *viewController = getCurrentViewController();
        [viewController.view addSubview:self.maskView];
        [self.maskView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(kStatusBarAndNavigationBarHeight + 44 + FilterViewHeight + pin);
            make.left.mas_equalTo(0);
            make.bottom.mas_equalTo(0);
            make.right.mas_equalTo(0);
        }];
    }
}

- (void)removeMaskView {
    if (self.maskView) {
        [self.maskView removeFromSuperview];
        self.maskView = nil;
    }
}

/**三个筛选列表**/
- (void)showWarehouseFilterView {
    [self buildTableViewDataSourceForTableViewType:TableViewTypeWarehouse];
    CGFloat height = self.warehouseSourceArray.count > 5 ? (44 * 5) : (44 * self.warehouseSourceArray.count);
    [self showMaskViewTopPin:height];
    self.currentType = TableViewTypeWarehouse;
    
    self.filterTableView.tag = TableViewTypeWarehouse;
    [self.filterTableView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(height);
    }];
    [self.filterTableView reloadData];
}

- (void)showOperationFilterView {
    [self buildTableViewDataSourceForTableViewType:TableViewTypeOperationType];
    CGFloat height = self.typeSourceArray.count > 5 ? (44 * 5) : (44 * self.typeSourceArray.count);
    [self showMaskViewTopPin:height];
    self.currentType = TableViewTypeOperationType;
    
    self.filterTableView.tag = TableViewTypeOperationType;
    [self.filterTableView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(height);
    }];
    [self.filterTableView reloadData];
}

- (void)showTimeFilterView {
    [self buildTableViewDataSourceForTableViewType:TableViewTypeTime];
    [self showMaskViewTopPin:44 * 2];
    self.currentType = TableViewTypeTime;
    
    self.filterTableView.tag = TableViewTypeTime;
    [self.filterTableView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(44 * 2);
    }];
    [self.filterTableView reloadData];
}

- (void)hiddenFilterViewUpdate:(BOOL)update {
    self.warehouseFilterButton.selected = NO;
    self.typeFilterButton.selected = NO;
    self.timeFilterButton.selected = NO;
    [self removeMaskView];
    
    self.filterTableView.tag = TableViewTypeNone;
    [self.filterTableView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(0);
    }];
    
    //重新请求数据
    if (update || self.currentType == TableViewTypeTime) {
        self.recordRequest.pageIndex = 1;
        self.recordRequest.pageSize = 20;
        self.recordRequest.source = [YYWarehouseRecordModel getIncomingTypeForName:[YYWarehouseRecordModel getIncomingNameForType:self.typeSourceArray[self.typeSelectIndex]]];
        self.recordRequest.warehouseId = self.warehouseSourceArray[self.warehouseSelectIndex].warehouseId;
        self.recordRequest.startTime = [NSNumber numberWithDouble:[self.beginDate timeIntervalSince1970] * 1000];
        self.recordRequest.endTime = [NSNumber numberWithDouble:[self.endDate timeIntervalSince1970] * 1000];
        [self getWarehouseRecordByRequest:self.recordRequest inBackground:NO];
    }
    
    self.currentType = TableViewTypeNone;
}

/**点击三个筛选按钮**/
- (void)warehouseFilterAction {
    self.warehouseFilterButton.selected = YES;
    if (!self.maskView) {
        [self showWarehouseFilterView];
    }else {
        [self hiddenFilterViewUpdate:NO];
    }
}

- (void)oprationFilterAction {
    self.typeFilterButton.selected = YES;
    if (!self.maskView) {
        [self showOperationFilterView];
    }else {
        [self hiddenFilterViewUpdate:NO];
    }
}

- (void)timeFilterAction {
    self.timeFilterButton.selected = YES;
    if (!self.maskView) {
        [self showTimeFilterView];
    }else {
        [self hiddenFilterViewUpdate:YES];
    }
}

/**选择开始结束时间**/
- (void)showBeginTimePickView {
    if (!self.datePickView) {
        self.datePickView = [[YYPickView alloc] initDatePickWithDate:self.beginDate datePickerMode:UIDatePickerModeDate isHaveNavControler:NO];
        [self.datePickView setToolbarTitle:NSLocalizedString(@"选择日期", nil)];
        self.datePickView.delegate = self;
    }
    self.datePickView.tag = PickViewTypeBegin;
    [self.datePickView setDatePickMinDate:nil];
    [self.datePickView setDatePickSelectedDate:self.beginDate];
    [self.datePickView show:nil];
}

- (void)showEndTimePickView {
    if (!self.datePickView) {
        self.datePickView = [[YYPickView alloc] initDatePickWithDate:self.endDate datePickerMode:UIDatePickerModeDate isHaveNavControler:NO];
        [self.datePickView setToolbarTitle:NSLocalizedString(@"选择日期", nil)];
        self.datePickView.delegate = self;
    }
    self.datePickView.tag = PickViewTypeEnd;
    [self.datePickView setDatePickMinDate:self.beginDate];
    [self.datePickView setDatePickSelectedDate:self.endDate];
    [self.datePickView show:nil];
}

#pragma mark - --------------自定义方法----------------------
- (void)updateFilterView {
    UIColor *selectedColor = [UIColor colorWithRed:237 / 255.0 green:100 / 255.0 blue:152 / 255.0 alpha:1];
    if (self.currentType == TableViewTypeWarehouse) {
        [self.warehouseFilterButton setTitle:((YYWarehouseListModel *)self.warehouseSourceArray[self.warehouseSelectIndex]).warehouseName forState:UIControlStateNormal];
        if (self.warehouseSelectIndex == 0) {
            [self.warehouseFilterButton setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
            [self.warehouseFilterButton setImage:[UIImage imageNamed:@"ChooseStype_Down_Normal"] forState:UIControlStateNormal];
            [self.warehouseFilterButton setImage:[UIImage imageNamed:@"ChooseStype_Up_Normal"] forState:UIControlStateSelected];
        }else {
            [self.warehouseFilterButton setTitleColor:selectedColor forState:UIControlStateNormal];
            [self.warehouseFilterButton setImage:[UIImage imageNamed:@"ChooseStype_Down_Select"] forState:UIControlStateNormal];
            [self.warehouseFilterButton setImage:[UIImage imageNamed:@"ChooseStype_Up_Select"] forState:UIControlStateSelected];
        }
        [self.warehouseFilterButton setButtonEdgeType:EdgeTypeRight];
    }else if (self.currentType == TableViewTypeOperationType) {
        [self.typeFilterButton setTitle:[YYWarehouseRecordModel getIncomingNameForType:self.typeSourceArray[self.typeSelectIndex]] forState:UIControlStateNormal];
        if (self.typeSelectIndex == 0) {
            [self.typeFilterButton setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
            [self.typeFilterButton setImage:[UIImage imageNamed:@"ChooseStype_Down_Normal"] forState:UIControlStateNormal];
            [self.typeFilterButton setImage:[UIImage imageNamed:@"ChooseStype_Up_Normal"] forState:UIControlStateSelected];
        }else {
            [self.typeFilterButton setTitleColor:selectedColor forState:UIControlStateNormal];
            [self.typeFilterButton setImage:[UIImage imageNamed:@"ChooseStype_Down_Select"] forState:UIControlStateNormal];
            [self.typeFilterButton setImage:[UIImage imageNamed:@"ChooseStype_Up_Select"] forState:UIControlStateSelected];
        }
        [self.typeFilterButton setButtonEdgeType:EdgeTypeRight];
    }else if (self.currentType == TableViewTypeTime) {
        NSString *dateRange = [self getMonthRangeFrom:self.beginDate To:self.endDate];
        [self.timeFilterButton setTitle:dateRange forState:UIControlStateNormal];
        [self.timeFilterButton setButtonEdgeType:EdgeTypeRight];
    }
}

- (void)initFilterView {
    self.filterView = [[UIView alloc] initWithFrame:CGRectMake(0, kStatusBarAndNavigationBarHeight + 44, SCREEN_WIDTH, FilterViewHeight)];
    self.filterView.backgroundColor = _define_white_color;
    [self.view addSubview:self.filterView];
    
    self.warehouseFilterButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.warehouseFilterButton setTitle:((YYWarehouseListModel *)self.warehouseSourceArray[self.warehouseSelectIndex]).warehouseName forState:UIControlStateNormal];
    [self.warehouseFilterButton setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
    [self.warehouseFilterButton setImage:[UIImage imageNamed:@"ChooseStype_Down_Normal"] forState:UIControlStateNormal];
    [self.warehouseFilterButton setImage:[UIImage imageNamed:@"ChooseStype_Up_Normal"] forState:UIControlStateSelected];
    self.warehouseFilterButton.titleLabel.font = [UIFont systemFontOfSize:14];
    self.warehouseFilterButton.titleLabel.lineBreakMode = NSLineBreakByTruncatingTail;
    [self.warehouseFilterButton addTarget:self action:@selector(warehouseFilterAction) forControlEvents:UIControlEventTouchUpInside];
    [self.filterView addSubview:self.warehouseFilterButton];
    [self.warehouseFilterButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(95);
        make.centerY.mas_equalTo(0);
        make.left.mas_equalTo(17);
    }];
    [self.warehouseFilterButton setButtonEdgeType:EdgeTypeRight];
    
    self.typeFilterButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.typeFilterButton setTitle:[YYWarehouseRecordModel getIncomingNameForType:self.typeSourceArray[self.typeSelectIndex]] forState:UIControlStateNormal];
    [self.typeFilterButton setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
    [self.typeFilterButton setImage:[UIImage imageNamed:@"ChooseStype_Down_Normal"] forState:UIControlStateNormal];
    [self.typeFilterButton setImage:[UIImage imageNamed:@"ChooseStype_Up_Normal"] forState:UIControlStateSelected];
    self.typeFilterButton.titleLabel.font = [UIFont systemFontOfSize:14];
    [self.typeFilterButton addTarget:self action:@selector(oprationFilterAction) forControlEvents:UIControlEventTouchUpInside];
    [self.filterView addSubview:self.typeFilterButton];
    [self.typeFilterButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.mas_equalTo(0);
    }];
    [self.typeFilterButton setButtonEdgeType:EdgeTypeRight];
    
    NSString *dateRange = [self getMonthRangeFrom:self.beginDate To:self.endDate];
    self.timeFilterButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.timeFilterButton setTitle:dateRange forState:UIControlStateNormal];
    [self.timeFilterButton setTitleColor:[UIColor colorWithRed:237 / 255.0 green:100 / 255.0 blue:152 / 255.0 alpha:1] forState:UIControlStateNormal];
    [self.timeFilterButton setImage:[UIImage imageNamed:@"ChooseStype_Down_Select"] forState:UIControlStateNormal];
    [self.timeFilterButton setImage:[UIImage imageNamed:@"ChooseStype_Up_Select"] forState:UIControlStateSelected];
    self.timeFilterButton.titleLabel.font = [UIFont systemFontOfSize:14];
    [self.timeFilterButton addTarget:self action:@selector(timeFilterAction) forControlEvents:UIControlEventTouchUpInside];
    [self.filterView addSubview:self.timeFilterButton];
    [self.timeFilterButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(0);
        make.right.mas_equalTo(-17);
    }];
    [self.timeFilterButton setButtonEdgeType:EdgeTypeRight];
}

- (void)addHeader {
    WeakSelf(ws);
    MJRefreshNormalHeader *header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        if (![YYCurrentNetworkSpace isNetwork]) {
            [YYToast showToastWithTitle:kNetworkIsOfflineTips andDuration:kAlertToastDuration];
            [ws.tableView.mj_header endRefreshing];
            return;
        }
        ws.recordRequest.pageIndex = 1;
        [ws getWarehouseRecordByRequest:ws.recordRequest inBackground:YES];
    }];
    self.tableView.mj_header = header;
    self.tableView.mj_header.automaticallyChangeAlpha = YES;
    header.lastUpdatedTimeLabel.hidden = YES;
}

- (void)addFooter {
    WeakSelf(ws);
    self.tableView.mj_footer = [MJRefreshBackNormalFooter footerWithRefreshingBlock:^{
        if (![YYCurrentNetworkSpace isNetwork]) {
            [YYToast showToastWithTitle:kNetworkIsOfflineTips andDuration:kAlertToastDuration];
            [ws.tableView.mj_footer endRefreshing];
            return;
        }
        ++ ws.recordRequest.pageIndex;
        [ws getWarehouseRecordByRequest:ws.recordRequest inBackground:YES];
    }];
}

- (NSDate *)getCurrentMonthBeginDate {
    NSDate *beginDate = nil;
    double interval = 0;
    NSCalendar *calendar = [NSCalendar currentCalendar];
    [calendar setFirstWeekday:2];//设定周一为周首日
    [calendar rangeOfUnit:NSCalendarUnitMonth startDate:&beginDate interval:&interval forDate:[NSDate date]];
    return beginDate;
}

- (NSDate *)getCurrentMonthEndDate {
    double interval = 0;
    NSDate *beginDate = nil;
    NSDate *endDate = nil;
    NSCalendar *calendar = [NSCalendar currentCalendar];
    [calendar setFirstWeekday:2];//设定周一为周首日
    BOOL successful = [calendar rangeOfUnit:NSCalendarUnitMonth startDate:&beginDate interval:&interval forDate:[NSDate date]];
    if (successful) {
        endDate = [beginDate dateByAddingTimeInterval:interval - 1];
    }
    return endDate;
}

- (NSString *)getMonthRangeFrom:(NSDate *)beginDate To:(NSDate *)endDate {
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"MM.dd"];
    NSString *begin = [dateFormatter stringFromDate:beginDate];
    NSString *end = [dateFormatter stringFromDate:endDate];
    return [NSString stringWithFormat:@"%@-%@", begin, end];
}

- (BOOL)isHiddenNoDataView {
    if (self.recordSourceArray && self.recordSourceArray.count > 0) {
        return YES;
    }else {
        return NO;
    }
}

- (void)getWarehouseRecord {
    [self getWarehouseRecordByRequest:self.recordRequest inBackground:NO];
}

#pragma mark - --------------other----------------------
- (void)buildTableViewDataSourceForTableViewType:(TableViewType)tableViewType {
    WeakSelf(ws);
    if (tableViewType == TableViewTypeNormal) {
        NSMutableArray *arrays = [NSMutableArray array];
        for (int i = 0; i < self.recordSourceArray.count; i++) {
            YYWarehouseRecordModel *recordModel = self.recordSourceArray[i];
            YYTableViewCellData *data = [[YYTableViewCellData alloc] init];
            data.reuseIdentifier = NSStringFromClass([YYInventoryRecordCell class]);
            data.useDynamicRowHeight = YES;
            data.object = recordModel;
            data.selectedCellBlock = ^(UITableView *tableView, NSIndexPath *indexPath) {
                YYWarehousingDetailViewController *viewController = [[YYWarehousingDetailViewController alloc] init];
                viewController.recordModel = recordModel;
                viewController.isEXwarehouse = self.isEXwarehouse;
                [ws.navigationController pushViewController:viewController animated:YES];
            };
            [arrays addObject:@[data]];
        }
        self.cellDataArrays = arrays;
    }else if (tableViewType == TableViewTypeWarehouse) {
        NSMutableArray *array = [NSMutableArray array];
        for (YYWarehouseListModel *model in self.warehouseSourceArray) {
            UIView *selectedView = [[UIView alloc] init];
            selectedView.backgroundColor = [UIColor colorWithHex:@"f8f8f8"];
            UIImageView *accessoryView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"chooseStyle_Select"]];
            
            YYTableViewCellData *data = [[YYTableViewCellData alloc] init];
            data.tableViewCellStyle = UITableViewCellStyleDefault;
            data.tableViewCellRowHeight = 44;
            data.dynamicCellBlock = ^(UITableViewCell *cell, NSIndexPath *indexPath) {
                cell.textLabel.text = model.warehouseName;
                cell.textLabel.font = [UIFont systemFontOfSize:14];
                cell.selectedBackgroundView = selectedView;
                if (indexPath.row == ws.warehouseSelectIndex) {
                    cell.textLabel.textColor = [UIColor colorWithRed:237 / 255.0 green:100 / 255.0 blue:152 / 255.0 alpha:1];
                    cell.accessoryView = accessoryView;
                    [ws.filterTableView selectRowAtIndexPath:indexPath animated:YES scrollPosition:(UITableViewScrollPosition)UITableViewScrollPositionNone];
                }else {
                    cell.textLabel.textColor = [UIColor lightGrayColor];
                    cell.accessoryView = nil;
                }
            };
            data.selectedCellBlock = ^(UITableView *tableView, NSIndexPath *indexPath) {
                if (indexPath.row != ws.warehouseSelectIndex) {
                    ws.warehouseSelectIndex = indexPath.row;
                    [tableView reloadData];
                }
                [ws updateFilterView];
                [ws hiddenFilterViewUpdate:YES];
            };
            [array addObject:data];
        }
        self.filterCellDataArray = array;
    }else if (tableViewType == TableViewTypeOperationType) {
        NSMutableArray *array = [NSMutableArray array];
        for (NSString *type in self.typeSourceArray) {
            UIView *selectedView = [[UIView alloc] init];
            selectedView.backgroundColor = [UIColor colorWithHex:@"f8f8f8"];
            UIImageView *accessoryView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"chooseStyle_Select"]];
            
            YYTableViewCellData *data = [[YYTableViewCellData alloc] init];
            data.tableViewCellStyle = UITableViewCellStyleDefault;
            data.tableViewCellRowHeight = 44;
            data.dynamicCellBlock = ^(UITableViewCell *cell, NSIndexPath *indexPath) {
                cell.textLabel.text = [YYWarehouseRecordModel getIncomingNameForType:type];
                cell.textLabel.font = [UIFont systemFontOfSize:14];
                cell.selectedBackgroundView = selectedView;
                if (indexPath.row == ws.typeSelectIndex) {
                    cell.textLabel.textColor = [UIColor colorWithRed:237 / 255.0 green:100 / 255.0 blue:152 / 255.0 alpha:1];
                    cell.accessoryView = accessoryView;
                    [ws.filterTableView selectRowAtIndexPath:indexPath animated:YES scrollPosition:(UITableViewScrollPosition)UITableViewScrollPositionNone];
                }else {
                    cell.textLabel.textColor = [UIColor lightGrayColor];
                    cell.accessoryView = nil;
                }
            };
            data.selectedCellBlock = ^(UITableView *tableView, NSIndexPath *indexPath) {
                if (indexPath.row != ws.typeSelectIndex) {
                    ws.typeSelectIndex = indexPath.row;
                    [tableView reloadData];
                }
                [ws updateFilterView];
                [ws hiddenFilterViewUpdate:YES];
            };
            [array addObject:data];
        }
        self.filterCellDataArray = array;
    }else if (tableViewType == TableViewTypeTime) {
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"yyyy-MM-dd"];
        NSMutableArray *array = [NSMutableArray array];
        if (YES) {
            YYTableViewCellData *data = [[YYTableViewCellData alloc] init];
            data.tableViewCellStyle = UITableViewCellStyleValue1;
            data.tableViewCellRowHeight = 44;
            data.dynamicCellBlock = ^(UITableViewCell *cell, NSIndexPath *indexPath) {
                cell.textLabel.text = NSLocalizedString(@"开始时间", nil);
                cell.textLabel.textColor = [UIColor lightGrayColor];
                cell.textLabel.font = [UIFont systemFontOfSize:14];
                cell.detailTextLabel.text = [dateFormatter stringFromDate:self.beginDate];
                cell.detailTextLabel.textColor = [UIColor lightGrayColor];
                cell.detailTextLabel.font = [UIFont systemFontOfSize:14];
                cell.accessoryView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"down_gray"]];
            };
            data.selectedCellBlock = ^(UITableView *tableView, NSIndexPath *indexPath) {
                [ws showBeginTimePickView];
            };
            [array addObject:data];
        }
        if (YES) {
            YYTableViewCellData *data = [[YYTableViewCellData alloc] init];
            data.tableViewCellStyle = UITableViewCellStyleValue1;
            data.tableViewCellRowHeight = 44;
            data.dynamicCellBlock = ^(UITableViewCell *cell, NSIndexPath *indexPath) {
                cell.textLabel.text = NSLocalizedString(@"结束时间", nil);
                cell.textLabel.textColor = [UIColor lightGrayColor];
                cell.textLabel.font = [UIFont systemFontOfSize:14];
                cell.detailTextLabel.text = [dateFormatter stringFromDate:self.endDate];
                cell.detailTextLabel.textColor = [UIColor lightGrayColor];
                cell.detailTextLabel.font = [UIFont systemFontOfSize:14];
                cell.accessoryView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"down_gray"]];
            };
            data.selectedCellBlock = ^(UITableView *tableView, NSIndexPath *indexPath) {
                [ws showEndTimePickView];
            };
            [array addObject:data];
        }
        self.filterCellDataArray = array;
    }
}
@end
