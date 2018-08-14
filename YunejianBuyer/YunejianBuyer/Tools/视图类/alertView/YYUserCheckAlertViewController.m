//
//  YYUserCheckAlertViewController.m
//  Yunejian
//
//  Created by Apple on 15/12/9.
//  Copyright © 2015年 yyj. All rights reserved.
//

#import "YYUserCheckAlertViewController.h"

// c文件 —> 系统文件（c文件在前）

// 控制器

// 自定义视图

// 接口

// 分类
#import "UIView+UpdateAutoLayoutConstraints.h"

// 自定义类和三方类（ cocoapods类 > model > 工具类 > 其他）
#import "YYStepViewCell.h"
#import "YYTableViewCellInfoModel.h"
#import "YYTableViewCellData.h"
#import "YYStepInfoModel.h"

@interface YYUserCheckAlertViewController ()<UITableViewDelegate,UITableViewDataSource>

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *tipImageHeightLayout;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *tipImageWidthLayout;

@property (weak, nonatomic) IBOutlet UIImageView *tipImageView;
@property (weak, nonatomic) IBOutlet UILabel *descLabel;
@property (weak, nonatomic) IBOutlet UIButton *doBtn;

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIView *tableViewLine;
@property (weak, nonatomic) IBOutlet UIView *tableViewLineView;

@property (weak, nonatomic) IBOutlet UIImageView *checkSuccessImage;
@property (weak, nonatomic) IBOutlet UILabel *checkSuccessLabel;

@property (nonatomic, strong) YYStepInfoModel *stepInfoModel;

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UIButton *backButton;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *navHeightLayout;

@end

@implementation YYUserCheckAlertViewController
#pragma mark - --------------生命周期--------------
- (void)viewDidLoad {
    [super viewDidLoad];
    [self SomePrepare];
}

#pragma mark - --------------SomePrepare--------------
- (void)SomePrepare
{
    [self PrepareData];
    [self PrepareUI];
}
- (void)PrepareData{
    self.stepInfoModel = [[YYStepInfoModel alloc] init];
    self.stepInfoModel.stepStyle = StepStyleFourStep;
    self.stepInfoModel.firtTitle = NSLocalizedString(@"提交入驻申请",nil);
    self.stepInfoModel.secondTitle = NSLocalizedString(@"验证邮箱",nil);
    self.stepInfoModel.thirdTitle = NSLocalizedString(@"提交验证信息",nil);
    self.stepInfoModel.fourthTitle = NSLocalizedString(@"成功入驻",nil);
    self.stepInfoModel.currentStep = 2;
}
- (void)PrepareUI{
    _navHeightLayout.constant = kStatusBarAndNavigationBarHeight;

    _navHeightLayout.constant = kStatusBarAndNavigationBarHeight;

    _tableView.delegate = self;
    _tableView.dataSource = self;
    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;

    _checkSuccessImage.hidden = YES;
    _checkSuccessLabel.hidden = YES;

    _titleLabel.text = NSLocalizedString(@"买手店身份验证",nil);
    [_backButton setTitle:NSLocalizedString(@"返回登录",nil) forState:UIControlStateNormal];

    _checkSuccessImage.image = [UIImage imageNamed:@"account_verify"];
    _checkSuccessImage.contentMode = UIViewContentModeScaleAspectFit;
    _checkSuccessLabel.text = NSLocalizedString(@"上百个国内外设计师品牌，等您来挑选", nil);

}

//#pragma mark - --------------UIConfig----------------------
//-(void)UIConfig{}

//#pragma mark - --------------请求数据----------------------

