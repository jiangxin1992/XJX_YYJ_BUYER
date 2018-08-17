//
//  YYBrandViewController.m
//  Yunejian
//
//  Created by Apple on 15/12/2.
//  Copyright © 2015年 yyj. All rights reserved.
//

#import "YYBrandViewController.h"

#import "YYTopBarShoppingCarButton.h"
#import "YYPageInfoModel.h"
#import "AppDelegate.h"
#import "YYMessageButton.h"
#import "YYConnMsgListController.h"
#import "YYOrderApi.h"
#import "YYConnApi.h"
#import "YYBrandSeriesListViewController.h"
#import "YYConnAddViewController.h"
#import "YYCartDetailViewController.h"
#import "UserDefaultsMacro.h"
#import "YYUserApi.h"
#import "TitlePagerView.h"
#import "YYBrandTableViewController.h"
#import "YYStylesAndTotalPriceModel.h"

@interface YYBrandViewController ()<ViewPagerDataSource, ViewPagerDelegate, TitlePagerViewDelegate,YYTableCellDelegate>
@property (weak, nonatomic) IBOutlet UIView *msgBtnContainer;
@property (nonatomic,strong) YYMessageButton *messageButton;
@property (weak, nonatomic) IBOutlet YYTopBarShoppingCarButton *topBarShoppingCarButton;
@property(nonatomic,strong) YYStylesAndTotalPriceModel *stylesAndTotalPriceModel;//总数
@property (strong, nonatomic) TitlePagerView *pagingTitleView;
@property (nonatomic, assign) NSInteger currentIndex;
@property(strong,nonatomic) YYBrandTableViewController *connedBrandTableVC;
@property(strong,nonatomic) YYBrandTableViewController *conningBrandTableVC;
@end

@implementation YYBrandViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.topBarShoppingCarButton.isRight = YES;
    [self.topBarShoppingCarButton initButton];
    [self updateShoppingCar];
    [self.topBarShoppingCarButton addTarget:self action:@selector(shoppingCarButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    
    _messageButton = [[YYMessageButton alloc] init];
    [_messageButton initButton:@""];
    [self unreadMsgAmountChangeNotification:nil];
    [_msgBtnContainer addSubview:_messageButton];
    [_messageButton addTarget:self action:@selector(messageButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(unreadMsgAmountChangeNotification:) name:UnreadMsgAmountChangeNotification object:nil];
    __weak UIView *weakContainerView = _msgBtnContainer;
    [_messageButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(weakContainerView.mas_bottom);
        make.left.equalTo(weakContainerView.mas_left);
        make.top.equalTo(weakContainerView.mas_top);
        make.right.equalTo(weakContainerView.mas_right);
    }];
    
    if (!_pagingTitleView) {
        self.pagingTitleView = [[TitlePagerView alloc] init];
        self.pagingTitleView.frame = CGRectMake(60, 24 + (kIPhoneX ? 24.f : 0.f), SCREEN_WIDTH-60-60, 40);
        self.pagingTitleView.font = [UIFont systemFontOfSize:14];
        NSArray *titleArray = @[NSLocalizedString(@"合作品牌",nil),NSLocalizedString(@"已经邀请_short",nil)];
        float titleViewWidth = [TitlePagerView calculateTitleWidth:titleArray withFont:self.pagingTitleView.font];
        self.pagingTitleView.width = titleViewWidth;
        float titleViewOffsetX = (SCREEN_WIDTH-60-60 - titleViewWidth)/2;
        if(IsPhone6_gt){
            //phone 6 以上
            self.pagingTitleView.x = 60 + MAX(0, titleViewOffsetX);
        }else{
            //phone 6 以下
            self.pagingTitleView.x = (60 + MAX(0, titleViewOffsetX))*2.0f/3.0f;
        }
        [self.pagingTitleView addObjects:titleArray];
        self.pagingTitleView.delegate = self;
    }
    self.pagingTitleView.backgroundColor = [UIColor clearColor];
    [self.view addSubview:self.pagingTitleView];

    self.dataSource = self;
    self.delegate = self;
    
    // Do not auto load data
    self.manualLoadData = YES;
    self.currentIndex = 0;
    [self reloadData];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(updateShoppingCarNotification:)
                                                 name:kUpdateShoppingCarNotification
                                               object:nil];
}
- (IBAction)backAction:(id)sender {
    if (_cancelButtonClicked) {
        _cancelButtonClicked();
    }
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self updateShoppingCar];
    YYBrandTableViewController *tableViewController = (YYBrandTableViewController *)[self viewControllerAtIndex:_currentIndex];
    if(tableViewController != nil){
        [tableViewController reloadBrandData];
    }

    // 进入埋点
    [MobClick beginLogPageView:kYYPageBrand];
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    // 退出埋点
    [MobClick endLogPageView:kYYPageBrand];
}

- (void)updateShoppingCarNotification:(NSNotification *)note{
    [self updateShoppingCar];
}


