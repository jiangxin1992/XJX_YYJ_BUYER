//
//  YYVisibleShopInfoViewController.m
//  YunejianBuyer
//
//  Created by chuanjun sun on 2017/10/25.
//  Copyright © 2017年 Apple. All rights reserved.
//

#import "YYVisibleShopInfoViewController.h"
// c文件 —> 系统文件（c文件在前）

// 控制器
#import "YYProtocolViewController.h"
#import "YYPerfectAuditingViewController.h"

// 自定义视图
#import "YYNavView.h"
#import "YYVisibleUploadImageView.h"
#import "YYVisibleShopInfoView.h"
#import "YYMoneyAndBrandView.h"
#import "YYVisibleSocialContactView.h"
#import "YYVisibleUploadPhotoButton.h"
// 接口
#import "YYOrderApi.h"
#import "YYAuditingApi.h"

// 分类
#import "UIActionSheet+JRPhoto.h"

// 自定义类和三方类（cocoapods类、model、工具类等） cocoapods类 —> model —> 其他
#import <MBProgressHUD.h>
#import "MLInputDodger.h"


@interface YYVisibleShopInfoViewController ()<YYVisibleUploadImageViewDelegate, YYVisibleShopInfoViewDelegate, JRPhotoImageDelegate, YYMoneyAndBrandViewDelegate, YYVisibleSocialContactDelegate>
/** 导航栏 */
@property (nonatomic, strong) YYNavView *navView;

/** scrollview */
@property (nonatomic, strong) UIScrollView *scrollView;

/** *协议 */
@property (nonatomic,assign) BOOL ProtocolViewIsShow;

/** 买手店照片 */
@property (nonatomic, strong) YYVisibleUploadImageView *uploadImage;
/** 买手店信息 */
@property (nonatomic, strong) YYVisibleShopInfoView *shopInfoView;
/** 微博等信息 */
@property (nonatomic, strong) YYVisibleSocialContactView *socialContact;

/** 正在处理的照骗 */
@property (nonatomic, strong) YYVisibleUploadPhotoButton *posterView;

/** 买手店照片地址集合 */
@property (nonatomic, strong) NSMutableArray *shopShowPhotoArray;
/** 合作品牌字典 */
@property (nonatomic, strong) NSMutableDictionary *brandDict;

/** 联系账号信息 */
@property (nonatomic, strong) NSMutableArray *contactInfoArray;

/** priceMax */
@property (nonatomic, copy) NSString *priceMax;
/** priceMin */
@property (nonatomic, copy) NSString *priceMin;

@end

@implementation YYVisibleShopInfoViewController
#pragma mark - --------------生命周期--------------
- (void)viewDidLoad {
    [super viewDidLoad];
    [self SomePrepare];
}

#pragma mark - --------------SomePrepare--------------
- (void)SomePrepare{
    [self PrepareData];
    [self PrepareUI];
}

- (void)PrepareData{
    self.shopShowPhotoArray = [NSMutableArray array];
    self.brandDict = [NSMutableDictionary dictionary];
    self.contactInfoArray = [NSMutableArray arrayWithArray:@[@"", @"", @"", @""]];
}


#pragma mark - --------------系统代理----------------------


#pragma mark - --------------自定义代理/block----------------------
#pragma mark - 法人和商务拍照
- (void)YYVisibleUploadImageView:(YYVisibleUploadImageView *)view photo:(whoPhoto)photo{
    if (photo == shop) {
        [UIActionSheet SheetPhotoControl:self WithDelegate:self photoType:(photoTypeCamera|photoTypeAlbum) isEditing:NO sign:@"shop"];
    }else if (photo == man){
        [UIActionSheet SheetPhotoControl:self WithDelegate:self photoType:(photoTypeCamera|photoTypeAlbum) isEditing:NO sign:@"man"];
    }
}

#pragma mark - 店铺简介
- (void)YYVisibleShopInfoViewDescContent:(YYVisibleShopInfoView *)view content:(NSString *)content{
    self.model.introduction = content;
}

#pragma mark - 店铺展示照
// 添加展示照
- (void)YYVisibleShopInfoViewPosterImage:(YYVisibleShopInfoView *)view Button:(YYVisibleUploadPhotoButton *)button{
    [UIActionSheet SheetPhotoControl:self WithDelegate:self photoType:(photoTypeCamera|photoTypeAlbum) isEditing:NO sign:@"poster"];
    self.posterView = button;
}

