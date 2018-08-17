//
//  YYVisibleContactInfoViewController.m
//  YunejianBuyer
//
//  Created by chuanjun sun on 2017/10/25.
//  Copyright © 2017年 Apple. All rights reserved.
//

// c文件 —> 系统文件（c文件在前）

// 控制器
#import "YYVisibleContactInfoViewController.h"
#import "YYVisibleAuditPickerViewController.h"
#import "YYVisibleShopInfoViewController.h"

// 自定义视图
#import "YYNavView.h"
#import "YYCountryPickView.h"
#import "YYPickView.h"
#import "YYVisibleContactInfoTableViewCell.h"

// 接口
#import "YYUserApi.h"
#import "YYAuditingApi.h"

// 分类

// 自定义类和三方类（ cocoapods类 > model > 工具类 > 其他）
#import "MLInputDodger.h"
#import "YYCountryListModel.h"
#import "YYPerfectInfoModel.h"

@interface YYVisibleContactInfoViewController ()<UITableViewDelegate, UITableViewDataSource, UITextViewDelegate, YYPickViewDelegate, YYCountryPickViewDelegate, YYVisibleContactInfoCellDelegate>
/** tableView */
@property (nonatomic, strong) UITableView *tableView;
/** 导航栏 */
@property (nonatomic, strong) YYNavView *navView;

/** 图片集合 */
@property (nonatomic, strong) NSArray *imageViewArray;
/** 文字集合 */
@property (nonatomic, strong) NSArray *inputArray;
/** 提示图 */
@property (nonatomic, strong) NSArray *tipImageArray;

/** 国家 */
@property (nonatomic, strong) YYCountryPickView *countryPickerView;
/** 省市 */
@property (nonatomic, strong) YYCountryPickView *provincePickerView;
/** 国家 */
@property (nonatomic, strong) YYPickView *photoPickerView;

/** 国家信息 */
@property (nonatomic,strong) YYCountryListModel *countryInfo;
/** 城市信息 */
@property (nonatomic,strong) YYCountryListModel *provinceInfo;
/** 电话区号 */
@property (nonatomic, strong) NSArray *photoArray;
/** 当前区号  提交时再拼接，防止用户返回修改 */
@property (nonatomic, strong) NSString *currentPhotoPre;

/** 改变了么（国家） */
@property (nonatomic, assign) BOOL isChangeNation;

/** 当前正在操作的cell */
@property (nonatomic, strong) YYVisibleContactInfoTableViewCell *currentCell;

/** 准备提交的模型 */
@property (nonatomic, strong) YYPerfectInfoModel *perfectInfoModel;

@end

@implementation YYVisibleContactInfoViewController
#pragma mark - --------------生命周期--------------
- (void)viewDidLoad {
    [super viewDidLoad];
    [self SomePrepare];
}

#pragma mark - --------------SomePrepare--------------
- (void)SomePrepare
{
    [self PrepareData];
    [YYAuditingApi getInvisibleAndBlock:^(YYRspStatusAndMessage *rspStatusAndMessage,NSDictionary *dict, NSError *error) {
        // 国家
        self.perfectInfoModel.shopName = dict[@"name"];
        self.perfectInfoModel.contactName = dict[@"contactName"];
        self.perfectInfoModel.contactPhone = dict[@"contactPhone"];
        self.perfectInfoModel.nation = NSLocalizedString(@"中国", nil);

        if (dict[@"nationId"]) {
            self.perfectInfoModel.nationId = [NSNumber numberWithInt:721];
        }else{
            self.perfectInfoModel.nationId = [NSNumber numberWithInt:[dict[@"nationId"] intValue]];

        }

        // 初始化为0
        self.perfectInfoModel.province = @"";
        self.perfectInfoModel.provinceId = @-1;

        self.perfectInfoModel.city = @"";
        self.perfectInfoModel.cityId = @-1;

        self.perfectInfoModel.addressDetail = dict[@"addressDetail"];

        [self.tableView reloadData];
    }];
    [self PrepareUI];

}
- (void)PrepareData{
    // 注册通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(goback) name:VisibleInfoPostIsOk object:nil];
    // cell 一一对应
    self.imageViewArray = @[@"infobuyer_icon",
                            @"infoposition_icon",
                            @"",
                            @"infoposition_icon",
                            @"infopeople_icon",
                            @"infophone_icon",
                            @""];

    self.inputArray = @[NSLocalizedString(@"买手店名称", nil),
                        NSLocalizedString(@"",nil),
                        NSLocalizedString(@"所在省/市/区", nil),
                        NSLocalizedString(@"填写详细地址", nil),
                        NSLocalizedString(@"买手店主要联系人", nil),
                        NSLocalizedString(@"",nil),
                        NSLocalizedString(@"主要联系人电话", nil)];

    self.tipImageArray = @[@"",
                           @"down_gray",
                           @"down_gray",
                           @"",
                           @"",
                           @"down_gray",
                           @""];

    // 默认中国
    self.isChangeNation = YES;

    self.currentPhotoPre = NSLocalizedString(@"+86 中国", nil);

    self.perfectInfoModel = [[YYPerfectInfoModel alloc] init];

}


