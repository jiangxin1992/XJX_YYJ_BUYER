//
//  YYAccountDetailViewController.m
//  Yunejian
//
//  Created by yyj on 15/7/12.
//  Copyright (c) 2015年 yyj. All rights reserved.
//

#import "YYAccountDetailViewController.h"

#import "YYSettingViewController.h"
#import "YYModifyPasswordViewController.h"
#import "YYOrderingHistoryListViewController.h"
#import "YYVerifyBuyerViewController.h"
#import "YYBuyerHomePageViewController.h"
#import "YYUserCollectionViewController.h"
#import "YYBuyerAddressViewController.h"
#import "YYAccountUserInfoViewController.h"
#import "YYVisibleContactInfoViewController.h"
#import "YYBrandViewController.h"
#import "YYMainViewController.h"

#import "YYUserInfoCell.h"
#import "YYUserLogoInfoCell.h"
#import "YYUserVerifyCell.h"
#import "YYMessageButton.h"
#import "MBProgressHUD.h"
#import "YYTableView.h"
#import <MJRefresh.h>

#import "UIImage+YYImage.h"

#import "YYUserInfo.h"
#import "YYBuyerStoreModel.h"
#import "YYUntreatedMsgAmountModel.h"
#import "YYUser.h"
#import "YYUserApi.h"
#import "AppDelegate.h"
#import "YYGuideHandler.h"
#import "UserDefaultsMacro.h"

@interface YYAccountDetailViewController ()<UITableViewDataSource,UITableViewDelegate>

@property (weak, nonatomic) IBOutlet YYTableView *tableView;
@property (weak, nonatomic) IBOutlet YYMessageButton *messageButton;

@property (nonatomic, strong) YYAccountUserInfoViewController *accountUserInfoView;

@property (nonatomic, strong) YYUserInfo *userInfo;

@property (nonatomic, strong) YYBuyerStoreModel *currenBuyerStoreModel;

@end

@implementation YYAccountDetailViewController

#pragma mark - --------------生命周期--------------
- (void)viewDidLoad {
    [super viewDidLoad];
    [self addHeader];
    [self SomePrepare];
}
-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [_tableView reloadData];
    // 进入埋点
    [MobClick beginLogPageView:kYYPageAccountDetail];

    [self headerWithRefreshingAction];
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    // 退出埋点
    [MobClick endLogPageView:kYYPageAccountDetail];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}
- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - --------------SomePrepare--------------
- (void)SomePrepare
{
    [self PrepareData];
    [self PrepareUI];
}
- (void)PrepareData{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationDidBecomeActiveAction) name:kApplicationDidBecomeActive object:nil];
}
- (void)PrepareUI{
    _tableView.backgroundColor = [UIColor colorWithHex:@"f8f8f8"];

    YYUser *user = [YYUser currentUser];
    self.userInfo = [[YYUserInfo alloc] init];
    self.userInfo.userId = user.userId;

    [_messageButton initButton:@""];
    [self unreadMsgAmountChangeNotification:nil];
    [_messageButton addTarget:self action:@selector(messageButtonClicked) forControlEvents:UIControlEventTouchUpInside];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(unreadMsgAmountChangeNotification:) name:UnreadMsgAmountChangeNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(userCheckStatusChangeNotification:) name:UserCheckStatusChangeNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(unreadMsgAmountStatusChange:) name:UnreadMsgAmountStatusChangeNotification object:nil];


    if ([YYCurrentNetworkSpace isNetwork]) {
        AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
        UIView *superView = appDelegate.mainViewController.view;
        [MBProgressHUD showHUDAddedTo :superView animated:YES];
        [appDelegate checkNoticeCount];
        [[YYUser currentUser] updateUserCheckStatus];
        [appDelegate checkAppointmentNoticeCount];
        [self loadDataFromServer];
    }else{
        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
        NSData *data = [userDefaults objectForKey:kUserInfoKey];
        if (data) {
            self.userInfo = [NSKeyedUnarchiver unarchiveObjectWithData:data];
            [_tableView reloadData];
        }

    }
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(reachabilityChanged:)
                                                 name:kNetWorkSpaceChangedNotification
                                               object:nil];
}
- (void)addHeader{
    WeakSelf(ws);
    MJRefreshNormalHeader *header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        [ws headerWithRefreshingAction];
    }];
    self.tableView.mj_header = header;
    header.lastUpdatedTimeLabel.hidden = YES;
}
-(void)headerWithRefreshingAction{
    if ([YYCurrentNetworkSpace isNetwork]) {
        AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
        [appDelegate checkNoticeCount];
        [[YYUser currentUser] updateUserCheckStatus];
        [appDelegate checkAppointmentNoticeCount];
    }
    [self loadDataFromServer];
}

