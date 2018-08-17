//
//  YYOrderModifyViewController.m
//  Yunejian
//
//  Created by yyj on 15/8/18.
//  Copyright (c) 2015年 yyj. All rights reserved.
//

#import "YYOrderModifyViewController.h"

// c文件 —> 系统文件（c文件在前）

// 控制器
#import "YYTaxChooseViewController.h"
#import "YYCustomCell02ViewController.h"
#import "YYBuyerAddressViewController.h"
#import "YYCustomCellTableViewController.h"
#import "YYStyleDetailListViewController.h"
#import "YYOrderStylesRemarkViewController.h"

// 自定义视图
#import "YYNavView.h"
#import "YYPickView.h"
#import "YYDiscountView.h"
#import "YYOrderRemarkCell.h"
#import "YYOrderTaxInfoCell.h"
#import "YYBuyerMessageCell.h"
#import "YYNewStyleDetailCell.h"
#import "YYOrderUseAddressCell.h"
#import "YYOrderDetailSectionHead.h"

// 接口
#import "YYUserApi.h"
#import "YYOrderApi.h"

// 分类
#import "UIImage+Tint.h"
#import "UIView+UpdateAutoLayoutConstraints.h"

// 自定义类和三方类（ cocoapods类 > model > 工具类 > 其他）
#import "YYUser.h"
#import "YYBuyerModel.h"
#import "YYOrderInfoModel.h"
#import "YYBuyerAddressModel.h"
#import "YYOrderSettingInfoModel.h"
#import "YYBuyerAddressListModel.h"
#import "YYStylesAndTotalPriceModel.h"

#import "AppDelegate.h"
#import "UserDefaultsMacro.h"

#import "MBProgressHUD.h"
#import "MLInputDodger.h"

#define kDelaySeconds 2
#define kOrderModifyPageSize 8

@interface YYOrderModifyViewController ()<UITableViewDataSource,UITableViewDelegate,UIPopoverControllerDelegate,UINavigationControllerDelegate,UIImagePickerControllerDelegate,YYTableCellDelegate,YYPickViewDelegate>

@property (weak, nonatomic) IBOutlet UIView *containerView;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UILabel *countLabel;
@property (weak, nonatomic) IBOutlet YYDiscountView *priceTotalDiscountView;
@property (weak, nonatomic) IBOutlet UIButton *saveButton;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *tableViewBottomLayoutConstraint;
@property (weak, nonatomic) IBOutlet UIButton *minOrderMoneyBtn1;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *countLabelLayoutBottomConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *minOrderRithtWidth;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *priceTotalRightWidth;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *orderBtnWidthLayout;

@property (nonatomic, strong) YYNavView *navView;

@property (nonatomic, assign) NSInteger totalSections;

@property (nonatomic, strong) YYStylesAndTotalPriceModel *stylesAndTotalPriceModel;//总数

@property (nonatomic, strong) YYOrderSettingInfoModel *orderSettingInfoModel;

@property (nonatomic, assign) NSInteger selectTaxType;//税制

@property (nonatomic, strong) NSMutableArray *menuData;

@property (nonatomic, strong) YYPickView *pickerView;
@property (nonatomic, strong) YYBuyerModel *buyerModel;//买手店地址
@property (nonatomic, strong) YYOrderBuyerAddress *nowBuyerAddress;//新增地址

@end

