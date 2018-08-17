//
//  YYOrderOtherCloseReqDealViewController.m
//  YunejianBuyer
//
//  Created by Apple on 16/4/20.
//  Copyright © 2016年 Apple. All rights reserved.
//

// c文件 —> 系统文件（c文件在前）

// 控制器
#import "YYOrderOtherCloseReqDealViewController.h"

// 自定义视图
#import "YYNavView.h"
#import "YYOrderOtherCloseReqCell.h"

// 接口

// 分类

// 自定义类和三方类（ cocoapods类 > model > 工具类 > 其他）

@interface YYOrderOtherCloseReqDealViewController ()<YYTableCellDelegate>

@property (weak, nonatomic) IBOutlet UIView *containerView;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, strong) YYNavView *navView;

@end

@implementation YYOrderOtherCloseReqDealViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navView = [[YYNavView alloc] initWithTitle:NSLocalizedString(@"处理订单",nil) WithSuperView:self.view haveStatusView:YES];
    WeakSelf(ws);
    self.navView.goBackBlock = ^{
        [ws goBack];
    };
    
    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.tableView registerNib:[UINib nibWithNibName:@"YYOrderOtherCloseReqCell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:@"YYOrderOtherCloseReqCell"];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)goBack {
    if(self.cancelButtonClicked){
        self.cancelButtonClicked();
    }
}

#pragma mark - myTableview
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{

    return 400;
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    YYOrderOtherCloseReqCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"YYOrderOtherCloseReqCell" forIndexPath:indexPath];
    cell.delegate = self;
    [cell updateUI];
    return cell;
}

-(void)btnClick:(NSInteger)row section:(NSInteger)section andParmas:(NSArray *)parmas{
    if(self.reqDealButtonClicked){
        self.reqDealButtonClicked(parmas);
    }
}
@end
