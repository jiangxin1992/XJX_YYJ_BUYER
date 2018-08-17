//
//  YYInventoryViewController.m
//  YunejianBuyer
//
//  Created by Apple on 16/8/29.
//  Copyright © 2016年 Apple. All rights reserved.
//

#import "YYInventoryViewController.h"

#import "UIImage+Tint.h"
#import "TitlePagerView.h"
#import "YYMessageButton.h"
#import "YYInventoryApi.h"
#import "AppDelegate.h"
#import "MBProgressHUD.h"
#import "YYInventoryTableViewController.h"
#import "YYOrderHelpViewController.h"
#import "YYInventorySelectBrandViewController.h"
#import <MJRefresh.h>
#import "YYInventoryBoardViewCell.h"
#import "YYInventoryLineCell.h"
#import "YYInventoryStyleListViewCell.h"
#import "YYInventoryStoreStyleInfoViewController.h"
#import "YYOpusApi.h"

@interface YYInventoryViewController ()<UITableViewDataSource,UITableViewDelegate,YYTableCellDelegate,UITextFieldDelegate,TitlePagerViewDelegate,ViewPagerDataSource, ViewPagerDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UITextField *searchField;
@property (weak, nonatomic) IBOutlet UIView *searchView;
@property (nonatomic,assign)BOOL isSearchView;
@property (nonatomic,copy) NSString *searchFieldStr;
@property (weak, nonatomic) IBOutlet UIButton *searchBtn;

@property (weak, nonatomic) IBOutlet UIView *tabBarView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *searchViewTopLayoutConstraint;
@property (weak, nonatomic) IBOutlet UIView *pagingView;
@property (strong, nonatomic) TitlePagerView *pagingTitleView;

@property (weak, nonatomic) IBOutlet YYMessageButton *messageButton;

@property (nonatomic,strong)YYPageInfoModel *currentPageInfo;
@property (strong, nonatomic)NSMutableArray *listArray;

@property (strong, nonatomic)NSMutableArray *localNoteArray;
@property (strong, nonatomic)NSMutableArray *searchNoteArray;//搜索历史记录

@property (nonatomic,strong) UIView *noDataView;
@property(nonatomic,assign) NSInteger currentType;

@property (strong, nonatomic)NSMutableArray *editRowArray;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *tableViewTopLayout;

@end

