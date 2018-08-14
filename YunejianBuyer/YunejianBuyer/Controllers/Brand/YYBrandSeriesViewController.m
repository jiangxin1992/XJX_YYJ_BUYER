//
//  YYBrandSeriesViewController.m
//  Yunejian
//
//  Created by Apple on 15/12/3.
//  Copyright © 2015年 yyj. All rights reserved.
//

#import "YYBrandSeriesViewController.h"

// c文件 —> 系统文件（c文件在前）

// 控制器
#import "YYStyleDetailViewController.h"
#import "YYCartDetailViewController.h"

// 自定义视图
#import "YYNavView.h"
#import "MBProgressHUD.h"
#import "YYDateRangeItemCell.h"
#import "YYSeriesInfoViewCell.h"
#import "YYSeriesStyleViewCell.h"
#import "YYTopBarShoppingCarButton.h"
#import "YYBrandSeriesHeadView.h"

// 接口
#import "YYOpusApi.h"

// 分类

// 自定义类和三方类（ cocoapods类 > model > 工具类 > 其他）
#import <MJRefresh.h>

#import "YYPageInfoModel.h"
#import "YYOrderInfoModel.h"
#import "YYSeriesInfoModel.h"
#import "YYOpusSeriesModel.h"
#import "YYOpusStyleListModel.h"
#import "YYSeriesInfoDetailModel.h"
#import "YYStylesAndTotalPriceModel.h"
#import "YYBrandSeriesToCartTempModel.h"

#import "AppDelegate.h"
#import "UserDefaultsMacro.h"
#import "RBCollectionViewBalancedColumnLayout.h"

#define YY_COLLECTION_HEADERVIEW_HEIGHT 66//headview height

@interface YYBrandSeriesViewController ()<UICollectionViewDataSource,UICollectionViewDelegate,UIScrollViewDelegate,UITextFieldDelegate,YYTableCellDelegate,UITableViewDelegate,UITableViewDataSource>

@property (weak, nonatomic) IBOutlet UIView *containerView;
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (strong, nonatomic) YYNavView *navView;
@property (strong, nonatomic) UIButton *searchButton;
@property (strong, nonatomic) UITextField *searchField;
@property (strong, nonatomic) UIView *searchView;

@property (strong, nonatomic) YYTopBarShoppingCarButton *topBarShoppingCarButton;
@property (nonatomic,strong) YYPageInfoModel *currentPageInfo;
@property (nonatomic,strong) NSMutableArray *stylesListArray;
@property(nonatomic,strong) YYSeriesInfoDetailModel *seriesInfoDetailModel;

//查询结果
@property (nonatomic,assign) BOOL isSearchView;
@property (nonatomic,copy) NSString *searchFieldStr;
@property (nonatomic,strong) NSMutableArray *searchResultArray;
@property (nonatomic,strong) YYPageInfoModel *currentSearchPageInfo;
@property(nonatomic,strong) YYStylesAndTotalPriceModel *stylesAndTotalPriceModel;//总数

//波段更好bar
@property (weak, nonatomic) IBOutlet UIControl *dateRangeFilterView;
@property (weak, nonatomic) IBOutlet UILabel *dateRangeTitleLabel;
@property (weak, nonatomic) IBOutlet UILabel *dateRangeValueLabel;
@property (strong, nonatomic) YYDateRangeModel *selectDateRange;
@property (nonatomic,strong) NSMutableArray *filterResultArray;
//当前税制
@property (assign, nonatomic) NSInteger selectTaxType;
@property (strong, nonatomic) NSArray *taxTypeData;

@property (assign, nonatomic) NSInteger selectListDataType;//0波段 1selectTaxType
@property (strong, nonatomic) CMAlertView *selectListAlert;
@property (nonatomic,strong) UITableView *selectListTableView;

@property (nonatomic)BOOL isDetail;

@property (nonatomic, assign) BOOL isSelect;

@property (nonatomic,strong) YYBrandSeriesHeadView *tempHeadView;

@property (nonatomic, strong) NSMutableArray *intentionStyleArray;//意向单临时存储

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *collectionViewTopLayout;

@property (nonatomic,assign) NSComparisonResult orderDueCompareResult;

@end

@implementation YYBrandSeriesViewController

static NSInteger infoViewHeight = 210;
static NSInteger headViewHeight = 37;

#pragma mark - --------------生命周期--------------
- (void)viewDidLoad {
    [super viewDidLoad];
    [self SomePrepare];
    [self UIConfig];
    [self RequestData];
}

-(void)dealloc{}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self updateShoppingCar];
    
    if(_seriesInfoDetailModel){
        AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
        //初始化或更新(brandName和brandLogo)购物车信息
        NSString *tempBrandName = [NSString isNilOrEmpty:_seriesInfoDetailModel.series.designerBrandName]?@"":_seriesInfoDetailModel.series.designerBrandName;
        NSString *tempLogoPath = [NSString isNilOrEmpty:_seriesInfoDetailModel.series.designerBrandLogo]?@"":_seriesInfoDetailModel.series.designerBrandLogo;
        [appDelegate initOrUpdateShoppingCarInfo:@(_designerId) designerInfo:@[tempBrandName,tempLogoPath]];
    }
    // 进入埋点
    [MobClick beginLogPageView:kYYPageBrandSeries];
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    // 退出埋点
    [MobClick endLogPageView:kYYPageBrandSeries];
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
- (void)PrepareData{
    _searchFieldStr = @"";
    self.stylesListArray = [[NSMutableArray alloc] init];
    _isSelect = NO;

    self.intentionStyleArray = [[NSMutableArray alloc] init];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateShoppingCarNotification:) name:kUpdateShoppingCarNotification object:nil];
}
- (void)updateShoppingCarNotification:(NSNotification *)note{
    [self updateShoppingCar];
}
- (void)PrepareUI{
    self.navView = [[YYNavView alloc] initWithTitle:nil WithSuperView:self.view haveStatusView:YES];
    [self initShoppingCartButton];
    self.searchButton = [self createSearchButton];
    [self.navView setNavCustomView:self.searchButton];
    [self initSearchView];

    _dateRangeFilterView.hidden = YES;

    [self addHeader];
    [self addFooter];

    self.collectionView.contentInset = UIEdgeInsetsMake(0, 0, 0, 0);

    RBCollectionViewBalancedColumnLayout * layout = (id)self.collectionView.collectionViewLayout;
    layout.interItemSpacingY = 15;
    layout.stickyHeader = NO;
}

