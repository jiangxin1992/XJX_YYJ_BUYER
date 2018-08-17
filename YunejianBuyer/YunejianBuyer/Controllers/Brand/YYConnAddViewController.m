//
//  YYBrandAddViewController.m
//  Yunejian
//
//  Created by Apple on 15/12/3.
//  Copyright © 2015年 yyj. All rights reserved.
//

#import "YYConnAddViewController.h"

// c文件 —> 系统文件（c文件在前）

// 控制器
#import "YYMainViewController.h"
#import "YYVisibleContactInfoViewController.h"

// 自定义视图
#import "YYNavView.h"
#import "YYNewBrandInfoCell.h"
#import "YYBrandAddHeadView.h"
#import "YYConSuitChooseView.h"
#import "YYBrandPeopleHeadView.h"
#import "YYBrandVerifyView.h"
#import "MBProgressHUD.h"
#import "YYMessageButton.h"

// 接口
#import "YYOpusApi.h"
#import "YYConnApi.h"

// 分类

// 自定义类和三方类（ cocoapods类 > model > 工具类 > 其他）
#import <MJRefresh.h>

#import "YYUser.h"
#import "YYConClass.h"
#import "YYSeriesInfoModel.h"
#import "YYSeriesInfoDetailModel.h"
#import "YYHotDesignerBrandsModel.h"
#import "YYUntreatedMsgAmountModel.h"
#import "YYNewConnDesignerListModel.h"

#import "AppDelegate.h"
#import "UserDefaultsMacro.h"

#define IndexHotBrandCellHeight 316
#define IndexHotBrandNoSeriesCellHeight 114


#define YY_COLLECTION_HEADERVIEW_HEIGHT 88//headview height

#define YY_ANIMATE_DURATION 0.2 //动画持续时间
#define YY_ANIMATE_BOUNDARY_OffSET 88 //动画触发offset边界
#define YY_ANIMATE_OffSET 90 //触发动画偏移量

@interface YYConnAddViewController ()<UICollectionViewDataSource,UICollectionViewDelegate,UITextFieldDelegate>

@property (nonatomic, strong) YYNavView *navView;
@property (strong, nonatomic) YYMessageButton *messageButton;
@property (strong, nonatomic) UIButton *searchButton;

@property (weak, nonatomic) IBOutlet UIView *containerView;
@property (strong, nonatomic) UICollectionView *collectionView;
@property (strong, nonatomic) UICollectionViewFlowLayout *collectionlayout;

@property (strong, nonatomic) UITextField *searchField;
@property (strong, nonatomic) UIView *searchView;


@property (nonatomic,strong) YYPageInfoModel *currentPageInfo;
@property (nonatomic,strong) UIView *noDataView;
@property (nonatomic,strong) NSMutableArray *designerListArray;

//查询结果
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *searchViewTopLayoutConstraint;
@property (nonatomic,assign) BOOL isSearchView;
@property (nonatomic,copy) NSString *searchFieldStr;
@property (nonatomic,strong) NSMutableArray *searchResultArray;
@property (nonatomic,strong) YYPageInfoModel *currentSearchPageInfo;

@property (nonatomic,strong) YYConClass *connClass;

@property (nonatomic,assign) NSInteger peopleSelectIndex;
@property (nonatomic,assign) NSInteger suitSelectIndex;

//动画相关
@property (nonatomic,assign) CGFloat start_offset;
@property (nonatomic,assign) CGFloat changing_offset;
@property (nonatomic,assign) BOOL isAnimation;
@property (nonatomic,strong) YYBrandPeopleHeadView *peopleHeadView;
@property (nonatomic,assign) CGRect tempHeadViewAppearRect;
@property (nonatomic,assign) CGRect tempHeadViewDisappearRect;
@property (nonatomic,assign) BOOL isOffsetIncrease;

//上面那个选择按钮
@property (nonatomic,strong) UIButton *suitBtn;
@property (nonatomic,strong) UILabel *suitLabel;
@property (nonatomic,strong) UIImageView *suitImg;

@property (nonatomic,strong) YYConSuitChooseView *suitChooseView;

@property (nonatomic,strong) YYBrandVerifyView *verifyView;

@property (nonatomic,assign) BOOL isLoadingListData;

@end

@implementation YYConnAddViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self SomePrepare];
    [self RequestData];
    [self CreateVerifyView];
}
- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    // 进入埋点
    [MobClick beginLogPageView:kYYPageConnAdd];
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    // 退出埋点
    [MobClick endLogPageView:kYYPageConnAdd];
}