@implementation YYInventoryViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    _searchField.delegate = self;
    _searchFieldStr = @"";
    self.listArray = [[NSMutableArray alloc] initWithCapacity:0];
    
    [_messageButton initButton:@""];
    [self messageCountChanged:nil];
    [_messageButton addTarget:self action:@selector(messageButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(messageCountChanged:) name:UnreadMsgAmountChangeNotification object:nil];

    if (!_pagingTitleView) {
        self.pagingTitleView = [[TitlePagerView alloc] init];
        self.pagingTitleView.frame = CGRectMake(50, 4, SCREEN_WIDTH-50-50, 40);
        self.pagingTitleView.font = [UIFont systemFontOfSize:14];
        NSArray *titleArray = @[NSLocalizedString(@"补货公告",nil),NSLocalizedString(@"我的补货",nil),NSLocalizedString(@"我的库存",nil)];
        float titleViewWidth = SCREEN_WIDTH-50-50;//[TitlePagerView calculateTitleWidth:titleArray withFont:self.pagingTitleView.font];
        float titleViewOffsetX  = (titleViewWidth -  [TitlePagerView getMaxTitleWidthFromArray:titleArray withFont:self.pagingTitleView.font]*[titleArray count])/2;
        
        if(titleViewOffsetX < 10){//
            self.pagingTitleView.dynamicTitlePagerViewTitleSpace = 10;
            titleViewOffsetX = (100+titleViewOffsetX*2-20)/2;
            
            self.pagingTitleView.width = [TitlePagerView getMaxTitleWidthFromArray:titleArray withFont:self.pagingTitleView.font]*[titleArray count] +self.pagingTitleView.dynamicTitlePagerViewTitleSpace * ([titleArray count] -1);
            self.pagingTitleView.x =  MAX(0, titleViewOffsetX);

        }else{
            if(titleViewOffsetX > 40){
                self.pagingTitleView.width = titleViewWidth -(titleViewOffsetX-40)*([titleArray count]-1);
                self.pagingTitleView.dynamicTitlePagerViewTitleSpace = 40;
                self.pagingTitleView.x = 50 + titleViewOffsetX-40;
            }else{
                self.pagingTitleView.width = titleViewWidth;
                self.pagingTitleView.dynamicTitlePagerViewTitleSpace = titleViewOffsetX;
                self.pagingTitleView.x = 50;
            }
        }
        [self.pagingTitleView addObjects:titleArray];
        self.pagingTitleView.delegate = self;
    }
    self.pagingTitleView.backgroundColor = [UIColor clearColor];
    [self.pagingView addSubview:self.pagingTitleView];
    
    self.noDataView = addNoDataView_phone(self.view, [NSString stringWithFormat:@"%@|icon:noinventory_icon",NSLocalizedString(@"暂无补货公告/n库存调拨可以让商品在不同的买手店之间流动起来~",)],nil,nil);
    _noDataView.hidden = YES;
    _tableView.hidden = YES;
    
    [self.tableView registerNib:[UINib nibWithNibName:@"YYInventoryBoardViewCell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:@"YYInventoryBoardViewCell"];
    [self.tableView registerNib:[UINib nibWithNibName:@"YYInventoryStyleListViewCell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:@"YYInventoryStyleListViewCell"];
    [self.tableView registerNib:[UINib nibWithNibName:@"YYInventoryLineCell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:@"YYInventoryLineCell"];

    [self addHeader];
    [self addFooter];

    self.dataSource = self;
    self.delegate = self;
    
    // Do not auto load data
    self.manualLoadData = YES;
    self.currentIndex = 0;
    [self reloadData];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    //    if(self.currentPageInfo != nil){
    //        [self loadOrderListFromServerByPageIndex:1 endRefreshing:NO];
    //    }
    [self reloadCurrentTableData:YES];
    // 进入埋点
    [MobClick beginLogPageView:kYYPageInventory];
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    // 退出埋点
    [MobClick endLogPageView:kYYPageInventory];
}

-(void)reloadCurrentTableData:(BOOL)newData{
    YYInventoryTableViewController *tableViewController = (YYInventoryTableViewController *)[self viewControllerAtIndex:_currentType];
    if(tableViewController != nil){
        [tableViewController relaodTableData:newData];
    }
}

#pragma msseage
- (void)messageButtonClicked:(id)sender {
    [YYInventoryApi markAsReadOnMsg:nil adnBlock:nil];
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    [appDelegate showMessageView:nil parentViewController:self];

}
- (void)messageCountChanged:(NSNotification *)notification{
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    NSInteger msgAmount = appDelegate.unreadOrderNotifyMsgAmount + appDelegate.unreadConnNotifyMsgAmount + appDelegate.unreadPersonalMsgAmount;
    
    if(msgAmount > 0 || appDelegate.unreadNewsAmount >0){
        if(msgAmount > 0 ){
            [_messageButton updateButtonNumber:[NSString stringWithFormat:@"%ld",(long)msgAmount]];
        }else{
            [_messageButton updateButtonNumber:@"dot"];
        }
    }else{
        [_messageButton updateButtonNumber:@""];
    }
}

- (void)loadListFromServerByPageIndex:(int)pageIndex endRefreshing:(BOOL)endrefreshing{
    WeakSelf(ws);
    __block BOOL blockEndrefreshing = endrefreshing;
    if(_currentType == 0){
        [YYInventoryApi getBoardList:nil month:3 pageIndex:pageIndex pageSize:8 queryStr:_searchFieldStr adnBlock:^(YYRspStatusAndMessage *rspStatusAndMessage, YYInventoryBoardListModel *boardsModel, NSError *error) {
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
            [MBProgressHUD hideAllHUDsForView:ws.view animated:YES];
            
        }];
    }else if(_currentType == 1){
        [YYInventoryApi getDemandList:nil month:0 pageIndex:pageIndex pageSize:8 queryStr:_searchFieldStr adnBlock:^(YYRspStatusAndMessage *rspStatusAndMessage, YYInventoryStyleListModel *listModel, NSError *error) {
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
            [MBProgressHUD hideAllHUDsForView:ws.view animated:YES];
        }];
    }else if(_currentType == 2){
        [YYInventoryApi getStoreList:nil month:0 pageIndex:pageIndex pageSize:8 queryStr:_searchFieldStr adnBlock:^(YYRspStatusAndMessage *rspStatusAndMessage, YYInventoryStyleListModel *listModel, NSError *error) {
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
            [MBProgressHUD hideAllHUDsForView:ws.view animated:YES];
        }];
    }else{
        
        if(blockEndrefreshing){
            [self.tableView.mj_header endRefreshing];
            [self.tableView.mj_footer endRefreshing];
        }
        [ws reloadTableData];
        
        [MBProgressHUD hideAllHUDsForView:ws.view animated:YES];
        
    }
}

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if(self.isSearchView){
        return [_searchNoteArray count];
    }else{
        return [_listArray count]*2;
    }
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = nil;
    if(self.isSearchView){
        static NSString *CellIdentifier = @"YYListSearchNoteCell";
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
            NSString *key = [NSString stringWithFormat:@"%ld_%ld",(long)self.currentType,indexPath.row];
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
    }
    return cell;
}


#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if(self.isSearchView){
        return 50;
    }else{
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
    }
}



- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if(self.isSearchView){
        NSArray *obj = [_searchNoteArray objectAtIndex:indexPath.row];
        self.searchFieldStr =  [obj objectAtIndex:0];
        self.searchField.text = self.searchFieldStr;
        _isSearchView = NO;
    }
}


-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath{
    if(self.isSearchView){
        return;
    }

}

-(void)reloadTableData{
    if(self.isSearchView){
        self.noDataView.hidden = YES;
    }else{
        if ([self.listArray count] <= 0) {
            self.noDataView.hidden = NO;
        }else{
            self.noDataView.hidden = YES;
        }
    }
    [self.tableView reloadData];
    
}

- (void)addHeader{
    WeakSelf(ws);
    MJRefreshNormalHeader *header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        if (![YYCurrentNetworkSpace isNetwork]) {
            [YYToast showToastWithTitle:kNetworkIsOfflineTips andDuration:kAlertToastDuration];
            [ws.tableView.mj_header endRefreshing];
            return;
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
            [ws loadListFromServerByPageIndex:[ws.currentPageInfo.pageIndex intValue]+1 endRefreshing:YES];
        }else{
            //弹出提示
            [ws.tableView.mj_footer endRefreshing];
        }
    }];
}

