//
//  YYIndexViewLogic.m
//  YunejianBuyer
//
//  Created by yyj on 2018/8/24.
//  Copyright © 2018年 Apple. All rights reserved.
//

#import "YYIndexViewLogic.h"

// c文件 —> 系统文件（c文件在前）

// 控制器

// 自定义视图

// 接口
#import "YYUserApi.h"
#import "YYConnApi.h"
#import "YYIndexApi.h"
#import "YYOpusApi.h"
#import "YYOrderingApi.h"

// 分类

// 自定义类和三方类（ cocoapods类 > model > 工具类 > 其他）
#import "YYUser.h"
#import "YYOrderingListModel.h"
#import "YYBrandHomeInfoModel.h"
#import "YYHotDesignerBrandsModel.h"

#import "AppDelegate.h"

@implementation YYIndexViewLogic
#pragma mark - --------------Life Cycle--------------
-(instancetype)init{
    self = [super init];
    if(self){
        [self SomePrepare];
    }
    return self;
}
#pragma mark - --------------SomePrepare--------------
- (void)SomePrepare
{
    [self PrepareData];
    [self PrepareUI];
}
- (void)PrepareData{
    self.bannerListHaveBeenSuccessful = NO;
    self.orderingListHaveBeenSuccessful = NO;
    self.hotDesignerBrandsHaveBeenSuccessful = NO;
    self.requestCount = 0;
    self.isHeadRefresh = NO;
    self.isFirstLoad = YES;
}
- (void)PrepareUI{

}
#pragma mark - --------------API----------------------
//获取首页banner
-(void)loadBannerInfo{
    WeakSelf(ws);
    //获取首页banner
    [YYIndexApi getBannerListWithBlock:^(YYRspStatusAndMessage *rspStatusAndMessage, NSArray *returnArr, NSError *error) {
        ws.requestCount ++;
        if(!ws.bannerListHaveBeenSuccessful){
            ws.bannerListHaveBeenSuccessful = YES;
        }

        if(rspStatusAndMessage){
            if(rspStatusAndMessage.status == YYReqStatusCode100){
                ws.bannerListModelArray = returnArr;

                if(ws.delegate && [ws.delegate respondsToSelector:@selector(requestDataCompletedWithType:)]){
                    [ws.delegate requestDataCompletedWithType:YYLogicAPITypeBannerList];
                }
            }else{
                if(ws.delegate && [ws.delegate respondsToSelector:@selector(requestDataErrorWithType:WithError:)]){
                    [ws.delegate requestDataErrorWithType:YYLogicAPITypeBannerList WithError:error];
                }
            }
            //        [ws reloadTableView];
        }else{
            if(ws.delegate && [ws.delegate respondsToSelector:@selector(requestDataFailureWithType:)]){
                [ws.delegate requestDataFailureWithType:YYLogicAPITypeBannerList];
            }
        }

    }];
}
//获取首页订货会列表
-(void)loadIndexOrderingInfo{
    WeakSelf(ws);
    //获取首页订货会列表
    [YYOrderingApi getIndexOrderingListWithBlock:^(YYRspStatusAndMessage *rspStatusAndMessage, YYOrderingListModel *orderingListModel, NSError *error) {
        _requestCount ++;
        if(!_orderingListHaveBeenSuccessful){
            _orderingListHaveBeenSuccessful = YES;
        }

        if(rspStatusAndMessage){
            if(rspStatusAndMessage.status == YYReqStatusCode100){
                ws.orderingListModel = orderingListModel;

                if(ws.delegate && [ws.delegate respondsToSelector:@selector(requestDataCompletedWithType:)]){
                    [ws.delegate requestDataCompletedWithType:YYLogicAPITypeOrderingList];
                }
            }else{
                if(ws.delegate && [ws.delegate respondsToSelector:@selector(requestDataErrorWithType:WithError:)]){
                    [ws.delegate requestDataErrorWithType:YYLogicAPITypeOrderingList WithError:error];
                }
            }
            //        [ws reloadTableView];
        }else{
            if(ws.delegate && [ws.delegate respondsToSelector:@selector(requestDataFailureWithType:)]){
                [ws.delegate requestDataFailureWithType:YYLogicAPITypeOrderingList];
            }
        }

    }];
}
//获取热门品牌列表
-(void)loadHotBrandsList{
    WeakSelf(ws);
    //获取首页订货会列表
    [YYIndexApi getHotBrandsListWithBlock:^(YYRspStatusAndMessage *rspStatusAndMessage, NSArray *hotList, NSError *error) {
        _requestCount ++;
        if(!_hotDesignerBrandsHaveBeenSuccessful){
            _hotDesignerBrandsHaveBeenSuccessful = YES;
        }

        if(rspStatusAndMessage){
            if(rspStatusAndMessage.status == YYReqStatusCode100){
                for (YYHotDesignerBrandsModel *brandModel in hotList) {
                    if([NSArray isNilOrEmpty:brandModel.seriesBoList]){
                        brandModel.seriesBoListNum = @(0);
                    }else{
                        brandModel.seriesBoListNum = @(brandModel.seriesBoList.count);
                    }
                }
                ws.hotDesignerBrandsModelArray = hotList;

                if(ws.delegate && [ws.delegate respondsToSelector:@selector(requestDataCompletedWithType:)]){
                    [ws.delegate requestDataCompletedWithType:YYLogicAPITypeBannerList];
                }
            }else{
                if(ws.delegate && [ws.delegate respondsToSelector:@selector(requestDataErrorWithType:WithError:)]){
                    [ws.delegate requestDataErrorWithType:YYLogicAPITypeBannerList WithError:error];
                }
            }
        }else{
            if(ws.delegate && [ws.delegate respondsToSelector:@selector(requestDataFailureWithType:)]){
                [ws.delegate requestDataFailureWithType:YYLogicAPITypeBannerList];
            }
        }

    }];
}
// 获取banner对应的设计师信息
-(void)getDesignerHomeInfoWithDesignerId:(NSInteger)designerId{
    WeakSelf(ws);
    _bannerDesignerHomeInfoModel = nil;
    [YYUserApi getDesignerHomeInfo:[[NSString alloc] initWithFormat:@"%ld",designerId] andBlock:^(YYRspStatusAndMessage *rspStatusAndMessage, YYBrandHomeInfoModel *infoModel, NSError *error) {
        if(rspStatusAndMessage){
            if(rspStatusAndMessage.status == YYReqStatusCode100){
                _bannerDesignerHomeInfoModel = infoModel;
                _bannerDesignerHomeInfoModel.designerId = @(designerId);
                if(ws.delegate && [ws.delegate respondsToSelector:@selector(requestDataCompletedWithType:)]){
                    [ws.delegate requestDataCompletedWithType:YYLogicAPITypeDesignerHomeInfo];
                }
            }else{
                if(ws.delegate && [ws.delegate respondsToSelector:@selector(requestDataErrorWithType:WithError:)]){
                    [ws.delegate requestDataErrorWithType:YYLogicAPITypeDesignerHomeInfo WithError:error];
                }
            }
        }else{
            if(ws.delegate && [ws.delegate respondsToSelector:@selector(requestDataFailureWithType:)]){
                [ws.delegate requestDataFailureWithType:YYLogicAPITypeDesignerHomeInfo];
            }
        }
    }];
}
//修改当前用户与品牌的关联状态 添加
-(void)connInviteByDesignerBrandsModel:(YYHotDesignerBrandsModel *)hotDesignerBrandsModel{
    WeakSelf(ws);
    if(hotDesignerBrandsModel && [hotDesignerBrandsModel.connectStatus integerValue] == YYUserConnStatusNone){
        [YYConnApi invite:[hotDesignerBrandsModel.designerId integerValue] andBlock:^(YYRspStatusAndMessage *rspStatusAndMessage, NSError *error) {
            if(rspStatusAndMessage){
                if(rspStatusAndMessage.status == YYReqStatusCode100){
                    hotDesignerBrandsModel.connectStatus = 0;
                    if(ws.delegate && [ws.delegate respondsToSelector:@selector(requestDataCompletedWithType:)]){
                        [ws.delegate requestDataCompletedWithType:YYLogicAPITypeConnInvite];
                    }
                }else{
                    if(ws.delegate && [ws.delegate respondsToSelector:@selector(requestDataErrorWithType:WithError:)]){
                        [ws.delegate requestDataErrorWithType:YYLogicAPITypeConnInvite WithError:error];
                    }
                }
            }else{
                if(ws.delegate && [ws.delegate respondsToSelector:@selector(requestDataFailureWithType:)]){
                    [ws.delegate requestDataFailureWithType:YYLogicAPITypeConnInvite];
                }
            }
        }];
    }
}

