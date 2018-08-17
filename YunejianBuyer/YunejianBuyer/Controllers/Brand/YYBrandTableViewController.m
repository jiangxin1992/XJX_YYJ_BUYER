//
//  YYBrandTableViewController.m
//  YunejianBuyer
//
//  Created by Apple on 16/5/27.
//  Copyright © 2016年 Apple. All rights reserved.
//

#import "YYBrandTableViewController.h"
#import "YYOrderApi.h"
#import "YYConnApi.h"
#import "YYPageInfoModel.h"
#import "AppDelegate.h"
#import "MBProgressHUD.h"
#import <MJRefresh.h>
#import "YYBrandViewCell.h"
#import "YYBrandAddViewCell.h"
#import "YYConnAddViewController.h"
#import "YYUser.h"

@interface YYBrandTableViewController ()<UICollectionViewDataSource,UICollectionViewDelegate>
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;

@property (nonatomic,strong)YYPageInfoModel *currentPageInfo;
@property (nonatomic,weak) UIView *noDataView;
@property (nonatomic,strong) NSMutableArray *brandListArray;
@property (nonatomic,assign) BOOL hasNewBrands;

@end

@implementation YYBrandTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self SomePrepare];
    
    if ([YYCurrentNetworkSpace isNetwork]) {
        [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    }
    //刚出现的时候
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    [appDelegate checkNoticeCount];
    [[YYUser currentUser] updateUserCheckStatus];
    [appDelegate checkAppointmentNoticeCount];
    [self loadDataByPageIndex:1 endRefreshing:NO];
//    [self hasNewBrandsRequest];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationDidBecomeActiveAction) name:kApplicationDidBecomeActive object:nil];
}
-(void)applicationDidBecomeActiveAction{
    if(!self.noDataView.hidden){
        [self headerWithRefreshingAction];
    }
}
- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    // 进入埋点
    [MobClick beginLogPageView:kYYPageBrandTable];
    if(!self.noDataView.hidden){
        [self headerWithRefreshingAction];
    }
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    // 退出埋点
    [MobClick endLogPageView:kYYPageBrandTable];
}

#pragma mark - SomePrepare
-(void)SomePrepare
{
    [self PrepareData];
    [self PrepareUI];
}
-(void)PrepareData{
    _hasNewBrands = NO;
}
-(void)PrepareUI{

    [self addHeader];
    [self addFooter];

    self.collectionView.alwaysBounceVertical = YES;
    //self.collectionView.contentInset = UIEdgeInsetsMake(45, 0, 58, 0);
    if(_currentListType == 1){
        self.noDataView = addNoDataView_phone(self.view,[NSString stringWithFormat:@"%@|icon:nobrand_icon|185",NSLocalizedString(@"还没有合作品牌/n与品牌合作后，可以查看更多系列哦~",nil)],nil,nil);
    }else if(_currentListType == 2){
        self.noDataView = addNoDataView_phone(self.view,[NSString stringWithFormat:@"%@|icon:nobrand_icon|185",NSLocalizedString(@"还没有邀请合作品牌/n与品牌合作后，可以查看更多系列哦~",nil)],nil,nil);
    }
    self.noDataView.userInteractionEnabled = YES;
    self.noDataView.hidden = YES;
}

#pragma mark - SomeAction
-(void)hasNewBrandsRequest{
    WeakSelf(ws);
    [YYConnApi hasNewBrandsWithBlock:^(YYRspStatusAndMessage *rspStatusAndMessage, BOOL hasNewBrands, NSError *error) {
        if (rspStatusAndMessage.status == kCode100){
            ws.hasNewBrands = hasNewBrands;
            dispatch_async(dispatch_get_main_queue(), ^{
                [ws reloadCollectionViewData:NO];
            });
        }
    }];
}
-(void)reloadBrandData{
    if(self.currentPageInfo != nil){
        //页面出现的时候
        [self loadDataByPageIndex:1 endRefreshing:NO];
//        [self hasNewBrandsRequest];
    }
}

//刷新界面
- (void)reloadCollectionViewData:(BOOL)endrefreshing{
    if(endrefreshing){
        [self.collectionView.mj_header endRefreshing];
        [self.collectionView.mj_footer endRefreshing];
    }
    [self.collectionView reloadData];
    
    if (!self.brandListArray || [self.brandListArray count ]==0) {
        self.noDataView.hidden = NO;
//        self.collectionView.scrollEnabled = NO;
    }else{
        self.noDataView.hidden = YES;
//        self.collectionView.scrollEnabled = YES;
    }
}

