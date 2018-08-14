//
//  YYIndexRecommendationBrandCell.m
//  YunejianBuyer
//
//  Created by yyj on 2017/8/8.
//  Copyright © 2017年 Apple. All rights reserved.
//

#import "YYIndexRecommendationBrandCell.h"

#import "SCGIFButtonView.h"
#import "SCGIFImageView.h"

#import "YYRecommendDesignerBrandsModel.h"

@interface YYIndexRecommendationBrandCell()

@property (nonatomic,strong) UIScrollView *scrollView;
@property (nonatomic,strong) UIView *container;

@property(nonatomic,copy) void (^recommendationBrandCellBlock)(NSString *type,NSInteger index);

@end

@implementation YYIndexRecommendationBrandCell

#pragma mark - --------------生命周期--------------
-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier WithBlock:(void(^)(NSString *type,NSInteger index))block{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if(self){
        _recommendationBrandCellBlock = block;
        [self SomePrepare];
        [self UIConfig];
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
- (void)PrepareUI{}
#pragma mark - --------------UIConfig----------------------
-(void)UIConfig{
    _scrollView=[[UIScrollView alloc] init];
    [self.contentView addSubview:_scrollView];
    _container = [UIView new];
    [_scrollView addSubview:_container];
    [_container mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(_scrollView);
        make.height.equalTo(_scrollView);
    }];
}
-(void)CreateRecommendScrollView{
    UIView *lastView = nil;
    for (int i = 0 ; i < _recommendDesignerBrandsModelArray.count; i++) {
        YYRecommendDesignerBrandsModel *recommendModel = _recommendDesignerBrandsModelArray[i];

        SCGIFButtonView *tempButton = [[SCGIFButtonView alloc] init];
        [_container addSubview:tempButton];
        [tempButton mas_makeConstraints:^(MASConstraintMaker *make) {
            if(!lastView){
                make.left.mas_equalTo(17);
            }else{
                make.left.mas_equalTo(lastView.mas_right).with.offset(20);
            }
            make.top.mas_equalTo(0);
            make.bottom.mas_equalTo(-15);
            make.width.mas_equalTo(60);
            if(i == _recommendDesignerBrandsModelArray.count - 1){
                make.right.mas_equalTo(-17);
            }
        }];
        tempButton.imageView.contentMode = UIViewContentModeScaleAspectFit;
        tempButton.layer.masksToBounds = YES;
        tempButton.layer.cornerRadius = 30.0f;
        tempButton.layer.borderColor = [[UIColor colorWithHex:@"EFEFEF"] CGColor];
        tempButton.layer.borderWidth = 1;
        tempButton.clipsToBounds = YES;
        tempButton.tag = 100 + i;
        [tempButton addTarget:self action:@selector(recommendClick:) forControlEvents:UIControlEventTouchUpInside];
        sd_downloadWebImageWithRelativePath(NO, recommendModel.logoPath, tempButton, kLogoCover, 0);

        lastView = tempButton;
    }

    [_scrollView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.mas_equalTo(0);
        make.height.mas_equalTo(75);
        make.top.mas_equalTo(0);
        // 让scrollview的contentSize随着内容的增多而变化
        make.right.mas_equalTo(lastView.mas_right).with.offset(17);
    }];
}
//#pragma mark - --------------请求数据----------------------
#pragma mark - --------------自定义响应----------------------
-(void)recommendClick:(SCGIFButtonView *)button{
    if(_recommendationBrandCellBlock){
        _recommendationBrandCellBlock(@"recommend_click",button.tag - 100);
    }
}
#pragma mark - --------------自定义方法----------------------
-(void)updateUI{
    if([YYCurrentNetworkSpace isNetwork]){
        if(_scrollView){
            //移除一些东西
            [self.container.subviews enumerateObjectsUsingBlock:^(__kindof UIView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                [obj removeFromSuperview];
                obj = nil;
            }];
        }

        if(_recommendDesignerBrandsModelArray && _recommendDesignerBrandsModelArray.count){
            //    banner ui创建
            [self CreateRecommendScrollView];
        }
    }
}

#pragma mark - --------------other----------------------
- (void)awakeFromNib {
    [super awakeFromNib];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}

@end
