//
//  YYBuyerInfoViewController.m
//  YunejianBuyer
//
//  Created by Apple on 16/12/21.
//  Copyright © 2016年 Apple. All rights reserved.
//

#import "YYBuyerInfoViewController.h"

#import "YYNavigationBarViewController.h"
#import "YYBuyerModifyInfoViewController.h"

#import "YYBuyerInfoPicsViewCell.h"
#import "YYBuyerInfoAboutViewCell.h"
#import "YYBuyerInfoConactViewCell.h"
#import "MBProgressHUD.h"

#import "YYUserApi.h"

@interface YYBuyerInfoViewController ()<YYTableCellDelegate>
@property (weak, nonatomic) IBOutlet UIView *containerView;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIButton *editButton;
@property (nonatomic ,assign) NSInteger tableSelectedIndex;//0 1

@property (strong, nonatomic)YYBuyerHomeInfoModel *homeInfoModel;
@end

@implementation YYBuyerInfoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]];
    YYNavigationBarViewController *navigationBarViewController = [storyboard instantiateViewControllerWithIdentifier:@"YYNavigationBarViewController"];
    
    navigationBarViewController.previousTitle = @"";
    navigationBarViewController.nowTitle = NSLocalizedString(@"我的买手店主页",nil);
    
    [_containerView addSubview:navigationBarViewController.view];
    __weak UIView *_weakContainerView = _containerView;
    [navigationBarViewController.view mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(_weakContainerView.mas_top);
        make.left.equalTo(_weakContainerView.mas_left);
        make.bottom.equalTo(_weakContainerView.mas_bottom);
        make.right.equalTo(_weakContainerView.mas_right);
        
    }];
    WeakSelf(ws);
    
    __block YYNavigationBarViewController *blockVc = navigationBarViewController;
    
    [navigationBarViewController setNavigationButtonClicked:^(NavigationButtonType buttonType){
        if (buttonType == NavigationButtonTypeGoBack) {
            if (ws.cancelButtonClicked) {
                ws.cancelButtonClicked();
            }
            blockVc = nil;
        }
    }];
    
    self.tableSelectedIndex = 0;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self loadModelInfo];
}

#pragma mark - loadModelInfo
-(void)loadModelInfo{
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    WeakSelf(ws);
    [YYUserApi getBuyerHomeInfo:@"" andBlock:^(YYRspStatusAndMessage *rspStatusAndMessage, YYBuyerHomeInfoModel *infoModel, NSError *error) {
        [MBProgressHUD hideHUDForView:ws.view animated:YES];
        
        if(rspStatusAndMessage.status == kCode100){
            ws.homeInfoModel = infoModel;
            [ws.tableView reloadData];
        }else{
            [YYToast showToastWithView:ws.view title:rspStatusAndMessage.message andDuration:kAlertToastDuration];
        }
    }];
}

#pragma mark - TableViewDelegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
    return 1;
}


-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if(indexPath.section == 0){
        return 350;
    }else{
        if(_tableSelectedIndex == 0){
            return [YYBuyerInfoAboutViewCell cellHeight:_homeInfoModel];//244
        }else{
            return 450;
        }
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    if(indexPath.section == 0){
        YYBuyerInfoPicsViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"YYBuyerInfoPicsViewCell" forIndexPath:indexPath];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.indexPath = indexPath;
        cell.delegate = self;
        cell.selectedSegmentIndex  = _tableSelectedIndex;
        cell.homeInfoModel = _homeInfoModel;
        [cell updateUI];
        return cell;
    }else {
        if(_tableSelectedIndex == 1){
            YYBuyerInfoConactViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"YYBuyerInfoConactViewCell" forIndexPath:indexPath];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            cell.homeInfoModel = _homeInfoModel;
            [cell updateUI];
            return cell;
        }else{
            YYBuyerInfoAboutViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"YYBuyerInfoAboutViewCell" forIndexPath:indexPath];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            cell.homeInfoModel = _homeInfoModel;
            [cell updateUI];
            return cell;
        }
    }
}

#pragma mark - YYTableCellDelegate
-(void)btnClick:(NSInteger)row section:(NSInteger)section andParmas:(NSArray *)parmas{
    NSString *type = [parmas objectAtIndex:0];
    if([type isEqualToString:@"SegmentIndex"]){
        NSInteger index = [[parmas objectAtIndex:1] integerValue];
        _tableSelectedIndex = index;
        [self.tableView reloadData];
    }
}


#pragma mark - SomeAction
//点击编辑
- (IBAction)modifyHandler:(id)sender {
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Buyer" bundle:[NSBundle mainBundle]];
    YYBuyerModifyInfoViewController *buyerModifyInfoController = [storyboard instantiateViewControllerWithIdentifier:@"YYBuyerModifyInfoViewController"];
    buyerModifyInfoController.homeInfoModel = _homeInfoModel;
    WeakSelf(ws);
    [buyerModifyInfoController setCancelButtonClicked:^(){
        [ws.navigationController popViewControllerAnimated:YES];
    }];
    [self.navigationController pushViewController:buyerModifyInfoController animated:YES];
}


#pragma mark - Other
- (void)viewWillAppear:(BOOL)animated{
    if(!_homeInfoModel){
        [self loadModelInfo];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
@end