#pragma mark - SomePrepare

-(void)SomePrepare
{
    [self PrepareData];
    [self PrepareUI];
}

-(void)PrepareData{

    _isLoadingListData = NO;

    self.designerListArray = [[NSMutableArray alloc] init];
    self.peopleSelectIndex = 0;
    self.suitSelectIndex = 0;

    _start_offset = 0.0f;
    _changing_offset = 0.0f;
    _isAnimation = NO;
    if(_isMainView){
        _tempHeadViewAppearRect = CGRectMake(0, kStatusBarAndNavigationBarHeight, SCREEN_WIDTH, YY_COLLECTION_HEADERVIEW_HEIGHT);
        _tempHeadViewDisappearRect = CGRectMake(0, -(YY_COLLECTION_HEADERVIEW_HEIGHT - kStatusBarAndNavigationBarHeight), SCREEN_WIDTH, YY_COLLECTION_HEADERVIEW_HEIGHT);
    }else{
        _tempHeadViewAppearRect = CGRectMake(0, kStatusBarAndNavigationBarHeight, SCREEN_WIDTH, YY_COLLECTION_HEADERVIEW_HEIGHT);
        _tempHeadViewDisappearRect = CGRectMake(0, -(YY_COLLECTION_HEADERVIEW_HEIGHT - kStatusBarAndNavigationBarHeight), SCREEN_WIDTH, YY_COLLECTION_HEADERVIEW_HEIGHT);
    }
    _isOffsetIncrease = NO;

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(userCheckStatusChangeNotification:) name:UserCheckStatusChangeNotification object:nil];
}
-(void)PrepareUI{
    self.navView = [[YYNavView alloc] initWithTitle:NSLocalizedString(@"品牌广场",nil) WithSuperView:self.view haveStatusView:YES];
    if (self.isMainView) {
        [self.navView hidesBackButton];
    }else {
        WeakSelf(ws);
        self.navView.goBackBlock = ^{
            [ws goBack];
        };
    }
    [self initMessageButton];
    [self initSearchButton];
    [self initSearchView];

    _searchField.delegate = self;
    _searchFieldStr = @"";
    
    [self CreateCollectionView];

    [self addHeader];
    [self addFooter];
    
    self.noDataView = addNoDataView_phone(self.view,nil,nil,nil);
    self.noDataView.hidden = YES;
}
- (void)userCheckStatusChangeNotification:(NSNotification *)notification{
    if(_verifyView){
        [_verifyView updateUI];
    }
}
-(void)CreateVerifyView{
    if(![[YYUser currentUser] hasPermissionsToVisit]){
        //1:待提交文件 2:待审核 4:审核拒绝
        YYUser *user = [YYUser currentUser];
        NSInteger checkStatus = [user.checkStatus integerValue];
        if(checkStatus == 1 || checkStatus == 2 || checkStatus == 4){
            if(!_verifyView){
                WeakSelf(ws);
                _verifyView = [[YYBrandVerifyView alloc] initWithSuperView:self.view];
                [_verifyView setVerifyBlock:^(NSString *type) {
                    if([type isEqualToString:@"fillInformation"]){
                        [ws fillInformation];
                    }else if([type isEqualToString:@"return_homepage"]){
                        [ws.navigationController popViewControllerAnimated:YES];
                    }
                }];
            }
            [_verifyView updateUI];
            _verifyView.hidden = NO;
        }else{
            _verifyView.hidden = YES;
        }
    }
}
- (void)CreateCollectionView{
    if (!_collectionView) {
        
        _collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 65, SCREEN_WIDTH, SCREEN_HEIGHT-65) collectionViewLayout:[self getCollectionViewLayout]];
        [self.view addSubview:_collectionView];
        [_collectionView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.right.bottom.mas_equalTo(0);
            make.top.mas_equalTo(_containerView.mas_bottom).with.offset(0);
        }];
        _collectionView.delegate = self;
        _collectionView.dataSource = self;
        _collectionView.backgroundColor =  _define_white_color;
        _collectionView.alwaysBounceVertical=YES;
        _collectionView.alwaysBounceHorizontal=NO;
        _collectionView.showsVerticalScrollIndicator = FALSE;
        _collectionView.showsHorizontalScrollIndicator = FALSE;
        [_collectionView registerClass:[YYNewBrandInfoCell class] forCellWithReuseIdentifier:@"YYNewBrandInfoCell"];
        [_collectionView registerClass:[YYBrandAddHeadView class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"YYBrandAddHeadView"];
        [_collectionView registerClass:[UICollectionReusableView class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"UICollectionReusableView"];

        [self isShowPeopleHeadView:YES];
    }
}
#pragma mark - RequestData
-(void)RequestData{
    [self RequestListData];
    [self RequestClassData];
}

