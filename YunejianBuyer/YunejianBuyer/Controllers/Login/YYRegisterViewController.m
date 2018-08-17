//
//  YYRegisterViewController.m
//  yunejianDesigner
//
//  Created by Victor on 2017/12/18.
//  Copyright © 2017年 Apple. All rights reserved.
//

// c文件 —> 系统文件（c文件在前）

// 控制器
#import "YYRegisterViewController.h"
#import "YYNavView.h"

// 自定义视图
#import "YYPickView.h"
#import "YYStepViewCell.h"
#import "YYRegisterTableTitleCell.h"
#import "YYRegisterTableInputCell.h"
#import "YYRegisterTableSubmitCell.h"
#import "YYProtocolViewController.h"
#import "YYRegisterTableEmailVerifyCell.h"
#import "YYCountryPickView.h"

// 接口
#import "YYUserApi.h"

// 分类

// 自定义类和三方类（ cocoapods类 > model > 工具类 > 其他）
#import <MBProgressHUD.h>
#import "MLInputDodger.h"
#import "YYTableViewCellData.h"
#import "YYTableViewCellInfoModel.h"
#import "YYStepInfoModel.h"
#import "Header.h"
#import "regular.h"
#import "YYYellowPanelManage.h"

@interface YYRegisterViewController () <UITableViewDataSource, UITableViewDelegate, YYRegisterTableCellDelegate, YYPickViewDelegate, YYCountryPickViewDelegate>

@property (nonatomic, strong) YYNavView *navView;
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) UIButton *submitButton;
@property(nonatomic,strong)YYProtocolViewController *protocolViewController;
@property (nonatomic,strong) YYCountryListModel *countryInfo;
@property (nonatomic,strong) YYCountryListModel *provinceInfo;
@property(nonatomic,strong) YYCountryPickView *countryPickerView;
@property(nonatomic,strong) YYCountryPickView *provincePickerView;
@property(nonatomic,strong) YYPickView *countryCodePickerView;

@property (nonatomic, strong) NSMutableArray *cellDataArrays;
@property (nonatomic,assign) BOOL protocolViewIsShow;
@property(nonatomic,strong) NSString *currentNation;
@property(nonatomic,strong) NSNumber *currentNationID;
@property(nonatomic,strong) NSString *currentProvinece;
@property(nonatomic,strong) NSNumber *currentProvineceID;
@property(nonatomic,strong) NSString *currentCity;
@property(nonatomic,strong) NSNumber *currentCityID;
@property(nonatomic,strong) NSIndexPath *countryIndexPath;
@property(nonatomic,strong) NSIndexPath *cityIndexPath;
@property(nonatomic,strong) NSIndexPath *countryCodeIndexPath;

@end

@implementation YYRegisterViewController

#pragma mark - --------------生命周期--------------
- (void)viewDidLoad {
    [super viewDidLoad];
    [self SomePrepare];
    [self UIConfig];
    [self RequestData];
    [self buildTableViewDataSource];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    if (self.registerType == kBuyerStorUserType) {
        [MobClick beginLogPageView:kYYPageRegisterBuyerStorUser];
    } else if (self.registerType == kEmailRegisterType) {
        [MobClick beginLogPageView:kYYPageRegisterEmailRegister];
    }
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    if (self.registerType == kBuyerStorUserType) {
        [MobClick endLogPageView:kYYPageRegisterBuyerStorUser];
    } else if (self.registerType == kEmailRegisterType) {
        [MobClick endLogPageView:kYYPageRegisterEmailRegister];
    }
}

#pragma mark - --------------SomePrepare--------------
- (void)SomePrepare
{
    [self PrepareData];
    [self PrepareUI];
}

- (void)PrepareData{
    self.countryCodeIndexPath = [NSIndexPath indexPathForRow:6 inSection:1];
    self.countryIndexPath = [NSIndexPath indexPathForRow:2 inSection:1];
    self.cityIndexPath = [NSIndexPath indexPathForRow:3 inSection:1];
    self.provinceInfo = nil;
    self.currentNation = @"";
    self.currentNationID = @(0);
    self.currentProvinece = @"";
    self.currentCity = @"";
    self.currentProvineceID = @(0);
    self.currentCityID = @(0);
}

- (void)PrepareUI{
    self.view.backgroundColor = _define_white_color;
    
    self.navView = [[YYNavView alloc] initWithTitle:NSLocalizedString(@"买手店入驻",nil) WithSuperView: self.view haveStatusView:YES];
    
    UIButton *backBtn = [UIButton getCustomImgBtnWithImageStr:@"goBack_normal" WithSelectedImageStr:nil];
    [self.navView addSubview:backBtn];
    [backBtn addTarget:self action:@selector(goBack) forControlEvents:UIControlEventTouchUpInside];
    [backBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.mas_equalTo(0);
        make.width.mas_equalTo(40);
        make.bottom.mas_equalTo(-1);
    }];
}