#pragma YYTableCellDelegate
-(void)btnClick:(NSInteger)row section:(NSInteger)section andParmas:(NSArray *)parmas{
    NSString *type = [parmas objectAtIndex:0];
    if([type isEqualToString:@"newHelpOrAdd"]){
        if(_currentType == 0){//帮助
            [self showHelp];
        }else if(_currentType == 1){//我要补货
            [self showSelectBrandView:1];
        }else if(_currentType == 2){//我有库存
            [self showSelectBrandView:2];
        }
    }else if([type isEqualToString:@"editStyleNum"]){
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
        YYInventoryStyleDetailModel *styleModel = nil;
        if([parmas count]== 3){
            styleModel = [parmas objectAtIndex:2];
            if(_currentType == 1){//我要补货
                [self editDemandStyleNum:styleModel];
            }else if(_currentType == 2){//我有库存
                [self editStoreStyleNum:styleModel];
            }
        }else{
            NSString *key = [NSString stringWithFormat:@"%ld_%ld",(long)self.currentType,row];
            if([self.editRowArray containsObject:key]){
                [self.editRowArray removeObject:key];
            }else{
                [self.editRowArray addObject:key];
            }
            NSString *dealStr = [parmas objectAtIndex:1];
            if([dealStr isEqualToString:@"update"]){//完成
                YYInventoryStyleDetailModel *styleModel= [_listArray objectAtIndex:row/2];
                if(_currentType == 1){//我要补货
                    [self editDemandStyleNum:styleModel];
                }else if(_currentType == 2){//我有库存
                    [self editStoreStyleNum:styleModel];
                }
            }
            [self reloadTableData];
        }
        

    }else if([type isEqualToString:@"deleteStyle"]){
        YYInventoryStyleDetailModel *styleModel = nil;
        if([parmas count]== 2){
            styleModel = [parmas objectAtIndex:1];
        }else{
            styleModel = [_listArray objectAtIndex:row/2];
        }
        if(_currentType == 1){//我要补货
            [self deleteDemandStyle:styleModel];
        }else if(_currentType == 2){//我有库存
            [self deleteStoreStyle:styleModel];
        }
    }else if([type isEqualToString:@"styleStore"]){
        YYInventoryBoardModel *boardModel = nil;
        if([parmas count]== 2){
            boardModel = [parmas objectAtIndex:1];
        }else{
            boardModel = [_listArray objectAtIndex:row/2];
        }
        [self showStyleStore:boardModel];
    }else if([type isEqualToString:@"styleInfo"]){
        YYInventoryBoardModel *boardModel = nil;
        if([parmas count]== 2){
            boardModel = [parmas objectAtIndex:1];
        }else{
            boardModel = [_listArray objectAtIndex:row/2];
        }
        [self showStyleInfo:boardModel];
    }else if([type isEqualToString:@"showInventory"]){
        [self showSelectBrandView:1];
    }
}

