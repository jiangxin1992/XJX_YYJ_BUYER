//
//  YYHotSeriesCardCell.m
//  YunejianBuyer
//
//  Created by yyj on 2017/9/21.
//  Copyright © 2017年 Apple. All rights reserved.
//

#import "YYHotSeriesCardCell.h"

#import "YYHotSeriesCardView.h"

@interface YYHotSeriesCardCell()

@property (nonatomic,strong) YYHotSeriesCardView *leftView;
@property (nonatomic,strong) YYHotSeriesCardView *rightView;

@property(nonatomic,copy) void (^hotSeriesCardBlock)(NSString *type,YYLatestSeriesModel *seriesModel);

@end

@implementation YYHotSeriesCardCell

#pragma mark - --------------生命周期--------------
-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier WithBlock:(void(^)(NSString *type,YYLatestSeriesModel *latestSeriesModel))block{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if(self){
        _hotSeriesCardBlock = block;
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
- (void)PrepareUI{
    _leftView = [[YYHotSeriesCardView alloc] init];
    _rightView = [[YYHotSeriesCardView alloc] init];
}

#pragma mark - --------------UIConfig----------------------
-(void)UIConfig{
    UIView *lastView = nil;
    for (int i = 0; i < 2 ; i++) {
        YYHotSeriesCardView *cardView = i ? _rightView : _leftView;
        [self.contentView addSubview:cardView];
        cardView.layer.borderColor = [[UIColor colorWithHex:@"EFEFEF"] CGColor];
        cardView.layer.borderWidth = 0.5f;
        [cardView mas_makeConstraints:^(MASConstraintMaker *make) {
            if(!lastView){
                make.left.mas_equalTo(13);
            }else{
                make.left.mas_equalTo(lastView.mas_right).with.offset(9);
                make.width.mas_equalTo(lastView);
                make.right.mas_equalTo(-13);
            }
            make.top.mas_equalTo(0);
            make.bottom.mas_equalTo(-20);
        }];
        [cardView setSeriesCardBlock:^(NSString *type,YYLatestSeriesModel *seriesModel){
            if(_hotSeriesCardBlock){
                _hotSeriesCardBlock(type,seriesModel);
            }
        }];
        lastView = cardView;
    }
}

//#pragma mark - --------------请求数据----------------------
//-(void)RequestData{}
//#pragma mark - --------------自定义响应----------------------
#pragma mark - --------------自定义方法----------------------
-(void)updateUI{
    if(_leftSeriesModel){
        _leftView.hidden = NO;
        _leftView.seriesModel = _leftSeriesModel;
        [_leftView updateUI];
    }else{
        _leftView.hidden = YES;
    }

    if(_rightSeriesModel){
        _rightView.hidden = NO;
        _rightView.seriesModel = _rightSeriesModel;
        [_rightView updateUI];
    }else{
        _rightView.hidden = YES;
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
