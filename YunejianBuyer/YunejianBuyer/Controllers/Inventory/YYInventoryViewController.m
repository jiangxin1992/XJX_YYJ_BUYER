//
//  YYInventoryViewController.m
//  YunejianBuyer
//
//  Created by Victor on 2018/6/19.
//  Copyright © 2018年 Apple. All rights reserved.
//

// c文件 —> 系统文件（c文件在前）

// 控制器
#import "YYInventoryViewController.h"
#import "YYWarehousingViewController.h"
#import "YYMerchandiseInventoryViewController.h"

// 自定义视图
#import "YYNavView.h"
#import "YYMessageButton.h"
#import "TitlePagerView.h"
#import "YYNoDataView.h"

// 接口

// 分类

// 自定义类和三方类（ cocoapods类 > model > 工具类 > 其他）
#import "YYUntreatedMsgAmountModel.h"
#import "AppDelegate.h"

@interface YYInventoryViewController () <TitlePagerViewDelegate, ViewPagerDataSource, ViewPagerDelegate, UITextFieldDelegate>

@property (nonatomic, strong) YYNavView *navView;
@property (nonatomic, strong) YYMessageButton *messageButton;
@property (nonatomic, strong) UIView *searchView;
@property (nonatomic, strong) UITextField *searchField;
@property (nonatomic, strong) TitlePagerView *titlePagerView;
@property (nonatomic, strong) YYMerchandiseInventoryViewController *merchandiseInventoryVC;
@property (nonatomic, strong) YYWarehousingViewController *warehousingVC;
@property (nonatomic, strong) YYWarehousingViewController *EXwarehouseVC;

@property (nonatomic, strong) UITapGestureRecognizer *tapGestureRecognizer;

@end

@implementation YYInventoryViewController

#pragma mark - --------------生命周期--------------
- (void)viewDidLoad {
    [super viewDidLoad];
    [self SomePrepare];
    [self UIConfig];
    [self RequestData];
}

#pragma mark - --------------SomePrepare--------------
- (void)SomePrepare {
    [self PrepareData];
    [self PrepareUI];
}

- (void)PrepareData {
    self.merchandiseInventoryVC = [[YYMerchandiseInventoryViewController alloc] init];
    self.merchandiseInventoryVC.navigationController = self.navigationController;
    
    self.warehousingVC = [[YYWarehousingViewController alloc] init];
    self.warehousingVC.navigationController = self.navigationController;
    self.warehousingVC.isEXwarehouse = NO;
    
    self.EXwarehouseVC = [[YYWarehousingViewController alloc] init];
    self.EXwarehouseVC.navigationController = self.navigationController;
    self.EXwarehouseVC.isEXwarehouse = YES;
}

- (void)PrepareUI {
    self.dataSource = self;
    self.delegate = self;
    self.view.backgroundColor = _define_white_color;

    self.navView = [[YYNavView alloc] initWithTitle:nil WithSuperView: self.view haveStatusView:YES];
    [self.navView hidesBackButton];
    [self initMessageButton];
    [self initSearchField];

    [self reloadDataWithIndex:_currentIndex];
    [self viewControllerAtIndex:_currentIndex];
}

#pragma mark - --------------UIConfig----------------------
-(void)UIConfig {
    UIView *lineView = [[UIView alloc] init];
    lineView.backgroundColor = [UIColor colorWithHex:@"d3d3d3"];
    [self.view addSubview:lineView];
    WeakSelf(ws);
    [lineView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(1);
        make.top.equalTo(ws.navView.mas_bottom).with.mas_offset(43);
        make.left.mas_equalTo(0);
        make.right.mas_equalTo(0);
    }];

    [self createPagingTitleView];
}

-(void)createPagingTitleView{
    NSArray *titleArray = @[NSLocalizedString(@"商品库存",nil),NSLocalizedString(@"入库记录",nil),NSLocalizedString(@"出库记录",nil)];
    if (!self.titlePagerView) {
        CGFloat titleFont = 0.0;
        if([LanguageManager isEnglishLanguage]){
            if(kIPhone6Plus){
                titleFont = 14.0f;
            }else if(IsPhone6_gt){
                titleFont = 13.0f;
            }else{
                titleFont = 11.0f;
            }
        }else{
            titleFont = 14.0f;
        }

        self.titlePagerView = [[TitlePagerView alloc] init];
        [self.view addSubview:self.titlePagerView];
        self.titlePagerView.dynamicTitlePagerViewTitleSpace = 5;
        self.titlePagerView.font = [UIFont systemFontOfSize:titleFont];
        [self.titlePagerView addObjects:titleArray];
        self.titlePagerView.delegate = self;
        self.titlePagerView.isInAnimation = NO;

        WeakSelf(ws);
        [self.titlePagerView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.height.mas_equalTo(40);
            make.top.equalTo(ws.navView.mas_bottom).with.mas_offset(4);
            make.left.mas_equalTo(0);
            make.right.mas_equalTo(0);
        }];
    }
    [self.titlePagerView adjustTitleViewByIndexNew:0];
}