#pragma mark - --------------UIConfig----------------------
-(void)UIConfig{
    self.tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStyleGrouped];
    [self.view addSubview:self.tableView];
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    [self.tableView registerClass:[YYRegisterTableTitleCell class] forCellReuseIdentifier:NSStringFromClass([YYRegisterTableTitleCell class])];
    [self.tableView registerClass:[YYRegisterTableInputCell class] forCellReuseIdentifier:NSStringFromClass([YYRegisterTableInputCell class])];
    [self.tableView registerClass:[YYRegisterTableSubmitCell class] forCellReuseIdentifier:NSStringFromClass([YYRegisterTableSubmitCell class])];
    [self.tableView registerClass:[YYRegisterTableEmailVerifyCell class] forCellReuseIdentifier:NSStringFromClass([YYRegisterTableEmailVerifyCell class])];
    self.tableView.shiftHeightAsDodgeViewForMLInputDodger = 44.0f+5.0f;
    [self.tableView registerAsDodgeViewForMLInputDodger];
    
    self.submitButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.submitButton.backgroundColor = _define_black_color;
    [self.submitButton setTitle:NSLocalizedString(@"提交申请",nil) forState:UIControlStateNormal];
    self.submitButton.titleLabel.font = [UIFont systemFontOfSize:15];
    [self.submitButton addTarget:self action:@selector(submitApplication) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.submitButton];
    [self reloadUI];
}

- (void)reloadUI {
    if (self.registerType == kBuyerStorUserType) {
        self.tableView.frame = CGRectMake(0, kStatusBarAndNavigationBarHeight, CGRectGetWidth([UIScreen mainScreen].bounds), CGRectGetHeight([UIScreen mainScreen].bounds) - kStatusBarAndNavigationBarHeight - 58 - (kIPhoneX?34.f:0.f));
        self.submitButton.hidden = NO;
        self.submitButton.frame = CGRectMake(0, CGRectGetHeight([UIScreen mainScreen].bounds) - 58 - (kIPhoneX?34.f:0.f), CGRectGetWidth([UIScreen mainScreen].bounds), 58);
    } else if (self.registerType == kEmailRegisterType) {
        self.tableView.frame = CGRectMake(0, kStatusBarAndNavigationBarHeight, CGRectGetWidth([UIScreen mainScreen].bounds), CGRectGetHeight([UIScreen mainScreen].bounds) - kStatusBarAndNavigationBarHeight);
        self.submitButton.hidden = YES;
        self.submitButton.frame = CGRectZero;
    }
}

#pragma mark - --------------请求数据----------------------
-(void)RequestData{}

- (void)registerBuyerWithParams:(NSArray *)paramsArr {
    [MBProgressHUD showHUDAddedTo:self.view animated:NO];
    YYTableViewCellInfoModel *infoModel = [self getCellData:1 row:9 index:0 content:nil];
    __block NSString *blockEmailstr = infoModel.value;
    [YYUserApi registerBuyerWithData:paramsArr andBlock:^(YYRspStatusAndMessage *rspStatusAndMessage, NSError *error) {
        [MBProgressHUD hideAllHUDsForView:self.view animated:NO];
        if( rspStatusAndMessage.status == kCode100){
            //直接请求登录接口？
            [YYToast showToastWithView:self.view title:NSLocalizedString(@"注册成功！",nil) andDuration:kAlertToastDuration];
            self.registerType = kEmailRegisterType;
            self.userEmail = blockEmailstr;
            [self reloadUI];
            [self buildTableViewDataSource];
            [self.tableView reloadData];
            return;
        }else{
            [YYToast showToastWithView:self.view title:rspStatusAndMessage.message andDuration:kAlertToastDuration];
        }
    }];
}

- (void)getCountryInfoWithBlock:(void(^)(YYCountryListModel *countryListModel))block {
    [MBProgressHUD showHUDAddedTo:self.view animated:NO];
    [YYUserApi getCountryInfoWithBlock:^(YYRspStatusAndMessage *rspStatusAndMessage, YYCountryListModel *countryListModel, NSError *error) {
        [MBProgressHUD hideAllHUDsForView:self.view animated:NO];
        if (rspStatusAndMessage.status == kCode100) {
            if (block) {
                block(countryListModel);
            }
        }
    }];
}