#pragma mark - --------------系统代理----------------------
#pragma mark - tableView
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 7;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    UIView *view = [[UIView alloc] init];
    view.backgroundColor = _define_white_color;

    UILabel *label = [[UILabel alloc] init];
    label.textColor = _define_black_color;
    label.text =NSLocalizedString(@"买手店信息", nil);
    label.font = [UIFont boldSystemFontOfSize:16];
    [view addSubview:label];
    [label sizeToFit];

    [label mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(view.mas_centerY);
    }];

    UIView *blackView = [[UIView alloc] init];
    blackView.backgroundColor = [UIColor blackColor];
    [view addSubview:blackView];
    [blackView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.left.right.mas_equalTo(0);
        make.height.mas_equalTo(2);
    }];

    return view;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 54;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 54;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return 0.01;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    YYVisibleContactInfoTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"YYVisibleContactInfoTableViewCell"];
    if (!cell) {
        cell = [[YYVisibleContactInfoTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"YYVisibleContactInfoTableViewCell"];
        cell.separatorInset = UIEdgeInsetsMake(0, 0, 0, 0);
    }
    cell.inputText = nil;
    cell.isShowButton = NO;
    cell.isEditing = YES;

    if (indexPath.row == 0) {
        cell.inputText = self.perfectInfoModel.shopName;
        cell.isEditing = NO;

    }else if (indexPath.row == 1) {
        cell.isShowButton = YES;
        cell.inputText = self.perfectInfoModel.nation;

    }else if (indexPath.row == 2){
        cell.isShowButton = YES;
        cell.inputText = [NSString stringWithFormat:@"%@ %@", self.perfectInfoModel.province, self.perfectInfoModel.city];

    }else if (indexPath.row == 4){
        cell.inputText = self.perfectInfoModel.contactName;
        cell.isEditing = NO;

    }else if (indexPath.row == 5){
        cell.isShowButton = YES;
        cell.inputText = self.currentPhotoPre;

    }else if (indexPath.row == 6){
        cell.isEditing = NO;
        cell.inputText = self.perfectInfoModel.contactPhone;
    }

    cell.titleImageName = self.imageViewArray[indexPath.row];
    cell.inputPlaceHode = self.inputArray[indexPath.row];
    cell.TipViewName = self.tipImageArray[indexPath.row];
    cell.indexPath = indexPath;
    cell.delegate = self;

    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
}

