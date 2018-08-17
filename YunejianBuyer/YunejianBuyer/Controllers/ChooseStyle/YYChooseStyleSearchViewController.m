//
//  YYChooseStyleSearchViewController.m
//  YunejianBuyer
//
//  Created by yyj on 2017/7/11.
//  Copyright © 2017年 Apple. All rights reserved.
//

#import "YYChooseStyleSearchViewController.h"

#import "UIImage+YYImage.h"
#import <AFNetworking/AFNetworkReachabilityManager.h>
#import "AppDelegate.h"
#import "YYUser.h"
#import "MBProgressHUD.h"
#import "UserDefaultsMacro.h"
#import <MJRefresh.h>
#import "MLInputDodger.h"

#import "YYChooseStyleCell.h"
#import "YYChooseStyleApi.h"
#import "YYInventoryBoardModel.h"

#define YY_COLLECTION_PAGESZIE 20

@interface YYChooseStyleSearchViewController ()<UICollectionViewDelegate, UICollectionViewDataSource,UITextFieldDelegate>

@property (nonatomic,strong) UIView *navView;

@property (nonatomic,strong) UITextField *searchField;

@property (strong, nonatomic) UICollectionView *collectionView;

@property (strong, nonatomic) YYPageInfoModel *currentPageInfo;
@property (nonatomic,strong) UIView *noDataView;
@property (nonatomic,strong) NSMutableArray *styleListArray;

@property (nonatomic,copy) NSString *searchFieldStr;//临时编辑变量

@end

@implementation YYChooseStyleSearchViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self SomePrepare];
    [self UIConfig];
    [_searchField becomeFirstResponder];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    // 进入埋点
    [MobClick beginLogPageView:kYYPageChooseStyleSearch];
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    // 退出埋点
    [MobClick endLogPageView:kYYPageChooseStyleSearch];
}

#pragma mark - SomePrepare
-(void)SomePrepare
{
    [self PrepareData];
    [self PrepareUI];
}
-(void)PrepareData{
    _styleListArray = [[NSMutableArray alloc] init];
    _searchFieldStr = @"";
}
-(void)PrepareUI{
    self.view.backgroundColor = _define_white_color;
}
#pragma mark - UIConfig
-(void)UIConfig{
    [self CreateNavView];
    [self CreateCollectionView];
    [self CreateNoDataView];
}
-(void)CreateNoDataView{
    self.noDataView = addNoDataView_phone(self.view,[[NSString alloc] initWithFormat:@"%@|icon:noSearchResultData_icon",NSLocalizedString(@"未搜索到相关款式",nil)],@"919191",@"noSearchResultData_icon");
    self.noDataView.hidden = YES;
}

