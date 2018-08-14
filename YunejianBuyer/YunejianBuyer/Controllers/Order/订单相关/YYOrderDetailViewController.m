//
//  YYOrderDetailViewController.m
//  Yunejian
//
//  Created by yyj on 15/8/6.
//  Copyright (c) 2015年 yyj. All rights reserved.
//

#import "YYOrderDetailViewController.h"

// c文件 —> 系统文件（c文件在前）

// 控制器
#import "YYCustomCellTableViewController.h"
#import "YYOrderModifyLogListController.h"
#import "YYOrderHelpViewController.h"
#import "YYOrderOtherCloseReqDealViewController.h"
#import "YYPackageListViewController.h"
#import "YYCustomCell02ViewController.h"
#import "YYOrderPayLogViewController.h"
#import "YYOrderMessageViewController.h"
#import "YYMessageDetailViewController.h"
#import "YYDeliveringDoneConfirmViewController.h"
#import "YYOriginalOrderDetailViewController.h"

// 自定义视图
#import "YYNavView.h"
#import "YYOrderPackageInfoCell.h"
#import "YYBuyerInfoCell1.h"
#import "YYBuyerInfoRemarkCell.h"
#import "YYOrderStatusCell.h"
#import "YYOrderMoneyLogCell.h"
#import "YYNewStyleDetailCell.h"
#import "YYOrderBuyerReceivedCell.h"
#import "YYOrderOtherCloseReqCell.h"
#import "YYOrderColseProgressCell.h"
#import "YYOrderTaxInfoCell.h"
#import "YYOrderDetailSectionHead.h"
#import "YYDiscountView.h"
#import "YYSelecteDateView.h"
#import "YYYellowPanelManage.h"
#import "YYMenuPopView.h"
#import "MBProgressHUD.h"

// 接口
#import "YYOrderApi.h"
#import "YYOpusApi.h"

// 分类
#import "UIImage+Tint.h"
#import "UIImage+YYImage.h"
#import "UIView+UpdateAutoLayoutConstraints.h"

// 自定义类和三方类（ cocoapods类 > model > 工具类 > 其他）
#import "YYUser.h"
#import "YYOrderInfoModel.h"
#import "YYPaymentNoteListModel.h"
#import "YYOrderConnStatusModel.h"
#import "YYOrderAppendParamModel.h"
#import "YYStylesAndTotalPriceModel.h"

#import "AppDelegate.h"

typedef NS_ENUM(NSInteger, kOrderMenuActionType) {
    kOrderMenuActionType_modifyOrder            = 10001,      //修改订单
    kOrderMenuActionType_cancelOrder            = 10002,      //取消订单
    kOrderMenuActionType_modifyRecord           = 10003,      //修改记录
    kOrderMenuActionType_closeOrder             = 10004,      //关闭订单
    kOrderMenuActionType_appendOrder            = 10005,      //追单补货
    kOrderMenuActionType_checkOriginalOrder     = 10006,      //查看原订单
    kOrderMenuActionType_shareOrder             = 10007,      //分享订单
    kOrderMenuActionType_checkAppendOrder       = 10008,      //查看追单
    kOrderMenuActionType_originalOrderDetail    = 100010      //原订单内容
};

@interface YYOrderDetailViewController ()<UITableViewDataSource,UITableViewDelegate,YYTableCellDelegate>

@property (weak, nonatomic) IBOutlet UIView *containerView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *containerViewTopLayout;

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *tableViewBottomLayout;

@property (nonatomic, strong) YYOrderInfoModel *currentYYOrderInfoModel;
@property (nonatomic, strong) YYOrderTransStatusModel *currentYYOrderTransStatusModel;
@property (nonatomic, strong) YYPaymentNoteListModel *paymentNoteList;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *discountViewTrailingLayoutConstraint;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *priceViewlayoutWidthConstraints;

@property (weak, nonatomic) IBOutlet UILabel *countLabel;
@property (weak, nonatomic) IBOutlet UILabel *priceTitleLabel;
@property (weak, nonatomic) IBOutlet YYDiscountView *priceTotalDiscountView;

@property (nonatomic, strong) YYStylesAndTotalPriceModel *stylesAndTotalPriceModel;//总数

@property (nonatomic, strong) UIButton *chatBtn;//私聊按钮
@property (nonatomic, strong) UIButton *menuBtn;//menu按钮
@property (nonatomic, assign) NSInteger isPaylistShow;
@property (nonatomic, strong) YYOrderOtherCloseReqDealViewController *orderCloseReqDealViewController;
@property (nonatomic, strong) YYNavView *navView;
@property (nonatomic, strong) CMAlertView *remarkAlert;

@property (nonatomic, assign) BOOL isAvailableForAliPay;

@property (nonatomic, strong) NSMutableArray *menuData;
@property (nonatomic, assign) NSInteger selectTaxType;

@end

