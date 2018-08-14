//
//  YYIndexTableHeadView.m
//  YunejianBuyer
//
//  Created by yyj on 2017/8/8.
//  Copyright © 2017年 Apple. All rights reserved.
//

#import "YYIndexTableHeadView.h"

#import "LBBannerView.h"
#import "SCGIFButtonView.h"

#import "YYBannerModel.h"
#import "YYDueBrandsModel.h"

@interface YYIndexTableHeadView()

@property (nonatomic,strong) LBBannerView *bannerView;

@property (nonatomic,strong) UIView *downView;
@property (nonatomic,strong) UILabel *titleTipLabel;
@property (nonatomic,strong) UIScrollView *scrollView;
@property (nonatomic,strong) UIView *container;

@property(nonatomic,copy) void (^indexTableHeadBlock)(NSString *type,NSInteger index);

@end

@implementation YYIndexTableHeadView

#pragma mark - --------------生命周期--------------
-(instancetype)initWithFrame:(CGRect)frame WithBlock:(void (^)(NSString *type,NSInteger index))block{
    self = [super initWithFrame:frame];
    if(self){
        _indexTableHeadBlock = block;
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
- (void)PrepareData{}
- (void)PrepareUI{
    self.backgroundColor = _define_white_color;
}
#pragma mark - --------------UIConfig----------------------
-(void)CreateBannerView{
    NSArray *imagesArray = [self getBannerImgs];
    if(imagesArray && imagesArray.count){
        _bannerView = [[LBBannerView alloc] initViewWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 214) autoPlayTime:5.0f type:nil imagesArray:imagesArray clickCallBack:^(NSInteger index) {
            if(_indexTableHeadBlock){
                _indexTableHeadBlock(@"banner_click",index);
            }
        }];
        [self addSubview:_bannerView];
    }
}
//#pragma mark - --------------系统代理----------------------
//#pragma mark - --------------自定义代理/block----------------------
#pragma mark - --------------自定义响应----------------------
-(void)dueBrandsClick:(SCGIFButtonView *)button{
    if(_indexTableHeadBlock){
        _indexTableHeadBlock(@"duebrands_click",button.tag - 100);
    }
}

#pragma mark - --------------自定义方法----------------------
-(void)updateUI{

    if([YYCurrentNetworkSpace isNetwork]){
        if(_bannerView || _downView){
            //移除一些东西
            [self.subviews enumerateObjectsUsingBlock:^(__kindof UIView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                [obj removeFromSuperview];
                obj = nil;
            }];
        }

        if(_bannerListModelArray && _bannerListModelArray.count){
            //    banner ui创建
            [self CreateBannerView];
        }
    }

}
-(NSArray *)getBannerImgs{
    NSMutableArray *tempArray = [[NSMutableArray alloc] init];
    if(_bannerListModelArray && _bannerListModelArray.count > 0){
        for (YYBannerModel *bannerModel in _bannerListModelArray) {
            if(![NSString isNilOrEmpty:bannerModel.coverImg]){
                [tempArray addObject:bannerModel.coverImg];
            }
        }
    }
    return [tempArray copy];
}

#pragma mark - --------------other----------------------

@end