-(void)RequestListData{
    [self loadDataByPageIndex:1 queryStr:@""];
}
-(void)RequestClassData{
    WeakSelf(ws);
    [YYConnApi getConBrandClassWithBlock:^(YYRspStatusAndMessage *rspStatusAndMessage, YYConClass *connClass, NSError *error) {
        if (rspStatusAndMessage.status == YYReqStatusCode100){
            ws.connClass = connClass;
            [ws updatePeopleHeadView];
        }
        if (rspStatusAndMessage.status != YYReqStatusCode100) {
            [YYToast showToastWithTitle:rspStatusAndMessage.message  andDuration:kAlertToastDuration];
        }
        [ws reloadCollectionViewData];
    }];
}


#pragma mark -  UICollectionViewDataSource
- (CGSize) collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSArray *tempArr = nil;
    if(_isSearchView){
        tempArr = [_searchResultArray copy];
    }else{
        tempArr = [_designerListArray copy];
    }
    if(![NSArray isNilOrEmpty:tempArr]){
        if(tempArr.count > indexPath.row){
            YYHotDesignerBrandsModel *brandsModel = tempArr[indexPath.row];
            if(![NSArray isNilOrEmpty:brandsModel.seriesBoList]){
                return CGSizeMake(SCREEN_WIDTH, IndexHotBrandCellHeight);
            }else{
                return CGSizeMake(SCREEN_WIDTH, IndexHotBrandNoSeriesCellHeight);
            }
        }
    }
    return CGSizeMake(SCREEN_WIDTH, 0);
}
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView{
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    if(_isSearchView){
        return [_searchResultArray count];
    }
    return [_designerListArray count];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"section=%ld row=%ld",indexPath.section,indexPath.row);
    WeakSelf(ws);
    YYHotDesignerBrandsModel *designerModel = nil;
    if(_isSearchView && ([_searchResultArray count] > indexPath.row)){
        designerModel =[_searchResultArray objectAtIndex:indexPath.row];
    }else if ([_designerListArray count] > indexPath.row) {
        designerModel = [_designerListArray objectAtIndex:indexPath.row];
    }

    YYNewBrandInfoCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"YYNewBrandInfoCell" forIndexPath:indexPath];
    cell.hotDesignerBrandsModel = designerModel;
    [cell setHotBrandCellBlock:^(NSString *type, YYHotDesignerBrandsModel *hotDesignerBrandsModel, YYHotDesignerBrandsSeriesModel *seriesModel) {
        if([type isEqualToString:@"enter_brand"]){
            //进入品牌主页
            NSLog(@"enter_brand");
            [ws enterDesignerBrandsHomePageWithModel:hotDesignerBrandsModel];

        }else if([type isEqualToString:@"enter_series"]){
            //进入系列详情
            NSLog(@"enter_series");
            [ws clickLatestSeriesCardWithModel:seriesModel];

        }else if([type isEqualToString:@"change_status"]){
            //修改当前用户与品牌的关联状态
            NSLog(@"change_status");
            [self showOprateView:hotDesignerBrandsModel];
        }
    }];
    [cell updateUI];

    return cell;
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath{
    if(!_searchView.hidden) {
        UICollectionReusableView *headerView = [collectionView dequeueReusableSupplementaryViewOfKind:kind withReuseIdentifier:@"UICollectionReusableView" forIndexPath:indexPath];
        return headerView;
    }else{
        YYBrandAddHeadView *headerView = [collectionView dequeueReusableSupplementaryViewOfKind:kind withReuseIdentifier:@"YYBrandAddHeadView" forIndexPath:indexPath];
        if(_connClass){
            headerView.peopleSelectIndex = _peopleSelectIndex;
            headerView.suitSelectIndex = _suitSelectIndex;
            headerView.connClass = _connClass;
        }
        WeakSelf(ws);

        [headerView setBlockPeople:^(NSInteger index){
            ws.peopleSelectIndex = index;
            //重新刷新数据
            [ws updatePeopleHeadView];
            [ws reloadCollectionViewData];
            [ws reloadListData];
        }];

        [headerView setBlockSuit:^(NSInteger index){
            ws.suitSelectIndex = index;
            //重新刷新数据
            [ws updatePeopleHeadView];
            [ws reloadCollectionViewData];
            [ws reloadListData];
        }];

        return headerView;
    }
    
}
#pragma msseage
- (void)messageButtonClicked:(id)sender {
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    [appDelegate showMessageView:nil parentViewController:self];
}

