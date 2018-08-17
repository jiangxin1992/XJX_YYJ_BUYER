//
//  YYVerifyBuyerViewController.m
//  YunejianBuyer
//
//  Created by Victor on 2017/12/25.
//  Copyright © 2017年 Apple. All rights reserved.
//

// c文件 —> 系统文件（c文件在前）

// 控制器
#import "YYVerifyBuyerViewController.h"
#import "YYProtocolViewController.h"

// 自定义视图
#import "YYNavView.h"
#import "YYStepViewCell.h"
#import "YYRegisterTableInputCell.h"
#import "YYRegisterTableIntroduceCell.h"
#import "YYRegisterTableBuyerPhotosCell.h"
#import "YYRegisterTableBuyerPriceRangCell.h"
#import "YYRegisterTableConnBrandCell.h"
#import "YYRegisterTableIconTitleCell.h"
#import "YYRegisterTableSubmitCell.h"

// 接口
#import "YYOrderApi.h"
#import "YYUserApi.h"

// 分类
#import "UIImage+Tint.h"

// 自定义类和三方类（ cocoapods类 > model > 工具类 > 其他）
#import <MBProgressHUD.h>
#import "MLInputDodger.h"
#import "YYTableViewCellData.h"
#import "YYTableViewCellInfoModel.h"
#import "YYStepInfoModel.h"
#import "YYBuyerHomeUpdateModel.h"
#import "regular.h"
#import "YYYellowPanelManage.h"
#import "YYUser.h"

@interface YYVerifyBuyerViewController ()<UITableViewDataSource, UITableViewDelegate, UIImagePickerControllerDelegate, YYRegisterTableCellDelegate,UINavigationControllerDelegate>

@property (nonatomic, strong) YYNavView *navView;
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) UIButton *submitButton;
@property(nonatomic,strong) YYProtocolViewController *protocolViewController;

@property (nonatomic, strong) NSArray *cellDataArrays;
@property (nonatomic,assign) BOOL ProtocolViewIsShow;

@end

@implementation YYVerifyBuyerViewController

#pragma mark - --------------生命周期--------------
- (void)viewDidLoad {
    [super viewDidLoad];
    [self SomePrepare];
    [self UIConfig];
    [self buildTableViewDataSource];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [MobClick beginLogPageView:kYYPageRegisterBuyerRegister];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [MobClick endLogPageView:kYYPageRegisterBuyerRegister];
}

#pragma mark - --------------SomePrepare--------------
- (void)SomePrepare
{
    [self PrepareData];
    [self PrepareUI];
}

- (void)PrepareData{
    if (!self.uploadImgs) {
        self.uploadImgs = [NSMutableArray array];
    }
}

- (void)PrepareUI{
    self.view.backgroundColor = _define_white_color;
    self.navView = [[YYNavView alloc] initWithTitle:NSLocalizedString(@"买手店身份审核",nil) WithSuperView: self.view haveStatusView:YES];
}

