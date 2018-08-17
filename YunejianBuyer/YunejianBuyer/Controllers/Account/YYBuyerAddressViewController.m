//
//  YYBuyerAddressViewController.m
//  YunejianBuyer
//
//  Created by Apple on 16/2/14.
//  Copyright © 2016年 Apple. All rights reserved.
//

// c文件 —> 系统文件（c文件在前）

// 控制器
#import "YYBuyerAddressViewController.h"
#import "YYCreateOrModifyAddressViewController.h"

// 自定义视图
#import "YYNavView.h"
#import "YYAddressCell.h"
#import "YYAddAddressCell.h"

// 接口
#import "YYUserApi.h"

// 分类

// 自定义类和三方类（ cocoapods类 > model > 工具类 > 其他）
#import "YYAddressListModel.h"
#import "YYAddress.h"
#import "AppDelegate.h"

@interface YYBuyerAddressViewController ()<UITableViewDataSource,UITableViewDelegate,YYTableCellDelegate, MGSwipeTableCellDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIView *_containerView;
@property (nonatomic,strong) NSMutableArray *addressArray;
@property (nonatomic,strong) YYCreateOrModifyAddressViewController *createOrModifyAddressViewController;
@property (nonatomic, strong) YYNavView *navView;

@end

@implementation YYBuyerAddressViewController

#pragma mark - --------------生命周期--------------
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.navView = [[YYNavView alloc] initWithTitle:nil WithSuperView:self.view haveStatusView:YES];
    WeakSelf(ws);
    self.navView.goBackBlock = ^{
        [ws goBack];
    };
    if(_isSelect){
        [self.navView setNavTitle:NSLocalizedString(@"添加收件地址",nil)];
    }else{
        [self.navView setNavTitle:NSLocalizedString(@"管理收件地址",nil)];
    }

    [self getAddressList];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    // 进入埋点
    [MobClick beginLogPageView:kYYPageBuyerAddress];
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    // 退出埋点
    [MobClick endLogPageView:kYYPageBuyerAddress];
}


#pragma mark - --------------SomePrepare--------------

#pragma mark - --------------系统代理----------------------

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{

    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    NSInteger rows = 0;

    if(section == 0){
        rows = 1;
    }else if (section == 1) {
        if ([_addressArray count]) {
            rows = [_addressArray count];
        }
    }
    return rows;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = nil;
    NSInteger section = indexPath.section;
    NSInteger row = indexPath.row;

    //    YYUser *user = [YYUser currentUser];
    //    WeakSelf(weakSelf);
    if(section == 0){
        static NSString *CellIdentifier = @"addAddressCell";
        YYAddAddressCell *addAddressCell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        addAddressCell.selectionStyle = UITableViewCellSelectionStyleNone;
        addAddressCell.delegate = self;
        [addAddressCell updateUI];
        cell = addAddressCell;
    }else if(section == 1) {
        static NSString *CellIdentifier = @"addressCell";
        YYAddressCell *addressCell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        addressCell.selectionStyle = UITableViewCellSelectionStyleNone;

        // 三方侧滑
        addressCell.accessoryType = UITableViewCellAccessoryNone;
        addressCell.delegate = self;
        addressCell.allowsMultipleSwipe = NO;
        addressCell.allowsButtonsWithDifferentWidth = YES;


        if (_addressArray && [_addressArray count] > 0 && row < [_addressArray count]) {
            YYAddress *address = [_addressArray objectAtIndex:row];

            addressCell.address = address;
            [addressCell updateUI];
        }
        cell = addressCell;

    }

    if (cell == nil){
        [NSException raise:@"DetailCell == nil.." format:@"No cells with matching CellIdentifier loaded from your storyboard"];
    }
    return cell;
}


#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if(indexPath.section== 0){
        return 80;
    }
    YYAddress *address = [_addressArray objectAtIndex:indexPath.row];
    return [YYAddressCell getCellHeight:address];
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    //if(section == 0){
    return 0.1;
    //}

    //return 6;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if(indexPath.section == 1){
        YYAddress *address = [_addressArray objectAtIndex:indexPath.row];

        if(_isSelect){
            if(self.selectAddressClicked){
                self.selectAddressClicked(address);
            }
        }else{
            [self createOrModifyAddress:address];
        }
    }
}

#pragma mark - --------------自定义代理/block----------------------
-(void)btnClick:(NSInteger)row section:(NSInteger)section andParmas:(NSArray *)parmas{
    [self createOrModifyAddress:nil];
}

