//
//  YYStyleDetailViewController.m
//  Yunejian
//
//  Created by yyj on 15/7/24.
//  Copyright (c) 2015年 yyj. All rights reserved.
//

#import "YYStyleDetailViewController.h"

#import "YYDetailContentViewController.h"
#import "YYTopBarShoppingCarButton.h"
#import "YYOpusStyleModel.h"

#import "YYCartDetailViewController.h"
#import "YYStylesAndTotalPriceModel.h"
#import "YYStyleInfoModel.h"
#import "AppDelegate.h"
#import "YYOpusSeriesModel.h"
#import "YYUserApi.h"

#define kDicKeyPrefix @"kDicKeyPrefix_"

static NSInteger tagOffset = 90000;

@interface YYStyleDetailViewController ()<UIScrollViewDelegate>

@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;

@property (nonatomic,strong) UIView *view1;
@property (nonatomic,strong) UIView *view2;
@property (nonatomic,strong) UIView *view3;

@property (nonatomic,strong) UIView *tempView;

@property (nonatomic,strong) NSMutableDictionary *localCacheDic;
@property (nonatomic,strong) NSMutableArray *templocalCacheArr;


@property (nonatomic,assign) int currentPage; //当前页

@property(nonatomic,strong) YYStylesAndTotalPriceModel *stylesAndTotalPriceModel;//总数
@property (nonatomic, strong) YYTopBarShoppingCarButton *topBarShoppingCarButton;
@end

@implementation YYStyleDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self SomePrepare];
    [self UIConfig];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    //在视图出现的时候更新购物车数据
    [self updateShoppingCar];
    // 进入埋点
    [MobClick beginLogPageView:kYYPageStyleDetail];
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    // 退出埋点
    [MobClick endLogPageView:kYYPageStyleDetail];
}

#pragma mark - SomePrepare
-(void)SomePrepare
{
    [self PrepareData];
    [self PrepareUI];
}