// 删除
- (void)YYVisibleShopInfoViewDeleteImage:(YYVisibleShopInfoView *)view Button:(YYVisibleUploadPhotoButton *)button{
    // 记录地址
    [self.shopShowPhotoArray removeObjectAtIndex:button.tag];

    // 展示图片的高度，需要动态计算
    CGFloat buttonW = ([UIScreen mainScreen].bounds.size.width - 52)/3;
    // 三个一行。所以在第2和第5个的时候，重新计算高度
    if (self.shopShowPhotoArray.count > 5) {

        [self.shopInfoView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.height.mas_equalTo(240 + buttonW*3 + 15);
        }];

        // 动态计算高度
        [self.view layoutIfNeeded];
        CGFloat height = CGRectGetMaxY(self.socialContact.frame);
        self.scrollView.contentSize = CGSizeMake(self.view.bounds.size.width, height);
    }else if (self.shopShowPhotoArray.count > 2){

        [self.shopInfoView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.height.mas_equalTo(240 + buttonW*2 + 15);
        }];

        // 动态计算高度
        [self.view layoutIfNeeded];
        CGFloat height = CGRectGetMaxY(self.socialContact.frame);
        self.scrollView.contentSize = CGSizeMake(self.view.bounds.size.width, height);
    }else {
        [self.shopInfoView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.height.mas_equalTo(240 + buttonW + 15);
        }];
        
        // 动态计算高度
        [self.view layoutIfNeeded];
        CGFloat height = CGRectGetMaxY(self.socialContact.frame);
        self.scrollView.contentSize = CGSizeMake(self.view.bounds.size.width, height);
    }
}

#pragma mark - 拍照回调
- (void)JRPhotoData:(NSData *)data sign:(NSString *)sign{
    UIImage *image = [UIImage imageWithData:data];
    WeakSelf(ws);
    if (image) {
        if (![YYCurrentNetworkSpace isNetwork]) {
            [YYToast showToastWithView:self.view title:kNetworkIsOfflineTips andDuration:kAlertToastDuration];
        }else{

            [MBProgressHUD showHUDAddedTo:self.view animated:YES];
            [YYOrderApi uploadImage:image size:2.0f andBlock:^(YYRspStatusAndMessage *rspStatusAndMessage, NSString *imageUrl, NSError *error) {
                [MBProgressHUD hideAllHUDsForView:ws.view animated:YES];
                if (imageUrl && [imageUrl length] > 0) {

                    if ([sign isEqualToString:@"shop"]) {
                        // 店铺营业执照
                        self.model.licenceFile = imageUrl;
                        self.uploadImage.shopPhoto = data;
                    }else if([sign isEqualToString:@"man"]){
                        // 法人身份证照片
                        self.model.legalPersonFiles = imageUrl;
                        self.uploadImage.manPhoto = data;
                    }else if([sign isEqualToString:@"poster"]){
                        // 店铺展示照片
                        [self.shopInfoView showNextPhotoButtonWithTag:self.posterView.tag imageData:data];
                        // 展示图片的高度，需要动态计算
                        CGFloat buttonW = ([UIScreen mainScreen].bounds.size.width - 52)/3;
                        // 记录地址
                        [self.shopShowPhotoArray addObject:imageUrl];

                        // 三个一行。所以在第2和第5个的时候，重新计算高度
                        if (self.posterView.tag == 2) {
                            [self.shopInfoView mas_updateConstraints:^(MASConstraintMaker *make) {
                                make.height.mas_equalTo(240 + buttonW*2 + 15);
                            }];

                            // 动态计算高度
                            [self.view layoutIfNeeded];
                            CGFloat height = CGRectGetMaxY(self.socialContact.frame);
                            self.scrollView.contentSize = CGSizeMake(self.view.bounds.size.width, height);

                        }else if (self.posterView.tag == 5){
                            [self.shopInfoView mas_updateConstraints:^(MASConstraintMaker *make) {
                                make.height.mas_equalTo(240 + buttonW*3 + 15);
                            }];

                            // 动态计算高度
                            [self.view layoutIfNeeded];
                            CGFloat height = CGRectGetMaxY(self.socialContact.frame);
                            self.scrollView.contentSize = CGSizeMake(self.view.bounds.size.width, height);
                        }
                    }
                }
                NSLog(@"imageUrl: %@",imageUrl);
            }];
        }
    }
}

#pragma mark - 品牌和价格文本输入回调
- (void)YYMoneyAndBrandView:(YYMoneyAndBrandView *)view inputTag:(NSInteger)tag content:(NSString *)content{
    switch (tag) {
        case 0:{
            self.priceMin = content;
        }
            break;
        case 1:{
            self.priceMax = content;
        }
            break;
        case 2:{
            NSString *key = [NSString stringWithFormat:@"%li", (long)tag];
            self.brandDict[key] = content;
        }
            break;
        case 3:{
            NSString *key = [NSString stringWithFormat:@"%li", (long)tag];
            self.brandDict[key] = content;
        }
            break;
        case 4:{
            NSString *key = [NSString stringWithFormat:@"%li", (long)tag];
            self.brandDict[key] = content;
        }
            break;
        case 5:{
            NSString *key = [NSString stringWithFormat:@"%li", (long)tag];
            self.brandDict[key] = content;
        }
            break;
        case 6:{
            NSString *key = [NSString stringWithFormat:@"%li", (long)tag];
            self.brandDict[key] = content;
        }
            break;
        case 7:{
            NSString *key = [NSString stringWithFormat:@"%li", (long)tag];
            self.brandDict[key] = content;
        }
            break;
        case 8:{
            NSString *key = [NSString stringWithFormat:@"%li", (long)tag];
            self.brandDict[key] = content;
        }
            break;

        default:
            break;
    }

}

