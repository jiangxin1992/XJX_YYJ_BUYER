//
//  YYOrderingHistoryListViewController.m
//  YunejianBuyer
//
//  Created by yyj on 2017/6/2.
//  Copyright © 2017年 Apple. All rights reserved.
//

#import "YYOrderingHistoryListViewController.h"

#import "YYOrderingListViewController.h"

#import "UIButton+Custom.h"
#import "YYOrderingApi.h"

#import <MJRefresh.h>
#import "YYNavView.h"
#import "OrderingHistoryListCell.h"
#import "YYOrderingDetailViewController.h"
#import "MBProgressHUD.h"
#import "AppDelegate.h"
#import "YYOrderingHistoryListModel.h"

@interface YYOrderingHistoryListViewController ()<UITableViewDelegate,UITableViewDataSource,UIScrollViewDelegate>

@property (nonatomic ,strong) YYNavView *navView;
@property (strong ,nonatomic) UITableView *tableView;

@property (nonatomic,strong) NSMutableArray *dataArr;

@property (nonatomic,strong)YYPageInfoModel *currentPageInfo;
@end

@implementation YYOrderingHistoryListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self SomePrepare];
    [self UIConfig];
    
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [self loadOrderingHistoryListFromServerByPageIndex:1 endRefreshing:YES];
    [YYOrderingApi DeleteAppointmentStatusChangeMessageWithBlock:^(YYRspStatusAndMessage *rspStatusAndMessage, NSError *error) {
        if (rspStatusAndMessage.status == YYReqStatusCode100) {
            AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
            [appDelegate checkAppointmentNoticeCount];
        }
    }];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    if(_tableView){
        [self loadOrderingHistoryListFromServerByPageIndex:1 endRefreshing:YES];
    }
    // 进入埋点
    [MobClick beginLogPageView:kYYPageOrderingHistoryList];
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    // 退出埋点
    [MobClick endLogPageView:kYYPageOrderingHistoryList];
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
    
    _navView = [[YYNavView alloc] initWithTitle:NSLocalizedString(@"我的预约",nil) WithSuperView:self.view haveStatusView:YES];
    WeakSelf(ws);
    self.navView.goBackBlock = ^{
        [ws GoBack:nil];
    };
}
#pragma mark - UIConfig
-(void)UIConfig{
    [self CreateTableView];
    [self addHeader];
    [self addFooter];
}
-(void)CreateTableView
{
    _tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
    [self.view addSubview:_tableView];
    //    消除分割线
    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    _tableView.delegate = self;
    _tableView.dataSource = self;
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
        if ([YYCurrentNetworkSpace isNetwork]){
            [ws loadOrderingHistoryListFromServerByPageIndex:1 endRefreshing:YES];
        }else{
            [ws.tableView.mj_header endRefreshing];
            [YYToast showToastWithTitle:kNetworkIsOfflineTips andDuration:kAlertToastDuration];
        }
    }];
    self.tableView.mj_header = header;
    self.tableView.mj_header.automaticallyChangeAlpha = YES;
    header.lastUpdatedTimeLabel.hidden = YES;
}
- (void)addFooter
{
    WeakSelf(ws);
    // 添加上拉刷新尾部控件
    self.tableView.mj_footer = [MJRefreshBackNormalFooter footerWithRefreshingBlock:^{
        // 进入刷新状态就会回调这个Block

        if (![YYCurrentNetworkSpace isNetwork]) {
            [YYToast showToastWithTitle:kNetworkIsOfflineTips andDuration:kAlertToastDuration];
            [ws.tableView.mj_footer endRefreshing];
            return;
        }

        if( [ws.dataArr count] > 0 && ws.currentPageInfo
           && !ws.currentPageInfo.isLastPage){
            [ws loadOrderingHistoryListFromServerByPageIndex:[ws.currentPageInfo.pageIndex intValue]+1 endRefreshing:YES];
            return;
        }

        [ws.tableView.mj_footer endRefreshing];
    }];
}