@implementation YYOrderDetailViewController
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
    [MobClick beginLogPageView:kYYPageOrderDetail];
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    // 退出埋点
    [MobClick endLogPageView:kYYPageOrderDetail];
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
    _menuData = getPayTaxInitData();
    _selectTaxType = 0;
    _isPaylistShow = 0;
}
- (void)PrepareUI{

    if(IsPhone6_gt){
        _countLabel.font = [UIFont systemFontOfSize:13.0f];
        _priceTitleLabel.font = [UIFont systemFontOfSize:13.0f];
    }else{
        _countLabel.font = [UIFont systemFontOfSize:12.0f];
        _priceTitleLabel.font = [UIFont systemFontOfSize:12.0f];
    }
    _containerViewTopLayout.constant = kStatusBarHeight;
    _tableViewBottomLayout.constant = kTabbarAndBottomSafeAreaHeight;
    [self.tableView registerNib:[UINib nibWithNibName:@"YYBuyerInfoCell1" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:@"YYBuyerInfoCell1"];
    [self.tableView registerNib:[UINib nibWithNibName:@"YYBuyerInfoRemarkCell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:@"YYBuyerInfoRemarkCell"];
    [self.tableView registerNib:[UINib nibWithNibName:@"YYOrderStatusCell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:@"YYOrderStatusCell"];
    [self.tableView registerNib:[UINib nibWithNibName:@"YYOrderMoneyLogCell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:@"YYOrderMoneyLogCell"];
    [self.tableView registerNib:[UINib nibWithNibName:@"YYOrderBuyerReceivedCell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:@"YYOrderBuyerReceivedCell"];
    [self.tableView registerNib:[UINib nibWithNibName:@"YYOrderOtherCloseReqCell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:@"YYOrderOtherCloseReqCell"];
    [self.tableView registerNib:[UINib nibWithNibName:@"YYOrderColseProgressCell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:@"YYOrderColseProgressCell"];
}

#pragma mark - --------------UIConfig----------------------
-(void)UIConfig{
    [self createNavigationBarView];
}
-(void)createNavigationBarView{
    self.navView = [[YYNavView alloc] initWithTitle:NSLocalizedString(@"订单详情",nil) WithSuperView:self.view haveStatusView:YES];
    WeakSelf(ws);
    self.navView.goBackBlock = ^{
        [ws goBack];
    };
    [self initMenuBtn];
    [self initChatBtn];
}

-(void)initMenuBtn{
    _menuBtn = [[UIButton alloc] init];
    [_menuBtn setTitleEdgeInsets:UIEdgeInsetsMake(0, 20, 0, 0)];
    [_menuBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [_menuBtn.titleLabel setFont:[UIFont systemFontOfSize:14]];
    _menuBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
    [self.navView addSubview:_menuBtn];
    [_menuBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(70);
        make.top.mas_equalTo(kStatusBarHeight);
        make.right.mas_equalTo(-17);
        make.bottom.mas_equalTo(-1);
    }];
}

-(void)initChatBtn{
    _chatBtn = [[UIButton alloc] init];
    [_chatBtn setTitleEdgeInsets:UIEdgeInsetsMake(0, 20, 0, 0)];
    [_chatBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [_chatBtn.titleLabel setFont:[UIFont systemFontOfSize:14]];
    [_chatBtn setTintColor:[UIColor blackColor]];
    [self.navView addSubview:_chatBtn];
    [_chatBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(40);
        make.top.mas_equalTo(kStatusBarHeight);
        make.right.mas_equalTo(-60);
        make.bottom.mas_equalTo(-1);
    }];
}

#pragma mark - --------------请求数据----------------------
-(void)RequestData{
    [self refreshOrder];
    if(_currentOrderConnStatus == YYOrderConnStatusUnknow){
        [self updateOrderConnStatus];
    }
}

#pragma mark - --------------系统代理----------------------
#pragma mark -UITableViewDelegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return [self getSectionsNum];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (section == 0) {
        if(_currentYYOrderInfoModel.packageStat){
            return 7;
        }
        return 6;
    }else if([self getSectionsNum] == (section+1)){
        return 1;
    }else{
        int rows = 0;
        if (_currentYYOrderInfoModel
            && _currentYYOrderInfoModel.groups
            && [_currentYYOrderInfoModel.groups count] > 0) {
            YYOrderOneInfoModel *orderOneInfoModel = _currentYYOrderInfoModel.groups[section - 1];
            if (orderOneInfoModel.styles
                && [orderOneInfoModel.styles count] > 0) {
                rows = (int)[orderOneInfoModel.styles count];
            }
        }
        return rows;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    WeakSelf(ws);
    if (indexPath.section == 0) {
        NSInteger orderStatus = getOrderTransStatus(self.currentYYOrderTransStatusModel.designerTransStatus, self.currentYYOrderTransStatusModel.buyerTransStatus);
        if(indexPath.row == 0){
            if(self.currentYYOrderInfoModel != nil){
                YYOrderStatusCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"YYOrderStatusCell" forIndexPath:indexPath];
                cell.currentYYOrderTransStatusModel = self.currentYYOrderTransStatusModel;
                cell.currentYYOrderInfoModel = self.currentYYOrderInfoModel;
                [cell updateUI];
                cell.delegate = self;

                return cell;
            }else{
                UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"YYOrderNullCell"];
                if(cell == nil){
                    cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"YYOrderNullCell"];
                }
                return cell;
            }
        }else if(indexPath.row == 1){
            if(self.currentYYOrderInfoModel != nil && (orderStatus == YYOrderCode_CLOSE_REQ || [_currentYYOrderInfoModel.closeReqStatus integerValue] == -1)){
                YYOrderColseProgressCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"YYOrderColseProgressCell" forIndexPath:indexPath];
                if([_currentYYOrderInfoModel.closeReqStatus integerValue] == -1){//对方
                    cell.titleArr =   @[NSLocalizedString(@"对方取消订单",nil),NSLocalizedString(@"处理中",nil),NSLocalizedString(@"已取消",nil)];
                    cell.progressValue = 2;
                }else if([_currentYYOrderInfoModel.closeReqStatus integerValue] == 1){//自己
                    cell.titleArr = @[NSLocalizedString(@"取消订单",nil),NSLocalizedString(@"对方处理中",nil),NSLocalizedString(@"已取消",nil)];
                    cell.progressValue = 2;
                }

                [cell updateUI];
                return cell;
            }
            UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"YYOrderNullCell"];
            if(cell == nil){
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"YYOrderNullCell"];
            }
            return cell;

        }else if(indexPath.row == 2){
            if(self.paymentNoteList != nil && orderStatus >= YYOrderCode_NEGOTIATION){
                YYOrderMoneyLogCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"YYOrderMoneyLogCell" forIndexPath:indexPath];
                cell.currentYYOrderTransStatusModel = self.currentYYOrderTransStatusModel;
                cell.currentYYOrderInfoModel = self.currentYYOrderInfoModel;
                cell.delegate = self;
                cell.paymentNoteList = self.paymentNoteList;
                cell.isPaylistShow = self.isPaylistShow;
                cell.alipayTipBtn.hidden = !self.isAvailableForAliPay;
                cell.alipayTipArrowView.hidden = !self.isAvailableForAliPay;
                [cell updateUI];
                return cell;
            }else{
                UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"YYOrderNullCell"];
                if(cell == nil){
                    cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"YYOrderNullCell"];
                }
                return cell;
            }
        }else if(indexPath.row == 3){
            UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"YYOrderNullCell"];
            if(cell == nil){
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"YYOrderNullCell"];
            }
            return cell;
        }else if(indexPath.row == 4){
            YYBuyerInfoCell1 *cell = [self.tableView dequeueReusableCellWithIdentifier:@"YYBuyerInfoCell1" forIndexPath:indexPath];
            cell.currentYYOrderInfoModel = _currentYYOrderInfoModel;
            cell.currentOrderConnStatus = _currentOrderConnStatus;
            cell.delegate = self;
            [cell updataUI];
            return cell ;
        }else{

            if(indexPath.row == 5 && _currentYYOrderInfoModel.packageStat){
                static NSString *cellid = @"YYOrderPackageInfoCell";
                YYOrderPackageInfoCell *cell = [_tableView dequeueReusableCellWithIdentifier:cellid];
                if(!cell){
                    cell = [[YYOrderPackageInfoCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellid];
                    cell.selectionStyle = UITableViewCellSelectionStyleNone;
                    [cell setCellClickBlock:^{
                        [ws gotoPackageListView];
                    }];
                }
                cell.orderPackageStatModel = _currentYYOrderInfoModel.packageStat;
                [cell updateUI];
                return cell;
            }

            if(indexPath.row == (_currentYYOrderInfoModel.packageStat ? 6 : 5)){
                static NSString *CellIdentifier = @"YYOrderTaxInfoCell";
                YYOrderTaxInfoCell *taxInfoCell  =  [_tableView dequeueReusableCellWithIdentifier:CellIdentifier];
                if(!taxInfoCell){
                    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"OrderDetail" bundle:[NSBundle mainBundle]];
                    YYCustomCell02ViewController *customCell02ViewController = [storyboard instantiateViewControllerWithIdentifier:@"YYCustomCell02ViewController"];
                    taxInfoCell = [customCell02ViewController.tableView dequeueReusableCellWithIdentifier:CellIdentifier];
                }
                taxInfoCell.menuData = _menuData;
                taxInfoCell.selectTaxType = _selectTaxType;
                taxInfoCell.delegate = self;
                taxInfoCell.indexPath = indexPath;
                taxInfoCell.selectTaxType = getPayTaxTypeFormServiceNew(ws.menuData,[ws.currentYYOrderInfoModel.taxRate integerValue]);
                taxInfoCell.stylesAndTotalPriceModel = _stylesAndTotalPriceModel;
                taxInfoCell.currentYYOrderInfoModel = _currentYYOrderInfoModel;
                taxInfoCell.moneyType = [_currentYYOrderInfoModel.curType integerValue];
                taxInfoCell.viewType = 3;
                taxInfoCell.spaceViewType = 1;
                [taxInfoCell updateUI];
                return taxInfoCell;
            }else{

                UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"YYOrderNullCell"];
                if(cell == nil){
                    cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"YYOrderNullCell"];
                }
                return cell;

            }
        }
    }else if([self getSectionsNum] == (indexPath.section + 1)){

        YYBuyerInfoRemarkCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"YYBuyerInfoRemarkCell" forIndexPath:indexPath];
        NSString *tmpOrderCode = @"0";
        if(_currentYYOrderInfoModel.orderCode){
            tmpOrderCode = _currentYYOrderInfoModel.orderCode;
        }

        NSString *tmpOrderCreateTime = getShowDateByFormatAndTimeInterval(@"yyyy/MM/dd HH:mm:ss",[_currentYYOrderInfoModel.orderCreateTime stringValue]);
        NSString *tmpOrderDescription =((_currentYYOrderInfoModel.orderDescription!=nil && _currentYYOrderInfoModel.orderDescription.length > 0)?_currentYYOrderInfoModel.orderDescription:NSLocalizedString(@"暂无备注" ,nil));
        [cell updateUI:@[tmpOrderCode,tmpOrderCreateTime,tmpOrderDescription]];
        return cell;
    }else{
        static NSString *CellIdentifier = @"YYNewStyleDetailCell";
        YYNewStyleDetailCell *cell   =  [_tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if(!cell){
            UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"OrderDetail" bundle:[NSBundle mainBundle]];
            YYCustomCellTableViewController *customCellTableViewController = [storyboard instantiateViewControllerWithIdentifier:@"YYCustomCellTableViewController"];
            cell = [customCellTableViewController.tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        }
        if (_currentYYOrderInfoModel && _currentYYOrderInfoModel.groups && [_currentYYOrderInfoModel.groups count] > 0) {
            YYOrderOneInfoModel *orderOneInfoModel = _currentYYOrderInfoModel.groups[indexPath.section - 1];
            if (orderOneInfoModel.styles && [orderOneInfoModel.styles count] > 0) {
                YYOrderStyleModel *orderStyleModel = [orderOneInfoModel.styles objectAtIndex:indexPath.row];
                orderStyleModel.curType = _currentYYOrderInfoModel.curType;
                YYOrderSeriesModel *orderSeriesModel = self.currentYYOrderInfoModel.seriesMap[[orderStyleModel.seriesId stringValue]];
                cell.orderStyleModel = orderStyleModel;
                cell.orderOneInfoModel = orderOneInfoModel;
                cell.orderSeriesModel = orderSeriesModel;
            }
        }
        NSInteger transStatus = getOrderTransStatus(self.currentYYOrderTransStatusModel.designerTransStatus, self.currentYYOrderTransStatusModel.buyerTransStatus);
        if(transStatus == YYOrderCode_DELIVERING){
            cell.isReceived = YES;
        }else{
            cell.isReceived = NO;
        }
        cell.menuData = _menuData;
        cell.showRemarkButton = YES;
        cell.isModifyNow = 0;
        cell.delegate = self;
        cell.indexPath = indexPath;
        cell.selectTaxType = getPayTaxTypeFormServiceNew(ws.menuData,[ws.currentYYOrderInfoModel.taxRate integerValue]);
        [cell updateUI];
        return cell;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section == 0) {
        NSInteger orderStatus = getOrderTransStatus(self.currentYYOrderTransStatusModel.designerTransStatus, self.currentYYOrderTransStatusModel.buyerTransStatus);
        if(indexPath.row == 0){
            if(self.currentYYOrderInfoModel!= nil){
                if([self.currentYYOrderInfoModel.closeReqStatus integerValue] == -1){
                    orderStatus = YYOrderCode_CLOSE_REQ;
                }
                return [YYOrderStatusCell cellHeight:orderStatus];
            }else{
                return 0.1;
            }
        }else if(indexPath.row == 1){
            if(self.currentYYOrderInfoModel != nil && (orderStatus == YYOrderCode_CLOSE_REQ || [self.currentYYOrderInfoModel.closeReqStatus integerValue] == -1)){
                return 76;
            }
            return 0.1;
        }else if(indexPath.row == 2){
            if(self.paymentNoteList != nil && orderStatus >= YYOrderCode_NEGOTIATION){
                if([self.currentYYOrderInfoModel.closeReqStatus integerValue] == -1){
                    return [YYOrderMoneyLogCell cellHeight:self.paymentNoteList.result tranStatus:YYOrderCode_CLOSE_REQ isPaylistShow:self.isPaylistShow];
                }
                return [YYOrderMoneyLogCell cellHeight:self.paymentNoteList.result tranStatus:orderStatus isPaylistShow:self.isPaylistShow];
            }else{
                return 0.1;
            }
        }else if(indexPath.row == 3){
            return 0.1;
        }else if(indexPath.row == 4){
            YYOrderBuyerAddress *buyerAddress = _currentYYOrderInfoModel.buyerAddress;
            NSString *addressStr = @"";
            if (buyerAddress) {
                addressStr = getBuyerAddressStr_phone(buyerAddress);
            }
            return [YYBuyerInfoCell1 getCellHeight:addressStr];
        }else{

            if(indexPath.row == 5 && _currentYYOrderInfoModel.packageStat){
                return [YYOrderPackageInfoCell cellHeight];
            }

            if(indexPath.row == (_currentYYOrderInfoModel.packageStat ? 6 : 5)){
                NSInteger moneyType = [_currentYYOrderInfoModel.curType integerValue];
                BOOL needTaxView = NO;
                if(needPayTaxView(moneyType)){
                    needTaxView = YES;
                }
                BOOL needDiscountView = YES;
                return [YYOrderTaxInfoCell CellHeight:needTaxView :needDiscountView];
            }

            return 0.1;

        }
    }else if([self getSectionsNum] == (indexPath.section + 1)){
        NSString *tmpOrderDescription =(_currentYYOrderInfoModel.orderDescription?_currentYYOrderInfoModel.orderDescription:@"");
        return [YYBuyerInfoRemarkCell getCellHeight:tmpOrderDescription];
    }else{
        NSInteger styleBuyedSizeCount = 0;
        NSInteger styleTotalNum = 0;
        YYOrderOneInfoModel *orderOneInfoModel =  [_currentYYOrderInfoModel.groups objectAtIndex:indexPath.section - 1];
        if (orderOneInfoModel && indexPath.row < [orderOneInfoModel.styles count]) {
            YYOrderStyleModel *styleModel = [orderOneInfoModel.styles objectAtIndex:indexPath.row];
            if (styleModel.colors
                && [styleModel.colors count] > 0) {
                for (int i=0; i<[styleModel.colors count]; i++) {
                    YYOrderOneColorModel *orderOneColorModel = [styleModel.colors objectAtIndex:i];

                    BOOL isColorSelect = [orderOneColorModel.isColorSelect boolValue];

                    //isModifyNow 0 没有修改
                    if(isColorSelect){
                        styleBuyedSizeCount += 1;
                    }else{
                        //判断amount是不是大于0
                        for (YYOrderSizeModel *sizeModel in orderOneColorModel.sizes) {
                            if([sizeModel.amount integerValue] > 0){
                                styleBuyedSizeCount ++;
                            }
                        }
                    }

                    for (YYOrderSizeModel *sizeModel in orderOneColorModel.sizes) {
                        if([sizeModel.amount integerValue] > 0){
                            styleTotalNum += [sizeModel.amount integerValue];
                        }
                    }
                }
            }
            BOOL showMinAmount = (styleTotalNum < [styleModel.orderAmountMin integerValue]);
            return [YYNewStyleDetailCell CellHeight:styleBuyedSizeCount showHelpFlag:showMinAmount showTopHeader:[orderOneInfoModel isInStock] showBottomFooter:YES];
        }
        return [YYNewStyleDetailCell CellHeight:styleBuyedSizeCount showHelpFlag:NO showTopHeader:[orderOneInfoModel isInStock] showBottomFooter:YES];
    }
}


- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    if([self getSectionsNum] == (section + 1)){
        UIView *tmpHead = [[UIView alloc] init];
        tmpHead.backgroundColor = [UIColor lightGrayColor];
        return tmpHead;
    }else if (section != 0) {
        YYOrderOneInfoModel *orderOneInfoModel =  [_currentYYOrderInfoModel.groups objectAtIndex:section - 1];
        if (![orderOneInfoModel isInStock]) {
            static NSString *CellIdentifier = @"YYOrderDetailSectionHead";
            
            UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"OrderDetail" bundle:[NSBundle mainBundle]];
            YYCustomCellTableViewController *customCellTableViewController = [storyboard instantiateViewControllerWithIdentifier:@"YYCustomCellTableViewController"];
            YYOrderOneInfoModel *orderOneInfoModel =  [_currentYYOrderInfoModel.groups objectAtIndex:section- 1];
            
            YYOrderDetailSectionHead *sectionHead = [customCellTableViewController.tableView dequeueReusableCellWithIdentifier:CellIdentifier];
            sectionHead.orderOneInfoModel = orderOneInfoModel;
            sectionHead.isHiddenSelectDateView = YES;
            [sectionHead updateUI];
            YYSelecteDateView *selecteDateView = (YYSelecteDateView *)[sectionHead viewWithTag:90008];
            sectionHead.contentView.backgroundColor = [UIColor whiteColor];
            selecteDateView.backgroundColor = [UIColor whiteColor];
            return sectionHead;
        } else {
            return nil;
        }
    }else {
        return nil;
    }

}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    if (section == 0) {
        return 0.1;
    }else if([self getSectionsNum] == (section + 1)){
        return 0.1;
    }else{
        YYOrderOneInfoModel *orderOneInfoModel =  [_currentYYOrderInfoModel.groups objectAtIndex:section - 1];
        if ([orderOneInfoModel isInStock]) {
            return 0.1;
        } else {
            return 40;
        }
    }
}