@implementation YYOrderModifyViewController
#pragma mark - --------------生命周期--------------
- (void)viewDidLoad {
    [super viewDidLoad];
    [self SomePrepare];
    [self RequestData];
}
- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    if (appDelegate.orderModel) {
        appDelegate.orderSeriesArray = nil;
        appDelegate.orderModel = nil;
    }
    [self updateUI];
    // 进入埋点
    if (_isCreatOrder) {
        // 确认订单
        [MobClick beginLogPageView:kYYPageOrderModifyConfirm];

    }else{
        if(!_isAppendOrder){
            //修改订单
            [MobClick beginLogPageView:kYYPageOrderModifyUpdate];

        }else{
            // 补货追单
            [MobClick beginLogPageView:kYYPageOrderModifyReplenishment];
        }
    }
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    // 退出埋点
    if (_isCreatOrder) {
        // 确认订单
        [MobClick endLogPageView:kYYPageOrderModifyConfirm];

    }else{
        if(!_isAppendOrder){
            //修改订单
            [MobClick endLogPageView:kYYPageOrderModifyUpdate];

        }else{
            // 补货追单
            [MobClick endLogPageView:kYYPageOrderModifyReplenishment];
        }
    }
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}
-(void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kUpdateShoppingCarNotification object:nil];
}
#pragma mark - --------------SomePrepare--------------
- (void)SomePrepare {
    [self PrepareData];
    [self PrepareUI];
}
- (void)PrepareData {

    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    if (appDelegate.orderModel) {
        appDelegate.orderSeriesArray = nil;
        appDelegate.orderModel = nil;
    }

    _buyerModel = [[YYBuyerModel alloc] init];
    YYUser *user = [YYUser currentUser];
    //买手店数据（可修改地址）
    if (_isCreatOrder && !_isReBuildOrder) {

        _buyerModel.buyerId = [[NSNumber alloc] initWithInteger:[user.userId integerValue]];
        _buyerModel.name = user.name;
        _buyerModel.contactEmail = user.email;

        _nowBuyerAddress = nil;
        [self loadBuyerAddressListWidthPageIndex:0 pageSize:1];
    }else{

        if(_isReBuildOrder){

            _buyerModel.buyerId = [[NSNumber alloc] initWithInteger:[user.userId integerValue]];
            _buyerModel.name = user.name;
            _buyerModel.contactEmail = user.email;

            if(_currentYYOrderInfoModel.buyerAddress.addressId){
                _buyerModel.nation = (_currentYYOrderInfoModel.buyerAddressId?_currentYYOrderInfoModel.buyerAddress.nation:@"");
                _buyerModel.province = (_currentYYOrderInfoModel.buyerAddressId?_currentYYOrderInfoModel.buyerAddress.province:@"");
                _buyerModel.city = (_currentYYOrderInfoModel.buyerAddressId?_currentYYOrderInfoModel.buyerAddress.city:@"");

                _buyerModel.nationEn = (_currentYYOrderInfoModel.buyerAddressId?_currentYYOrderInfoModel.buyerAddress.nationEn:@"");
                _buyerModel.provinceEn = (_currentYYOrderInfoModel.buyerAddressId?_currentYYOrderInfoModel.buyerAddress.provinceEn:@"");
                _buyerModel.cityEn = (_currentYYOrderInfoModel.buyerAddressId?_currentYYOrderInfoModel.buyerAddress.cityEn:@"");

                _buyerModel.nationId = (_currentYYOrderInfoModel.buyerAddressId?_currentYYOrderInfoModel.buyerAddress.nationId:@(0));
                _buyerModel.provinceId = (_currentYYOrderInfoModel.buyerAddressId?_currentYYOrderInfoModel.buyerAddress.provinceId:@(0));
                _buyerModel.cityId = (_currentYYOrderInfoModel.buyerAddressId?_currentYYOrderInfoModel.buyerAddress.cityId:@(0));

                _nowBuyerAddress = _currentYYOrderInfoModel.buyerAddress;

                _currentYYOrderInfoModel.buyerAddressId = nil;
                _currentYYOrderInfoModel.buyerAddress.addressId = nil;

            }else{
                _nowBuyerAddress = nil;

                _currentYYOrderInfoModel.buyerAddressId = nil;
                _currentYYOrderInfoModel.buyerAddress.addressId = nil;

                [self loadBuyerAddressListWidthPageIndex:0 pageSize:1];
            }
        }else{

            _buyerModel.buyerId = _currentYYOrderInfoModel.realBuyerId;
            _buyerModel.name = _currentYYOrderInfoModel.buyerName;
            _buyerModel.contactEmail = (_currentYYOrderInfoModel.buyerEmail?_currentYYOrderInfoModel.buyerEmail:@"");

            _buyerModel.nation = (_currentYYOrderInfoModel.buyerAddressId?_currentYYOrderInfoModel.buyerAddress.nation:@"");
            _buyerModel.province = (_currentYYOrderInfoModel.buyerAddressId?_currentYYOrderInfoModel.buyerAddress.province:@"");
            _buyerModel.city = (_currentYYOrderInfoModel.buyerAddressId?_currentYYOrderInfoModel.buyerAddress.city:@"");

            _buyerModel.nationEn = (_currentYYOrderInfoModel.buyerAddressId?_currentYYOrderInfoModel.buyerAddress.nationEn:@"");
            _buyerModel.provinceEn = (_currentYYOrderInfoModel.buyerAddressId?_currentYYOrderInfoModel.buyerAddress.provinceEn:@"");
            _buyerModel.cityEn = (_currentYYOrderInfoModel.buyerAddressId?_currentYYOrderInfoModel.buyerAddress.cityEn:@"");

            _buyerModel.nationId = (_currentYYOrderInfoModel.buyerAddressId?_currentYYOrderInfoModel.buyerAddress.nationId:@(0));
            _buyerModel.provinceId = (_currentYYOrderInfoModel.buyerAddressId?_currentYYOrderInfoModel.buyerAddress.provinceId:@(0));
            _buyerModel.cityId = (_currentYYOrderInfoModel.buyerAddressId?_currentYYOrderInfoModel.buyerAddress.cityId:@(0));

            _nowBuyerAddress = _currentYYOrderInfoModel.buyerAddress;
        }
    }

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(updateShoppingCarNotification:)
                                                 name:kUpdateShoppingCarNotification
                                               object:nil];
}
- (void)PrepareUI {

    _priceTotalRightWidth.constant = IsPhone6_gt?15.0f:5.0f;
    _minOrderRithtWidth.constant = IsPhone6_gt?15.0f:5.0f;
    _countLabel.font = [UIFont systemFontOfSize:IsPhone6_gt?15.0f:12.0f];
    _countLabel.adjustsFontSizeToFitWidth = YES;
    _orderBtnWidthLayout.constant = IsPhone6_gt?120.0f:100.0f;
    [_saveButton.titleLabel setFont:[UIFont systemFontOfSize:IsPhone6_gt?18.0f:15.0f]];
    _saveButton.backgroundColor = [UIColor colorWithHex:@"d3d3d3"];

    //初始化_menuData
    _menuData = getPayTaxInitData();
    NSNumber *changeNum = [NSNumber numberWithFloat:[_currentYYOrderInfoModel.taxRate floatValue]/100.0f];
    updateCustomTaxValue(_menuData, changeNum,YES);
    _selectTaxType = getPayTaxTypeFormServiceNew(_menuData, [_currentYYOrderInfoModel.taxRate integerValue]);

    self.navView = [[YYNavView alloc] initWithTitle:NSLocalizedString(@"确认订单", nil) WithSuperView:self.view haveStatusView:YES];
    WeakSelf(ws);
    self.navView.goBackBlock = ^{
        [ws goBack];
    };

    self.tableView.shiftHeightAsDodgeViewForMLInputDodger = 44.0f+5.0f;
    [self.tableView registerAsDodgeViewForMLInputDodger];

    [self updateUI];
}

//#pragma mark - --------------UIConfig----------------------
//- (void)UIConfig {
//
//}

