//
//  YYIndexTableView.m
//  YunejianBuyer
//
//  Created by yyj on 2018/8/24.
//  Copyright © 2018年 Apple. All rights reserved.
//

#import "YYIndexTableView.h"

// c文件 —> 系统文件（c文件在前）

// 控制器

// 自定义视图
#import "YYUserOrderCell.h"
#import "YYIndexVerifyCell.h"
#import "YYIndexNoDataCell.h"
#import "YYIndexHotBrandCell.h"
#import "YYIndexTableHeadView.h"
#import "YYIndexSectionHeadCell.h"
#import "YYIndexOrderingPageCell.h"
#import "YYIndexOrderingNoDataCell.h"

// 接口

// 分类

// 自定义类和三方类（ cocoapods类 > model > 工具类 > 其他）
#import <MJRefresh.h>

#import "YYUser.h"
#import "YYOrderingListModel.h"
#import "YYHotDesignerBrandsModel.h"

#import "YYIndexViewLogic.h"

#define NoDataCellHeight 250

#define IndexOrderCellHeight 71

#define IndexOrderingCellHeight 194 + 17
#define IndexOrderingCellNoDataHeight 165

#define IndexVerifyCellHeight 317
#define IndexPendingCellHeight 250

#define IndexHotBrandCellHeight 316
#define IndexHotBrandNoSeriesCellHeight 114

#define IndexSectionHeadOrder 50
#define IndexSectionHeadOrdering 60
#define IndexSectionHeadVerify 10
#define IndexSectionHeadHotBrand 60

@interface YYIndexTableView()<UITableViewDataSource,UITableViewDelegate>

@property (nonatomic, strong) YYIndexTableHeadView *headView;

@end

@implementation YYIndexTableView

#pragma mark - --------------Life Cycle--------------
- (instancetype)initWithFrame:(CGRect)frame style:(UITableViewStyle)style{
    self = [super initWithFrame:frame style:style];
    if(self){
        [self SomePrepare];
        [self UIConfig];
    }
    return self;
}
#pragma mark - --------------SomePrepare--------------
- (void)SomePrepare {
    [self PrepareData];
    [self PrepareUI];
}
- (void)PrepareData {
    self.delegate = self;
    self.dataSource = self;
}
- (void)PrepareUI {
    self.backgroundColor = [UIColor colorWithHex:@"f8f8f8"];
    self.separatorStyle = UITableViewCellSeparatorStyleNone;
}

#pragma mark - --------------UIConfig----------------------
- (void)UIConfig {
    [self addHeader];
}
//MJRefresh
- (void)addHeader
{
    WeakSelf(ws);
    // 添加下拉刷新头部控件
    MJRefreshNormalHeader *header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        // 进入刷新状态就会回调这个Block
        if(ws.headerWithRefreshingBlock){
            ws.headerWithRefreshingBlock();
        }
    }];
    header.lastUpdatedTimeLabel.hidden = YES;
    self.mj_header = header;
    self.mj_header.automaticallyChangeAlpha = YES;
}
#pragma mark - --------------Request----------------------
//- (void)RequestData {
//
//}