#pragma mark - --------------自定义代理/block----------------------
#pragma mark -YYTableCellDelegate
-(void)btnClick:(NSInteger)row section:(NSInteger)section andParmas:(NSArray *)parmas{
    NSString *type = [parmas objectAtIndex:0];
    if([type isEqualToString:@"status"]){

        //已发货
        NSIndexPath *indexPath =  [NSIndexPath indexPathForRow:row inSection:section];
        [self updateTransStatusWithIndexPath:indexPath];

    }else if ([type isEqualToString:@"confirmOrder"]){

        //确认订单
        NSIndexPath *indexPath =  [NSIndexPath indexPathForRow:row inSection:section];
        [self confirmOrderWithIndexPath:indexPath];

    }else if ([type isEqualToString:@"refuseOrder"]){

        //拒绝确认
        NSIndexPath *indexPath =  [NSIndexPath indexPathForRow:row inSection:section];
        [self refuseOrderWithIndexPath:indexPath];

    }else if([type isEqualToString:@"paylog"]){

        //添加收款记录
        [self addPaylogRecord];

    }else if([type isEqualToString:@"payloglist"]){

        //跳转付款记录页面
        [self showOrderPayLogList];

    }else if([type isEqualToString:@"reBuildOrder"]){

        //重新建立订单
        [self reBuildOrder];

    }else if([type isEqualToString:@"cancelReqClose"]){

        //撤销申请
        NSIndexPath *indexPath =  [NSIndexPath indexPathForRow:row inSection:section];
        [self cancelReqCloseWithIndexPath:indexPath];

    }else if([type isEqualToString:@"refuseReqClose"]){

        //我方交易继续
        NSIndexPath *indexPath =  [NSIndexPath indexPathForRow:row inSection:section];
        [self refuseReqCloseWithIndexPath:indexPath];

    }else if([type isEqualToString:@"agreeReqClose"]){

        //同意关闭交易
        NSIndexPath *indexPath =  [NSIndexPath indexPathForRow:row inSection:section];
        [self agreeReqCloseWithIndexPath:indexPath];

    }else if([type isEqualToString:@"paylistShow"]){

        self.isPaylistShow =  (self.isPaylistShow == 0?1:0);
        [self.tableView reloadData];

    }else if([type isEqualToString:@"orderHelp"]){

        //订单帮助
        [self showOrderHelp];

    }else if([type isEqualToString:@"orderCloseReqDeal"]){

        //订单关闭请求
        [self showOrderCloseReqDeal];

    }else if([type isEqualToString:@"brandInfo"]){

        //设计师主页
        [self showBrandInfo];

    }else if ([type isEqualToString:@"styleInfo"]){

        //款式详情
        NSIndexPath *indexPath =  [NSIndexPath indexPathForRow:row inSection:section];
        [self showStyleInfoWithIndexPath:indexPath];

    }else if([type isEqualToString:@"styleRemark"]){

        //款式备注
        [self styleRemark:[parmas objectAtIndex:1]];

    }
}
#pragma mark -YYTableCellDelegate-Method
//确认订单
-(void)confirmOrderWithIndexPath:(NSIndexPath *)indexPath{
    NSLog(@"confirmOrder");
    WeakSelf(ws);
    CMAlertView *alertView = [[CMAlertView alloc] initWithTitle:NSLocalizedString(@"确认此订单？", nil) message:NSLocalizedString(@"确认后将无法修改订单，是否确认该订单？",nil) needwarn:NO delegate:nil cancelButtonTitle:NSLocalizedString(@"取消",nil) otherButtonTitles:@[NSLocalizedString(@"确认",nil)]];
    [alertView setAlertViewBlock:^(NSInteger selectedIndex){
        if (selectedIndex == 1) {
            [YYOrderApi confirmOrderByOrderCode:ws.currentYYOrderInfoModel.orderCode andBlock:^(YYRspStatusAndMessage *rspStatusAndMessage, NSError *error) {
                if(rspStatusAndMessage.status == YYReqStatusCode100){
                    [ws refreshOrder];
                    [YYToast showToastWithTitle:NSLocalizedString(@"订单已确认", nil) andDuration:kAlertToastDuration];
                }else{
                    [YYToast showToastWithTitle:rspStatusAndMessage.message andDuration:kAlertToastDuration];
                }
            }];
        }
    }];
    [alertView show];
}
//拒绝确认订单
-(void)refuseOrderWithIndexPath:(NSIndexPath *)indexPath{
    NSLog(@"refuseOrder");
    WeakSelf(ws);
    CMAlertView *alertView = [[CMAlertView alloc] initRefuseOrderReasonWithTitle:NSLocalizedString(@"请填写拒绝原因", nil) message:nil otherButtonTitles:@[NSLocalizedString(@"提交",nil)]];
    [alertView setAlertViewSubmitBlock:^(NSString *reson) {
        NSLog(@"准备提交");
        [YYOrderApi refuseOrderByOrderCode:ws.currentYYOrderInfoModel.orderCode reason:reson andBlock:^(YYRspStatusAndMessage *rspStatusAndMessage, NSError *error) {
            if(rspStatusAndMessage.status == YYReqStatusCode100){
                [ws refreshOrder];
                [YYToast showToastWithTitle:NSLocalizedString(@"已提交", nil) andDuration:kAlertToastDuration];
            }else{
                [YYToast showToastWithTitle:rspStatusAndMessage.message andDuration:kAlertToastDuration];
            }
        }];
    }];
    [alertView show];
}
//updateTrans 已发货
-(void)updateTransStatusWithIndexPath:(NSIndexPath *)indexPath{
    WeakSelf(ws);
    NSString *orderCode = _currentYYOrderInfoModel.orderCode;
    __block NSString *blockOrderCode = orderCode;
    NSInteger transStatus = getOrderTransStatus(_currentYYOrderTransStatusModel.designerTransStatus, _currentYYOrderTransStatusModel.buyerTransStatus);
    NSInteger nextTransStatus = getOrderNextStatus(transStatus,_currentOrderConnStatus);

    NSString *oprateStr = getOrderStatusBtnName_buyer(nextTransStatus);
    CMAlertView *alertView = [[CMAlertView alloc] initWithTitle:[NSString stringWithFormat:@"%@吗？",oprateStr] message:nil needwarn:NO delegate:nil cancelButtonTitle:NSLocalizedString(@"取消",nil) otherButtonTitles:@[[NSString stringWithFormat:@"%@|000000",oprateStr]]];

    alertView.specialParentView = self.view;

    __block NSInteger blockStatus = nextTransStatus;
    [alertView setAlertViewBlock:^(NSInteger selectedIndex){
        if (selectedIndex == 1) {
            [YYOrderApi updateTransStatus:blockOrderCode statusCode:nextTransStatus andBlock:^(YYRspStatusAndMessage *rspStatusAndMessage, NSError *error) {
                if(rspStatusAndMessage.status == YYReqStatusCode100){

                    ws.currentYYOrderTransStatusModel.designerTransStatus = [[NSNumber alloc] initWithInteger:blockStatus];
                    ws.currentYYOrderTransStatusModel.buyerTransStatus = [[NSNumber alloc] initWithInteger:blockStatus];
                    NSTimeInterval time = [[NSDate date] timeIntervalSince1970]*1000;
                    ws.currentYYOrderTransStatusModel.operationTime = [NSNumber numberWithLongLong:time];

                    ws.currentYYOrderInfoModel.designerOrderStatus = [[NSNumber alloc] initWithInteger:blockStatus];
                    ws.currentYYOrderInfoModel.buyerOrderStatus = [[NSNumber alloc] initWithInteger:blockStatus];

                    [ws.tableView reloadData];
                    [YYToast showToastWithTitle:rspStatusAndMessage.message andDuration:kAlertToastDuration];
                }
            }];
        }
    }];
    [alertView show];
}
//添加收款记录
-(void)addPaylogRecord{
    WeakSelf(ws);
    if([_paymentNoteList.hasGiveRate floatValue] != 100.f){

        BOOL isNeedRefund = NO;
        if([_paymentNoteList.hasGiveRate floatValue] > 100.f){
            isNeedRefund = YES;
        }

        NSString *orderCode = _currentYYOrderInfoModel.orderCode;
        __block NSString *blockOrderCode = orderCode;
        NSString *brandLogo = (ws.currentYYOrderInfoModel.brandLogo?ws.currentYYOrderInfoModel.brandLogo:@"");
        NSInteger designerId = (ws.currentYYOrderInfoModel.designerId?[ws.currentYYOrderInfoModel.designerId integerValue]:0);

        [[YYYellowPanelManage instance] showOrderAddMoneyLogPanel:@"Order" andIdentifier:@"YYOrderAddMoneyLogController" orderCode:blockOrderCode params:@[brandLogo,@(designerId)] totalMoney:[_currentYYOrderInfoModel.finalTotalPrice doubleValue] moneyType:[_currentYYOrderInfoModel.curType integerValue] isNeedRefund:isNeedRefund parentView:self andCallBack:^(NSString *orderCode, NSNumber *totalPercent) {

            [ws loadPaymentNoteList:blockOrderCode];

        }];
    }
}
//重新建立订单
-(void)reBuildOrder{
    YYOrderInfoModel *orderInfoModel = [[YYOrderInfoModel alloc] initWithDictionary:[_currentYYOrderInfoModel toDictionary] error:nil];
    [YYOrderApi getOrderByOrderCode:orderInfoModel.orderCode isForReBuildOrder:YES andBlock:^(YYRspStatusAndMessage *rspStatusAndMessage, YYOrderInfoModel *orderInfoModel, NSError *error) {
        AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
        if (rspStatusAndMessage.status == YYReqStatusCode100) {
            orderInfoModel.orderCode = @"";
            orderInfoModel.realBuyerId = 0;
            orderInfoModel.buyerEmail = @"";
            orderInfoModel.buyerName = @"";
            orderInfoModel.payApp = @"";
            orderInfoModel.deliveryChoose = @"";
            orderInfoModel.businessCard = @"";
            orderInfoModel.designerOrderStatus = [[NSNumber alloc] initWithInt:YYOrderCode_NEGOTIATION];
            orderInfoModel.buyerOrderStatus = [[NSNumber alloc] initWithInt:YYOrderCode_NEGOTIATION];
            orderInfoModel.orderConnStatus = @(YYOrderConnStatusUnconfirmed);
            orderInfoModel.orderCreateTime = nil;
            [appDelegate showBuildOrderViewController:orderInfoModel parent:self isCreatOrder:YES isReBuildOrder:YES isAppendOrder:NO modifySuccess:^(){
                [[NSNotificationCenter defaultCenter] postNotificationName:kShowOrderListNotification object:nil];
            }];
        }else{
            [YYToast showToastWithView:appDelegate.mainViewController.view title:rspStatusAndMessage.message andDuration:kAlertToastDuration];
        }
    }];
}
//撤销申请
-(void)cancelReqCloseWithIndexPath:(NSIndexPath *)indexPath{
    WeakSelf(ws);
    NSString *orderCode = _currentYYOrderInfoModel.orderCode;
    __block NSString *blockOrderCode = orderCode;
    CMAlertView *alertView = [[CMAlertView alloc] initWithTitle:NSLocalizedString(@"是否确认撤销“取消订单”申请？",nil) message:nil needwarn:NO delegate:nil cancelButtonTitle:NSLocalizedString(@"否",nil) otherButtonTitles:@[NSLocalizedString(@"是",nil)]];
    alertView.specialParentView = self.navigationController.topViewController.view ;
    [alertView setAlertViewBlock:^(NSInteger selectedIndex){
        if (selectedIndex == 1) {
            [YYOrderApi revokeOrderCloseRequest:blockOrderCode andBlock:^(YYRspStatusAndMessage *rspStatusAndMessage, NSError *error) {
                if(rspStatusAndMessage.status == YYReqStatusCode100){
                    [ws refreshOrder];
                }
                [YYToast showToastWithTitle:rspStatusAndMessage.message andDuration:kAlertToastDuration];
            }];
        }
    }];
    [alertView show];
}
//我方交易继续
-(void)refuseReqCloseWithIndexPath:(NSIndexPath *)indexPath{
    WeakSelf(ws);
    NSString *orderCode = _currentYYOrderInfoModel.orderCode;
    __block NSString *blockOrderCode = orderCode;
    CMAlertView *alertView = [[CMAlertView alloc] initWithTitle:NSLocalizedString(@"确认拒绝已取消申请",nil) message:nil needwarn:NO delegate:nil cancelButtonTitle:NSLocalizedString(@"取消",nil) otherButtonTitles:@[NSLocalizedString(@"确认",nil)]];
    alertView.specialParentView = self.navigationController.topViewController.view ;
    [alertView setAlertViewBlock:^(NSInteger selectedIndex){
        if (selectedIndex == 1) {
            [YYOrderApi dealOrderCloseRequest:blockOrderCode isAgree:@"false" andBlock:^(YYRspStatusAndMessage *rspStatusAndMessage, NSError *error) {
                if(rspStatusAndMessage.status == YYReqStatusCode100){
                    [ws refreshOrder];
                }
                [ws.navigationController popViewControllerAnimated:YES];
                [YYToast showToastWithTitle:rspStatusAndMessage.message andDuration:kAlertToastDuration];
            }];
        }
    }];
    [alertView show];
}
//同意关闭交易
-(void)agreeReqCloseWithIndexPath:(NSIndexPath *)indexPath{
    WeakSelf(ws);
    NSString *orderCode = _currentYYOrderInfoModel.orderCode;
    __block NSString *blockOrderCode = orderCode;
    CMAlertView *alertView = [[CMAlertView alloc] initWithTitle:NSLocalizedString(@"确认同意已取消申请",nil) message:nil needwarn:NO delegate:nil cancelButtonTitle:NSLocalizedString(@"取消",nil) otherButtonTitles:@[NSLocalizedString(@"确认",nil)]];
    alertView.specialParentView = self.navigationController.topViewController.view ;
    [alertView setAlertViewBlock:^(NSInteger selectedIndex){
        if (selectedIndex == 1) {
            [YYOrderApi dealOrderCloseRequest:blockOrderCode isAgree:@"true" andBlock:^(YYRspStatusAndMessage *rspStatusAndMessage, NSError *error) {
                if(rspStatusAndMessage.status == YYReqStatusCode100){
                    [ws refreshOrder];
                }
                [ws.navigationController popViewControllerAnimated:YES];
                [YYToast showToastWithTitle:rspStatusAndMessage.message andDuration:kAlertToastDuration];
            }];
        }
    }];
    [alertView show];
}
//设计师主页
-(void)showBrandInfo{
    if(_currentYYOrderInfoModel && _currentYYOrderInfoModel.brandName && _currentYYOrderInfoModel.brandLogo){

        AppDelegate *appdelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
        NSString *brandName = self.currentYYOrderInfoModel.brandName;
        NSString *logoPath = self.currentYYOrderInfoModel.brandLogo;
        [appdelegate showBrandInfoViewController:self.currentYYOrderInfoModel.designerId WithBrandName:brandName WithLogoPath:logoPath parentViewController:self WithHomePageBlock:nil WithSelectedValue:nil];

    }
}
//款式详情
-(void)showStyleInfoWithIndexPath:(NSIndexPath *)indexPath{
    if (_currentYYOrderInfoModel && _currentYYOrderInfoModel.groups && [_currentYYOrderInfoModel.groups count] > 0) {
        YYOrderOneInfoModel *orderOneInfoModel = _currentYYOrderInfoModel.groups[indexPath.section - 1];
        if (orderOneInfoModel.styles && [orderOneInfoModel.styles count] > 0) {
            WeakSelf(ws);
            YYOrderStyleModel *orderStyleModel = [orderOneInfoModel.styles objectAtIndex:indexPath.row];

            [YYOpusApi getStyleInfoByStyleId:[orderStyleModel.styleId longValue] orderCode:nil andBlock:^(YYRspStatusAndMessage *rspStatusAndMessage, YYStyleInfoModel *styleInfoModel, NSError *error) {
                if (rspStatusAndMessage.status != YYReqStatusCode100) {
                    [YYToast showToastWithView:ws.view title:rspStatusAndMessage.message andDuration:kAlertToastDuration];
                }else{
                    if(ws.currentYYOrderInfoModel.brandName && ws.currentYYOrderInfoModel.brandLogo){
                        AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;

                        [appDelegate showStyleInfoViewController:ws.currentYYOrderInfoModel oneInfoModel:orderOneInfoModel orderStyleModel:orderStyleModel parentViewController:ws];
                    }
                }
            }];
        }
    }
}
//款式备注
-(void)styleRemark:(NSString *)remarkStr{
    float uiWidth = SCREEN_WIDTH-40;
    float boxWidth = 4;
    float contentSpace = 22;
    float txtHeight = getTxtHeight(uiWidth-(boxWidth+contentSpace)*2,remarkStr,@{NSFontAttributeName:[UIFont systemFontOfSize:13]});
    float uiHeight = 25+15+10+txtHeight+30;

    UIView *containerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, uiWidth, uiHeight)];
    containerView.backgroundColor = [UIColor whiteColor];
    containerView.layer.borderColor = [UIColor blackColor].CGColor;
    containerView.layer.borderWidth = boxWidth;
    UILabel *title = [[UILabel alloc] initWithFrame:CGRectMake(0, 25, uiWidth, 15)];
    title.textAlignment = NSTextAlignmentCenter;
    title.font = [UIFont systemFontOfSize:15];
    title.textColor = [UIColor blackColor];
    title.text = NSLocalizedString(@"款式备注",nil);
    UILabel *content = [[UILabel alloc] initWithFrame:CGRectMake(contentSpace, CGRectGetMaxY(title.frame)+10, uiWidth-(boxWidth+contentSpace)*2, txtHeight)];
    content.textAlignment = NSTextAlignmentLeft;
    content.font = [UIFont systemFontOfSize:13];
    content.textColor = [UIColor colorWithHex:@"919191"];
    content.text = remarkStr;
    content.numberOfLines = 0;
    [containerView addSubview:title];
    [containerView addSubview:content];

    _remarkAlert = [[CMAlertView alloc] initWithViews:@[containerView] imageFrame:CGRectMake(0, 0, uiWidth, uiHeight) bgClose:NO];
    [_remarkAlert show];
}
//订单帮助
-(void)showOrderHelp{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Order" bundle:[NSBundle mainBundle]];
    YYOrderHelpViewController *orderHelpViewController = [storyboard instantiateViewControllerWithIdentifier:@"YYOrderHelpViewController"];
    [self.navigationController pushViewController:orderHelpViewController animated:YES];

    WeakSelf(ws);
    [orderHelpViewController setCancelButtonClicked:^(){
        [ws.navigationController popViewControllerAnimated:YES];
    }];
}
//订单关闭请求
-(void)showOrderCloseReqDeal{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Order" bundle:[NSBundle mainBundle]];
    YYOrderOtherCloseReqDealViewController *orderCloseReqDealViewController = [storyboard instantiateViewControllerWithIdentifier:@"YYOrderOtherCloseReqDealViewController"];
    self.orderCloseReqDealViewController = orderCloseReqDealViewController;
    [self.navigationController pushViewController:orderCloseReqDealViewController animated:YES];

    WeakSelf(ws);
    [orderCloseReqDealViewController setCancelButtonClicked:^(){
        [ws.navigationController popViewControllerAnimated:YES];
        ws.orderCloseReqDealViewController = nil;
    }];
    [orderCloseReqDealViewController setReqDealButtonClicked:^(NSArray *value){
        [self btnClick:-1 section:-1 andParmas:value];

    }];
}
//跳转付款记录页面
-(void)showOrderPayLogList{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Order" bundle:[NSBundle mainBundle]];
    YYOrderPayLogViewController *orderPayLogViewController = [storyboard instantiateViewControllerWithIdentifier:@"YYOrderPayLogViewController"];
    orderPayLogViewController.currentYYOrderInfoModel = _currentYYOrderInfoModel;
    [self.navigationController pushViewController:orderPayLogViewController animated:YES];

    WeakSelf(ws);
    __block NSString *blockOrderCode = _currentYYOrderInfoModel.orderCode;
    [orderPayLogViewController setCancelButtonClicked:^(){
        [ws loadPaymentNoteList:blockOrderCode];
        [ws.navigationController popViewControllerAnimated:YES];
    }];
}
#pragma mark - --------------自定义响应----------------------
- (void)goBack {
    if(self.cancelButtonClicked){
        self.cancelButtonClicked();
    }
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)chatBtnHandler:(id)sender {
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Message" bundle:[NSBundle mainBundle]];
    YYMessageDetailViewController *messageViewController = [storyboard instantiateViewControllerWithIdentifier:@"YYMessageDetailViewController"];
    messageViewController.userlogo =  self.currentYYOrderInfoModel.brandLogo;
    messageViewController.userEmail = @"";
    messageViewController.userId = self.currentYYOrderInfoModel.designerId;
    messageViewController.brandName = self.currentYYOrderInfoModel.brandName;
    WeakSelf(ws);
    [messageViewController setCancelButtonClicked:^(void){
        [ws.navigationController popViewControllerAnimated:YES];
        [YYMessageDetailViewController markAsRead];
    }];
    [self.navigationController pushViewController:messageViewController animated:YES];

}
-(void)showMenuUI:(id)sender{
    if(self.currentYYOrderTransStatusModel){
        NSInteger menuUIWidth = 137;
        if([LanguageManager isEnglishLanguage]){
            menuUIWidth = 175;
        }else{
            menuUIWidth = 137;
        }
        NSArray *menuData;
        NSArray *menuIconData;
        NSInteger needAppendOrderMenu = 0;
        BOOL isForcedDelivery = [_currentYYOrderInfoModel.isForcedDelivery boolValue];
        
        if([self.currentYYOrderInfoModel.isAppend integerValue] == 0){
            if([self.currentYYOrderInfoModel.hasAppend integerValue] == 0){
                if(self.currentOrderConnStatus == YYOrderConnStatusNotFound ||self.currentOrderConnStatus == YYOrderConnStatusUnconfirmed || self.currentOrderConnStatus == YYOrderConnStatusLinked ){
                    needAppendOrderMenu = 1;//追单
                }
            }else{
                needAppendOrderMenu = 2;//查看追单
            }
        }else{
            if(self.currentYYOrderInfoModel.originalOrderCode ){
                needAppendOrderMenu = 3;//查看原始订单
            }
        }

        NSInteger transStatus = getOrderTransStatus(self.currentYYOrderTransStatusModel.designerTransStatus, self.currentYYOrderTransStatusModel.buyerTransStatus);

        if(transStatus == YYOrderCode_CLOSE_REQ || [self.currentYYOrderInfoModel.closeReqStatus integerValue] == -1){
            //交易关闭
            menuData = @[NSLocalizedString(@"修改记录",nil)];
            menuIconData = @[@"download_update"];

            NSMutableArray *tmpMenuData = [[NSMutableArray alloc] init];
            NSMutableArray *tmpMenuIconData = [[NSMutableArray alloc] init];
            if(isForcedDelivery){
                [tmpMenuData addObject:NSLocalizedString(@"初始订单", nil)];
                [tmpMenuIconData addObject:@"originalOrder"];
            }
            [tmpMenuData addObjectsFromArray:@[NSLocalizedString(@"修改记录",nil)]];
            [tmpMenuIconData addObjectsFromArray:@[@"download_update"]];
            menuData = [tmpMenuData copy];
            menuIconData = [tmpMenuIconData copy];

        }else if(transStatus == YYOrderCode_NEGOTIATION){
            //已下单
            BOOL isDesignerConfrim = [_currentYYOrderInfoModel isDesignerConfrim];
            BOOL isBuyerConfrim = [_currentYYOrderInfoModel isBuyerConfrim];
            if(!isBuyerConfrim&&!isDesignerConfrim){
                //双方都未确认
                if(needAppendOrderMenu == 3){
                    menuData = @[NSLocalizedString(@"查看原订单",nil),NSLocalizedString(@"修改订单_short",nil),NSLocalizedString(@"取消订单_short",nil),NSLocalizedString(@"修改记录",nil)];
                    menuIconData = @[@"originorder",@"pencil1",@"cancel",@"download_update"];
                }else{
                    menuData = @[NSLocalizedString(@"修改订单_short",nil),NSLocalizedString(@"取消订单_short",nil),NSLocalizedString(@"修改记录",nil)];
                    menuIconData = @[@"pencil1",@"cancel",@"download_update"];
                }
            }else{
                if(needAppendOrderMenu == 3){
                    menuData = @[NSLocalizedString(@"查看原订单",nil),NSLocalizedString(@"修改记录",nil)];
                    menuIconData = @[@"originorder",@"download_update"];
                }else{
                    menuData = @[NSLocalizedString(@"修改记录",nil)];
                    menuIconData = @[@"download_update"];
                }
            }
        }else if(transStatus == YYOrderCode_NEGOTIATION_DONE || transStatus == YYOrderCode_CONTRACT_DONE){
            //已确认
            if(needAppendOrderMenu ==1){
                menuData = @[NSLocalizedString(@"追单补货",nil),NSLocalizedString(@"取消订单",nil),NSLocalizedString(@"修改记录",nil)];
                menuIconData = @[@"append",@"cancel",@"download_update"];
            }else if(needAppendOrderMenu ==2){
                menuData = @[NSLocalizedString(@"查看追单",nil),NSLocalizedString(@"取消订单",nil),NSLocalizedString(@"修改记录",nil)];
                menuIconData = @[@"append",@"cancel",@"download_update"];
            }else if(needAppendOrderMenu ==3){
                menuData = @[NSLocalizedString(@"查看原订单",nil),NSLocalizedString(@"取消订单",nil),NSLocalizedString(@"修改记录",nil)];
                menuIconData = @[@"originorder",@"cancel",@"download_update"];
            }else{
                menuData = @[NSLocalizedString(@"取消订单",nil),NSLocalizedString(@"修改记录",nil)];
                menuIconData = @[@"cancel",@"download_update"];
            }
        }else if(transStatus == YYOrderCode_MANUFACTURE){
            //已生产
            if(needAppendOrderMenu == 1){
                menuData = @[NSLocalizedString(@"追单补货",nil),NSLocalizedString(@"取消订单",nil),NSLocalizedString(@"修改记录",nil)];
                menuIconData = @[@"append",@"cancel",@"download_update"];
            }else if(needAppendOrderMenu == 2){
                menuData = @[NSLocalizedString(@"查看追单",nil),NSLocalizedString(@"取消订单",nil),NSLocalizedString(@"修改记录",nil)];
                menuIconData = @[@"append",@"cancel",@"download_update"];
            }else if(needAppendOrderMenu == 3){
                menuData = @[NSLocalizedString(@"查看原订单",nil),NSLocalizedString(@"取消订单",nil),NSLocalizedString(@"修改记录",nil)];
                menuIconData = @[@"originorder",@"cancel",@"download_update"];
            }else{
                menuData = @[NSLocalizedString(@"取消订单",nil),NSLocalizedString(@"修改记录",nil)];
                menuIconData = @[@"cancel",@"download_update"];
            }
        }else if(transStatus == YYOrderCode_DELIVERING){
            //发货中
            if(needAppendOrderMenu == 1){
                menuData = @[NSLocalizedString(@"追单补货",nil),NSLocalizedString(@"修改记录",nil)];
                menuIconData = @[@"append",@"download_update"];
            }else if(needAppendOrderMenu == 2){
                menuData = @[NSLocalizedString(@"查看追单",nil),NSLocalizedString(@"修改记录",nil)];
                menuIconData = @[@"append",@"download_update"];
            }else if(needAppendOrderMenu == 3){
                menuData = @[NSLocalizedString(@"查看原订单",nil),NSLocalizedString(@"修改记录",nil)];
                menuIconData = @[@"originorder",@"download_update"];
            }else{
                menuData = @[NSLocalizedString(@"修改记录",nil)];
                menuIconData = @[@"download_update"];
            }
        }else if(transStatus == YYOrderCode_DELIVERY){
            //已发货
            NSMutableArray *tmpMenuData = [[NSMutableArray alloc] init];
            NSMutableArray *tmpMenuIconData = [[NSMutableArray alloc] init];
            if(isForcedDelivery){
                [tmpMenuData addObject:NSLocalizedString(@"初始订单", nil)];
                [tmpMenuIconData addObject:@"originalOrder"];
            }
            if(needAppendOrderMenu == 1){
                [tmpMenuData addObjectsFromArray:@[NSLocalizedString(@"追单补货",nil),NSLocalizedString(@"取消订单",nil),NSLocalizedString(@"修改记录",nil)]];
                [tmpMenuIconData addObjectsFromArray:@[@"append",@"cancel",@"download_update"]];
            }else if(needAppendOrderMenu == 2){
                [tmpMenuData addObjectsFromArray:@[NSLocalizedString(@"查看追单",nil),NSLocalizedString(@"取消订单",nil),NSLocalizedString(@"修改记录",nil)]];
                [tmpMenuIconData addObjectsFromArray:@[@"append",@"cancel",@"download_update"]];
            }else if(needAppendOrderMenu == 3){
                [tmpMenuData addObjectsFromArray:@[NSLocalizedString(@"查看原订单",nil),NSLocalizedString(@"取消订单",nil),NSLocalizedString(@"修改记录",nil)]];
                [tmpMenuIconData addObjectsFromArray:@[@"originorder",@"cancel",@"download_update"]];
            }else{
                [tmpMenuData addObjectsFromArray:@[NSLocalizedString(@"取消订单",nil),NSLocalizedString(@"修改记录",nil)]];
                [tmpMenuIconData addObjectsFromArray:@[@"cancel",@"download_update"]];
            }
            menuData = [tmpMenuData copy];
            menuIconData = [tmpMenuIconData copy];
        }else if(transStatus == YYOrderCode_RECEIVED){
            //已收货
            NSMutableArray *tmpMenuData = [[NSMutableArray alloc] init];
            NSMutableArray *tmpMenuIconData = [[NSMutableArray alloc] init];
            if(isForcedDelivery){
                [tmpMenuData addObject:NSLocalizedString(@"初始订单", nil)];
                [tmpMenuIconData addObject:@"originalOrder"];
            }
            if(needAppendOrderMenu == 1){
                [tmpMenuData addObjectsFromArray:@[NSLocalizedString(@"追单补货",nil),NSLocalizedString(@"修改记录",nil)]];
                [tmpMenuIconData addObjectsFromArray:@[@"append",@"download_update"]];
            }else if(needAppendOrderMenu == 2){
                [tmpMenuData addObjectsFromArray:@[NSLocalizedString(@"查看追单",nil),NSLocalizedString(@"修改记录",nil)]];
                [tmpMenuIconData addObjectsFromArray:@[@"append",@"download_update"]];
            }else if(needAppendOrderMenu == 3){
                [tmpMenuData addObjectsFromArray:@[NSLocalizedString(@"查看原订单",nil),NSLocalizedString(@"修改记录",nil)]];
                [tmpMenuIconData addObjectsFromArray:@[@"originorder",@"download_update"]];
            }else{
                [tmpMenuData addObjectsFromArray:@[NSLocalizedString(@"修改记录",nil)]];
                [tmpMenuIconData addObjectsFromArray:@[@"download_update"]];
            }
            menuData = [tmpMenuData copy];
            menuIconData = [tmpMenuIconData copy];
        }else if(transStatus == YYOrderCode_CANCELLED || transStatus == YYOrderCode_CLOSED){
            //已取消
            menuData = @[NSLocalizedString(@"修改记录",nil)];
            menuIconData = @[@"download_update"];

            NSMutableArray *tmpMenuData = [[NSMutableArray alloc] init];
            NSMutableArray *tmpMenuIconData = [[NSMutableArray alloc] init];
            if(isForcedDelivery){
                [tmpMenuData addObject:NSLocalizedString(@"初始订单", nil)];
                [tmpMenuIconData addObject:@"originalOrder"];
            }
            [tmpMenuData addObjectsFromArray:@[NSLocalizedString(@"修改记录",nil)]];
            [tmpMenuIconData addObjectsFromArray:@[@"download_update"]];
            menuData = [tmpMenuData copy];
            menuIconData = [tmpMenuIconData copy];
        }

        NSInteger menuUIHeight = 46 * menuData.count;

        CGPoint p = [self.menuBtn convertPoint:CGPointMake(CGRectGetWidth(self.menuBtn.frame), CGRectGetHeight(self.menuBtn.frame)) toView:self.view];
        WeakSelf(ws);
        [YYMenuPopView addPellTableViewSelectWithWindowFrame:CGRectMake(p.x-menuUIWidth+5, p.y, menuUIWidth, menuUIHeight) selectData:menuData images:menuIconData textAlignment:NSTextAlignmentLeft action:^(NSInteger index) {
            [ws menuBtnHandler:index];
        } animated:YES];
    }
}
- (kOrderMenuActionType )getOrderMenuTypeWithIndex:(NSInteger )index{

    NSInteger needAppendOrderMenu = 0;
    BOOL isForcedDelivery = [_currentYYOrderInfoModel.isForcedDelivery boolValue];
    if([self.currentYYOrderInfoModel.isAppend integerValue] == 0){
        if([self.currentYYOrderInfoModel.hasAppend integerValue] == 0){
            if(self.currentOrderConnStatus == YYOrderConnStatusNotFound ||self.currentOrderConnStatus == YYOrderConnStatusUnconfirmed || self.currentOrderConnStatus == YYOrderConnStatusLinked ){
                needAppendOrderMenu = 1;//追单
            }
        }else{
            needAppendOrderMenu = 2;//查看追单
        }
    }else{
        if(self.currentYYOrderInfoModel.originalOrderCode ){
            needAppendOrderMenu = 3;//查看原始订单
        }
    }

    NSInteger transStatus = getOrderTransStatus(self.currentYYOrderTransStatusModel.designerTransStatus, self.currentYYOrderTransStatusModel.buyerTransStatus);
    kOrderMenuActionType menuActionType = 0;
    if(transStatus == YYOrderCode_CLOSE_REQ || [self.currentYYOrderInfoModel.closeReqStatus integerValue] == -1){
        //交易关闭
        if(isForcedDelivery){
            if(index == 1){
                //原订单内容
                menuActionType = kOrderMenuActionType_originalOrderDetail;
            }else if(index == 2){
                //修改记录
                menuActionType = kOrderMenuActionType_modifyRecord;
            }
        }else{
            if(index == 1){
                //修改记录
                menuActionType = kOrderMenuActionType_modifyRecord;
            }
        }
    }else if(transStatus == YYOrderCode_NEGOTIATION){
        //已下单
        BOOL isDesignerConfrim = [_currentYYOrderInfoModel isDesignerConfrim];
        BOOL isBuyerConfrim = [_currentYYOrderInfoModel isBuyerConfrim];
        if(!isBuyerConfrim&&!isDesignerConfrim){
            //双方都未确认
            if(needAppendOrderMenu == 3){
                if(index == 1){
                    //查看原订单
                    menuActionType = kOrderMenuActionType_checkOriginalOrder;
                }else if(index == 2){
                    //修改订单
                    menuActionType = kOrderMenuActionType_modifyOrder;
                }else if(index == 3){
                    //取消订单
                    menuActionType = kOrderMenuActionType_cancelOrder;
                }else if(index == 4){
                    //修改记录
                    menuActionType = kOrderMenuActionType_modifyRecord;
                }
            }else{
                if(index == 1){
                    //修改订单
                    menuActionType = kOrderMenuActionType_modifyOrder;
                }else if(index == 2){
                    //取消订单
                    menuActionType = kOrderMenuActionType_cancelOrder;
                }else if(index == 3){
                    //修改记录
                    menuActionType = kOrderMenuActionType_modifyRecord;
                }
            }
        }else{
            if(needAppendOrderMenu == 3){
                if(index == 1){
                    //查看原订单
                    menuActionType = kOrderMenuActionType_checkOriginalOrder;
                }else if(index == 2){
                    //修改记录
                    menuActionType = kOrderMenuActionType_modifyRecord;
                }
            }else{
                if(index == 1){
                    //修改记录
                    menuActionType = kOrderMenuActionType_modifyRecord;
                }
            }
        }
    }else if(transStatus == YYOrderCode_NEGOTIATION_DONE || transStatus == YYOrderCode_CONTRACT_DONE){
        //已确认
        if(needAppendOrderMenu == 1){
            if(index == 1){
                //追单补货
                menuActionType = kOrderMenuActionType_appendOrder;
            }else if(index == 2){
                //取消订单
                menuActionType = kOrderMenuActionType_closeOrder;
            }else if(index == 3){
                //修改记录
                menuActionType = kOrderMenuActionType_modifyRecord;
            }
        }else if(needAppendOrderMenu == 2){
            if(index == 1){
                //查看追单
                menuActionType = kOrderMenuActionType_checkAppendOrder;
            }else if(index == 2){
                //取消订单
                menuActionType = kOrderMenuActionType_closeOrder;
            }else if(index == 3){
                //修改记录
                menuActionType = kOrderMenuActionType_modifyRecord;
            }
        }else if(needAppendOrderMenu == 3){
            if(index == 1){
                //查看原订单
                menuActionType = kOrderMenuActionType_checkOriginalOrder;
            }else if(index == 2){
                //取消订单
                menuActionType = kOrderMenuActionType_closeOrder;
            }else if(index == 3){
                //修改记录
                menuActionType = kOrderMenuActionType_modifyRecord;
            }
        }else{
            if(index == 1){
                //取消订单
                menuActionType = kOrderMenuActionType_closeOrder;
            }else if(index == 2){
                //修改记录
                menuActionType = kOrderMenuActionType_modifyRecord;
            }
        }
    }else if(transStatus == YYOrderCode_MANUFACTURE){
        //已生产
        if(needAppendOrderMenu == 1){
            if(index == 1){
                //追单补货
                menuActionType = kOrderMenuActionType_appendOrder;
            }else if(index == 2){
                //取消订单
                menuActionType = kOrderMenuActionType_closeOrder;
            }else if(index == 3){
                //修改记录
                menuActionType = kOrderMenuActionType_modifyRecord;
            }
        }else if(needAppendOrderMenu == 2){
            if(index == 1){
                //查看追单
                menuActionType = kOrderMenuActionType_checkAppendOrder;
            }else if(index == 2){
                //取消订单
                menuActionType = kOrderMenuActionType_closeOrder;
            }else if(index == 3){
                //修改记录
                menuActionType = kOrderMenuActionType_modifyRecord;
            }
        }else if(needAppendOrderMenu == 3){
            if(index == 1){
                //查看原订单
                menuActionType = kOrderMenuActionType_checkOriginalOrder;
            }else if(index == 2){
                //取消订单
                menuActionType = kOrderMenuActionType_closeOrder;
            }else if(index == 3){
                //修改记录
                menuActionType = kOrderMenuActionType_modifyRecord;
            }
        }else{
            if(index == 1){
                //取消订单
                menuActionType = kOrderMenuActionType_closeOrder;
            }else if(index == 2){
                //修改记录
                menuActionType = kOrderMenuActionType_modifyRecord;
            }
        }
    }else if(transStatus == YYOrderCode_DELIVERING){
        //发货中
        if(needAppendOrderMenu == 1){
            if(index == 1){
                //追单补货
                menuActionType = kOrderMenuActionType_appendOrder;
            }else if(index == 2){
                //修改记录
                menuActionType = kOrderMenuActionType_modifyRecord;
            }
        }else if(needAppendOrderMenu == 2){
            if(index == 1){
                //查看追单
                menuActionType = kOrderMenuActionType_checkAppendOrder;
            }else if(index == 2){
                //修改记录
                menuActionType = kOrderMenuActionType_modifyRecord;
            }
        }else if(needAppendOrderMenu == 3){
            if(index == 1){
                //查看原订单
                menuActionType = kOrderMenuActionType_checkOriginalOrder;
            }else if(index == 2){
                //修改记录
                menuActionType = kOrderMenuActionType_modifyRecord;
            }
        }else{
            if(index == 1){
                //修改记录
                menuActionType = kOrderMenuActionType_modifyRecord;
            }
        }
    }else if(transStatus == YYOrderCode_DELIVERY){
        //已发货
        NSInteger addIndex = 0;
        if(isForcedDelivery){
            if(index == 1){
                //原订单内容
                menuActionType = kOrderMenuActionType_originalOrderDetail;
            }
            addIndex = 1;
        }

        if(needAppendOrderMenu == 1){
            if(index == (1 + addIndex)){
                //追单补货
                menuActionType = kOrderMenuActionType_appendOrder;
            }else if(index == (2 + addIndex)){
                //取消订单
                menuActionType = kOrderMenuActionType_closeOrder;
            }else if(index == (3 + addIndex)){
                //修改记录
                menuActionType = kOrderMenuActionType_modifyRecord;
            }
        }else if(needAppendOrderMenu == 2){
            if(index == (1 + addIndex)){
                //查看追单
                menuActionType = kOrderMenuActionType_checkAppendOrder;
            }else if(index == (2 + addIndex)){
                //取消订单
                menuActionType = kOrderMenuActionType_closeOrder;
            }else if(index == (3 + addIndex)){
                //修改记录
                menuActionType = kOrderMenuActionType_modifyRecord;
            }
        }else if(needAppendOrderMenu == 3){
            if(index == (1 + addIndex)){
                //查看原订单
                menuActionType = kOrderMenuActionType_checkOriginalOrder;
            }else if(index == (2 + addIndex)){
                //取消订单
                menuActionType = kOrderMenuActionType_closeOrder;
            }else if(index == (3 + addIndex)){
                //修改记录
                menuActionType = kOrderMenuActionType_modifyRecord;
            }
        }else{
            if(index == (1 + addIndex)){
                //取消订单
                menuActionType = kOrderMenuActionType_closeOrder;
            }else if(index == (2 + addIndex)){
                //修改记录
                menuActionType = kOrderMenuActionType_modifyRecord;
            }
        }
    }else if(transStatus == YYOrderCode_RECEIVED){
        //已收货
        NSInteger addIndex = 0;
        if(isForcedDelivery){
            if(index == 1){
                //原订单内容
                menuActionType = kOrderMenuActionType_originalOrderDetail;
            }
            addIndex = 1;
        }

        if(needAppendOrderMenu == 1){
            if(index == (1 + addIndex)){
                //追单补货
                menuActionType = kOrderMenuActionType_appendOrder;
            }else if(index == (2 + addIndex)){
                //修改记录
                menuActionType = kOrderMenuActionType_modifyRecord;
            }
        }else if(needAppendOrderMenu == 2){
            if(index == (1 + addIndex)){
                //查看追单
                menuActionType = kOrderMenuActionType_checkAppendOrder;
            }else if(index == (2 + addIndex)){
                //修改记录
                menuActionType = kOrderMenuActionType_modifyRecord;
            }
        }else if(needAppendOrderMenu == 3){
            if(index == (1 + addIndex)){
                //查看原订单
                menuActionType = kOrderMenuActionType_checkOriginalOrder;
            }else if(index == (2 + addIndex)){
                //修改记录
                menuActionType = kOrderMenuActionType_modifyRecord;
            }
        }else{
            if(index == (1 + addIndex)){
                //修改记录
                menuActionType = kOrderMenuActionType_modifyRecord;
            }
        }
    }else if(transStatus == YYOrderCode_CANCELLED || transStatus == YYOrderCode_CLOSED){
        //已取消
        if(isForcedDelivery){
            if(index == 1){
                //原订单内容
                menuActionType = kOrderMenuActionType_originalOrderDetail;
            }else if(index == 2){
                //修改记录
                menuActionType = kOrderMenuActionType_modifyRecord;
            }
        }else{
            if(index == 1){
                //修改记录
                menuActionType = kOrderMenuActionType_modifyRecord;
            }
        }
    }

    return menuActionType;
}
#pragma mark -menuBtnHandler
-(void)menuBtnHandler:(NSInteger)index{
    if(self.currentYYOrderTransStatusModel){
        kOrderMenuActionType menuActionType = [self getOrderMenuTypeWithIndex:index+1];
        if(menuActionType == kOrderMenuActionType_modifyOrder){
            //修改订单
            [self modifyOrder];
        }else if(menuActionType == kOrderMenuActionType_cancelOrder){
            //取消订单
            [self cancelOrder];
        }else if(menuActionType == kOrderMenuActionType_modifyRecord){
            //修改记录
            [self modifyRecord];
        }else if(menuActionType == kOrderMenuActionType_closeOrder){
            //关闭交易
            [self closeOrder];
        }else if(menuActionType == kOrderMenuActionType_appendOrder){
            //追单补货
            [self appendOrder];
        }else if(menuActionType == kOrderMenuActionType_checkOriginalOrder){
            //查看原订单
            [self checkOriginalOrder];
        }else if(menuActionType == kOrderMenuActionType_checkAppendOrder){
            //查看追单
            [self checkAppendOrder];
        }else if(menuActionType == kOrderMenuActionType_originalOrderDetail){
            //原订单内容
            [self gotoOriginalOrderDetailView];
        }
    }
}
//查看原订单
-(void)gotoOriginalOrderDetailView{
    WeakSelf(ws);
    YYOriginalOrderDetailViewController *originalOrderDetailView = [[YYOriginalOrderDetailViewController alloc] init];
    originalOrderDetailView.currentYYOrderInfoModel = [_currentYYOrderInfoModel copy];
    originalOrderDetailView.currentYYOrderTransStatusModel = [_currentYYOrderTransStatusModel copy];
    originalOrderDetailView.menuData = [_menuData mutableCopy];
    [originalOrderDetailView updateUI];
    [originalOrderDetailView setCancelButtonClicked:^{
        [ws.navigationController popViewControllerAnimated:YES];
    }];
    [self.navigationController pushViewController:originalOrderDetailView animated:YES];
}
//删除订单
-(void)deleteOrder{
    WeakSelf(ws);
    if (![YYCurrentNetworkSpace isNetwork]) {
        [YYToast showToastWithView:ws.view title:kNetworkIsOfflineTips  andDuration:kAlertToastDuration];
        return;
    }
    CMAlertView *alertView = [[CMAlertView alloc] initWithTitle:NSLocalizedString(@"确定要删除订单吗？",nil) message:nil needwarn:NO delegate:nil cancelButtonTitle:NSLocalizedString(@"取消",nil) otherButtonTitles:@[NSLocalizedString(@"删除订单",nil)]];
    alertView.specialParentView = self.view;
    [alertView setAlertViewBlock:^(NSInteger selectedIndex){
        if (selectedIndex == 1) {
            [YYOrderApi updateOrderWithOrderCode:ws.currentYYOrderInfoModel.orderCode opType:3 andBlock:^(YYRspStatusAndMessage *rspStatusAndMessage, NSError *error) {
                if (rspStatusAndMessage.status == YYReqStatusCode100) {
                    [YYToast showToastWithTitle:NSLocalizedString(@"删除订单成功",nil)  andDuration:kAlertToastDuration];
                    [ws.navigationController popViewControllerAnimated:YES];
                }
            }];
        }
    }];

    [alertView show];
}
//修改订单
- (void)modifyOrder{
    WeakSelf(ws);
    if (![YYCurrentNetworkSpace isNetwork]) {
        [YYToast showToastWithView:ws.view title:kNetworkIsOfflineTips  andDuration:kAlertToastDuration];
        return;
    }
    YYOrderInfoModel *orderInfoModel = [[YYOrderInfoModel alloc] initWithDictionary:[self.currentYYOrderInfoModel toDictionary] error:nil];
    orderInfoModel.orderConnStatus = [[NSNumber alloc] initWithInteger:_currentOrderConnStatus];//
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    [appDelegate showBuildOrderViewController:orderInfoModel parent:self isCreatOrder:NO isReBuildOrder:NO isAppendOrder:NO modifySuccess:^(){
        [ws refreshOrder];
    }];
}

