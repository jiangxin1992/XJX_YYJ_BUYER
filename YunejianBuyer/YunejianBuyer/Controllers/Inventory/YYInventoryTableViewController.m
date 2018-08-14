//
//  YYInventoryTableViewController.m
//  YunejianBuyer
//
//  Created by Apple on 16/8/29.
//  Copyright © 2016年 Apple. All rights reserved.
//

#import "YYInventoryTableViewController.h"

#import "YYInventoryApi.h"
#import "MBProgressHUD.h"
#import <MJRefresh.h>
#import "YYInventoryNewTipViewCell.h"
#import "YYInventoryApi.h"
#import "YYInventoryBoardViewCell.h"
#import "YYInventoryLineCell.h"
#import "YYInventoryStyleListViewCell.h"
#import "AppDelegate.h"
#import "YYUser.h"

@interface YYInventoryTableViewController ()<UITableViewDataSource,UITableViewDelegate,YYTableCellDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic,strong)YYPageInfoModel *currentPageInfo;
@property (strong, nonatomic)NSMutableArray *listArray;
@property (nonatomic,copy) NSString *searchFieldStr;
@property (nonatomic,weak) UIView *noDataView;

@property (strong, nonatomic)NSMutableArray *editRowArray;

@end

@implementation YYInventoryTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.listArray = [[NSMutableArray alloc] initWithCapacity:0];
    self.editRowArray = [[NSMutableArray alloc] initWithCapacity:0];

    [self.tableView registerNib:[UINib nibWithNibName:@"YYInventoryBoardViewCell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:@"YYInventoryBoardViewCell"];
    [self.tableView registerNib:[UINib nibWithNibName:@"YYInventoryStyleListViewCell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:@"YYInventoryStyleListViewCell"];
    [self.tableView registerNib:[UINib nibWithNibName:@"YYInventoryLineCell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:@"YYInventoryLineCell"];

    [self addHeader];
    [self addFooter];

    _searchFieldStr = @"";
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    [appDelegate checkNoticeCount];
    [[YYUser currentUser] updateUserCheckStatus];
    [appDelegate checkAppointmentNoticeCount];
    [self loadListFromServerByPageIndex:1 endRefreshing:NO];
    
}

-(void)relaodTableData:(BOOL)newData{
    if(self.currentPageInfo != nil){
        if(newData){
            [MBProgressHUD showHUDAddedTo:self.view animated:YES];
            [self loadListFromServerByPageIndex:1 endRefreshing:NO];
        }else{
            [self.tableView reloadData];
        }
    }
}

- (void)loadListFromServerByPageIndex:(int)pageIndex endRefreshing:(BOOL)endrefreshing{
    WeakSelf(ws);

    if (![YYCurrentNetworkSpace isNetwork]) {
        [_listArray removeAllObjects];

        if(endrefreshing){
            [self.tableView.mj_header endRefreshing];
            [self.tableView.mj_footer endRefreshing];
        }
        [ws reloadTableData];
        [MBProgressHUD hideHUDForView:ws.view animated:YES];
        return;
    }
    __block BOOL blockEndrefreshing = endrefreshing;
    if(_currentType == 0){
        [YYInventoryApi getBoardList:nil month:3 pageIndex:pageIndex pageSize:8 queryStr:nil adnBlock:^(YYRspStatusAndMessage *rspStatusAndMessage, YYInventoryBoardListModel *boardsModel, NSError *error) {
            if (rspStatusAndMessage.status == kCode100) {
                if(pageIndex == 1) {
                    [ws.listArray removeAllObjects];
                }
                ws.currentPageInfo = boardsModel.pageInfo;
            
                if (boardsModel && boardsModel.result
                    && [boardsModel.result count] > 0){
                    [ws.listArray addObjectsFromArray:boardsModel.result];
            
                 }
             }
            
            if(blockEndrefreshing){
                [self.tableView.mj_header endRefreshing];
                [self.tableView.mj_footer endRefreshing];
            }
            [ws reloadTableData];
            //
            [MBProgressHUD hideHUDForView:ws.view animated:YES];

        }];
    }else if(_currentType == 1){
        [YYInventoryApi getDemandList:nil month:0 pageIndex:pageIndex pageSize:8 queryStr:nil adnBlock:^(YYRspStatusAndMessage *rspStatusAndMessage, YYInventoryStyleListModel *listModel, NSError *error) {
            if (rspStatusAndMessage.status == kCode100) {
                if(pageIndex == 1) {
                    [ws.listArray removeAllObjects];
                }
                ws.currentPageInfo = listModel.pageInfo;
                
                if (listModel && listModel.result
                    && [listModel.result count] > 0){
                    [ws.listArray addObjectsFromArray:listModel.result];
                    
                }
            }
            
            if(blockEndrefreshing){
                [self.tableView.mj_header endRefreshing];
                [self.tableView.mj_footer endRefreshing];
            }
            [ws reloadTableData];
            //
            [MBProgressHUD hideHUDForView:ws.view animated:YES];
        }];
    }else if(_currentType == 2){
        [YYInventoryApi getStoreList:nil month:0 pageIndex:pageIndex pageSize:8 queryStr:nil adnBlock:^(YYRspStatusAndMessage *rspStatusAndMessage, YYInventoryStyleListModel *listModel, NSError *error) {
            if (rspStatusAndMessage.status == kCode100) {
                if(pageIndex == 1) {
                    [ws.listArray removeAllObjects];
                }
                ws.currentPageInfo = listModel.pageInfo;
                
                if (listModel && listModel.result
                    && [listModel.result count] > 0){
                    [ws.listArray addObjectsFromArray:listModel.result];
                    
                }
            }
            
            if(blockEndrefreshing){
                [self.tableView.mj_header endRefreshing];
                [self.tableView.mj_footer endRefreshing];
            }
            [ws reloadTableData];
            //
            [MBProgressHUD hideHUDForView:ws.view animated:YES];
        }];
    }else{
        
        if(blockEndrefreshing){
            [self.tableView.mj_header endRefreshing];
            [self.tableView.mj_footer endRefreshing];
        }
        [ws reloadTableData];

        [MBProgressHUD hideHUDForView:ws.view animated:YES];

    }
}

-(void)reloadTableData{
    [self.tableView reloadData];
}

- (void)addHeader
{
    WeakSelf(ws);
    MJRefreshNormalHeader *header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        if (![YYCurrentNetworkSpace isNetwork]) {
            [YYToast showToastWithTitle:kNetworkIsOfflineTips andDuration:kAlertToastDuration];
            [ws.tableView.mj_header endRefreshing];
            return;
        }else{
            AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
            [appDelegate checkNoticeCount];
            [[YYUser currentUser] updateUserCheckStatus];
            [appDelegate checkAppointmentNoticeCount];
        }
        [ws loadListFromServerByPageIndex:1 endRefreshing:YES];
    }];
    self.tableView.mj_header = header;
    self.tableView.mj_header.automaticallyChangeAlpha = YES;
    header.lastUpdatedTimeLabel.hidden = YES;
}

- (void)addFooter{
    WeakSelf(ws);
    self.tableView.mj_footer = [MJRefreshBackNormalFooter footerWithRefreshingBlock:^{
        if (![YYCurrentNetworkSpace isNetwork]) {
            [YYToast showToastWithTitle:kNetworkIsOfflineTips andDuration:kAlertToastDuration];
            [ws.tableView.mj_footer endRefreshing];
            return;
        }
        if (!ws.currentPageInfo.isLastPage) {
            [ws loadListFromServerByPageIndex:[self.currentPageInfo.pageIndex intValue]+1 endRefreshing:YES];
        }else{
            //弹出提示
            [ws.tableView.mj_footer endRefreshing];
        }
    }];
}

#pragma mark - UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if(section == 0){
        return 1;
    }
    if([_listArray count] > 0){
        return [_listArray count]*2;
    }else{
        return 1;
    }
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    if(indexPath.section == 0){
        NSString *CellIdentifier = @"YYInventoryNewTipViewCell";
        YYInventoryNewTipViewCell *cell = [tableView  dequeueReusableCellWithIdentifier:CellIdentifier];
        cell.indexPath = indexPath;
        cell.delegate = self;
        cell.currentType = _currentType;
        [cell updateUI];
        return cell;
    }else{
        if([_listArray count] > 0){
            if(indexPath.row%2 == 1){
                YYInventoryLineCell *cell = [tableView dequeueReusableCellWithIdentifier:@"YYInventoryLineCell"];
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
                return cell;
            }
            
            if(_currentType == 0){
                YYInventoryBoardModel *boardModel = [_listArray objectAtIndex:indexPath.row/2];
                YYInventoryBoardViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"YYInventoryBoardViewCell"];
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
                cell.boardModel = boardModel;
                cell.delegate = self;
                cell.indexPath = indexPath;
                [cell updateUI];
                return cell;
            }else{
                YYInventoryStyleDetailModel *styleModel= [_listArray objectAtIndex:indexPath.row/2];
                YYInventoryStyleListViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"YYInventoryStyleListViewCell"];
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
                cell.styleModel = styleModel;
                NSString *key = [NSString stringWithFormat:@"%d_%ld",self.currentType,indexPath.row];
                if([self.editRowArray containsObject:key]){
                    cell.isModifyNow = YES;
                }else{
                    cell.isModifyNow = NO;
                }
                cell.delegate = self;
                cell.indexPath = indexPath;
                [cell updateUI];
                return cell;
            }
            
        }else{
            static NSString* reuseIdentifier = @"YYInventoryViewNullCell";
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:reuseIdentifier forIndexPath:indexPath];
            UIButton *tipBtn = [cell.contentView viewWithTag:10001];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            if(self.noDataView == nil){
            if(_currentType == 0){
                self.noDataView = addNoDataView_phone(cell.contentView,[NSString stringWithFormat:@"%@|icon:noinventory_icon|60",NSLocalizedString(@"暂无补货公告/n库存调拨可以让商品在不同的买手店之间流动起来~",nil) ],nil,nil);
                tipBtn.hidden = NO;
                NSString *textStr = tipBtn.currentTitle;
                NSRange range = [textStr rangeOfString:NSLocalizedString(@"我要补货",nil)];
                NSMutableAttributedString *attributedStr = [[NSMutableAttributedString alloc] initWithString: textStr];
                [attributedStr addAttribute: NSForegroundColorAttributeName value: [UIColor colorWithHex:@"47a3dc"] range:range];
                [tipBtn setAttributedTitle:attributedStr forState:UIControlStateNormal];
                
                [tipBtn addTarget:self action:@selector(showInventory) forControlEvents:UIControlEventTouchUpInside];
            }else if(_currentType == 1){
                self.noDataView = addNoDataView_phone(cell.contentView,[NSString stringWithFormat:@"%@|icon:noinventory_icon|60",NSLocalizedString(@"还没有提交补货需求/n提交补货需求，能让设计师及时为您调解库存的流动~",nil)],nil,nil);
                tipBtn.hidden = YES;
            }else if(_currentType == 2){
                self.noDataView = addNoDataView_phone(cell.contentView,[NSString stringWithFormat:@"%@|icon:noinventory_icon|60",NSLocalizedString(@"还没有提交补货需求/n提交补货需求，能让设计师及时为您调解库存的流动~",nil)],nil,nil);
                tipBtn.hidden = YES;
            }
            }
            cell.backgroundColor = [UIColor clearColor];
            return cell;
        }
    }

}