-(void)PrepareData{
    
    self.currentPage = (int)self.currentIndex;
    
    self.totalPages = [self.onlineOrOfflineOpusStyleArray count];
    self.localCacheDic = [[NSMutableDictionary alloc] initWithCapacity:0];
    self.templocalCacheArr = [[NSMutableArray alloc] init];
    self.tempView = [[UIView alloc] init];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateShoppingCarNotification:) name:kUpdateShoppingCarNotification object:nil];
}
-(void)PrepareUI{}
#pragma mark - UIConfig
-(void)UIConfig{
    [self CreateOtherView];
    [self CreateNavView];
}
-(void)CreateOtherView{
    UIScrollView *scrollView = _scrollView;
    scrollView.delegate = self;
    scrollView.pagingEnabled = YES;
    scrollView.backgroundColor = [UIColor whiteColor];
    
    self.automaticallyAdjustsScrollViewInsets = NO;
    UIView *tempContainer = [[UIView alloc] init];
    __weak UIScrollView *weakScrollView = _scrollView;
    
    [scrollView addSubview:tempContainer];
    [tempContainer mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(weakScrollView);
        make.top.and.left.equalTo(weakScrollView);
        make.height.equalTo(weakScrollView);
    }];
    self.view1 = [[UIView alloc] init];
    self.view2 = [[UIView alloc] init];
    self.view3 = [[UIView alloc] init];
    
    int count = 3;
    if (_totalPages == 1) {
        count = 1;
    }else if (_totalPages == 2){
        count = 2;
    }
    
    
    UIView *lastView = nil;
    for ( int i = 1 ; i <= count ; ++i )
    {
        UIView *subv = nil;
        if (i == 1) {
            subv = _view1;
        }else if (i == 2) {
            subv = _view2;
        }else if (i == 3) {
            subv = _view3;
        }
        
        [tempContainer addSubview:subv];
        
        __weak UIView *weakContainer = tempContainer;
        [subv mas_makeConstraints:^(MASConstraintMaker *make) {
            
            make.top.equalTo(weakContainer);
            make.width.mas_equalTo(SCREEN_WIDTH);
            //            make.height.mas_equalTo(SCREEN_HEIGHT-64);
            make.height.mas_equalTo(SCREEN_HEIGHT);
            if ( lastView )
            {
                make.left.mas_equalTo(lastView.mas_right);
            }
            else
            {
                make.left.mas_equalTo(weakContainer.mas_left);
            }
        }];
        
        lastView = subv;
    }
    
    [tempContainer mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(lastView.mas_right);
    }];
    
    if (_totalPages > 2) {
        _scrollView.contentSize = CGSizeMake(SCREEN_WIDTH*3, 0);
        //始终将scrollview置为第2页
        [_scrollView setContentOffset:CGPointMake(SCREEN_WIDTH, 0.0)];
    }else{
        if (_totalPages == 2) {
            _scrollView.contentSize = CGSizeMake(SCREEN_WIDTH*2, 0);
            
            if (_currentPage == 1) {
                [_scrollView setContentOffset:CGPointMake(SCREEN_WIDTH, 0.0)];
            }
        }
    }
    
    [self moveView];
    if (self.isModityCart) {
        self.topBarShoppingCarButton.hidden = YES;
    }
}
-(void)CreateNavView{
    self.topBarShoppingCarButton = [YYTopBarShoppingCarButton buttonWithType:UIButtonTypeCustom];
    [self.view addSubview:self.topBarShoppingCarButton];
    [self.topBarShoppingCarButton initCircleButton];
    [self updateShoppingCar];
    [self.topBarShoppingCarButton addTarget:self action:@selector(shoppingCarButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    [self.topBarShoppingCarButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(36);
        make.height.mas_equalTo(36);
        make.right.mas_equalTo(-7);
        make.top.mas_equalTo(kStatusBarHeight);
    }];
    
    UIButton *backBtn = [UIButton getCustomImgBtnWithImageStr:@"topback_circle_icon" WithSelectedImageStr:nil];
    [self.view addSubview:backBtn];
    [backBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(36);
        make.height.mas_equalTo(36);
        make.left.mas_equalTo(7);
        make.top.mas_equalTo(kStatusBarHeight);
    }];
    backBtn.adjustsImageWhenHighlighted = NO;
    [backBtn addTarget:self action:@selector(backAction) forControlEvents:UIControlEventTouchUpInside];
}
#pragma mark - SomeAction
- (void)moveView{
    //scrollview结束滚动时判断是否已经换页
    
    NSString *nowTitle = nil;
    NSInteger nowIndex = 0;
    //始终将scrollview置为第2页
    
    if (_totalPages > 2) {
        if (_scrollView.contentOffset.x > SCREEN_WIDTH) {
            
            //如果是最后一张图片，则将主imageview内容置为第一张图片
            //如果不是最后一张图片，则将主imageview内容置为下一张图片
            if (_currentPage < (_totalPages - 1)) {
                _currentPage ++;
            } else {
                _currentPage = 0;
            }
            
        } else if (_scrollView.contentOffset.x < SCREEN_WIDTH) {
            
            //如果是第一张图片，则将主imageview内容置为最后一张图片
            //如果不是第一张图片，则将主imageview内容置为上一张图片
            if (_currentPage > 0) {
                _currentPage --;
            } else {
                _currentPage = (int)_totalPages - 1;
            }
            
        }
        
        nowTitle = [NSString stringWithFormat:@"%i/%li",_currentPage+1,(long)_totalPages];
        nowIndex = _currentPage;
        [_scrollView setContentOffset:CGPointMake(SCREEN_WIDTH, 0.0)];
    }else if (_totalPages == 2) {
        if (_scrollView.contentOffset.x == SCREEN_WIDTH) {
            nowTitle = @"2/2";
            nowIndex = 1;
        }else{
            nowTitle = @"1/2";
            nowIndex = 0;
        }
    }else if(_totalPages == 1){
        nowTitle = @"1/1";
        nowIndex = 0;
    }
    nowTitle = @"";
    YYOpusStyleModel *tempStyleModel = nil;
    if ([_onlineOrOfflineOpusStyleArray count] > nowIndex) {
        tempStyleModel = [_onlineOrOfflineOpusStyleArray objectAtIndex:nowIndex];
        nowTitle = tempStyleModel.name;
    }
    
    [self addView];
    
}
- (void)addView{
    
    [self cacheDataByCurrentPage];
    
    //scrollview上添加三个imageview
    //第一个imageview的图片为当前图片的前一张图片（如果当前图片为第一张则显示最后一张图片）
    //第二个imageview的图片为当前图片
    //第三个imageview的图片为当前图片的后一张图片（如果当前图片为最后一张则显示第一张图片）
    
    
    NSString *key01 = [NSString stringWithFormat:@"%@%li",kDicKeyPrefix,(_currentPage == 0 ? (_totalPages - 1) : (_currentPage - 1))];
    UIViewController *tempViewController01 = [_localCacheDic objectForKey:key01];
    
    NSString *key02 = [NSString stringWithFormat:@"%@%i",kDicKeyPrefix,_currentPage];
    UIViewController *tempViewController02 = [_localCacheDic objectForKey:key02];
    
    NSString *key03 = [NSString stringWithFormat:@"%@%i",kDicKeyPrefix,(_currentPage == (_totalPages - 1) ? 0 : (_currentPage + 1))];
    UIViewController *tempViewController03 = [_localCacheDic objectForKey:key03];
    
    [self clearSubview];
    
    
    if (_totalPages == 2) {
        key01 = [NSString stringWithFormat:@"%@%i",kDicKeyPrefix,0];
        tempViewController01 = [_localCacheDic objectForKey:key01];
        
        key02 = [NSString stringWithFormat:@"%@%i",kDicKeyPrefix,1];
        tempViewController02 = [_localCacheDic objectForKey:key02];
        
        if (self.view1.subviews.count <= 0) {
            [self.view1 addSubview:tempViewController01.view];
            [self setChildView:tempViewController01.view];
        }
        if (self.view2.subviews.count <= 0) {
            [self.view2 addSubview:tempViewController02.view];
            [self setChildView:tempViewController02.view];
        }
    }else if (_totalPages == 1){
        key01 = [NSString stringWithFormat:@"%@%i",kDicKeyPrefix,0];
        tempViewController01 = [_localCacheDic objectForKey:key01];
        
        if (self.view1.subviews.count <= 0) {
            [self.view1 addSubview:tempViewController01.view];
            [self setChildView:tempViewController01.view];
        }
    }else{
        if (self.view1.subviews.count <= 0) {
            [self.view1 addSubview:tempViewController01.view];
            [self setChildView:tempViewController01.view];
        }
        if (self.view2.subviews.count <= 0) {
            [self.view2 addSubview:tempViewController02.view];
            [self setChildView:tempViewController02.view];
        }
        if (self.view3.subviews.count <= 0) {
            [self.view3 addSubview:tempViewController03.view];
            [self setChildView:tempViewController03.view];
        }
    }
}

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