//取消订单
- (void)cancelOrder{
    WeakSelf(ws);
    if (![YYCurrentNetworkSpace isNetwork]) {
        [YYToast showToastWithView:ws.view title:kNetworkIsOfflineTips  andDuration:kAlertToastDuration];
        return;
    }


    CMAlertView *alertView =nil;
    if([_currentYYOrderInfoModel.isAppend integerValue] == 1){
        alertView = [[CMAlertView alloc] initWithTitle:NSLocalizedString(@"取消此订单？",nil) message:NSLocalizedString(@"这是一个追单订单，操作取消订单后，该追单与原始订单解除绑定。",nil) needwarn:NO delegate:nil cancelButtonTitle:NSLocalizedString(@"保留订单",nil) otherButtonTitles:@[NSLocalizedString(@"取消订单_short",nil)]];

    }else{
        alertView = [[CMAlertView alloc] initWithTitle:NSLocalizedString(@"取消此订单？",nil) message:NSLocalizedString(@"订单取消后，可在“已取消”的订单中找到该订单",nil) needwarn:NO delegate:nil cancelButtonTitle:NSLocalizedString(@"保留订单",nil) otherButtonTitles:@[NSLocalizedString(@"取消订单_short",nil)]];
    }
    alertView.specialParentView = self.view;
    [alertView setAlertViewBlock:^(NSInteger selectedIndex){
        if (selectedIndex == 1) {

            [YYOrderApi updateOrderWithOrderCode:ws.currentYYOrderInfoModel.orderCode opType:1 andBlock:^(YYRspStatusAndMessage *rspStatusAndMessage, NSError *error) {
                if (rspStatusAndMessage.status == YYReqStatusCode100) {
                    [YYToast showToastWithView:ws.view title:NSLocalizedString(@"取消订单成功",nil)  andDuration:kAlertToastDuration];
                    [ws refreshOrder];
                }
            }];
        }
    }];

    [alertView show];
}
//修改记录
- (void)modifyRecord {
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"OrderDetail" bundle:[NSBundle mainBundle]];
    YYOrderModifyLogListController *orderMessageViewController = [storyboard instantiateViewControllerWithIdentifier:@"YYOrderModifyLogListController"];
    orderMessageViewController.currentYYOrderInfoModel = _currentYYOrderInfoModel;
    orderMessageViewController.stylesAndTotalPriceModel = _stylesAndTotalPriceModel;
    orderMessageViewController.currentOrderLogo =_currentOrderLogo;
    [self.navigationController pushViewController:orderMessageViewController animated:YES];
}
//关闭交易
-(void)closeOrder{
    WeakSelf(ws);
    __block NSString *blockOrderCode = _currentYYOrderInfoModel.orderCode;
    __block NSInteger blockIsOrderClose = 0;//0代表为未关闭  1代表关闭

    __block BOOL _inRunLoop = true;
    if(_currentOrderConnStatus == YYOrderConnStatusLinked){
        [YYOrderApi getOrderCloseStatus:_currentYYOrderInfoModel.orderCode andBlock:^(YYRspStatusAndMessage *rspStatusAndMessage, NSInteger isclose, NSError *error) {
            blockIsOrderClose = isclose;
            _inRunLoop = false;
        }];
    }else{
        if(_currentOrderConnStatus == YYOrderConnStatusUnconfirmed || _currentOrderConnStatus == YYOrderConnStatusNotFound){
            blockIsOrderClose = 1;
        }
        _inRunLoop = false;
    }
    while (_inRunLoop) {
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantFuture]];
    }
    if (blockIsOrderClose == 0){
        [[YYYellowPanelManage instance] showOrderStatusRequestClosePanelWidthParentView:self.view currentYYOrderInfoModel:_currentYYOrderInfoModel andCallBack:^(NSArray *value) {
            [YYOrderApi setOrderCloseRequest:blockOrderCode andBlock:^(YYRspStatusAndMessage *rspStatusAndMessage,  NSError *error) {
                if(rspStatusAndMessage.status == YYReqStatusCode100){
                    [ws refreshOrder];
                }else{
                    [YYToast showToastWithView:ws.view title:rspStatusAndMessage.message andDuration:kAlertToastDuration];
                }

            }];
        }];
    }else{
        CMAlertView *alertView = [[CMAlertView alloc] initWithTitle:NSLocalizedString(@"确认要取消交易吗？",nil) message:nil needwarn:NO delegate:nil cancelButtonTitle:NSLocalizedString(@"关闭",nil) otherButtonTitles:@[NSLocalizedString(@"取消",nil)]];
        alertView.specialParentView = self.view;
        [alertView setAlertViewBlock:^(NSInteger selectedIndex){
            if (selectedIndex == 1) {
                [YYOrderApi closeOrder:ws.currentYYOrderInfoModel.orderCode andBlock:^(YYRspStatusAndMessage *rspStatusAndMessage,  NSError *error) {
                    if(rspStatusAndMessage.status == YYReqStatusCode100){
                        [ws refreshOrder];
                    }else{
                        [YYToast showToastWithView:ws.view title:rspStatusAndMessage.message andDuration:kAlertToastDuration];
                    }

                }];
            }
        }];
        [alertView show];

    }

}
//追单补货
-(void)appendOrder{
    if(_currentYYOrderInfoModel.orderCode){
        WeakSelf(ws);
        [[YYYellowPanelManage instance] showOrderAppendViewWidthParentView:self info:@[_currentYYOrderInfoModel.orderCode] andCallBack:^(NSArray *value) {
            YYOrderAppendParamModel *appendParamModel = [[YYOrderAppendParamModel alloc] initWithDictionary:[ws.currentYYOrderInfoModel toDictionary] error:nil];
            appendParamModel.styleIds = value;
            appendParamModel.originOrderCode = ws.currentYYOrderInfoModel.orderCode ;
            [MBProgressHUD showHUDAddedTo:ws.view animated:YES];
            [YYOrderApi appendOrder:appendParamModel andBlock:^(YYRspStatusAndMessage *rspStatusAndMessage, NSString *orderCode, NSError *error) {
                [MBProgressHUD hideAllHUDsForView:ws.view animated:YES];

                if(rspStatusAndMessage.status == YYReqStatusCode100 ){
                    //[YYToast showToastWithView:weakself.view title:rspStatusAndMessage.message andDuration:kAlertToastDuration];
                    __block NSString *blockAppendOrderCode = orderCode;

                    [YYOrderApi getOrderByOrderCode:orderCode isForReBuildOrder:NO andBlock:^(YYRspStatusAndMessage *rspStatusAndMessage, YYOrderInfoModel *orderInfoModel, NSError *error) {
                        AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
                        if (rspStatusAndMessage.status == YYReqStatusCode100) {
                            [appDelegate showBuildOrderViewController:orderInfoModel parent:self isCreatOrder:NO isReBuildOrder:NO isAppendOrder:YES modifySuccess:^(){
                                ws.currentOrderCode = blockAppendOrderCode;
                                [ws updateOrderConnStatus];
                                [ws refreshOrder];
                            }];
                        }else{
                            [YYToast showToastWithView:appDelegate.mainViewController.view title:rspStatusAndMessage.message andDuration:kAlertToastDuration];
                        }
                    }];
                }else{
                    [YYToast showToastWithView:ws.view title:rspStatusAndMessage.message andDuration:kAlertToastDuration];
                }
            }];

        }];
    }
}
//查看追单
-(void)checkAppendOrder{
    if([_currentYYOrderInfoModel.isAppend integerValue] == 0){
        if(_currentYYOrderInfoModel.appendOrderCode){
            WeakSelf(ws);
            [YYOrderApi getOrderConnStatus:self.currentYYOrderInfoModel.appendOrderCode andBlock:^(YYRspStatusAndMessage *rspStatusAndMessage, YYOrderConnStatusModel *statusModel, NSError *error){
                if(rspStatusAndMessage.status == YYReqStatusCode100){
                    if([statusModel.status integerValue] == YYOrderConnStatusLinked){
                        [ws checkOriginalOrder];
                    }else{
                        CMAlertView *alertView = [[CMAlertView alloc] initWithTitle:NSLocalizedString(@"追单未关联",nil) message:NSLocalizedString(@"请先至订单消息中同意订单关联。",nil) needwarn:NO delegate:nil cancelButtonTitle:NSLocalizedString(@"取消",nil) otherButtonTitles:@[[NSString stringWithFormat:@"%@|000000",NSLocalizedString(@"查看订单消息",nil)]]];
                        alertView.specialParentView = self.view;
                        [alertView setAlertViewBlock:^(NSInteger selectedIndex){
                            if (selectedIndex == 1) {
                                [ws showOrderMessageList];
                            }
                        }];

                        [alertView show];
                    }
                }else{
                    [YYToast showToastWithView:ws.view title:rspStatusAndMessage.message andDuration:kAlertToastDuration];
                }
            }];
        }
    }
}