#pragma mark - --------------自定义代理/block----------------------
#pragma mark - cell
- (void)YYVisibleCellselectClick:(YYVisibleContactInfoTableViewCell *)cell{
    self.currentCell = cell;
    switch (cell.indexPath.row) {
            // 国家
        case 1:{
            if(!_countryInfo){
                [YYUserApi getCountryInfoWithBlock:^(YYRspStatusAndMessage *rspStatusAndMessage, YYCountryListModel *countryListModel, NSError *error) {
                    if (rspStatusAndMessage.status == YYReqStatusCode100) {
                        _countryInfo = countryListModel;
                        NSLog(@"%@", _countryInfo);
                        if(_countryInfo.result.count){
                            self.countryPickerView = [[YYCountryPickView alloc] initPickviewWithCountryArray:_countryInfo.result WithPlistType:CountryPickView isHaveNavControler:NO];
                            self.countryPickerView.tag = 10;
                            self.countryPickerView.delegate = self;
                            [_countryPickerView show:self.view];
                        }
                    }
                }];
            }else{
                [_countryPickerView show:self.view];
            }
        }
            break;
        case 2:{
            [self showProvince];
        }
            break;
        case 5:{
            if(self.photoPickerView == nil){
                NSArray *pickData = getContactLocalData();
                self.photoPickerView=[[YYPickView alloc] initPickviewWithArray:pickData isHaveNavControler:NO];
                self.photoPickerView.delegate = self;
                [self.photoPickerView show:self.view];
            }else
            {
                [self.photoPickerView show:self.view];
            }
        }
            break;
            
        default:
            break;
    }
}

- (void)YYVisibleCellInputChange:(YYVisibleContactInfoTableViewCell *)cell text:(NSString *)text{
    self.perfectInfoModel.addressDetail = text;
}

#pragma mark - picker
- (void)toobarDonBtnHaveCountryClick:(YYCountryPickView *)pickView resultString:(NSString *)resultString{

    NSIndexPath *indexPathNation = [NSIndexPath indexPathForRow:1 inSection:0];
    NSIndexPath *indexPathProvince = [NSIndexPath indexPathForRow:2 inSection:0];

    switch (pickView.tag) {
        case 10:{
            // 国家
            NSArray *array = [resultString componentsSeparatedByString:@"/"];
            self.perfectInfoModel.nation = array[0];
            self.perfectInfoModel.nationId = [NSNumber numberWithInt:[array[1] intValue]];

            self.perfectInfoModel.province = @"";
            self.perfectInfoModel.provinceId = @-1;

            self.perfectInfoModel.city = @"";
            self.perfectInfoModel.cityId = @-1;

            self.isChangeNation = YES;
            [self.tableView reloadRowsAtIndexPaths:@[indexPathNation, indexPathProvince] withRowAnimation:UITableViewRowAnimationNone];

        }
            break;
        case 20:{
            // 城市
            // 爱尔巴桑/143497
            // 北京/4008,东城/142999
            NSArray *address = [resultString componentsSeparatedByString:@","];

            if (address.count == 1) {
                NSArray *provinceArr =[address[0] componentsSeparatedByString:@"/"];
                self.perfectInfoModel.province = provinceArr[0];
                self.perfectInfoModel.provinceId = [NSNumber numberWithInt:[provinceArr[1] intValue]];

            }else if (address.count == 2){
                NSArray *provinceArr =[address[0] componentsSeparatedByString:@"/"];
                NSArray *cityArr =[address[1] componentsSeparatedByString:@"/"];
                self.perfectInfoModel.province = provinceArr[0];
                self.perfectInfoModel.provinceId = [NSNumber numberWithInt:[provinceArr[1] intValue]];

                self.perfectInfoModel.city = cityArr[0];
                self.perfectInfoModel.cityId = [NSNumber numberWithInt:[cityArr[1] intValue]];
            }
            [self.tableView reloadRowsAtIndexPaths:@[indexPathProvince] withRowAnimation:UITableViewRowAnimationNone];

        }

        default:
            break;
    }
}

// 电话区号回调
- (void)toobarDonBtnHaveClick:(YYPickView *)pickView resultString:(NSString *)resultString{
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:5 inSection:0];
    NSArray *arr = [resultString componentsSeparatedByString:@" "];
    self.currentPhotoPre = arr[1];
    [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
}

#pragma mark - --------------自定义响应----------------------
- (void)submitClick{
    // 检查/ 所在省市区、 填写详细地址、 按钮状态

    if ([NSString isNilOrEmpty:self.perfectInfoModel.province]) {
        [YYToast showToastWithTitle:NSLocalizedString(@"所在省/市/区", nil) andDuration:kAlertToastDuration];
        return;
    }

    if ([NSString isNilOrEmpty:self.perfectInfoModel.addressDetail]) {
        [YYToast showToastWithTitle:NSLocalizedString(@"填写详细地址", nil) andDuration:kAlertToastDuration];
        return;
    }

    // 跳转
    YYVisibleShopInfoViewController *visibleShop = [[YYVisibleShopInfoViewController alloc] init];
    visibleShop.model = self.perfectInfoModel;
    [self.navigationController pushViewController:visibleShop animated:YES];
}