#pragma mark - --------------系统代理----------------------
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return [self.cellDataArrays count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSArray *data = [self.cellDataArrays objectAtIndex:section];
    return [data count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSArray *data = [self.cellDataArrays objectAtIndex:indexPath.section];
    YYTableViewCellData *cellData = [data objectAtIndex:indexPath.row];
    NSInteger type = cellData.type;
    
    if(type == RegisterTableCellStep){
        YYStepInfoModel *info = cellData.object;
        YYStepViewCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([YYStepViewCell class])];
        if (!cell) {
            cell = [[YYStepViewCell alloc] initWithStepStyle:info.stepStyle reuseIdentifier:NSStringFromClass([YYStepViewCell class])];
            cell.firtTitle = info.firtTitle;
            cell.secondTitle = info.secondTitle;
            cell.thirdTitle = info.thirdTitle;
            cell.fourthTitle = info.fourthTitle;
        }
        cell.currentStep = info.currentStep;
        [cell updateUI];
        return cell;
    }
    if(type == RegisterTableCellTypeTitle){
        YYTableViewCellInfoModel *infoModel = cellData.object;
        YYRegisterTableTitleCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([YYRegisterTableTitleCell class])];
        [cell updateCellInfo:infoModel];
        return cell;
    }
    if(type == RegisterTableCellTypeInput){
        YYRegisterTableInputCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([YYRegisterTableInputCell class])];
        if (indexPath.section == 1 && (indexPath.row == 3 || indexPath.row == 7)) {
            cell.isMust = NO;
        } else {
            cell.isMust = YES;
        }
        YYTableViewCellInfoModel *infoModel = cellData.object;
        cell.otherInfo = nil;
        //判断当前InputCell 是否是电话号码输入类型  再传入区号类型  根据这个进行验证
        if([infoModel.propertyKey isEqualToString:@"contactPhone"]){
            if(indexPath.row){
                NSArray *tempData = [self.cellDataArrays objectAtIndex:indexPath.section];
                YYTableViewCellData *tempCellData = [tempData objectAtIndex:indexPath.row - 1];
                cell.otherInfo = tempCellData.object;
            }
        }
        
        [cell updateCellInfo:cellData.object];
        cell.delegate = self;
        cell.indexPath = indexPath;
        return cell;
    }
    if(type == RegisterTableCellTypeSubmit){
         YYRegisterTableSubmitCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([YYRegisterTableSubmitCell class])];
        [cell updateCellInfo:cellData.object];
        cell.delegate = self;
        cell.indexPath = indexPath;
        [cell setBlock:^(NSString *type) {
            if([type isEqualToString:@"secrecyAgreement"])
            {
                [self showProtocolView:NSLocalizedString(@"隐私权保护声明",nil) protocolType:@"secrecyAgreement"];
            }else if([type isEqualToString:@"serviceAgreement"])
            {
                [self showProtocolView:NSLocalizedString(@"服务协议",nil) protocolType:@"serviceAgreement"];
            }
        }];
        return cell;
    }
    if(type == RegisterTableCellTypeEmailVerify){
        YYRegisterTableEmailVerifyCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([YYRegisterTableEmailVerifyCell class])];
        [cell updateCellInfo:cellData.object];
        [cell setSubmitBlock:^{
            [self submitApplication];
        }];
        return cell;
    }
    
    return nil;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSArray *data = [self.cellDataArrays objectAtIndex:indexPath.section];
    YYTableViewCellData *cellData = [data objectAtIndex:indexPath.row];
    return cellData.tableViewCellRowHeight;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 0.1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    if (section == 1) {
        return 0.1;
    }
    return 10;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    NSArray *data = [self.cellDataArrays objectAtIndex:indexPath.section];
    YYTableViewCellData *cellData = [data objectAtIndex:indexPath.row];
    if (cellData.selectedCellBlock) {
        cellData.selectedCellBlock(indexPath);
    }
}

#pragma mark - --------------自定义代理/block----------------------
#pragma mark YYpickVIewDelegate
-(void)toobarDonBtnHaveClick:(YYPickView *)pickView resultString:(NSString *)resultString{
    //    +44 英国|8
    //    +971 阿拉伯联合酋长国|17
    //直接存了  这边
    NSLog(@"1111");
    [self selectClick:self.countryCodeIndexPath.row AndSection:self.countryCodeIndexPath.section andParmas:@[resultString,@(0),@(1)]];
}