#pragma mark - --------------UIConfig----------------------
-(void)UIConfig{
    self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, kStatusBarAndNavigationBarHeight, SCREEN_WIDTH, SCREEN_HEIGHT - kStatusBarAndNavigationBarHeight - kTabbarAndBottomSafeAreaHeight) style:UITableViewStyleGrouped];
    [self.view addSubview:self.tableView];
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    [self.tableView registerClass:[YYRegisterTableBuyerRegisterUploadCell class] forCellReuseIdentifier:NSStringFromClass([YYRegisterTableBuyerRegisterUploadCell class])];
    [self.tableView registerClass:[YYRegisterTableIconTitleCell class] forCellReuseIdentifier:NSStringFromClass([YYRegisterTableIconTitleCell class])];
    [self.tableView registerClass:[YYRegisterTableInputCell class] forCellReuseIdentifier:NSStringFromClass([YYRegisterTableInputCell class])];
    [self.tableView registerClass:[YYRegisterTableIntroduceCell class] forCellReuseIdentifier:NSStringFromClass([YYRegisterTableIntroduceCell class])];
    [self.tableView registerClass:[YYRegisterTableBuyerPhotosCell class] forCellReuseIdentifier:NSStringFromClass([YYRegisterTableBuyerPhotosCell class])];
    [self.tableView registerClass:[YYRegisterTableBuyerPriceRangCell class] forCellReuseIdentifier:NSStringFromClass([YYRegisterTableBuyerPriceRangCell class])];
    [self.tableView registerClass:[YYRegisterTableConnBrandCell class] forCellReuseIdentifier:NSStringFromClass([YYRegisterTableConnBrandCell class])];
    [self.tableView registerClass:[YYRegisterTableSubmitCell class] forCellReuseIdentifier:NSStringFromClass([YYRegisterTableSubmitCell class])];
    self.tableView.shiftHeightAsDodgeViewForMLInputDodger = 44.0f+5.0f;
    [self.tableView registerAsDodgeViewForMLInputDodger];
    
    self.submitButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.submitButton.frame = CGRectMake(0, SCREEN_HEIGHT - kTabbarAndBottomSafeAreaHeight, SCREEN_WIDTH, 58);
    self.submitButton.backgroundColor = _define_black_color;
    [self.submitButton setTitle:NSLocalizedString(@"保存",nil) forState:UIControlStateNormal];
    self.submitButton.titleLabel.font = [UIFont systemFontOfSize:15];
    [self.submitButton addTarget:self action:@selector(submitApplication) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.submitButton];
}

