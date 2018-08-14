//
//  YYInventoryStoreStyleInfoViewController.m
//  YunejianBuyer
//
//  Created by Apple on 16/9/2.
//  Copyright © 2016年 Apple. All rights reserved.
//

#import "YYInventoryStoreStyleInfoViewController.h"

#import "YYNavigationBarViewController.h"
#import "MBProgressHUD.h"
#import <MJRefresh.h>
#import "YYInventoryApi.h"
#import "MLInputDodger.h"
#import "YYInventoryStoreStyleInfoCell.h"
#import "YYInventorySubmitStyleColorSizeCell.h"
#import "YYInventoryStyleDemandModel.h"

@interface YYInventoryStoreStyleInfoViewController ()
@property (weak, nonatomic) IBOutlet UIView *containerView;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIButton *submitBtn;
@property (nonatomic,weak) UIView *noDataView;
@property (strong, nonatomic)NSMutableArray *listArray;
@property (strong, nonatomic)YYInventoryStyleColorInfoModel *infoModel;
@end

@implementation YYInventoryStoreStyleInfoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]];
    YYNavigationBarViewController *navigationBarViewController = [storyboard instantiateViewControllerWithIdentifier:@"YYNavigationBarViewController"];
    navigationBarViewController.previousTitle = @"";
    //self.navigationBarViewController = navigationBarViewController;
    if([_boardModel.hasInventory integerValue]){
        [_submitBtn setTitle:NSLocalizedString(@"保存修改",nil) forState:UIControlStateNormal];
        navigationBarViewController.nowTitle = NSLocalizedString(@"修改已添加库存",nil);
    }else{
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
    
    [self.tableView registerNib:[UINib nibWithNibName:@"YYInventoryStoreStyleInfoCell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:@"YYInventoryStoreStyleInfoCell"];
    [self.tableView registerNib:[UINib nibWithNibName:@"YYInventorySubmitStyleColorSizeCell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:@"YYInventorySubmitStyleColorSizeCell"];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;

    [self addHeader];
        
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [self loadStyleInfoFromServerWithendRefreshing:NO];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    // 进入埋点
    [MobClick beginLogPageView:kYYPageInventoryStore];
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    // 退出埋点
    [MobClick endLogPageView:kYYPageInventoryStore];
}


- (void)loadStyleInfoFromServerWithendRefreshing:(BOOL)endrefreshing{
    WeakSelf(ws);
    NSInteger styleId = [_boardModel.styleId integerValue];
    NSString *colorIds = [_boardModel.colorId stringValue];
    NSString *type = @"INVENTORY";
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
        
        [MBProgressHUD hideHUDForView:ws.view animated:YES];
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
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{

        if([_infoModel.colors count] > 0){
            return [_infoModel.colors count];
        }else{
            return 1;
        }
    
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    YYInventoryStoreStyleInfoCell *cell = [tableView dequeueReusableCellWithIdentifier:@"YYInventoryStoreStyleInfoCell"];
   // cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.boardModel = _boardModel;
    [cell updateUI];
    return cell;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 143;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
        if([_infoModel.colors count] > 0){//
            YYInventorySubmitStyleColorSizeCell *cell = [tableView dequeueReusableCellWithIdentifier:@"YYInventorySubmitStyleColorSizeCell" forIndexPath:indexPath];
            //cell.styleInfoModel = _styleInfoModel;
            NSInteger  cellRow = indexPath.row;///2 ;
            cell.colorModel = [_infoModel.colors objectAtIndex:cellRow];
            cell.sizeArr = _infoModel.sizes;
            cell.indexPath = indexPath;
            cell.delegate = self;
            [cell updateUI];
            if([_infoModel.colors count] == (indexPath.row+1)){
                [cell setLineStyle:-1];
            }else{
                [cell setLineStyle:-1];
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


#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{

        if([_infoModel.colors count] > 0){//
            NSInteger maxSizeCount = kMaxSizeCount;
            if ([_infoModel.sizes count] <= kMaxSizeCount) {
                maxSizeCount = [_infoModel.sizes count];
            }
            
            return maxSizeCount*50 +20;
            
        }else{
            return SCREEN_HEIGHT-65-60;
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
    styleDemandModel.designerId = _boardModel.designerId;
    styleDemandModel.styleId = _boardModel.styleId;
    styleDemandModel.colors = _infoModel.colors;
    NSData *modelData = [[styleDemandModel toDictionary] mj_JSONData];
    WeakSelf(ws);

        [YYInventoryApi addStore:modelData adnBlock:^(YYRspStatusAndMessage *rspStatusAndMessage, NSError *error) {
            [MBProgressHUD hideHUDForView:ws.view animated:YES];

            if(rspStatusAndMessage.status == kCode100){
                [ws clearStyleInfo];
                if(self.cancelButtonClicked){
                    self.cancelButtonClicked();
                }
            }
            
            [YYToast showToastWithTitle:rspStatusAndMessage.message andDuration:kAlertToastDuration];

        }];
    
}
#pragma mark - Other

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