- (void)updateShoppingCar{
    WeakSelf(ws);
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        dispatch_async(dispatch_get_main_queue(), ^{
            AppDelegate *appdelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
            ws.stylesAndTotalPriceModel = getLocalShoppingCartStyleCount(appdelegate.cartDesignerIdArray);
            [ws.topBarShoppingCarButton updateButtonNumber:[NSString stringWithFormat:@"%li", self.stylesAndTotalPriceModel.totalStyles]];
        });
    });
}

//缓存到内存
- (void)cacheDataByCurrentPage{
    int offset = 1;
    
    NSMutableArray *needCacheArray = [[NSMutableArray alloc] initWithCapacity:0];
    
    for (int j= _currentPage-offset; j<=_currentPage+offset; j++) {
        NSInteger nowIndex = j;
        if (nowIndex < 0) {
            nowIndex = _totalPages - labs(nowIndex);
        }
        
        if (nowIndex >= _totalPages) {
            nowIndex = nowIndex - _totalPages;
        }
        
        if (nowIndex>=0 && nowIndex<_totalPages) {
            [needCacheArray addObject:[NSNumber numberWithInteger:nowIndex]];
            
            NSString *key = [NSString stringWithFormat:@"%@%li",kDicKeyPrefix,(long)nowIndex];
            YYOpusStyleModel *tempStyleModel = nil;
            if (![_localCacheDic objectForKey:key]) {
                
                tempStyleModel = [_onlineOrOfflineOpusStyleArray objectAtIndex:nowIndex];
                
                UIViewController *viewController = [self loadViewByYYOpusStyleModel:tempStyleModel];
                UIView *tempView = viewController.view;
                tempView.tag = tagOffset+nowIndex;
                
                [self.tempView addSubview:tempView];
                [_localCacheDic setObject:viewController forKey:key];
            }
        }
    }
    
    NSArray *keys = [_localCacheDic allKeys];

    if (keys
        && [keys count] > 0) {
        for (NSString *key in keys) {
            NSString *index = [key substringFromIndex:14];
            
            NSNumber *number = [NSNumber numberWithInt:[index intValue]];
            if (![needCacheArray containsObject:number]) {
                UIView *deleteView = [self.tempView viewWithTag:tagOffset+[index integerValue]];
                
                if (deleteView) {
                    [deleteView removeFromSuperview];
                }
                UIViewController *viewController = [_localCacheDic objectForKey:key];
                [_localCacheDic removeObjectForKey:key];
                [_templocalCacheArr addObject:viewController];

            }
        }
    }
}


