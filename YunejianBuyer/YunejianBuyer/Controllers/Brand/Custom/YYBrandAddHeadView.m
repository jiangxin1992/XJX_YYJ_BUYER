//
//  YYBrandAddHeadView.m
//  YunejianBuyer
//
//  Created by yyj on 2017/4/12.
//  Copyright © 2017年 Apple. All rights reserved.
//

#import "YYBrandAddHeadView.h"

#import "YYConClass.h"
#import "YYBrandAddHeadBtn.h"
//#import "YYConNewBrandModel.h"
//#import "YYConNewBrandItemModel.h"
//#import "SCGIFImageView.h"

@interface YYBrandAddHeadView ()

//@property(nonatomic,strong) NSMutableArray *ArrBrand;
@property(nonatomic,strong) NSMutableArray *ArrPeople;
@property(nonatomic,strong) NSMutableArray *ArrSuit;

//@property(nonatomic,strong) UIView *containerBrand;
//@property(nonatomic,strong) UIScrollView *scrollViewBrand;
//@property(nonatomic,strong) UILabel *titleLabel;

@property(nonatomic,strong) UIView *containerPeople;
@property(nonatomic,strong) UIScrollView *scrollViewPeople;
@property(nonatomic,strong) UIView *downLinePeople;

@property(nonatomic,strong) UIView *containerSuit;
@property(nonatomic,strong) UIScrollView *scrollViewSuit;
@property(nonatomic,strong) UIView *downLineSuit;

@end

@implementation YYBrandAddHeadView
#pragma mark - --------------生命周期--------------
- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
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
- (void)PrepareUI{}

#pragma mark - --------------UIConfig----------------------
-(void)UIConfig{
    //        _scrollViewBrand=[[UIScrollView alloc] init];
    //        [self addSubview:_scrollViewBrand];
    //        _containerBrand = [UIView new];
    //        [_scrollViewBrand addSubview:_containerBrand];
    //        _scrollViewBrand.showsVerticalScrollIndicator = FALSE;
    //        _scrollViewBrand.showsHorizontalScrollIndicator = FALSE;
    //        [_containerBrand mas_makeConstraints:^(MASConstraintMaker *make) {
    //            make.edges.equalTo(_scrollViewBrand);
    //            make.height.equalTo(_scrollViewBrand);
    //        }];
    //
    //        _titleLabel = [UILabel getLabelWithAlignment:0 WithTitle:NSLocalizedString(@"最新入驻品牌",nil) WithFont:12.0f WithTextColor:nil WithSpacing:0];
    //        [self addSubview:_titleLabel];
    //        [_titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
    //            make.left.mas_equalTo(15);
    //            make.top.mas_equalTo(13);
    //            make.height.mas_equalTo(15);
    //        }];
    //
    //        [_scrollViewBrand mas_makeConstraints:^(MASConstraintMaker *make) {
    //            make.top.left.right.mas_equalTo(0);
    //            make.height.mas_equalTo(127);
    //        }];


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

#pragma mark - --------------other----------------------
- (void)awakeFromNib {
    [super awakeFromNib];
}

//-(void)setNewbrandModel:(YYConNewBrandModel *)newbrandModel{
//    _newbrandModel = newbrandModel;
//    if(_ArrBrand){
//        for (int i=0; i<_ArrBrand.count; i++) {
//            UIView *obj = _ArrBrand[i];
//            [obj removeFromSuperview];
//        }
//        [_ArrBrand removeAllObjects];
//    }
//    if(_newbrandModel){
//        _downLine.hidden = NO;
//        UIView *lastView = nil;
//        for (int i=0; i<_newbrandModel.result.count; i++) {
//            YYConNewBrandItemModel *itemModel = _newbrandModel.result[i];
//            YYBrandAddHeadBtn *btn = [YYBrandAddHeadBtn getCustomBtn];
//            [_containerBrand addSubview:btn];
//            [btn mas_makeConstraints:^(MASConstraintMaker *make) {
//                if(lastView){
//                    make.left.mas_equalTo(lastView.mas_right).with.offset(0);
//                }else{
//                    make.left.mas_equalTo(17);
//                }
//                make.top.mas_equalTo(_titleLabel.mas_bottom).with.offset(0);
//                make.bottom.mas_equalTo(0);
//                make.width.mas_equalTo(80);
//            }];
//            [btn addTarget:self action:@selector(enterBrand:) forControlEvents:UIControlEventTouchUpInside];
//
//            SCGIFImageView *brandLogo = [[SCGIFImageView alloc] init];
//            brandLogo.contentMode = UIViewContentModeScaleAspectFit;
//            [btn addSubview:brandLogo];
//            brandLogo.backgroundColor = _define_white_color;
//            [brandLogo mas_makeConstraints:^(MASConstraintMaker *make) {
//                make.top.mas_equalTo(8);
//                make.centerX.mas_equalTo(btn);
//                make.width.height.mas_equalTo(60);
//            }];
//            setBorderCustom(brandLogo, 2, [UIColor colorWithHex:@"F8F8F8"]);
//            brandLogo.layer.cornerRadius = 30;
//            sd_downloadWebImageWithRelativePath(NO, itemModel.logo, brandLogo, kLogoCover, 0);
//
//
//            UILabel *brandnameLabel = [UILabel getLabelWithAlignment:1 WithTitle:itemModel.brandName WithFont:12.0f WithTextColor:[UIColor colorWithHex:@"919191"] WithSpacing:0];
//            [btn addSubview:brandnameLabel];
//            [brandnameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
//                make.left.right.mas_equalTo(0);
//                make.top.mas_equalTo(brandLogo.mas_bottom).with.offset(5);
//            }];
//
//            btn.itemModel = itemModel;
//            lastView = btn;
//            [_ArrBrand addObject:btn];
//        }
//        if(lastView){
//            [_scrollViewBrand mas_remakeConstraints:^(MASConstraintMaker *make) {
//                make.top.left.right.mas_equalTo(0);
//                make.height.mas_equalTo(127);
//                make.right.mas_equalTo(lastView.mas_right).with.offset(17);
//            }];
//        }else{
//            [_scrollViewBrand mas_remakeConstraints:^(MASConstraintMaker *make) {
//                make.top.left.right.mas_equalTo(0);
//                make.height.mas_equalTo(127);
//            }];
//        }
//    }else{
//        _downLine.hidden = YES;
//        [_scrollViewBrand mas_remakeConstraints:^(MASConstraintMaker *make) {
//            make.top.left.right.mas_equalTo(0);
//            make.height.mas_equalTo(0);
//        }];
//    }
//}

//-(void)enterBrand:(YYBrandAddHeadBtn *)btn{
//    if(btn.itemModel){
//        NSLog(@"%@",btn.itemModel.brandName);
//        if(_blockBrand){
//            _blockBrand(btn.itemModel);
//        }
//    }
//}

@end