//获取系列详情
-(void)getConnSeriesInfoWithDesignerId:(NSInteger)designerId WithSeriesID:(NSInteger)seriesId{
    WeakSelf(ws);
    _seriesInfoModel = nil;
    [YYOpusApi getConnSeriesInfoWithId:designerId seriesId:seriesId andBlock:^(YYRspStatusAndMessage *rspStatusAndMessage, YYSeriesInfoDetailModel *infoDetailModel, NSError *error) {
        if(rspStatusAndMessage){
            if (rspStatusAndMessage.status == YYReqStatusCode100) {
                _seriesInfoModel = infoDetailModel;
                if(ws.delegate && [ws.delegate respondsToSelector:@selector(requestDataCompletedWithType:)]){
                    [ws.delegate requestDataCompletedWithType:YYLogicAPITypeSeriesDetail];
                }
            }else{
                if(ws.delegate && [ws.delegate respondsToSelector:@selector(requestDataErrorWithType:WithError:)]){
                    [ws.delegate requestDataErrorWithType:YYLogicAPITypeSeriesDetail WithError:error];
                }
            }
        }else{
            if(ws.delegate && [ws.delegate respondsToSelector:@selector(requestDataFailureWithType:)]){
                [ws.delegate requestDataFailureWithType:YYLogicAPITypeSeriesDetail];
            }
        }
    }];
}

