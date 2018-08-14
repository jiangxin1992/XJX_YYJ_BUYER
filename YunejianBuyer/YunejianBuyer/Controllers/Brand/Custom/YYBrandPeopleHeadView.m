//
//  YYBrandPeopleHeadView.m
//  YunejianBuyer
//
//  Created by yyj on 2017/4/13.
//  Copyright © 2017年 Apple. All rights reserved.
//

#import "YYBrandPeopleHeadView.h"

#import "YYConClass.h"
#import "YYBrandAddHeadBtn.h"

@interface YYBrandPeopleHeadView()

@property(nonatomic,strong) NSMutableArray *ArrPeople;
@property(nonatomic,strong) NSMutableArray *ArrSuit;

@property(nonatomic,strong) UIView *containerPeople;
@property(nonatomic,strong) UIScrollView *scrollViewPeople;
@property(nonatomic,strong) UIView *downLinePeople;

@property(nonatomic,strong) UIView *containerSuit;
@property(nonatomic,strong) UIScrollView *scrollViewSuit;
@property(nonatomic,strong) UIView *downLineSuit;

@end

@implementation YYBrandPeopleHeadView
#pragma mark - --------------生命周期--------------
-(instancetype)init{
    self = [super init];
    if(self){
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
- (void)PrepareData{
    _ArrPeople = [[NSMutableArray alloc] init];
    _ArrSuit = [[NSMutableArray alloc] init];
}
- (void)PrepareUI{
    self.backgroundColor = _define_white_color;
}

#pragma mark - --------------UIConfig----------------------
-(void)UIConfig{
    _scrollViewPeople=[[UIScrollView alloc] init];
    [self addSubview:_scrollViewPeople];
    _containerPeople = [UIView new];
    [_scrollViewPeople addSubview:_containerPeople];
    _containerPeople.backgroundColor = _define_white_color;
    _scrollViewPeople.showsVerticalScrollIndicator = FALSE;
    _scrollViewPeople.showsHorizontalScrollIndicator = FALSE;
    [_containerPeople mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(_scrollViewPeople);
        make.height.equalTo(_scrollViewPeople);
    }];

    [_scrollViewPeople mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(0);
        make.left.right.mas_equalTo(0);
        make.height.mas_equalTo(43);
    }];

    _downLinePeople = [UIView getCustomViewWithColor:[UIColor colorWithHex:@"EFEFEF"]];
    [self addSubview:_downLinePeople];
    [_downLinePeople mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.mas_equalTo(0);
        make.top.mas_equalTo(_scrollViewPeople.mas_bottom).with.offset(0);
        make.height.mas_equalTo(1);
    }];

    _scrollViewSuit=[[UIScrollView alloc] init];
    [self addSubview:_scrollViewSuit];
    _containerSuit = [UIView new];
    [_scrollViewSuit addSubview:_containerSuit];
    _containerSuit.backgroundColor = _define_white_color;
    _scrollViewSuit.showsVerticalScrollIndicator = FALSE;
    _scrollViewSuit.showsHorizontalScrollIndicator = FALSE;
    [_containerSuit mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(_scrollViewSuit);
        make.height.equalTo(_scrollViewSuit);
    }];

    [_scrollViewSuit mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(_downLinePeople.mas_bottom).with.offset(0);
        make.left.right.mas_equalTo(0);
        make.height.mas_equalTo(43);
    }];

    _downLineSuit = [UIView getCustomViewWithColor:[UIColor colorWithHex:@"EFEFEF"]];
    [self addSubview:_downLineSuit];
    [_downLineSuit mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.mas_equalTo(0);
        make.top.mas_equalTo(_scrollViewSuit.mas_bottom).with.offset(0);
        make.height.mas_equalTo(1);
    }];
}

//#pragma mark - --------------请求数据----------------------
//-(void)RequestData{}

#pragma mark - --------------自定义响应----------------------
-(void)peopleTypeClick:(YYBrandAddHeadBtn *)btn{
    NSInteger index = btn.tag-100;
    if(_blockPeople){
        _blockPeople(index);
    }
}
-(void)suitTypeClick:(YYBrandAddHeadBtn *)btn{
    NSInteger index = btn.tag-200;
    if(_blockSuit){
        _blockSuit(index);
    }
}