#pragma mark - --------------UIConfig----------------------
-(void)UIConfig{
    [self createOrUpdateTempHeadView];
}
-(void)createOrUpdateTempHeadView{
    if(!_tempHeadView){
        _tempHeadView = [[YYBrandSeriesHeadView alloc] initWithFrame:CGRectMake(0, kIPhoneX?(45 + 44):(45 + 20), SCREEN_WIDTH, YY_COLLECTION_HEADERVIEW_HEIGHT)];
        [self.view addSubview:_tempHeadView];
        _tempHeadView.delegate = self;
        _tempHeadView.hidden = YES;
    }
    _tempHeadView.orderDueCompareResult = _orderDueCompareResult;
    _tempHeadView.isSelect = _isSelect;
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
    _tempHeadView.selectCount = _intentionStyleArray.count;
    _tempHeadView.indexPath = indexPath;
    [_tempHeadView updateUI];
    [self scrollViewDidScroll:_collectionView];
}
#pragma mark - --------------请求数据----------------------
-(void)RequestData{
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [self changeSeries:0];
}
-(void)loadSeriesInfo{
    WeakSelf(ws);
    [YYOpusApi getConnSeriesInfoWithId:_designerId seriesId:_seriesId andBlock:^(YYRspStatusAndMessage *rspStatusAndMessage, YYSeriesInfoDetailModel *infoDetailModel, NSError *error) {
        if (rspStatusAndMessage.status == YYReqStatusCode100){
            ws.seriesInfoDetailModel = infoDetailModel;
            NSComparisonResult compareResult = NSOrderedDescending;
            if(ws.seriesInfoDetailModel.series.orderDueTime !=nil){
                compareResult = compareNowDate(ws.seriesInfoDetailModel.series.orderDueTime);
            }
            self.orderDueCompareResult = compareResult;
        }
        [MBProgressHUD hideAllHUDsForView:ws.view animated:YES];
        if (rspStatusAndMessage.status != YYReqStatusCode100) {
            [YYToast showToastWithTitle:rspStatusAndMessage.message  andDuration:kAlertToastDuration];
        }
        [ws reloadCollectionViewData];
    }];
}

- (void)loadDataByPageIndex:(int)pageIndex queryStr:(NSString*)queryStr{
    WeakSelf(ws);
    [YYOpusApi getConnStyleListWithDesignerId:_designerId seriesId:_seriesId orderBy:nil queryStr:queryStr pageIndex:pageIndex pageSize:8 andBlock:^(YYRspStatusAndMessage *rspStatusAndMessage, YYOpusStyleListModel *opusStyleListModel, NSError *error) {
        if (rspStatusAndMessage.status == YYReqStatusCode100 && opusStyleListModel.result
            ) {
            if(!_isSearchView){
                ws.currentPageInfo = opusStyleListModel.pageInfo;
                if (ws.currentPageInfo== nil || ws.currentPageInfo.isFirstPage) {
                    [ws.stylesListArray removeAllObjects];
                }
                if([opusStyleListModel.result count] > 0)
                    [ws.stylesListArray addObjectsFromArray:opusStyleListModel.result];
            }else{
                ws.currentSearchPageInfo = opusStyleListModel.pageInfo;
                if (ws.currentSearchPageInfo == nil || ws.currentSearchPageInfo.isFirstPage) {
                    [ws.searchResultArray removeAllObjects];
                }
                [ws.searchResultArray addObjectsFromArray:opusStyleListModel.result];
            }
        }

        [MBProgressHUD hideAllHUDsForView:ws.view animated:YES];
        if (rspStatusAndMessage.status != YYReqStatusCode100) {
            [YYToast showToastWithTitle:rspStatusAndMessage.message  andDuration:kAlertToastDuration];
        }
        [ws reloadCollectionViewData];
    }];
}

- (void)getStyleDetailInfoByStyleId:(long)styleId successed:(void (^) (YYStyleInfoModel *styleInfoModel))successBlock {
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    WeakSelf(ws);
    [YYOpusApi getStyleInfoByStyleId:styleId orderCode:nil andBlock:^(YYRspStatusAndMessage *rspStatusAndMessage, YYStyleInfoModel *styleInfoModel, NSError *error) {
        [MBProgressHUD hideAllHUDsForView:ws.view animated:YES];
        if (!error && rspStatusAndMessage.status == YYReqStatusCode100) {
            if (successBlock) {
                successBlock(styleInfoModel);
            }
        }
    }];
}

#pragma mark - --------------系统代理----------------------
#pragma mark -UICollectionViewDataSource
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView{
    return 2;
}
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    if (section == 0) {
        return 1;
    }
    if(_isSearchView){
        return [_searchResultArray count];
    }
    if(_filterResultArray != nil){
        return [_filterResultArray count];
    }
    return [self.stylesListArray count];
}
#pragma mark -RBCollectionViewBalancedColumnLayoutDelegate
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(RBCollectionViewBalancedColumnLayout*)collectionViewLayout heightForItemAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.section == 0){//
        if(_isSearchView){
            return 0.1;

        }
        NSString *descStr = ((_seriesInfoDetailModel && _seriesInfoDetailModel.brandDescription.length>0)?_seriesInfoDetailModel.brandDescription:@"");
        infoViewHeight = [YYSeriesInfoViewCell cellHeight:descStr isDetail:_isDetail showMinPrice:[self.seriesInfoDetailModel.series.orderPriceMin floatValue] > 0];
        return infoViewHeight;
    }else{
        YYOpusStyleModel *opusStyleModel = nil;
        if(_isSearchView && ([_searchResultArray count] > indexPath.row)){
            opusStyleModel = [_searchResultArray objectAtIndex:indexPath.row];
        }else if ([_filterResultArray count] > indexPath.row) {
            opusStyleModel = [_filterResultArray objectAtIndex:indexPath.row];
        }else if ([_stylesListArray count] > indexPath.row) {
            opusStyleModel = [_stylesListArray objectAtIndex:indexPath.row];
        }
        NSInteger moneyType = (opusStyleModel?[opusStyleModel.curType integerValue]:0);

        NSInteger cellWidth = (SCREEN_WIDTH-25-7)/2;
        if(needPayTaxView(moneyType) &&_selectTaxType){
            return 355 + cellWidth - 10 - 196;
        }else{
            return 333 + cellWidth - 10 - 196;
        }
    }
}


- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(RBCollectionViewBalancedColumnLayout *)collectionViewLayout widthForCellsInSection:(NSInteger)section
{
    if(section == 0){
        return SCREEN_WIDTH;
    }else{
        NSInteger cellWidth = (SCREEN_WIDTH-25-7)/2;
        return cellWidth;
    }
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.section == 0){

        static NSString* reuseIdentifier = @"YYSeriesInfoViewCell";
        YYSeriesInfoViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:reuseIdentifier forIndexPath:indexPath];
        if(_isSearchView){
            cell.hidden = YES;
        }else{
            cell.orderDueCompareResult = _orderDueCompareResult;
            cell.isSelect = _isSelect;
            cell.hidden = NO;
            cell.seriesModel = _seriesInfoDetailModel.series;
            cell.seriesDescription =_seriesInfoDetailModel.brandDescription;
            cell.dateRanges = _seriesInfoDetailModel.dateRanges;
            cell.selectDateRange = self.selectDateRange;
            cell.selectTaxType = _selectTaxType;
            cell.isDetail = _isDetail;
            cell.delegate = self;
            cell.indexPath = indexPath;
            cell.selectCount = _intentionStyleArray.count;
            [cell updateUI];
        }
        [cell setSeriesInfoBlock:^(NSString *type){
            WeakSelf(ws);
            if([type isEqualToString:@"cancel_collect"] || [type isEqualToString:@"go_collect"]){
                [ws collectionAction:type];
            }else if([type isEqualToString:@"enter_designer"]){
                [ws enterDesignerView:ws.seriesInfoDetailModel.series];
            }
        }];
        return cell;

    }else if(indexPath.section == 1){
        static NSString* reuseIdentifier = @"YYSeriesStyleViewCell";
        YYSeriesStyleViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:reuseIdentifier forIndexPath:indexPath];
        YYOpusStyleModel *opusStyleModel = nil;
        if(_isSearchView && ([_searchResultArray count] > indexPath.row)){
            opusStyleModel = [_searchResultArray objectAtIndex:indexPath.row];
        }else if ([_filterResultArray count] > indexPath.row) {
            opusStyleModel = [_filterResultArray objectAtIndex:indexPath.row];
        }else if ([_stylesListArray count] > indexPath.row) {
            opusStyleModel = [_stylesListArray objectAtIndex:indexPath.row];
        }
        cell.opusStyleModel = opusStyleModel;
        cell.selectTaxType = _selectTaxType;
        cell.isModifyOrder = NO;
        cell.delegate = self;
        cell.indexPath = indexPath;
        cell.isSelect = _isSelect;
        cell.opusStyleIsSelect = [self opusStyleIsSelect:opusStyleModel];
        [cell updateUI];
        return cell;
    }
    UICollectionViewCell *cell = [[UICollectionViewCell alloc] init];
    cell.backgroundColor = [UIColor lightGrayColor];
    return cell;
}
-(BOOL )opusStyleIsSelect:(YYOpusStyleModel *)opusStyleModel{
    BOOL isexit = NO;
    for (YYBrandSeriesToCartTempModel *brandSeriesToCardTempModel in _intentionStyleArray) {
        //遍历看看有没有
        if([brandSeriesToCardTempModel.styleInfoModel.style.id integerValue] == [opusStyleModel.id integerValue]){
            isexit = YES;
        }
    }
    return isexit;
}
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.section == 0 || ([NSMutableArray isNilOrEmpty:_searchResultArray]&&[NSMutableArray isNilOrEmpty:_filterResultArray]&&[NSMutableArray isNilOrEmpty:_stylesListArray]) || !self.seriesInfoDetailModel){
        return;
    }

    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    //初始化或更新(brandName和brandLogo)购物车信息
    NSString *tempBrandName = [NSString isNilOrEmpty:self.seriesInfoDetailModel.series.designerBrandName]?@"":self.seriesInfoDetailModel.series.designerBrandName;
    NSString *tempLogoPath = [NSString isNilOrEmpty:self.seriesInfoDetailModel.series.designerBrandLogo]?@"":self.seriesInfoDetailModel.series.designerBrandLogo;
    [appDelegate initOrUpdateShoppingCarInfo:self.seriesInfoDetailModel.series.designerId designerInfo:@[tempBrandName,tempLogoPath]];

    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Opus" bundle:[NSBundle mainBundle]];
    YYStyleDetailViewController *styleDetailViewController = [storyboard instantiateViewControllerWithIdentifier:@"YYStyleDetailViewController"];
    styleDetailViewController.currentIndex = indexPath.row;
    if(_searchResultArray != nil){
        styleDetailViewController.onlineOrOfflineOpusStyleArray = self.searchResultArray;
        if(self.currentSearchPageInfo == nil){
            styleDetailViewController.totalPages = [self.searchResultArray count];
        }else{
            styleDetailViewController.totalPages = [self.currentSearchPageInfo.recordTotalAmount integerValue];
        }
        styleDetailViewController.opusSeriesModel = [_seriesInfoDetailModel toOpusSeriesModel];
    }else if([_filterResultArray count] > 0){
        styleDetailViewController.onlineOrOfflineOpusStyleArray = self.filterResultArray;
        styleDetailViewController.totalPages = [self.filterResultArray count];
        styleDetailViewController.opusSeriesModel = [_seriesInfoDetailModel toOpusSeriesModel];
    }else if([_stylesListArray count] > 0){
        styleDetailViewController.onlineOrOfflineOpusStyleArray = self.stylesListArray;
        styleDetailViewController.totalPages = [self.currentPageInfo.recordTotalAmount integerValue];
        styleDetailViewController.opusSeriesModel = [_seriesInfoDetailModel toOpusSeriesModel];
    }
    styleDetailViewController.selectTaxType = _selectTaxType;
    [self.navigationController pushViewController:styleDetailViewController animated:YES];

}
#pragma mark -UITableViewDelegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if(_selectListDataType == 0){
        return [_seriesInfoDetailModel.dateRanges count]+1;
    }else if(_selectListDataType == 1){
        return [_taxTypeData count];
    }else{
        return 0;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 58;
}


- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *CellIdentifier = @"YYDateRangeItemCell";
    YYDateRangeItemCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    if(_selectListDataType == 0){
        if(indexPath.row == 0){
            cell.dateRangeTitleLabel.text = [NSString stringWithFormat:NSLocalizedString(@"共分%lu个波段",nil),(unsigned long)[_seriesInfoDetailModel.dateRanges count]];
            cell.dateRangeValueLabel.text = [NSString stringWithFormat:@"%@-%@",getShowDateByFormatAndTimeInterval(@"yyyy/MM/dd",[_seriesInfoDetailModel.series.supplyStartTime stringValue]),getShowDateByFormatAndTimeInterval(@"yyyy/MM/dd",[_seriesInfoDetailModel.series.supplyEndTime stringValue])];
        }else{
            YYDateRangeModel *dateRangeModel = [_seriesInfoDetailModel.dateRanges objectAtIndex:(indexPath.row-1)];
            cell.dateRangeTitleLabel.text = dateRangeModel.name;
            cell.dateRangeValueLabel.text = [NSString stringWithFormat:@"%@-%@",getShowDateByFormatAndTimeInterval(@"yyyy/MM/dd",[dateRangeModel.start stringValue]),getShowDateByFormatAndTimeInterval(@"yyyy/MM/dd",[dateRangeModel.end stringValue])];
        }
    }else if(_selectListDataType == 1){
        NSString *taxType = [_taxTypeData objectAtIndex:indexPath.row];
        cell.dateRangeTitleLabel.text = taxType;
        if(indexPath.row == 1){
            cell.dateRangeValueLabel.text = NSLocalizedString(@"一般纳税人增值税",nil);
        }else if(indexPath.row == 2){
            cell.dateRangeValueLabel.text = NSLocalizedString(@"小规模纳税人增值税",nil);
        }else{
            cell.dateRangeValueLabel.text = @"";
        }
    }
    cell.dateRangeValueLabel.adjustsFontSizeToFitWidth = YES;
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(nonnull NSIndexPath *)indexPath{
    if(_selectListDataType == 0){
        if(indexPath.row != 0){
            self.filterResultArray = [[NSMutableArray alloc] init];
            // _series
            YYDateRangeModel *dateRange = [_seriesInfoDetailModel.dateRanges objectAtIndex:(indexPath.row-1)];
            if(dateRange){
                if([self.stylesListArray count] >0){
                    for (YYOpusStyleModel *stylemodel in self.stylesListArray) {
                        if(stylemodel.dateRange && [stylemodel.dateRange.id integerValue] == [dateRange.id integerValue]){
                            [self.filterResultArray addObject:stylemodel];
                        }
                    }
                }
                self.selectDateRange = dateRange;
            }
        }else{
            self.filterResultArray = nil;
            self.selectDateRange = nil;
        }
        [self updateDateRangeUI:self.selectDateRange];
    }else if(_selectListDataType == 1){
        _selectTaxType = indexPath.row;
    }

    [self reloadCollectionViewData];
    if(_selectListTableView){
        [_selectListTableView removeFromSuperview];
    }
    if(_selectListAlert){
        [_selectListAlert OnTapBg:nil];
    }
}
#pragma mark -UITextFieldDelegate
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
#pragma mark -scrollViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView; {

    NSLog(@"scrollView.contentOffset.y = %lf",scrollView.contentOffset.y);

    if(_isSearchView){
        //显示
        if([NSMutableArray isNilOrEmpty:_searchResultArray]){
            _tempHeadView.hidden = YES;
        }else{
            _tempHeadView.hidden = NO;
        }

    }else{
        NSString *descStr = ((_seriesInfoDetailModel && _seriesInfoDetailModel.brandDescription.length>0)?_seriesInfoDetailModel.brandDescription:@"");
        NSInteger tempHeight = [YYSeriesInfoViewCell cellHeight:descStr isDetail:_isDetail showMinPrice:[self.seriesInfoDetailModel.series.orderPriceMin floatValue] > 0];
        if (scrollView.contentOffset.y > tempHeight - YY_COLLECTION_HEADERVIEW_HEIGHT){
            //显示
            _tempHeadView.hidden = NO;
        }else{
            //消失
            _tempHeadView.hidden = YES;
        }
    }

    if(_isSearchView){
        return ;
    }

    if (scrollView.contentOffset.y > (infoViewHeight - headViewHeight) ) {
        _dateRangeFilterView.hidden = NO;
        [self updateDateRangeUI:self.selectDateRange];
    }else{
        _dateRangeFilterView.hidden = YES;
    }
}
#pragma mark - --------------自定义代理/block----------------------
#pragma mark -YYTableCellDelegate
-(void)btnClick:(NSInteger)row section:(NSInteger)section andParmas:(NSArray *)parmas{
    NSString *type = [parmas objectAtIndex:0];
    if([type isEqualToString:@"descDetail"]){
        BOOL value = [[parmas objectAtIndex:1] boolValue];
        _isDetail = !value;
        [self reloadCollectionViewData];
    }else if([type isEqualToString:@"filterDateRange"]){
        [self filterDateRangHandler:nil];
    }else if([type isEqualToString:@"selectedTaxType"]){
        [self selectTaxTypeHandler:nil];
    }else if([type isEqualToString:@"addToCart"]){
        //加入购物车
        [self addToCart];
    }else if([type isEqualToString:@"cancelAddToCart"]){
        //取消购物车
        [self cancelAddToCart];
    }else if([type isEqualToString:@"sureToAddToCart"]){
        //确认加入
        [self sureToAddToCart];
    }else if([type isEqualToString:@"selectStyle"]){
        //锁定（取消锁定)款式
        YYOpusStyleModel *opusStyleModel = [parmas objectAtIndex:1];
        [self selectStyleWithOpusStyleModel:opusStyleModel];
    }
}
//加入购物车
-(void)addToCart{
    if(self.orderDueCompareResult == NSOrderedAscending){
        [YYToast showToastWithTitle:NSLocalizedString(@"此系列已过最晚下单日期，不能下单。",nil) andDuration:kAlertToastDuration];
    }else{
        _isSelect = YES;
        [self reloadCollectionViewData];
    }
}
//取消购物车
-(void)cancelAddToCart{
    _isSelect = NO;
    [self reloadCollectionViewData];
}
//确认加入
-(void)sureToAddToCart{

    //当购物车中无数据时
    //需要判断当前所选款式中否是含多币种
    BOOL isContainMultiCurType = NO;
    if (self.stylesAndTotalPriceModel.totalStyles <= 0) {
        if(_intentionStyleArray.count > 1){
            NSInteger moneyType = -1;
            for (YYBrandSeriesToCartTempModel *brandSeriesToCardTempModel in _intentionStyleArray) {
                if (brandSeriesToCardTempModel) {
                    if(moneyType < 0){
                        moneyType = [brandSeriesToCardTempModel.styleInfoModel.style.curType integerValue];
                    }else{
                        if(moneyType != [brandSeriesToCardTempModel.styleInfoModel.style.curType integerValue]){
                            isContainMultiCurType = YES;
                            break;
                        }
                    }
                }
            }
        }
    }

    if(isContainMultiCurType){
        [YYToast showToastWithView:self.view title:NSLocalizedString(@"不同币种的款式不能同时加入购物车",nil) andDuration:kAlertToastDuration];
        return;
    }

    //遍历 加入购物车
    for (YYBrandSeriesToCartTempModel *brandSeriesToCardTempModel in _intentionStyleArray) {
        [self addToLocalCartWithTempModel:brandSeriesToCardTempModel];
        NSLog(@"1111");
    }
    //发出通知，更新购物车图标
    [[NSNotificationCenter defaultCenter] postNotificationName:kUpdateShoppingCarNotification object:nil];
    _isSelect = NO;
    [_intentionStyleArray removeAllObjects];
    [self removeTempIsSelect];
    [self reloadCollectionViewData];
}
-(void)addToLocalCartWithTempModel:(YYBrandSeriesToCartTempModel *)brandSeriesToCardTempModel{

    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];

    NSMutableArray *tempSeriesArray = appDelegate.seriesArray;
    if(tempSeriesArray == nil){
        tempSeriesArray = [[NSMutableArray alloc] init];
    }
    YYStyleInfoModel *styleInfoModel = brandSeriesToCardTempModel.styleInfoModel;
    YYOpusSeriesModel *opusSeriesModel = brandSeriesToCardTempModel.opusSeriesModel;
    YYOrderInfoModel *tempOrderInfoModel = brandSeriesToCardTempModel.tempOrderInfoModel;
    NSArray *sizeNameArr = brandSeriesToCardTempModel.sizeNameArr;
    NSArray *amountSizeArr = brandSeriesToCardTempModel.amountSizeArr;
    BOOL isModifyOrder = brandSeriesToCardTempModel.isModifyOrder;

    NSString *_remark = @"";
    YYDateRangeModel *_tmpDateRange = nil;
    NSString *_tmpRemark = @"";

    YYOrderOneInfoModel *orderOneInfoM = nil;
    if ([tempSeriesArray count] > 0) {
        //已经有系列创建
        //查询是否已经有该系列

        for (YYOrderOneInfoModel *orderOneInfoModel in tempSeriesArray) {
            if((styleInfoModel.dateRange && [styleInfoModel.dateRange.id integerValue] > 0 &&  [orderOneInfoModel.dateRange.id  integerValue] == [styleInfoModel.dateRange.id integerValue]) || ((!styleInfoModel.dateRange || [styleInfoModel.dateRange.id integerValue] == 0) &&(orderOneInfoModel.dateRange == nil || [orderOneInfoModel.dateRange.id  integerValue] == 0))){
                orderOneInfoM = orderOneInfoModel;
                break;
            }
        }

        if (orderOneInfoM) {
            NSArray *arr = orderOneInfoM.styles; //当前系列所有款式
            for (YYOrderStyleModel *style in arr){
                if ([style.styleId intValue] == [styleInfoModel.style.id intValue]) {
                    _remark = style.remark;
                    _tmpDateRange = style.tmpDateRange;
                    _tmpRemark = style.tmpRemark;
                    [orderOneInfoM.styles removeObject:style];
                    break;
                }
            }
        }
    }

    if (!orderOneInfoM) {
        orderOneInfoM = [[YYOrderOneInfoModel alloc] init];
        orderOneInfoM.dateRange = styleInfoModel.dateRange;
        orderOneInfoM.styles = (NSMutableArray<YYOrderStyleModel>*)[[NSMutableArray alloc] init];
        [tempSeriesArray addObject:orderOneInfoM];
    }

    //增加系列队列
    if(opusSeriesModel){
        if(!tempOrderInfoModel.seriesMap){
            tempOrderInfoModel = [[YYOrderInfoModel alloc] init];
            tempOrderInfoModel.seriesMap = (NSMutableDictionary<YYOrderSeriesModel, Optional,ConvertOnDemand> *)[[NSMutableDictionary alloc] init];
        }
        YYOrderSeriesModel *seriesModel = [[YYOrderSeriesModel alloc] init];
        seriesModel.seriesId = opusSeriesModel.id;
        seriesModel.name = opusSeriesModel.name;
        seriesModel.orderAmountMin = opusSeriesModel.orderAmountMin;// style 有orderAmountMin
        seriesModel.supplyStatus = opusSeriesModel.supplyStatus;
        [tempOrderInfoModel.seriesMap setObject:seriesModel forKey:[seriesModel.seriesId stringValue]];
    }


    YYOrderStyleModel *orderStyleModel = [[YYOrderStyleModel alloc] init];
    orderStyleModel.styleId = styleInfoModel.style.id;
    orderStyleModel.albumImg = styleInfoModel.style.albumImg;
    orderStyleModel.name = styleInfoModel.style.name;
    orderStyleModel.finalPrice = (styleInfoModel.style.finalPrice !=nil?styleInfoModel.style.finalPrice: styleInfoModel.style.tradePrice);
    orderStyleModel.originalPrice = styleInfoModel.style.tradePrice;
    orderStyleModel.retailPrice = styleInfoModel.style.retailPrice;
    orderStyleModel.orderAmountMin = styleInfoModel.style.orderAmountMin;
    orderStyleModel.styleCode = styleInfoModel.style.styleCode;
    orderStyleModel.styleModifyTime = styleInfoModel.style.modifyTime;
    orderStyleModel.sizeNameList = (NSArray<YYSizeModel, ConvertOnDemand> *) sizeNameArr;
    orderStyleModel.stockEnabled = @(styleInfoModel.stockEnabled);
    orderStyleModel.dateRange = styleInfoModel.dateRange;
    orderStyleModel.colors =(NSArray<YYOrderOneColorModel, ConvertOnDemand> *) amountSizeArr;
    orderStyleModel.curType = styleInfoModel.style.curType;
    orderStyleModel.seriesId = opusSeriesModel.id;
    orderStyleModel.supportAdd = styleInfoModel.style.supportAdd;
    orderStyleModel.remark = _remark;
    orderStyleModel.tmpDateRange = _tmpDateRange;
    orderStyleModel.tmpRemark = _remark;

    [orderOneInfoM.styles insertObject:orderStyleModel atIndex:0];

    if (isModifyOrder) {
        //修改订单
        appDelegate.orderModel.groups = (NSMutableArray<YYOrderOneInfoModel> *)tempSeriesArray;
        appDelegate.orderModel.seriesMap = tempOrderInfoModel.seriesMap;
        appDelegate.orderSeriesArray = (NSMutableArray<YYOrderOneInfoModel> *)tempSeriesArray;
    }else{
        //修改购物车
        NSInteger cartMoneyType = [styleInfoModel.style.curType integerValue];

        //组合最终的YYOrderInfoModel模型对象。
        if (appDelegate.cartModel.designerId) {
            appDelegate.cartModel.groups = (NSMutableArray<YYOrderOneInfoModel> *)tempSeriesArray;
            appDelegate.cartModel.seriesMap = tempOrderInfoModel.seriesMap;
            appDelegate.cartModel.curType = [NSNumber numberWithInteger:cartMoneyType];
            appDelegate.cartModel.stockEnabled = @(styleInfoModel.stockEnabled);
            appDelegate.seriesArray=(NSMutableArray<YYOrderOneInfoModel> *)tempSeriesArray;
        }else{
            YYOrderInfoModel *orderInfoModel = [[YYOrderInfoModel alloc] init];
            NSArray *brandInfo = [appDelegate.connDesignerInfoMap valueForKey: [opusSeriesModel.designerId stringValue]];
            orderInfoModel.stockEnabled = @(styleInfoModel.stockEnabled);
            orderInfoModel.designerId = opusSeriesModel.designerId;
            orderInfoModel.orderDescription = nil;
            if(brandInfo != nil){
                orderInfoModel.brandLogo = [brandInfo objectAtIndex:1];
                orderInfoModel.brandName = [brandInfo objectAtIndex:0];
            }
            orderInfoModel.groups = (NSMutableArray<YYOrderOneInfoModel> *)tempSeriesArray;
            orderInfoModel.seriesMap = tempOrderInfoModel.seriesMap;
            orderInfoModel.curType = [NSNumber numberWithInteger:cartMoneyType];
            appDelegate.cartModel = orderInfoModel;
            appDelegate.seriesArray =(NSMutableArray<YYOrderOneInfoModel> *)tempSeriesArray;

        }

        //重设isColorSelect
        [self resetCartModelWithTempModel:brandSeriesToCardTempModel];

        //储存对象的JSONString
        NSString *designerId = [appDelegate.cartModel.designerId stringValue];
        NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
        NSString *jsonString = appDelegate.cartModel.toJSONString;
        NSLog(@"%@",jsonString);

        [userDefault setObject:jsonString forKey:[NSString stringWithFormat:@"%@_%@",KUserCartKey,designerId]];
        if(![appDelegate.cartDesignerIdArray containsObject:designerId]){
            [appDelegate.cartDesignerIdArray addObject:designerId];
            [userDefault setObject:[appDelegate.cartDesignerIdArray componentsJoinedByString:@","] forKey:KUserCartBrandKey];
            [userDefault setObject:[NSString stringWithFormat:@"%ld",(long)cartMoneyType] forKey:[NSString stringWithFormat:@"%@_%@",KUserCartMoneyTypeKey,designerId]];
        }
        [userDefault synchronize];
    }

}
- (void)resetCartModelWithTempModel:(YYBrandSeriesToCartTempModel *)brandSeriesToCardTempModel{

    YYStyleInfoModel *styleInfoModel = brandSeriesToCardTempModel.styleInfoModel;
    BOOL isOnlyColor = [brandSeriesToCardTempModel.isOnlyColor boolValue];
    NSMutableArray *selectColorArr = brandSeriesToCardTempModel.selectColorArr;

    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    for (YYOrderOneInfoModel *orderOneInfoModel in appDelegate.cartModel.groups) {
        for (YYOrderStyleModel *orderStyleModel in orderOneInfoModel.styles) {
            if ([orderStyleModel.styleId intValue] == [styleInfoModel.style.id intValue]) {
                for (YYOrderOneColorModel *orderOneColorModel in orderStyleModel.colors) {
                    if(isOnlyColor){
                        //锁定的情况下清空amout
                        BOOL colorIsSelect = NO;
                        for (NSDictionary *tempDict in selectColorArr) {
                            if([[tempDict objectForKey:@"colorId"] integerValue] == [orderOneColorModel.colorId integerValue]){
                                colorIsSelect = [[tempDict objectForKey:@"colorIsSelect"] boolValue];
                            }
                        }
                        if(colorIsSelect){
                            orderOneColorModel.isColorSelect = @(YES);
                            for (YYOrderSizeModel *orderSizeModel in orderOneColorModel.sizes) {
                                orderSizeModel.amount = @(0);
                            }
                        }else{
                            orderOneColorModel.isColorSelect = @(NO);
                            for (YYOrderSizeModel *orderSizeModel in orderOneColorModel.sizes) {
                                //给他设原来的amout    colorId  sizeId
                                orderSizeModel.amount = [self getOldAmountWithColorId:[orderOneColorModel.colorId integerValue] WithSizeId:[orderSizeModel.sizeId integerValue] WithTempModel:brandSeriesToCardTempModel];
                            }
                        }
                    }else{
                        BOOL haveAmount = NO;
                        for (YYOrderSizeModel *orderSizeModel in orderOneColorModel.sizes) {
                            if([orderSizeModel.amount integerValue]){
                                haveAmount = YES;
                            }
                        }

                        if(haveAmount){
                            orderOneColorModel.isColorSelect = @(NO);
                        }
                    }
                }
            }
        }
    }
}
- (NSNumber *)getOldAmountWithColorId:(NSInteger )colorId WithSizeId:(NSInteger )sizeId WithTempModel:(YYBrandSeriesToCartTempModel *)brandSeriesToCardTempModel{

    YYStyleInfoModel *styleInfoModel = brandSeriesToCardTempModel.styleInfoModel;

    YYOrderStyleModel *oldOrderStyleModel = nil;
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    for (YYOrderOneInfoModel *orderOneInfoModel in appDelegate.cartModel.groups) {
        for (YYOrderStyleModel *orderStyleModel in orderOneInfoModel.styles) {
            if ([orderStyleModel.styleId intValue] == [styleInfoModel.style.id intValue]) {
                oldOrderStyleModel = orderStyleModel;
            }
        }
    }

    NSInteger returnamount = 0;
    if(oldOrderStyleModel){
        for (YYOrderOneColorModel *orderOneColorModel in oldOrderStyleModel.colors) {
            if([orderOneColorModel.colorId integerValue] == colorId){
                for (YYOrderSizeModel *orderSizeModel in orderOneColorModel.sizes) {
                    if([orderSizeModel.sizeId integerValue] == sizeId){
                        returnamount = [orderSizeModel.amount integerValue];
                    }
                }
            }
        }
    }
    return @(returnamount);
}
-(void)removeTempIsSelect{
    if(_searchResultArray){
        for (YYOpusStyleModel *opusStyleModel in _searchResultArray) {
            for (YYColorModel *colorModel in opusStyleModel.color) {
                colorModel.isSelect = @(NO);
            }
        }
    }

    if(_filterResultArray){
        for (YYOpusStyleModel *opusStyleModel in _filterResultArray) {
            for (YYColorModel *colorModel in opusStyleModel.color) {
                colorModel.isSelect = @(NO);
            }
        }
    }

    if(_stylesListArray){
        for (YYOpusStyleModel *opusStyleModel in _stylesListArray) {
            for (YYColorModel *colorModel in opusStyleModel.color) {
                colorModel.isSelect = @(NO);
            }
        }
    }
}
//锁定（取消锁定)款式
-(void)selectStyleWithOpusStyleModel:(YYOpusStyleModel *)opusStyleModel{
    BOOL isexit = [self opusStyleIsSelect:opusStyleModel];
    if(!isexit){
        //添加
        [self addShoppingCartWithOpusStyleModel:opusStyleModel];
    }else{
        //删除
        [self removeShoppingCarWithOpusStyleModel:opusStyleModel];
    }
    [self reloadCollectionViewData];
}
-(void)removeShoppingCarWithOpusStyleModel:(YYOpusStyleModel *)opusStyleModel{
    BOOL isExit = NO;
    NSInteger index = 0;
    for (int i=0; i < _intentionStyleArray.count; i++) {
        YYBrandSeriesToCartTempModel *tempBrandSeriesToCardTempModel = _intentionStyleArray[i];
        //遍历看看有没有
        if([tempBrandSeriesToCardTempModel.styleInfoModel.style.id integerValue] == [opusStyleModel.id integerValue]){
            isExit = YES;
            index = i;
        }
    }
    [_intentionStyleArray removeObjectAtIndex:index];
    [self reloadCollectionViewData];
}
- (void)addShoppingCartWithOpusStyleModel:(YYOpusStyleModel *)opusStyleModel{
    if(opusStyleModel.id == nil){
        return;
    }

    NSComparisonResult compareResult = NSOrderedDescending;
    if(opusStyleModel.orderDueTime !=nil){
        compareResult = compareNowDate(opusStyleModel.orderDueTime);
    }
    NSComparisonResult orderDueCompareResult = compareResult;
    if(orderDueCompareResult == NSOrderedAscending) {
        [YYToast showToastWithTitle:NSLocalizedString(@"此系列已过最晚下单日期，不能下单。",nil) andDuration:kAlertToastDuration];
        return;
    }

    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    NSInteger moneyType = -1;
    if (opusStyleModel) {
        moneyType = [opusStyleModel.curType integerValue];
    }
    NSInteger cartMoneyType = -1;
    if(appDelegate.cartModel == nil){
        cartMoneyType = -1;
    }else{
        cartMoneyType = getMoneyType([appDelegate.cartModel.designerId integerValue]);
    }

    if(cartMoneyType > -1 && moneyType != cartMoneyType){
        [YYToast showToastWithView:self.view title:NSLocalizedString(@"购物车中存在其他币种的款式，不能将此款式加入购物车。您可以清空购物车后，将此款式加入购物车。",nil) andDuration:kAlertToastDuration];
        return;
    }

    WeakSelf(ws);
    [self getStyleDetailInfoByStyleId:[opusStyleModel.id longValue] successed:^(YYStyleInfoModel *styleInfoModel) {
        [ws showShoppingView:styleInfoModel];
    }];
}