#pragma mark - --------------请求数据----------------------
- (void)RequestData {

}
-(void)loadBuyerAddressListWidthPageIndex:(int)pageIndex pageSize:(int)pageSize{
    WeakSelf(ws);
    [YYUserApi getAddressListWithPageIndex:(int)pageIndex pageSize:(int)pageSize andBlock:^(YYRspStatusAndMessage *rspStatusAndMessage, YYBuyerAddressListModel *addressListModel, NSError *error) {
        if (addressListModel) {
            if( ws.nowBuyerAddress == nil){
                for (YYOrderBuyerAddress *buyerAddress in addressListModel.result) {
                    if([buyerAddress.defaultShipping integerValue] > 0){
                        buyerAddress.addressId = [[NSNumber alloc] initWithInt:0];
                        ws.nowBuyerAddress = buyerAddress;
                        ws.currentYYOrderInfoModel.buyerAddress = buyerAddress;
                        ws.currentYYOrderInfoModel.buyerAddressId = buyerAddress.addressId;
                        break;
                    }
                }
            }

            dispatch_async(dispatch_get_main_queue(), ^{
                [ws.tableView reloadData];
            });
        }
    }];
}
#pragma mark - --------------系统代理----------------------
#pragma mark - UIImagePickerControllerDelegate
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    //    获取选择图片
    UIImage *image = [UIImage fixOrientation:info[UIImagePickerControllerOriginalImage]];
    WeakSelf(ws);

    if (image) {

        if (![YYCurrentNetworkSpace isNetwork]) {
            if (self.currentYYOrderInfoModel.shareCode
                && !self.currentYYOrderInfoModel.orderCode) {
                [ws updateUI];
            }
        }else{

            [MBProgressHUD showHUDAddedTo:self.view animated:YES];
            [YYOrderApi uploadImage:image size:2.0f andBlock:^(YYRspStatusAndMessage *rspStatusAndMessage, NSString *imageUrl, NSError *error) {
                [MBProgressHUD hideAllHUDsForView:ws.view animated:YES];
                if (imageUrl
                    && [imageUrl length] > 0) {
                    NSLog(@"imageUrl: %@",imageUrl);

                    ws.currentYYOrderInfoModel.businessCard = imageUrl;
                    [ws updateUI];
                }

            }];

        }
    }
    [picker dismissViewControllerAnimated:YES completion:nil];
}
#pragma mark UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return self.totalSections;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    NSInteger rows = 0;
    if (section == 0) {
        return 3;
    }else if (section == self.totalSections-1) {
        return 1;
    }else{
        if (_currentYYOrderInfoModel
            && _currentYYOrderInfoModel.groups
            && [_currentYYOrderInfoModel.groups count] > 0) {

            NSInteger nowIndex = section-1;
            if (nowIndex >= 0
                && nowIndex < [_currentYYOrderInfoModel.groups count]) {
                YYOrderOneInfoModel *orderOneInfoModel = _currentYYOrderInfoModel.groups[nowIndex];
                if (orderOneInfoModel.styles
                    && [orderOneInfoModel.styles count] > 0) {
                    rows = [orderOneInfoModel.styles count];
                }
            }
        }
    }


    return rows;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = nil;
    WeakSelf(ws);
    if (indexPath.section == 0) {
        if(indexPath.row == 0){
            static NSString *CellIdentifier = @"YYOrderUseAddressCell";
            YYOrderUseAddressCell *addressCell =  [_tableView dequeueReusableCellWithIdentifier:CellIdentifier];
            if(!addressCell){
                UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"OrderDetail" bundle:[NSBundle mainBundle]];
                YYCustomCell02ViewController *customCell02ViewController = [storyboard instantiateViewControllerWithIdentifier:@"YYCustomCell02ViewController"];
                addressCell = [customCell02ViewController.tableView dequeueReusableCellWithIdentifier:CellIdentifier];
            }
            addressCell.delegate = self;
            addressCell.indexPath = indexPath;
            addressCell.buyerAddress = _nowBuyerAddress;
            addressCell.currentYYOrderInfoModel = _currentYYOrderInfoModel;
            [addressCell setOrderTypeButtonClicked:^{
                [ws showPickView:@[@"买断（Buy out）",@"寄售（Consignment sale）"]];
            }];
            [addressCell updateUI];
            cell = addressCell;
        }else if(indexPath.row == 1){
            static NSString *CellIdentifier = @"YYOrderTaxInfoCell";
            YYOrderTaxInfoCell *taxInfoCell =  [_tableView dequeueReusableCellWithIdentifier:CellIdentifier];
            if(!taxInfoCell){
                UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"OrderDetail" bundle:[NSBundle mainBundle]];
                YYCustomCell02ViewController *customCell02ViewController = [storyboard instantiateViewControllerWithIdentifier:@"YYCustomCell02ViewController"];
                taxInfoCell = [customCell02ViewController.tableView dequeueReusableCellWithIdentifier:CellIdentifier];
            }
            taxInfoCell.menuData = _menuData;
            taxInfoCell.selectTaxType = _selectTaxType;
            taxInfoCell.delegate = self;
            taxInfoCell.indexPath = indexPath;
            taxInfoCell.stylesAndTotalPriceModel = _stylesAndTotalPriceModel;
            taxInfoCell.currentYYOrderInfoModel = _currentYYOrderInfoModel;
            taxInfoCell.moneyType = [_currentYYOrderInfoModel.curType integerValue];
            WeakSelf(ws);
            [taxInfoCell setTaxChooseBlock:^{
                YYTaxChooseViewController *chooseTaxView = [[YYTaxChooseViewController alloc] init];
                chooseTaxView.selectIndex = _selectTaxType;
                chooseTaxView.selectData = _menuData;
                [chooseTaxView setCancelButtonClicked:^(){
                    [ws.navigationController popViewControllerAnimated:YES];
                }];
                [chooseTaxView setSelectBlock:^(NSInteger selectIndex){
                    ws.selectTaxType = selectIndex;
                    if(selectIndex != 2){
                        ws.menuData = getPayTaxInitData();
                    }
                    [ws.navigationController popViewControllerAnimated:YES];
                    [self btnClick:indexPath.row section:indexPath.section andParmas:@[@(_selectTaxType)]];
                    NSLog(@"111");
                }];
                [self.navigationController pushViewController:chooseTaxView animated:YES];
            }];
            if(_isAppendOrder || [_currentYYOrderInfoModel.isAppend integerValue] == 1){
                taxInfoCell.viewType = 4;
            }else{
                taxInfoCell.viewType = (_isCreatOrder?1:2);
            }
            [taxInfoCell updateUI];
            cell = taxInfoCell;
        }else{
            static NSString *CellIdentifier = @"YYBuyerMessageCell";
            YYBuyerMessageCell *buyerMessageCell =  [_tableView dequeueReusableCellWithIdentifier:CellIdentifier];
            if(!buyerMessageCell){
                UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"OrderDetail" bundle:[NSBundle mainBundle]];
                YYCustomCell02ViewController *customCell02ViewController = [storyboard instantiateViewControllerWithIdentifier:@"YYCustomCell02ViewController"];
                buyerMessageCell = [customCell02ViewController.tableView dequeueReusableCellWithIdentifier:CellIdentifier];
            }
            buyerMessageCell.currentYYOrderInfoModel = self.currentYYOrderInfoModel;
            UIButton *addbtn = [buyerMessageCell viewWithTag:10001];
            if (_isCreatOrder) {
                if(_isReBuildOrder){
                    addbtn.hidden = NO;
                }else{
                    addbtn.hidden = YES;
                }
            }else{
                addbtn.hidden = NO;
            }
            buyerMessageCell.delegate = self;
            buyerMessageCell.indexPath = indexPath;
            [buyerMessageCell updateUI];
            cell = buyerMessageCell;
        }

    }else if (indexPath.section != self.totalSections-1) {
        static NSString *CellIdentifier = @"YYNewStyleDetailCell";
        YYNewStyleDetailCell *tempCell =  [_tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if(!tempCell){
            UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"OrderDetail" bundle:[NSBundle mainBundle]];
            YYCustomCellTableViewController *customCellTableViewController = [storyboard instantiateViewControllerWithIdentifier:@"YYCustomCellTableViewController"];
            tempCell = [customCellTableViewController.tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        }
        if (_currentYYOrderInfoModel && _currentYYOrderInfoModel.groups && [_currentYYOrderInfoModel.groups count] > 0) {
            YYOrderOneInfoModel *orderOneInfoModel = _currentYYOrderInfoModel.groups[indexPath.section - 1];
            if (orderOneInfoModel.styles && [orderOneInfoModel.styles count] > 0) {
                YYOrderStyleModel *orderStyleModel = [orderOneInfoModel.styles objectAtIndex:indexPath.row];
                orderStyleModel.curType = _currentYYOrderInfoModel.curType;
                YYOrderSeriesModel *orderSeriesModel = self.currentYYOrderInfoModel.seriesMap[[orderStyleModel.seriesId stringValue]];
                tempCell.orderStyleModel = orderStyleModel;
                tempCell.orderOneInfoModel = orderOneInfoModel;
                tempCell.orderSeriesModel = orderSeriesModel;
            }
        }
        if (_isCreatOrder) {
            if(_isReBuildOrder){
                tempCell.isModifyNow = 3;
            }else{
                tempCell.isModifyNow = 0;
            }
        }else{
            if(_isAppendOrder){
                tempCell.isModifyNow = 5;
            }else{
                tempCell.isModifyNow = 3;
            }
        }
        tempCell.isReceived = NO;
        tempCell.menuData = _menuData;
        tempCell.delegate = self;
        tempCell.indexPath = indexPath;
        tempCell.selectTaxType = getPayTaxTypeFormServiceNew(_menuData,[ws.currentYYOrderInfoModel.taxRate integerValue]);
        tempCell.isAppendOrder = _isAppendOrder;
        [tempCell updateUI];
        cell = tempCell;
    }else if (indexPath.section == self.totalSections-1) {
        static NSString *CellIdentifier = @"YYOrderRemarkCell";
        YYOrderRemarkCell *orderRemarkCell  =  [_tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if(!orderRemarkCell){
            UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"OrderDetail" bundle:[NSBundle mainBundle]];
            YYCustomCell02ViewController *customCell02ViewController = [storyboard instantiateViewControllerWithIdentifier:@"YYCustomCell02ViewController"];
            orderRemarkCell = [customCell02ViewController.tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        }
        orderRemarkCell.currentYYOrderInfoModel = self.currentYYOrderInfoModel;
        [orderRemarkCell updateUI];
        //订单备注这块
        [orderRemarkCell setTextViewIsEditCallback:^(BOOL isEdit){
            [UIView animateWithDuration:0.3 animations:^{
                [ws.tableView layoutIfNeeded];
                [ws.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:ws.totalSections-1] atScrollPosition:UITableViewScrollPositionBottom animated:YES];
            }];

        }];
        [orderRemarkCell setRemarkButtonClicked:^(){

            [ws showStyleRemarkViewController];
        }];
        cell = orderRemarkCell;
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;

    return cell;
}
#pragma mark UITableViewDelegate
-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return  0.1;
}
- (void)tableView:(UITableView *)tableView willDisplayFooterView:(UIView *)view forSection:(NSInteger)section {
    view.tintColor = [UIColor clearColor];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section == 0) {
        if(indexPath.row == 0){
            if( _nowBuyerAddress == nil ){
                return 48 + 60;
            }
            return 90 + 60;
        }else if(indexPath.row == 1){
            NSInteger moneyType = [_currentYYOrderInfoModel.curType integerValue];
            BOOL needTaxView = NO;
            if(needPayTaxView(moneyType)){
                needTaxView = YES;
            }
            BOOL needDiscountView = YES;
            if (_isCreatOrder) {
                needDiscountView = NO;
            }
            return [YYOrderTaxInfoCell CellHeight:needTaxView :needDiscountView];
        }else{
            return 57;
        }
    }else if (indexPath.section == self.totalSections-1) {
        return 140;
    }else{

        NSInteger styleBuyedSizeCount = 0;
        NSInteger styleTotalNum = 0;
        YYOrderOneInfoModel *orderOneInfoModel =  [_currentYYOrderInfoModel.groups objectAtIndex:indexPath.section - 1];
        if (orderOneInfoModel && indexPath.row < [orderOneInfoModel.styles count]) {
            YYOrderStyleModel *styleModel = [orderOneInfoModel.styles objectAtIndex:indexPath.row];
            if (styleModel.colors && [styleModel.colors count] > 0) {
                for (int i=0; i<[styleModel.colors count]; i++) {
                    YYOrderOneColorModel *orderOneColorModel = [styleModel.colors objectAtIndex:i];

                    //判断amount是不是都是0
                    BOOL isColorSelect = [orderOneColorModel.isColorSelect boolValue];

                    if(isColorSelect){
                        if(!_isCreatOrder && _isAppendOrder){
                            //显示全部size
                            styleBuyedSizeCount += [orderOneColorModel.sizes count];
                        }else{
                            styleBuyedSizeCount += 1;
                        }
                    }else{
                        //判断amount是不是大于0
                        for (YYOrderSizeModel *sizeModel in orderOneColorModel.sizes) {
                            if([sizeModel.amount integerValue] > 0 || [sizeModel.amount integerValue] == -1){
                                styleBuyedSizeCount ++;
                            }
                        }
                    }

                    for (YYOrderSizeModel *sizeModel in orderOneColorModel.sizes) {
                        if([sizeModel.amount integerValue] > 0 || [sizeModel.amount integerValue] == -1){
                            styleTotalNum += MAX(0, [sizeModel.amount integerValue]);
                        }
                    }
                }
            }
            BOOL showHelpFlag = ((styleTotalNum < [styleModel.orderAmountMin integerValue]) || (self.isAppendOrder && [styleModel.supportAdd integerValue] ==0));
            return [YYNewStyleDetailCell CellHeight:styleBuyedSizeCount showHelpFlag:showHelpFlag showTopHeader:[orderOneInfoModel isInStock] showBottomFooter:YES];
        }
    }

    return 0;
}


- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    if (section != 0 && section != self.totalSections - 1) {
        YYOrderOneInfoModel *orderOneInfoModel = _currentYYOrderInfoModel.groups[section - 1];
        if (![orderOneInfoModel isInStock]) {
            static NSString *CellIdentifier = @"YYOrderDetailSectionHead";

            UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"OrderDetail" bundle:[NSBundle mainBundle]];
            YYCustomCellTableViewController *customCellTableViewController = [storyboard instantiateViewControllerWithIdentifier:@"YYCustomCellTableViewController"];

            YYOrderOneInfoModel *orderOneInfoModel =  [_currentYYOrderInfoModel.groups objectAtIndex:section-1];

            YYOrderDetailSectionHead *sectionHead = [customCellTableViewController.tableView dequeueReusableCellWithIdentifier:CellIdentifier];
            sectionHead.isHiddenSelectDateView = YES;
            sectionHead.contentView.backgroundColor = [UIColor whiteColor];
            sectionHead.orderOneInfoModel = orderOneInfoModel;
            [sectionHead updateUI];
            return sectionHead;
        } else {
            return nil;
        }
    }
    return nil;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    if (section == 0 || section == self.totalSections-1) {
        return 0;
    } else {
        YYOrderOneInfoModel *orderOneInfoModel = _currentYYOrderInfoModel.groups[section - 1];
        if ([orderOneInfoModel isInStock]) {
            return 0;
        } else {
            return 40;
        }
    }
}

