//
//  YYUserSeriesCollectionViewController.m
//  YunejianBuyer
//
//  Created by yyj on 2017/7/14.
//  Copyright © 2017年 Apple. All rights reserved.
//

#import "YYUserSeriesCollectionViewController.h"

#import "YYOpusApi.h"
#import "YYUserStyleListModel.h"
#import "regular.h"
#import "SCGIFImageView.h"
#import "MBProgressHUD.h"
#import "YYUserSeriesListModel.h"
#import <MJRefresh.h>

#import "YYUserSeriesCollectionCell.h"

#define YY_TABLEVIEW_PAGESZIE 20

@interface YYUserSeriesCollectionViewController ()<UITableViewDelegate,UITableViewDataSource, MGSwipeTableCellDelegate>

@property (nonatomic,strong) UITableView *tableview;

@property (strong, nonatomic) YYPageInfoModel *currentPageInfo;
@property (nonatomic,strong) UIView *noDataView;
@property (nonatomic,strong) NSMutableArray *seriesListArray;

@property (nonatomic,assign) BOOL isFirstShow;//界面第一次出现？

@end

@implementation YYUserSeriesCollectionViewController

#pragma mark - --------------生命周期--------------
- (void)viewDidLoad {
    [super viewDidLoad];
    [self SomePrepare];
    [self UIConfig];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    if(!_isFirstShow){
        if(_tableview){
            [self loadDataByPageIndex:1];
        }
    }else{
        _isFirstShow = NO;
    }
    // 进入埋点
    [MobClick beginLogPageView:kYYPageUserSeriesCollection];
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    // 退出埋点
    [MobClick endLogPageView:kYYPageUserSeriesCollection];
}

#pragma mark - --------------SomePrepare--------------
-(void)SomePrepare
{
    [self PrepareData];
    [self PrepareUI];
}
-(void)PrepareData{
    _seriesListArray = [[NSMutableArray alloc] init];
    _isFirstShow = YES;
}

#pragma mark - --------------系统代理----------------------
#pragma mark - TableViewDelegate

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(_seriesListArray.count >0){
        return 127;
    }
    return 235;
}
-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 10.0f;
}
-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    UIView *headerview = [UIView getCustomViewWithColor:nil];
    headerview.frame = CGRectMake(0, 0, SCREEN_WIDTH, 10);
    return headerview;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if(_seriesListArray.count >0){
        return _seriesListArray.count;
    }
    return 1;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *reuseIdentifier=@"YYUserSeriesCollectionCell";
    YYUserSeriesCollectionCell *cell=[_tableview dequeueReusableCellWithIdentifier:reuseIdentifier];
    if(!cell)
    {
        cell=[[YYUserSeriesCollectionCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseIdentifier];
        cell.selectionStyle=UITableViewCellSelectionStyleNone;

        // 三方侧滑
        cell.accessoryType = UITableViewCellAccessoryNone;
        cell.delegate = self;
        cell.allowsMultipleSwipe = NO;
        cell.allowsButtonsWithDifferentWidth = YES;

        [cell setSeriesCellBlock:^(NSString *type){
            if([type isEqualToString:@"go_seriesview"]){
                if(_styleBlock){
                    _styleBlock(type,nil,nil);
                }
            }
        }];
    }

    if(_seriesListArray.count){
        YYUserSeriesModel* seriesModel = [self.seriesListArray objectAtIndex:indexPath.row];
        cell.seriesModel = seriesModel;
        cell.haveData = YES;
    }else{
        cell.seriesModel = nil;
        cell.haveData = NO;
    }

    [cell updateUI];
    return cell;
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if(_seriesListArray.count > 0){
        YYUserSeriesModel *userSeriesModel = _seriesListArray[indexPath.row];
        if(_styleBlock){
            _styleBlock(@"series_detail",userSeriesModel,indexPath);
        }
    }
}
//设置可删除
//- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath{
//    if(){
//        return YES;
//    }
//    return NO;
//}

// 自定义左滑显示编辑按钮
//-(NSArray<UITableViewRowAction*>*)tableView:(UITableView *)tableView editActionsForRowAtIndexPath:(NSIndexPath *)indexPath
//{
//    UITableViewRowAction *rowAction = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleNormal
//                                                                         title:NSLocalizedString(@"删除",nil) handler:^(UITableViewRowAction * _Nonnull action, NSIndexPath * _Nonnull indexPath) {
//
//
//                                                                         }];
//    rowAction.backgroundColor = [UIColor colorWithHex:@"EF4E31"];
//
//    NSArray *arr = @[rowAction];
//    return arr;
//}

