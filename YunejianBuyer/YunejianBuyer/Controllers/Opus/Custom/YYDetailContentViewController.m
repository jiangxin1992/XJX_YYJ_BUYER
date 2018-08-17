//
//  YYDetailContentViewController.m
//  Yunejian
//
//  Created by yyj on 15/7/26.
//  Copyright (c) 2015年 yyj. All rights reserved.
//

#import "YYDetailContentViewController.h"

#import "YYOpusApi.h"
#import "YYBurideApi.h"

#import "UIImage+YYImage.h"

#import "AppDelegate.h"
#import "YYStyleDetailViewController.h"
#import "YYDetailContentTopViewCell.h"
#import "YYDetailContentParamsViewCellNew.h"
#import "YYDetailContentBrandViewCell.h"
#import "MBProgressHUD.h"
#import "YYSeriesInfoModel.h"
#import "YYOrderInfoModel.h"

@interface YYDetailContentViewController ()<YYTableCellDelegate,UITableViewDataSource,UITableViewDelegate>
@property (weak, nonatomic) IBOutlet UITableView *MyTableView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *MyTableViewTopLayout;

@property(nonatomic) NSInteger tmpContentOffsety; //0

@property (weak, nonatomic) IBOutlet UIButton *addShoppingCarButton;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *addShoppingCarButtonBottomLayout;

@property (weak, nonatomic) IBOutlet UIButton *collectionButton;
@property (weak, nonatomic) IBOutlet UIView *buttonBackView;

@property (nonatomic,strong) YYStyleInfoModel *styleInfoModel;

@property (nonatomic,strong) NSMutableArray *colorsArry;
@property(nonatomic) NSInteger currentColorIndexToShow; //0

@property (nonatomic,assign) NSComparisonResult orderDueCompareResult;

@property (nonatomic,assign) CGFloat desHeight;
@end

@implementation YYDetailContentViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    [self SomePrepare];
    [self RequestData];
    [self updateUI];
}
#pragma mark - SomePrepare
-(void)SomePrepare
{
    [self PrepareData];
    [self PrepareUI];
}

-(void)PrepareData{}
-(void)PrepareUI{
    _MyTableViewTopLayout.constant = kIPhoneX?kStatusBarHeight:0;
    _addShoppingCarButtonBottomLayout.constant = kIPhoneX?34.f:0.f;
    _MyTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    _MyTableView.separatorInset = UIEdgeInsetsMake(0, 40, 0,40 );
    [self updateCollectionButtonEdgeInsets];
    
    self.currentColorIndexToShow = 0;
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.desHeight = 0;
}

#pragma mark - RequestData
-(void)RequestData{
    [self loadStyleInfo];
}
- (void)loadStyleInfo{
    WeakSelf(ws);
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [YYOpusApi getStyleInfoByStyleId:[_currentOpusStyleModel.id longValue] orderCode:nil andBlock:^(YYRspStatusAndMessage *rspStatusAndMessage, YYStyleInfoModel *styleInfoModel, NSError *error) {
       if (rspStatusAndMessage.status == kCode100) {
           ws.styleInfoModel = styleInfoModel;
           ws.desHeight = [YYDetailContentParamsViewCellNew getHeightWithColorModel:_styleInfoModel atColorIndex:self.currentColorIndexToShow];
           [ws updateCollectionButtonEdgeInsets];
           [ws loadSeriesInfo];
       }else{
            [YYToast showToastWithView:ws.view title:rspStatusAndMessage.message andDuration:kAlertToastDuration];
            [MBProgressHUD hideAllHUDsForView:ws.view animated:YES];
       }
    }];

    // 埋点 pv
    [YYBurideApi addStatPVWithOpusDetailId:[NSString stringWithFormat:@"%@", _currentOpusStyleModel.id]];
}