#pragma mark - --------------自定义代理/block----------------------
#pragma mark YYpickViewDelegate
-(void)toobarDonBtnHaveClick:(YYPickView *)pickView resultString:(NSString *)resultString{
    if([resultString isEqualToString:@"买断（Buy out）"]){
        self.currentYYOrderInfoModel.type = @"BUYOUT";
    }else if([resultString isEqualToString:@"寄售（Consignment sale）"]){
        self.currentYYOrderInfoModel.type = @"CONSIGNMENT";
    }
    [self.tableView reloadData];
}
#pragma mark YYTableCellDelegate
-(void)btnClick:(NSInteger)row section:(NSInteger)section andParmas:(NSArray *)parmas{
    if(section == 0){
        if(row == 0){
            [self changeAddress];
        }else if(row == 2){
            [self thirdButtonClicked:nil];
        }else if(row == 1){
            _selectTaxType = [[parmas objectAtIndex:0] integerValue];
            _currentYYOrderInfoModel.taxRate = [NSNumber numberWithInteger:getPayTaxTypeToServiceNew(_menuData,_selectTaxType)];
            [self updateUI];
        }
    }else if(section > 0){
        NSString *type = [parmas objectAtIndex:0];
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:row inSection:section];
        WeakSelf(ws);
        if([type isEqualToString:@"edit"]){
            [self showShoppingView:indexPath];
        }else if ([type isEqualToString:@"delete"]){
            CMAlertView *alertView = [[CMAlertView alloc] initWithTitle:NSLocalizedString(@"确定要删除款式吗？",nil) message:nil needwarn:NO delegate:nil cancelButtonTitle:NSLocalizedString(@"取消",nil) otherButtonTitles:@[NSLocalizedString(@"删除款式",nil)]];
            alertView.specialParentView = self.view;
            [alertView setAlertViewBlock:^(NSInteger selectedIndex){
                if (selectedIndex == 1) {
                    [ws deleteCellStyleInfo:indexPath];
                    ws.currentYYOrderInfoModel.finalTotalPrice = nil;
                    [ws updateTotalValue];
                    [ws.tableView reloadData];
                }
            }];
            [alertView show];
        }else if([type isEqualToString:@"editStyleNum"]){
            NSIndexPath *sizeIndexPath = [parmas objectAtIndex:1];
            NSString *num = [parmas objectAtIndex:2];
            [self editCellStyleInfo:indexPath sizeIndex:sizeIndexPath amount:num];
            [self updateUI];
        }
    }
}

