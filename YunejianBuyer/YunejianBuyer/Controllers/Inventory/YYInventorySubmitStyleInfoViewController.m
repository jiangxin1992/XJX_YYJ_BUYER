//
//  YYInventorySubmitStyleInfoViewController.m
//  YunejianBuyer
//
//  Created by Apple on 16/9/1.
//  Copyright © 2016年 Apple. All rights reserved.
//

#import "YYInventorySubmitStyleInfoViewController.h"

#import "YYNavigationBarViewController.h"
#import "YYInventoryTableStepCell.h"
#import "MBProgressHUD.h"
#import <MJRefresh.h>
#import "YYInventoryApi.h"
#import "YYInventoryOrderStyleTableViewCell.h"
#import "MLInputDodger.h"
#import "YYInventorySubmitStyleInfoCell.h"
#import "YYInventorySubmitStyleColorSizeCell.h"
#import "YYInventoryStyleDemandModel.h"

@interface YYInventorySubmitStyleInfoViewController ()<YYTableCellDelegate>
@property (weak, nonatomic) IBOutlet UIView *containerView;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIButton *submitBtn;
@property (nonatomic,weak) UIView *noDataView;
@property (strong, nonatomic)NSMutableArray *listArray;
@property (strong, nonatomic)YYInventoryStyleColorInfoModel *infoModel;
@end

@implementation YYInventorySubmitStyleInfoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]];
    YYNavigationBarViewController *navigationBarViewController = [storyboard instantiateViewControllerWithIdentifier:@"YYNavigationBarViewController"];
    navigationBarViewController.previousTitle = @"";
    //self.navigationBarViewController = navigationBarViewController;
    if(_viewType == 1){
        navigationBarViewController.nowTitle = NSLocalizedString(@"我要补货",nil);
        [_submitBtn setTitle:NSLocalizedString(@"发布补货需求",nil) forState:UIControlStateNormal];
    }else if(_viewType == 2){
        navigationBarViewController.nowTitle = NSLocalizedString(@"我有库存",nil);
        [_submitBtn setTitle:NSLocalizedString(@"提交库存",nil) forState:UIControlStateNormal];
    }
    [_containerView insertSubview:navigationBarViewController.view atIndex:0];
    //[_containerView addSubview:navigationBarViewController.view];
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
            if(ws.cancelButtonClicked){
                ws.cancelButtonClicked();
            }
            blockVc = nil;
        }
    }];
    self.tableView.shiftHeightAsDodgeViewForMLInputDodger = 44.0f+5.0f;
    [self.tableView registerAsDodgeViewForMLInputDodger];
    
    [self.tableView registerNib:[UINib nibWithNibName:@"YYInventorySubmitStyleInfoCell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:@"YYInventorySubmitStyleInfoCell"];
    [self.tableView registerNib:[UINib nibWithNibName:@"YYInventorySubmitStyleColorSizeCell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:@"YYInventorySubmitStyleColorSizeCell"];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;

    [self addHeader];

    [_tableView registerNib:[UINib nibWithNibName:@"YYInventoryTableStepCell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:@"YYInventoryTableStepCell"];
    
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [self loadStyleInfoFromServerWithendRefreshing:NO];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    // 进入埋点
    [MobClick beginLogPageView:kYYPageInventorySubmitStyleInfo];
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    // 退出埋点
    [MobClick endLogPageView:kYYPageInventorySubmitStyleInfo];
}

- (void)loadStyleInfoFromServerWithendRefreshing:(BOOL)endrefreshing{
    WeakSelf(ws);
    NSInteger styleId = [_styleInfoModel.styleId integerValue];
    NSString *colorIds = _styleInfoModel.colorIds;
    NSString *type = ((_viewType == 1)?@"DEMAND":@"INVENTORY");
    __block BOOL blockEndrefreshing = endrefreshing;

    [YYInventoryApi getStyleColorInfo:styleId colorIds:colorIds type:type adnBlock:^(YYRspStatusAndMessage *rspStatusAndMessage, YYInventoryStyleColorInfoModel *infoModel, NSError *error) {
        if (rspStatusAndMessage.status == kCode100) {
            ws.infoModel = infoModel;
        }else{
            ws.infoModel = nil;
        }
        if(blockEndrefreshing){
            [self.tableView.mj_header endRefreshing];
            [self.tableView.mj_footer endRefreshing];
        }
        [ws reloadTableData];
        
        [MBProgressHUD hideAllHUDsForView:ws.view animated:YES];
    }];
    
}

- (void)addHeader
{
    WeakSelf(ws);
    MJRefreshNormalHeader *header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        if (![YYCurrentNetworkSpace isNetwork]) {
            [YYToast showToastWithTitle:kNetworkIsOfflineTips andDuration:kAlertToastDuration];
            [ws.tableView.mj_header endRefreshing];
            return;
        }
        [ws loadStyleInfoFromServerWithendRefreshing:YES];
    }];
    self.tableView.mj_header = header;
    self.tableView.mj_header.automaticallyChangeAlpha = YES;
    header.lastUpdatedTimeLabel.hidden = YES;
}

-(void)reloadTableData{
    //    if(self.isSearchView){
    //        self.noDataView.hidden = YES;
    //    }else{
    //        if ([self.listArray count] <= 0) {
    //            self.noDataView.hidden = NO;
    //        }else{
    //            self.noDataView.hidden = YES;
    //        }
    //    }
    [self.tableView reloadData];
    
}

#pragma mark - UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if(section == 0 || section == 1){
        return 1;
    }else{
        if([_infoModel.colors count] > 0){
            return [_infoModel.colors count];
        }else{
            return 1;
        }
    }
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if(indexPath.section == 0){
        static NSString *CellIdentifier = @"YYInventoryTableStepCell";
        YYInventoryTableStepCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
        if(_viewType == 1){
            [cell updateCellInfo:@[@[NSLocalizedString(@"选择合作品牌",nil),@"true"],@[NSLocalizedString(@"选择款式",nil),@"true"],@[NSLocalizedString(@"添加补货需求",nil),@"true"]]];
        }else if(_viewType == 2){
            [cell updateCellInfo:@[@[NSLocalizedString(@"选择合作品牌",nil),@"true"],@[NSLocalizedString(@"选择款式",nil),@"true"],@[NSLocalizedString(@"添加库存",nil),@"true"]]];
        }
        return cell;
    }if(indexPath.section == 1){
        YYInventorySubmitStyleInfoCell *cell = [tableView dequeueReusableCellWithIdentifier:@"YYInventorySubmitStyleInfoCell"];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.styleInfoModel = _styleInfoModel;
        [cell updateUI];
        return cell;
    }else{
        
        if([_infoModel.colors count] > 0){//
//            if(indexPath.row%2 == 0){
//                UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"YYInventoryViewLineCell1"];
//                if(cell == nil){
//                    cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"YYOrderNullCell"];
//                    cell.contentView.backgroundColor = [UIColor colorWithHex:@"efefef"];
//                }
//                return cell;
//            }else{
                YYInventorySubmitStyleColorSizeCell *cell = [tableView dequeueReusableCellWithIdentifier:@"YYInventorySubmitStyleColorSizeCell" forIndexPath:indexPath];
                //cell.styleInfoModel = _styleInfoModel;
            NSInteger  cellRow = indexPath.row;///2 ;
                cell.colorModel = [_infoModel.colors objectAtIndex:cellRow];
                cell.sizeArr = _infoModel.sizes;
                cell.indexPath = indexPath;
                cell.delegate = self;
                [cell updateUI];
                if([_infoModel.colors count] == (indexPath.row+1)){
                    [cell setLineStyle:1];
                }else{
                    [cell setLineStyle:0];
                }
                return cell;
            //}
        }else{
            static NSString* reuseIdentifier = @"YYInventoryViewNullCell";
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:reuseIdentifier forIndexPath:indexPath];
            if(self.noDataView == nil){
            self.noDataView = addNoDataView_phone(cell.contentView,[NSString stringWithFormat:@"%@|icon:nodata_icon|40",NSLocalizedString(@"暂无相关数据哦~",nil)],nil,nil);
            }
            cell.backgroundColor = [UIColor whiteColor];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            return cell;
        }
    }
}


