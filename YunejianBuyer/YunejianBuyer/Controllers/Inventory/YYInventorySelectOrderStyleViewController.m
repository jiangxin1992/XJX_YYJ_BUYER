//
//  YYInventorySelectOrderStyleViewController.m
//  YunejianBuyer
//
//  Created by Apple on 16/9/1.
//  Copyright © 2016年 Apple. All rights reserved.
//

#import "YYInventorySelectOrderStyleViewController.h"
#import "YYNavigationBarViewController.h"
#import "YYInventoryTableStepCell.h"
#import "MBProgressHUD.h"
#import <MJRefresh.h>
#import "YYInventoryApi.h"
#import "YYInventoryOrderStyleTableViewCell.h"
#import "YYInventorySubmitStyleInfoViewController.h"

@interface YYInventorySelectOrderStyleViewController ()
@property (weak, nonatomic) IBOutlet UIView *containerView;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic,weak) UIView *noDataView;
@property (strong, nonatomic)NSMutableArray *listArray;
@property (nonatomic,strong)YYPageInfoModel *currentPageInfo;

@end

@implementation YYInventorySelectOrderStyleViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]];
    YYNavigationBarViewController *navigationBarViewController = [storyboard instantiateViewControllerWithIdentifier:@"YYNavigationBarViewController"];
    navigationBarViewController.previousTitle = @"";
    //self.navigationBarViewController = navigationBarViewController;
    if(_viewType == 1){
        navigationBarViewController.nowTitle = NSLocalizedString(@"我要补货",nil);
    }else if(_viewType == 2){
        navigationBarViewController.nowTitle = NSLocalizedString(@"我有库存",nil);
    }
    [_containerView insertSubview:navigationBarViewController.view atIndex:0];
    //[_containerView addSubview:navigationBarViewController.view];
    __weak UIView *_weakContainerView = _containerView;
    [navigationBarViewController.view mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(_weakContainerView.mas_top);
        make.left.equalTo(_weakContainerView.mas_left);
        make.bottom.equalTo(_weakContainerView.mas_bottom);
        make.right.equalTo(_weakContainerView.mas_right);
    }];
    
    WeakSelf(ws);
    __block YYNavigationBarViewController *blockVc = navigationBarViewController;
    
    [navigationBarViewController setNavigationButtonClicked:^(NavigationButtonType buttonType){
        if (buttonType == NavigationButtonTypeGoBack) {
            if(ws.cancelButtonClicked){
                ws.cancelButtonClicked();
            }
            blockVc = nil;
        }
    }];

    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self addHeader];
    [self addFooter];

    [_tableView registerNib:[UINib nibWithNibName:@"YYInventoryTableStepCell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:@"YYInventoryTableStepCell"];
    self.listArray = [[NSMutableArray alloc] initWithCapacity:0];
    
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [self loadListFromServerByPageIndex:1 endRefreshing:NO];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    // 进入埋点
    [MobClick beginLogPageView:kYYPageInventorySelectOrderStyle];
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    // 退出埋点
    [MobClick endLogPageView:kYYPageInventorySelectOrderStyle];
}

- (void)loadListFromServerByPageIndex:(int)pageIndex endRefreshing:(BOOL)endrefreshing{
    WeakSelf(ws);
    
    __block BOOL blockEndrefreshing = endrefreshing;
    [YYInventoryApi getOrderStyles:_designerId query:@""  pageIndex:pageIndex pageSize:8 adnBlock:^(YYRspStatusAndMessage *rspStatusAndMessage, YYInventoryOrderStylesModel *stylesModel, NSError *error) {
         if (rspStatusAndMessage.status == kCode100) {
            if (pageIndex == 1) {
                [ws.listArray removeAllObjects];
            }
             ws.currentPageInfo = stylesModel.pageInfo;
            if (stylesModel && stylesModel.result
                && [stylesModel.result count] > 0){
                [ws.listArray addObjectsFromArray:stylesModel.result];
                
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

- (void)addHeader
{
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

-(void)reloadTableData{
    //    if(self.isSearchView){
    //        self.noDataView.hidden = YES;
    //    }else{
    //        if ([self.listArray count] <= 0) {
    //            self.noDataView.hidden = NO;
    //        }else{
    //            self.noDataView.hidden = YES;
    //        }
    //    }
    [self.tableView reloadData];
    
}

#pragma mark - UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if(section == 0){
        return 1;
    }else{
        if([_listArray count] > 0){
            return [_listArray count];
        }else{
            return 1;
        }
    }
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if(indexPath.section == 0){
        static NSString *CellIdentifier = @"YYInventoryTableStepCell";
        YYInventoryTableStepCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
        if(_viewType == 1){
            [cell updateCellInfo:@[@[NSLocalizedString(@"选择合作品牌",nil),@"true"],@[NSLocalizedString(@"选择款式",nil),@"true"],@[NSLocalizedString(@"添加补货需求",nil),@""]]];
        }else if(_viewType == 2){
            [cell updateCellInfo:@[@[NSLocalizedString(@"选择合作品牌",nil),@"true"],@[NSLocalizedString(@"选择款式",nil),@"true"],@[NSLocalizedString(@"添加库存",nil),@""]]];
        }
        return cell;
    }else{
        
        if([_listArray count] > 0){//
            YYInventoryStyleModel * styleInfoModel= [_listArray objectAtIndex:indexPath.row];
            NSString *CellIdentifier = @"YYInventoryOrderStyleTableViewCell";
            YYInventoryOrderStyleTableViewCell *cell = [tableView  dequeueReusableCellWithIdentifier:CellIdentifier];
            cell.styleInfoModel = styleInfoModel;
            [cell updateUI];
            return cell;
        }else{
            static NSString* reuseIdentifier = @"YYInventoryViewNullCell";
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:reuseIdentifier forIndexPath:indexPath];
            if(self.noDataView == nil){
                self.noDataView = addNoDataView_phone(cell.contentView,[NSString stringWithFormat:@"%@|icon:nodata_icon|40",NSLocalizedString(@"暂无相关数据哦~",nil)],nil,nil);
            }
            cell.backgroundColor = [UIColor whiteColor];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            
            return cell;
        }
    }
}


#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if(indexPath.section == 0){
        return 81;
    }else{
        if([_listArray count] > 0){//
            return 81;
        }else{
            return SCREEN_HEIGHT-65-81;
        }
    }
}



- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if(indexPath.section == 1 && [_listArray count] > 0){//
        YYInventoryStyleModel * styleInfoModel= [_listArray objectAtIndex:indexPath.row];
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Inventory" bundle:[NSBundle mainBundle]];
        YYInventorySubmitStyleInfoViewController *submitStyleInfoViewController = [storyboard instantiateViewControllerWithIdentifier:@"YYInventorySubmitStyleInfoViewController"];
        submitStyleInfoViewController.viewType = _viewType;
        submitStyleInfoViewController.styleInfoModel = styleInfoModel;
        [self.navigationController pushViewController:submitStyleInfoViewController animated:YES];
        
        WeakSelf(ws);
        [submitStyleInfoViewController setCancelButtonClicked:^(){
            [ws.navigationController popViewControllerAnimated:YES];
            //[ws.navigationController popToRootViewControllerAnimated:YES];

        }];
        
    }
}

#pragma mark - Other

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
@end