#pragma mark - --------------自定义响应----------------------
#pragma mark Notifications
- (void)updateShoppingCarNotification:(NSNotification *)note{
    [self orderAddStyleNotification:note];
}
- (void)orderAddStyleNotification:(NSNotification *)note{
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    if (appDelegate.orderModel) {
        NSLog(@"appDelegate.orderModel toJSONString : %@",[appDelegate.orderModel toJSONString]);

        self.currentYYOrderInfoModel = [[YYOrderInfoModel alloc] initWithDictionary:[appDelegate.orderModel toDictionary] error:nil];
        self.currentYYOrderInfoModel.finalTotalPrice = nil;
        if(note == nil){//不是消息就清理掉 添加款式多次用到缓存
            appDelegate.orderSeriesArray = nil;
            appDelegate.orderModel = nil;
        }
    }
    [self updateUI];
}
#pragma mark SomeClicked
- (IBAction)closeButtonClicked:(id)sender{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kUpdateShoppingCarNotification object:nil];
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    if (appDelegate.orderModel) {
        appDelegate.orderSeriesArray = nil;
        appDelegate.orderModel = nil;
    }

    if (self.closeButtonClicked) {
        self.closeButtonClicked();
    }
}
- (IBAction)saveButtonClicked:(id)sender{
    if (_stylesAndTotalPriceModel.totalStyles == 0) {
        if(_isCreatOrder){
            [YYToast showToastWithView:self.view title:NSLocalizedString(@"订单中款式数为0，不能建立订单",nil)  andDuration:kAlertToastDuration];
        }else{
            [YYToast showToastWithView:self.view title:NSLocalizedString(@"订单中款式数为0，不能保存修改",nil)  andDuration:kAlertToastDuration];
        }
        return;
    }

    if (_stylesAndTotalPriceModel.totalCount == 0) {
        if(_isCreatOrder){
            [YYToast showToastWithView:self.view title:NSLocalizedString(@"订单中件数为0，不能建立订单",nil)  andDuration:kAlertToastDuration];
        }else{
            [YYToast showToastWithView:self.view title:NSLocalizedString(@"订单中件数为0，不能保存修改",nil)  andDuration:kAlertToastDuration];
        }
        return;
    }

    if([NSString isNilOrEmpty:self.currentYYOrderInfoModel.type]){
        [YYToast showToastWithView:self.view title:NSLocalizedString(@"请选择订单类型",nil)  andDuration:kAlertToastDuration];
        return;
    }
    
    WeakSelf(ws);
    self.currentYYOrderInfoModel.buyerEmail =_buyerModel.contactEmail;
    self.currentYYOrderInfoModel.realBuyerId =_buyerModel.buyerId;
    self.currentYYOrderInfoModel.buyerName =_buyerModel.name;

    NSMutableArray *seriesIds =  [[NSMutableArray alloc] init];
    [_currentYYOrderInfoModel.groups enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        YYOrderOneInfoModel *orderOneInfoModel = obj;
        if (orderOneInfoModel) {
            if ([orderOneInfoModel.styles count] > 0) {
                for (YYOrderStyleModel *orderStyleModel in orderOneInfoModel.styles) {
                    if(![seriesIds containsObject:[orderStyleModel.seriesId stringValue]]){
                        [seriesIds addObject:[orderStyleModel.seriesId stringValue]];
                    }
                }
            }
        }
    }];

    //删除系列队列seriesMap
    NSArray *allKeys = [_currentYYOrderInfoModel.seriesMap allKeys];
    for (NSString *seriesId  in allKeys) {
        if(![seriesIds containsObject:seriesId]){
            [_currentYYOrderInfoModel.seriesMap removeObjectForKey:seriesId];
        }
    }

    if (self.stylesAndTotalPriceModel) {
        self.currentYYOrderInfoModel.totalPrice = [NSNumber numberWithFloat: self.stylesAndTotalPriceModel.originalTotalPrice];
    }

    self.currentYYOrderInfoModel.finalTotalPrice =  [NSNumber numberWithFloat: self.stylesAndTotalPriceModel.finalTotalPrice];

    if (!self.currentYYOrderInfoModel.orderCreateTime) {
        NSTimeInterval time = [[NSDate date] timeIntervalSince1970]*1000;
        self.currentYYOrderInfoModel.orderCreateTime = [NSNumber numberWithLongLong:time];
    }

    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    YYAddress * adress = [self getcurBuyerAddress];
    if(adress != nil ){
        __block BOOL _inRunLoop = true;
        NSString *orderCode = (_isCreatOrder?nil:self.currentYYOrderInfoModel.orderCode);
        [YYOrderApi createOrModifyAddress:adress orderCode:orderCode andBlock:^(YYRspStatusAndMessage *rspStatusAndMessage, YYBuyerAddressModel *addressModel, NSError *error) {
            if (rspStatusAndMessage.status == YYReqStatusCode100 && addressModel && addressModel.addressId){
                NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
                [numberFormatter setNumberStyle:NSNumberFormatterDecimalStyle];
                ws.currentYYOrderInfoModel.buyerAddress.addressId = [numberFormatter numberFromString:addressModel.addressId];
                ws.currentYYOrderInfoModel.buyerAddressId = [numberFormatter numberFromString:addressModel.addressId];
                _inRunLoop = false;
            }else{
                [YYToast showToastWithView:ws.view title:rspStatusAndMessage.message  andDuration:kAlertToastDuration];
                [MBProgressHUD hideAllHUDsForView:ws.view animated:YES];
            }
        }];
        while (_inRunLoop) {
            [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantFuture]];
        }
    }

    NSData *jsonData = [[self.currentYYOrderInfoModel toDictionary] mj_JSONData];

    NSString *actionRefer = (_isCreatOrder?@"create":@"modify");
    if(_isAppendOrder){
        actionRefer = @"append";
    }
    NSInteger realBuyerId = [_buyerModel.buyerId integerValue];

    [YYOrderApi createOrModifyOrderByJsonData:jsonData actionRefer:actionRefer realBuyerId:realBuyerId andBlock:^(YYRspStatusAndMessage *rspStatusAndMessage, NSString *orderCode, NSError *error) {
        if (rspStatusAndMessage.status == YYReqStatusCode100) {
            [MBProgressHUD hideAllHUDsForView:ws.view animated:YES];
            [YYToast showToastWithView:ws.view title:NSLocalizedString(@"操作成功",nil)  andDuration:kAlertToastDuration];
            if (ws.currentYYOrderInfoModel.shareCode
                && !ws.currentYYOrderInfoModel.orderCode){
                //这里要清除购物车
                AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
                [appDelegate clearBuyCarWidthDesingerId:[ws.currentYYOrderInfoModel.designerId stringValue]];
                NSLog(@"111");
            }
            //更新购物车按钮数量
            [[NSNotificationCenter defaultCenter] postNotificationName:kUpdateShoppingCarNotification object:nil];
            if(ws.isCreatOrder){
                ws.saveButton.enabled = NO;
            }
            // 延迟调用
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(kDelaySeconds * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [ws closeModifyOrderViewWhenSave];
            });

        }else{
            [MBProgressHUD hideAllHUDsForView:ws.view animated:YES];
            [YYToast showToastWithView:ws.view title:rspStatusAndMessage.message andDuration:kAlertToastDuration];
        }

    }];
}
//添加款式
- (IBAction)thirdButtonClicked:(id)sender {
    //把当前的订单对象，传到全局的AppDelegate中
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    appDelegate.orderModel = [[YYOrderInfoModel alloc] initWithDictionary:[self.currentYYOrderInfoModel toDictionary] error:nil];

    NSMutableArray *tempArray = [[NSMutableArray alloc] initWithCapacity:0];
    [tempArray addObjectsFromArray:self.currentYYOrderInfoModel.groups];
    appDelegate.orderSeriesArray = tempArray;

    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Opus" bundle:[NSBundle mainBundle]];
    YYStyleDetailListViewController *styleDetailListViewController = [storyboard instantiateViewControllerWithIdentifier:@"YYStyleDetailListViewController"];
    styleDetailListViewController.isModifyOrder = YES;
    styleDetailListViewController.designerId = [self.currentYYOrderInfoModel.designerId integerValue];
    //这里要根据实际情况判断，是用离线的数据，还是缓存的，还是在线的
    styleDetailListViewController.currentYYOrderInfoModel = self.currentYYOrderInfoModel;

    [self.navigationController pushViewController:styleDetailListViewController animated:YES];
}
#pragma mark Other
- (void)goBack {
    [self closeButtonClicked:nil];
}
- (void)closeModifyOrderViewWhenSave{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kUpdateShoppingCarNotification object:nil];

    if (self.modifySuccess) {
        self.modifySuccess();
    }else{
        if (self.closeButtonClicked) {
            self.closeButtonClicked();
        }
    }
}
//编辑
-(void)showShoppingView:(NSIndexPath *)indexPath{
    //把当前的订单对象，传到全局的AppDelegate中
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    appDelegate.orderModel = [[YYOrderInfoModel alloc] initWithDictionary:[self.currentYYOrderInfoModel toDictionary] error:nil];

    NSMutableArray *tempArray = [[NSMutableArray alloc] initWithCapacity:0];
    [tempArray addObjectsFromArray:self.currentYYOrderInfoModel.groups];
    appDelegate.orderSeriesArray = tempArray;

    YYOrderOneInfoModel *oneInfoModel = _currentYYOrderInfoModel.groups[indexPath.section-1];
    YYOrderStyleModel *orderStyleModel = [oneInfoModel.styles objectAtIndex:indexPath.row];
    orderStyleModel.tmpDateRange = oneInfoModel.dateRange;
    YYOrderSeriesModel *orderseriesModel = [_currentYYOrderInfoModel.seriesMap objectForKey:[orderStyleModel.seriesId stringValue]];
    if(orderStyleModel == nil || orderseriesModel == nil){
        return;
    }

    UIView *superView = self.view;
    [appDelegate showShoppingView:YES styleInfoModel:orderStyleModel seriesModel:orderseriesModel opusStyleModel:nil currentYYOrderInfoModel:_currentYYOrderInfoModel parentView:superView fromBrandSeriesView:NO WithBlock:nil];
}