- (void)messageCountChanged:(NSNotification *)notification{
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    [appDelegate.untreatedMsgAmountModel setUnreadMessageAmount:_messageButton];
}
#pragma mark - 动画相关
//导航栏的动画显示与隐藏
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView{
    [self updateStartOffset];
}
- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    NSLog(@"scrollViewDidScroll = %lf",scrollView.contentOffset.y);
    BOOL isShow = NO;
    if(_searchView.hidden){
        if(scrollView.contentOffset.y > 0.0f){
            //显示
            isShow = YES;
        }
    }
    if(_peopleHeadView){
        _peopleHeadView.hidden = !isShow;
    }else{
        [self isShowPeopleHeadView:isShow];
    }

    //更新start_offset
    CGFloat offset_y = scrollView.contentOffset.y;

    BOOL isOffsetIncrease_Temp = NO;
    CGFloat changeOffset = offset_y - _changing_offset;

    if(changeOffset > 0){
        isOffsetIncrease_Temp = YES;
    }else{
        isOffsetIncrease_Temp = NO;
    }

    if(_isOffsetIncrease != isOffsetIncrease_Temp){
        [self updateStartOffset];
    }

    _isOffsetIncrease = isOffsetIncrease_Temp;
    _changing_offset = offset_y;
    //动画
    CGFloat changeOffsetByStart = _start_offset - _changing_offset;
    if(changeOffsetByStart >= YY_ANIMATE_OffSET && offset_y >= YY_ANIMATE_BOUNDARY_OffSET ){
        [self setAnimationAppear];
    }else if(changeOffsetByStart <= -YY_ANIMATE_OffSET){
        [self setAnimationDisappear];
    }
}
-(void)updateStartOffset{
    _start_offset = _collectionView.contentOffset.y;
}
-(void)setAnimationAppear{
    //不在动画中 并且y位置正确
    CGFloat origin_y = -(YY_COLLECTION_HEADERVIEW_HEIGHT - kStatusBarAndNavigationBarHeight);
    if(!_isAnimation && _peopleHeadView && _peopleHeadView.frame.origin.y == origin_y){
        NSLog(@"_peopleHeadView.frame.origin.y = %lf",_peopleHeadView.frame.origin.y);
        NSLog(@"peopleHeadView ishide = %d",_peopleHeadView.hidden);
        _isAnimation = YES;
        _peopleHeadView.viewStyle = YYBrandPeopleHeadViewAppear;
        [UIView animateWithDuration:YY_ANIMATE_DURATION animations:^{
            _peopleHeadView.frame = _tempHeadViewAppearRect;
        } completion:^(BOOL finished) {
            _isAnimation = NO;
            [self updateStartOffset];
        }];
    }
}
-(void)setAnimationDisappear{
    //不在动画中 并且y位置正确
    CGFloat origin_y = kStatusBarAndNavigationBarHeight;
    if(!_isAnimation && _peopleHeadView && _peopleHeadView.frame.origin.y == origin_y){
        NSLog(@"_peopleHeadView.frame.origin.y = %lf",_peopleHeadView.frame.origin.y);//-43
        NSLog(@"peopleHeadView ishide = %d",_peopleHeadView.hidden);
        _isAnimation = YES;
        [UIView animateWithDuration:YY_ANIMATE_DURATION animations:^{
            _peopleHeadView.frame = _tempHeadViewDisappearRect;
        } completion:^(BOOL finished) {
            _peopleHeadView.viewStyle = YYBrandPeopleHeadViewDisappear;
            _isAnimation = NO;
            [self updateStartOffset];
        }];
    }
}
-(void)updatePeopleHeadView{
    if(_searchView.hidden){
        if(_collectionView.contentOffset.y > 0.0f){
            //显示
            [self isShowPeopleHeadView:YES];
        }else{
            //藏起来
            [self isShowPeopleHeadView:NO];
        }
    }else{
        //藏起来
        [self isShowPeopleHeadView:NO];
    }
}
#pragma mark - SomeAction
- (void)goBack {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
    if (self.cancelButtonClicked) {
        self.cancelButtonClicked();
    }
    [self.navigationController popViewControllerAnimated:YES];
}