- (void)updateShoppingCar{
    WeakSelf(ws);
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        dispatch_async(dispatch_get_main_queue(), ^{
            AppDelegate *appdelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
            ws.stylesAndTotalPriceModel = getLocalShoppingCartStyleCount(appdelegate.cartDesignerIdArray);
            [ws.topBarShoppingCarButton updateButtonNumber:[NSString stringWithFormat:@"%i", self.stylesAndTotalPriceModel.totalStyles]];
        });
    });
}


- (void)unreadMsgAmountChangeNotification:(NSNotification *)notification{
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


- (void)messageButtonClicked:(id)sender {
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    [appDelegate showMessageView:nil parentViewController:self];

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)shoppingCarClicked:(id)sender{
}

- (void)addBrandHandler{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Brand" bundle:[NSBundle mainBundle]];
    YYConnAddViewController *addBrandViewController = [storyboard instantiateViewControllerWithIdentifier:@"YYConnAddViewController"];
    addBrandViewController.isMainView = NO;
    [self.navigationController pushViewController:addBrandViewController animated:YES];
}

#pragma YYTableCellDelegate
-(void)btnClick:(NSInteger)row section:(NSInteger)section andParmas:(NSArray *)parmas{
    if(parmas == nil )
        return;
    NSString *type = [parmas objectAtIndex:0];
    
    if([type isEqualToString:@"brandInfo"] ){

        YYConnBrandInfoModel * brandInfoModel = [parmas objectAtIndex:1];//[self.brandListArray objectAtIndex:row];
        AppDelegate *appdelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
        NSString *brandName = (brandInfoModel.brandName?brandInfoModel.brandName:@"");
        NSString *logoPath = (brandInfoModel.logoPath?brandInfoModel.logoPath:@"");
        [appdelegate showBrandInfoViewController:brandInfoModel.designerId WithBrandName:brandName WithLogoPath:logoPath parentViewController:self WithHomePageBlock:nil WithSelectedValue:nil];
     
    }else if([type isEqualToString:@"addBrand"]){
        [self addBrandHandler];
    }
}
#pragma mark --进入购物车
- (void)shoppingCarButtonClicked:(id)sender{
    
    if (self.stylesAndTotalPriceModel.totalStyles <= 0) {
        [YYToast showToastWithView:self.view title:NSLocalizedString(@"购物车暂无数据",nil)  andDuration:kAlertToastDuration];
        return;
    }
    
    
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Order" bundle:[NSBundle mainBundle]];
    YYCartDetailViewController *cartVC = [storyboard instantiateViewControllerWithIdentifier:@"YYCartDetailViewController"];
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:cartVC];
    nav.navigationBar.hidden = YES;
    
    WeakSelf(ws);
    [cartVC setGoBackButtonClicked:^(){
        [ws dismissViewControllerAnimated:YES completion:^{
            //刷新购物车图标数据
            [ws updateShoppingCar];
        }];
    }];
    
    [cartVC setToOrderList:^(){
        [ws dismissViewControllerAnimated:NO completion:^{
            //进入订单列表界面
            [[NSNotificationCenter defaultCenter] postNotificationName:kShowOrderListNotification object:nil];
        }];
    }];
    
    [self presentViewController:nav animated:YES completion:nil];
}

#pragma mark - ViewPagerDataSource
- (NSUInteger)numberOfTabsForViewPager:(ViewPagerController *)viewPager {
    return 2;
}

- (UIViewController *)viewPager:(ViewPagerController *)viewPager contentViewControllerForTabAtIndex:(NSUInteger)index {
    if (index == 0) {
        return [self createConnedTableVC];
    } else if (index == 1) {
        return [self createConningTableVC];
    } else {
        return nil;
    }
}

- (UIViewController *)createConnedTableVC {
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Brand" bundle:[NSBundle mainBundle]];
    self.connedBrandTableVC = [storyboard instantiateViewControllerWithIdentifier:@"YYBrandTableViewController"];
    self.connedBrandTableVC.currentListType = 1;
    self.connedBrandTableVC.delegate = self;
    return self.connedBrandTableVC;
}

- (UIViewController *)createConningTableVC {
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Brand" bundle:[NSBundle mainBundle]];
    self.conningBrandTableVC = [storyboard instantiateViewControllerWithIdentifier:@"YYBrandTableViewController"];
    self.conningBrandTableVC.currentListType = 2;
    self.conningBrandTableVC.delegate = self;
    return self.conningBrandTableVC;
}



- (void)viewPager:(ViewPagerController *)viewPager didChangeTabToIndex:(NSUInteger)index {
    self.currentIndex = index;
}

#pragma TitlePagerViewDelegate
- (void)didTouchBWTitle:(NSUInteger)index {
    
    UIPageViewControllerNavigationDirection direction;
    
    if (self.currentIndex == index) {
        return;
    }
    
    if (index > self.currentIndex) {
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
    _currentIndex = index;
    [self.pagingTitleView adjustTitleViewByIndex:index];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    CGFloat contentOffsetX = scrollView.contentOffset.x;
    
    if (self.currentIndex != 0 && contentOffsetX <= SCREEN_WIDTH * 2) {
        contentOffsetX += SCREEN_WIDTH * self.currentIndex;
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

@end