-(void)deleteCellStyleInfo:(NSIndexPath *)indexPath{
    YYOrderOneInfoModel *orderOneInfo = _currentYYOrderInfoModel.groups[indexPath.section-1];
    if([orderOneInfo.styles count] > indexPath.row){
        [orderOneInfo.styles removeObjectAtIndex:indexPath.row];
    }
    if([orderOneInfo.styles count] == 0){
        [_currentYYOrderInfoModel.groups removeObjectAtIndex:indexPath.section-1];
    }
    self.totalSections = [self.currentYYOrderInfoModel.groups count]+2;
}
-(void)showStyleRemarkViewController{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"OrderDetail" bundle:[NSBundle mainBundle]];
    YYOrderStylesRemarkViewController *orderStylesRemarkViewController = [storyboard instantiateViewControllerWithIdentifier:@"YYOrderStylesRemarkViewController"];
    WeakSelf(ws);
    [orderStylesRemarkViewController setCancelButtonClicked:
     ^(){
         [ws.navigationController popViewControllerAnimated:YES];
     }];
    [orderStylesRemarkViewController setSaveButtonClicked:
     ^(){
         [ws.navigationController popViewControllerAnimated:YES];
     }];
    orderStylesRemarkViewController.orderInfoModel = _currentYYOrderInfoModel;
    [self.navigationController pushViewController:orderStylesRemarkViewController animated:YES];

}
#pragma mark - --------------自定义方法----------------------
#pragma mark Update
//更新显示总数
- (void)updateTotalValue{
    _minOrderMoneyBtn1.hidden = YES;
    _countLabelLayoutBottomConstraint.constant = 14;
    self.stylesAndTotalPriceModel = [self.currentYYOrderInfoModel getTotalValueByOrderInfo:NO];

    if (_stylesAndTotalPriceModel) {
        _countLabel.text = [NSString stringWithFormat:NSLocalizedString(@"共%i款 %i件",nil),_stylesAndTotalPriceModel.totalStyles,_stylesAndTotalPriceModel.totalCount];


        _priceTotalDiscountView.backgroundColor = [UIColor clearColor];

        _priceTotalDiscountView.bgColorIsBlack = NO;

        self.currentYYOrderInfoModel.finalTotalPrice = [NSNumber numberWithFloat:self.stylesAndTotalPriceModel.finalTotalPrice];

        NSString *finalValue = finalValue = replaceMoneyFlag([NSString stringWithFormat:@"￥%.2f",_stylesAndTotalPriceModel.finalTotalPrice],[_currentYYOrderInfoModel.curType integerValue]);
        CGSize txtSize = [finalValue sizeWithAttributes:@{NSFontAttributeName:[UIFont boldSystemFontOfSize:IsPhone6_gt?15:12]}];

        _priceTotalDiscountView.notShowDiscountValueTextAlignmentLeft = YES;
        _priceTotalDiscountView.fontColorStr =  @"ed6498";
        [_priceTotalDiscountView updateUIWithOriginPrice:finalValue
                                              fianlPrice:finalValue
                                              originFont:[UIFont boldSystemFontOfSize:IsPhone6_gt?15:12]
                                               finalFont:[UIFont boldSystemFontOfSize:IsPhone6_gt?15:12]];
        [_priceTotalDiscountView setConstraintConstant:txtSize.width+1 forAttribute:NSLayoutAttributeWidth];

        __block double blockcostMeoney = _stylesAndTotalPriceModel.originalTotalPrice;
        __block float blockcurType = [self.currentYYOrderInfoModel.curType integerValue];
        WeakSelf(ws);
        if(blockcurType >= 0){
            [YYOrderApi getOrderUnitPrice:[self.currentYYOrderInfoModel.designerId unsignedIntegerValue] moneyType:blockcurType andBlock:^(YYRspStatusAndMessage *rspStatusAndMessage, NSUInteger orderUnitPrice, NSError *error) {
                if(orderUnitPrice > blockcostMeoney){

                    UIImage *icon = [[UIImage imageNamed:@"warn"] imageWithTintColor:[UIColor colorWithHex:@"ef4e31"]];
                    [ws.minOrderMoneyBtn1 setImage:icon forState:UIControlStateNormal];
                    [ws.minOrderMoneyBtn1 setTitle:replaceMoneyFlag([NSString stringWithFormat:NSLocalizedString(@"未达到每单起订额 ￥%ld",nil),orderUnitPrice],blockcurType) forState:UIControlStateNormal];
                    ws.minOrderMoneyBtn1.hidden = NO;
                    ws.countLabelLayoutBottomConstraint.constant = 14+7;
                }
            }];
        }
    }
}