//修改当前用户与品牌的关联状态
-(void)showOprateView:(YYHotDesignerBrandsModel *)hotDesignerBrandsModel{
    if(hotDesignerBrandsModel && [hotDesignerBrandsModel.connectStatus integerValue] == YYUserConnStatusNone){
        WeakSelf(ws);
        __block YYHotDesignerBrandsModel *blockDesignerModel = hotDesignerBrandsModel;
        [YYConnApi invite:[blockDesignerModel.designerId integerValue] andBlock:^(YYRspStatusAndMessage *rspStatusAndMessage, NSError *error) {
            if(rspStatusAndMessage.status == YYReqStatusCode100){
                blockDesignerModel.connectStatus = 0;
                [YYToast showToastWithTitle:NSLocalizedString(@"已向品牌发送合作邀请",nil) andDuration:kAlertToastDuration];
                [ws reloadCollectionViewData];
            }
        }];
    }
}
//  进入系列主页
-(void)clickLatestSeriesCardWithModel:(YYHotDesignerBrandsSeriesModel *)seriesModel{

    [YYOpusApi getConnSeriesInfoWithId:[seriesModel.designerId integerValue] seriesId:[seriesModel.id integerValue] andBlock:^(YYRspStatusAndMessage *rspStatusAndMessage, YYSeriesInfoDetailModel *infoDetailModel, NSError *error) {
        if (rspStatusAndMessage.status == YYReqStatusCode100) {

            NSString *brandName = [NSString isNilOrEmpty:infoDetailModel.series.designerBrandName]?@"":infoDetailModel.series.designerBrandName;
            NSString *brandLogo = [NSString isNilOrEmpty:infoDetailModel.series.designerBrandLogo]?@"":infoDetailModel.series.designerBrandLogo;
            AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
            [appDelegate showSeriesInfoViewController:seriesModel.designerId seriesId:seriesModel.id designerInfo:@[brandName,brandLogo] parentViewController:self];

        }
    }];

}
//  进入品牌主页
-(void)enterDesignerBrandsHomePageWithModel:(YYHotDesignerBrandsModel *)hotDesignerBrandsModel{

    WeakSelf(ws);
    AppDelegate *appdelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    NSString *brandName = hotDesignerBrandsModel.brandName;
    NSString *logoPath = hotDesignerBrandsModel.logo;
    [appdelegate showBrandInfoViewController:hotDesignerBrandsModel.designerId WithBrandName:brandName WithLogoPath:logoPath parentViewController:self WithHomePageBlock:^(NSString *type, NSNumber *connectStatus) {
        if([type isEqualToString:@"refresh"])
        {
            hotDesignerBrandsModel.connectStatus = connectStatus;
            [ws reloadCollectionViewData];
        }
    } WithSelectedValue:^(NSArray *value) {
        hotDesignerBrandsModel.connectStatus = [[NSNumber alloc] initWithInteger:[[value objectAtIndex:0] integerValue]];
        [ws reloadCollectionViewData];
    }];

}
//完善资料
-(void)fillInformation{
    NSLog(@"fillInformation");
    YYVisibleContactInfoViewController *visibleContactInfoViewController = [[YYVisibleContactInfoViewController alloc] init];
    [self.navigationController pushViewController:visibleContactInfoViewController animated:YES];
    [visibleContactInfoViewController setGoBack:^{
        //返回
        for (UIViewController *temp in self.navigationController.viewControllers) {
            if ([temp isKindOfClass:[YYMainViewController class]]) {
                [self.navigationController popToViewController:temp animated:YES];
            }
        }
        //该界面不用刷新审核状态
        //更新用户审核状态
        [[YYUser currentUser] updateUserCheckStatus];
    }];
}

-(void)isShowPeopleHeadView:(BOOL )isshow{
    WeakSelf(ws);
    if(!_peopleHeadView){
        _peopleHeadView = [[YYBrandPeopleHeadView alloc] init];
        [self.view addSubview:_peopleHeadView];
        [self.view bringSubviewToFront:self.navView];
        _peopleHeadView.frame = _tempHeadViewAppearRect;

        [_peopleHeadView setBlockPeople:^(NSInteger index){
            ws.peopleSelectIndex = index;
            [ws isShowPeopleHeadView:isshow];
            //重新刷新数据
            [ws reloadCollectionViewData];
            [ws reloadListData];
        }];

        [_peopleHeadView setBlockSuit:^(NSInteger index){
            ws.suitSelectIndex = index;
            //重新刷新数据
            [ws updatePeopleHeadView];
            [ws reloadCollectionViewData];
            [ws reloadListData];
        }];
    }
    _peopleHeadView.hidden = !isshow;
    if(_connClass){
        _peopleHeadView.peopleSelectIndex = _peopleSelectIndex;
        _peopleHeadView.suitSelectIndex = _suitSelectIndex;
        _peopleHeadView.connClass = _connClass;
    }
}
-(void)reloadListData{
    if ([YYCurrentNetworkSpace isNetwork]){
        if(!self.isSearchView){
            [self loadDataByPageIndex:1 queryStr:@""];
        }else{
            if(![self.searchFieldStr isEqualToString:@""]){
                [self loadDataByPageIndex:1 queryStr:self.searchFieldStr];
            }
        }
    }else{
        [self.collectionView.mj_header endRefreshing];
        [YYToast showToastWithTitle:kNetworkIsOfflineTips andDuration:kAlertToastDuration];
    }
}