#pragma mark - --------------SystemDelegate----------------------
#pragma mark UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    if([_indexViewLogic isAllowRendering]){
        if([[YYUser currentUser] hasPermissionsToVisit]){
            return 3;
        }else{
            return 2;
        }
    }
    return 1;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if([_indexViewLogic isAllowRendering]){
        if([[YYUser currentUser] hasPermissionsToVisit]){
            if(section == 2){
                if(_indexViewLogic.hotDesignerBrandsModelArray && _indexViewLogic.hotDesignerBrandsModelArray.count > 0){
                    NSInteger returnCount = _indexViewLogic.hotDesignerBrandsModelArray.count;
                    return returnCount;
                }
                return 0;
            }
        }
    }
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    WeakSelf(ws);
    if([_indexViewLogic isAllowRendering]){
        if(indexPath.section == 0){
            static NSString *cellid=@"YYUserOrderCell";
            YYUserOrderCell *userOrderCell=[self dequeueReusableCellWithIdentifier:cellid];
            if(!userOrderCell)
            {
                userOrderCell=[[YYUserOrderCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellid WithActionBlock:^(NSInteger pageIndex) {
                    if(ws.indexTableViewBlock){
                        ws.indexTableViewBlock(YYIndexTableViewUserActionTypeMoreOrder,pageIndex,nil,nil,nil);
                    }
                }];
                userOrderCell.selectionStyle = UITableViewCellSelectionStyleNone;
            }
            [userOrderCell updateUI];
            return userOrderCell;
        }else if(indexPath.section == 1){
            if([[YYUser currentUser] hasPermissionsToVisit]){
                if(_indexViewLogic.orderingListModel && _indexViewLogic.orderingListModel.result.count > 0){
                    static NSString *cellid=@"YYIndexOrderingPageCell";
                    YYIndexOrderingPageCell *cell=[tableView dequeueReusableCellWithIdentifier:cellid];
                    if(!cell)
                    {
                        cell=[[YYIndexOrderingPageCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellid WithBlock:^(NSString *type,YYOrderingListItemModel *listItemModel) {
                            if([type isEqualToString:@"card_click"]){
                                if(ws.indexTableViewBlock){
                                    ws.indexTableViewBlock(YYIndexTableViewUserActionTypeEnterOrderingDetail,0,listItemModel,nil,nil);
                                }
                            }
                        }];
                        cell.selectionStyle = UITableViewCellSelectionStyleNone;
                    }
                    cell.orderingListModel = _indexViewLogic.orderingListModel;
                    [cell updateUI];
                    return cell;
                }else{
                    static NSString *cellid=@"YYIndexOrderingNoDataCell";
                    YYIndexOrderingNoDataCell *cell=[tableView dequeueReusableCellWithIdentifier:cellid];
                    if(!cell)
                    {
                        cell=[[YYIndexOrderingNoDataCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellid WithBlock:nil];
                        cell.selectionStyle = UITableViewCellSelectionStyleNone;
                    }
                    return cell;
                }
            }else{

                static NSString *cellid=@"YYIndexVerifyCell";
                YYIndexVerifyCell *cell=[tableView dequeueReusableCellWithIdentifier:cellid];
                if(!cell)
                {
                    cell=[[YYIndexVerifyCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellid WithBlock:^(NSString *type) {
                        if([type isEqualToString:@"fillInformation"]){
                            //完善资料
                            if(ws.indexTableViewBlock){
                                ws.indexTableViewBlock(YYIndexTableViewUserActionTypeFillInformation,0,nil,nil,nil);
                            }
                        }
                    }];
                    cell.selectionStyle = UITableViewCellSelectionStyleNone;
                }
                [cell updateUI];
                return cell;
            }
        }else if(indexPath.section == 2){
            static NSString *cellid=@"YYIndexHotBrandCell";
            YYIndexHotBrandCell *cell=[tableView dequeueReusableCellWithIdentifier:cellid];
            if(!cell)
            {
                cell = [[YYIndexHotBrandCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellid WithBlock:^(NSString *type,YYHotDesignerBrandsModel *hotDesignerBrandsModel,YYHotDesignerBrandsSeriesModel *seriesModel) {
                    if([type isEqualToString:@"enter_brand"]){
                        //进入品牌主页
                        NSLog(@"enter_brand");
                        if(ws.indexTableViewBlock){
                            ws.indexTableViewBlock(YYIndexTableViewUserActionTypeEnterDesignerHomePage,0,nil,hotDesignerBrandsModel,nil);
                        }
                    }else if([type isEqualToString:@"enter_series"]){
                        //进入系列详情
                        NSLog(@"enter_series");
                        if(ws.indexTableViewBlock){
                            ws.indexTableViewBlock(YYIndexTableViewUserActionTypeEnterSeriesDetail,0,nil,nil,seriesModel);
                        }
                    }else if([type isEqualToString:@"change_status"]){
                        //修改当前用户与品牌的关联状态
                        NSLog(@"change_status");
                        if(ws.indexTableViewBlock){
                            ws.indexTableViewBlock(YYIndexTableViewUserActionTypeChangeStatus,0,nil,hotDesignerBrandsModel,nil);
                        }
                    }else if([type isEqualToString:@"more_brand"]){
                        //查看更多品牌
                        NSLog(@"more_brand");
                        if(ws.indexTableViewBlock){
                            ws.indexTableViewBlock(YYIndexTableViewUserActionTypeMoreBrandByNot,0,nil,nil,nil);
                        }
                    }
                }];
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
            }
            if(indexPath.row == _indexViewLogic.hotDesignerBrandsModelArray.count - 1){
                cell.isLastCell = YES;
            }else{
                cell.isLastCell = NO;
            }
            cell.hotDesignerBrandsModel = _indexViewLogic.hotDesignerBrandsModelArray[indexPath.row];
            [cell updateUI];
            return cell;
        }
    }
    static NSString *cellid = @"YYIndexNoDataCell";
    YYIndexNoDataCell *cell = [self dequeueReusableCellWithIdentifier:cellid];
    if(!cell)
    {
        cell = [[YYIndexNoDataCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellid];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    return cell;
}
#pragma mark UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return [self getHeadViewHeightInSection:section];
}
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    if([_indexViewLogic isAllowRendering] && (section == 0 || section == 1 || section == 2)){
        YYIndexSectionHeadCell *cell = [[YYIndexSectionHeadCell alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, [self getHeadViewHeightInSection:section])];
        if(section == 0){
            cell.sectionHeadType = EIndexSectionHeadOrder;
            cell.titleIsCenter = YES;
            cell.topLineIsHide = YES;
            cell.moreBtnIsShow = YES;
        }else if(section == 1){
            if([[YYUser currentUser] hasPermissionsToVisit]){
                cell.sectionHeadType = EIndexSectionHeadOrdering;
                cell.titleIsCenter = YES;
                cell.topLineIsHide = NO;
                cell.moreBtnIsShow = YES;
            }else{
                cell.sectionHeadType = EIndexSectionHeadVerify;
                cell.titleIsCenter = YES;
                cell.topLineIsHide = NO;
                cell.moreBtnIsShow = NO;
            }
        }else if(section == 2){
            cell.sectionHeadType = EIndexSectionHeadHot;
            cell.titleIsCenter = YES;
            cell.topLineIsHide = NO;
            cell.moreBtnIsShow = YES;
        }
        WeakSelf(ws);
        [cell setIndexSectionHeadBlock:^(NSString *type){
            if([type isEqualToString:@"more"]){
                if(cell.sectionHeadType == EIndexSectionHeadOrdering){
                    //更多订货会
                    if(ws.indexTableViewBlock){
                        ws.indexTableViewBlock(YYIndexTableViewUserActionTypeMoreOrdering,0,nil,nil,nil);
                    }
                }else if(cell.sectionHeadType == EIndexSectionHeadOrder){
                    //更多订单
                    if(ws.indexTableViewBlock){
                        ws.indexTableViewBlock(YYIndexTableViewUserActionTypeMoreOrder,0,nil,nil,nil);
                    }
                }else if(cell.sectionHeadType == EIndexSectionHeadHot){
                    //查看更多品牌
                    if(ws.indexTableViewBlock){
                        ws.indexTableViewBlock(YYIndexTableViewUserActionTypeMoreBrandByPush,0,nil,nil,nil);
                    }
                }
            }
        }];
        [cell updateUI];
        return cell;
    }
    UIView *view = [UIView getCustomViewWithColor:nil];
    return view;
}
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return 0.01;
}
- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section{
    UIView *footer = [[UIView alloc] init];
    footer.backgroundColor = _define_white_color;
    return footer;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if([_indexViewLogic isAllowRendering]){
        if(indexPath.section == 0){
            return IndexOrderCellHeight;
        }else if(indexPath.section == 1){
            if([[YYUser currentUser] hasPermissionsToVisit]){
                if(_indexViewLogic.orderingListModel && _indexViewLogic.orderingListModel.result.count > 0){
                    return IndexOrderingCellHeight;
                }else{
                    return IndexOrderingCellNoDataHeight;
                }
            }else{
                YYUser *user = [YYUser currentUser];
                NSInteger checkStatus = [user.checkStatus integerValue];
                if(checkStatus == 1 || checkStatus == 4){
                    return IndexVerifyCellHeight;
                }else if(checkStatus == 2){
                    return IndexPendingCellHeight;
                }else{
                    return IndexPendingCellHeight;
                }
                return IndexVerifyCellHeight;
            }
        }else if(indexPath.section == 2){
            return [self getHotCellHeightWithIndexPath:indexPath];
        }
    }
    return NoDataCellHeight;//显示那个nodata
}

#pragma mark - --------------CustomDelegate----------------------

#pragma mark - --------------Event Response----------------------

#pragma mark - --------------Getter/Setter Methods----------------------

#pragma mark - --------------Private Methods----------------------
- (void)reloadTableData{
    WeakSelf(ws);
    if([_indexViewLogic isAllowRendering]){
        if(!_headView){
            _headView = [[YYIndexTableHeadView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 214) WithBlock:^(NSString *type,NSInteger index) {
                if([type isEqualToString:@"banner_click"]){
                    // 点击banner
                    if(ws.indexTableViewBlock){
                        ws.indexTableViewBlock(YYIndexTableViewUserActionTypeEnterIndexBannerDetail,index,nil,nil,nil);
                    }
                }
            }];
            self.tableHeaderView = _headView;
        }
        _headView.bannerListModelArray = _indexViewLogic.bannerListModelArray;
        [_headView updateUI];
    }
    [self reloadData];
}
- (void)endRefreshing{
    [self.mj_header endRefreshing];
}
- (CGFloat)getHotCellHeightWithIndexPath:(NSIndexPath *)indexPath{
    if(![NSArray isNilOrEmpty:_indexViewLogic.hotDesignerBrandsModelArray]){
        if(_indexViewLogic.hotDesignerBrandsModelArray.count > indexPath.row){
            YYHotDesignerBrandsModel *brandsModel = _indexViewLogic.hotDesignerBrandsModelArray[indexPath.row];
            if(![NSArray isNilOrEmpty:brandsModel.seriesBoList]){
                if(indexPath.row == _indexViewLogic.hotDesignerBrandsModelArray.count - 1){
                    return IndexHotBrandCellHeight + 30;
                }else{
                    return IndexHotBrandCellHeight;
                }
            }else{
                return IndexHotBrandNoSeriesCellHeight;
            }
        }
    }
    return 0;
}
- (CGFloat)getHeadViewHeightInSection:(NSInteger)section{
    if([_indexViewLogic isAllowRendering]){
        if(section == 0){
            return IndexSectionHeadOrder;
        }else if(section == 1){
            if([[YYUser currentUser] hasPermissionsToVisit]){
                return IndexSectionHeadOrdering;
            }else{
                return IndexSectionHeadVerify;
            }
        }else if(section == 2){
            return IndexSectionHeadHotBrand;
        }
    }
    return 0.01;
}

@end
