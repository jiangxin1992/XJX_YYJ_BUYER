//
//  YYMerchandiseInventoryViewController.m
//  YunejianBuyer
//
//  Created by Victor on 2018/7/25.
//  Copyright © 2018年 Apple. All rights reserved.
//
// c文件 —> 系统文件（c文件在前）

// 控制器
#import "YYMerchandiseInventoryViewController.h"
#import "YYWarehousingViewController.h"

// 自定义视图

// 接口
#import "YYInventoryApi.h"

// 分类
#import "NSArray+FirstLetter.h"
#import "UIButton+EdgeImageButton.h"

// 自定义类和三方类（ cocoapods类 > model > 工具类 > 其他）
#import "YYTableViewCellData.h"
#import "YYWarehouseListModel.h"

@interface YYMerchandiseInventoryViewController ()<UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) UIView *filterView;
@property (nonatomic, strong) UIButton *warehouseFilterButton;
@property (nonatomic, strong) UIView *maskView;
@property (nonatomic, strong) UIView *noDataView;
@property (nonatomic, strong) UITableView *filterTableView;

@property (nonatomic, strong) NSArray *filterCellDataArray;
@property (nonatomic, strong) NSArray *cellDataArrays;
@property (nonatomic, strong) NSMutableArray *warehouseSourceArray;
@property (nonatomic, strong) NSArray *dataSourceArray;
@property (nonatomic, assign) NSInteger warehouseSelectIndex;
@property (nonatomic, assign) TableViewType currentType;

@end

static CGFloat const FilterViewHeight = 40;

@implementation YYMerchandiseInventoryViewController

#pragma mark - --------------生命周期--------------
- (void)viewDidLoad {
    [super viewDidLoad];
    [self SomePrepare];
    [self UIConfig];
    [self RequestData];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [MobClick beginLogPageView:kYYMerchandiseInventory];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [MobClick endLogPageView:kYYMerchandiseInventory];
}

#pragma mark - --------------SomePrepare--------------
- (void)SomePrepare {
    [self PrepareData];
    [self PrepareUI];
}

- (void)PrepareData {
    self.warehouseSourceArray = [NSMutableArray array];
    YYWarehouseListModel *model = [[YYWarehouseListModel alloc] init];
    model.warehouseId = nil;
    model.warehouseName = NSLocalizedString(@"所有仓库", nil);
    [self.warehouseSourceArray addObject:model];
    
    self.currentType = TableViewTypeNone;
}

- (void)PrepareUI {
    [self initFilterView];
    
    self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, kStatusBarAndNavigationBarHeight + 44 + FilterViewHeight, SCREEN_WIDTH, SCREEN_HEIGHT - kStatusBarAndNavigationBarHeight - 44 - FilterViewHeight - kTabbarAndBottomSafeAreaHeight) style:UITableViewStylePlain];
    self.tableView.backgroundColor = [UIColor colorWithHex:@"f8f8f8"];
    self.tableView.tag = TableViewTypeNormal;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    [self.view addSubview:self.tableView];
    
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
    
}

#pragma mark - --------------请求数据----------------------
-(void)RequestData {
    [self getWarehouseList];
    [self getWarehouseBrand];
}

- (void)getWarehouseList {
    [YYInventoryApi getWarehouseListWithBlock:^(YYRspStatusAndMessage *rspStatusAndMessage, NSArray *warehouseList, NSError *error) {
        if (!error && rspStatusAndMessage.status == YYReqStatusCode100) {
            [self.warehouseSourceArray addObjectsFromArray:warehouseList];
        }
    }];
}

- (void)getWarehouseBrand {
    NSArray *originalData = @[@"重庆", @"重量",@"长度", @"长大", @"TableView", @"Demo", @"ARETE", @"angel Chen", @"*People~~", @"ALIAS", @"BLACKBRIDGE", @"~.~", @"中心",];
    self.dataSourceArray = [originalData arrayWithFirstLetterFormat];
    self.noDataView.hidden = [self isHiddenNoDataView];
    [self buildTableViewDataSourceForTableViewType:TableViewTypeNormal];
    [self.tableView reloadData];
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
        return [self.cellDataArrays[section] count];
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
    return [data tableView:tableView cellForRowAtIndexPath:indexPath];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if (tableView.tag == TableViewTypeNormal) {
        return self.dataSourceArray[section][@"firstLetter"];
    }else {
        return nil;
    }
}