-(UICollectionViewFlowLayout *)getCollectionViewLayout{
    UICollectionViewFlowLayout *templayout = [[UICollectionViewFlowLayout alloc] init];

    templayout.footerReferenceSize  = CGSizeMake(0, 0);
    templayout.headerReferenceSize = CGSizeMake(SCREEN_WIDTH, 88);//170
    templayout.sectionInset = UIEdgeInsetsMake(20, 0, 0, 0);
    templayout.minimumInteritemSpacing = 0.0f;
    templayout.minimumLineSpacing = 0.0f;

    return templayout;
}
-(void)updateCollectionViewLayout{
    if(!_searchView.hidden) {
        ((UICollectionViewFlowLayout *)_collectionView.collectionViewLayout).headerReferenceSize = CGSizeMake(SCREEN_WIDTH, 0);
    }else{
        ((UICollectionViewFlowLayout *)_collectionView.collectionViewLayout).headerReferenceSize = CGSizeMake(SCREEN_WIDTH, 88);
    }
}
#pragma mark - MJRefresh
//刷新界面
- (void)reloadCollectionViewData{
    [self.collectionView.mj_header endRefreshing];
    [self.collectionView.mj_footer endRefreshing];

    [self updateCollectionViewLayout];

    [self.collectionView reloadData];

    if (!self.designerListArray || [self.designerListArray count ] == 0) {
        if(!_isLoadingListData){
            self.noDataView.hidden = NO;
        }else{
            self.noDataView.hidden = YES;
        }
    }else{
        self.noDataView.hidden = YES;
    }
}

//加载品牌，
- (void)loadDataByPageIndex:(int)pageIndex queryStr:(NSString*)queryStr{
    WeakSelf(ws);
    NSString *SuitIds = @"";
    NSString *PeopleIds = @"";
    if(_connClass){
        if(_connClass.suitTypes){
            if(_connClass.suitTypes.count){
                if(_suitSelectIndex<_connClass.suitTypes.count){
                    YYConSuitClass *suitclass = _connClass.suitTypes[_suitSelectIndex];
                    SuitIds = [suitclass.suitIds componentsJoinedByString:@","];
                }
            }
        }
        if(_connClass.peopleTypes){
            if(_connClass.peopleTypes.count){
                if(_peopleSelectIndex<_connClass.peopleTypes.count){
                    YYConPeopleClass *popleclass = _connClass.peopleTypes[_peopleSelectIndex];
                    PeopleIds = [popleclass.peopleIds componentsJoinedByString:@","];
                }
            }
        }
    }
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    _isLoadingListData = YES;
    [YYConnApi queryDesignerWithQueryStr:queryStr WithSuitIds:SuitIds WithPeopleIds:PeopleIds pageIndex:pageIndex pageSize:8 andBlock:^(YYRspStatusAndMessage *rspStatusAndMessage, YYNewConnDesignerListModel *designerListModel, NSError *error) {
        if (rspStatusAndMessage.status == YYReqStatusCode100 && designerListModel.result
                && [designerListModel.result count] > 0) {
            if(!_isSearchView){
                ws.currentPageInfo = designerListModel.pageInfo;
                if (ws.currentPageInfo== nil || ws.currentPageInfo.isFirstPage) {
                    [ws.designerListArray removeAllObjects];
                }
                [ws.designerListArray addObjectsFromArray:designerListModel.result];
            }else{
                ws.currentSearchPageInfo = designerListModel.pageInfo;
                if (ws.currentSearchPageInfo == nil || ws.currentSearchPageInfo.isFirstPage) {
                    [ws.searchResultArray removeAllObjects];
                }
                [ws.searchResultArray addObjectsFromArray:designerListModel.result];
            }
        }else{
            if(designerListModel.result){
                if(!designerListModel.result.count){
                    if(!_isSearchView){
                        ws.currentPageInfo = designerListModel.pageInfo;
                        if (ws.currentPageInfo== nil || ws.currentPageInfo.isFirstPage) {
                            [ws.designerListArray removeAllObjects];
                        }
                    }else{
                        ws.currentSearchPageInfo = designerListModel.pageInfo;
                        if (ws.currentSearchPageInfo == nil || ws.currentSearchPageInfo.isFirstPage) {
                            [ws.searchResultArray removeAllObjects];
                        }
                    }
                }
            }
        }

        [MBProgressHUD hideAllHUDsForView:ws.view animated:YES];
        if (rspStatusAndMessage.status != YYReqStatusCode100) {
            [YYToast showToastWithTitle:rspStatusAndMessage.message andDuration:kAlertToastDuration];
        }
        _isLoadingListData = NO;
        [ws reloadCollectionViewData];
    }];
}

