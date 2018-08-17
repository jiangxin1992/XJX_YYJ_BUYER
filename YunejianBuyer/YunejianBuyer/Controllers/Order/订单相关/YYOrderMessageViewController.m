//
//  YYOrderMessageViewController.m
//  Yunejian
//
//  Created by Apple on 15/10/26.
//  Copyright © 2015年 yyj. All rights reserved.
//

#import "YYOrderMessageViewController.h"

// c文件 —> 系统文件（c文件在前）

// 控制器
#import "YYOrderDetailViewController.h"

// 自定义视图
#import "YYNavView.h"
#import "MBProgressHUD.h"
#import "YYOrderMessageViewCell.h"

// 接口
#import "YYOrderApi.h"

// 分类

// 自定义类和三方类（ cocoapods类 > model > 工具类 > 其他）
#import <MJRefresh.h>

#import "YYOrderInfoModel.h"
#import "YYOrderTransStatusModel.h"
#import "YYOrderMessageInfoModel.h"
#import "YYOrderMessageInfoListModel.h"
#import "YYUntreatedMsgAmountModel.h"

#import "AppDelegate.h"
#import "YYRspStatusAndMessage.h"

@interface YYOrderMessageViewController ()<UITableViewDataSource,UITableViewDelegate,YYTableCellDelegate>

@property (weak, nonatomic) IBOutlet UIView *containerView;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, strong) YYNavView *navView;
@property (nonatomic, strong) YYPageInfoModel *currentPageInfo;
@property (strong, nonatomic) NSMutableArray *msgListArray;
@property (strong, nonatomic) NSMutableArray *msgGroupTitleArray;
@property (strong, nonatomic) NSMutableArray *msgGroupDataArray;

@property (nonatomic, strong) UIView *noDataView;

@end

@implementation YYOrderMessageViewController
#pragma mark - --------------生命周期--------------
- (void)viewDidLoad {
    [super viewDidLoad];
    [self SomePrepare];
    [self UIConfig];
    [self RequestData];
}
- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    // 进入埋点
    [MobClick beginLogPageView:kYYPageOrderMessage];
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    // 退出埋点
    [MobClick endLogPageView:kYYPageOrderMessage];
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
- (void)PrepareData{}
- (void)PrepareUI{
    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;

    [self addHeader];
    [self addFooter];
}

#pragma mark - --------------UIConfig----------------------
-(void)UIConfig{
    [self CreateNavView];
    [self CreateNoDataView];
}
-(void)CreateNavView{
    self.navView = [[YYNavView alloc] initWithTitle:NSLocalizedString(@"订单消息",nil) WithSuperView:self.view haveStatusView:YES];
    WeakSelf(ws);
    self.navView.goBackBlock = ^{
        [ws goBack];
    };
}
-(void)CreateNoDataView{
    self.noDataView = addNoDataView_phone(self.view,[NSString stringWithFormat:@"%@|icon:nomsg_icon",NSLocalizedString(@"暂无订单消息",nil)],nil,nil);
    _noDataView.hidden = YES;
}
#pragma mark - --------------请求数据----------------------
-(void)RequestData{
    [self loadMsgListWithpageIndex:1];
}