#pragma mark - --------------系统代理----------------------
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 1;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 82;
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 0.1;
}
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return 0.1;
}
- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    YYStepViewCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([YYStepViewCell class])];
    if (!cell) {
        cell = [[YYStepViewCell alloc] initWithStepStyle:self.stepInfoModel.stepStyle reuseIdentifier:NSStringFromClass([YYStepViewCell class])];
        cell.firtTitle = self.stepInfoModel.firtTitle;
        cell.secondTitle = self.stepInfoModel.secondTitle;
        cell.thirdTitle = self.stepInfoModel.thirdTitle;
        cell.fourthTitle = self.stepInfoModel.fourthTitle;
    }
    cell.currentStep = self.stepInfoModel.currentStep;
    [cell updateUI];
    return cell;
}


//#pragma mark - --------------自定义代理/block----------------------


#pragma mark - --------------自定义响应----------------------
- (IBAction)closeBtnHandler:(id)sender {
    if(self.cancelButtonClicked){
        self.cancelButtonClicked();
    }
}

- (IBAction)doBtnHandler:(id)sender {
    if(self.modifySuccess){
        self.modifySuccess();
    }
}

#pragma mark - --------------自定义方法----------------------
-(void)UpdateUI{
    if(_checkStyle == ECheckStyleConfirmOK){
        //审核通过
        _tipImageView.hidden = NO;
        _descLabel.hidden = YES;

        _tipImageHeightLayout.constant = 60;
        _tipImageWidthLayout.constant = 60;
        _tipImageView.image = [UIImage imageNamed:@"verify_success"];
        _doBtn.hidden = NO;
        [_doBtn setTitle:NSLocalizedString(@"进入我的 YCO SYSTEM", nil) forState:UIControlStateNormal];

        [self setSelectStep:3];
        [self tableViewHide:NO];
        [self successViewHide:YES];

    }else if(_checkStyle == ECheckStyleConfirmReject){
        //审核拒绝
        _tipImageView.hidden = NO;
        _descLabel.hidden = NO;

        _tipImageHeightLayout.constant = 60;
        _tipImageWidthLayout.constant = 60;
        _tipImageView.image = [UIImage imageNamed:@"verify_failure"];
        _descLabel.text = NSLocalizedString(@"您可以在邮件中查看审核失败的原因", nil);
        _doBtn.hidden = NO;
        [_doBtn setTitle:NSLocalizedString(@"再次验证买手店身份", nil) forState:UIControlStateNormal];

        [self setSelectStep:2];
        [self tableViewHide:NO];
        [self successViewHide:YES];

    }else if(_checkStyle == ECheckStyleToBeConfirm){
        //待审核
        _tipImageView.hidden = NO;
        _descLabel.hidden = NO;

        _tipImageHeightLayout.constant = 99;
        _tipImageWidthLayout.constant = 87;
        _tipImageView.image = [UIImage imageNamed:@"account_verify_pending"];
        _descLabel.text = NSLocalizedString(@"买手店身份审核中，请耐心等待2-3个工作日", nil);
        _doBtn.hidden = YES;

        [self setSelectStep:2];
        [self tableViewHide:NO];
        [self successViewHide:YES];

    }else if(_checkStyle == ECheckStyleNeedSubmit){
        //待提交材料
        _tipImageView.hidden = YES;
        _descLabel.hidden = YES;

        [_doBtn setTitle:NSLocalizedString(@"即刻身份验证", nil) forState:UIControlStateNormal];

        [self tableViewHide:YES];
        [self successViewHide:NO];

    }
    [_tableView reloadData];
}

- (void)setSelectStep:(NSUInteger)step {
    self.stepInfoModel.currentStep = step;
}

-(void)tableViewHide:(BOOL )isHide{
    _tableView.hidden = isHide;
    _tableViewLine.hidden = isHide;
    _tableViewLineView.hidden = isHide;
}

-(void)successViewHide:(BOOL )isHide{
    _checkSuccessImage.hidden = isHide;
    _checkSuccessLabel.hidden = isHide;
}

-(void)checkViewHide:(BOOL )isHide{
    _tipImageView.hidden = isHide;
    _descLabel.hidden = isHide;
}

#pragma mark - --------------other----------------------
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
@end