- (void)addHeader
{
    WeakSelf(ws);
    // 添加下拉刷新头部控件
    MJRefreshNormalHeader *header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        // 进入刷新状态就会回调这个Block
        if ([YYCurrentNetworkSpace isNetwork]){
            if(!ws.isSearchView){
                [ws loadDataByPageIndex:1 queryStr:@""];
            }else{
                if(![ws.searchFieldStr isEqualToString:@""]){
                    [ws loadDataByPageIndex:1 queryStr:ws.searchFieldStr];
                }
            }
        }else{
            [ws.collectionView.mj_header endRefreshing];
            [YYToast showToastWithTitle:kNetworkIsOfflineTips andDuration:kAlertToastDuration];
        }
    }];
    self.collectionView.mj_header = header;
    self.collectionView.mj_header.automaticallyChangeAlpha = YES;
    header.lastUpdatedTimeLabel.hidden = YES;
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

        if(!ws.isSearchView){
            if( [ws.designerListArray count] > 0 && ws.currentPageInfo
               && !ws.currentPageInfo.isLastPage){
                [ws loadDataByPageIndex:[ws.currentPageInfo.pageIndex intValue]+1 queryStr:@""];
                return;
            }
        }else if(![_searchFieldStr isEqualToString:@""] && [ws.searchResultArray count] > 0 && ws.currentSearchPageInfo
                 && !ws.currentSearchPageInfo.isLastPage){
            [ws loadDataByPageIndex:[ws.currentSearchPageInfo.pageIndex intValue]+1 queryStr:ws.searchFieldStr];
            return;
        }

        [ws.collectionView.mj_footer endRefreshing];
    }];
}

#pragma mark - search
- (void)showSearchView:(id)sender {
    if (_searchView.hidden == YES) {
        
        self.suitChooseView.hidden = YES;
        self.suitBtn.selected = NO;
        self.suitImg.image = [UIImage imageNamed:@"down"];
        
        _searchView.hidden = NO;
        _searchField.text = nil;
        _searchFieldStr = @"";
        _searchView.alpha = 0.0;
        _searchViewTopLayoutConstraint.constant = -44;
        self.searchResultArray = [[NSMutableArray alloc] init];
        [_searchView layoutIfNeeded];

        [UIView animateWithDuration:0.3 animations:^{
            _searchView.alpha = 1.0;
            _searchViewTopLayoutConstraint.constant = 0;
            [_searchView layoutIfNeeded];
        } completion:^(BOOL finished) {
            [_searchField becomeFirstResponder];
            self.isSearchView = YES;
            self.noDataView.hidden = YES;
            [self reloadCollectionViewData];
            [self updatePeopleHeadView];
        }];
    }
}
- (void)hideSearchView:(id)sender {
    if ( _searchView.hidden == NO) {
        _searchFieldStr = @"";
        _searchView.alpha = 1.0;
        _searchViewTopLayoutConstraint.constant = 0;
        [_searchView layoutIfNeeded];
        
        [self updatePeopleHeadView];
        [UIView animateWithDuration:0.3 animations:^{
            _searchViewTopLayoutConstraint.constant = -44;
            _searchView.alpha = 0.0;
            [_searchView layoutIfNeeded];
        } completion:^(BOOL finished) {
            _searchView.hidden = YES;
           [_searchField resignFirstResponder];
            self.isSearchView = NO;
            self.searchResultArray = nil;
            self.noDataView.hidden = YES;
            [self reloadCollectionViewData];
            [self updatePeopleHeadView];
        }];
    }
}

- (void)textFieldDidEndEditing:(UITextField *)textField{
    [[NSNotificationCenter defaultCenter]removeObserver:self name:UITextFieldTextDidChangeNotification object:_searchField];
    
}