#pragma mark - --------------请求数据----------------------
- (void)checkBuyerWithParams:(NSArray *)params {
    YYBuyerHomeUpdateModel *model = [YYBuyerHomeUpdateModel createUploadCertModel:params];
    NSLog(@"[model toJSONString] %@",[model toJSONString]);
    [YYUserApi checkBuyerWithData:[[model toDictionary] mj_JSONData] andBlock:^(YYRspStatusAndMessage *rspStatusAndMessage, NSError *error) {
        [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
        if( rspStatusAndMessage.status == YYReqStatusCode100){
            [self showYellowUserCheckAlert];
        }else{
            [YYToast showToastWithView:self.view title:rspStatusAndMessage.message andDuration:kAlertToastDuration];
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
    
    NSLog(@"RegisterTableCellTypeBuyerRegisterUpload %ld------------------", type);
    
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
    if(type == RegisterTableCellTypeIconTitle){
        YYRegisterTableIconTitleCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([YYRegisterTableIconTitleCell class])];
        [cell updateCellInfo:cellData.object];
        return cell;
    }
    if(type == RegisterTableCellTypeInput){
        YYRegisterTableInputCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([YYRegisterTableInputCell class])];
        YYTableViewCellInfoModel *infoModel = cellData.object;
        [cell updateCellInfo:infoModel];
        cell.delegate = self;
        cell.indexPath = indexPath;
        return cell;
    }
    if (type == RegisterTableCellTypeBuyerRegisterUpload) {
        YYRegisterTableBuyerRegisterUploadCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([YYRegisterTableBuyerRegisterUploadCell class])];
        cell.delegate = self;
        cell.indexPath = indexPath;
        UIImage *uploadImg = nil;
        if(cell.photoType == UploadImageType0){
            uploadImg = self.uploadImg0;
        }else if (cell.photoType == UploadImageType1){
            uploadImg =self.uploadImg1;
        }else if (cell.photoType == UploadImageType2){
            uploadImg =self.uploadImg2;
        }else if (cell.photoType == UploadImageType3){
            uploadImg =self.uploadImg3;
        }
        cell.uploadImage = uploadImg;
        [cell updateCellInfo:cellData.object];
        return cell;
    }
    if (type == RegisterTableCellTypeIntroduce) {
        YYRegisterTableIntroduceCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([YYRegisterTableIntroduceCell class])];
        [cell updateCellInfo:cellData.object];
        cell.delegate = self;
        cell.indexPath = indexPath;
        return cell;
    }
    if (type == RegisterTableCellTypeBuyerPhotos) {
        YYRegisterTableBuyerPhotosCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([YYRegisterTableBuyerPhotosCell class])];
        cell.delegate = self;
        cell.indexPath = indexPath;
        [cell updateParamInfo:cellData.object];
        [cell updateCellInfo:_uploadImgs];
        return cell;
    }
    if (type == RegisterTableCellTypeBuyerPriceRang) {
        YYRegisterTableBuyerPriceRangCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([YYRegisterTableBuyerPriceRangCell class])];
        cell.delegate = self;
        cell.indexPath = indexPath;
        [cell updateCellInfo:cellData.object];
        return cell;
    }
    if (type == RegisterTableCellTypeConnBrand) {
        YYRegisterTableConnBrandCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([YYRegisterTableConnBrandCell class])];
        cell.delegate = self;
        cell.indexPath = indexPath;
        [cell updateCellInfo:cellData.object];
        return cell;
    }
    if (type == RegisterTableCellTypeSubmit) {
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
    return nil;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSArray *data = [self.cellDataArrays objectAtIndex:indexPath.section];
    YYTableViewCellData *cellData = [data objectAtIndex:indexPath.row];
    if (cellData.useDynamicRowHeight) {
        if (cellData.dynamicCellRowHeight) {
            return cellData.dynamicCellRowHeight();
        } else {
            return UITableViewAutomaticDimension;
        }
    } else {
        return cellData.tableViewCellRowHeight;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 0.1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    if (section == 3) {
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
        cellData.selectedCellBlock(tableView, indexPath);
    }
}

#pragma mark - --------------自定义代理/block----------------------
-(void)upLoadPhotoImage:(NSInteger )type pointX:(NSInteger)px pointY:(NSInteger)py{
    self.uploadImgType = type;
    if(px == -1 && py ==-1){//delete
        [self deleteUpdatePhoto];
        return ;
    }//add
    
    WeakSelf(ws);
    UIImagePickerController *picker=[[UIImagePickerController alloc] init];
    picker.view.backgroundColor = _define_white_color;
    picker.delegate = self;
    picker.videoQuality = UIImagePickerControllerQualityTypeLow;
    picker.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
    UIAlertController * alertController = [regular getAlertWithFirstActionTitle:NSLocalizedString(@"相册",nil) FirstActionBlock:^{
        
        if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary]) {
            picker.allowsEditing = NO;
            picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
            [ws presentViewController:picker animated:YES completion:nil];
        }else
        {
            NSLog(@"无法打开相册");
        }
        
    } SecondActionTwoTitle:NSLocalizedString(@"拍照",nil) SecondActionBlock:^{
        
        if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
            //打开相机
            picker.allowsEditing = NO;
            picker.sourceType = UIImagePickerControllerSourceTypeCamera;
            //picker.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
            [ws presentViewController:picker animated:YES completion:nil];
        }else
        {
            NSLog(@"不能打开相机");
        }
        
    }];
    [self presentViewController:alertController animated:YES completion:nil];
}

-(void)showTopView:(BOOL)show{
    if(show == NO ){
        if(self.topLayer != nil){
            [self.topLayer removeFromSuperview];
        }
    }else {
        if(self.topLayer == nil){
            self.topLayer = [[UIView alloc] initWithFrame:self.view.bounds];
            self.topLayer.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.1];
        }
        [self.view addSubview:self.topLayer];
    }
}

