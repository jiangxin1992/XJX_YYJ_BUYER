//
//  YYSwitchView.m
//  YunejianBuyer
//
//  Created by yyj on 2017/7/14.
//  Copyright © 2017年 Apple. All rights reserved.
//

#import "YYSwitchView.h"

@interface YYSwitchView()

@property (nonatomic,strong) NSArray *titleArr;
@property (nonatomic,strong) NSMutableArray *btnArr;
@property (nonatomic,strong) UIView *sliderView;

@property (nonatomic,assign) BOOL isAnimation;

@end

@implementation YYSwitchView

#pragma mark - INIT

-(instancetype)initWithTitleArr:(NSArray *)titleArr WithSelectIndex:(NSInteger )selectIndex WithBlock:(void (^)(NSString *type,NSInteger index))switchBlock{
    self = [super init];
    if(self){
        _titleArr = titleArr;
        _selectIndex = selectIndex;
        _switchBlock = switchBlock;
        if(_titleArr && _titleArr.count){
            [self SomePrepare];
            [self UIConfig];
        }
    }
    return self;
}

#pragma mark - SomePrepare

-(void)SomePrepare
{
    [self PrepareData];
    [self PrepareUI];
}
-(void)PrepareData{
    _btnArr = [[NSMutableArray alloc] init];
    _isAnimation = NO;
}
-(void)PrepareUI{}

#pragma mark - UIConfig

-(void)UIConfig{
    UIView *lastView = nil;
    UIView *selectView = nil;
    for (int i=0; i<_titleArr.count; i++) {
        NSString *titleStr = _titleArr[i];
        
        UIButton *btn = [UIButton getCustomTitleBtnWithAlignment:0 WithFont:15.0f WithSpacing:0 WithNormalTitle:titleStr WithNormalColor:[UIColor colorWithHex:@"919191"] WithSelectedTitle:titleStr WithSelectedColor:nil];
        [self addSubview:btn];
        btn.tag = 100+i;
        [btn mas_makeConstraints:^(MASConstraintMaker *make) {
            if(lastView){
                make.left.mas_equalTo(lastView.mas_right).with.offset(0);
                make.width.mas_equalTo(lastView);
            }else{
                make.left.mas_equalTo(0);
            }
            make.top.mas_equalTo(0);
            make.bottom.mas_equalTo(-1);
            if(i == _titleArr.count - 1){
                make.right.mas_equalTo(0);
            }
            
        }];
        [btn addTarget:self action:@selector(selectAction:) forControlEvents:UIControlEventTouchUpInside];
        if(_selectIndex == i){
            btn.selected = YES;
            selectView = btn;
        }
        lastView = btn;
        [_btnArr addObject:btn];
    }
    
    UIView *lineView = [UIView getCustomViewWithColor:[UIColor colorWithHex:@"EFEFEF"]];
    [self addSubview:lineView];
    [lineView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.bottom.mas_equalTo(0);
        make.height.mas_equalTo(1);
    }];
    
    _sliderView = [UIView getCustomViewWithColor:_define_black_color];
    [self addSubview:_sliderView];
    CGFloat width = SCREEN_WIDTH/_titleArr.count;
    CGFloat bianju = (width-90)/2.0f;
    CGFloat x_p = _selectIndex*width+bianju;
    _sliderView.frame = CGRectMake(x_p, 37, 90, 2);
}

#pragma mark - SomeAction
-(void)selectAction:(UIButton *)btn{
    NSInteger btnTag = btn.tag - 100;
    if(btnTag != _selectIndex && !_isAnimation){
        UIButton *selectBtn = _btnArr[_selectIndex];
        selectBtn.selected = NO;
        btn.selected = YES;
        
        _isAnimation = YES;
        [UIView animateWithDuration:0.5f animations:^{
            CGFloat width = SCREEN_WIDTH/_titleArr.count;
            CGFloat bianju = (width-90)/2.0f;
            CGFloat x_p = btnTag*width+bianju;
            _sliderView.frame = CGRectMake(x_p, 37, 90, 2);
        } completion:^(BOOL finished) {
            self.isAnimation = NO;
            self.selectIndex = btnTag;
            if(self.switchBlock){
                self.switchBlock(@"switch",self.selectIndex);
            }
        }];
    }
}
@end