#pragma search
- (IBAction)showSearchView:(id)sender {
    if (_searchView.hidden == YES) {
        _pagingView.hidden = YES;
        _tableViewTopLayout.constant = -44;
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
            _searchNoteArray = [NSKeyedUnarchiver unarchiveObjectWithFile:getInventorySearchNoteStorePath()];
            [self.tableView reloadData];
            [YYInventoryApi markAsReadOnMsg:nil adnBlock:nil];
        }];
    }
}
- (IBAction)hideSearchView:(id)sender {
    if ( _searchView.hidden == NO) {
        _pagingView.hidden = NO;
        _tableViewTopLayout.constant = 0;
        _searchFieldStr = @"";
        _searchView.alpha = 1.0;
        _searchViewTopLayoutConstraint.constant = 0;
        [_searchView layoutIfNeeded];
        [UIView animateWithDuration:0.3 animations:^{
            _searchViewTopLayoutConstraint.constant = -44;
            _searchView.alpha = 0.0;
            [_searchView layoutIfNeeded];
        } completion:^(BOOL finished) {
            _searchView.hidden = YES;
            [_searchField resignFirstResponder];
            self.isSearchView = NO;
            self.searchNoteArray = nil;
            self.tableView.hidden = YES;
            [self.listArray removeAllObjects];
            [self.editRowArray removeAllObjects];
            self.noDataView.hidden = YES;
        }];
    }
}

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
    //    NSString *str = _textNameInput.text;
    //  self.currentYYOrderInfoModel.buyerName = str;
    if(![str isEqualToString:@""]){
        _searchFieldStr = str;
        _isSearchView = YES;
        
        _localNoteArray = [NSKeyedUnarchiver unarchiveObjectWithFile:getInventorySearchNoteStorePath()];
        _searchNoteArray = [[NSMutableArray alloc] init];
        for (NSArray *note in _localNoteArray) {
            if([note[0] containsString:str]){
                [_searchNoteArray addObject:note];
            }
        }
        [self reloadTableData];
        //[self loadOrderListFromServerByPageIndex:1 endRefreshing:NO ];
    }else{
        _searchFieldStr = @"";
    }
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    if(![NSString isNilOrEmpty:_searchFieldStr]){
        _isSearchView = NO;
        [_searchField resignFirstResponder];
        [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        [self loadListFromServerByPageIndex:1 endRefreshing:NO ];
        return YES;
    }
    return NO;
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
        BOOL iskeyedarchiver= [NSKeyedArchiver archiveRootObject:self.localNoteArray toFile:getInventorySearchNoteStorePath()];
        if(iskeyedarchiver){
            NSLog(@"archive success ");
        }
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
    BOOL iskeyedarchiver= [NSKeyedArchiver archiveRootObject:self.localNoteArray toFile:getInventorySearchNoteStorePath()];
    if(iskeyedarchiver){
        NSLog(@"archive success ");
        [_searchNoteArray removeObjectAtIndex:row];
        [self.tableView reloadData];
    }
}