#pragma mark - --------------请求数据----------------------
-(void)RequestData{}

#pragma mark - --------------系统代理----------------------
#pragma mark -UIScrollViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if ([self.searchField isFirstResponder]) {
        [self deselectedTextField];
    }
    
    CGFloat contentOffsetX = scrollView.contentOffset.x;
    if (self.currentIndex != 0 && contentOffsetX <= SCREEN_WIDTH * 3) {
        contentOffsetX += SCREEN_WIDTH * self.currentIndex;
    }
    [self.titlePagerView updatePageIndicatorPosition:contentOffsetX];
}

#pragma mark -UITextFieldDelegate
- (void)textFieldDidEndEditing:(UITextField *)textField{
    [self.view removeGestureRecognizer:self.tapGestureRecognizer];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UITextFieldTextDidChangeNotification object:self.searchField];
}

- (void)textFieldDidBeginEditing:(UITextField *)textField{
    [self.view addGestureRecognizer:self.tapGestureRecognizer];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textFieldDidChange:) name:UITextFieldTextDidChangeNotification object:self.searchField];
}

- (void)textFieldDidChange:(NSNotification *)note{
    NSString *toBeString = self.searchField.text;
    if([toBeString isEqualToString:@""]){
    }else{
    }
}

- (BOOL)textFieldShouldClear:(UITextField *)textField {
    self.warehousingVC.searchFieldText = nil;
    [self.warehousingVC getWarehouseRecord];
    
    self.EXwarehouseVC.searchFieldText = nil;
    [self.EXwarehouseVC getWarehouseRecord];
    
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    [self.searchField resignFirstResponder];
    
    self.warehousingVC.searchFieldText = self.searchField.text;
    [self.warehousingVC getWarehouseRecord];
    
    self.EXwarehouseVC.searchFieldText = self.searchField.text;
    [self.EXwarehouseVC getWarehouseRecord];
    
    return YES;
}

#pragma mark - --------------自定义代理/block----------------------
#pragma mark - TitlePagerViewDelegate
- (void)didTouchBWTitle:(NSUInteger)index {
    if (self.titlePagerView) {
        if (!self.titlePagerView.isInAnimation) {
            UIPageViewControllerNavigationDirection direction;

            if (self.currentIndex == index) {
                return;
            }

            self.titlePagerView.isInAnimation = YES;

            if (index > self.currentIndex) {
                direction = UIPageViewControllerNavigationDirectionForward;
            } else {
                direction = UIPageViewControllerNavigationDirectionReverse;
            }

            UIViewController *viewController = [self viewControllerAtIndex:index];

            if (viewController) {
                __weak typeof(self) weakself = self;
                [self.pageViewController setViewControllers:@[viewController] direction:direction animated:YES completion:^(BOOL finished) {
                    weakself.titlePagerView.isInAnimation = NO;
                    weakself.currentIndex = index;
                }];
            }else{
                self.titlePagerView.isInAnimation = NO;
            }
        }
    }
}

#pragma mark - ViewPagerDataSource
- (NSUInteger)numberOfTabsForViewPager:(ViewPagerController *)viewPager {
    return 3;
}

- (UIViewController *)viewPager:(ViewPagerController *)viewPager contentViewControllerForTabAtIndex:(NSUInteger)index {
    if (index == 0) {
        return [self createCommodityStocksViewController];
    } else if (index == 1) {
        return [self createWarehousingViewController];
    } else if (index == 2) {
        return [self createEXwarehouseViewController];
    }
    return nil;
}

#pragma mark - --------------自定义响应----------------------
- (void)messageButtonClicked:(id)sender {
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    [appDelegate showMessageView:nil parentViewController:self];
}

#pragma mark - --------------自定义方法----------------------
- (void)initMessageButton {
    self.messageButton = [[YYMessageButton alloc] init];
    [self.messageButton initButton:@""];
    [self messageCountChanged:nil];
    [_messageButton addTarget:self action:@selector(messageButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(messageCountChanged:) name:UnreadMsgAmountChangeNotification object:nil];
    [self.navView addSubview:self.messageButton];
    [self.messageButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(50);
        make.height.mas_equalTo(44);
        make.top.mas_equalTo(kStatusBarHeight);
        make.right.mas_equalTo(0);
    }];
}

