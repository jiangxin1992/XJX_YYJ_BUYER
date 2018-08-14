//
//  YYOpusViewController.m
//  Yunejian
//
//  Created by yyj on 15/7/9.
//  Copyright (c) 2015年 yyj. All rights reserved.
//

#import "YYOpusViewController.h"
#import "YYOpusApi.h"
#import "YYUser.h"
#import "SDWebImageManager.h"
#import "CommonHelper.h"
#import "MJRefresh.h"
#import "CommonMacro.h"
#import "YYTopBarShoppingCarButton.h"
#import "YYStyleDetailListViewController.h"
#import "NSManagedObject+helper.h"
#import "YYNetworkReachability.h"
#import "MBProgressHUD.h"
#import "AppDelegate.h"
#import "UIImage+YYImage.h"
#import "UIColor+KTUtilities.h"
#import "YYAlert.h"
#import "YYCartDetailViewController.h"
#import "YYSeriesCollectionViewCell.h"

@interface YYOpusViewController ()<UICollectionViewDataSource,UICollectionViewDelegate,YYSeriesCollectionViewCellDelegate>

@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (weak, nonatomic) IBOutlet YYTopBarShoppingCarButton *topBarShoppingCarButton;

@property (nonatomic,strong)NSMutableArray *online_opusSeriesArray;
@property (nonatomic,strong)YYPageInfoModel *currentPageInfo;

@property(nonatomic,strong) YYStylesAndTotalPriceModel *stylesAndTotalPriceModel;//总数

@property (nonatomic,strong) UIView *noDataView;

@end

@implementation YYOpusViewController



- (void)viewDidLoad{
    [super viewDidLoad];
    
    [self.topBarShoppingCarButton initButton];
    
    self.online_opusSeriesArray = [[NSMutableArray alloc] initWithCapacity:0];
    
    [self addHeader];
    [self addFooter];
    
    self.collectionView.alwaysBounceVertical = YES;
    self.noDataView = addNoDataView(self.view,nil);
    self.noDataView.hidden = YES;
    
    if ([YYNetworkReachability connectedToNetwork]) {
        AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
        UIView *superView = appDelegate.window.rootViewController.view;
        [MBProgressHUD showHUDAddedTo:superView animated:YES];
     }
    [self loadDataByPageIndex:1];
}

//在视图出现的时候更新购物车数据
- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    AppDelegate *appdelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    self.stylesAndTotalPriceModel = getTotalBrandsOrderInfo(appdelegate.cartDesignerIdArray);
    
    [self.topBarShoppingCarButton updateButtonNumber:[NSString stringWithFormat:@"%i", self.stylesAndTotalPriceModel.totalCount]];
}

- (IBAction)shoppingCarClicked:(id)sender{
    
    if (self.stylesAndTotalPriceModel.totalCount <= 0) {
        [YYAlert showYYAlertWithTitle:@"购物车暂无数据" andDuration:kAlertToastDuration];
        return;
    }
    
    
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Order" bundle:[NSBundle mainBundle]];
    YYCartDetailViewController *cartVC = [storyboard instantiateViewControllerWithIdentifier:@"YYCartDetailViewController"];
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:cartVC];
    nav.navigationBar.hidden = YES;
    
    WeakSelf(weakSelf);
    [cartVC setGoBackButtonClicked:^(){
        [weakSelf dismissViewControllerAnimated:YES completion:^{
            //刷新购物车图标数据
            
            AppDelegate *appdelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
            weakSelf.stylesAndTotalPriceModel = getTotalBrandsOrderInfo(appdelegate.cartDesignerIdArray);
            
            [weakSelf.topBarShoppingCarButton updateButtonNumber:[NSString stringWithFormat:@"%i", self.stylesAndTotalPriceModel.totalCount]];
            
        }];
    }];
    
    [cartVC setToOrderList:^(){
        [weakSelf dismissViewControllerAnimated:NO completion:^{
            //刷新购物车图标数据
            
            AppDelegate *appdelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
            weakSelf.stylesAndTotalPriceModel = getTotalBrandsOrderInfo(appdelegate.cartDesignerIdArray);
            
            [weakSelf.topBarShoppingCarButton updateButtonNumber:[NSString stringWithFormat:@"%i", self.stylesAndTotalPriceModel.totalCount]];
            
            AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
            if ([appDelegate.cartDesignerIdArray count] == 0){
                //如果购物车为空了，进入订单列表界面
                [[NSNotificationCenter defaultCenter] postNotificationName:kShowOrderListNotification object:nil];
            }
        }];
    }];
    
    [self presentViewController:nav animated:YES completion:nil];
}