//查看原订单
-(void)checkOriginalOrder{
    if([_currentYYOrderInfoModel.isAppend integerValue] == 0){
        if(![NSString isNilOrEmpty:_currentYYOrderInfoModel.appendOrderCode]){
            UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"OrderDetail" bundle:[NSBundle mainBundle]];
            YYOrderDetailViewController *orderDetailViewController = [storyboard instantiateViewControllerWithIdentifier:@"YYOrderDetailViewController"];
            orderDetailViewController.currentOrderCode = _currentYYOrderInfoModel.appendOrderCode;
            orderDetailViewController.currentOrderLogo =  _currentYYOrderInfoModel.brandLogo;
            orderDetailViewController.currentOrderConnStatus = YYOrderConnStatusUnknow;
            [self.navigationController pushViewController:orderDetailViewController animated:YES];
        }
    }else{
        if(![NSString isNilOrEmpty:_currentYYOrderInfoModel.originalOrderCode]){
            UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"OrderDetail" bundle:[NSBundle mainBundle]];
            YYOrderDetailViewController *orderDetailViewController = [storyboard instantiateViewControllerWithIdentifier:@"YYOrderDetailViewController"];
            orderDetailViewController.currentOrderCode = _currentYYOrderInfoModel.originalOrderCode;
            orderDetailViewController.currentOrderLogo =  _currentYYOrderInfoModel.brandLogo;
            orderDetailViewController.currentOrderConnStatus = YYOrderConnStatusUnknow;
            [self.navigationController pushViewController:orderDetailViewController animated:YES];
        }else{
            [YYToast showToastWithView:self.view title:NSLocalizedString(@"原始订单已被删除",nil) andDuration:kAlertToastDuration];
        }
    }
}
#pragma mark - --------------自定义方法----------------------
//去包裹列表
- (void)gotoPackageListView{
    WeakSelf(ws);
    YYPackageListViewController *packageListView = [[YYPackageListViewController alloc] init];
    packageListView.orderCode = _currentOrderCode;
    [packageListView setCancelButtonClicked:^{
        [ws.navigationController popViewControllerAnimated:YES];
    }];
    [self.navigationController pushViewController:packageListView animated:YES];
}
-(void)loadPaymentNoteList:(NSString *)orderCode{
    WeakSelf(ws);
    [YYOrderApi getPaymentNoteList:orderCode finalTotalPrice:[_currentYYOrderInfoModel.finalTotalPrice doubleValue] andBlock:^(YYRspStatusAndMessage *rspStatusAndMessage, YYPaymentNoteListModel *paymentNoteList, NSError *error) {
        if(rspStatusAndMessage.status == YYReqStatusCode100){
            ws.paymentNoteList = paymentNoteList;
        }else{
            ws.paymentNoteList = nil;
        }
        [ws.tableView reloadData];
    }];
}