#pragma mark - 联系方式回调 微信、新浪、ins、facebook
- (void)YYVisibleSocialContactView:(YYVisibleSocialContactView *)view withTag:(NSInteger)tag content:(NSString *)content{
    self.contactInfoArray[tag] = content;
}


#pragma mark - --------------自定义响应----------------------
- (void)submitButtonClick{
    // 1, 判断必填项
    if ([self.model.licenceFile isEqualToString:@""]||!self.model.licenceFile) {
        [YYToast showToastWithTitle:NSLocalizedString(@"上传店铺营业执照", nil) andDuration:kAlertToastDuration];
        return;
    }

    if ([self.model.legalPersonFiles isEqualToString:@""]||!self.model.legalPersonFiles) {
        [YYToast showToastWithTitle:NSLocalizedString(@"上传法人身份证 （正面照）", nil) andDuration:kAlertToastDuration];
        return;
    }

    if ([self.model.introduction isEqualToString:@""]||!self.model.introduction) {
        [YYToast showToastWithTitle:NSLocalizedString(@"请输入买手店简介", nil) andDuration:kAlertToastDuration];
        return;
    }

    if (!self.shopShowPhotoArray.count) {
        [YYToast showToastWithTitle:NSLocalizedString(@"上传照片", nil) andDuration:kAlertToastDuration];
        return;
    }

    if ((([self.priceMax isEqualToString:@""] || !self.priceMax)|| ([self.priceMin isEqualToString:@""]||!self.priceMin))) {
        [YYToast showToastWithTitle:NSLocalizedString(@"款式零售价范围", nil) andDuration:kAlertToastDuration];
        return;
    }else{
        self.model.priceMin = [self.priceMin floatValue];
        self.model.priceMax = [self.priceMax floatValue];
    }

    if (!self.brandDict.count) {
        [YYToast showToastWithTitle:NSLocalizedString(@"列举合作品牌", nil) andDuration:kAlertToastDuration];
        return;
    }

    if (!self.socialContact.isAgree) {
        [YYToast showToastWithTitle:NSLocalizedString(@"隐私权保护声明", nil) andDuration:kAlertToastDuration];
        return;
    }

    // 2, 拼接买手店照片
     NSString *shopString = [self.shopShowPhotoArray componentsJoinedByString:@","];
    self.model.storeImgs = shopString;

    // 3, 拼接合作品牌（更改为["aa","bb"]这种格式）
    self.model.copBrands = self.brandDict.allValues;

    // 4， 拼接买手店信息，新浪、ins等
    NSString *wechat = self.contactInfoArray[0];
    NSString *xinlang = self.contactInfoArray[1];
    NSString *ins = self.contactInfoArray[2];
    NSString *fb = self.contactInfoArray[3];

    NSMutableArray *infos = [NSMutableArray array];
    if (![NSString isNilOrEmpty:wechat]) {
        NSDictionary *dict = @{@"socialType":@1, @"socialName": wechat};
        [infos addObject:dict];
    }
    if (![NSString isNilOrEmpty:xinlang]) {
        NSDictionary *dict = @{@"socialType":@0, @"socialName": xinlang};
        [infos addObject:dict];
    }

    if (![NSString isNilOrEmpty:ins]) {
        NSDictionary *dict = @{@"socialType":@3, @"socialName": ins};
        [infos addObject:dict];
    }

    if (![NSString isNilOrEmpty:fb]) {
        NSDictionary *dict = @{@"socialType":@2, @"socialName": fb};
        [infos addObject:dict];
    }

    self.model.userSocialInfos = infos;

    [YYAuditingApi postInvisibleWithModel:self.model AndBlock:^(YYRspStatusAndMessage *rspStatusAndMessage, NSError *error) {
        if (rspStatusAndMessage.status == YYReqStatusCode100) {
            YYPerfectAuditingViewController *audit = [[YYPerfectAuditingViewController alloc] init];
            [self.navigationController pushViewController:audit animated:YES];
        }else{
            [YYToast showToastWithTitle:rspStatusAndMessage.message andDuration:kAlertToastDuration];
        }
    }];
}