-(void)selectClick:(NSInteger)type AndSection:(NSInteger)section andParmas:(NSArray *)parmas{
    //WeakSelf(weakself);
    NSArray *data = nil;
    YYTableViewCellData *cellData =nil;
    id info = nil;
    NSString *content = [parmas objectAtIndex:0];
    NSInteger index = [[parmas objectAtIndex:1] integerValue];
    BOOL refreshFlag = (([parmas count] == 3)?YES:NO);
    
    data = [self.cellDataArrays objectAtIndex:section];
    cellData = [data objectAtIndex:type];
    info = cellData.object;
    //更新数据
    if([info isKindOfClass:[YYTableViewCellInfoModel class]]){
        YYTableViewCellInfoModel *infoModel = info;
        infoModel.value = content;
    } else if ([info isKindOfClass:[YYRegisterTableBuyerPriceRangeInfoModel class]]) {
        YYRegisterTableBuyerPriceRangeInfoModel *infoModel = info;
        if (index == 0) {
            infoModel.minPriceValue = content;
        }else {
            infoModel.maxPriceValue = content;
        }
    }
    if(refreshFlag)
        [self.tableView reloadData];
}

#pragma mark - UIImagePickerControllerDelegate
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    //    获取选择图片
    UIImage *image = [UIImage fixOrientation:info[UIImagePickerControllerOriginalImage]];
    if (image) {
        if (![YYCurrentNetworkSpace isNetwork]) {
            [YYToast showToastWithView:self.view title:kNetworkIsOfflineTips andDuration:kAlertToastDuration];
        }else{
            [MBProgressHUD showHUDAddedTo:self.view animated:YES];
            [YYOrderApi uploadImage:image size:2.0f andBlock:^(YYRspStatusAndMessage *rspStatusAndMessage, NSString *imageUrl, NSError *error) {
                [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
                if (imageUrl && [imageUrl length] > 0) {
                    NSLog(@"imageUrl: %@",imageUrl);
                    NSArray *data = nil;
                    YYTableViewCellData *cellData =nil;
                    if(self.uploadImgType >= UploadImageType0){
                        data = [self.cellDataArrays objectAtIndex:1];
                        if(self.uploadImgType == UploadImageType0){
                            self.uploadImg0 = image;
                            cellData = [data objectAtIndex:0];//动态
                        }else if (self.uploadImgType == UploadImageType1){
                            self.uploadImg1 = image;
                            cellData = [data objectAtIndex:1];//动态
                        }else if (self.uploadImgType == UploadImageType2){
                            self.uploadImg2 = image;
                        }else if (self.uploadImgType == UploadImageType3){
                            self.uploadImg3 = image;
                        }
                        YYTableViewCellInfoModel *infoModel = cellData.object;
                        infoModel.value = imageUrl;
                    }else{
                        data = [self.cellDataArrays objectAtIndex:2];
                        cellData = [data objectAtIndex:3];//动态
                        YYTableViewCellInfoModel *infoModel = cellData.object;
                        NSArray *valueArr = [infoModel.value componentsSeparatedByString:@","];
                        NSMutableArray *tmpValueArr = [[NSMutableArray alloc] initWithArray:valueArr];
                        if (valueArr.count == 1 && [valueArr[0] isEqualToString:@""]) {
                            [tmpValueArr replaceObjectAtIndex:0 withObject:imageUrl];
                        } else {
                            [tmpValueArr addObject:imageUrl];
                        }
                        infoModel.value = [tmpValueArr componentsJoinedByString:@","];
                        
                        if(self.uploadImgType > [self.uploadImgs count]){
                            [self.uploadImgs addObject:image];
                        }else{
                            [self.uploadImgs replaceObjectAtIndex:(self.uploadImgType-1) withObject:image];
                        }
                    }
                    [self.tableView reloadData];
                }
                
            }];
        }
        if(self.uploadImgType >= UploadImageType0){
            if(self.uploadImgType == UploadImageType0){
                self.uploadImg0 = image;
            }else if (self.uploadImgType == UploadImageType1){
                self.uploadImg1 = image;
            }else if (self.uploadImgType == UploadImageType2){
                self.uploadImg2 = image;
            }else if (self.uploadImgType == UploadImageType3){
                self.uploadImg3 = image;
            }
        }else{
            if(self.uploadImgType > [self.uploadImgs count]){
                [self.uploadImgs addObject:image];
            }else{
                [self.uploadImgs replaceObjectAtIndex:(self.uploadImgType-1) withObject:image];
            }
        }
    }
    [picker dismissViewControllerAnimated:YES completion:nil];
}