//#pragma mark - --------------UIConfig----------------------

#pragma mark - --------------请求数据----------------------
- (void)getBuyStoreUserInfo{
    WeakSelf(ws);
    [YYUserApi getBuyerStorBasicInfoWithBlock:^(YYRspStatusAndMessage *rspStatusAndMessage, YYBuyerStoreModel *BuyerStoreModel, NSError *error) {
        [ws.tableView.mj_header endRefreshingWithCompletionBlock:^{
            [ws.tableView setContentOffset:CGPointMake(0, 0) animated:YES];
        }];

        if (BuyerStoreModel) {
            ws.currenBuyerStoreModel = BuyerStoreModel;

            ws.userInfo.username = BuyerStoreModel.contactName;
            ws.userInfo.phone = BuyerStoreModel.contactPhone;
            ws.userInfo.email = BuyerStoreModel.contactEmail;
            ws.userInfo.userType = YYUserTypeRetailer;
            ws.userInfo.brandName = BuyerStoreModel.name;
            ws.userInfo.brandLogoName = BuyerStoreModel.logoPath;

            ws.userInfo.nation = BuyerStoreModel.nation;
            ws.userInfo.province = BuyerStoreModel.province;
            ws.userInfo.city = BuyerStoreModel.city;
            ws.userInfo.nationEn = BuyerStoreModel.nationEn;
            ws.userInfo.provinceEn = BuyerStoreModel.provinceEn;
            ws.userInfo.cityEn = BuyerStoreModel.cityEn;
            ws.userInfo.nationId = BuyerStoreModel.nationId;
            ws.userInfo.provinceId = BuyerStoreModel.provinceId;
            ws.userInfo.cityId = BuyerStoreModel.cityId;


            dispatch_async(dispatch_get_main_queue(), ^{
                [ws reloadTableView];
                if(ws.accountUserInfoView){
                    [ws.accountUserInfoView reloadTableView];
                }
            });
        }
    }];
}