-(void)toobarDonBtnHaveCountryClick:(YYCountryPickView *)pickView resultString:(NSString *)resultString {
    if(pickView == self.countryPickerView){
        //        选择了国家 判断是不是切换了国家  切换了重置省 城市
        NSArray *countryArr = [resultString componentsSeparatedByString:@"/"];
        if(countryArr.count > 1){
            if([self.currentNationID integerValue] != [countryArr[1] integerValue]){
                //切换了初始化
                [self initProvinceCityData];
                //更新国家信息
                self.currentNation = countryArr[0];
                self.currentNationID = @([countryArr[1] integerValue]);
            }
        }else{
            //切换了初始化
            [self initCountryData];
            [self initProvinceCityData];
        }
        [self provinecesAndCityButtonClicked];
        
    }else if(pickView == self.provincePickerView){//Al l'Ayn/143596 城市+区号
        NSArray *provinceCityArr = [resultString componentsSeparatedByString:@","];
        if(provinceCityArr.count){
            NSArray * provinceArr = [provinceCityArr[0] componentsSeparatedByString:@"/"];
            if(provinceArr.count > 1){
                self.currentProvinece = provinceArr[0];
                self.currentProvineceID = @([provinceArr[1] integerValue]);
            }else{
                [self initProvinceData];
            }
            
            if(provinceCityArr.count > 1){
                
                NSArray * cityArr = [provinceCityArr[1] componentsSeparatedByString:@"/"];
                if(cityArr.count > 1){
                    self.currentCity = cityArr[0];
                    self.currentCityID = @([cityArr[1] integerValue]);
                }else{
                    [self initCityData];
                }
            }else{
                [self initCityData];
            }
        }
        [self selectClick:_countryIndexPath.row AndSection:_countryIndexPath.section andParmas:@[[self getCountryResultString],@(0),@(1)]];
        [self selectClick:_cityIndexPath.row AndSection:_cityIndexPath.section andParmas:@[resultString,@(0),@(1)]];
    }
}

#pragma mark - YYRegisterTableCellDelegate
-(void)selectClick:(NSInteger)type AndSection:(NSInteger)section andParmas:(NSArray *)parmas {
    NSArray *data = nil;
    YYTableViewCellData *cellData =nil;
    YYTableViewCellInfoModel *info = nil;
    NSString *content = [parmas objectAtIndex:0];
    NSInteger index = [[parmas objectAtIndex:1] integerValue];
    BOOL refreshFlag = (([parmas count] == 3)?YES:NO);
    
    if (index == -1) {
        [self submitApplication];
    }
    
    data = [self.cellDataArrays objectAtIndex:section];
    cellData = [data objectAtIndex:type];
    info = cellData.object;
    //更新数据
    if(info){
        YYTableViewCellInfoModel *infoModel = info;
        infoModel.value = content;
        if([infoModel.propertyKey isEqualToString:@"password"] && [data count]>(type+1)){
            cellData = [data objectAtIndex:type+1];
            info = cellData.object;
            infoModel = info;
            infoModel.passwordvalue = content;
        }else if([infoModel.propertyKey isEqualToString:@"brandRegisterType"]&& [data count]>(type+1)){
            
        }
    }
    if(refreshFlag) {
        [self.tableView reloadData];
    }
}

#pragma mark - --------------自定义响应----------------------
- (void)goBack {
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)countryCodeButtonClicked{
    if(self.countryCodePickerView == nil){
        NSArray *pickData = getContactLocalData();
        self.countryCodePickerView=[[YYPickView alloc] initPickviewWithArray:pickData isHaveNavControler:NO];
        [self.countryCodePickerView show:self.view];
        self.countryCodePickerView.delegate = self;
    }else
    {
        [self.countryCodePickerView show:self.view];
    }
}

//选择国家
-(void)countryButtonClicked{
    [self.provincePickerView removeNoBlock];
    [regular dismissKeyborad];
    
    WeakSelf(ws);
    if(!self.countryInfo){
        [self getCountryInfoWithBlock:^(YYCountryListModel *countryListModel) {
            ws.countryInfo = countryListModel;
            if(ws.countryInfo.result.count){
                ws.countryPickerView=[[YYCountryPickView alloc] initPickviewWithCountryArray:ws.countryInfo.result WithPlistType:CountryPickView isHaveNavControler:NO];
                ws.countryPickerView.delegate = ws;
                [ws.countryPickerView setCancelButtonClicked:^(){
                    [ws updateTempCountryDataByRealData];
                }];
                [ws.countryPickerView show:ws.view];
            }
        }];
    }else{
        [self.countryPickerView show:self.view];
    }
}

