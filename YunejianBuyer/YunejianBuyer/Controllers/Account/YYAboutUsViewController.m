//
//  YYAboutUsViewController.m
//  Yunejian
//
//  Created by yyj on 15/9/17.
//  Copyright (c) 2015年 yyj. All rights reserved.
//

// c文件 —> 系统文件（c文件在前）

// 控制器
#import "YYAboutUsViewController.h"
#import "YYProtocolViewController.h"

// 自定义视图
#import "YYNavView.h"

// 接口

// 分类

// 自定义类和三方类（ cocoapods类 > model > 工具类 > 其他）
#import <StoreKit/StoreKit.h>

@interface YYAboutUsViewController ()<UITableViewDataSource,UITableViewDelegate, SKStoreProductViewControllerDelegate>

@property(nonatomic,strong) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIView *containerView;
@property (nonatomic,assign) BOOL ProtocolViewIsShow;

@property (nonatomic, strong) YYNavView *navView;

@end

@implementation YYAboutUsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self SomePrepare];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    // 进入埋点
    [MobClick beginLogPageView:kYYPageAboutUs];
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    // 退出埋点
    [MobClick endLogPageView:kYYPageAboutUs];
}

#pragma mark - SomePrepare
-(void)SomePrepare
{
    [self PrepareData];
    [self PrepareUI];
}
-(void)PrepareData{
    _ProtocolViewIsShow = NO;
}
-(void)PrepareUI{
    self.navView = [[YYNavView alloc] initWithTitle:NSLocalizedString(@"关于我们",nil) WithSuperView:self.view haveStatusView:YES];
    WeakSelf(ws);
    self.navView.goBackBlock = ^{
        [ws goBack];
    };
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
    return 8;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    NSString *CellIdentifier = @"MyCell0";
    if(indexPath.row ==1 || indexPath.row == 5 || indexPath.row == 7 ){
        CellIdentifier = @"MyCell0";
    }else if(indexPath.row == 2){
        CellIdentifier = @"MyCell1";
    }else if(indexPath.row == 3){
        CellIdentifier = @"MyCell2";
    }else if(indexPath.row == 4){
        CellIdentifier = @"MyCell3";
    }else if(indexPath.row == 6){
        CellIdentifier = @"MyCell4";
    }else if(indexPath.row == 0){
        CellIdentifier = @"MyCellInfo";
    }
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if(indexPath.row ==1 || indexPath.row == 5 || indexPath.row == 7 ){
        UILabel *lable1 = (UILabel *)[cell viewWithTag:10001];
        UILabel *lable2 = (UILabel *)[cell viewWithTag:10002];
        if( indexPath.row ==7){
            lable1.hidden = NO;
            lable2.hidden = YES;
        }else{
            lable1.hidden = NO;
            lable2.hidden = NO;
        }
    }
    
    if (indexPath.row == 0) {
        UILabel *lable = (UILabel *)[cell viewWithTag:89990];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        if (lable) {
            NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
            NSString *projectName =  [infoDictionary objectForKey:@"CFBundleName"];
            lable.text = [NSString stringWithFormat:@"%@ %@",projectName,kYYCurrentVersion];
        }
        
    }
    
    if (cell == nil){
        [NSException raise:@"DetailCell == nil.." format:@"No cells with matching CellIdentifier loaded from your storyboard"];
    }
    return cell;
}


#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if(indexPath.row ==1 || indexPath.row == 5 || indexPath.row == 7){
        return 10;
    }else if(indexPath.row ==0){
        return 130;
    }else{
        return 54;
    }
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.row == 2) {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:KYYYcoFoundationURL]];
    }else if (indexPath.row == 3) {
        [self showProtocolView:NSLocalizedString(@"隐私权保护声明",nil) protocolType:@"secrecyAgreement"];
    }else if (indexPath.row == 4) {
        [self showProtocolView:NSLocalizedString(@"服务协议",nil) protocolType:@"serviceAgreement"];
    }else if (indexPath.row == 6){
        [self goToAppStore];
    }
}
#pragma mark - SomeAction
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

- (void)goBack {
    [self cancelClicked:nil];
}

-(void)goToAppStore
{
    //    NSString *str = [NSString stringWithFormat:
    //                     @"itms-apps://ax.itunes.apple.com/WebObjects/MZStore.woa/wa/viewContentsUserReviews?type=Purple+Software&id=%@",kYYAppID]; //appID 解释如下
    //    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:str]];
    
    SKStoreProductViewController *storeProductViewController = [[SKStoreProductViewController alloc] init];
    // Configure View Controller
    [storeProductViewController setDelegate:self];
    [storeProductViewController loadProductWithParameters:@{SKStoreProductParameterITunesItemIdentifier : kYYAppID}
                                          completionBlock:^(BOOL result, NSError *error) {
                                              if (error) {
                                                  NSLog(@"Error %@ with User Info %@.", error, [error userInfo]);
                                              } else {
                                                  // Present Store Product View Controller
                                                  [self presentViewController:storeProductViewController animated:YES completion:nil];
                                              }
                                          }];
    
}
- (IBAction)cancelClicked:(id)sender{
    if (_cancelButtonClicked) {
        _cancelButtonClicked();
    }
}
- (void)productViewControllerDidFinish:(SKStoreProductViewController *)viewController {
    [self dismissViewControllerAnimated:YES completion:nil];
}
@end