#pragma mark - --------------系统代理----------------------
#pragma mark -UITableViewDelegate
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;//[_msgGroupTitleArray count];
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [_msgListArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{

    YYOrderMessageInfoModel *infoModel = [_msgListArray objectAtIndex:indexPath.row];
    static NSString* reuseIdentifier = @"YYOrderMessageViewCell";
    YYOrderMessageViewCell *cell = [tableView dequeueReusableCellWithIdentifier:reuseIdentifier forIndexPath:indexPath];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.msgInfoModel = infoModel;
    cell.delegate = self;
    [cell updateUI];
    return cell;
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{

    YYOrderMessageInfoModel* _msgInfoModel = [_msgListArray objectAtIndex:indexPath.row];

    CGFloat cellHeight = 160.0f;

    BOOL btnIsHide = YES;
    CGFloat orderRejectedReasonHeight = 0.0f;

    if(_msgInfoModel.msgContent && ![NSString isNilOrEmpty:_msgInfoModel.msgContent.op]){
        if([_msgInfoModel.msgContent.op isEqualToString:@"need_confirm"]){
            if([_msgInfoModel.dealStatus integerValue] == -1){
                if(_msgInfoModel.orderTransStatus && [_msgInfoModel.orderTransStatus integerValue] != 4){
                    //双方都已确认
                    btnIsHide = YES;
                }else{
                    //我待确认(对方已确认)
                    btnIsHide = NO;
                }
            }else if([_msgInfoModel.dealStatus integerValue] == 1){
                //我已确认
                btnIsHide = YES;
            }else if([_msgInfoModel.dealStatus integerValue] == 2){
                //我已拒绝
                btnIsHide = YES;
            }
        }else if([_msgInfoModel.msgContent.op isEqualToString:@"order_rejected"]){
            //对方已拒绝
            btnIsHide = YES;
            if(![NSString isNilOrEmpty:_msgInfoModel.msgContent.reason]){
                NSString *reason = [[NSString alloc] initWithFormat:@"拒绝理由：%@",_msgInfoModel.msgContent.reason];
                orderRejectedReasonHeight = getHeightWithWidth(SCREEN_WIDTH - 17 * 2, reason, [UIFont systemFontOfSize:12.0f]);
            }
        }else if([_msgInfoModel.msgContent.op isEqualToString:@"force_delivery"]){
            //提前结束
            btnIsHide = YES;
            cellHeight = 136.f;
        }
    }else{
        if(_msgInfoModel.isPlainMsg == NO){
            if([_msgInfoModel.dealStatus integerValue] == -1){
                btnIsHide = NO;
            }else{
                btnIsHide = YES;
            }
        }else{
            btnIsHide = YES;
        }
    }

    if(!btnIsHide){
        cellHeight += 30;
    }

    if(orderRejectedReasonHeight > 0){
        cellHeight += orderRejectedReasonHeight + 10;
    }
    return cellHeight;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{

    WeakSelf(ws);

    YYOrderMessageInfoModel *infoModel = [_msgListArray objectAtIndex:indexPath.row];

    if(!infoModel.msgContent){
        return;
    }

    NSString *orderCode = infoModel.msgContent.orderCode;
    __block YYOrderMessageInfoModel *blockInfoModel = infoModel;
    [YYOrderApi getOrderTransStatus:orderCode andBlock:^(YYRspStatusAndMessage *rspStatusAndMessage, YYOrderTransStatusModel *transStatusModel, NSError *error) {
        if(rspStatusAndMessage.status == YYReqStatusCode100){

            NSInteger transStatus = getOrderTransStatus(transStatusModel.designerTransStatus, transStatusModel.buyerTransStatus);

            if (transStatusModel == nil || transStatus == YYOrderCode_DELETED) {
                [YYToast showToastWithView:self.view title:NSLocalizedString(@"此订单已被删除",nil) andDuration:kAlertToastDuration];//“
                return ;
            }

            if(![NSString isNilOrEmpty:blockInfoModel.msgContent.op]){
                BOOL canGoToOrderDetailView = NO;
                if([blockInfoModel.msgContent.op isEqualToString:@"need_confirm"]){
                    if([blockInfoModel.dealStatus integerValue] == -1){
                        if(blockInfoModel.orderTransStatus && [blockInfoModel.orderTransStatus integerValue] != 4){
                            //双方都已确认
                            canGoToOrderDetailView = YES;
                        }else{
                            //我待确认(对方已确认)
                            canGoToOrderDetailView = YES;
                        }
                    }else if([blockInfoModel.dealStatus integerValue] == 1){
                        //我已确认
                        canGoToOrderDetailView = YES;
                    }if([blockInfoModel.dealStatus integerValue] == 2){
                        //我已拒绝
                        canGoToOrderDetailView = YES;
                    }
                }else if([blockInfoModel.msgContent.op isEqualToString:@"order_rejected"]){
                    //对方已拒绝
                    canGoToOrderDetailView = YES;
                }else if([blockInfoModel.msgContent.op isEqualToString:@"force_delivery"]){
                    //提前结束
                    canGoToOrderDetailView = YES;
                }

                if(canGoToOrderDetailView){
                    [ws gotoOrderDetailView:blockInfoModel orderConnStatus:YYOrderConnStatusUnknow];
                }
            }else{
                [ws pushOrderDetailWithOrderInfo:blockInfoModel];
            }
        }
    }];
}
#pragma mark - --------------自定义代理/block----------------------
#pragma mark -YYTableCellDelegate
-(void)btnClick:(NSInteger)row section:(NSInteger)section andParmas:(NSArray *)parmas{
    NSString *type = [parmas objectAtIndex:0];
    if([type isEqualToString:@"refresh"]){
        [self loadMsgListWithpageIndex:1];
    }else if([type isEqualToString:@"reload"]){
        [_tableView reloadData];
    }
}


#pragma mark - --------------自定义响应----------------------
- (void)goBack {
    if(self.markAsReadHandler){
        self.markAsReadHandler();
    }
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - --------------自定义方法----------------------
-(void)pushOrderDetailWithOrderInfo:(YYOrderMessageInfoModel *)infoModel{
    if(infoModel.isPlainMsg == NO){
        //非普通消息
        if([infoModel.dealStatus integerValue] == 1 && infoModel.msgContent){
            [self gotoOrderDetailView:infoModel orderConnStatus:YYOrderConnStatusLinked];
        }else{
            [YYToast showToastWithView:self.view title:NSLocalizedString(@"对不起，您没有权限查看订单",nil) andDuration:kAlertToastDuration];//“
        }
    }else{
        //普通消息
        [self gotoOrderDetailView:infoModel orderConnStatus:YYOrderConnStatusLinked];
    }
}
-(void)gotoOrderDetailView:(YYOrderMessageInfoModel *)infoModel orderConnStatus:(NSInteger)orderConnStatus{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"OrderDetail" bundle:[NSBundle mainBundle]];
    YYOrderDetailViewController *orderDetailViewController = [storyboard instantiateViewControllerWithIdentifier:@"YYOrderDetailViewController"];
    orderDetailViewController.currentOrderCode = infoModel.msgContent.orderCode;
    orderDetailViewController.currentOrderLogo =  infoModel.msgContent.designerBrandLogo;
    orderDetailViewController.currentOrderConnStatus = orderConnStatus;
    if(!infoModel.isRead && [infoModel.msgContent.op isEqualToString:@"force_delivery"]){
        orderDetailViewController.isNeedShowOrderChange = YES;
    }
    orderDetailViewController.currentOrderConnStatus = YYOrderConnStatusUnknow;
    [self.navigationController pushViewController:orderDetailViewController animated:YES];
}
-(void)setMsgListGroupArray{
    _msgGroupTitleArray = [[NSMutableArray alloc] init];
    _msgGroupDataArray = [[NSMutableArray alloc] init];
    double dateTimer = 0;
    for (YYOrderMessageInfoModel *infoModel in self.msgListArray) {
        dateTimer = floor([infoModel.sendTime doubleValue]/86400000);
        dateTimer = dateTimer*86400000;
        NSString *key = [NSString stringWithFormat:@"%f",dateTimer];
        if(![_msgGroupTitleArray containsObject:key]){
            [_msgGroupTitleArray addObject:key];
        }
        NSInteger index = [_msgGroupTitleArray indexOfObject:key];
        if(index >= [_msgGroupDataArray count]){
            _msgGroupDataArray[index] = [[NSMutableArray alloc] init];
        }
        [_msgGroupDataArray[index] addObject:infoModel];

    }
    if([self.msgListArray count]){
        _noDataView.hidden = YES;
        _tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    }else{
        _noDataView.hidden = NO;
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    }
}

//请求买手地址列表
-(void)loadMsgListWithpageIndex:(NSInteger)pageIndex{
    WeakSelf(ws);
    NSString *type = @"1";

    NSInteger pageSize = 10;

    [MBProgressHUD showHUDAddedTo:self.view animated:YES];

    [YYOrderApi getNotifyMsgList:type pageIndex:pageIndex pageSize:pageSize andBlock:^(YYRspStatusAndMessage *rspStatusAndMessage, YYOrderMessageInfoListModel *msgListModel, NSError *error) {
        if(rspStatusAndMessage.status == YYReqStatusCode100){
            ws.currentPageInfo = msgListModel.pageInfo;
            if(ws.currentPageInfo.isFirstPage){
                ws.msgListArray =  [[NSMutableArray alloc] init];//;
            }
            [ws.msgListArray addObjectsFromArray:msgListModel.result];
            //[ws setMsgListGroupArray];
            if([ws.msgListArray count]){
                ws.noDataView.hidden = YES;
            }else{
                ws.noDataView.hidden = NO;
            }
            dispatch_async(dispatch_get_main_queue(), ^{
                [ws.tableView reloadData];
            });
        }
        [ws.tableView.mj_header endRefreshing];
        [ws.tableView.mj_footer endRefreshing];
        [MBProgressHUD hideAllHUDsForView:self.view animated:YES];

    }];

}

+(void)markAsRead{
    [YYOrderApi markAsRead:1 andBlock:^(YYRspStatusAndMessage *rspStatusAndMessage, NSError *error) {

    }];
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    if(appDelegate.untreatedMsgAmountModel.unreadOrderNotifyMsgAmount > 0){
        appDelegate.untreatedMsgAmountModel.unreadOrderNotifyMsgAmount = 0;
        [[NSNotificationCenter defaultCenter] postNotificationName:UnreadMsgAmountChangeNotification object:nil userInfo:nil];
    }
}
- (void)addHeader{
    WeakSelf(ws);
    // 添加下拉刷新头部控件
    MJRefreshNormalHeader *header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        // 进入刷新状态就会回调这个Block
        [ws loadMsgListWithpageIndex:1];
    }];
    self.tableView.mj_header = header;
    self.tableView.mj_header.automaticallyChangeAlpha = YES;
    header.lastUpdatedTimeLabel.hidden = YES;
}


- (void)addFooter{
    WeakSelf(ws);
    // 添加上拉刷新尾部控件
    self.tableView.mj_footer = [MJRefreshBackNormalFooter footerWithRefreshingBlock:^{
        // 进入刷新状态就会回调这个Block

        if (![YYCurrentNetworkSpace isNetwork]) {
            //[YYToast showToastWithTitle:kNetworkIsOfflineTips andDuration:kAlertToastDuration];
            [ws.tableView.mj_footer endRefreshing];
            return;
        }

        if ([ws.msgListArray count] > 0
            && ws.currentPageInfo
            && !ws.currentPageInfo.isLastPage) {
            [ws loadMsgListWithpageIndex:[ws.currentPageInfo.pageIndex intValue]+1];
        }else{
            [ws.tableView.mj_footer endRefreshing];
        }
    }];
}
#pragma mark - --------------other----------------------


@end
