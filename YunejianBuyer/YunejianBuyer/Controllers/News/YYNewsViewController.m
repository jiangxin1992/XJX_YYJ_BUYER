//
//  YYNewsViewController.m
//  YunejianBuyer
//
//  Created by Apple on 16/9/5.
//  Copyright © 2016年 Apple. All rights reserved.
//

#import "YYNewsViewController.h"

// c文件 —> 系统文件（c文件在前）

// 控制器
#import "YYNewsTableViewController.h"
#import "YYNewsDetailViewController.h"

// 自定义视图
#import "YYNavView.h"
#import "HMSegmentedControl.h"

// 接口

// 分类

// 自定义类和三方类（ cocoapods类 > model > 工具类 > 其他）
#import "YYUntreatedMsgAmountModel.h"
#import "AppDelegate.h"

@interface YYNewsViewController ()<ViewPagerDataSource, ViewPagerDelegate,YYTableCellDelegate>{
    NSArray *titleArr;
}

@property (weak, nonatomic) IBOutlet UIView *containerView;
@property (nonatomic, strong) YYNavView *navView;
@property (strong, nonatomic) HMSegmentedControl *segmentedControl;
@property (nonatomic, assign) NSInteger currentType;

@end

@implementation YYNewsViewController
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
    [MobClick beginLogPageView:kYYPageNews];
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    // 退出埋点
    [MobClick endLogPageView:kYYPageNews];
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
    [self createNavView];
    self.dataSource = self;
    self.delegate = self;
    [self scrollEnabled:YES];
    self.manualLoadData = YES;
    self.currentIndex = 0;
    [self reloadData];
}

#pragma mark - --------------UIConfig----------------------
-(void)UIConfig{}
-(void)createNavView{
    self.navView = [[YYNavView alloc] initWithTitle:nil WithSuperView:self.view haveStatusView:YES];
    WeakSelf(ws);
    self.navView.goBackBlock = ^{
        [ws goBack];
    };
    self.segmentedControl = [self createSegmentedControl];
    [self.navView setNavCustomView:self.segmentedControl];
}

-(HMSegmentedControl *)createSegmentedControl{
    titleArr = @[NSLocalizedString(@"YCO新闻",nil)];
    CGSize titleSize= CGSizeZero;
    float titlesWidth = 0;
    float titleSpace = 80;
    float segmentedControlOffset = 0;
    if( [titleArr count] == 1){
        for (NSString * titleStr in titleArr) {
            titleSize =[titleStr sizeWithAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:17]}];
            titlesWidth += titleSize.width;
        }
    }else{
        for (NSString * titleStr in titleArr) {
            titleSize =[titleStr sizeWithAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:14]}];
            titlesWidth += titleSize.width;
        }
    }
    titlesWidth += titleSpace*MAX(0, [titleArr count]-1);

    if(titlesWidth < ( SCREEN_WIDTH-40-20)){
        segmentedControlOffset = ((SCREEN_WIDTH-40-20)-titlesWidth)/2;
    }
    HMSegmentedControl *segmentedControl =  [[HMSegmentedControl alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH-40-20-segmentedControlOffset*2, 40)];
    segmentedControl.backgroundColor = [UIColor clearColor];
    [segmentedControl setSectionTitles:titleArr];
    segmentedControl.selectionIndicatorLocation = HMSegmentedControlSelectionIndicatorLocationDown;
    segmentedControl.selectionIndicatorColor = [UIColor blackColor];
    segmentedControl.selectionIndicatorHeight =2;
    segmentedControl.titleTextAttributes = @{NSForegroundColorAttributeName : [UIColor colorWithHex:@"919191"],NSFontAttributeName:[UIFont systemFontOfSize:14]};
    segmentedControl.selectedTitleTextAttributes = @{NSForegroundColorAttributeName : [UIColor colorWithHex:@"000000"],NSFontAttributeName:[UIFont systemFontOfSize:14]};
    segmentedControl.selectedSegmentIndex = 0;
    segmentedControl.borderWidth = 100;
    [segmentedControl addTarget:self action:@selector(segmentedControlChangedValue:) forControlEvents:UIControlEventValueChanged];
    //当一个title时处理
    if([titleArr count] == 1){
        segmentedControl.selectionIndicatorColor = [UIColor clearColor];
        segmentedControl.titleTextAttributes = @{NSForegroundColorAttributeName : [UIColor colorWithHex:@"919191"],NSFontAttributeName:[UIFont systemFontOfSize:17]};
        segmentedControl.selectedTitleTextAttributes = @{NSForegroundColorAttributeName : [UIColor colorWithHex:@"000000"],NSFontAttributeName:[UIFont systemFontOfSize:17]};
        segmentedControl.userInteractionEnabled = NO;
    }

    return segmentedControl;
}
#pragma mark - --------------请求数据----------------------
-(void)RequestData{}