- (void)initSearchField {
    self.searchView = [[UIView alloc] init];
    self.searchView.backgroundColor = [UIColor colorWithHex:@"efefef"];

    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    [btn setImage:[UIImage imageNamed:@"search_Img"] forState:UIControlStateNormal];
    btn.backgroundColor = [UIColor colorWithHex:@"efefef"];
    [self.searchView addSubview:btn];
    [btn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(18);
        make.height.mas_equalTo(22);
        make.centerY.mas_equalTo(0);
        make.left.mas_equalTo(7);
    }];

    self.searchField = [[UITextField alloc] init];
    self.searchField.delegate = self;
    self.searchField.borderStyle = UITextBorderStyleNone;
    self.searchField.returnKeyType = UIReturnKeySearch;
    self.searchField.backgroundColor = [UIColor colorWithHex:@"efefef"];
    self.searchField.placeholder = NSLocalizedString(@"搜索款式名称", nil);
    self.searchView.layer.masksToBounds = YES;
    self.searchView.layer.cornerRadius = 3.0f;
    if (IsPhone6_gt) {
        self.searchField.font = [UIFont systemFontOfSize:14];
    }else {
        self.searchField.font = [UIFont systemFontOfSize:12];
    }
    self.searchField.clearButtonMode = UITextFieldViewModeAlways;
    [self.searchView addSubview:self.searchField];
    [self.searchField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(30);
        make.centerY.mas_equalTo(0);
        make.top.mas_equalTo(0);
        make.left.mas_equalTo(btn.mas_right).with.mas_offset(2);
        make.bottom.mas_equalTo(0);
        make.right.mas_equalTo(0);
    }];

    [self.navView addSubview:self.searchView];
    WeakSelf(ws);
    [self.searchView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(13);
        make.bottom.mas_equalTo(-7);
        make.right.mas_equalTo(ws.messageButton.mas_left).with.mas_offset(-17);
    }];

    self.tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(deselectedTextField)];
}

- (UIViewController *)createCommodityStocksViewController {
    if (!self.merchandiseInventoryVC) {
        self.merchandiseInventoryVC = [[YYMerchandiseInventoryViewController alloc] init];
        self.merchandiseInventoryVC.navigationController = self.navigationController;
    }
    return self.merchandiseInventoryVC;
}

- (UIViewController *)createWarehousingViewController {
    if (!self.warehousingVC) {
        self.warehousingVC = [[YYWarehousingViewController alloc] init];
        self.warehousingVC.navigationController = self.navigationController;
        self.warehousingVC.isEXwarehouse = NO;
    }
    return self.warehousingVC;
}

- (UIViewController *)createEXwarehouseViewController {
    if (!self.EXwarehouseVC) {
        self.EXwarehouseVC = [[YYWarehousingViewController alloc] init];
        self.EXwarehouseVC.navigationController = self.navigationController;
        self.EXwarehouseVC.isEXwarehouse = YES;
    }
    return self.EXwarehouseVC;
}

#pragma mark - --------------自定义通知----------------------
- (void)messageCountChanged:(NSNotification *)notification{
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    [appDelegate.untreatedMsgAmountModel setUnreadMessageAmount:_messageButton];
}

#pragma mark - --------------other----------------------

- (void)setCurrentIndex:(NSInteger)index {
    if(self.titlePagerView){
        [self.titlePagerView adjustTitleViewByIndexNew:index];
    }
    _currentIndex = index;
}

- (void)deselectedTextField {
    if ([self.searchField.text isEqualToString:@""]) {
        self.warehousingVC.searchFieldText = nil;
        [self.warehousingVC getWarehouseRecord];
        
        self.EXwarehouseVC.searchFieldText = nil;
        [self.EXwarehouseVC getWarehouseRecord];
    }else {
        if (self.currentIndex == 1) {
            if (self.warehousingVC.searchFieldText) {
                self.searchField.text = self.warehousingVC.searchFieldText;
            }else {
                self.searchField.text = nil;
            }
        }else if (self.currentIndex == 2) {
            if (self.EXwarehouseVC.searchFieldText) {
                self.searchField.text = self.EXwarehouseVC.searchFieldText;
            }else {
                self.searchField.text = nil;
            }
        }else {
            self.searchField.text = nil;
        }
    }
    [self.searchField resignFirstResponder];
}

@end