#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if(indexPath.section == 0){
        return 61;
    }
    if([_listArray count] > 0){
        if(indexPath.row%2 == 1){
            if((indexPath.row+1) == [_listArray count]*2){
                return 1;
            }
            return 11;
        }
        if(_currentType == 0){
            YYInventoryBoardModel *boardModel = [_listArray objectAtIndex:indexPath.row/2];
            return [YYInventoryBoardViewCell cellHeigh:[boardModel.sizes count]];
        }
        return 196;
    }else{
        return SCREEN_HEIGHT-65-58-61;
    }
    
}



- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
//    NSObject *obj = [_listArray objectAtIndex:indexPath.row];
//    if(self.delegate && obj){
//        [self.delegate btnClick:indexPath.row section:indexPath.section andParmas:@[@"orderDetail",obj]];
//    }
}

-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath{
}



#pragma YYTableCellDelegate
-(void)btnClick:(NSInteger)row section:(NSInteger)section andParmas:(NSArray *)parmas{
    NSString *type = [parmas objectAtIndex:0];
    if(section == 0){
        if(self.delegate && type){
            [self.delegate btnClick:row section:section andParmas:@[type]];
        }
        return ;
    }
    //NSObject *obj = [_listArray objectAtIndex:row];
    if([type isEqualToString:@"editStyleNum"]){
        YYInventoryStyleDetailModel *styleModel= [_listArray objectAtIndex:row/2];
        NSInteger num = [[parmas objectAtIndex:1] integerValue];
        if(num == 0){
            if(_currentType == 1){//我要补货
                [YYToast showToastWithView:self.view title:NSLocalizedString(@"已提交的需求件数不可改为0",nil) andDuration:kAlertToastDuration];
            }else if(_currentType == 2){//我有库存
                [YYToast showToastWithView:self.view title:NSLocalizedString(@"已提交的库存件数不可改为0",nil) andDuration:kAlertToastDuration];
            }
            [self.tableView reloadData];
        }else{
            styleModel.amount = [NSNumber numberWithInteger:num];
        }
    }else if([type isEqualToString:@"editStatus"]){
        NSString *key = [NSString stringWithFormat:@"%d_%ld",self.currentType,row];
        if([self.editRowArray containsObject:key]){
            [self.editRowArray removeObject:key];
        }else{
            [self.editRowArray addObject:key];
        }
        NSString *dealStr = [parmas objectAtIndex:1];
        if([dealStr isEqualToString:@"update"]){//完成
            YYInventoryStyleDetailModel *styleModel= [_listArray objectAtIndex:row/2];
            if(self.delegate && styleModel && type){
                [self.delegate btnClick:row section:section andParmas:@[type,@"",styleModel]];
            }
        }
        [self reloadTableData];
    }else if([type isEqualToString:@"deleteStyle"]){
        YYInventoryStyleDetailModel *styleModel= [_listArray objectAtIndex:row/2];
        if(self.delegate && styleModel && type){
            [self.delegate btnClick:row section:section andParmas:@[type,styleModel]];
        }
    }else if([type isEqualToString:@"styleStore"]){
        YYInventoryBoardModel *boardModel= [_listArray objectAtIndex:row/2];
        if(self.delegate && boardModel && type){
            [self.delegate btnClick:row section:section andParmas:@[type,boardModel]];
        }
    }else if([type isEqualToString:@"styleInfo"]){//
        YYInventoryBoardModel *boardModel= [_listArray objectAtIndex:row/2];
        if(self.delegate && boardModel && type){
            [self.delegate btnClick:row section:section andParmas:@[type,boardModel]];
        }
    }
    
//    if(self.delegate && obj && type){
//        [self.delegate btnClick:row section:section andParmas:@[type,obj]];
//    }
}

-(void)showInventory{
    if(self.delegate ){
        [self.delegate btnClick:0 section:0 andParmas:@[@"showInventory"]];
    }
}
#pragma mark - Other

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
@end