#pragma mark - 侧滑
- (NSArray<UIView *> *)swipeTableCell:(MGSwipeTableCell *)cell swipeButtonsForDirection:(MGSwipeDirection)direction swipeSettings:(MGSwipeSettings *)swipeSettings expansionSettings:(MGSwipeExpansionSettings *)expansionSettings{
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
    NSArray * result = @[];
    // 右边显示
    if (direction == MGSwipeDirectionRightToLeft) {
        swipeSettings.transition = MGSwipeTransitionStatic;
        expansionSettings.fillOnTrigger = NO;
        // 删除按钮

        MGSwipeButton *delete = [MGSwipeButton buttonWithTitle:@"" icon:[UIImage imageNamed:@"styledelete_icon"] backgroundColor:[UIColor redColor] callback:^BOOL(MGSwipeTableCell * sender){
            WeakSelf(ws);

            CMAlertView *alertView = [[CMAlertView alloc] initWithTitle:NSLocalizedString(@"确认删除此收件地址吗？",nil) message:nil needwarn:NO delegate:nil cancelButtonTitle:NSLocalizedString(@"取消",nil) otherButtonTitles:@[NSLocalizedString(@"删除",nil)]];
            alertView.specialParentView = self.view;
            [alertView setAlertViewBlock:^(NSInteger selectedIndex){
                if (selectedIndex == 1) {
                    YYAddress *address = [ws.addressArray objectAtIndex:indexPath.row];
                    [YYUserApi deleteAddress:[address.addressId integerValue] andBlock:^(YYRspStatusAndMessage *rspStatusAndMessage, NSError *error) {
                        if(rspStatusAndMessage.status == YYReqStatusCode100){
                            [ws getAddressList];
                        }else{
                            [YYToast showToastWithTitle:rspStatusAndMessage.message andDuration:kAlertToastDuration];
                        }
                    }];
                }
            }];
            [alertView show];
            return YES;
        }];
        // 基本样式
        delete.buttonWidth = 67;
        delete.backgroundColor = [UIColor colorWithHex:@"5d5d5d"];

        result = @[delete];
    }
    return result;
}


#pragma mark - --------------自定义响应----------------------
- (void)goBack {
    [self closeBtnHandler:nil];
}

- (IBAction)closeBtnHandler:(id)sender {
    if (_cancelButtonClicked) {
        _cancelButtonClicked();
    }
}

#pragma mark - --------------自定义方法----------------------

- (void)getAddressList{
    WeakSelf(ws);
    [YYUserApi getAddressListWithBlock:^(YYRspStatusAndMessage *rspStatusAndMessage, YYAddressListModel *addressListModel, NSError *error) {
        if (addressListModel) {
            NSMutableArray *array = [[NSMutableArray alloc] initWithCapacity:0];
            for (YYAddressModel *addressModel in addressListModel.result) {
                YYAddress *address = [[YYAddress alloc] init];

                address.addressId = addressModel.addressId;
                address.detailAddress = addressModel.detailAddress;
                address.receiverName = addressModel.receiverName;
                address.receiverPhone = addressModel.receiverPhone;
                address.defaultShipping = addressModel.defaultShipping;
                address.defaultBilling = addressModel.defaultBilling;

                address.nation = addressModel.nation;
                address.province = addressModel.province;
                address.city = addressModel.city;
                address.nationEn = addressModel.nationEn;
                address.provinceEn = addressModel.provinceEn;
                address.cityEn = addressModel.cityEn;
                address.nationId = addressModel.nationId;
                address.provinceId = addressModel.provinceId;
                address.cityId = addressModel.cityId;

                address.street = addressModel.street;
                address.zipCode = addressModel.zipCode;
                [array addObject:address];
            }

            _addressArray = [NSMutableArray arrayWithArray:array];
            dispatch_async(dispatch_get_main_queue(), ^{
                [ws reloadTableView];
            });
        }
    }];
}

- (void)reloadTableView{
    [_tableView reloadData];
}

//创建或修改收件地址
- (void)createOrModifyAddress:(YYAddress *)address{

    WeakSelf(ws);

    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Account" bundle:[NSBundle mainBundle]];
    YYCreateOrModifyAddressViewController *createOrModifyAddressViewController = [storyboard instantiateViewControllerWithIdentifier:@"YYCreateOrModifyAddressViewController"];
    self.createOrModifyAddressViewController = createOrModifyAddressViewController;

    if (address && [address isKindOfClass:[YYAddress class]]) {
        createOrModifyAddressViewController.currentOperationType = OperationTypeModify;
        createOrModifyAddressViewController.address = address;
    }else{
        createOrModifyAddressViewController.currentOperationType = OperationTypeCreate;
        createOrModifyAddressViewController.address = nil;
    }
    [self.navigationController pushViewController:createOrModifyAddressViewController animated:YES];
    [createOrModifyAddressViewController setCancelButtonClicked:^(){

        [ws.navigationController popViewControllerAnimated:YES];

    }];

    [createOrModifyAddressViewController setModifySuccess:^(){
        [ws.navigationController popViewControllerAnimated:NO];
        [ws getAddressList];
    }];
}

#pragma mark - --------------UI----------------------

#pragma mark - --------------other----------------------

@end