- (void)updateUI{
    if (_isCreatOrder) {
        [self.navView setNavTitle:NSLocalizedString(@"确认订单",nil)];
        [_saveButton setTitle:NSLocalizedString(@"建立订单",nil) forState:UIControlStateNormal];
        //创建时，订单状态是正常
        if (!self.currentYYOrderInfoModel.designerOrderStatus || !self.currentYYOrderInfoModel.buyerOrderStatus) {
            self.currentYYOrderInfoModel.designerOrderStatus = [NSNumber numberWithInt:0];
            self.currentYYOrderInfoModel.buyerOrderStatus = [NSNumber numberWithInt:0];
        }

        if (!self.currentYYOrderInfoModel.shareCode) {
            //如果是新建订单，而且没有网络
            self.currentYYOrderInfoModel.shareCode = createOrderSharecode();
        }

    }else{
        if(!_isAppendOrder){
            [self.navView setNavTitle:NSLocalizedString(@"修改订单",nil)];
            [_saveButton setTitle:NSLocalizedString(@"保存修改",nil) forState:UIControlStateNormal];
        }else{
            [self.navView setNavTitle:NSLocalizedString(@"补货追单",nil)];
            [_saveButton setTitle:NSLocalizedString(@"确认追单",nil) forState:UIControlStateNormal];
        }
    }

    if (!self.currentYYOrderInfoModel.orderCreateTime) {
        NSTimeInterval time = [[NSDate date] timeIntervalSince1970]*1000;
        self.currentYYOrderInfoModel.orderCreateTime = [NSNumber numberWithLongLong:time];
    }
    [self updateTotalValue];

    self.totalSections = [self.currentYYOrderInfoModel.groups count]+2;

    if(!_stylesAndTotalPriceModel.totalStyles || !_stylesAndTotalPriceModel.totalCount){
        _saveButton.backgroundColor = [UIColor colorWithHex:@"d3d3d3"];
    }else{
        _saveButton.backgroundColor = _define_black_color;
    }

    [self.tableView reloadData];
}
- (void)updateBuyerAddress:(YYAddress *)nowAddress{
    YYOrderBuyerAddress *buyerAddress = [[YYOrderBuyerAddress alloc] init];

    buyerAddress.addressId = [[NSNumber alloc] initWithInt:0];
    if (nowAddress.receiverName) {
        buyerAddress.receiverName = nowAddress.receiverName;
    }
    if (nowAddress.receiverPhone) {
        buyerAddress.receiverPhone = nowAddress.receiverPhone;
    }
    if (nowAddress.zipCode) {
        buyerAddress.zipCode = nowAddress.zipCode;
    }
    if (nowAddress.detailAddress) {
        buyerAddress.detailAddress = nowAddress.detailAddress;
    }
    if (nowAddress.defaultShipping){
        buyerAddress.defaultShipping = [[NSNumber alloc] initWithInt:1];
        buyerAddress.defaultShippingAddress= [[NSNumber alloc] initWithInt:1];
    }else{
        buyerAddress.defaultShipping = [[NSNumber alloc] initWithInt:0];
        buyerAddress.defaultShippingAddress= [[NSNumber alloc] initWithInt:1];
    }
    if (nowAddress.nation) {
        buyerAddress.nation = nowAddress.nation;
    }
    if (nowAddress.province) {
        buyerAddress.province = nowAddress.province;
    }
    if (nowAddress.city) {
        buyerAddress.city = nowAddress.city;
    }
    if (nowAddress.nationEn) {
        buyerAddress.nationEn = nowAddress.nationEn;
    }
    if (nowAddress.provinceEn) {
        buyerAddress.provinceEn = nowAddress.provinceEn;
    }
    if (nowAddress.cityEn) {
        buyerAddress.cityEn = nowAddress.cityEn;
    }
    if (nowAddress.nationId) {
        buyerAddress.nationId = nowAddress.nationId;
    }
    if (nowAddress.provinceId) {
        buyerAddress.provinceId = nowAddress.provinceId;
    }
    if (nowAddress.cityId) {
        buyerAddress.cityId = nowAddress.cityId;
    }

    if(self.currentYYOrderInfoModel.buyerAddress == nil){
        self.currentYYOrderInfoModel.buyerAddress = buyerAddress;
        self.currentYYOrderInfoModel.buyerAddressId = buyerAddress.addressId;
    }

    _nowBuyerAddress = buyerAddress;
    [self updateUI];
}
#pragma mark Other
- (NSInteger)getArrayCount:(NSArray *)data {
    if (data) {
        return [data count];
    }

    return 0;
}
-(void)editCellStyleInfo:(NSIndexPath *)indexPath sizeIndex:(NSIndexPath *)index amount:(NSString *)amount{

    YYOrderOneInfoModel *orderOneInfo = _currentYYOrderInfoModel.groups[indexPath.section-1];
    YYOrderStyleModel *orderStyleModel = [orderOneInfo.styles objectAtIndex:indexPath.row];
    YYOrderOneColorModel * oneColorModel = [orderStyleModel.colors objectAtIndex:index.section];
    YYOrderSizeModel * sizeModel = [oneColorModel.sizes objectAtIndex:index.row];
    sizeModel.amount = [[NSNumber alloc] initWithInteger:[amount integerValue]];
    if([amount integerValue] == 0){
        for (oneColorModel in orderStyleModel.colors) {
            for (sizeModel in oneColorModel.sizes) {
                if(sizeModel.amount && [sizeModel.amount integerValue] != 0){
                    return;
                }
            }
        }
        [orderOneInfo.styles removeObjectAtIndex:indexPath.row];
    }
}
//更换地址
-(void)changeAddress{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Account" bundle:[NSBundle mainBundle]];
    YYBuyerAddressViewController *buyerAddressViewController = [storyboard instantiateViewControllerWithIdentifier:@"YYBuyerAddressViewController"];
    WeakSelf(ws);
    [buyerAddressViewController setCancelButtonClicked:
     ^(){
         [ws.navigationController popViewControllerAnimated:YES];
     }];
    [buyerAddressViewController setSelectAddressClicked:
     ^(YYAddress *address){
         [ws.navigationController popViewControllerAnimated:YES];
         [ws updateBuyerAddress:address];
     }];
    buyerAddressViewController.isSelect = 1;
    [self.navigationController pushViewController:buyerAddressViewController animated:YES];

}
-(YYAddress *)getcurBuyerAddress{
    if(_currentYYOrderInfoModel.buyerAddress == nil || ([_nowBuyerAddress.addressId integerValue] >0 && [_currentYYOrderInfoModel.buyerAddress.addressId integerValue] == [_nowBuyerAddress.addressId integerValue] )){
        return nil;
    }
    YYAddress *newAddress = [[YYAddress alloc] init];
    newAddress.addressId = 0;
    newAddress.receiverName = _nowBuyerAddress.receiverName;
    newAddress.receiverPhone = _nowBuyerAddress.receiverPhone;
    newAddress.zipCode = _nowBuyerAddress.zipCode;
    newAddress.detailAddress = _nowBuyerAddress.detailAddress;
    newAddress.nation = _nowBuyerAddress.nation;
    newAddress.province = _nowBuyerAddress.province;
    newAddress.city = _nowBuyerAddress.city;
    newAddress.nationEn = _nowBuyerAddress.nationEn;
    newAddress.provinceEn = _nowBuyerAddress.provinceEn;
    newAddress.cityEn = _nowBuyerAddress.cityEn;
    newAddress.nationId = _nowBuyerAddress.nationId;
    newAddress.provinceId = _nowBuyerAddress.provinceId;
    newAddress.cityId = _nowBuyerAddress.cityId;
    if([_nowBuyerAddress.defaultShippingAddress integerValue] > 0 || [_nowBuyerAddress.defaultShipping integerValue] > 0){
        newAddress.defaultShipping = YES;
    }else{
        newAddress.defaultShipping = NO;
    }
    return newAddress;
}
-(void)showPickView:(NSArray *)dataArr{
    if(self.pickerView.superview != nil){
        return;
    }
    self.pickerView=[[YYPickView alloc] initPickviewWithArray:dataArr isHaveNavControler:NO];
    [self.pickerView show:self.view];
    [self.pickerView selectPickerRow:0 inComponent:0 animated:YES];
    self.pickerView.delegate = self;
}
#pragma mark - --------------other----------------------

@end