-(void)imagePickerControllerDidCancel:(UIImagePickerController *)picker{
    //    WeakSelf(weakSelf);
    [self dismissViewControllerAnimated:YES completion:^{
    }];
    
}

#pragma mark - --------------自定义响应----------------------
- (void)submitApplication {
    NSArray *data = nil;
    NSInteger total=[self.cellDataArrays count];
    NSInteger verifySection=0;
    NSInteger verifyRow=0;
    NSMutableArray *retailerNameArr = [[NSMutableArray alloc] init];
    NSMutableArray *paramsArr = [[NSMutableArray alloc] initWithCapacity:10];
    NSString *paramsStr = nil;
    for(;verifySection<total;verifySection++){
        data = [self.cellDataArrays objectAtIndex:verifySection];
        verifyRow = 0;
        for(YYTableViewCellData *cellData in data){
            if(cellData.object){
                if(cellData.type !=  RegisterTableCellTypeTitle && cellData.type !=  RegisterTableCellTypeSubmit){
                    if ([cellData.object isKindOfClass:[YYTableViewCellInfoModel class]]) {
                        YYTableViewCellInfoModel *model = cellData.object;
                        if(model.ismust > 0 && ([NSString isNilOrEmpty:model.value] || ![model checkWarn]) ){
                            //[YYToast showToastWithTitle:[NSString stringWithFormat:@"完善%@信息",model.title] andDuration:kAlertToastDuration];
                            if ([NSString isNilOrEmpty:model.title]) {
                                [YYToast showToastWithView:self.view title:NSLocalizedString(@"完善信息",nil) andDuration:kAlertToastDuration];
                            } else {
                                [YYToast showToastWithView:self.view title:[NSString stringWithFormat: NSLocalizedString(@"完善%@信息",nil),model.title] andDuration:kAlertToastDuration];
                            }
                            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:verifyRow inSection:verifySection];
                            [self.tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionTop animated:YES];
                            return;
                        }
                        if(model.ismust !=2 && ![NSString isNilOrEmpty:model.value]){
                            if(model.ismust == 3){
                                paramsStr = [model getParamStr];
                            }else{
                                NSString *getstr = [model getParamStr];
                                if(![NSString isNilOrEmpty:getstr]) {
                                    if ([getstr containsString:@"retailerName"]) {
                                        NSArray *compArr = [getstr componentsSeparatedByString:@"="];
                                        if(compArr.count > 1) {
                                            [retailerNameArr addObject:compArr[1]];
                                        }
                                    } else {
                                        [paramsArr addObject:getstr];
                                    }
                                }
                            }
                        }
                    } else if ([cellData.object isKindOfClass:[YYRegisterTableBuyerPriceRangeInfoModel class]]) {
                        YYRegisterTableBuyerPriceRangeInfoModel *model = cellData.object;
                        if (model.ismust > 0 && [NSString isNilOrEmpty:model.minPriceValue]) {
                            [YYToast showToastWithView:self.view title:[NSString stringWithFormat: NSLocalizedString(@"完善%@信息",nil),model.minPriceTitle] andDuration:kAlertToastDuration];
                            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:verifyRow inSection:verifySection];
                            [self.tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionTop animated:YES];
                            return;
                        }
                        if (model.ismust > 0 && [NSString isNilOrEmpty:model.maxPriceValue]) {
                            [YYToast showToastWithView:self.view title:[NSString stringWithFormat: NSLocalizedString(@"完善%@信息",nil),model.maxPriceTItle] andDuration:kAlertToastDuration];
                            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:verifyRow inSection:verifySection];
                            [self.tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionTop animated:YES];
                            return;
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
    [self checkBuyerWithParams:paramsArr];
}

#pragma mark - --------------自定义方法----------------------
- (void)buildTableViewDataSource {
    NSMutableArray *arrays = [NSMutableArray array];
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
            info.currentStep = 2;
            data.object = info;
            [array addObject:data];
        }
        [arrays addObject:array];
    }
    if (YES) {
        NSMutableArray *array = [NSMutableArray array];
        if (YES) {
            YYTableViewCellData *data = [[YYTableViewCellData alloc] init];
            data.type = RegisterTableCellTypeBuyerRegisterUpload;
            data.tableViewCellRowHeight = 175;
            YYTableViewCellInfoModel *info = [[YYTableViewCellInfoModel alloc] init];
            info.propertyKey = @"licenceFile";
            info.ismust = 1;
            info.tipStr = NSLocalizedString(@"上传店铺营业执照",nil);
            info.warnStr = [NSString stringWithFormat: @"%ld", (long)UploadImageType0];
            data.object = info;
            [array addObject:data];
        }
        if (YES) {
            YYTableViewCellData *data = [[YYTableViewCellData alloc] init];
            data.type = RegisterTableCellTypeBuyerRegisterUpload;
            data.tableViewCellRowHeight = 175;
            YYTableViewCellInfoModel *info = [[YYTableViewCellInfoModel alloc] init];
            info.propertyKey = @"legalPersonFiles";
            info.ismust = 1;
            info.tipStr = NSLocalizedString(@"上传法人身份证 （正面照）" ,nil);
            info.warnStr = [NSString stringWithFormat: @"%ld", (long)UploadImageType1];
            data.object = info;
            [array addObject:data];
        }
        [arrays addObject:array];
    }
    if (YES) {
        NSMutableArray *array = [NSMutableArray array];
        if (YES) {
            YYTableViewCellData *data = [[YYTableViewCellData alloc] init];
            data.type = RegisterTableCellTypeIconTitle;
            data.useDynamicRowHeight = YES;
            YYTableViewCellInfoModel *info = [[YYTableViewCellInfoModel alloc] init];
            info.ismust = 0;
            info.title = NSLocalizedString(@"*买手店简介",nil);
            data.object = info;
            [array addObject:data];
        }
        if (YES) {
            YYTableViewCellData *data = [[YYTableViewCellData alloc] init];
            data.type = RegisterTableCellTypeIntroduce;
            data.tableViewCellRowHeight = 140;
            YYTableViewCellInfoModel *info = [[YYTableViewCellInfoModel alloc] init];
            info.propertyKey = @"introduction";
            info.ismust = 1;
            info.title = @"300";
            info.tipStr = NSLocalizedString(@"请输入买手店简介",nil);
            data.object = info;
            [array addObject:data];
        }
        if (YES) {
            YYTableViewCellData *data = [[YYTableViewCellData alloc] init];
            data.type = RegisterTableCellTypeIconTitle;
            data.useDynamicRowHeight = YES;
            YYTableViewCellInfoModel *info = [[YYTableViewCellInfoModel alloc] init];
            info.ismust = 0;
            info.title = NSLocalizedString(@"*买手店照片",nil);
            data.object = info;
            [array addObject:data];
        }
        if (YES) {
            YYTableViewCellData *data = [[YYTableViewCellData alloc] init];
            data.type = RegisterTableCellTypeBuyerPhotos;
            data.useDynamicRowHeight = YES;
            [data setDynamicCellRowHeight:^CGFloat{
                NSInteger maxPhotoNum = 8;
                maxPhotoNum = MIN([self.uploadImgs count], maxPhotoNum-1);
                return [YYRegisterTableBuyerPhotosCell cellHeight:maxPhotoNum];
            }];
            YYTableViewCellInfoModel *info = [[YYTableViewCellInfoModel alloc] init];
            info.propertyKey = @"storeImgs";
            info.ismust = 1;
            info.title = NSLocalizedString(@"买手店照片",nil);
            info.tipStr = NSLocalizedString(@"上传照片",nil);
            info.warnStr = @"8";
            info.value = @"";
            data.object = info;
            [array addObject:data];
        }
        if (YES) {
            YYTableViewCellData *data = [[YYTableViewCellData alloc] init];
            data.type = RegisterTableCellTypeIconTitle;
            data.useDynamicRowHeight = YES;
            YYTableViewCellInfoModel *info = [[YYTableViewCellInfoModel alloc] init];
            info.ismust = 0;
            info.title = NSLocalizedString(@"*款式零售价范围￥",nil);
            data.object = info;
            [array addObject:data];
        }
        if (YES) {
            YYTableViewCellData *data = [[YYTableViewCellData alloc] init];
            data.type = RegisterTableCellTypeBuyerPriceRang;
            data.tableViewCellRowHeight = 53;
            YYRegisterTableBuyerPriceRangeInfoModel *info = [[YYRegisterTableBuyerPriceRangeInfoModel alloc] init];
            info.ismust = 1;
            info.minPriceTitle = NSLocalizedString(@"从",nil);
            info.minPricePlaceholder = NSLocalizedString(@"款式最低零售价",nil);
            info.maxPriceTItle = NSLocalizedString(@"到",nil);
            info.maxPricePlaceholder = NSLocalizedString(@"款式最高零售价",nil);
            data.object = info;
            [array addObject:data];
        }
        if (YES) {
            YYTableViewCellData *data = [[YYTableViewCellData alloc] init];
            data.type = RegisterTableCellTypeIconTitle;
            data.useDynamicRowHeight = YES;
            YYTableViewCellInfoModel *info = [[YYTableViewCellInfoModel alloc] init];
            info.ismust = 0;
            info.title = NSLocalizedString(@"*列举合作品牌",nil);
            data.object = info;
            [array addObject:data];
        }
        if (YES) {
            YYTableViewCellData *data = [[YYTableViewCellData alloc] init];
            data.type = RegisterTableCellTypeConnBrand;
            data.tableViewCellRowHeight = 225;
            YYTableViewCellInfoModel *info = [[YYTableViewCellInfoModel alloc] init];
            info.propertyKey = @"copBrands";
            info.ismust = 1;
            info.warnStr = NSLocalizedString(@"完善信息",nil);
            data.object = info;
            [array addObject:data];
        }
        [arrays addObject:array];
    }
    if (YES) {
        NSMutableArray *array = [NSMutableArray array];
        if (YES) {
            YYTableViewCellData *data = [[YYTableViewCellData alloc] init];
            data.type = RegisterTableCellTypeIconTitle;
            data.useDynamicRowHeight = YES;
            YYTableViewCellInfoModel *info = [[YYTableViewCellInfoModel alloc] init];
            info.ismust = 0;
            info.title = NSLocalizedString(@"微信公众号",nil);
            info.tipStr = @"reg_weixin_icon";
            data.object = info;
            [array addObject:data];
        }
        if (YES) {
            YYTableViewCellData *data = [[YYTableViewCellData alloc] init];
            data.type = RegisterTableCellTypeInput;
            data.tableViewCellRowHeight = 53;
            YYTableViewCellInfoModel *info = [[YYTableViewCellInfoModel alloc] init];
            info.propertyKey = @"Social_1";
            info.ismust = 0;
            info.title = NSLocalizedString(@"请填写公众号",nil);
            data.object = info;
            [array addObject:data];
        }
        if (YES) {
            YYTableViewCellData *data = [[YYTableViewCellData alloc] init];
            data.type = RegisterTableCellTypeIconTitle;
            data.useDynamicRowHeight = YES;
            YYTableViewCellInfoModel *info = [[YYTableViewCellInfoModel alloc] init];
            info.ismust = 0;
            info.title = NSLocalizedString(@"新浪微博",nil);
            info.tipStr = @"reg_weibo_icon";
            data.object = info;
            [array addObject:data];
        }
        if (YES) {
            YYTableViewCellData *data = [[YYTableViewCellData alloc] init];
            data.type = RegisterTableCellTypeInput;
            data.tableViewCellRowHeight = 53;
            YYTableViewCellInfoModel *info = [[YYTableViewCellInfoModel alloc] init];
            info.propertyKey = @"Social_0";
            info.ismust = 0;
            info.title = NSLocalizedString(@"请填写新浪微博账号",nil);
            data.object = info;
            [array addObject:data];
        }
        if (YES) {
            YYTableViewCellData *data = [[YYTableViewCellData alloc] init];
            data.type = RegisterTableCellTypeIconTitle;
            data.useDynamicRowHeight = YES;
            YYTableViewCellInfoModel *info = [[YYTableViewCellInfoModel alloc] init];
            info.ismust = 0;
            info.title = NSLocalizedString(@"Instagram",nil);
            info.tipStr = @"reg_instagram_icon";
            data.object = info;
            [array addObject:data];
        }
        if (YES) {
            YYTableViewCellData *data = [[YYTableViewCellData alloc] init];
            data.type = RegisterTableCellTypeInput;
            data.tableViewCellRowHeight = 53;
            YYTableViewCellInfoModel *info = [[YYTableViewCellInfoModel alloc] init];
            info.propertyKey = @"Social_2";
            info.ismust = 0;
            info.title = NSLocalizedString(@"请填写Instagram账号",nil);
            data.object = info;
            [array addObject:data];
        }
        if (YES) {
            YYTableViewCellData *data = [[YYTableViewCellData alloc] init];
            data.type = RegisterTableCellTypeIconTitle;
            data.useDynamicRowHeight = YES;
            YYTableViewCellInfoModel *info = [[YYTableViewCellInfoModel alloc] init];
            info.ismust = 0;
            info.title = NSLocalizedString(@"Facebook",nil);
            info.tipStr = @"reg_facebook_icon";
            data.object = info;
            [array addObject:data];
        }
        if (YES) {
            YYTableViewCellData *data = [[YYTableViewCellData alloc] init];
            data.type = RegisterTableCellTypeInput;
            data.tableViewCellRowHeight = 53;
            YYTableViewCellInfoModel *info = [[YYTableViewCellInfoModel alloc] init];
            info.propertyKey = @"Social_3";
            info.ismust = 0;
            info.title = NSLocalizedString(@"请填写Facebook账号",nil);
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
}

-(void)deleteUpdatePhoto{
    NSArray *data = nil;
    YYTableViewCellData *cellData =nil;
    YYTableViewCellInfoModel *values = nil;
    if(self.uploadImgType == 0){
        
    }else{
        data = [self.cellDataArrays objectAtIndex:2];
        cellData = [data objectAtIndex:3];
        values = cellData.object;
        YYTableViewCellInfoModel *infoModel = values;
        NSArray *valueArr = [infoModel.value componentsSeparatedByString:@","];
        NSMutableArray *tmpValueArr = [[NSMutableArray alloc] initWithArray:valueArr];

        [tmpValueArr removeObjectAtIndex:(self.uploadImgType-1)];
        infoModel.value = [tmpValueArr componentsJoinedByString:@","];

        if(self.uploadImgType > [self.uploadImgs count]){
        }else{
            [self.uploadImgs removeObjectAtIndex:(self.uploadImgType-1)];
        }
    }
    [self.tableView reloadData];
}

-(void)showProtocolView:(NSString *)nowTitle protocolType:(NSString*)protocolType{
    if(!_ProtocolViewIsShow){
        _ProtocolViewIsShow = YES;
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
            ws.ProtocolViewIsShow = NO;
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

#pragma mark - --------------other----------------------
-(void)showYellowUserCheckAlert{
    //    身份审核中
    [[YYYellowPanelManage instance] showYellowUserCheckAlertPanel:@"Main" andIdentifier:@"YYUserCheckAlertViewController" checkStyle:ECheckStyleToBeConfirm andCallBack:^(NSArray *value) {
        if (self.cancelButtonClicked) {
            self.cancelButtonClicked();
        }
        [self.navigationController popViewControllerAnimated:YES];
    }];
    YYUser *user = [YYUser currentUser];
    user.status = [NSString stringWithFormat:@"%ld",YYReqStatusCode300];
    [user saveUserData];
}

@end
