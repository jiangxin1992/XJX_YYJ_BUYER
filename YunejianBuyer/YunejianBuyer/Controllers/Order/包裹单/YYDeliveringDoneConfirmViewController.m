//
//  YYDeliveringDoneConfirmViewController.m
//  yunejianDesigner
//
//  Created by yyj on 2018/7/3.
//  Copyright © 2018年 Apple. All rights reserved.
//

#import "YYDeliveringDoneConfirmViewController.h"

// c文件 —> 系统文件（c文件在前）

// 控制器

// 自定义视图
#import "YYNavView.h"
#import "YYPickingListNullCell.h"
#import "YYDeliverDoneTotalPriceCell.h"
#import "YYDeliverDoneConfirmStyleInfoCell.h"

// 接口

// 分类

// 自定义类和三方类（ cocoapods类 > model > 工具类 > 其他）
#import "YYOrderInfoModel.h"
#import "YYStylesAndTotalPriceModel.h"

@interface YYDeliveringDoneConfirmViewController ()<UITableViewDelegate,UITableViewDataSource>

@property (nonatomic, strong) YYNavView *navView;
@property (nonatomic, strong) UITableView *tableView;

@property (nonatomic, strong) NSArray *undeliveredStylesArray;//这里放的style数据

@end

@implementation YYDeliveringDoneConfirmViewController

#pragma mark - --------------生命周期--------------
- (void)viewDidLoad {
    [super viewDidLoad];
    [self SomePrepare];
    [self UIConfig];
}
- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    // 进入埋点
    [MobClick beginLogPageView:kYYPageDeliveringDoneConfirm];
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    // 退出埋点
    [MobClick endLogPageView:kYYPageDeliveringDoneConfirm];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}
#pragma mark - --------------SomePrepare--------------
- (void)SomePrepare {
    [self PrepareData];
    [self PrepareUI];
}
- (void)PrepareData {

}
- (void)PrepareUI {
    self.view.backgroundColor = _define_white_color;

    _navView = [[YYNavView alloc] initWithTitle:NSLocalizedString(@"订单改动内容",nil) WithSuperView:self.view haveStatusView:YES];
    WeakSelf(ws);
    self.navView.goBackBlock = ^{
        [ws goBack:nil];
    };
}

#pragma mark - --------------UIConfig----------------------
- (void)UIConfig {
    [self createTableView];
}
-(void)createTableView{
    WeakSelf(ws);
    _tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
    [self.view addSubview:_tableView];
    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    _tableView.delegate = self;
    _tableView.dataSource = self;
    [_tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(ws.navView.mas_bottom).with.offset(0);
        make.left.right.bottom.mas_equalTo(0);
    }];
}

#pragma mark - --------------系统代理----------------------
#pragma mark - TableViewDelegate

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(!_currentYYOrderInfoModel){
        return 0;
    }

    if(indexPath.row%2 == 1){
        return [YYPickingListNullCell cellHeight];
    }

    if(indexPath.row == _undeliveredStylesArray.count*2){
        return UITableViewAutomaticDimension;
    }

    CGFloat confirmCellHeight = 105 + 46;
    NSInteger cellIndex = indexPath.row/2;
    YYOrderStyleModel *orderStyleModel = _undeliveredStylesArray[cellIndex];
    for (YYOrderOneColorModel *orderOneColorModel in orderStyleModel.colors) {
        NSInteger sizeCount = orderOneColorModel.sizes.count;
        confirmCellHeight += (sizeCount*50 + 20);
    }
    if(!cellIndex){
        confirmCellHeight += 46;
    }
    return confirmCellHeight;
}
- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 10;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if(!_currentYYOrderInfoModel){
        return 0;
    }
    return _undeliveredStylesArray.count*2 + 1;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(!_currentYYOrderInfoModel){
        static NSString *cellid = @"cellid";
        UITableViewCell *cell = [_tableView dequeueReusableCellWithIdentifier:cellid];
        if(!cell){
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellid];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
        }
        return cell;
    }

    if(indexPath.row%2 == 1){
        static NSString *cellid = @"YYPickingListNullCell";
        YYPickingListNullCell *cell = [_tableView dequeueReusableCellWithIdentifier:cellid];
        if(!cell){
            cell = [[YYPickingListNullCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellid];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
        }
        return cell;
    }

    if(indexPath.row == _undeliveredStylesArray.count*2){
        static NSString *cellid = @"YYDeliverDoneTotalPriceCell";
        YYDeliverDoneTotalPriceCell *cell = [_tableView dequeueReusableCellWithIdentifier:cellid];
        if(!cell){
            cell = [[YYDeliverDoneTotalPriceCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellid];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
        }
        cell.stylesAndTotalPriceModel = _stylesAndTotalPriceModel;
        cell.nowStylesAndTotalPriceModel = _nowStylesAndTotalPriceModel;
        cell.curType = _currentYYOrderInfoModel.curType;
        [cell updateUI];
        return cell;
    }

    static NSString *cellid = @"YYDeliverDoneConfirmStyleInfoCell";
    YYDeliverDoneConfirmStyleInfoCell *cell = [_tableView dequeueReusableCellWithIdentifier:cellid];
    if(!cell){
        cell = [[YYDeliverDoneConfirmStyleInfoCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellid];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    NSInteger cellIndex = indexPath.row/2;
    if(!cellIndex){
        cell.isFirstCell = YES;
    }else{
        cell.isFirstCell = NO;
    }
    cell.orderStyleModel = _undeliveredStylesArray[cellIndex];
    [cell updateUI];
    return cell;
}

#pragma mark - --------------自定义代理/block----------------------

#pragma mark - --------------自定义响应----------------------
-(void)goBack:(id)sender {
    if(_cancelButtonClicked){
        _cancelButtonClicked();
    }
}

#pragma mark - --------------自定义方法----------------------
-(void)updateUI{
    _undeliveredStylesArray = [_currentYYOrderInfoModel getUndeliveredStylesAfterDelivering];
    [_tableView reloadData];
}
#pragma mark - --------------other----------------------

@end