//获取款式信息
-(void)getStyleInfoByStyleId:(NSInteger)styleId{
    WeakSelf(ws);
    _styleInfoModel = nil;
    [YYOpusApi getStyleInfoByStyleId:styleId orderCode:nil andBlock:^(YYRspStatusAndMessage *rspStatusAndMessage, YYStyleInfoModel *styleInfoModel, NSError *error) {
        if(rspStatusAndMessage){
            if (rspStatusAndMessage.status == YYReqStatusCode100) {
                _styleInfoModel = styleInfoModel;
                if(ws.delegate && [ws.delegate respondsToSelector:@selector(requestDataCompletedWithType:)]){
                    [ws.delegate requestDataCompletedWithType:YYLogicAPITypeSweepToStyleInfo];
                }
            }else{
                if(ws.delegate && [ws.delegate respondsToSelector:@selector(requestDataErrorWithType:WithError:)]){
                    [ws.delegate requestDataErrorWithType:YYLogicAPITypeSweepToStyleInfo WithError:error];
                }
            }
        }else{
            if(ws.delegate && [ws.delegate respondsToSelector:@selector(requestDataFailureWithType:)]){
                [ws.delegate requestDataFailureWithType:YYLogicAPITypeSweepToStyleInfo];
            }
        }
    }];
}
#pragma mark - --------------SomeDelegate----------------------

#pragma mark - --------------Event Response----------------------

#pragma mark - --------------Private Methods----------------------
-(BOOL)isAllowRendering{
    if(self){
        if([[YYUser currentUser] hasPermissionsToVisit]){
            if(self.bannerListHaveBeenSuccessful && self.orderingListHaveBeenSuccessful && self.hotDesignerBrandsHaveBeenSuccessful){
                return YES;
            }
        }else{
            if(self.bannerListHaveBeenSuccessful){
                return YES;
            }
        }
    }
    return NO;
}
-(void)checkNoticeCount{
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    [appDelegate checkNoticeCount];
}

@end