#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if(indexPath.section == 0 || indexPath.section == 1){
        return 81;
    }else{
        if([_infoModel.colors count] > 0){//
            NSInteger maxSizeCount = kMaxSizeCount;
            if ([_infoModel.sizes count] <= kMaxSizeCount) {
                maxSizeCount = [_infoModel.sizes count];
            }
            
            return maxSizeCount*50 +20;
            
        }else{
            return SCREEN_HEIGHT-65-60-81;
        }
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{

}

-(void)clearStyleInfo{
    for (YYInventoryOneColorModel *oneColorModel in _infoModel.colors) {
        for (YYOrderSizeModel *sizeModel  in oneColorModel.sizeAmounts) {
            if([sizeModel.amount integerValue] > 0){
                sizeModel.amount = [NSNumber numberWithInt:0];
            }
        }
    }
    [self.tableView reloadData];
}

-(void)btnClick:(NSInteger)row section:(NSInteger)section andParmas:(NSArray *)parmas{
    if(_infoModel){//_infoModel.szie
        YYInventoryOneColorModel *oneColorModel = [_infoModel.colors objectAtIndex:row];
        NSInteger index = [[parmas objectAtIndex:0] integerValue];
        NSInteger value = [[parmas objectAtIndex:1] integerValue];
        YYOrderSizeModel *sizeModel =  [oneColorModel.sizeAmounts objectAtIndex:index];
        //NSInteger amount = MAX(0, [sizeModel.amount integerValue]);
        sizeModel.amount = [NSNumber numberWithInteger:value];
    }
}

- (IBAction)submitBtnHandler:(id)sender {
    if([_infoModel.colors count] == 0){
        return;
    }
    BOOL hasStyleAmount = NO;
    for (YYInventoryOneColorModel *oneColorModel in _infoModel.colors) {
        for (YYOrderSizeModel *sizeModel  in oneColorModel.sizeAmounts) {
            if([sizeModel.amount integerValue] > 0){
                hasStyleAmount = YES;
                break;
            }
        }
    }
    if(!hasStyleAmount){
        [YYToast showToastWithView:self.view title:NSLocalizedString(@"请添加款式尺寸数量！",nil) andDuration:kAlertToastDuration];
        return;
    };
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];

    YYInventoryStyleDemandModel *styleDemandModel = [[YYInventoryStyleDemandModel alloc] init];
    styleDemandModel.designerId = _styleInfoModel.designerId;
    styleDemandModel.styleId = _styleInfoModel.styleId;
    styleDemandModel.colors = _infoModel.colors;
    NSData *modelData = [[styleDemandModel toDictionary] mj_JSONData];
    WeakSelf(ws);
    if(_viewType == 1){
        [YYInventoryApi addDemand:modelData adnBlock:^(YYRspStatusAndMessage *rspStatusAndMessage, NSError *error) {
            [MBProgressHUD hideAllHUDsForView:ws.view animated:YES];
            if(rspStatusAndMessage.status == kCode100){
                [ws clearStyleInfo];
                [ws.navigationController popToRootViewControllerAnimated:YES];
            }
            [YYToast showToastWithTitle:rspStatusAndMessage.message andDuration:kAlertToastDuration];
        }];
    }else if(_viewType == 2){
        [YYInventoryApi addStore:modelData adnBlock:^(YYRspStatusAndMessage *rspStatusAndMessage, NSError *error) {
            [MBProgressHUD hideAllHUDsForView:ws.view animated:YES];

            if(rspStatusAndMessage.status == kCode100){
                [ws clearStyleInfo];
                [ws.navigationController popToRootViewControllerAnimated:YES];
            }

            [YYToast showToastWithTitle:rspStatusAndMessage.message andDuration:kAlertToastDuration];
            
        }];
    }
}
#pragma mark - Other

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