-(void) textFieldDidBeginEditing:(UITextField *)textField{
    _isSearchView = YES;
    [self reloadCollectionViewData];
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
    if(![str isEqualToString:@""]){
        _searchFieldStr = str;
        _isSearchView = YES;
    }else{
        _searchFieldStr = @"";
    }
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    if(![_searchFieldStr isEqualToString:@""]){
        [_searchField resignFirstResponder];
        [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        [self loadDataByPageIndex:1 queryStr:_searchFieldStr];
        return YES;
    }
    return NO;
}
#pragma mark - Other
- (void)initMessageButton {
    self.messageButton = [[YYMessageButton alloc] init];
    [self.messageButton initButton:@""];
    [self messageCountChanged:nil];
    [self.messageButton addTarget:self action:@selector(messageButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(messageCountChanged:) name:UnreadMsgAmountChangeNotification object:nil];
    [self.navView addSubview:self.messageButton];
    [self.messageButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(50);
        make.height.mas_equalTo(44);
        make.top.mas_equalTo(kStatusBarHeight);
        make.right.mas_equalTo(0);
    }];
}

- (void)initSearchButton {
    WeakSelf(ws);
    self.searchButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.searchButton setImage:[UIImage imageNamed:@"search_icon"] forState:UIControlStateNormal];
    self.searchButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
    [self.searchButton addTarget:self action:@selector(showSearchView:) forControlEvents:UIControlEventTouchUpInside];
    [self.navView addSubview:self.searchButton];
    [self.searchButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(50);
        make.height.mas_equalTo(44);
        make.centerY.mas_equalTo(ws.messageButton.mas_centerY);
        make.right.mas_equalTo(ws.messageButton.mas_left);
    }];
}

- (void)initSearchView {
    self.searchView = [[UIView alloc] init];
    self.searchView.backgroundColor = _define_white_color;
    self.searchView.hidden = YES;
    [self.navView addSubview:self.searchView];
    [self.searchView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(44);
        make.top.mas_equalTo(kStatusBarHeight);
        make.left.right.mas_equalTo(0);
    }];
    
    UIView *searchBackView = [[UIView alloc] init];
    searchBackView.backgroundColor = [UIColor colorWithHex:@"efefef"];
    searchBackView.layer.masksToBounds = YES;
    searchBackView.layer.cornerRadius = 3.0f;
    [self.searchView addSubview:searchBackView];
    [searchBackView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(30);
        make.centerY.mas_equalTo(0);
        make.left.mas_equalTo(13);
    }];
    
    UIButton *iconButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [iconButton setImage:[UIImage imageNamed:@"search_Img"] forState:UIControlStateNormal];
    iconButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    [searchBackView addSubview:iconButton];
    [iconButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(18);
        make.height.mas_equalTo(22);
        make.centerY.mas_equalTo(0);
        make.left.mas_equalTo(10);
    }];
    
    self.searchField = [[UITextField alloc] init];
    self.searchField.delegate = self;
    self.searchField.borderStyle = UITextBorderStyleNone;
    self.searchField.returnKeyType = UIReturnKeySearch;
    self.searchField.backgroundColor = [UIColor colorWithHex:@"efefef"];
    self.searchField.placeholder = NSLocalizedString(@"输入款式名称/款号/颜色搜索", nil);
    if (IsPhone6_gt) {
        self.searchField.font = [UIFont systemFontOfSize:14];
    }else {
        self.searchField.font = [UIFont systemFontOfSize:12];
    }
    self.searchField.clearButtonMode = UITextFieldViewModeAlways;
    [searchBackView addSubview:self.searchField];
    [self.searchField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.bottom.right.mas_equalTo(0);
        make.left.mas_equalTo(iconButton.mas_right);
    }];
    
    UIButton *cancelButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [cancelButton setTitle:NSLocalizedString(@"取消", nil) forState:UIControlStateNormal];
    [cancelButton setTitleColor:[UIColor colorWithHex:@"919191"] forState:UIControlStateNormal];
    cancelButton.titleLabel.font = [UIFont systemFontOfSize:18];
    cancelButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
    [cancelButton addTarget:self action:@selector(hideSearchView:) forControlEvents:UIControlEventTouchUpInside];
    [self.searchView addSubview:cancelButton];
    [cancelButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(60);
        make.height.mas_equalTo(44);
        make.top.mas_equalTo(0);
        make.left.mas_equalTo(searchBackView.mas_right);
        make.right.mas_equalTo(-13);
    }];
}

@end
