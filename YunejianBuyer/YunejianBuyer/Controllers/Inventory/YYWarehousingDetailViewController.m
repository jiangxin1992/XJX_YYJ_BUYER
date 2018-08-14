//
//  YYWarehousingDetailViewController.m
//  YunejianBuyer
//
//  Created by Victor on 2018/7/4.
//  Copyright © 2018年 Apple. All rights reserved.
//
// c文件 —> 系统文件（c文件在前）

// 控制器
#import "YYWarehousingDetailViewController.h"
#import "YYCustomCellTableViewController.h"

// 自定义视图
#import "YYNavView.h"
#import "YYMessageButton.h"
#import "YYNewStyleDetailCell.h"
#import "YYInventoryRecordCell.h"

// 接口
#import "YYInventoryApi.h"

// 分类

// 自定义类和三方类（ cocoapods类 > model > 工具类 > 其他）
#import <MBProgressHUD.h>
#import "YYOrderStyleModel.h"
#import "YYUntreatedMsgAmountModel.h"
#import "YYWarehouseDetailRequestModel.h"
#import "YYTableViewCellData.h"
#import "AppDelegate.h"

@interface YYWarehousingDetailViewController () <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) YYNavView *navView;
@property (nonatomic, strong) YYMessageButton *messageButton;
@property (nonatomic, strong) UITableView *tableView;

@property (nonatomic, strong) NSArray *cellDataArrays;
@property (nonatomic, strong) YYWarehouseRecordModel *response;

@end

@implementation YYWarehousingDetailViewController

#pragma mark - --------------生命周期--------------
- (void)viewDidLoad {
    [super viewDidLoad];
    [self SomePrepare];
    [self UIConfig];
    [self RequestData];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [MobClick beginLogPageView:kYYInventoryWarehouseDetail];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [MobClick endLogPageView:kYYInventoryWarehouseDetail];
}

#pragma mark - --------------SomePrepare--------------
- (void)SomePrepare {
    [self PrepareData];
    [self PrepareUI];
}

- (void)PrepareData {
}

- (void)PrepareUI {
    self.view.backgroundColor = _define_white_color;
    self.navView = [[YYNavView alloc] initWithTitle:self.isEXwarehouse ? NSLocalizedString(@"出库单详情",nil) : NSLocalizedString(@"入库单详情",nil) WithSuperView: self.view haveStatusView:YES];
    [self initMessageButton];
    
    self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, kStatusBarAndNavigationBarHeight, SCREEN_WIDTH, SCREEN_HEIGHT - kStatusBarAndNavigationBarHeight) style:UITableViewStyleGrouped];
    self.tableView.backgroundColor = [UIColor colorWithHex:@"f8f8f8"];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    [self.view addSubview:self.tableView];
    [self.tableView registerClass:[YYInventoryRecordCell class] forCellReuseIdentifier:NSStringFromClass([YYInventoryRecordCell class])];
}

#pragma mark - --------------UIConfig----------------------
-(void)UIConfig {
    
}

#pragma mark - --------------请求数据----------------------
-(void)RequestData {
    YYWarehouseDetailRequestModel *request = [[YYWarehouseDetailRequestModel alloc] init];
    request.incomingBill = self.recordModel.incomingBill;
    request.purchaseOrderId = self.recordModel.purchaseOrderId;
    [self getWarehouseDetailsByRequest:request];
}