- (NSArray<NSString *> *)sectionIndexTitlesForTableView:(UITableView *)tableView {
    if (tableView.tag == TableViewTypeNormal) {
        return [self.dataSourceArray valueForKeyPath:@"firstLetter"];
    }else {
        return nil;
    }
}

- (NSInteger)tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index {
    if (tableView.tag == TableViewTypeNormal) {
        NSArray *indexes = [self.dataSourceArray valueForKeyPath:@"firstLetter"];
        return [indexes indexOfObject:title];
    }else {
        return 0;
    }
}

#pragma mark - UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    YYTableViewCellData *data = nil;
    if (tableView.tag == TableViewTypeNormal) {
        data = self.cellDataArrays[indexPath.section][indexPath.row];
    }else {
        data = self.filterCellDataArray[indexPath.row];
    }
    return [data tableView:tableView heightForRowAtIndexPath:indexPath];
}

- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath {
    YYTableViewCellData *data = nil;
    if (tableView.tag == TableViewTypeNormal) {
        data = self.cellDataArrays[indexPath.section][indexPath.row];
    }else {
        data = self.filterCellDataArray[indexPath.row];
    }
    return [data tableView:tableView estimatedHeightForRowAtIndexPath:indexPath];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    YYTableViewCellData *data = nil;
    if (tableView.tag == TableViewTypeNormal) {
        data = self.cellDataArrays[indexPath.section][indexPath.row];
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
    }else {
        data = self.filterCellDataArray[indexPath.row];
    }
    [data tableView:tableView didSelectRowAtIndexPath:indexPath];
}

#pragma mark - --------------自定义代理/block----------------------


#pragma mark - --------------自定义响应----------------------
/**显示移除遮罩层**/
- (void)showMaskViewTopPin:(CGFloat)pin {
    if (!self.maskView) {
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hiddenFilterView)];
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

/**筛选列表**/
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

- (void)hiddenFilterView {
    self.warehouseFilterButton.selected = NO;
    [self removeMaskView];
    
    self.filterTableView.tag = TableViewTypeNone;
    [self.filterTableView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(0);
    }];
    self.currentType = TableViewTypeNone;
}

/**筛选按钮**/
- (void)warehouseFilterAction {
    self.warehouseFilterButton.selected = YES;
    if (!self.maskView) {
        [self showWarehouseFilterView];
    }else {
        [self hiddenFilterView];
    }
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
        make.top.mas_equalTo(0);
        make.left.mas_equalTo(17);
        make.bottom.mas_equalTo(0);
        make.right.mas_equalTo(-17);
    }];
    [self.warehouseFilterButton setButtonEdgeType:EdgeTypeRight];
}

- (BOOL)isHiddenNoDataView {
    if (self.dataSourceArray && self.dataSourceArray.count > 0) {
        return YES;
    }else {
        return NO;
    }
}

#pragma mark - --------------other----------------------
- (void)buildTableViewDataSourceForTableViewType:(TableViewType)tableViewType {
    WeakSelf(ws);
    if (tableViewType == TableViewTypeNormal) {
        NSMutableArray *arrays = [NSMutableArray array];
        for (NSDictionary *indexDict in self.dataSourceArray) {
            NSMutableArray *array = [NSMutableArray array];
            for (NSString *contentStr in indexDict[@"content"]) {
                YYTableViewCellData *data = [[YYTableViewCellData alloc] init];
                data.tableViewCellStyle = UITableViewCellStyleDefault;
                data.text = contentStr;
                data.tableViewCellRowHeight = 44;
                data.selectedCellBlock = ^(UITableView *tableView, NSIndexPath *indexPath) {
                    NSLog(@"%@-->%@", indexDict[@"firstLetter"], contentStr);
                };
                [array addObject:data];
            }
            [arrays addObject:array];
        }
        self.cellDataArrays = [NSArray arrayWithArray:arrays];
    }else {
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
                    [ws getWarehouseBrand];
                }
                [ws updateFilterView];
                [ws hiddenFilterView];
            };
            [array addObject:data];
        }
        self.filterCellDataArray = [NSArray arrayWithArray:array];
    }
}

@end
