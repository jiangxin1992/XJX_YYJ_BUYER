//
//  YYAccountUserInfoViewController.m
//  YunejianBuyer
//
//  Created by yyj on 2017/8/15.
//  Copyright © 2017年 Apple. All rights reserved.
//

#import "YYAccountUserInfoViewController.h"

#import "YYModifyNameOrPhoneViewContrller.h"

#import "YYNavView.h"
#import "YYAccountUserInfoCell.h"
#import "MBProgressHUD.h"

#import "UIImage+Tint.h"

#import "YYUser.h"
#import "YYUserInfo.h"
#import "YYOrderApi.h"
#import "YYUserApi.h"
#import "AppDelegate.h"
#import "UserDefaultsMacro.h"

@interface YYAccountUserInfoViewController ()<UITableViewDelegate,UITableViewDataSource,UINavigationControllerDelegate,UIImagePickerControllerDelegate>

@property (nonatomic,strong) YYNavView *navView;
@property (nonatomic,strong) UITableView *tableview;

@end

@implementation YYAccountUserInfoViewController

#pragma mark - --------------生命周期--------------
- (void)viewDidLoad {
    [super viewDidLoad];
    [self SomePrepare];
    [self UIConfig];
}

#pragma mark - --------------SomePrepare--------------
- (void)SomePrepare
{
    [self PrepareData];
    [self PrepareUI];
}
- (void)PrepareData{}
- (void)PrepareUI{
    self.view.backgroundColor = _define_white_color;

    _navView = [[YYNavView alloc] initWithTitle:NSLocalizedString(@"个人账号信息",nil) WithSuperView:self.view haveStatusView:YES];
    WeakSelf(ws);
    self.navView.goBackBlock = ^{
        [ws GoBack:nil];
    };
}

#pragma mark - --------------UIConfig----------------------
-(void)UIConfig{
    [self CreateTableView];
}
-(void)CreateTableView
{
    WeakSelf(ws);
    _tableview = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
    [self.view addSubview:_tableview];
    //    消除分割线
    _tableview.separatorStyle = UITableViewCellSeparatorStyleNone;
    _tableview.delegate = self;
    _tableview.dataSource = self;
    [_tableview mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.bottom.mas_equalTo(0);
        make.top.mas_equalTo(ws.navView.mas_bottom).with.offset(0);
    }];
}

#pragma mark - --------------请求数据----------------------
-(void)uploadUserHeadImage:(UIImage *)image{
    WeakSelf(ws);
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [YYOrderApi uploadImage:image size:2.0f andBlock:^(YYRspStatusAndMessage *rspStatusAndMessage, NSString *imageUrl, NSError *error) {
        [MBProgressHUD hideAllHUDsForView:ws.view animated:YES];
        if (imageUrl
            && [imageUrl length] > 0) {
            NSLog(@"imageUrl: %@",imageUrl);
            self.userInfo.brandLogoName = imageUrl;
            YYUser *user = [YYUser currentUser];
            user.logo = imageUrl;
            [user saveUserData];
            [YYUserApi modifyLogoWithUrl:imageUrl andBlock:nil];
            [ws reloadTableView];
        }
    }];
}
#pragma mark - --------------系统代理----------------------
#pragma mark UITableViewDelegate
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.row == 0){
        return 70;
    }
    return 54;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 3;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellid = @"YYAccountUserInfoCell";
    YYAccountUserInfoCell *cell = [_tableview dequeueReusableCellWithIdentifier:cellid];
    if(!cell)
    {
        cell = [[YYAccountUserInfoCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellid ];
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    if(indexPath.row == 0){
        cell.UserInfoType = AccountUserInfoTypeUserHead;
    }else if(indexPath.row == 1){
        cell.UserInfoType = AccountUserInfoTypeUsername;
    }else if(indexPath.row == 2){
        cell.UserInfoType = AccountUserInfoTypePhone;
    }
    cell.userInfo = _userInfo;
    [cell UpdateUI];
    return cell;
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if(indexPath.row == 0){
        [self logoButtonAction];
    }else if(indexPath.row == 1){
        [self modifyUserInfo:AccountUserInfoTypeUsername];
    }else if(indexPath.row == 2){
        [self modifyUserInfo:AccountUserInfoTypePhone];
    }
}
#pragma mark UIImagePickerControllerDelegate
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    //    获取选择图片
    UIImage *image = [UIImage fixOrientation:info[UIImagePickerControllerEditedImage]];
    if (image) {
        //上传头像
        [self uploadUserHeadImage:image];
    }
    [picker dismissViewControllerAnimated:YES completion:nil];
}

-(void)imagePickerControllerDidCancel:(UIImagePickerController *)picker{
    [picker dismissViewControllerAnimated:YES completion:nil];
}
//#pragma mark - --------------自定义代理/block----------------------
#pragma mark - --------------自定义响应----------------------
-(void)GoBack:(id)sender {
    if(_cancelButtonClicked)
    {
        _cancelButtonClicked();
    }
}

#pragma mark - --------------自定义方法----------------------
#pragma mark 头像点击
-(void)logoButtonAction{
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary]) {
        UIImagePickerController *picker=[[UIImagePickerController alloc] init];
        picker.view.backgroundColor = _define_white_color;
        picker.delegate = self;
        picker.allowsEditing = YES;
        picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;

        [self.navigationController presentViewController:picker animated:YES completion:nil];
    }else
    {
        NSLog(@"无法打开相册");
    }
}
- (void)reloadTableView{
    [_tableview reloadData];
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
#pragma mark 缓存当前用户信息
- (void)saveCurrentUserInfoToDisk{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setObject:[NSKeyedArchiver archivedDataWithRootObject:self.userInfo] forKey:kUserInfoKey];
    [userDefaults synchronize];
}
#pragma mark 跳转修改用户名／电话界面
-(void)modifyUserInfo:(NSInteger)currentShowType{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Account" bundle:[NSBundle mainBundle]];
    YYModifyNameOrPhoneViewContrller *modifyNameOrPhoneViewContrller = [storyboard instantiateViewControllerWithIdentifier:@"YYModifyNameOrPhoneViewContrller"];
    modifyNameOrPhoneViewContrller.userInfo = self.userInfo;
    modifyNameOrPhoneViewContrller.currentShowType = currentShowType;
    [self.navigationController pushViewController:modifyNameOrPhoneViewContrller animated:YES];

    WeakSelf(ws);

    [modifyNameOrPhoneViewContrller setCancelButtonClicked:^(){
        [ws.navigationController popViewControllerAnimated:YES];
    }];

    [modifyNameOrPhoneViewContrller setModifySuccess:^(){
        [ws.navigationController popViewControllerAnimated:YES];
        if(_accountUserInfoCellBlock){
            _accountUserInfoCellBlock(@"reload_data");
        }
    }];
}

#pragma mark - --------------other----------------------

@end