#pragma mark - --------------自定义响应----------------------
//进入购物车
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

- (IBAction)filterDateRangHandler:(id)sender {
    if(_seriesInfoDetailModel == nil || [_seriesInfoDetailModel.dateRanges count] == 0){
        return;
    }
    _selectListDataType = 0;
    NSInteger listUIWidth = SCREEN_WIDTH - 36;
    NSInteger listUIHeight = ([_seriesInfoDetailModel.dateRanges count]+1)*58;
    listUIHeight = MIN(302, listUIHeight);
    UITableView *view = [self listTableView];
    view.frame = CGRectMake(0, 0, listUIWidth, listUIHeight);
    view.layer.borderColor = [UIColor blackColor].CGColor;
    view.layer.borderWidth = 4;
    _selectListAlert = [[CMAlertView alloc] initWithViews:@[view] imageFrame:CGRectMake(0, 0, listUIWidth, listUIHeight) bgClose:NO];
    [_selectListAlert show];
}
//search
- (void)showSearchView:(id)sender {
    if (_searchView.hidden == YES) {
        _searchView.hidden = NO;
        _searchField.text = nil;
        _searchFieldStr = @"";
        _searchView.alpha = 0.0;
        self.searchResultArray = [[NSMutableArray alloc] init];
        [_searchView layoutIfNeeded];
        [UIView animateWithDuration:0.3 animations:^{
            _searchView.alpha = 1.0;
            [_searchView layoutIfNeeded];
        } completion:^(BOOL finished) {
            [_searchField becomeFirstResponder];
            self.isSearchView = YES;
            [self reloadCollectionViewData];
            self.dateRangeFilterView.hidden = YES;
        }];
    }
}
- (void)hideSearchView:(id)sender {
    if ( _searchView.hidden == NO) {
        _searchFieldStr = @"";
        _searchView.alpha = 1.0;
        [_searchView layoutIfNeeded];
        [UIView animateWithDuration:0.3 animations:^{
            _searchView.alpha = 0.0;
            [_searchView layoutIfNeeded];
        } completion:^(BOOL finished) {
            _searchView.hidden = YES;
            [_searchField resignFirstResponder];
            self.isSearchView = NO;
            self.searchResultArray = nil;
            self.filterResultArray = nil;
            self.selectDateRange = nil;
            [self reloadCollectionViewData];
        }];
    }
}