-(void)CreateNavView{
    _navView = [UIView getCustomViewWithColor:_define_white_color];
    [self.view addSubview:_navView];
    [_navView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.mas_equalTo(0);
        make.top.mas_equalTo(20);
        make.height.mas_equalTo(45);
    }];
    
    UIView *lineView = [UIView getCustomViewWithColor:[UIColor colorWithHex:@"D3D3D3"]];
    [_navView addSubview:lineView];
    [lineView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.bottom.mas_equalTo(0);
        make.height.mas_equalTo(1);
    }];
    
    UIButton *cancelButton = [UIButton getCustomTitleBtnWithAlignment:2 WithFont:15.0f WithSpacing:0 WithNormalTitle:NSLocalizedString(@"取消",nil) WithNormalColor:[UIColor colorWithHex:@"919191"] WithSelectedTitle:nil WithSelectedColor:nil];
    [_navView addSubview:cancelButton];
    [cancelButton addTarget:self action:@selector(CancelAction) forControlEvents:UIControlEventTouchUpInside];
    [cancelButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(-13);
        make.width.mas_equalTo(60);
        make.bottom.mas_equalTo(0);
        make.height.mas_equalTo(44);
    }];
    
    UIView *searchView = [UIView getCustomViewWithColor:[UIColor colorWithHex:@"EFEFEF"]];
    [_navView addSubview:searchView];
    [searchView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(13);
        make.top.mas_equalTo(7);
        make.bottom.mas_equalTo(-7);
        make.right.mas_equalTo(cancelButton.mas_left).with.offset(0);
    }];
    
    UIButton *searchIcon = [UIButton getCustomImgBtnWithImageStr:@"search_Img" WithSelectedImageStr:nil];
    [searchView addSubview:searchIcon];
    [searchIcon mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(_navView);
        make.left.mas_equalTo(10);
        make.width.mas_equalTo(18);
        make.height.mas_equalTo(22);
    }];
    
    _searchField = [[UITextField alloc] init];
    [searchView addSubview:_searchField];
    [_searchField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(searchIcon.mas_right).with.offset(0);
        make.right.top.bottom.mas_equalTo(0);
    }];
    _searchField.textColor = _define_black_color;
    _searchField.placeholder = NSLocalizedString(@"搜索款式相关关键字",nil);
    _searchField.font = [UIFont systemFontOfSize:14.0f];
    _searchField.textAlignment = 0;
    _searchField.layer.masksToBounds = YES;
    _searchField.layer.cornerRadius = 3.0f;
    _searchField.returnKeyType = UIReturnKeySearch;
    _searchField.delegate = self;
    
}
- (void )CreateCollectionView{
    if (!_collectionView) {
        //        6
        _collectionView = [[UICollectionView alloc]initWithFrame:CGRectZero collectionViewLayout:[self getCollectionViewLayout]];
        [self.view addSubview:_collectionView];
        [_collectionView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.right.bottom.mas_equalTo(0);
            make.top.mas_equalTo(_navView.mas_bottom).with.offset(0);
        }];
        _collectionView.delegate = self;
        _collectionView.dataSource = self;
        _collectionView.backgroundColor =  [UIColor colorWithHex:@"F8F8F8"];
        _collectionView.showsVerticalScrollIndicator = NO;
        [_collectionView registerClass:[YYChooseStyleCell class] forCellWithReuseIdentifier:@"YYChooseStyleCell"];
        
        [self addFooter];
    }
}
-(UICollectionViewFlowLayout *)getCollectionViewLayout{
    UICollectionViewFlowLayout *templayout = [[UICollectionViewFlowLayout alloc] init];
    CGFloat cellW = (SCREEN_WIDTH - 12*2 - 10)/2.0f;
    //    CGFloat cellH = 266;
    CGFloat cellH = (cellW - 10) + 106;
    templayout.itemSize = CGSizeMake(cellW, cellH);
    templayout.footerReferenceSize = CGSizeZero;
    templayout.headerReferenceSize = CGSizeZero;
    
    templayout.sectionInset = UIEdgeInsetsMake(12, 12, 12, 12);
    templayout.minimumInteritemSpacing = 10.0f;
    templayout.minimumLineSpacing = 15.0f;
    return templayout;
}
#pragma mark - MJRefresh
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

        if( [ws.styleListArray count] > 0 && ws.currentPageInfo
           && !ws.currentPageInfo.isLastPage){
            [ws loadDataByPageIndex:[ws.currentPageInfo.pageIndex intValue]+1];
            return;
        }

        [ws.collectionView.mj_footer endRefreshing];
    }];
}
//刷新界面
- (void)reloadCollectionViewData{
    [self.collectionView.mj_header endRefreshing];
    [self.collectionView.mj_footer endRefreshing];
    [self.collectionView reloadData];
    if (!self.styleListArray || [self.styleListArray count ]==0) {
        if([NSString isNilOrEmpty:_searchFieldStr]){
            self.noDataView.hidden = YES;
        }else{
            self.noDataView.hidden = NO;
        }
    }else{
        self.noDataView.hidden = YES;
    }
}
#pragma mark - RequestData
- (void)loadDataByPageIndex:(int)pageIndex{
    WeakSelf(ws);
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [YYChooseStyleApi getOrderingListWithReqModel:_reqModel pageIndex:pageIndex pageSize:YY_COLLECTION_PAGESZIE andBlock:^(YYRspStatusAndMessage *rspStatusAndMessage, YYChooseStyleListModel *chooseStyleListModel, NSError *error) {
        if (rspStatusAndMessage.status == kCode100 && chooseStyleListModel.result
            && [chooseStyleListModel.result count] > 0) {
            ws.currentPageInfo = chooseStyleListModel.pageInfo;
            if (ws.currentPageInfo== nil || ws.currentPageInfo.isFirstPage) {
                [ws.styleListArray removeAllObjects];
            }
            [ws.styleListArray addObjectsFromArray:chooseStyleListModel.result];
        }else{
            if(chooseStyleListModel.result){
                if(!chooseStyleListModel.result.count){
                    ws.currentPageInfo = chooseStyleListModel.pageInfo;
                    if (ws.currentPageInfo== nil || ws.currentPageInfo.isFirstPage) {
                        [ws.styleListArray removeAllObjects];
                    }
                }
            }
        }
        
        [MBProgressHUD hideAllHUDsForView:ws.view animated:YES];
        if (rspStatusAndMessage.status != kCode100) {
            [YYToast showToastWithTitle:rspStatusAndMessage.message  andDuration:kAlertToastDuration];
        }
        [ws reloadCollectionViewData];
    }];
}
#pragma mark - CancelAction
-(void)CancelAction{
    //清空搜索数据
    _reqModel.query = @"";
    [self.navigationController popViewControllerAnimated:NO];
}
- (void)textFieldDidEndEditing:(UITextField *)textField{
    [[NSNotificationCenter defaultCenter]removeObserver:self name:UITextFieldTextDidChangeNotification object:_searchField];
}