#pragma mark - --------------自定义代理/block----------------------
#pragma mark - cell侧滑
- (NSArray<UIView *> *)swipeTableCell:(MGSwipeTableCell *)cell swipeButtonsForDirection:(MGSwipeDirection)direction swipeSettings:(MGSwipeSettings *)swipeSettings expansionSettings:(MGSwipeExpansionSettings *)expansionSettings{
    NSIndexPath *indexPath = [self.tableview indexPathForCell:cell];
    swipeSettings.offset = 11;

    NSArray * result = @[];
    // 右边显示
    if (direction == MGSwipeDirectionRightToLeft) {
        swipeSettings.transition = MGSwipeTransitionStatic;
        expansionSettings.fillOnTrigger = NO;
        // 删除按钮

        MGSwipeButton *delete = [MGSwipeButton buttonWithTitle:NSLocalizedString(@"删除", nil) backgroundColor:[UIColor redColor] callback:^BOOL(MGSwipeTableCell * sender){
            if(_seriesListArray.count > 0){
                YYUserSeriesModel *userSeriesModel = _seriesListArray[indexPath.row];
                if(_styleBlock){
                    _styleBlock(@"series_delete",userSeriesModel,indexPath);
                }
            }
            return YES;
        }];
        // 基本样式
        delete.buttonWidth = 70;
        delete.backgroundColor = [UIColor clearColor];
        delete.layer.masksToBounds = YES;
        delete.layer.cornerRadius = 5;
        [delete sizeToFit];

        // 添加一个子项，实现自定义UI
        UILabel *name = [[UILabel alloc] init];
        name.frame = CGRectMake(7, 0, delete.frame.size.width - 7, cell.frame.size.height - 7);
        name.backgroundColor = [UIColor colorWithHex:@"EF4E31"];
        name.font = [UIFont systemFontOfSize:15];
        name.text = NSLocalizedString(@"删除", nil);
        name.textAlignment = NSTextAlignmentCenter;
        name.textColor = _define_white_color;
        name.layer.masksToBounds = YES;
        name.layer.cornerRadius = 5;

        [delete addSubview:name];

        result = @[delete];
    }
    return result;
}

#pragma mark - --------------自定义响应----------------------


#pragma mark - --------------自定义方法----------------------
#pragma mark - RequestData
- (void)loadDataByPageIndex:(int)pageIndex{
    WeakSelf(ws);
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [YYOpusApi getSeriesCollectListByPageIndex:pageIndex pageSize:YY_TABLEVIEW_PAGESZIE andBlock:^(YYRspStatusAndMessage *rspStatusAndMessage, YYUserSeriesListModel *seriesListModel, NSError *error) {
        if (rspStatusAndMessage.status == YYReqStatusCode100 && seriesListModel.result
            && [seriesListModel.result count] > 0) {
            ws.currentPageInfo = seriesListModel.pageInfo;
            if (ws.currentPageInfo== nil || ws.currentPageInfo.isFirstPage) {
                [ws.seriesListArray removeAllObjects];
            }
            [ws.seriesListArray addObjectsFromArray:seriesListModel.result];
        }else{
            if(seriesListModel.result){
                if(!seriesListModel.result.count){
                    ws.currentPageInfo = seriesListModel.pageInfo;
                    if (ws.currentPageInfo== nil || ws.currentPageInfo.isFirstPage) {
                        [ws.seriesListArray removeAllObjects];
                    }
                }
            }
        }

        [MBProgressHUD hideAllHUDsForView:ws.view animated:YES];
        if (rspStatusAndMessage.status != YYReqStatusCode100) {
            [YYToast showToastWithTitle:rspStatusAndMessage.message  andDuration:kAlertToastDuration];
        }
        [ws reloadTabeleViewData];
    }];
}
#pragma mark - SomeAction
-(void)reloadTabeleViewData{
    [_tableview.mj_header endRefreshing];
    [_tableview.mj_footer endRefreshing];
    [_tableview reloadData];
}

-(void)deleteRowsAtIndexPaths:(NSIndexPath *)indexPath{
    if(_tableview){
        if(_seriesListArray && _seriesListArray.count > indexPath.row){
            [self.seriesListArray removeObjectAtIndex:indexPath.row];
            //之后再改
            if (self.seriesListArray.count == 0) {
                [self.tableview reloadData];
            } else {
                [self.tableview deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
            }
        }
    }
}

#pragma mark - --------------UI----------------------
-(void)PrepareUI{}
#pragma mark - UIConfig
-(void)UIConfig{
    [self CreateTableView];
    [self addHeader];
    [self addFooter];
}


-(void)CreateTableView{
    _tableview = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
    [self.view addSubview:_tableview];
    //    消除分割线
    _tableview.backgroundColor = [UIColor colorWithHex:@"f8f8f8"];
    _tableview.separatorStyle = UITableViewCellSeparatorStyleNone;
    _tableview.delegate = self;
    _tableview.dataSource = self;
    [_tableview mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];
}
- (void)addHeader{
    WeakSelf(ws);
    // 添加下拉刷新头部控件
    MJRefreshNormalHeader *header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        // 进入刷新状态就会回调这个Block
        if (![YYCurrentNetworkSpace isNetwork]) {
            [YYToast showToastWithTitle:kNetworkIsOfflineTips andDuration:kAlertToastDuration];
            [ws.tableview.mj_header endRefreshing];
            return;
        }
        [ws loadDataByPageIndex:1];
    }];
    self.tableview.mj_header = header;
    self.tableview.mj_header.automaticallyChangeAlpha = YES;
    header.lastUpdatedTimeLabel.hidden = YES;
    [_tableview.mj_header beginRefreshing];
}

- (void)addFooter{
    WeakSelf(ws);
    // 添加上拉刷新尾部控件
    self.tableview.mj_footer = [MJRefreshBackNormalFooter footerWithRefreshingBlock:^{
        // 进入刷新状态就会回调这个Block

        if (![YYCurrentNetworkSpace isNetwork]) {
            [YYToast showToastWithTitle:kNetworkIsOfflineTips andDuration:kAlertToastDuration];
            [ws.tableview.mj_footer endRefreshing];
            return;
        }

        if ([ws.seriesListArray count] > 0
            && ws.currentPageInfo
            && !ws.currentPageInfo.isLastPage) {
            [ws loadDataByPageIndex:[ws.currentPageInfo.pageIndex intValue]+1];
        }else{
            [ws.tableview.mj_footer endRefreshing];
        }
    }];
}

#pragma mark - --------------other----------------------
@end