-(void)showOrderMessageList{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"OrderDetail" bundle:[NSBundle mainBundle]];
    YYOrderMessageViewController *orderMessageViewController = [storyboard instantiateViewControllerWithIdentifier:@"YYOrderMessageViewController"];
    [orderMessageViewController setMarkAsReadHandler:^(void){
        [YYOrderMessageViewController markAsRead];
    }];
    [self.navigationController pushViewController:orderMessageViewController animated:YES];
}

//订单流动状态的网络数据
-(void)updateOrderTransStatus{
    WeakSelf(ws);
    [YYOrderApi getOrderTransStatus:self.currentOrderCode andBlock:^(YYRspStatusAndMessage *rspStatusAndMessage, YYOrderTransStatusModel *transStatusModel, NSError *error) {
        if (rspStatusAndMessage.status == YYReqStatusCode100){
            ws.currentYYOrderTransStatusModel = transStatusModel;
            [ws.tableView reloadData];
        }
    }];
}

-(void)updateOrderConnStatus{
    WeakSelf(ws);
    [YYOrderApi getOrderConnStatus:self.currentOrderCode andBlock:^(YYRspStatusAndMessage *rspStatusAndMessage, YYOrderConnStatusModel *statusModel, NSError *error){
        if(rspStatusAndMessage.status == YYReqStatusCode100){
            ws.currentOrderConnStatus = [statusModel.status integerValue];
            [ws.tableView reloadData];
        }
    }];
}

