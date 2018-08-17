//
//  YYOrderingListViewController.m
//  YunejianBuyer
//
//  Created by yyj on 2017/5/31.
//  Copyright © 2017年 Apple. All rights reserved.
//

#import "YYOrderingListViewController.h"

#import "UIButton+Custom.h"
#import "YYOrderingApi.h"
#import "YYOrderingListModel.h"
#import "YYOrderingListItemModel.h"
#import "YYOrderingDetailViewController.h"

#import "AppDelegate.h"
#import "OrderingListCell.h"
#import <MJRefresh.h>
#import "YYNavView.h"
#import "MBProgressHUD.h"

@interface YYOrderingListViewController ()<UITableViewDelegate,UITableViewDataSource>

@property (nonatomic ,strong) YYNavView *navView;
@property (strong ,nonatomic) UITableView *tableView;

@property (nonatomic,strong) NSMutableArray *dataArr;

@end

@implementation YYOrderingListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self SomePrepare];
    [self UIConfig];
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [self RequestData];
    [YYOrderingApi clearAppointmentUnreadMessageWithBlock:^(YYRspStatusAndMessage *rspStatusAndMessage, NSError *error) {
        if (rspStatusAndMessage.status == kCode100) {
            //清空订货会消息成功
            AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
            [appDelegate checkNoticeCount];
        }
    }];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    // 进入埋点
    [MobClick beginLogPageView:kYYPageOrderingList];
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    // 退出埋点
    [MobClick endLogPageView:kYYPageOrderingList];
}

#pragma mark - SomePrepare
-(void)SomePrepare
{
    [self PrepareData];
    [self PrepareUI];
}
-(void)PrepareData{
    _dataArr = [[NSMutableArray alloc] init];
}
-(void)PrepareUI{
    
    self.view.backgroundColor = _define_white_color;
    
    _navView = [[YYNavView alloc] initWithTitle:NSLocalizedString(@"YCO线下订货会",nil) WithSuperView:self.view haveStatusView:YES];
    
    [_navView.titleLabel mas_updateConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(200);
    }];
    UIButton *backBtn = [UIButton getCustomImgBtnWithImageStr:@"goBack_normal" WithSelectedImageStr:nil];
    [_navView addSubview:backBtn];
    [backBtn addTarget:self action:@selector(GoBack:) forControlEvents:UIControlEventTouchUpInside];
    [backBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.mas_equalTo(0);
        make.width.mas_equalTo(40);
        make.bottom.mas_equalTo(-1);
    }];
}
#pragma mark - UIConfig
-(void)UIConfig{
    [self CreateTableView];
    [self addHeader];
}