#pragma mark - --------------自定义方法----------------------
- (void)showProvince{
    //  默认是yes
    if (self.isChangeNation) {
        // 先进性网络请求
        [YYUserApi getSubCountryInfoWithCountryID:[self.perfectInfoModel.nationId integerValue] WithBlock:^(YYRspStatusAndMessage *rspStatusAndMessage, YYCountryListModel *countryListModel, NSInteger impId,NSError *error) {
            if (rspStatusAndMessage.status == YYReqStatusCode100) {
                self.isChangeNation = NO;
                // 处理数据
                if(countryListModel.result.count){
                    _provinceInfo = countryListModel;
                }else{
                    YYCountryModel *TempModel = [[YYCountryModel alloc] init];
                    TempModel.impId = @(-1);
                    TempModel.name = @"-";
                    TempModel.nameEn = @"-";
                    countryListModel.result = [NSArray arrayWithObject:TempModel];
                    _provinceInfo = countryListModel;
                }

                if(_provinceInfo.result.count){
                    _provincePickerView = [[YYCountryPickView alloc] initPickviewWithCountryArray:_provinceInfo.result WithPlistType:SubCountryPickView isHaveNavControler:NO];
                    _provincePickerView.delegate = self;
                    _provincePickerView.tag = 20;
                    [self.provincePickerView show:self.view];
                }
            }
        }];

    }else{
        // 没有改变。代表self.isChangeNation == NO。说明控件已经创建过了，直接显示即可
        [_provincePickerView show:self.view];
    }
}

- (void)goback{
    if (self.goBack) {
        self.goBack();
    }
    [self.navigationController popViewControllerAnimated:NO];
}
#pragma mark - --------------UI----------------------
// 创建子控件
- (void)PrepareUI{
    // 此界面应当禁止侧滑返回,因为返回的地方可能有差
    id traget = self.navigationController.interactivePopGestureRecognizer.delegate;
    UIPanGestureRecognizer * pan = [[UIPanGestureRecognizer alloc]initWithTarget:traget action:nil];
    [self.view addGestureRecognizer:pan];
    self.view.backgroundColor = _define_white_color;

    self.navView = [[YYNavView alloc] initWithTitle:NSLocalizedString(@"买手店入驻",nil) WithSuperView:self.view haveStatusView:YES];
    WeakSelf(ws);
    self.navView.goBackBlock = ^{
        [ws goBack];
    };

    UIButton *submitButton = [[UIButton alloc] init];
    submitButton.backgroundColor = [UIColor blackColor];
    submitButton.titleLabel.font = [UIFont systemFontOfSize:15];

    [submitButton setTitle:NSLocalizedString(@"下一步", nil) forState:UIControlStateNormal];
    [submitButton addTarget:self action:@selector(submitClick) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:submitButton];
    [submitButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.mas_equalTo(0);
        make.height.mas_equalTo(58);
        make.bottom.mas_equalTo(self.mas_bottomLayoutGuideTop).with.offset(0);
    }];

    UITableView *tableView = [[UITableView alloc] init];
    self.tableView = tableView;
    tableView.backgroundColor = _define_white_color;
    tableView.delegate = self;
    tableView.dataSource = self;
    tableView.separatorColor = [UIColor colorWithHex:@"EFEFEF"];
    tableView.showsVerticalScrollIndicator = NO;
    [self.view addSubview:tableView];
    [tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(12.5);
        make.right.mas_equalTo(-12.5);
        make.top.mas_equalTo(ws.navView.mas_bottom).with.offset(0);
        make.bottom.mas_equalTo(submitButton.mas_top).with.offset(0);
    }];

    self.view.shiftHeightAsDodgeViewForMLInputDodger = 40.0f;
    [self.view registerAsDodgeViewForMLInputDodger];

}

- (void)dealloc{
    [self removeObserver:self forKeyPath:VisibleInfoPostIsOk];
}

#pragma mark - --------------other----------------------
@end