#pragma mark - --------------系统代理----------------------
#pragma mark UITableViewDelegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    BOOL isShow = [self getCheckStatusIsShow];
    if(isShow){
        return 4;
    }else{
        return 3;
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    NSInteger rows = 0;
    BOOL isShow = [self getCheckStatusIsShow];
    if(isShow){
        if(section == 0){
            rows = 1;
        }else if (section == 1) {
            rows = 1;
        }else if(section == 2){
            rows = 1;
        }else if(section == 3){
            rows = 5;
        }
    }else{
        if(section == 0){
            rows = 1;
        }else if (section == 1) {
            rows = 1;
        }else if(section == 2){
            rows = 5;
        }
    }
    return rows;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{

    YYUser *user = [YYUser currentUser];
    BOOL isShow = [self getCheckStatusIsShow];
    NSInteger home_section = 0;
    NSInteger verity_section = 0;
    NSInteger other_section = 0;
    if(isShow){
        verity_section = 1;
        home_section = 2;
        other_section = 3;
    }else{
        verity_section = 3;
        home_section = 1;
        other_section = 2;
    }

    WeakSelf(ws);
    if(indexPath.section == 0){
        static NSString *CellIdentifier = @"LogoCell";
        YYUserLogoInfoCell *logoCell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        logoCell.usernameLabel.text = self.userInfo.brandName;
        [[logoCell.logoButton imageView] setContentMode:UIViewContentModeScaleAspectFit];
        if(self.userInfo != nil && self.userInfo.brandLogoName != nil){
            sd_downloadWebImageWithRelativePath(NO, self.userInfo.brandLogoName, logoCell.logoButton, kLogoCover, 0);
        }else{
            if(user.logo != nil){
                sd_downloadWebImageWithRelativePath(NO, user.logo, logoCell.logoButton, kLogoCover, 0);
            }else{
                [logoCell.logoButton setImage:[UIImage imageNamed:@"default_icon"] forState:UIControlStateNormal];
            }
        }
        logoCell.logoButton.imageView.contentMode = UIViewContentModeScaleAspectFit;
        logoCell.logoButton.backgroundColor = _define_white_color;
        logoCell.logoButton.layer.masksToBounds = YES;
        logoCell.logoButton.layer.cornerRadius = CGRectGetWidth(logoCell.logoButton.frame)/2;
        logoCell.logoButton.layer.borderWidth = 1;
        logoCell.logoButton.layer.borderColor = [UIColor colorWithHex:kDefaultImageColor].CGColor;

        logoCell.editButton.layer.masksToBounds = YES;
        logoCell.editButton.layer.borderColor = [[UIColor colorWithHex:@"d3d3d3"] CGColor];
        logoCell.editButton.layer.borderWidth = 1.0f;
        logoCell.editButton.layer.cornerRadius = 2.0f;

        if ([YYCurrentNetworkSpace isNetwork]) {
            logoCell.logoButton.enabled = YES;
        }else{
            logoCell.logoButton.enabled = NO;
        }
        [logoCell setUserLogoInfoCellBlock:^(NSString *type){
            if([type isEqualToString:@"edit_user_info"]){
                [self showUserInfoView];
            }
        }];
        return logoCell;
    }else if(indexPath.section == verity_section){
        //验证的窗口
        static NSString *cellid = @"YYUserVerifyCell";
        YYUserVerifyCell *cell = [_tableView dequeueReusableCellWithIdentifier:cellid];
        if(!cell)
        {
            cell = [[YYUserVerifyCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellid WithBlock:^(NSString *type) {
                if([type isEqualToString:@"fillInformation"]){
                    [ws fillInformation];
                }
            }];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
        }
        [cell updateUI];
        return cell;
    }else{

        static NSString *CellIdentifier = @"DetailCell";
        YYUserInfoCell *userInfoCell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];

        userInfoCell.userInfo = _userInfo;
        [userInfoCell hideBottomLine:NO];
        if (indexPath.section == home_section){
            if(indexPath.row == 0){
                //我的买手店主页
                [userInfoCell updateUIWithShowType:ShowTypeHome];
                [userInfoCell hideBottomLine:YES];
            }
        }else if (indexPath.section == other_section) {
            if (indexPath.row == 0) {
                //我的收藏
                [userInfoCell updateUIWithShowType:ShowTypeCollection];
            }else if (indexPath.row == 1){
                //我的合作品牌
                [userInfoCell updateUIWithShowType:ShowTypeCopBrands];
            }else if (indexPath.row == 2){
                //我的预约
                [userInfoCell updateUIWithShowType:ShowTypeOrdering];
            }else if (indexPath.row == 3){
                //收件地址
                [userInfoCell updateUIWithShowType:ShowTypeAddress];
            }else if (indexPath.row == 4){
                //设置
                [userInfoCell updateUIWithShowType:ShowTypeSetting];
                [userInfoCell hideBottomLine:YES];
            }
        }
        [userInfoCell setModifyButtonClicked:^(YYUserInfo *userInfo, ShowType currentShowType){

            switch (currentShowType) {
                case ShowTypePassword:{
                    [ws modifyPassword];
                }
                    break;
                case ShowTypeAddress:{
                    [ws showAddressView];
                }
                    break;
                case ShowTypeHome:{
                    [ws showBuyerHomePage];
                }
                    break;
                case ShowTypeOrdering:{
                    [ws showUserOrderingHistoryView];
                }
                    break;
                case ShowTypeCollection:{
                    [ws showUserCollectionView];
                }
                    break;
                case ShowTypeCopBrands:{
                    [ws showUserCopBrands];
                }
                    break;
                case ShowTypeSetting:{
                    [ws showTypeSetttingView];
                }
                    break;
                default:
                    break;
            }

            NSLog(@"userInfo.email: %@  userInfo.username: %@,currentShowType: %ld",userInfo.email,userInfo.username,(long)currentShowType);
        }];
        return userInfoCell;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    BOOL isShow = [self getCheckStatusIsShow];
    if(indexPath.section == 0){
        return 110;
    }else{
        if(isShow){
            if(indexPath.section == 1){
                return 89;
            }
        }
    }
    return 54;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    
    static NSString *CellIdentifier = @"SectionHeader";
    UITableViewCell *headerView = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (headerView == nil){
        [NSException raise:@"SectionHeader == nil.." format:@"No cells with matching CellIdentifier loaded from your storyboard"];
    }else{
        
    }
    
    return headerView;
}
- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section{
    BOOL isShow = [self getCheckStatusIsShow];
    NSInteger section_num = 0;
    if(isShow){
        section_num = 3;
    }else{
        section_num = 2;
    }
    if(section == section_num){
        static NSString *CellIdentifier = @"SectionHeader";
        UITableViewCell *headerView = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        return headerView;
    }

    static NSString *CellIdentifier = @"";
    UITableViewCell *headerView = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    return headerView;
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    if(section == 0){
        return 0.1;
    }
    BOOL isShow = [self getCheckStatusIsShow];
    if(isShow){
        if(section == 1 || section == 2){
            return 0.1;
        }
    }
    return 11;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    BOOL isShow = [self getCheckStatusIsShow];
    NSInteger section_num = 0;
    if(isShow){
        section_num = 3;
    }else{
        section_num = 2;
    }
    if(section == section_num){
        return 11;
    }
    return 0.1;
}

//#pragma mark - --------------自定义代理/block----------------------
#pragma mark - --------------自定义响应----------------------
#pragma mark 跳转消息界面
- (void)messageButtonClicked {
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    [appDelegate showMessageView:nil parentViewController:self];
}

#pragma mark - --------------自定义方法----------------------
-(void)applicationDidBecomeActiveAction{
    [self headerWithRefreshingAction];
}

#pragma mark 完善资料cell是否显示
//1:待提交文件 2:待审核 4:审核拒绝 就这三种符合
-(BOOL )getCheckStatusIsShow{
    BOOL isShow = NO;
    if(![[YYUser currentUser] hasPermissionsToVisit]){
        YYUser *user = [YYUser currentUser];
        //1:待提交文件 2:待审核 3:审核通过 4:审核拒绝 5:停止
        NSInteger checkStatus = [user.checkStatus integerValue];
        if(checkStatus == 1 || checkStatus == 2 || checkStatus == 4){
            isShow = YES;
        }
    }
    return isShow;
}
#pragma mark 跳转完善资料界面
//完善资料
-(void)fillInformation{

    YYVisibleContactInfoViewController *visibleContactInfoViewController = [[YYVisibleContactInfoViewController alloc] init];

    [visibleContactInfoViewController setGoBack:^{
        //返回
        for (UIViewController *temp in self.navigationController.viewControllers) {
            if ([temp isKindOfClass:[YYMainViewController class]]) {
                [self.navigationController popToViewController:temp animated:YES];
            }
        }
        //刷新该界面审核状态
        [_tableView reloadData];
        //更新用户审核状态
        [[YYUser currentUser] updateUserCheckStatus];
    }];

    [self.navigationController pushViewController:visibleContactInfoViewController animated:YES];
}
#pragma mark 跳转编辑资料界面
-(void)showUserInfoView{
    if(_userInfo){

        WeakSelf(ws);

        _accountUserInfoView = [[YYAccountUserInfoViewController alloc] init];
        _accountUserInfoView.userInfo = _userInfo;

        [_accountUserInfoView setCancelButtonClicked:^(){
            [ws.navigationController popViewControllerAnimated:YES];
            ws.accountUserInfoView = nil;
        }];

        [_accountUserInfoView setAccountUserInfoCellBlock:^(NSString *type){
            if([type isEqualToString:@"reload_data"]){
                [ws loadDataFromServer];
            }
        }];

        [self.navigationController pushViewController:_accountUserInfoView animated:YES];
    }
}
#pragma mark 跳转设置页面
-(void)showTypeSetttingView{

    WeakSelf(ws);

    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Account" bundle:[NSBundle mainBundle]];
    YYSettingViewController *settingViewController = [storyboard instantiateViewControllerWithIdentifier:@"YYSettingViewController"];

    [settingViewController setCancelButtonClicked:^(){
        [ws.navigationController popViewControllerAnimated:YES];
    }];

    [self.navigationController pushViewController:settingViewController animated:YES];

    [YYGuideHandler markGuide:GuideTypeSettingDot];
}
#pragma mark 跳转我的合作品牌
-(void)showUserCopBrands{

    WeakSelf(ws);

    UIStoryboard *brandStoryboard = [UIStoryboard storyboardWithName:@"Brand" bundle:[NSBundle mainBundle]];
    YYBrandViewController *brandViewController = [brandStoryboard instantiateViewControllerWithIdentifier:@"YYBrandViewController"];

    [brandViewController setCancelButtonClicked:^(){
        [ws.navigationController popViewControllerAnimated:YES];
    }];

    [self.navigationController pushViewController:brandViewController animated:YES];
}
#pragma mark 跳转我的收件地址界面
-(void)showAddressView{

    WeakSelf(ws);

    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Account" bundle:[NSBundle mainBundle]];
    YYBuyerAddressViewController *buyerAddressViewController = [storyboard instantiateViewControllerWithIdentifier:@"YYBuyerAddressViewController"];

    [buyerAddressViewController setCancelButtonClicked:
     ^(){
         [ws.navigationController popViewControllerAnimated:YES];
     }];

    [self.navigationController pushViewController:buyerAddressViewController animated:YES];
}
#pragma mark 跳转我的收藏界面
-(void)showUserCollectionView{

    WeakSelf(ws);

    YYUserCollectionViewController *userCollectionView = [[YYUserCollectionViewController alloc] init];

    [userCollectionView setCancelButtonClicked:^(){
        [ws.navigationController popViewControllerAnimated:YES];
    }];

    [self.navigationController pushViewController:userCollectionView animated:YES];
}

#pragma mark 跳转修改密码界面
-(void)modifyPassword{

    WeakSelf(ws);

    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Account" bundle:[NSBundle mainBundle]];
    YYModifyPasswordViewController *modifyPasswordViewController = [storyboard instantiateViewControllerWithIdentifier:@"YYModifyPasswordViewController"];

    [modifyPasswordViewController setCancelButtonClicked:^(){
        [ws.navigationController popViewControllerAnimated:YES];
    }];

    [modifyPasswordViewController setModifySuccess:^(){
        [ws.navigationController popViewControllerAnimated:YES];
        [[NSNotificationCenter defaultCenter] postNotificationName:kNeedLoginNotification object:nil];
    }];

    [self.navigationController pushViewController:modifyPasswordViewController animated:YES];
}
#pragma mark 跳转我的主页界面
-(void)showBuyerHomePage{

    WeakSelf(ws);

    YYBuyerHomePageViewController *connInfoController = [[YYBuyerHomePageViewController alloc] init];
    connInfoController.previousTitle = NSLocalizedString(@"我的买手店主页",nil);
    connInfoController.isHomePage = YES;

    [connInfoController setReadblock:^(NSString * type) {
        if([type isEqualToString:@"reload"])
        {
            [ws.tableView reloadData];
        }
    }];

    [connInfoController setCancelButtonClicked:^(){
        [ws.navigationController popViewControllerAnimated:YES];
    }];

    [self.navigationController pushViewController:connInfoController animated:YES];
}
#pragma mark 跳转我的预约界面
-(void)showUserOrderingHistoryView{

    WeakSelf(ws);

    YYOrderingHistoryListViewController *orderHistoryView = [[YYOrderingHistoryListViewController alloc] init];

    [orderHistoryView setCancelButtonClicked:^(){
        [ws.navigationController popViewControllerAnimated:YES];
    }];
    
    [self.navigationController pushViewController:orderHistoryView animated:YES];
}
#pragma mark 更新用户信息
- (void)loadDataFromServer{
    YYUser *user = [YYUser currentUser];
    self.userInfo.status = user.status;
    [self getBuyStoreUserInfo];
}
#pragma mark reload TableView
- (void)reloadTableView{
    [_tableView reloadData];
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    UIView *superView = appDelegate.mainViewController.view;
    [MBProgressHUD hideAllHUDsForView:superView animated:YES];

    //以下代码，目前只考虑设计师登录的情况，保存信息至本地
    if (_userInfo
        && _userInfo.username
        && _userInfo.brandName) {
        [self saveCurrentUserInfoToDisk];
    }
}
- (void)userCheckStatusChangeNotification:(NSNotification *)notification{
    [_tableView reloadData];
}
#pragma mark 消息数量变化监听 回调
- (void)unreadMsgAmountChangeNotification:(NSNotification *)notification{
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    [appDelegate.untreatedMsgAmountModel setUnreadMessageAmount:_messageButton];
}
#pragma mark 未读消息变化监听 回调
- (void)unreadMsgAmountStatusChange:(NSNotification *)notification{
    [_tableView reloadData];
}
#pragma mark 网络状态监测
- (void)reachabilityChanged:(NSNotification *)notification{
    if (![YYCurrentNetworkSpace isNetwork]) {
        AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
        UIView *superView = appDelegate.mainViewController.view;
        [MBProgressHUD hideAllHUDsForView:superView animated:YES];
        [self.tableView reloadData];
    }
}
#pragma mark check 当前用户状态
-(void)checkUserIdentity{
    WeakSelf(ws);
    if([_userInfo.status integerValue] == YYReqStatusCode300){
        [YYToast showToastWithTitle:NSLocalizedString(@"审核中!",nil) andDuration:kAlertToastDuration];
        return ;
    }
    YYVerifyBuyerViewController *viewController = [[YYVerifyBuyerViewController alloc] init];
    [viewController setCancelButtonClicked:^(){
        YYUser *user = [YYUser currentUser];
        ws.userInfo.status = user.status;
        dispatch_async(dispatch_get_main_queue(), ^{
            [ws.tableView reloadData];
        });
    }];
    [self.navigationController pushViewController:viewController animated:YES];
}
#pragma mark 缓存当前用户信息
- (void)saveCurrentUserInfoToDisk{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setObject:[NSKeyedArchiver archivedDataWithRootObject:self.userInfo] forKey:kUserInfoKey];
    [userDefaults synchronize];
}
#pragma mark - --------------other----------------------

@end