-(void) textFieldDidBeginEditing:(UITextField *)textField{
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

    if(![NSString isNilOrEmpty:str]){
        _searchFieldStr = str;
    }else{
        _searchFieldStr = @"";
    }
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    if(![NSString isNilOrEmpty:_searchFieldStr]){
        _reqModel.query = _searchFieldStr;
        [_searchField resignFirstResponder];
        [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        [self loadDataByPageIndex:1];
        return YES;
    }
    return NO;
}
#pragma mark - UICollectionViewDataSource
//返回section个数
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    if(_styleListArray){
        if(_styleListArray.count){
            return [_styleListArray count];
        }
    }
    return 0;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    YYChooseStyleModel *styleModel = nil;
    if ([_styleListArray count] > indexPath.row) {
        styleModel = [_styleListArray objectAtIndex:indexPath.row];
    }
    YYChooseStyleCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"YYChooseStyleCell" forIndexPath:indexPath];
    cell.styleModel = styleModel;
    [cell updateUI];
    return cell;
}
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    YYChooseStyleModel *chooseStyleModel = self.styleListArray[indexPath.row];
    //跳转对应页面
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    YYInventoryBoardModel *infoModel = [self modelTransformByChooseStyleModel:chooseStyleModel];
    [appDelegate showStyleInfoViewController:infoModel parentViewController:self];
}
-(YYInventoryBoardModel *)modelTransformByChooseStyleModel:(YYChooseStyleModel *)chooseStyleModel{
    YYInventoryBoardModel *infoModel = [[YYInventoryBoardModel alloc] init];
    infoModel.designerId = chooseStyleModel.designerId;
    infoModel.brandName = chooseStyleModel.brandName;
    infoModel.brandLogo = chooseStyleModel.brandLogo;
    infoModel.seriesName = chooseStyleModel.seriesName;
    infoModel.albumImg = chooseStyleModel.albumImg;
    infoModel.styleName = chooseStyleModel.styleName;
    infoModel.styleId = chooseStyleModel.styleId;
    return infoModel;
}

#pragma mark - Other
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