- (void)loadDataByPageIndex:(int)pageIndex endRefreshing:(BOOL)endrefreshing{
    WeakSelf(ws);
    __block BOOL blockEndrefreshing =endrefreshing;
    [YYConnApi getConnBrands:_currentListType andPageIndex:pageIndex andBlock:^(YYRspStatusAndMessage *rspStatusAndMessage, YYConnBrandInfoListModel *listModel, NSError *error) {
        if (rspStatusAndMessage.status == kCode100){
            ws.currentPageInfo = listModel.pageInfo;
            if( !ws.currentPageInfo || ws.currentPageInfo.isFirstPage){
                ws.brandListArray =  [[NSMutableArray alloc] init];//;
            }
            [ws.brandListArray addObjectsFromArray:listModel.result];
            
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            [ws reloadCollectionViewData:blockEndrefreshing];
        });
        
//        AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
//        UIView *superView = appDelegate.window.rootViewController.view;
        
        [MBProgressHUD hideAllHUDsForView:ws.view animated:YES];
        
        if (rspStatusAndMessage.status != kCode100) {
            [YYToast showToastWithTitle:rspStatusAndMessage.message  andDuration:kAlertToastDuration];
        }
    }];
}

- (void)addHeader
{
    WeakSelf(ws);
    MJRefreshNormalHeader *header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        // 进入刷新状态就会回调这个Block
        [ws headerWithRefreshingAction];
    }];
    self.collectionView.mj_header = header;
    self.collectionView.mj_header.automaticallyChangeAlpha = YES;
    header.lastUpdatedTimeLabel.hidden = YES;
}
-(void)headerWithRefreshingAction{
    if (![YYCurrentNetworkSpace isNetwork]) {
        [YYToast showToastWithTitle:kNetworkIsOfflineTips andDuration:kAlertToastDuration];
        [self.collectionView.mj_header endRefreshing];
        return;
    }else{
        AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
        [appDelegate checkNoticeCount];
        [[YYUser currentUser] updateUserCheckStatus];
        [appDelegate checkAppointmentNoticeCount];
    }
    [self loadDataByPageIndex:1 endRefreshing:YES];
}
- (void)addFooter
{
    WeakSelf(ws);
    // 添加上拉刷新尾部控件
    self.collectionView.mj_footer = [MJRefreshBackNormalFooter footerWithRefreshingBlock:^{
        // 进入刷新状态就会回调这个Block

        if (![YYCurrentNetworkSpace isNetwork]) {
            [YYToast showToastWithTitle:kNetworkIsOfflineTips andDuration:kAlertToastDuration];
            [ws.collectionView.mj_footer endRefreshing];
            return;
        }


        if ([ws.brandListArray count] > 0
            && ws.currentPageInfo
            && !ws.currentPageInfo.isLastPage) {
            [ws loadDataByPageIndex:[ws.currentPageInfo.pageIndex intValue]+1 endRefreshing:YES];
        }else{
            [ws.collectionView.mj_footer endRefreshing];
        }
    }];
}

#pragma mark -  UICollectionViewDataSource
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return [self.brandListArray count]+1;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{

    return CGSizeMake(SCREEN_WIDTH, 80);
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.row == 0){
        static NSString* reuseIdentifier = @"YYBrandAddViewCell";
        YYBrandAddViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:reuseIdentifier forIndexPath:indexPath];
        //cell.delegate = self;
        cell.hasNewBrands = _hasNewBrands;
        [cell updateUI];
        return cell;
    }else{
        static NSString* reuseIdentifier = @"YYBrandViewCell";
        YYBrandViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:reuseIdentifier forIndexPath:indexPath];
        cell.indexPath = indexPath;
        if([self.brandListArray count] > 0){
            YYConnBrandInfoModel * brandInfoModel = [self.brandListArray objectAtIndex:(indexPath.row-1)];
            cell.brandInfoModel = brandInfoModel;
        }
        [cell updateUI];
        
        return cell;
    }
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.row == 0){
        if(self.delegate){
            [self.delegate btnClick:indexPath.row section:indexPath.section andParmas:@[@"addBrand"]];
        }
    }else{
         YYConnBrandInfoModel * brandInfoModel = [self.brandListArray objectAtIndex:(indexPath.row-1)];
        if(self.delegate && brandInfoModel){
            [self.delegate btnClick:indexPath.row section:indexPath.section andParmas:@[@"brandInfo",brandInfoModel]];
        }
    }
}
#pragma mark - Other
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