- (void)refreshOrder{
    WeakSelf(ws);

    if (self.currentOrderCode) {
        //在线的
        [YYOrderApi getOrderByOrderCode:_currentOrderCode isForReBuildOrder:NO andBlock:^(YYRspStatusAndMessage *rspStatusAndMessage, YYOrderInfoModel *orderInfoModel, NSError *error) {
            if (rspStatusAndMessage.status == YYReqStatusCode100) {
                ws.currentYYOrderInfoModel = orderInfoModel;
                ws.currentYYOrderInfoModel.orderConnStatus = @(ws.currentOrderConnStatus);

                CGFloat taxValue = [ws.currentYYOrderInfoModel.taxRate floatValue]/100.0f;
                updateCustomTaxValue(ws.menuData, [NSNumber numberWithFloat:taxValue],YES);
                ws.selectTaxType = getPayTaxTypeFormServiceNew(ws.menuData, [ws.currentYYOrderInfoModel.taxRate integerValue]);

                ws.currentOrderLogo = ws.currentYYOrderInfoModel.brandLogo;
                ws.stylesAndTotalPriceModel = [orderInfoModel getTotalValueByOrderInfo:NO];
                [ws updateTotalLabel];
                [ws updateBottomViewStatus];
                [ws loadAliPaySettting];
                [ws.tableView reloadData];

                [self updateOrderTransStatus];

                [self loadPaymentNoteList:self.currentOrderCode];

                if(ws.isNeedShowOrderChange){
                    //弹个弹窗
                    [ws showOrderChange];
                }
            }
        }];
    }
}
-(void)showOrderChange{

    WeakSelf(ws);
    NSInteger transStatus = getOrderTransStatus(self.currentYYOrderTransStatusModel.designerTransStatus, self.currentYYOrderTransStatusModel.buyerTransStatus);
    BOOL isForcedDelivery = [_currentYYOrderInfoModel.isForcedDelivery boolValue];
    if(transStatus == YYOrderCode_CLOSE_REQ || [self.currentYYOrderInfoModel.closeReqStatus integerValue] == -1 || transStatus == YYOrderCode_DELIVERY || transStatus == YYOrderCode_RECEIVED || transStatus == YYOrderCode_CANCELLED || transStatus == YYOrderCode_CLOSED){
        //交易关闭 已发货 已收货 已取消
        if(isForcedDelivery){
            CMAlertView *alertView = [[CMAlertView alloc] initWithTitle:NSLocalizedString(@"查看订单改动内容",nil) message:nil needwarn:NO delegate:nil cancelButtonTitle:NSLocalizedString(@"取消",nil) otherButtonTitles:@[NSLocalizedString(@"确定",nil)]];
            alertView.specialParentView = self.view;
            [alertView setAlertViewBlock:^(NSInteger selectedIndex){
                if (selectedIndex == 1) {
                    [ws gotoDeliveringDoneConfirmView];
                }
            }];

            [alertView show];
        }
    }
}