#pragma mark - --------------自定义方法----------------------
- (void)initShoppingCartButton {
    self.topBarShoppingCarButton = [[YYTopBarShoppingCarButton alloc] init];
    self.topBarShoppingCarButton.isRight = NO;
    [self.topBarShoppingCarButton initButton];
    [self updateShoppingCar];
    [self.topBarShoppingCarButton addTarget:self action:@selector(shoppingCarButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    [self.navView addSubview:self.topBarShoppingCarButton];
    [self.topBarShoppingCarButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(50);
        make.height.mas_equalTo(45);
        make.top.mas_equalTo(kStatusBarHeight);
        make.bottom.mas_equalTo(-1);
        make.right.mas_equalTo(0);
    }];
}

- (UIButton *)createSearchButton {
    UIButton * searchButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [searchButton setFrame:CGRectMake(0, 0, CGRectGetWidth([UIScreen mainScreen].bounds) - 50 * 2, 30)];
    [searchButton setTitle:NSLocalizedString(@"输入款式名称/款号/颜色搜索", nil) forState:UIControlStateNormal];
    [searchButton setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
    if(IsPhone6_gt){
        [searchButton.titleLabel setFont:[UIFont systemFontOfSize:14.0f]];
    }else{
        [searchButton.titleLabel setFont:[UIFont systemFontOfSize:12.0f]];
    }
    searchButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    [searchButton setTitleEdgeInsets:UIEdgeInsetsMake(0, 14, 0, 0)];
    [searchButton setImage:[UIImage imageNamed:@"search_Img"] forState:UIControlStateNormal];
    [searchButton setImageEdgeInsets:UIEdgeInsetsMake(0, 8, 0, 0)];
    searchButton.layer.masksToBounds = YES;
    searchButton.layer.cornerRadius = 3.0f;
    searchButton.backgroundColor = [UIColor colorWithHex:@"efefef"];
    [searchButton addTarget:self action:@selector(showSearchView:) forControlEvents:UIControlEventTouchUpInside];
    return searchButton;
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
//刷新界面
- (void)reloadCollectionViewData{
    [self.collectionView.mj_header endRefreshing];
    [self.collectionView.mj_footer endRefreshing];
    if(_isSearchView){
        if([NSMutableArray isNilOrEmpty:_searchResultArray]){
            _collectionViewTopLayout.constant = 0;
        }else{
            _collectionViewTopLayout.constant = YY_COLLECTION_HEADERVIEW_HEIGHT;
        }
    }else{
        _collectionViewTopLayout.constant = 0;
    }
    [self createOrUpdateTempHeadView];
    [self.collectionView reloadData];
    [_selectListTableView reloadData];
}
-(void)changeSeries:(NSInteger)index{
    [self loadDataByPageIndex:1 queryStr:@""];
    [self loadSeriesInfo];
}
- (void)addHeader{
    WeakSelf(ws);
    MJRefreshNormalHeader *header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        // 进入刷新状态就会回调这个Block
        if ([YYCurrentNetworkSpace isNetwork]){
            if(!ws.isSearchView){
                [ws loadSeriesInfo];
                [ws loadDataByPageIndex:1 queryStr:@""];
            }else{
                if(![ws.searchFieldStr isEqualToString:@""]){
                    [ws loadDataByPageIndex:1 queryStr:ws.searchField.text];
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
- (void)addFooter{
    WeakSelf(ws);
    self.collectionView.mj_footer = [MJRefreshBackNormalFooter footerWithRefreshingBlock:^{
        // 进入刷新状态就会回调这个Block

        if (![YYCurrentNetworkSpace isNetwork]) {
            [YYToast showToastWithTitle:kNetworkIsOfflineTips andDuration:kAlertToastDuration];
            [ws.collectionView.mj_footer endRefreshing];
            return;
        }

        if(!ws.isSearchView){
            if( [ws.stylesListArray count] > 0 && ws.currentPageInfo
               && !ws.currentPageInfo.isLastPage){
                [ws loadDataByPageIndex:[ws.currentPageInfo.pageIndex intValue]+1 queryStr:@""];
                return;
            }
        }else if(![ws.searchFieldStr isEqualToString:@""] && [ws.searchResultArray count] > 0 && ws.currentSearchPageInfo
                 && !ws.currentSearchPageInfo.isLastPage){
            [ws loadDataByPageIndex:[ws.currentSearchPageInfo.pageIndex intValue]+1 queryStr:ws.searchFieldStr];
            return;
        }

        [ws.collectionView.mj_footer endRefreshing];
    }];
}
-(void)enterDesignerView:(YYSeriesInfoModel *)seriesInfoMode{
    if([seriesInfoMode.designerId integerValue]){
        AppDelegate *appdelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
        NSString *brandName = [NSString isNilOrEmpty:seriesInfoMode.designerBrandName]?@"":seriesInfoMode.designerBrandName;
        NSString *logoPath = [NSString isNilOrEmpty:seriesInfoMode.designerBrandLogo]?@"":seriesInfoMode.designerBrandLogo;
        [appdelegate showBrandInfoViewController:seriesInfoMode.designerId WithBrandName:brandName WithLogoPath:logoPath parentViewController:self WithHomePageBlock:nil WithSelectedValue:nil];
    }
}
-(void)collectionAction:(NSString *)type{
    BOOL iscollect = [type isEqualToString:@"go_collect"];
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [YYOpusApi updateSeriesCollectStateBySeriesId:_seriesId isCollect:iscollect andBlock:^(YYRspStatusAndMessage *rspStatusAndMessage, NSError *error) {
        if (rspStatusAndMessage.status == YYReqStatusCode100) {
            self.seriesInfoDetailModel.series.collect = @(iscollect);
            NSString *alertStr = @"";
            if([self.seriesInfoDetailModel.series.collect boolValue]){
                alertStr = NSLocalizedString(@"收藏成功，请到账户-我的收藏 中查看",nil);
            }else{
                alertStr = NSLocalizedString(@"取消收藏",nil);
            }
            [YYToast showToastWithView:self.view title:alertStr andDuration:kAlertToastDuration];
            [self reloadCollectionViewData];
        }else{
            [YYToast showToastWithView:self.view title:rspStatusAndMessage.message andDuration:kAlertToastDuration];
        }
        [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
    }];
}
-(void)updateDateRangeUI:(YYDateRangeModel *)dateRange{
    if(_seriesInfoDetailModel ){
        if(dateRange == nil || [dateRange.id unsignedIntegerValue] == 0){
            _dateRangeTitleLabel.text = [NSString stringWithFormat:NSLocalizedString(@"共分%lu个波段",nil),(unsigned long)[_seriesInfoDetailModel.dateRanges count]];
            _dateRangeValueLabel.text = [NSString stringWithFormat:@"%@-%@",getShowDateByFormatAndTimeInterval(@"yyyy/MM/dd",[_seriesInfoDetailModel.series.supplyStartTime stringValue]),getShowDateByFormatAndTimeInterval(@"yyyy/MM/dd",[_seriesInfoDetailModel.series.supplyEndTime stringValue])];
        }else{
            _dateRangeTitleLabel.text =  [NSString stringWithFormat:@"%@%@%@",NSLocalizedString(@"波段",nil),NSLocalizedString(@"：",nil),dateRange.name];
            _dateRangeValueLabel.text = [NSString stringWithFormat:@"%@-%@",getShowDateByFormatAndTimeInterval(@"yyyy/MM/dd",[dateRange.start stringValue]),getShowDateByFormatAndTimeInterval(@"yyyy/MM/dd",[dateRange.end stringValue])];
        }
    }
}
- (void)selectTaxTypeHandler:(id)sender {
    _selectListDataType = 1;
    _taxTypeData = getPayTaxData(YES);
    NSInteger listUIWidth = SCREEN_WIDTH - 36;
    NSInteger listUIHeight = 60*[_taxTypeData count];
    UITableView *view = [self listTableView];
    view.frame = CGRectMake(0, 0, listUIWidth, listUIHeight);
    view.layer.borderColor = [UIColor blackColor].CGColor;
    view.layer.borderWidth = 4;
    _selectListAlert = [[CMAlertView alloc] initWithViews:@[view] imageFrame:CGRectMake(0, 0, listUIWidth, listUIHeight) bgClose:NO];
    [_selectListAlert show];
}

-(UITableView *)listTableView{
    if(_selectListTableView == nil){
        _selectListTableView = [[UITableView alloc] init];
        _selectListTableView.delegate = self;
        _selectListTableView.dataSource = self;
        _selectListTableView.separatorColor = [UIColor colorWithHex:@"efefef"];
        _selectListTableView.separatorInset = UIEdgeInsetsMake(0, 0, 0, 0);
        _selectListTableView.backgroundColor = [UIColor whiteColor];
        [_selectListTableView registerNib:[UINib nibWithNibName:@"YYDateRangeItemCell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:@"YYDateRangeItemCell"];
        
    }
    [_selectListTableView reloadData];
    return _selectListTableView;
}

#pragma mark - --------------other----------------------
- (void)showShoppingView:(YYStyleInfoModel *)styleInfo {
    UIView *superView = self.view;
    YYOpusSeriesModel *opusSeriesModel = [_seriesInfoDetailModel toOpusSeriesModel];
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    [appDelegate showShoppingView:NO styleInfoModel:styleInfo seriesModel:opusSeriesModel opusStyleModel:nil currentYYOrderInfoModel:nil parentView:superView fromBrandSeriesView:YES WithBlock:^(YYBrandSeriesToCartTempModel *brandSeriesToCardTempModel) {
        if(brandSeriesToCardTempModel){
            
            BOOL isExit = NO;
            NSInteger index = 0;
            for (int i = 0; i < _intentionStyleArray.count; i++) {
                YYBrandSeriesToCartTempModel *tempBrandSeriesToCardTempModel = _intentionStyleArray[i];
                //遍历看看有没有
                if([tempBrandSeriesToCardTempModel.styleInfoModel.style.id integerValue] == [brandSeriesToCardTempModel.styleInfoModel.style.id integerValue]){
                    isExit = YES;
                    index = i;
                }
            }
            if(isExit){
                [_intentionStyleArray removeObjectAtIndex:index];
            }
            [_intentionStyleArray addObject:brandSeriesToCardTempModel];
            [self reloadCollectionViewData];
        }
    }];
}

@end