- (UIViewController *)loadViewByYYOpusStyleModel:(YYOpusStyleModel *)opusStyleModel {
    //return [[UIViewController alloc] init];
    
    YYDetailContentViewController *detailContentViewController = nil;
    bool iscacheViewController = NO;
    if([_templocalCacheArr count] > 0){
        detailContentViewController = [_templocalCacheArr objectAtIndex:0];
        [_templocalCacheArr removeObjectAtIndex:0];
        iscacheViewController = YES;
    }else{
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Opus" bundle:[NSBundle mainBundle]];
        detailContentViewController = [storyboard instantiateViewControllerWithIdentifier:@"YYDetailContentViewController"];
    }

    [detailContentViewController setDetailContentBlock:^(NSString *type,YYStyleInfoModel *styleInfoModel){
        if([type isEqualToString:@"enter_designer"]){
            [self enterDesignerView:styleInfoModel];
        }
    }];
    detailContentViewController.currentOpusStyleModel = opusStyleModel;
    detailContentViewController.opusSeriesModel = _opusSeriesModel;
    detailContentViewController.selectTaxType=_selectTaxType;
    detailContentViewController.styleDetailViewController = self;
    if(iscacheViewController){
        [detailContentViewController loadStyleInfo];
        [detailContentViewController updateUI];
    }
    return detailContentViewController;
}



-(void)setChildView:(UIView *)view{
    [view mas_makeConstraints:^(MASConstraintMaker *make) {
        //make.width.mas_equalTo(SCREEN_WIDTH);
        //make.height.mas_equalTo(@(SCREEN_HEIGHT-64));
        make.top.mas_equalTo(0);
        make.left.mas_equalTo(0);
        make.right.mas_equalTo(0);
        make.bottom.mas_equalTo(0);
    }];
}

- (void)clearSubview{
    NSArray *array1 = [self.view1 subviews];
    for (UIView *view in array1) {
        [view removeFromSuperview];
    }
    
    NSArray *array2 = [self.view2 subviews];
    for (UIView *view in array2) {
        [view removeFromSuperview];
    }
    
    NSArray *array3 = [self.view3 subviews];
    for (UIView *view in array3) {
        [view removeFromSuperview];
    }

}

-(void)enterDesignerView:(YYStyleInfoModel *)_styleInfoModel{
    if([_styleInfoModel.style.designerId integerValue]){

        AppDelegate *appdelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
        NSString *brandName = [NSString isNilOrEmpty:_styleInfoModel.style.designerBrandName]?@"":_styleInfoModel.style.designerBrandName;
        NSString *logoPath = [NSString isNilOrEmpty:_styleInfoModel.style.designerBrandLogo]?@"":_styleInfoModel.style.designerBrandLogo;
        [appdelegate showBrandInfoViewController:_styleInfoModel.style.designerId WithBrandName:brandName WithLogoPath:logoPath parentViewController:self WithHomePageBlock:nil WithSelectedValue:nil];

    }
}

-(void)backAction{
    [self.navigationController popViewControllerAnimated:YES];
}
- (void)updateShoppingCarNotification:(NSNotification *)note{
    [self updateShoppingCar];
}

#pragma mark - UIScrollViewDelegate

//通过scrollview委托来实现首尾相连的效果
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    _finigerTouched = YES;
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
    if (_finigerTouched) {
        if (_totalPages > 1) {
            
            [self moveView];
        }
        _finigerTouched = NO;
    }
}

- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView{
    if (!_finigerTouched) {
        if (_totalPages > 1) {
            [self moveView];
        }
    }
}

#pragma mark - Other

- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    [self addView];
}

- (void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
@end