-(void)gotoDeliveringDoneConfirmView{
    WeakSelf(ws);
    YYDeliveringDoneConfirmViewController *deliveringDoneConfirmView = [[YYDeliveringDoneConfirmViewController alloc] init];
    deliveringDoneConfirmView.currentYYOrderInfoModel = _currentYYOrderInfoModel;
    deliveringDoneConfirmView.stylesAndTotalPriceModel = [_currentYYOrderInfoModel getPreTotalValueByOrderInfo];
    deliveringDoneConfirmView.nowStylesAndTotalPriceModel = _stylesAndTotalPriceModel;
    [deliveringDoneConfirmView updateUI];
    [deliveringDoneConfirmView setCancelButtonClicked:^{
        [ws.navigationController popViewControllerAnimated:YES];
    }];
    [self.navigationController pushViewController:deliveringDoneConfirmView animated:YES];
}
-(void)loadAliPaySettting{
    NSInteger _designerId = [self.currentYYOrderInfoModel.designerId integerValue];
    NSInteger _moneyType = [self.currentYYOrderInfoModel.curType integerValue];
    NSInteger orderStatus = getOrderTransStatus(self.currentYYOrderTransStatusModel.designerTransStatus, self.currentYYOrderTransStatusModel.buyerTransStatus);
    if(self.currentYYOrderInfoModel != nil && (orderStatus == YYOrderCode_CLOSE_REQ || [self.currentYYOrderInfoModel.closeReqStatus integerValue] == -1)){
        self.isAvailableForAliPay = NO;
        [self.tableView reloadData];
    }else{
        if(_designerId > 0 && _moneyType == 0 ){
            WeakSelf(ws);
            [YYOrderApi isAvailableForAliPay:_designerId andBlock:^(YYRspStatusAndMessage *rspStatusAndMessage, Boolean isAvailable, NSError *error) {
                if(isAvailable){
                    ws.isAvailableForAliPay = YES;
                }else{
                    ws.isAvailableForAliPay = NO;
                }
                [ws.tableView reloadData];
            }];
        }
    }
}

- (void)updateBottomViewStatus{
    NSInteger chatBtnoffset=0;
    NSInteger orderStatus = getOrderTransStatus(self.currentYYOrderTransStatusModel.designerTransStatus, self.currentYYOrderTransStatusModel.buyerTransStatus);
    if (orderStatus == YYOrderCode_CANCELLED || orderStatus == YYOrderCode_CLOSED) {
        [_menuBtn setImage:nil forState:UIControlStateNormal];
        [_menuBtn setTitle:NSLocalizedString(@"删除",nil) forState:UIControlStateNormal];
        [_menuBtn removeTarget:self action:@selector(showMenuUI:) forControlEvents:UIControlEventTouchUpInside];
        [_menuBtn addTarget:self action:@selector(deleteOrder) forControlEvents:UIControlEventTouchUpInside];
        chatBtnoffset = -60;
    }else{
        [_menuBtn setImage:[UIImage imageNamed:@"download_menu"] forState:UIControlStateNormal];
        [_menuBtn setTitle:@"" forState:UIControlStateNormal];
        [_menuBtn removeTarget:self action:@selector(deleteOrder) forControlEvents:UIControlEventTouchUpInside];
        [_menuBtn addTarget:self action:@selector(showMenuUI:) forControlEvents:UIControlEventTouchUpInside];
        chatBtnoffset = -40;
    }
    if([_currentYYOrderInfoModel.designerId integerValue] > 0 && [_currentYYOrderInfoModel.connStatus integerValue] == 1){
        [self.chatBtn setImage:[UIImage imageNamed:@"chat_icon"] forState:UIControlStateNormal];
        [self.chatBtn addTarget:self action:@selector(chatBtnHandler:) forControlEvents:UIControlEventTouchUpInside];
        self.chatBtn.hidden = NO;
        __weak UIView *_weakContainerView = _containerView;
        [_chatBtn mas_updateConstraints:^(MASConstraintMaker *make) {
            make.right.equalTo(_weakContainerView.mas_right).offset(chatBtnoffset);
        }];
    }else{
        _chatBtn.hidden = YES;
    }
    if([_currentYYOrderInfoModel.isAppend integerValue] == 1){
        [self.navView setNavTitle:NSLocalizedString(@"追单",nil)];
    }else{
        [self.navView setNavTitle:NSLocalizedString(@"订单详情",nil)];
    }

}


- (void)updateTotalLabel{
    if (_stylesAndTotalPriceModel) {
        _countLabel.text = [NSString stringWithFormat:@"%@%@%li %@ %li %@",NSLocalizedString(@"共计",nil),NSLocalizedString(@"：",nil),_stylesAndTotalPriceModel.totalStyles,NSLocalizedString(@"款",nil),_stylesAndTotalPriceModel.totalCount,NSLocalizedString(@"件",nil)];

        _priceTotalDiscountView.backgroundColor = [UIColor clearColor];
        _priceTotalDiscountView.bgColorIsBlack = NO;

        if (!self.currentYYOrderInfoModel.finalTotalPrice
            || [self.currentYYOrderInfoModel.finalTotalPrice floatValue] <= 0) {
            self.currentYYOrderInfoModel.finalTotalPrice = [NSNumber numberWithFloat:self.stylesAndTotalPriceModel.finalTotalPrice];
        }

        _priceTotalDiscountView.showDiscountValue = NO;
        _priceTotalDiscountView.notShowDiscountValueTextAlignmentLeft = YES;

        NSString *finalValue = replaceMoneyFlag([NSString stringWithFormat:@"￥%.2f",[_currentYYOrderInfoModel.finalTotalPrice doubleValue]],[_currentYYOrderInfoModel.curType integerValue]);
        _priceTotalDiscountView.fontColorStr =  @"ed6498";

        if(IsPhone6_gt){
            NSInteger priceWidth = [finalValue sizeWithAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:15]}].width;
            _priceViewlayoutWidthConstraints.constant = priceWidth;
            [_priceTotalDiscountView updateUIWithOriginPrice:finalValue
                                                  fianlPrice:finalValue
                                                  originFont:[UIFont boldSystemFontOfSize:15]
                                                   finalFont:[UIFont boldSystemFontOfSize:15]];
        }else{
            NSInteger priceWidth = [finalValue sizeWithAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:13]}].width;
            _priceViewlayoutWidthConstraints.constant = priceWidth;
            [_priceTotalDiscountView updateUIWithOriginPrice:finalValue
                                                  fianlPrice:finalValue
                                                  originFont:[UIFont boldSystemFontOfSize:13]
                                                   finalFont:[UIFont boldSystemFontOfSize:13]];
        }


    }
}
-(NSInteger)getSectionsNum{
    int sections = 0;
    if (_currentYYOrderInfoModel
        && _currentYYOrderInfoModel.groups
        && [_currentYYOrderInfoModel.groups count] > 0) {
        sections = (int)[_currentYYOrderInfoModel.groups count];
    }
    return sections + 2;
}

#pragma mark - --------------other----------------------

@end