-(void)CreateTableView
{
    _tableView=[[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
    [self.view addSubview:_tableView];
    //    消除分割线
    _tableView.separatorStyle=UITableViewCellSeparatorStyleNone;
    _tableView.delegate=self;
    _tableView.dataSource=self;
    WeakSelf(ws);
    [_tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.bottom.mas_equalTo(0);
        make.top.mas_equalTo(ws.navView.mas_bottom).with.offset(0);
    }];
}
- (void)addHeader
{
    WeakSelf(ws);
    // 添加下拉刷新头部控件
    MJRefreshNormalHeader *header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        // 进入刷新状态就会回调这个Block
        //[ws loadDataByPageIndex:1 queryStr:@""];
        if ([YYCurrentNetworkSpace isNetwork]){
            [ws RequestData];
        }else{
            [ws.tableView.mj_header endRefreshing];
            [YYToast showToastWithTitle:kNetworkIsOfflineTips andDuration:kAlertToastDuration];
        }
    }];
    self.tableView.mj_header = header;
    self.tableView.mj_header.automaticallyChangeAlpha = YES;
    header.lastUpdatedTimeLabel.hidden = YES;
}
#pragma mark - RequestData
-(void)RequestData{
    WeakSelf(ws);
    [YYOrderingApi getOrderingListandBlock:^(YYRspStatusAndMessage *rspStatusAndMessage, YYOrderingListModel *listModel, NSError *error) {
        if(rspStatusAndMessage.status == kCode100){
            [ws.dataArr removeAllObjects];
            [ws.dataArr addObjectsFromArray:listModel.result];

            [ws reloadTableData];
            [ws.tableView.mj_header endRefreshing];
        }else{
            [YYToast showToastWithTitle:rspStatusAndMessage.message andDuration:kAlertToastDuration];
            [ws.tableView.mj_header endRefreshing];
        }
        [MBProgressHUD hideAllHUDsForView:ws.view animated:YES];
    }];
}
#pragma mark - UIScrollViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    //    //headerView
    //    if (scrollView == _tableView) {
    //        //去掉UItableview的section的headerview黏性
    //        CGFloat sectionHeaderHeight = 36;
    //        if (scrollView.contentOffset.y<=sectionHeaderHeight && scrollView.contentOffset.y>=0) {
    //            scrollView.contentInset = UIEdgeInsetsMake(-scrollView.contentOffset.y, 0, 0, 0);
    //        } else if (scrollView.contentOffset.y>=sectionHeaderHeight) {
    //            scrollView.contentInset = UIEdgeInsetsMake(-sectionHeaderHeight, 0, 0, 0);
    //        }
    //    }
    
    //footerView
    if (scrollView == _tableView) {
        if(_dataArr.count){
            //去掉UItableview的section的footerview黏性
            [self reloadStickFooterView];
        }
    }
}
#pragma mark - TableViewDelegate

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 289;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if(_dataArr.count >0){
        return _dataArr.count;
    }
    return 1;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    static NSString *cellid=@"OrderingListCell";
    OrderingListCell *cell=[tableView dequeueReusableCellWithIdentifier:cellid];
    if(!cell)
    {
        cell=[[OrderingListCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellid];
    }
    cell.selectionStyle=UITableViewCellSelectionStyleNone;
    cell.cellType = EOrderingListCellTypeList;
    if(_dataArr.count){
        cell.haveData = YES;
        cell.listItemModel = [_dataArr objectAtIndex:indexPath.section];
    }else{
        cell.haveData = NO;
        cell.listItemModel = nil;
    }
    return cell;
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if(_dataArr.count){
        if(_dataArr.count > indexPath.section){
            WeakSelf(ws);
            YYOrderingListItemModel *tempModel = [_dataArr objectAtIndex:indexPath.section];
            YYOrderingDetailViewController *orderingDetailView = [[YYOrderingDetailViewController alloc] init];
            orderingDetailView.orderingModel = tempModel;
            [orderingDetailView setCancelButtonClicked:^(){
                [ws.navigationController popViewControllerAnimated:YES];
            }];
            [self.navigationController pushViewController:orderingDetailView animated:YES];
        }
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    if(_dataArr.count){
        return 10;
    }
    return 0.01;
}
//section底部视图
- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    UIView *footview = [UIView getCustomViewWithColor:[UIColor colorWithHex:@"EFEFEF"]];
    footview.frame = CGRectMake(0, 0, SCREEN_WIDTH, _dataArr.count?10:0.01);
    return footview;
}
#pragma mark - SomeAction
-(void)reloadTableData{
    [self reloadStickFooterView];
    [self.tableView reloadData];
}
-(void)reloadStickFooterView{
    if(_dataArr.count){
        //去掉UItableview的section的footerview黏性
        CGFloat sectionFooterHeight = 10;
        if (_tableView.contentOffset.y<=sectionFooterHeight && _tableView.contentOffset.y>=0) {
            _tableView.contentInset = UIEdgeInsetsMake(0, 0, -sectionFooterHeight, 0);
        } else if (_tableView.contentOffset.y>=sectionFooterHeight) {
            _tableView.contentInset = UIEdgeInsetsMake(0, 0, -sectionFooterHeight, 0);
        }
    }
}

-(void)GoBack:(id)sender {
    if(_cancelButtonClicked)
    {
        _cancelButtonClicked();
    }
}
#pragma mark - Other

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
