//
//  YYUserCollectionViewController.m
//  YunejianBuyer
//
//  Created by yyj on 2017/7/14.
//  Copyright © 2017年 Apple. All rights reserved.
//

#import "YYUserCollectionViewController.h"

#import "UIButton+Custom.h"

#import "YYOrderingApi.h"
#import "YYNavView.h"
#import "YYSwitchView.h"
#import "MBProgressHUD.h"
#import "YYOpusApi.h"
#import "AppDelegate.h"
#import "YYInventoryBoardModel.h"

#import "YYChooseStyleViewController.h"
#import "YYUserStyleCollectionViewController.h"
#import "YYBrandSeriesViewController.h"
#import "YYUserSeriesCollectionViewController.h"
#import "UINavigationController+YRBackGesture.h"

@interface YYUserCollectionViewController ()

@property (nonatomic,assign) NSInteger currentPage;
@property (nonatomic,strong) YYNavView *navView;
@property (nonatomic,strong) YYSwitchView *switchView;

@property (nonatomic,strong) UIPageViewController *pageVc;
@property (nonatomic,strong) YYUserStyleCollectionViewController *left;
@property (nonatomic,strong) YYUserSeriesCollectionViewController *right;

@end

@implementation YYUserCollectionViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self SomePrepare];
    [self UIConfig];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    // 禁用返回手势
    self.navigationController.enableBackGesture = NO;
    // 进入埋点
    [MobClick beginLogPageView:kYYPageUserCollection];
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    self.navigationController.enableBackGesture = YES;
    // 退出埋点
    [MobClick endLogPageView:kYYPageUserCollection];
}

#pragma mark - SomePrepare
-(void)SomePrepare
{
    [self PrepareData];
    [self PrepareUI];
}
-(void)PrepareData{}
-(void)PrepareUI{
    self.view.backgroundColor = _define_white_color;
    
    _navView = [[YYNavView alloc] initWithTitle:NSLocalizedString(@"我的收藏",nil) WithSuperView:self.view haveStatusView:YES];
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
    [self CreateSwitchView];
    [self CreatePageView];
}
-(void)CreateSwitchView{
    _switchView = [[YYSwitchView alloc] initWithTitleArr:@[NSLocalizedString(@"款式",nil),NSLocalizedString(@"系列",nil)] WithSelectIndex:_currentPage WithBlock:^(NSString *type, NSInteger index) {
        //切换
        if([type isEqualToString:@"switch"]){
            NSLog(@"index = %ld",index);
            _currentPage = index;
            [self switchAction];
        }
    }];
    [self.view addSubview:_switchView];
    [_switchView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.mas_equalTo(0);
        make.top.mas_equalTo(_navView.mas_bottom).with.offset(0);
        make.height.mas_equalTo(40);
    }];
}
-(void)CreatePageView
{
    _pageVc = [[UIPageViewController alloc]initWithTransitionStyle:1 navigationOrientation:0 options:nil];
    _pageVc.view.frame = CGRectMake(0, 105 + (kIPhoneX?24.f:0), SCREEN_WIDTH , SCREEN_HEIGHT - (105 + (kIPhoneX?24.f:0)));
    if(!_left)
    {
        WeakSelf(ws);
        _left=[[YYUserStyleCollectionViewController alloc] init];
        [_left setStyleBlock:^(NSString *type,YYUserStyleModel *userStyleModel,NSIndexPath *indexPath){
            [ws leftViewBlockWithType:type WithUserStyleModel:userStyleModel WithIndexPath:indexPath];
        }];
    }
    [_pageVc setViewControllers:@[_left] direction:1 animated:YES completion:nil];
    _currentPage=0;
    [self.view addSubview:_pageVc.view];
}