//选择城市
-(void)provinecesAndCityButtonClicked{
    [self.countryPickerView removeNoBlock];
    [regular dismissKeyborad];
    
    if(!self.provinceInfo){
        [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        [YYUserApi getSubCountryInfoWithCountryID:[self.currentNationID integerValue] WithBlock:^(YYRspStatusAndMessage *rspStatusAndMessage, YYCountryListModel *countryListModel, NSInteger impId,NSError *error) {
            [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
            if (rspStatusAndMessage.status == kCode100) {
                if(countryListModel.result.count){
                    self.provinceInfo = countryListModel;
                }else{
                    YYCountryModel *TempModel = [[YYCountryModel alloc] init];
                    TempModel.impId = @(-1);
                    TempModel.name = @"-";
                    TempModel.nameEn = @"-";
                    countryListModel.result = [NSArray arrayWithObject:TempModel];
                    self.provinceInfo = countryListModel;
                }
                
                if(self.provinceInfo.result.count){
                    self.provincePickerView=[[YYCountryPickView alloc] initPickviewWithCountryArray:self.provinceInfo.result WithPlistType:SubCountryPickView isHaveNavControler:NO];
                    self.provincePickerView.delegate = self;
                    WeakSelf(ws);
                    [self.provincePickerView setCancelButtonClicked:^(){
                        [ws updateTempCountryDataByRealData];
                    }];
                    [self.provincePickerView show:self.view];
                }
            }
        }];
    }else{
        [_provincePickerView show:self.view];
    }
}

- (void)submitApplication {
    NSArray *dataArray = nil;
    
    NSInteger verifyRow=0;
    NSMutableArray *retailerNameArr = [[NSMutableArray alloc] init];
    NSMutableArray *paramsArr = [[NSMutableArray alloc] initWithCapacity:10];
    NSString *paramsStr = nil;
    for(NSInteger verifySection = 0; verifySection < [self.cellDataArrays count]; verifySection++){
        dataArray = [self.cellDataArrays objectAtIndex:verifySection];
        verifyRow = 0;
        for(YYTableViewCellData *cellData in dataArray){
            if(cellData.object){
                if(cellData.type !=  RegisterTableCellTypeTitle && cellData.type !=  RegisterTableCellTypeSubmit){
                    if ([cellData.object isKindOfClass:[YYTableViewCellInfoModel class]]) {
                        YYTableViewCellInfoModel *model = cellData.object;
                        if(model.ismust > 0 && ([NSString isNilOrEmpty:model.value] || ![model checkWarn]) ){
                            [YYToast showToastWithView:self.view title:[NSString stringWithFormat: NSLocalizedString(@"完善%@信息",nil),model.title] andDuration:kAlertToastDuration];
                            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:verifyRow inSection:verifySection];
                            [self.tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionTop animated:YES];
                            return;
                        }
                        if(model.ismust !=2 && ![NSString isNilOrEmpty:model.value]){
                            if(model.ismust == 3){
                                paramsStr = [model getParamStr];
                            }else{
                                
                                NSString *getstr = [model getParamStr];
                                if(![NSString isNilOrEmpty:getstr])
                                {
                                    if ([getstr containsString:@"retailerName"]) {
                                        NSArray *compArr = [getstr componentsSeparatedByString:@"="];
                                        if(compArr.count > 1)
                                        {
                                            [retailerNameArr addObject:compArr[1]];
                                        }
                                    }else
                                    {
                                        [paramsArr addObject:getstr];
                                    }
                                }
                            }
                        }
                    }
                }else if(cellData.type ==  RegisterTableCellTypeSubmit){
                    YYTableViewCellInfoModel *model = cellData.object;
                    if(model.ismust > 0&& ![model.value isEqualToString:@"checked"]){
                        [YYToast showToastWithView:self.view title: NSLocalizedString(@"请选择同意服务条款",nil) andDuration:kAlertToastDuration];
                        return;
                    }
                }
            }
            verifyRow ++;
        }
    }
    if(self.registerType == kBuyerStorUserType){
        [self registerBuyerWithParams:paramsArr];
    }else if (self.registerType == kEmailRegisterType) {
        [MBProgressHUD hideAllHUDsForView:self.view animated:NO];
        [self.navigationController popViewControllerAnimated:YES];
    }
}

#pragma mark - --------------自定义方法----------------------
- (void)buildTableViewDataSource {
    WeakSelf(ws);
    NSMutableArray *arrays = [NSMutableArray array];
    if (self.registerType == kBuyerStorUserType) {
        if (YES) {
            NSMutableArray *array = [NSMutableArray array];
            if (YES) {
                YYTableViewCellData *data = [[YYTableViewCellData alloc] init];
                data.type = RegisterTableCellStep;
                data.tableViewCellRowHeight = 82;
                YYStepInfoModel *info = [[YYStepInfoModel alloc] init];
                info.stepStyle = StepStyleFourStep;
                info.firtTitle = NSLocalizedString(@"提交入驻申请",nil);
                info.secondTitle = NSLocalizedString(@"验证邮箱",nil);
                info.thirdTitle = NSLocalizedString(@"提交验证信息",nil);
                info.fourthTitle = NSLocalizedString(@"成功入驻",nil);
                info.currentStep = 0;
                data.object = info;
                [array addObject:data];
            }
            [arrays addObject:array];
        }
        if (YES) {
            NSMutableArray *array = [NSMutableArray array];
            if (YES) {
                YYTableViewCellData *data = [[YYTableViewCellData alloc] init];
                data.type = RegisterTableCellTypeTitle;
                data.tableViewCellRowHeight = 55;
                YYTableViewCellInfoModel *info = [[YYTableViewCellInfoModel alloc] init];
                info.ismust = 1;
                info.title = NSLocalizedString(@"买手店信息", nil);
                data.object = info;
                [array addObject:data];
            }
            if (YES) {
                YYTableViewCellData *data = [[YYTableViewCellData alloc] init];
                data.type = RegisterTableCellTypeInput;
                data.tableViewCellRowHeight = 53;
                YYTableViewCellInfoModel *info = [[YYTableViewCellInfoModel alloc] init];
                info.propertyKey = @"name";
                info.ismust = 1;
                info.title = NSLocalizedString(@"买手店名称",nil);
                info.tipStr = @"infobuyer_icon";
                data.object = info;
                [array addObject:data];
            }
            if (YES) {
                YYTableViewCellData *data = [[YYTableViewCellData alloc] init];
                data.type = RegisterTableCellTypeInput;
                data.tableViewCellRowHeight = 53;
                YYTableViewCellInfoModel *info = [[YYTableViewCellInfoModel alloc] init];
                info.propertyKey = @"country";
                info.ismust = 1;
                info.title = NSLocalizedString(@"所在国家",nil);
                info.tipStr = @"infoposition_icon";
                info.value = [[NSString alloc] initWithFormat:@"%@/721", NSLocalizedString(@"中国",nil)];
                data.object = info;
                [data setSelectedCellBlock:^(NSIndexPath *indexPath) {
                    [ws countryButtonClicked];
                }];
                [array addObject:data];
            }
            if (YES) {
                YYTableViewCellData *data = [[YYTableViewCellData alloc] init];
                data.type = RegisterTableCellTypeInput;
                data.tableViewCellRowHeight = 53;
                YYTableViewCellInfoModel *info = [[YYTableViewCellInfoModel alloc] init];
                info.propertyKey = @"city";
                info.ismust = 1;
                info.title = NSLocalizedString(@"所在省/市/区",nil);
                data.object = info;
                [data setSelectedCellBlock:^(NSIndexPath *indexPath) {
                    [ws provinecesAndCityButtonClicked];
                }];
                [array addObject:data];
            }
            if (YES) {
                YYTableViewCellData *data = [[YYTableViewCellData alloc] init];
                data.type = RegisterTableCellTypeInput;
                data.tableViewCellRowHeight = 53;
                YYTableViewCellInfoModel *info = [[YYTableViewCellInfoModel alloc] init];
                info.propertyKey = @"addressDetail";
                info.ismust = 1;
                info.title = NSLocalizedString(@"填写详细地址",nil);
                info.tipStr = @"infoposition_icon";
                data.object = info;
                [array addObject:data];
            }
            if (YES) {
                YYTableViewCellData *data = [[YYTableViewCellData alloc] init];
                data.type = RegisterTableCellTypeInput;
                data.tableViewCellRowHeight = 53;
                YYTableViewCellInfoModel *info = [[YYTableViewCellInfoModel alloc] init];
                info.propertyKey = @"contactName";
                info.ismust = 1;
                info.title = NSLocalizedString(@"买手店主要联系人",nil);
                info.tipStr = @"infopeople_icon";
                data.object = info;
                [array addObject:data];
            }
            if (YES) {
                YYTableViewCellData *data = [[YYTableViewCellData alloc] init];
                data.type = RegisterTableCellTypeInput;
                data.tableViewCellRowHeight = 53;
                YYTableViewCellInfoModel *info = [[YYTableViewCellInfoModel alloc] init];
                info.propertyKey = @"countryCode";
                info.ismust = 1;
                info.title = NSLocalizedString(@"区号",nil);
                info.tipStr = @"infophone_icon";
                info.value = NSLocalizedString(@"+86 中国",nil);
                data.object = info;
                [data setSelectedCellBlock:^(NSIndexPath *indexPath) {
                    [ws countryCodeButtonClicked];
                }];
                [array addObject:data];
            }
            if (YES) {
                YYTableViewCellData *data = [[YYTableViewCellData alloc] init];
                data.type = RegisterTableCellTypeInput;
                data.tableViewCellRowHeight = 53;
                YYTableViewCellInfoModel *info = [[YYTableViewCellInfoModel alloc] init];
                info.propertyKey = @"contactPhone";
                info.ismust = 1;
                info.title = NSLocalizedString(@"主要联系人电话",nil);
                info.warnStr = NSLocalizedString(@"手机号码格式不对",nil);
                info.keyboardType = UIKeyboardTypePhonePad;
                data.object = info;
                [array addObject:data];
            }
            if (YES) {
                YYTableViewCellData *data = [[YYTableViewCellData alloc] init];
                data.type = RegisterTableCellTypeTitle;
                data.tableViewCellRowHeight = 55;
                YYTableViewCellInfoModel *info = [[YYTableViewCellInfoModel alloc] init];
                info.title = NSLocalizedString(@"账户登录信息",nil);
                data.object = info;
                [array addObject:data];
            }
            if (YES) {
                YYTableViewCellData *data = [[YYTableViewCellData alloc] init];
                data.type = RegisterTableCellTypeInput;
                data.tableViewCellRowHeight = 53;
                YYTableViewCellInfoModel *info = [[YYTableViewCellInfoModel alloc] init];
                info.propertyKey = @"contactEmail";
                info.ismust = 1;
                info.title = NSLocalizedString(@"登录Email",nil);
                info.tipStr = @"infoemail_icon";
                info.warnStr = NSLocalizedString(@"Emial格式不对",nil);
                info.keyboardType = UIKeyboardTypeEmailAddress;
                data.object = info;
                [array addObject:data];
            }
            if (YES) {
                YYTableViewCellData *data = [[YYTableViewCellData alloc] init];
                data.type = RegisterTableCellTypeInput;
                data.tableViewCellRowHeight = 53;
                YYTableViewCellInfoModel *info = [[YYTableViewCellInfoModel alloc] init];
                info.propertyKey = @"password";
                info.ismust = 1;
                info.title = NSLocalizedString(@"登录密码",nil);
                info.tipStr = @"infopwd_icon";
                info.secureTextEntry = YES;
                data.object = info;
                [array addObject:data];
            }
            if (YES) {
                YYTableViewCellData *data = [[YYTableViewCellData alloc] init];
                data.type = RegisterTableCellTypeInput;
                data.tableViewCellRowHeight = 53;
                YYTableViewCellInfoModel *info = [[YYTableViewCellInfoModel alloc] init];
                info.propertyKey = @"password";
                info.ismust = 2;
                info.title = NSLocalizedString(@"再输入一次登录密码",nil);
                info.tipStr = @"infopwd_icon";
                info.warnStr = NSLocalizedString(@"两次密码输入不一致",nil);
                info.secureTextEntry = YES;
                data.object = info;
                [array addObject:data];
            }
            if (YES) {
                YYTableViewCellData *data = [[YYTableViewCellData alloc] init];
                data.type = RegisterTableCellTypeSubmit;
                data.tableViewCellRowHeight = 62;
                YYTableViewCellInfoModel *info = [[YYTableViewCellInfoModel alloc] init];
                info.propertyKey = @"agreerule";
                info.ismust = 1;
                info.value = @"checked";
                data.object = info;
                [array addObject:data];
            }
            [arrays addObject:array];
        }
        self.cellDataArrays = arrays;
        [self updateTempCountryDataByRealData];
    } else if (self.registerType == kEmailRegisterType) {
        if (YES) {
            NSMutableArray *array = [NSMutableArray array];
            if (YES) {
                YYTableViewCellData *data = [[YYTableViewCellData alloc] init];
                data.type = RegisterTableCellStep;
                data.tableViewCellRowHeight = 82;
                YYStepInfoModel *info = [[YYStepInfoModel alloc] init];
                info.stepStyle = StepStyleFourStep;
                info.firtTitle = NSLocalizedString(@"提交入驻申请",nil);
                info.secondTitle = NSLocalizedString(@"验证邮箱",nil);
                info.thirdTitle = NSLocalizedString(@"提交验证信息",nil);
                info.fourthTitle = NSLocalizedString(@"成功入驻",nil);
                info.currentStep = 1;
                data.object = info;
                [array addObject:data];
            }
            [arrays addObject:array];
        }
        if (YES) {
            NSMutableArray *array = [NSMutableArray array];
            if (YES) {
                YYTableViewCellData *data = [[YYTableViewCellData alloc] init];
                data.type = RegisterTableCellTypeEmailVerify;
                data.tableViewCellRowHeight = 510;
                YYTableViewCellInfoModel *info = [[YYTableViewCellInfoModel alloc] init];
                info.title = NSLocalizedString(@"已成功验证邮箱，去登录",nil);
                info.value = [NSString stringWithFormat:@"%d|%@",self.registerType,self.userEmail];
                data.object = info;
                [array addObject:data];
            }
            [arrays addObject:array];
        }
        self.cellDataArrays = arrays;
    }
}

-(void)showProtocolView:(NSString *)nowTitle protocolType:(NSString*)protocolType{
    if(!self.protocolViewIsShow){
        self.protocolViewIsShow = YES;
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Account" bundle:[NSBundle mainBundle]];
        YYProtocolViewController *protocolViewController = [storyboard instantiateViewControllerWithIdentifier:@"YYProtocolViewController"];
        protocolViewController.nowTitle = nowTitle;
        protocolViewController.protocolType = protocolType;
        self.protocolViewController = protocolViewController;
        
        UIView *superView = self.view;
        
        WeakSelf(ws);
        UIView *showView = protocolViewController.view;
        __weak UIView *weakShowView = showView;
        [protocolViewController setCancelButtonClicked:^(){
            removeFromSuperviewUseUseAnimateAndDeallocViewController(weakShowView,ws.protocolViewController);
            ws.protocolViewIsShow = NO;
        }];
        [superView addSubview:showView];
        [showView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.height.mas_equalTo(SCREEN_HEIGHT);
            make.left.equalTo(superView.mas_left);
            make.bottom.mas_equalTo(SCREEN_HEIGHT);
            make.width.mas_equalTo(SCREEN_WIDTH);
        }];
        [showView.superview layoutIfNeeded];
        [UIView animateWithDuration:kAddSubviewAnimateDuration animations:^{
            [showView mas_updateConstraints:^(MASConstraintMaker *make) {
                make.bottom.mas_equalTo(20);
            }];
            //必须调用此方法，才能出动画效果
            [showView.superview layoutIfNeeded];
        }completion:^(BOOL finished) {
            
        }];
    }
}