#pragma mark - ViewPagerDataSource
- (NSUInteger)numberOfTabsForViewPager:(ViewPagerController *)viewPager {
    return 3;
}

- (UIViewController *)viewPager:(ViewPagerController *)viewPager contentViewControllerForTabAtIndex:(NSUInteger)index {
    if (index == 0) {
        return [self createBoradTableVC];
    } else if (index == 1) {
        return [self createInventoryTableVC];
    } else {
        return [self createStoreTableVC];
    }
}

- (UIViewController *)createBoradTableVC {
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Inventory" bundle:[NSBundle mainBundle]];
    YYInventoryTableViewController *tableViewController = [storyboard instantiateViewControllerWithIdentifier:@"YYInventoryTableViewController"];
    tableViewController.currentType = 0;
    tableViewController.delegate = self;
    return tableViewController;
}

- (UIViewController *)createInventoryTableVC {
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Inventory" bundle:[NSBundle mainBundle]];
    YYInventoryTableViewController *tableViewController = [storyboard instantiateViewControllerWithIdentifier:@"YYInventoryTableViewController"];
    tableViewController.currentType = 1;
    tableViewController.delegate = self;
    return tableViewController;
}

- (UIViewController *)createStoreTableVC {
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Inventory" bundle:[NSBundle mainBundle]];
    YYInventoryTableViewController *tableViewController = [storyboard instantiateViewControllerWithIdentifier:@"YYInventoryTableViewController"];
    tableViewController.currentType = 2;
    tableViewController.delegate = self;
    return tableViewController;
}



#pragma TitlePagerViewDelegate
- (void)didTouchBWTitle:(NSUInteger)index {

    UIPageViewControllerNavigationDirection direction;
    
    if (self.currentType == index) {
        return;
    }
    
    if (index > self.currentType) {
        direction = UIPageViewControllerNavigationDirectionForward;
    } else {
        direction = UIPageViewControllerNavigationDirectionReverse;
    }
    
    UIViewController *viewController = [self viewControllerAtIndex:index];
    
    if (viewController) {
        __weak typeof(self) weakself = self;
        [self.pageViewController setViewControllers:@[viewController] direction:direction animated:YES completion:^(BOOL finished) {
            weakself.currentIndex = index;
        }];
    }
}

- (void)setCurrentIndex:(NSInteger)index {
    if(index == 0){
        _searchBtn.hidden = NO;
    }else{
        _searchBtn.hidden = YES;
    }
    if(_currentType ==0 && index >0){//公告页
        [YYInventoryApi markAsReadOnMsg:nil adnBlock:nil];
        
    }
    _currentType = index;

    [self reloadCurrentTableData:YES];

    [self.pagingTitleView adjustTitleViewByIndex:index];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if(self.tableView.hidden == NO){
        return;
    }
    CGFloat contentOffsetX = scrollView.contentOffset.x;
    
    if (self.currentType != 0 && contentOffsetX <= SCREEN_WIDTH * 3) {
        contentOffsetX += SCREEN_WIDTH * self.currentType;
    }
    
    [self.pagingTitleView updatePageIndicatorPosition:contentOffsetX];
}

