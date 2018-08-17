//
//  YYUserStyleCollectionViewController.m
//  YunejianBuyer
//
//  Created by yyj on 2017/7/14.
//  Copyright © 2017年 Apple. All rights reserved.
//

#import "YYUserStyleCollectionViewController.h"

#import "YYOpusApi.h"
#import "YYUserStyleListModel.h"
#import "regular.h"
#import "SCGIFImageView.h"
#import "MBProgressHUD.h"
#import <MJRefresh.h>

#import "YYUserStyleCollectionCell.h"
#import "YYChooseStyleViewController.h"

#define YY_TABLEVIEW_PAGESZIE 20

@interface YYUserStyleCollectionViewController ()<UITableViewDelegate,UITableViewDataSource, MGSwipeTableCellDelegate>

@property (nonatomic,strong) UITableView *tableview;

@property (strong, nonatomic) YYPageInfoModel *currentPageInfo;
@property (nonatomic,strong) UIView *noDataView;
@property (nonatomic,strong) NSMutableArray *styleListArray;

@property (nonatomic,assign) BOOL isFirstShow;//界面第一次出现？

@end

@implementation YYUserStyleCollectionViewController


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
    [MobClick beginLogPageView:kYYPageUserStyleCollection];
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    // 退出埋点
    [MobClick endLogPageView:kYYPageUserStyleCollection];
}

#pragma mark - --------------SomePrepare--------------
-(void)SomePrepare
{
    [self PrepareData];
    [self PrepareUI];
}
-(void)PrepareData{
    _styleListArray = [[NSMutableArray alloc] init];
    _isFirstShow = YES;
}
#pragma mark - --------------系统代理----------------------
#pragma mark - TableViewDelegate

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(_styleListArray.count >0){
        return 107;
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
    if(_styleListArray.count >0){
        return _styleListArray.count;
    }
    return 1;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *reuseIdentifier=@"YYUserStyleCollectionCell";
    YYUserStyleCollectionCell *cell=[_tableview dequeueReusableCellWithIdentifier:reuseIdentifier];
    if(!cell)
    {
        cell=[[YYUserStyleCollectionCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseIdentifier];
        cell.selectionStyle=UITableViewCellSelectionStyleNone;

        [cell setStyleCellBlock:^(NSString *type){
            if([type isEqualToString:@"go_styleview"]){
                if(_styleBlock){
                    _styleBlock(type,nil,nil);
                }
            }
        }];

        // 三方侧滑
        cell.accessoryType = UITableViewCellAccessoryNone;
        cell.delegate = self;
        cell.allowsMultipleSwipe = NO;
        cell.allowsButtonsWithDifferentWidth = YES;

    }

    if(_styleListArray.count){
        YYUserStyleModel* styleModel = [self.styleListArray objectAtIndex:indexPath.row];
        cell.styleModel = styleModel;
        cell.haveData = YES;
    }else{
        cell.styleModel = nil;
        cell.haveData = NO;
    }
    [cell updateUI];
    return cell;
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if(_styleListArray.count > 0){
        YYUserStyleModel *userStyleModel = _styleListArray[indexPath.row];
        if(_styleBlock){
            _styleBlock(@"style_detail",userStyleModel,indexPath);
        }
    }
}

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
            if(_styleListArray.count > 0){
                YYUserStyleModel *userStyleModel = _styleListArray[indexPath.row];
                if(_styleBlock){
                    _styleBlock(@"style_delete",userStyleModel,indexPath);
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
    [YYOpusApi getStyleCollectListByPageIndex:pageIndex pageSize:YY_TABLEVIEW_PAGESZIE andBlock:^(YYRspStatusAndMessage *rspStatusAndMessage, YYUserStyleListModel *styleListModel, NSError *error) {
        if (rspStatusAndMessage.status == YYReqStatusCode100 && styleListModel.result
            && [styleListModel.result count] > 0) {
            ws.currentPageInfo = styleListModel.pageInfo;
            if (ws.currentPageInfo== nil || ws.currentPageInfo.isFirstPage) {
                [ws.styleListArray removeAllObjects];
            }
            [ws.styleListArray addObjectsFromArray:styleListModel.result];
        }else{
            if(styleListModel.result){
                if(!styleListModel.result.count){
                    ws.currentPageInfo = styleListModel.pageInfo;
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
        if(_styleListArray && _styleListArray.count > indexPath.row){
            [self.styleListArray removeObjectAtIndex:indexPath.row];
            //之后再改
            if (self.styleListArray.count == 0) {
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

- (void)addHeader
{
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

- (void)addFooter
{
    WeakSelf(ws);
    // 添加上拉刷新尾部控件
    self.tableview.mj_footer = [MJRefreshBackNormalFooter footerWithRefreshingBlock:^{
        // 进入刷新状态就会回调这个Block

        if (![YYCurrentNetworkSpace isNetwork]) {
            [YYToast showToastWithTitle:kNetworkIsOfflineTips andDuration:kAlertToastDuration];
            [ws.tableview.mj_footer endRefreshing];
            return;
        }
        if ([ws.styleListArray count] > 0
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
