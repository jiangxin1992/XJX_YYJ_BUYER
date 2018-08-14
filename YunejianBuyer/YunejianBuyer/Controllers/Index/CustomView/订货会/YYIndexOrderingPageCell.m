//
//  YYIndexOrderingPageCell.m
//  YunejianBuyer
//
//  Created by yyj on 2017/9/21.
//  Copyright © 2017年 Apple. All rights reserved.
//

#import "YYIndexOrderingPageCell.h"

#import "TYCyclePagerView.h"
#import "YYIndexOrderingPageCollCell.h"
#import "SCGIFImageView.h"

#import "YYOrderingListModel.h"
#import "YYOrderingListItemModel.h"

@interface YYIndexOrderingPageCell()<TYCyclePagerViewDataSource, TYCyclePagerViewDelegate>

@property (nonatomic, strong) TYCyclePagerView *pagerView;
@property (nonatomic, strong) YYIndexOrderingPageCollCell *IndexOrderingPageCollView;//只有一个订货会的时候显示

@property(nonatomic,copy) void (^indexOrderingPageCell)(NSString *type,YYOrderingListItemModel *listItemModel);

@end

@implementation YYIndexOrderingPageCell

#pragma mark - --------------生命周期--------------
-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier WithBlock:(void(^)(NSString *type,YYOrderingListItemModel *listItemModel))block{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if(self){
        _indexOrderingPageCell = block;
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
    [self addPagerView];
    [self createOneOrderingView];
}
-(void)createOneOrderingView{
    _IndexOrderingPageCollView = [[YYIndexOrderingPageCollCell alloc] initWithFrame:CGRectMake(17, 0, SCREEN_WIDTH - 17 *2, 190)];
    [self.contentView addSubview:_IndexOrderingPageCollView];
}
- (void)addPagerView {
    TYCyclePagerView *pagerView = [[TYCyclePagerView alloc]init];
    pagerView.isInfiniteLoop = NO;
    pagerView.autoScrollInterval = 0.0;
    pagerView.dataSource = self;
    pagerView.delegate = self;
    [pagerView registerClass:[YYIndexOrderingPageCollCell class] forCellWithReuseIdentifier:@"YYIndexOrderingPageCollCell"];
    [self.contentView addSubview:pagerView];
    pagerView.frame = CGRectMake(0, 0, SCREEN_WIDTH, 190);
    _pagerView = pagerView;
}
-(void)updateUI{
    if(_orderingListModel){
        if(_orderingListModel.result.count > 1){
            _pagerView.hidden = NO;
            _IndexOrderingPageCollView.hidden = YES;

            [_pagerView reloadData];
        }else{
            _pagerView.hidden = YES;
            _IndexOrderingPageCollView.hidden = NO;

            _IndexOrderingPageCollView.listItemModel = _orderingListModel.result[0];
            [_IndexOrderingPageCollView updateUI];
        }
    }

}
//#pragma mark - --------------请求数据----------------------
#pragma mark - TYCyclePagerViewDataSource

- (NSInteger)numberOfItemsInPagerView:(TYCyclePagerView *)pageView {
    return _orderingListModel.result.count;
}

- (UICollectionViewCell *)pagerView:(TYCyclePagerView *)pagerView cellForItemAtIndex:(NSInteger)index {
    YYIndexOrderingPageCollCell *cell = [pagerView dequeueReusableCellWithReuseIdentifier:@"YYIndexOrderingPageCollCell" forIndex:index];
    cell.listItemModel = _orderingListModel.result[index];
    [cell updateUI];
    return cell;
}

- (TYCyclePagerViewLayout *)layoutForPagerView:(TYCyclePagerView *)pageView {
    TYCyclePagerViewLayout *layout = [[TYCyclePagerViewLayout alloc]init];
    layout.itemSize = CGSizeMake(SCREEN_WIDTH - 10 - 17 - 40, 190);
    layout.itemSpacing = 10;
    layout.itemHorizontalCenter = NO;
    layout.layoutType = TYCyclePagerTransformLayoutLinear;
    return layout;
}

- (void)pagerView:(TYCyclePagerView *)pageView didScrollFromIndex:(NSInteger)fromIndex toIndex:(NSInteger)toIndex {
    NSLog(@"%ld ->  %ld",fromIndex,toIndex);
}

- (void)pagerView:(TYCyclePagerView *)pageView didSelectedItemCell:(__kindof UICollectionViewCell *)cell atIndex:(NSInteger)index{
    NSLog(@"didSelectedIndex = %ld",index);
    if(_indexOrderingPageCell){
        _indexOrderingPageCell(@"card_click",_orderingListModel.result[index]);
    }
}
//#pragma mark - --------------自定义响应----------------------
#pragma mark - --------------自定义方法----------------------


#pragma mark - --------------other----------------------
- (void)awakeFromNib {
    [super awakeFromNib];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}

@end