#pragma mark - --------------自定义方法----------------------
#pragma mark - 弹出协议
-(void)showProtocolView:(NSString *)nowTitle protocolType:(NSString*)protocolType{
    if(!_ProtocolViewIsShow){
        _ProtocolViewIsShow = YES;
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Account" bundle:[NSBundle mainBundle]];
        YYProtocolViewController *protocolViewController = [storyboard instantiateViewControllerWithIdentifier:@"YYProtocolViewController"];
        protocolViewController.nowTitle = nowTitle;
        protocolViewController.protocolType = protocolType;
        [self.navigationController pushViewController:protocolViewController animated:YES];
        WeakSelf(ws);
        [protocolViewController setCancelButtonClicked:^(){
            [ws.navigationController popViewControllerAnimated:YES];
            ws.ProtocolViewIsShow = NO;
        }];
    }
}

#pragma mark - --------------UI----------------------
// 创建子控件
- (void)PrepareUI{
    self.view.backgroundColor =_define_white_color;
    
    self.navView = [[YYNavView alloc] initWithTitle:NSLocalizedString(@"买手店入驻",nil) WithSuperView:self.view haveStatusView:YES];

    // 提交按钮
    UIButton *submitButton  = [[UIButton alloc] init];
    submitButton.backgroundColor = _define_black_color;
    submitButton.titleLabel.font = [UIFont systemFontOfSize:15];
    [submitButton addTarget:self action:@selector(submitButtonClick) forControlEvents:UIControlEventTouchUpInside];
    [submitButton setTitle:NSLocalizedString(@"提交审核", nil) forState:UIControlStateNormal];
    [self.view addSubview:submitButton];

    [submitButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.mas_equalTo(0);
        make.height.mas_equalTo(58);
        make.bottom.mas_equalTo(self.mas_bottomLayoutGuideTop).with.offset(0);
    }];

    UIScrollView *scrollView = [[UIScrollView alloc] init];
    self.scrollView = scrollView;
    scrollView.backgroundColor = [UIColor colorWithHex:@"EFEFEF"];
    [self.view addSubview:scrollView];
    WeakSelf(ws);
    [scrollView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.mas_equalTo(0);
        make.top.mas_equalTo(ws.navView.mas_bottom).with.offset(0);
        make.bottom.mas_equalTo(submitButton.mas_top).with.offset(0);
    }];

    // 身份证和商铺照片
    YYVisibleUploadImageView *uploadImage = [[YYVisibleUploadImageView alloc] init];
    uploadImage.delegate = self;
    self.uploadImage = uploadImage;
    [scrollView addSubview:uploadImage];

    [uploadImage mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(0);
        make.left.mas_equalTo(self.view.mas_left);
        make.right.mas_equalTo(self.view.mas_right);
        make.height.mas_equalTo(335);
    }];

    // 八个照片和简介
    YYVisibleShopInfoView *shopInfoView = [[YYVisibleShopInfoView alloc] init];
    self.shopInfoView = shopInfoView;
    shopInfoView.delegate = self;
    [scrollView addSubview:shopInfoView];

    // 展示图片的高度，需要动态计算
    CGFloat buttonW = ([UIScreen mainScreen].bounds.size.width - 52)/3;

    [shopInfoView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(uploadImage.mas_bottom).mas_offset(10);
        make.left.mas_equalTo(self.view.mas_left);
        make.right.mas_equalTo(self.view.mas_right);
        make.height.mas_equalTo(240+buttonW);
    }];

    // 价格/品牌
    YYMoneyAndBrandView *moneyAndBrand = [[YYMoneyAndBrandView alloc] init];
    moneyAndBrand.delegate = self;
    [scrollView addSubview:moneyAndBrand];

    [moneyAndBrand mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(shopInfoView.mas_bottom);
        make.left.mas_equalTo(self.view.mas_left);
        make.right.mas_equalTo(self.view.mas_right);
        make.height.mas_equalTo(376);
    }];

    // 微博等联系方式
    YYVisibleSocialContactView *socialContact = [[YYVisibleSocialContactView alloc] init];
    self.socialContact = socialContact;
    socialContact.delegate = self;

    [socialContact setAgreement:^(NSString *type, NSString *title) {
        [self showProtocolView:title protocolType:type];
    }];
    
    [scrollView addSubview:socialContact];

    [socialContact mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(moneyAndBrand.mas_bottom).mas_offset(10);
        make.left.mas_equalTo(self.view.mas_left);
        make.right.mas_equalTo(self.view.mas_right);
        make.height.mas_equalTo(418);
    }];

    // 动态计算高度
    [self.view layoutIfNeeded];
    CGFloat height = CGRectGetMaxY(socialContact.frame);
    scrollView.contentSize = CGSizeMake(self.view.bounds.size.width, height);

    self.view.shiftHeightAsDodgeViewForMLInputDodger = 40.0f;
    [self.view registerAsDodgeViewForMLInputDodger];
}

#pragma mark - --------------other----------------------

@end