- (void)getWarehouseDetailsByRequest:(YYWarehouseDetailRequestModel *)request {
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [YYInventoryApi getWarehouseDetailsByRequest:request andBlock:^(YYRspStatusAndMessage *rspStatusAndMessage, YYWarehouseRecordModel *response, NSError *error) {
        [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
        if (!error) {
            if (rspStatusAndMessage.status == YYReqStatusCode100) {
                self.response = response;
                [self buildTableViewDataSource];
                [self.tableView reloadData];
            }else {
                [YYToast showToastWithView:self.view title:rspStatusAndMessage.message andDuration:kAlertToastDuration];
            }
        }
    }];
}

#pragma mark - --------------系统代理----------------------
#pragma mark - UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.cellDataArrays.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    YYTableViewCellData *data = self.cellDataArrays[indexPath.section][indexPath.row];
    if ([data.reuseIdentifier isEqualToString:NSStringFromClass([YYInventoryRecordCell class])]) {
        YYInventoryRecordCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([YYInventoryRecordCell class])];
        [cell updateCellWithModel:data.object];
        return cell;
    }else if ([data.reuseIdentifier isEqualToString:NSStringFromClass([YYNewStyleDetailCell class])]) {
        YYNewStyleDetailCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([YYNewStyleDetailCell class])];
        if (!cell) {
            UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"OrderDetail" bundle:[NSBundle mainBundle]];
            YYCustomCellTableViewController *customCellTableViewController = [storyboard instantiateViewControllerWithIdentifier:NSStringFromClass([YYCustomCellTableViewController class])];
            cell = [customCellTableViewController.tableView dequeueReusableCellWithIdentifier:NSStringFromClass([YYNewStyleDetailCell class])];
        }
        cell.warehouseStyleModel = data.object;
        cell.hiddenTopHeader = YES;
        cell.style = self.isEXwarehouse ? YYNewStyleEXwarehousingRecord : YYNewStyleWarehousingRecord;
        [cell updateUI];
        return cell;
    }
    return nil;
}

#pragma mark - UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    YYTableViewCellData *data = self.cellDataArrays[indexPath.section][indexPath.row];
    return [data tableView:tableView heightForRowAtIndexPath:indexPath];
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section; {
    return 5;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 5;
}

- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath {
    YYTableViewCellData *data = self.cellDataArrays[indexPath.section][indexPath.row];
    return [data tableView:tableView estimatedHeightForRowAtIndexPath:indexPath];
}

#pragma mark - --------------自定义代理/block----------------------


#pragma mark - --------------自定义响应----------------------
- (void)messageButtonClicked:(id)sender {
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    [appDelegate showMessageView:nil parentViewController:self];
}

- (void)goBack {
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - --------------自定义方法----------------------
- (void)initMessageButton {
    self.messageButton = [[YYMessageButton alloc] init];
    [self.messageButton initButton:@""];
    [self messageCountChanged:nil];
    [_messageButton addTarget:self action:@selector(messageButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(messageCountChanged:) name:UnreadMsgAmountChangeNotification object:nil];
    [self.navView addSubview:self.messageButton];
    [self.messageButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(50);
        make.height.mas_equalTo(44);
        make.top.mas_equalTo(kStatusBarHeight);
        make.right.mas_equalTo(0);
    }];
}

#pragma mark - --------------自定义通知-------------------
- (void)messageCountChanged:(NSNotification *)notification{
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    [appDelegate.untreatedMsgAmountModel setUnreadMessageAmount:_messageButton];
}

#pragma mark - --------------other----------------------
- (void)buildTableViewDataSource {
    NSMutableArray *arrays = [NSMutableArray array];
    if (YES) {
        YYTableViewCellData *data = [[YYTableViewCellData alloc] init];
        data.reuseIdentifier = NSStringFromClass([YYInventoryRecordCell class]);
        data.useDynamicRowHeight = YES;
        data.object = self.recordModel;
        [arrays addObject:@[data]];
    }
    if (YES) {
        for (YYWarehouseStyleModel *style in self.response.incomingSubBos) {
            YYTableViewCellData *data = [[YYTableViewCellData alloc] init];
            data.reuseIdentifier = NSStringFromClass([YYNewStyleDetailCell class]);
            data.tableViewCellRowHeight = [YYNewStyleDetailCell CellHeight:style.sizes.count showHelpFlag:NO showTopHeader:NO showBottomFooter:NO];
            data.object = style;
            [arrays addObject:@[data]];
        }
    }
    self.cellDataArrays = [NSArray arrayWithArray:arrays];
}

@end