- (void)scrollEnabled:(BOOL)enabled {
    self.scrollingLocked = !enabled;
    
    for (UIScrollView *view in self.pageViewController.view.subviews) {
        if ([view isKindOfClass:[UIScrollView class]]) {
            view.scrollEnabled = enabled;
            view.bounces = enabled;
        }
    }
}

-(void)showHelp{
    [YYInventoryApi markAsReadOnMsg:nil adnBlock:nil];
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Order" bundle:[NSBundle mainBundle]];
    YYOrderHelpViewController *orderHelpViewController = [storyboard instantiateViewControllerWithIdentifier:@"YYOrderHelpViewController"];
    orderHelpViewController.helpType = 1;
    [self.navigationController pushViewController:orderHelpViewController animated:YES];
    
    WeakSelf(ws);
    [orderHelpViewController setCancelButtonClicked:^(){
        [ws.navigationController popViewControllerAnimated:YES];
    }];
}

-(void)showSelectBrandView:(NSInteger)type{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Inventory" bundle:[NSBundle mainBundle]];
    YYInventorySelectBrandViewController *selectBrandViewController = [storyboard instantiateViewControllerWithIdentifier:@"YYInventorySelectBrandViewController"];
    selectBrandViewController.viewType = type;
    [self.navigationController pushViewController:selectBrandViewController animated:YES];
    
    WeakSelf(ws);
    [selectBrandViewController setCancelButtonClicked:^(){
        [ws.navigationController popViewControllerAnimated:YES];
        [ws reloadCurrentTableData:YES];
    }];
}
- (IBAction)backAction:(id)sender {
    if(_cancelButtonClicked){
        _cancelButtonClicked();
    }
}
-(void)deleteDemandStyle :(YYInventoryStyleDetailModel *)styleModel{
    WeakSelf(ws);
    CMAlertView *alertView = [[CMAlertView alloc] initWithTitle:NSLocalizedString(@"确定要删除此条目？",nil) message:nil needwarn:NO delegate:nil cancelButtonTitle:NSLocalizedString(@"取消",nil) otherButtonTitles:@[NSLocalizedString(@"删除",nil)]];
    //alertView.specialParentView = self.view;
    __block NSInteger demandId = [styleModel.id integerValue];
    [alertView setAlertViewBlock:^(NSInteger selectedIndex){
        if (selectedIndex == 1) {
            [YYInventoryApi deleteDemand:demandId adnBlock:^(YYRspStatusAndMessage *rspStatusAndMessage, NSError *error) {
                if (rspStatusAndMessage.status == kCode100) {
                    [YYToast showToastWithTitle:NSLocalizedString(@"删除成功",nil)  andDuration:kAlertToastDuration];
                    if(ws.tableView.hidden){
                        [ws reloadCurrentTableData:YES];
                    }else{
                        [ws loadListFromServerByPageIndex:1 endRefreshing:NO];
                    }
                }
            }];
        }
    }];
    
    [alertView show];

}

-(void)deleteStoreStyle :(YYInventoryStyleDetailModel *)styleModel{
    [YYInventoryApi deleteStore:0 adnBlock:^(YYRspStatusAndMessage *rspStatusAndMessage, NSError *error) {
        
    }];
    WeakSelf(ws);
    CMAlertView *alertView = [[CMAlertView alloc] initWithTitle:NSLocalizedString(@"确定要删除此条目？",nil) message:nil needwarn:NO delegate:nil cancelButtonTitle:NSLocalizedString(@"取消",nil) otherButtonTitles:@[NSLocalizedString(@"删除",nil)]];
    //alertView.specialParentView = self.view;
    __block NSInteger storeId = [styleModel.id integerValue];
    [alertView setAlertViewBlock:^(NSInteger selectedIndex){
        if (selectedIndex == 1) {
            [YYInventoryApi deleteStore:storeId adnBlock:^(YYRspStatusAndMessage *rspStatusAndMessage, NSError *error) {
                if (rspStatusAndMessage.status == kCode100) {
                    [YYToast showToastWithTitle:NSLocalizedString(@"删除成功",nil)  andDuration:kAlertToastDuration];
                    if(ws.tableView.hidden){
                        [ws reloadCurrentTableData:YES];
                    }else{
                        [ws loadListFromServerByPageIndex:1 endRefreshing:NO];
                    }
                }
            }];
        }
    }];
    
    [alertView show];
}