//刷新界面
- (void)reloadCollectionViewData{
    [self.collectionView headerEndRefreshing];
    [self.collectionView footerEndRefreshing];
    
    [self.collectionView reloadData];
    
    if ([self.online_opusSeriesArray count] == 0) {
        self.noDataView.hidden = NO;
    }else{
        self.noDataView.hidden = YES;
    }
}

- (void)loadDataByPageIndex:(int)pageIndex{

    if (![YYNetworkReachability connectedToNetwork]) {
        //如果网络不通的，取本地数据库缓存的数据

        [YYAlert showYYAlertWithTitle:kNetworkIsOfflineTips andDuration:kAlertToastDuration];
        return;
    }
    
    YYUser *user = [YYUser currentUser];
    WeakSelf(weakSelf);

    [YYOpusApi getSeriesListWithId:[user.userId intValue] pageIndex:pageIndex pageSize:kPageSize andBlock:^(YYRspStatusAndMessage *rspStatusAndMessage, YYOpusSeriesListModel *opusSeriesListModel, NSError *error) {
        if (rspStatusAndMessage.status == kCode100
            && opusSeriesListModel.result
            && [opusSeriesListModel.result count] > 0) {
            
            if (pageIndex == 1) {
                [_online_opusSeriesArray removeAllObjects];
            }
            weakSelf.currentPageInfo = opusSeriesListModel.pageInfo;
            [weakSelf.online_opusSeriesArray addObjectsFromArray:opusSeriesListModel.result];
          
        
        }
        [weakSelf reloadCollectionViewData];
        AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
        UIView *superView = appDelegate.window.rootViewController.view;
        
        [MBProgressHUD hideHUDForView:superView animated:YES];
        
        if (rspStatusAndMessage.status != kCode100) {
            [YYAlert showYYAlertWithTitle:rspStatusAndMessage.message  andDuration:kAlertToastDuration];
        }
    }];
}



- (void)addHeader
{
    WeakSelf(weakSelf);
    // 添加下拉刷新头部控件
    [self.collectionView addHeaderWithCallback:^{
        // 进入刷新状态就会回调这个Block
        
        [weakSelf loadDataByPageIndex:1];
        
    }];
    
}

- (void)addFooter
{
    WeakSelf(weakSelf);
    // 添加上拉刷新尾部控件
    [self.collectionView addFooterWithCallback:^{
        // 进入刷新状态就会回调这个Block
        
        if (![YYNetworkReachability connectedToNetwork]) {
            [YYAlert showYYAlertWithTitle:kNetworkIsOfflineTips andDuration:kAlertToastDuration];
            [weakSelf.collectionView footerEndRefreshing];
            return;
        }
        
        
        if ([weakSelf.online_opusSeriesArray count] > 0
            && weakSelf.currentPageInfo
            && !weakSelf.currentPageInfo.isLastPage) {
            [weakSelf loadDataByPageIndex:[weakSelf.currentPageInfo.pageIndex intValue]+1];
        }else{
           [weakSelf.collectionView footerEndRefreshing];
        }
        
    }];
}