#pragma mark - SomeAction
//删除收藏系列
-(void)deleteSeriesWithModel:(YYUserSeriesModel *)userSeriesModel WithIndexPath:(NSIndexPath *)indexPath{

        [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        [YYOpusApi updateSeriesCollectStateBySeriesId:[userSeriesModel.seriesId integerValue] isCollect:NO andBlock:^(YYRspStatusAndMessage *rspStatusAndMessage, NSError *error) {
            if (rspStatusAndMessage.status == kCode100) {
                [self.right deleteRowsAtIndexPaths:indexPath];
            }else{
                [YYToast showToastWithView:self.view title:rspStatusAndMessage.message andDuration:kAlertToastDuration];
            }
            [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
        }];
}
//删除收藏款式
-(void)deleteStyleWithModel:(YYUserStyleModel *)userStyleModel WithIndexPath:(NSIndexPath *)indexPath{
    
        [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        [YYOpusApi updateStyleCollectStateByStyleId:[userStyleModel.styleId integerValue] isCollect:NO andBlock:^(YYRspStatusAndMessage *rspStatusAndMessage, NSError *error) {
            if (rspStatusAndMessage.status == kCode100) {
                [self.left deleteRowsAtIndexPaths:indexPath];
            }else{
                [YYToast showToastWithView:self.view title:rspStatusAndMessage.message andDuration:kAlertToastDuration];
            }
            [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
        }];
}
-(void)leftViewBlockWithType:(NSString *)type WithUserStyleModel:(YYUserStyleModel *)userStyleModel WithIndexPath:(NSIndexPath *)indexPath{
    if([type isEqualToString:@"style_delete"]){
        [self deleteStyleWithModel:userStyleModel WithIndexPath:indexPath];
    }else if([type isEqualToString:@"go_styleview"]){
        if(self.cancelButtonClicked){
            self.cancelButtonClicked();
            [[NSNotificationCenter defaultCenter] postNotificationName:kShowStyleNotification object:nil];
        }
    }else if([type isEqualToString:@"style_detail"]){
        //进入款式详情页
        if([userStyleModel.status integerValue] == 0){
            AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
            
            YYInventoryBoardModel *infoModel = [self modelTransformByUserStyleModel:userStyleModel];
            [appDelegate showStyleInfoViewController:infoModel parentViewController:self];
        }
    }
}
-(void)rightViewBlockWithType:(NSString *)type WithUserSeriesModel:(YYUserSeriesModel *)userSeriesModel WithIndexPath:(NSIndexPath *)indexPath{
    if([type isEqualToString:@"series_delete"]){
        [self deleteSeriesWithModel:userSeriesModel WithIndexPath:indexPath];
    }else if([type isEqualToString:@"series_detail"]){
        //进入系列详情页
        if([userSeriesModel.status integerValue] == 0){

            NSString *brandName = [NSString isNilOrEmpty:userSeriesModel.brandName]?@"":userSeriesModel.brandName;
            NSString *brandLogo = [NSString isNilOrEmpty:userSeriesModel.brandLogo]?@"":userSeriesModel.brandLogo;
            AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
            [appDelegate showSeriesInfoViewController:userSeriesModel.designerId seriesId:userSeriesModel.seriesId designerInfo:@[brandName,brandLogo] parentViewController:self];
            
        }
    }else if([type isEqualToString:@"go_seriesview"]){
        if(self.cancelButtonClicked){
            self.cancelButtonClicked();
            [[NSNotificationCenter defaultCenter] postNotificationName:kShowStyleNotification object:nil];
        }
    }
}
-(void)switchAction
{
    if(_currentPage>0){
        if(!_right)
        {
            WeakSelf(ws);
            _right = [[YYUserSeriesCollectionViewController alloc] init];
            [_right setStyleBlock:^(NSString *type,YYUserSeriesModel *userSeriesModel,NSIndexPath *indexPath){
                [ws rightViewBlockWithType:type WithUserSeriesModel:userSeriesModel WithIndexPath:indexPath];
            }];
        }
        [_pageVc setViewControllers:@[_right] direction:0 animated:YES completion:nil];
    }else{
        if(!_left)
        {
            WeakSelf(ws);
            _left=[[YYUserStyleCollectionViewController alloc] init];
            [_left setStyleBlock:^(NSString *type,YYUserStyleModel *userStyleModel,NSIndexPath *indexPath){
                [ws leftViewBlockWithType:type WithUserStyleModel:userStyleModel WithIndexPath:indexPath];
            }];
        }
        [_pageVc setViewControllers:@[_left] direction:1 animated:YES completion:nil];
    }
}
-(YYInventoryBoardModel *)modelTransformByUserStyleModel:(YYUserStyleModel *)userStyleModel{
    YYInventoryBoardModel *tempModel = [[YYInventoryBoardModel alloc] init];
    tempModel.albumImg = userStyleModel.albumImg;
    tempModel.brandName = userStyleModel.brandName;
    tempModel.brandLogo = userStyleModel.brandLogo;
    tempModel.designerId = userStyleModel.designerId;
    tempModel.styleId = userStyleModel.styleId;
    tempModel.styleName = userStyleModel.styleName;
    tempModel.seriesName = userStyleModel.seriesName;
    return tempModel;
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
}
@end