-(void)loadSeriesInfo{
    if(_opusSeriesModel.designerId && _styleInfoModel.style.seriesId){
        WeakSelf(ws);
        [YYOpusApi getConnSeriesInfoWithId:[_opusSeriesModel.designerId integerValue] seriesId:[_styleInfoModel.style.seriesId integerValue] andBlock:^(YYRspStatusAndMessage *rspStatusAndMessage, YYSeriesInfoDetailModel *infoDetailModel, NSError *error) {
            if (rspStatusAndMessage.status == kCode100) {
                
                ws.opusSeriesModel.id = infoDetailModel.series.id;
                ws.opusSeriesModel.orderDueTime = infoDetailModel.series.orderDueTime;
                
                ws.styleInfoModel.style.designerId = infoDetailModel.series.designerId;
                ws.styleInfoModel.style.designerBrandLogo = infoDetailModel.series.designerBrandLogo;
                ws.styleInfoModel.style.designerBrandName = infoDetailModel.series.designerBrandName;
                ws.styleInfoModel.style.designerEmail = infoDetailModel.series.designerEmail;
                ws.styleInfoModel.style.brandDescription = infoDetailModel.series.brandDescription;
                ws.styleInfoModel.style.designerName = infoDetailModel.series.designerName;
                
                [ws.MyTableView reloadData];
                [ws updateUI];
                [MBProgressHUD hideAllHUDsForView:ws.view animated:YES];
            }else{
                [ws.MyTableView reloadData];
                [MBProgressHUD hideAllHUDsForView:ws.view animated:YES];
            }
        }];
    }else{
        [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
    }
}

#pragma mark - updateUI
- (void)updateUI{
    NSComparisonResult compareResult = NSOrderedDescending;
    if(_opusSeriesModel.orderDueTime !=nil){
        compareResult = compareNowDate(_opusSeriesModel.orderDueTime);
    }
    self.orderDueCompareResult = compareResult;
    
    if ( self.orderDueCompareResult == NSOrderedAscending) {
        self.addShoppingCarButton.backgroundColor = [UIColor colorWithHex:@"d3d3d3"];
        self.buttonBackView.backgroundColor = [UIColor colorWithHex:@"d3d3d3"];
        [YYToast showToastWithTitle:NSLocalizedString(@"此系列已过最晚下单日期，不能下单。",nil) andDuration:kAlertToastDuration];
        return;
    }
    self.addShoppingCarButton.backgroundColor = [UIColor blackColor];
    self.buttonBackView.backgroundColor = [UIColor blackColor];
}

#pragma mark - SomeAction
//取消收藏/收藏
- (IBAction)collectionAction:(id)sender {

    WeakSelf(ws);
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [YYOpusApi updateStyleCollectStateByStyleId:[_currentOpusStyleModel.id longValue] isCollect:!_collectionButton.selected andBlock:^(YYRspStatusAndMessage *rspStatusAndMessage, NSError *error) {
        if (rspStatusAndMessage.status == kCode100) {
            ws.styleInfoModel.style.collect = @(!_collectionButton.selected);
            [ws updateCollectionButtonEdgeInsets];
            NSString *alertStr = @"";
            if([ws.styleInfoModel.style.collect boolValue]){
                alertStr = NSLocalizedString(@"收藏成功，请到账户-我的收藏 中查看",nil);
            }else{
                alertStr = NSLocalizedString(@"取消收藏",nil);
            }
            [YYToast showToastWithView:ws.view title:alertStr andDuration:kAlertToastDuration];
        }else{
            [YYToast showToastWithView:ws.view title:rspStatusAndMessage.message andDuration:kAlertToastDuration];
        }
        [MBProgressHUD hideAllHUDsForView:ws.view animated:YES];
    }];
}
-(void)updateCollectionButtonEdgeInsets{
    if(_collectionButton){
        if(_styleInfoModel){
            if([_styleInfoModel.style.collect boolValue]){
                _collectionButton.selected = YES;
            }else{
                _collectionButton.selected = NO;
            }
        }
        
        NSString *titleStr = @"";
        NSString *imageStr = @"";
        if(_collectionButton.selected){
            titleStr = NSLocalizedString(@"已收藏",nil);
            imageStr = @"has_collection";
        }else{
            titleStr = NSLocalizedString(@"收藏",nil);
            imageStr = @"not_collection";
        }
        CGFloat getWidth = getWidthWithHeight(999, titleStr, [UIFont systemFontOfSize:12]);
        CGFloat getHeight = getHeightWithWidth(999, titleStr, [UIFont systemFontOfSize:12]);
        UIImage *image = [UIImage imageNamed:imageStr];
        self.collectionButton.titleEdgeInsets =UIEdgeInsetsMake(0.5 * image.size.height + 3, -0.5 * image.size.width, -0.5 * image.size.height, 0.5 * image.size.width);
        self.collectionButton.imageEdgeInsets =UIEdgeInsetsMake(-0.5 * getHeight - 3, 0.5 * getWidth, 0.5 * getHeight, -0.5 * getWidth);
    }
}
- (IBAction)addShoppingCarAction:(id)sender {
    if(_opusSeriesModel.id == nil){
        return;
    }
    
    if ( self.orderDueCompareResult == NSOrderedAscending) {
        [YYToast showToastWithTitle:NSLocalizedString(@"此系列已过最晚下单日期，不能下单。",nil) andDuration:kAlertToastDuration];
        return;
    }
    
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    NSInteger moneyType = -1;
    if (_styleInfoModel) {
        moneyType = [_styleInfoModel.style.curType integerValue];
    }
    NSInteger cartMoneyType = -1;
    if(appDelegate.cartModel == nil){
        cartMoneyType = -1;
    }else{
        cartMoneyType = getMoneyType([appDelegate.cartModel.designerId integerValue]);
    }
    
    if(cartMoneyType > -1 && moneyType != cartMoneyType){
        [YYToast showToastWithView:self.view title:NSLocalizedString(@"购物车中存在其他币种的款式，不能将此款式加入购物车。您可以清空购物车后，将此款式加入购物车。",nil) andDuration:kAlertToastDuration];
        return;
    }
    
    UIView *superView = self.styleDetailViewController.view;
    [appDelegate showShoppingView:NO styleInfoModel:_styleInfoModel seriesModel:_opusSeriesModel opusStyleModel:nil currentYYOrderInfoModel:nil parentView:superView fromBrandSeriesView:NO WithBlock:nil];
    
}
-(void)btnClick:(NSInteger)row section:(NSInteger)section andParmas:(NSArray *)parmas{
    NSString *type = [parmas objectAtIndex:0];
    if([type isEqualToString:@"ColorIndexToShow"]){
        NSInteger index = [[parmas objectAtIndex:1] integerValue];
        _currentColorIndexToShow = index;
        //[_MyTableView reloadData];
    }
    
}
#pragma mark - UITableViewDelegate

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 3;
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if(indexPath.row == 0){
        CGFloat tempHeight = 176 + SCREEN_WIDTH + 10;
        if(_styleInfoModel){
            if(_styleInfoModel.colorImages && _styleInfoModel.colorImages.count > 0){
                NSInteger lineNum = (_styleInfoModel.colorImages.count/5) + 1;
                tempHeight += (lineNum - 1)*(32 + 3 + 25);
            }
        }
        return tempHeight;

    }else if(indexPath.row == 1){
        return _desHeight;
    }else if(indexPath.row == 2){
        return 186 + 10;
    }
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    if(indexPath.row == 0){
        YYDetailContentTopViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"YYDetailContentTopViewCell" forIndexPath:indexPath];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.styleInfoModel = _styleInfoModel;
        cell.indexPath = indexPath;
        cell.delegate = self;
        cell.currentColorIndexToShow = _currentColorIndexToShow;
        cell.selectTaxType = _selectTaxType;
        [cell updateUI];
        return cell;
    }else if(indexPath.row == 1){
        YYDetailContentParamsViewCellNew *cell = [tableView dequeueReusableCellWithIdentifier:@"YYDetailContentParamsViewCellNew"];
        if(!cell){
            cell = [[YYDetailContentParamsViewCellNew alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"YYDetailContentParamsViewCellNew"];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
        }
        [cell updateUI:self.styleInfoModel atColorIndex:self.currentColorIndexToShow];
        return cell;
    }else if(indexPath.row == 2){
        YYDetailContentBrandViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"YYDetailContentBrandViewCell"];
        if(!cell){
            cell = [[YYDetailContentBrandViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"YYDetailContentBrandViewCell" WithBlock:^(NSString *type) {
                if([type isEqualToString:@"enter_designer"]){
                    if(_detailContentBlock){
                        _detailContentBlock(@"enter_designer",_styleInfoModel);
                    }
                }
            }];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
        }
        cell.styleInfoModel = _styleInfoModel;
        [cell updateUI];
        return cell;
    }
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"YYOrderNullCell"];
    if(cell == nil){
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"YYOrderNullCell"];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    cell.backgroundColor = [UIColor clearColor];
    return cell;
}

#pragma mark - Other

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
@end