#pragma mark - RequestData
- (void)loadOrderingHistoryListFromServerByPageIndex:(int)pageIndex endRefreshing:(BOOL)endrefreshing{
    
    WeakSelf(ws);
    __block BOOL blockEndrefreshing = endrefreshing;
    [YYOrderingApi getOrderingHistoryListPageIndex:pageIndex pageSize:10 andBlock:^(YYRspStatusAndMessage *rspStatusAndMessage, YYOrderingHistoryListModel *orderingListModel, NSError *error) {
        if (rspStatusAndMessage.status == YYReqStatusCode100) {
            if (pageIndex == 1) {
                [ws.dataArr removeAllObjects];
            }
            ws.currentPageInfo = orderingListModel.pageInfo;
            
            if (orderingListModel && orderingListModel.result
                && [orderingListModel.result count] > 0){
                [ws.dataArr addObjectsFromArray:orderingListModel.result];
            }
        }

        if(blockEndrefreshing){
            [self.tableView.mj_header endRefreshing];
            [self.tableView.mj_footer endRefreshing];
        }
        [ws reloadTableData];
        
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
    return 235;
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
    
    static NSString *cellid=@"OrderingHistoryListCell";
    OrderingHistoryListCell *cell=[tableView dequeueReusableCellWithIdentifier:cellid];
    if(!cell)
    {
        WeakSelf(ws);
        cell=[[OrderingHistoryListCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellid WithBlock:^(NSString *type, NSIndexPath *indexPath) {
            if([type isEqualToString:@"cancel"]){
                //取消
                [ws CancelOrderingWithIndexPath:indexPath];
            }else if([type isEqualToString:@"delete"]){
                //删除
                [ws DeleteOrderingWithIndexPath:indexPath];
            }else if([type isEqualToString:@"ordering_list"]){
                //去订货会列表
                [ws goToOrderingView];
            }
        }];
    }
    cell.selectionStyle=UITableViewCellSelectionStyleNone;
    if(_dataArr.count){
        cell.haveData = YES;
        cell.listItemModel = [_dataArr objectAtIndex:indexPath.section];
        cell.indexPath = indexPath;
    }else{
        cell.haveData = NO;
        cell.listItemModel = nil;
        cell.indexPath = nil;
    }
    return cell;
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 0.01;
}
- (nullable UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    UIView *headView = [UIView getCustomViewWithColor:[UIColor colorWithHex:@"EFEFEF"]];
    headView.frame = CGRectMake(0, 0, SCREEN_WIDTH, 0.01);
    return headView;
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
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if(_dataArr.count){
        if(_dataArr.count > indexPath.section){
            WeakSelf(ws);
            YYOrderingHistoryListItemModel *tempModel = [_dataArr objectAtIndex:indexPath.section];
//            转换成YYOrderingListItemModel 需后台加字段
            YYOrderingDetailViewController *orderingDetailView = [[YYOrderingDetailViewController alloc] init];
            YYOrderingListItemModel *itemModel = [self changeToOrderingListItemModel:tempModel];
            orderingDetailView.orderingModel = itemModel;
            [orderingDetailView setCancelButtonClicked:^(){
                [ws.navigationController popViewControllerAnimated:YES];
            }];
            [self.navigationController pushViewController:orderingDetailView animated:YES];
        }
    }
}
#pragma mark - SomeAction
-(YYOrderingListItemModel *)changeToOrderingListItemModel:(YYOrderingHistoryListItemModel *)tempModel{
    YYOrderingListItemModel *itemModel = [[YYOrderingListItemModel alloc] init];
    itemModel.id = tempModel.appointmentId;
    itemModel.coordinate = tempModel.coordinate;
    itemModel.coordinateBaidu = tempModel.coordinateBaidu;
    itemModel.address = tempModel.address;
    itemModel.poster = tempModel.poster;
    itemModel.name = tempModel.name;
    return itemModel;
}
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
//跳转到订货会列表
-(void)goToOrderingView{
    WeakSelf(ws);
    YYOrderingListViewController *orderingListViewController = [[YYOrderingListViewController alloc] init];
    [orderingListViewController setCancelButtonClicked:^(){
        [ws.navigationController popViewControllerAnimated:YES];
    }];
    [self.navigationController pushViewController:orderingListViewController animated:YES];
}
-(void)GoBack:(id)sender {
    if(_cancelButtonClicked)
    {
        _cancelButtonClicked();
    }
}
-(void)CancelOrderingWithIndexPath:(NSIndexPath *)indexPath{
    NSLog(@"cancel");
    WeakSelf(ws);
    CMAlertView *alertView = [[CMAlertView alloc] initWithTitle:NSLocalizedString(@"取消该次预约吗？",nil) message:nil needwarn:NO delegate:nil cancelButtonTitle:NSLocalizedString(@"暂不取消",nil) otherButtonTitles:@[NSLocalizedString(@"取消预约",nil)]];
    //__weak CMAlertView *_weakAlertView = alertView;
    alertView.specialParentView = self.view;
    [alertView setAlertViewBlock:^(NSInteger selectedIndex){
        if (selectedIndex == 1) {
            if(_dataArr.count>indexPath.section){
                [MBProgressHUD showHUDAddedTo:self.view animated:YES];
                YYOrderingHistoryListItemModel *itemModel = [_dataArr objectAtIndex:indexPath.section];
                [YYOrderingApi CancelOrderingWithID:(int)[itemModel.id integerValue] andBlock:^(YYRspStatusAndMessage *rspStatusAndMessage, NSError *error) {
                    if (rspStatusAndMessage.status == YYReqStatusCode100) {
                        //状态变成已取消
                        itemModel.status = @"CANCELLED";
                    }
                    
                    [ws reloadTableData];
                    
                    [MBProgressHUD hideAllHUDsForView:ws.view animated:YES];
                }];
            }
        }
    }];
    [alertView show];
}
-(void)DeleteOrderingWithIndexPath:(NSIndexPath *)indexPath{

    WeakSelf(ws);
    CMAlertView *alertView = [[CMAlertView alloc] initWithTitle:NSLocalizedString(@"删除该次预约吗？",nil) message:nil needwarn:NO delegate:nil cancelButtonTitle:NSLocalizedString(@"暂不删除",nil) otherButtonTitles:@[NSLocalizedString(@"删除预约",nil)]];
    //__weak CMAlertView *_weakAlertView = alertView;
    alertView.specialParentView = self.view;
    [alertView setAlertViewBlock:^(NSInteger selectedIndex){
        if (selectedIndex == 1) {
            if(_dataArr.count>indexPath.section){
                [MBProgressHUD showHUDAddedTo:self.view animated:YES];
                YYOrderingHistoryListItemModel *itemModel = [_dataArr objectAtIndex:indexPath.section];
                [YYOrderingApi DeleteOrderingWithID:(int)[itemModel.id integerValue] andBlock:^(YYRspStatusAndMessage *rspStatusAndMessage, NSError *error) {
                    if (rspStatusAndMessage.status == YYReqStatusCode100) {
                        //删除
                        [ws.dataArr removeObjectAtIndex:indexPath.section];
                    }
                    
                    [ws reloadTableData];
                    
                    [MBProgressHUD hideAllHUDsForView:ws.view animated:YES];
                }];
            }
        }
        
    }];
    [alertView show];
}
#pragma mark - Other

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