-(YYTableViewCellInfoModel *)getCellData:(NSInteger)section row:(NSInteger)type index:(NSInteger)index content:(NSString *)content{
    NSArray *data = nil;
    YYTableViewCellData *cellData =nil;
    data = [self.cellDataArrays objectAtIndex:section];
    cellData = [data objectAtIndex:type];
    YYTableViewCellInfoModel *info = cellData.object;
    return info;
}

-(NSString *)getCountryResultString{
    if([self.currentNationID integerValue]){
        return [[NSString alloc] initWithFormat:@"%@/%ld",self.currentNation,[self.currentNationID integerValue]];
    }
    return @"";
}

-(void)updateTempCountryDataByRealData{
    
    NSArray *data_country = [self.cellDataArrays objectAtIndex:self.countryIndexPath.section];
    YYTableViewCellData *cellData_country = [data_country objectAtIndex:self.countryIndexPath.row];
    YYTableViewCellInfoModel *infoModel_country = cellData_country.object;
    //        选择了国家 判断是不是切换了国家  切换了重置省 城市
    if(![NSString isNilOrEmpty:infoModel_country.value]){
        NSArray *countryArr = [infoModel_country.value componentsSeparatedByString:@"/"];
        if(countryArr.count > 1){
            if([self.currentNationID integerValue] != [countryArr[1] integerValue]){
                //切换了初始化
                [self initProvinceCityData];
                //更新国家信息
                self.currentNation = countryArr[0];
                self.currentNationID = @([countryArr[1] integerValue]);
                NSLog(@"111");
            }
        }else{
            //切换了初始化
            [self initCountryData];
            [self initProvinceCityData];
        }
    }else{
        //切换了初始化
        [self initCountryData];
        [self initProvinceCityData];
    }
    
    NSArray *data_city = [self.cellDataArrays objectAtIndex:self.cityIndexPath.section];
    YYTableViewCellData *cellData_city = [data_city objectAtIndex:self.cityIndexPath.row];
    YYTableViewCellInfoModel *infoModel_city = cellData_city.object;
    if(![NSString isNilOrEmpty:infoModel_city.value]){
        NSArray *provinceCityArr = [infoModel_city.value componentsSeparatedByString:@","];
        if(provinceCityArr.count){
            NSArray * provinceArr = [provinceCityArr[0] componentsSeparatedByString:@"/"];
            if(provinceArr.count > 1){
                self.currentProvinece = provinceArr[0];
                self.currentProvineceID = @([provinceArr[1] integerValue]);
            }else{
                [self initProvinceData];
            }
            
            if(provinceCityArr.count > 1){
                
                NSArray * cityArr = [provinceCityArr[1] componentsSeparatedByString:@"/"];
                if(cityArr.count > 1){
                    self.currentCity = cityArr[0];
                    self.currentCityID = @([cityArr[1] integerValue]);
                }else{
                    [self initCityData];
                }
            }else{
                [self initCityData];
            }
        }
    }else{
        [self initCityData];
    }
    NSLog(@"\ncurrentNation = %@ currentNationID = %ld \n currentProvinece = %@ currentProvineceID = %ld \n currentCity = %@ currentCityID = %ld \n",_currentNation,[_currentNationID integerValue],_currentProvinece,[_currentProvineceID integerValue],_currentCity,[_currentCityID integerValue]);
    NSLog(@"111");
}

#pragma mark - --------------other----------------------
-(void)initProvinceCityData{
    self.provinceInfo = nil;
    self.currentProvinece = @"";
    self.currentCity = @"";
    self.currentProvineceID = @(0);
    self.currentCityID = @(0);
}

-(void)initProvinceData{
    self.currentProvinece = @"";
    self.currentProvineceID = @(0);
}

-(void)initCityData{
    self.currentCity = @"";
    self.currentCityID = @(0);
}

-(void)initCountryData{
    self.currentNation = @"";
    self.currentNationID = @(0);
}

@end