#pragma mark - --------------系统代理----------------------
#pragma mark -ViewPagerDataSource
- (NSUInteger)numberOfTabsForViewPager:(ViewPagerController *)viewPager {
    return [titleArr count];
}

- (UIViewController *)viewPager:(ViewPagerController *)viewPager contentViewControllerForTabAtIndex:(NSUInteger)index {
    return [self createNewsTableVC:index];
}

#pragma mark - --------------自定义代理/block----------------------
-(void)btnClick:(NSInteger)row section:(NSInteger)section andParmas:(NSArray *)parmas{
    NSString *type = [parmas objectAtIndex:0];
    if([type isEqualToString:@"detail"]){
        NSString *urlString = [parmas objectAtIndex:1];
        [self showNewsDetail:urlString];
    }
}

#pragma mark - --------------自定义响应----------------------
- (void)goBack {
    if(self.cancelButtonClicked){
        self.cancelButtonClicked();
    }
}

- (void)segmentedControlChangedValue:(HMSegmentedControl *)segmentedControl {
    NSInteger index = (int)segmentedControl.selectedSegmentIndex;
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

#pragma mark - --------------自定义方法----------------------
- (void)setCurrentIndex:(NSInteger)index {
    _currentType = index;
    _segmentedControl.selectedSegmentIndex = _currentType;
}

- (UIViewController *)createNewsTableVC:(NSInteger)index {
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"News" bundle:[NSBundle mainBundle]];
    YYNewsTableViewController *tableViewController = [storyboard instantiateViewControllerWithIdentifier:@"YYNewsTableViewController"];
    tableViewController.delegate = self;
    tableViewController.index = index;
    return tableViewController;
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
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {

    CGFloat contentOffsetX = scrollView.contentOffset.x;

    if (self.currentType != 0 && contentOffsetX <= SCREEN_WIDTH * [titleArr count]) {
        contentOffsetX += SCREEN_WIDTH * self.currentType;
    }

}

-(void)showNewsDetail:(NSString *)urlString{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"News" bundle:[NSBundle mainBundle]];
    YYNewsDetailViewController *detailViewController = [storyboard instantiateViewControllerWithIdentifier:@"YYNewsDetailViewController"];
    detailViewController.newsUrlString = urlString;
    [self.navigationController pushViewController:detailViewController animated:YES];

    WeakSelf(ws);
    [detailViewController setCancelButtonClicked:^(){
        [ws.navigationController popViewControllerAnimated:YES];
    }];
}

+(void)markAsRead{
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    if(appDelegate.untreatedMsgAmountModel.unreadNewsAmount > 0){
        appDelegate.untreatedMsgAmountModel.unreadNewsAmount = 0;
        [[NSNotificationCenter defaultCenter] postNotificationName:UnreadMsgAmountChangeNotification object:nil userInfo:nil];
    }
}

#pragma mark - --------------other----------------------


@end