#pragma mark -  UICollectionViewDataSource
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    UICollectionViewFlowLayout *layout = (UICollectionViewFlowLayout *)collectionView.collectionViewLayout;
    
    layout.sectionInset = UIEdgeInsetsMake(0, 0, 0, 15);
    
    if ([_online_opusSeriesArray count] > 0) {
        return [_online_opusSeriesArray count];
    }
    return 0;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString* reuseIdentifier = @"YYSeriesCollectionViewCell";
    YYSeriesCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:reuseIdentifier forIndexPath:indexPath];
    
    NSString *imageRelativePath = nil;
    NSString *title = nil;
    NSString *beginDate = @"";
    NSString *endDate = @"";

    NSString *order = nil;
    NSString *styleAmount = nil;
    long series_id = 0;
    int supplyStatus = -1;
    NSInteger authType= 0;
    NSComparisonResult compareResult1 = NSOrderedDescending;
    NSComparisonResult compareResult2 = NSOrderedDescending;
    
    if (indexPath.row < [_online_opusSeriesArray count]) {
        if (_online_opusSeriesArray
            && [_online_opusSeriesArray count] > indexPath.row) {
            YYOpusSeriesModel *opusSeriesModel = [_online_opusSeriesArray objectAtIndex:indexPath.row];
            imageRelativePath = opusSeriesModel.albumImg;
            series_id = [opusSeriesModel.id longValue];
            title = opusSeriesModel.name;
            beginDate = getShowDateByFormatAndTimeInterval(@"yy/MM/dd",[opusSeriesModel.supplyStartTime stringValue]);
            endDate = getShowDateByFormatAndTimeInterval(@"yy/MM/dd",[opusSeriesModel.supplyEndTime stringValue]);
            order = [NSString stringWithFormat:@"最晚下单 %@",getShowDateByFormatAndTimeInterval(@"yy/MM/dd",opusSeriesModel.orderDueTime)];
            styleAmount =  [NSString stringWithFormat:@"%i 款",[opusSeriesModel.styleAmount intValue]];
            
            supplyStatus = [opusSeriesModel.supplyStatus intValue];
            compareResult1 = compareNowDate([opusSeriesModel.supplyEndTime stringValue]);
            compareResult2 = compareNowDate(opusSeriesModel.orderDueTime);
            authType = [opusSeriesModel.authType integerValue];
        }
    }
    
    cell.series_id = series_id ;
    cell.imageRelativePath = imageRelativePath;
    cell.title = title;
    cell.order = order;
    cell.styleAmount = styleAmount;
    cell.authType = authType;
    if (supplyStatus == 0) {
        cell.produce = @"发货日期 马上发货";
        compareResult1 = NSOrderedSame;
    }else{
       cell.produce = [NSString stringWithFormat:@"发货日期 %@-%@",beginDate,endDate];
    }
    cell.compareResult1 = compareResult1;
    cell.compareResult2 = compareResult2;
    cell.indexPath = indexPath;
    cell.delegate = self;
    [cell updateUI];

    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    //这里要判断是用离线数据，还是缓存数据，还是在线数据
    
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Opus" bundle:[NSBundle mainBundle]];
    YYStyleDetailListViewController *styleDetailListViewController = [storyboard instantiateViewControllerWithIdentifier:@"YYStyleDetailListViewController"];
    BOOL isHaveOfflineData = NO;//有没有离线数据，如果有，直接读离线数据
    long _series_id = 0;
    int _designer_id = 0;
    YYOpusSeriesModel *opusSeriesModel = nil;
    if ([_online_opusSeriesArray count] > indexPath.row ) {
         opusSeriesModel = [_online_opusSeriesArray objectAtIndex:indexPath.row];
        _series_id = [opusSeriesModel.id longValue];
        _designer_id = [opusSeriesModel.designerId intValue];
    }
    
//    NSString *folderName = [NSString stringWithFormat:@"%li",_series_id];
//    NSString *offlineFilePath = [stringByAppendingPathComponent:folderName];
//    
//    NSFileManager *fileManager = [NSFileManager defaultManager];
//    if ([fileManager fileExistsAtPath:offlineFilePath]) {
//        //已经下载过
//        isHaveOfflineData = YES;
//    }
    
    if ([_online_opusSeriesArray count] > indexPath.row){
        styleDetailListViewController.opusSeriesModel = opusSeriesModel;
        styleDetailListViewController.seriesId = _series_id;
        styleDetailListViewController.designerId = _designer_id;
    }

    [self.navigationController pushViewController:styleDetailListViewController animated:YES];
}

#pragma mark - YYSeriesCollectionViewCellDelegate
-(void)downloadImages:(NSURL *)url andStorePath:(NSString *)storePath{
    WeakSelf(weakSelf);
    SDWebImageManager *manager = [SDWebImageManager sharedManager];
    __block NSString *blockStorePath = storePath;
    
    [manager downloadImageWithURL:url options:0 progress:^(NSInteger receivedSize, NSInteger expectedSize) {
    } completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, BOOL finished, NSURL *imageURL) {
        if (image) {
            [UIImagePNGRepresentation(image) writeToFile:blockStorePath atomically:YES];
            dispatch_async(dispatch_get_main_queue(), ^{
                //NSLog(@"imageUrl%@",storePath);
                [weakSelf.collectionView reloadData];
    
            });
        }
        blockStorePath = nil;
        return ;
    }];
    [weakSelf.collectionView reloadData];
}

-(void)operateHandler:(NSInteger)section androw:(NSInteger)row{
    if(section == -1 && row == -1){//更新下载进度
        [self.collectionView reloadData];
    }else{//更新权限更改
        WeakSelf(weakSelf);
        if ([_online_opusSeriesArray count] > row ) {
            YYOpusSeriesModel *opusSeriesModel = [_online_opusSeriesArray objectAtIndex:row];
            __block YYOpusSeriesModel *blockopusSeriesModel = opusSeriesModel;
            [YYOpusApi updateSeriesAuthType:[opusSeriesModel.id integerValue] authType:section andBlock:^(YYRspStatusAndMessage *rspStatusAndMessage, NSError *error) {
                if(rspStatusAndMessage.status == kCode100){
                    blockopusSeriesModel.authType = [[NSNumber alloc] initWithInt:section];
                    [weakSelf.collectionView reloadData];
                    [YYAlert showYYAlertWithTitle:@"修改成功" andDuration:kAlertToastDuration];
                }
            }];

        }
    }
}

-(UIView *)getview{
    return self.view;
}

@end