#pragma mark - --------------自定义方法----------------------
-(void)setConnClass:(YYConClass *)connClass{
    _connClass = connClass;
    if(_ArrPeople){
        for (int i=0; i<_ArrPeople.count; i++) {
            UIView *obj = _ArrPeople[i];
            [obj removeFromSuperview];
        }
        [_ArrPeople removeAllObjects];
    }
    if(_ArrSuit){
        for (int i=0; i<_ArrSuit.count; i++) {
            UIView *obj = _ArrSuit[i];
            [obj removeFromSuperview];
        }
        [_ArrSuit removeAllObjects];
    }

    if(_connClass){
        CGFloat _widthPeople = SCREEN_WIDTH/4.0f;
        UIView *lastViewPeople = nil;
        for (int i=0; i<_connClass.peopleTypes.count; i++) {
            YYConPeopleClass *peopleclass = _connClass.peopleTypes[i];
            YYBrandAddHeadBtn *btn = [YYBrandAddHeadBtn getCustomTitleBtnWithAlignment:0 WithFont:14.0f WithSpacing:0 WithNormalTitle:peopleclass.name WithNormalColor:nil WithSelectedTitle:nil WithSelectedColor:nil];
            [_containerPeople addSubview:btn];
            [btn mas_makeConstraints:^(MASConstraintMaker *make) {
                if(lastViewPeople){
                    make.left.mas_equalTo(lastViewPeople.mas_right).with.offset(0);
                }else{
                    make.left.mas_equalTo(0);
                }
                make.top.bottom.mas_equalTo(0);
                make.width.mas_equalTo(_widthPeople);
            }];
            [btn addTarget:self action:@selector(peopleTypeClick:) forControlEvents:UIControlEventTouchUpInside];
            btn.tag = 100+i;
            if(_peopleSelectIndex == i){
                //添加锁定
                UIView *line = [UIView getCustomViewWithColor:_define_black_color];
                [btn addSubview:line];
                [line mas_makeConstraints:^(MASConstraintMaker *make) {
                    make.centerX.mas_equalTo(btn);
                    make.bottom.mas_equalTo(0);
                    make.height.mas_equalTo(2);
                    make.width.mas_equalTo(55);
                }];
            }

            btn.peopleClass = peopleclass;
            lastViewPeople = btn;
            [_ArrPeople addObject:btn];
        }

        if(lastViewPeople){
            [_scrollViewPeople mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.top.mas_equalTo(0);
                make.left.right.mas_equalTo(0);
                make.height.mas_equalTo(43);
                make.right.mas_equalTo(lastViewPeople.mas_right).with.offset(0);
            }];
        }else{
            [_scrollViewPeople mas_makeConstraints:^(MASConstraintMaker *make) {
                make.top.mas_equalTo(0);
                make.left.right.mas_equalTo(0);
                make.height.mas_equalTo(43);
            }];
        }


        CGFloat _widthSuit = (SCREEN_WIDTH - 16)/6.0f;
        UIView *lastViewSuit = nil;
        for (int i=0; i<_connClass.suitTypes.count; i++) {
            YYConSuitClass *suitclass = _connClass.suitTypes[i];
            YYBrandAddHeadBtn *btn = [YYBrandAddHeadBtn getCustomTitleBtnWithAlignment:0 WithFont:[LanguageManager isEnglishLanguage]?10.0f:13.0f WithSpacing:0 WithNormalTitle:suitclass.name WithNormalColor:[UIColor colorWithHex:@"919191"] WithSelectedTitle:suitclass.name WithSelectedColor:[UIColor colorWithHex:@"ED6498"]];
            [_containerSuit addSubview:btn];
            [btn mas_makeConstraints:^(MASConstraintMaker *make) {
                if(lastViewSuit){
                    make.left.mas_equalTo(lastViewSuit.mas_right).with.offset(0);
                }else{
                    make.left.mas_equalTo(8);
                }
                make.top.bottom.mas_equalTo(0);
                make.width.mas_equalTo(_widthSuit);
            }];
            [btn addTarget:self action:@selector(suitTypeClick:) forControlEvents:UIControlEventTouchUpInside];
            btn.tag = 200+i;
            //添加锁定
            if(_suitSelectIndex == i){
                btn.selected = YES;
            }else{
                btn.selected = NO;
            }

            btn.suitClass = suitclass;
            lastViewSuit = btn;
            [_ArrSuit addObject:btn];
        }

        if(lastViewSuit){
            [_scrollViewSuit mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.top.mas_equalTo(_downLinePeople.mas_bottom).with.offset(0);
                make.left.right.mas_equalTo(0);
                make.height.mas_equalTo(43);
                make.right.mas_equalTo(lastViewSuit.mas_right).with.offset(0);
            }];
        }else{
            [_scrollViewSuit mas_makeConstraints:^(MASConstraintMaker *make) {
                make.top.mas_equalTo(_downLinePeople.mas_bottom).with.offset(0);
                make.left.right.mas_equalTo(0);
                make.height.mas_equalTo(43);
            }];
        }
    }else{
        //        _titleLabel.hidden = YES;
        [_scrollViewPeople mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(0);
            make.left.right.mas_equalTo(0);
            make.height.mas_equalTo(0);
        }];

        [_scrollViewSuit mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(_downLinePeople.mas_bottom).with.offset(0);
            make.left.right.mas_equalTo(0);
            make.height.mas_equalTo(0);
        }];
    }
}
-(void)setViewStyle:(YYBrandPeopleHeadViewStyle)viewStyle{
    _viewStyle = viewStyle;
    if(_viewStyle == YYBrandPeopleHeadViewAppear){
        _containerPeople.hidden = NO;
        _downLinePeople.hidden = NO;
        _containerSuit.hidden = NO;
        _downLineSuit.hidden = NO;
    }else{
        _containerPeople.hidden = YES;
        _downLinePeople.hidden = YES;
        _containerSuit.hidden = YES;
        _downLineSuit.hidden = YES;
    }
}
#pragma mark - --------------other----------------------
- (void)awakeFromNib {
    [super awakeFromNib];
}
@end