-(void)editDemandStyleNum :(YYInventoryStyleDetailModel *)styleModel{
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    WeakSelf(ws);

    [YYInventoryApi modifyDemand:[styleModel.id integerValue] amount:[styleModel.amount integerValue] adnBlock:^(YYRspStatusAndMessage *rspStatusAndMessage, NSError *error) {
        if (rspStatusAndMessage.status == kCode100) {
            if(ws.tableView.hidden){
                [ws reloadCurrentTableData:YES];
            }else{
                [ws loadListFromServerByPageIndex:1 endRefreshing:NO];
            }
        }
        [MBProgressHUD hideAllHUDsForView:ws.view animated:YES];
        [YYToast showToastWithTitle:rspStatusAndMessage.message  andDuration:kAlertToastDuration];
    }];
}

-(void)editStoreStyleNum :(YYInventoryStyleDetailModel *)styleModel{
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    WeakSelf(ws);
    
    [YYInventoryApi modifyStore:[styleModel.id integerValue] amount:[styleModel.amount integerValue] adnBlock:^(YYRspStatusAndMessage *rspStatusAndMessage, NSError *error) {
        if (rspStatusAndMessage.status == kCode100) {
            if(ws.tableView.hidden){
                [ws reloadCurrentTableData:YES];
            }else{
                [ws loadListFromServerByPageIndex:1 endRefreshing:NO];
            }
        }
        [MBProgressHUD hideAllHUDsForView:ws.view animated:YES];
        [YYToast showToastWithTitle:rspStatusAndMessage.message  andDuration:kAlertToastDuration];
    }];
}

-(void)showStyleStore:(YYInventoryBoardModel *)boardModel{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Inventory" bundle:[NSBundle mainBundle]];
    YYInventoryStoreStyleInfoViewController *storeStyleInfoViewController = [storyboard instantiateViewControllerWithIdentifier:@"YYInventoryStoreStyleInfoViewController"];
    storeStyleInfoViewController.boardModel = boardModel;
    [self.navigationController pushViewController:storeStyleInfoViewController animated:YES];
    
    WeakSelf(ws);
    __block YYInventoryBoardModel * blockboardModel = boardModel;
    [storeStyleInfoViewController setCancelButtonClicked:^(){
        [ws.navigationController popViewControllerAnimated:YES];
        blockboardModel.hasRead = [[NSNumber alloc] initWithInt:1];
        if(ws.tableView.hidden){
            [ws reloadCurrentTableData:YES];
        }
        [YYInventoryApi markAsReadOnMsg:[blockboardModel.msgId stringValue] adnBlock:^(YYRspStatusAndMessage *rspStatusAndMessage, NSError *error) {
            if(rspStatusAndMessage.status == kCode100){
                AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
                if(appDelegate.unreadInventoryAmount > 0){
                    appDelegate.unreadInventoryAmount --;
                    [[NSNotificationCenter defaultCenter] postNotificationName:UnreadMsgAmountChangeNotification object:nil userInfo:nil];
                }
            }
        }];
    }];
}

-(void)showStyleInfo:(YYInventoryBoardModel *)boardModel{
    WeakSelf(ws);
    [YYOpusApi getStyleInfoByStyleId:[boardModel.styleId longValue] orderCode:nil andBlock:^(YYRspStatusAndMessage *rspStatusAndMessage, YYStyleInfoModel *styleInfoModel, NSError *error) {
        if (rspStatusAndMessage.status != kCode100) {
            [YYToast showToastWithView:ws.view title:rspStatusAndMessage.message andDuration:kAlertToastDuration];
        }else{
            AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
            [appDelegate showStyleInfoViewController:boardModel parentViewController:self];
        }
    }];
}
#pragma mark - Other

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
