//
//  YYChooseStyleSlideView.m
//  YunejianBuyer
//
//  Created by yyj on 2017/7/10.
//  Copyright © 2017年 Apple. All rights reserved.
//

#import "YYChooseStyleSlideView.h"

#import "regular.h"
#import "SCGIFImageView.h"

#import "YYChooseStyleModuleSlideView.h"

#define YY_TABBAR_HEIGHT 78
#define YY_ANIMATE_DURATION 0.2 //动画持续时间

@interface YYChooseStyleSlideView()<UITextFieldDelegate>

@property (nonatomic,strong) UIView *backView;

@property (nonatomic,strong) UIView *downActionView;

@property (nonatomic,strong) UIScrollView *scrollView;
@property (nonatomic,strong) UIView *container;
@property (nonatomic,strong) NSMutableArray *viewArr;
@property (nonatomic,strong) UILabel *currencySignLabel;
@property (nonatomic,strong) UITextField *retailPriceMinTextField;
@property (nonatomic,strong) UITextField *retailPriceMaxTextField;

@property (nonatomic,assign) CGRect hideRect;
@property (nonatomic,assign) CGRect normalRect;

@property (nonatomic,assign) BOOL isAnimation;

@end

@implementation YYChooseStyleSlideView
#pragma mark - INIT
- (instancetype)initWithFrame:(CGRect)frame WithConClass:(YYConClass *)connClass WithReqModel:(YYChooseStyleReqModel *)reqModel{
    self = [super initWithFrame:frame];
    if(self){
        _connClass = connClass;
        _reqModel = reqModel;
        [self SomePrepare];
        [self UIConfig];
        [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(minTextFiledEditChanged:)
                                                    name:@"UITextFieldTextDidChangeNotification"
                                                  object:_retailPriceMinTextField];
        [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(maxTextFiledEditChanged:)
                                                    name:@"UITextFieldTextDidChangeNotification"
                                                  object:_retailPriceMaxTextField];
        [self slideShowAnimation];
    }
    return self;
}
-(void)minTextFiledEditChanged:(NSNotification *)obj{
    if([NSString isNilOrEmpty:_retailPriceMinTextField.text]){
        _reqModel.retailPriceMin = @(-1);
    }else{
        _reqModel.retailPriceMin = @([_retailPriceMinTextField.text integerValue]);
    }
}
-(void)maxTextFiledEditChanged:(NSNotification *)obj{
    if([NSString isNilOrEmpty:_retailPriceMaxTextField.text]){
        _reqModel.retailPriceMax = @(-1);
    }else{
        _reqModel.retailPriceMax = @([_retailPriceMaxTextField.text integerValue]);
    }
}
#pragma mark - SomePrepare
-(void)SomePrepare
{
    [self PrepareData];
    [self PrepareUI];
}

-(void)PrepareData{
    _viewArr = [[NSMutableArray alloc] init];
    _normalRect = CGRectMake(SCREEN_WIDTH-(kIPhone6Plus?324.0f:285.0f), 0, kIPhone6Plus?324.0f:285.0f, SCREEN_HEIGHT-YY_TABBAR_HEIGHT);
    _hideRect = CGRectMake(SCREEN_WIDTH, 0, kIPhone6Plus?324.0f:285.0f, SCREEN_HEIGHT-YY_TABBAR_HEIGHT);
    _isAnimation = NO;
}
-(void)PrepareUI{
    self.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.3];
    [self addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(disappearAction)]];
}
#pragma mark - UIConfig
-(void)UIConfig{
    [self CreateBackView];
    [self CreateDownActionView];
    [self CreateScrollView];
    [self CreateScrollContainerUI];
}
-(void)CreateBackView{
    if(!_backView){
        _backView = [UIView getCustomViewWithColor:_define_white_color];
        [self addSubview:_backView];
        _backView.frame = _hideRect;
        [_backView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(NULLAction)]];
    }
}
-(void)CreateDownActionView{
    _downActionView = [UIView getCustomViewWithColor:_define_white_color];
    [_backView addSubview:_downActionView];
    [_downActionView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.right.left.mas_equalTo(0);
        make.height.mas_equalTo(44);
    }];
    
    UIView *lineView = [UIView getCustomViewWithColor:_define_black_color];
    [_downActionView addSubview:lineView];
    [lineView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.top.mas_equalTo(0);
        make.height.mas_equalTo(1);
    }];
    
    UIView *lastView = nil;
    NSArray *titleArr = @[NSLocalizedString(@"重置",nil),NSLocalizedString(@"完成",nil)];
    for (int i=0; i<titleArr.count; i++) {
        UIButton *btn = [UIButton getCustomTitleBtnWithAlignment:0 WithFont:15.0f WithSpacing:0 WithNormalTitle:titleArr[i] WithNormalColor:i?_define_white_color:_define_black_color WithSelectedTitle:nil WithSelectedColor:nil];
        [_downActionView addSubview:btn];
        [btn mas_makeConstraints:^(MASConstraintMaker *make) {
            if(!lastView){
                make.left.mas_equalTo(0);
            }else{
                make.left.mas_equalTo(lastView.mas_right).with.offset(0);
                make.width.mas_equalTo(lastView);
            }
            if(titleArr.count-1 == i){
                make.right.mas_equalTo(0);
            }
            make.top.mas_equalTo(lineView.mas_bottom).with.offset(0);
            make.bottom.mas_equalTo(0);
        }];
        if(i==0){
            btn.backgroundColor = _define_white_color;
            [btn addTarget:self action:@selector(clearAction) forControlEvents:UIControlEventTouchUpInside];
        }else{
            btn.backgroundColor = _define_black_color;
            [btn addTarget:self action:@selector(doneAction) forControlEvents:UIControlEventTouchUpInside];
        }
        lastView = btn;
    }
}
-(void)CreateScrollView
{
    _scrollView=[[UIScrollView alloc] init];
    [_backView addSubview:_scrollView];
    _container = [UIView new];
    [_scrollView addSubview:_container];
    [_container mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(_scrollView);
        make.width.equalTo(_scrollView);
    }];
}
-(void)CreateScrollContainerUI{
    NSArray *typeArr = @[@(YYChooseStyleModuleSlideViewTypeRecommendation)
                         ,@(YYChooseStyleModuleSlideViewTypePeople)
                         ,@(YYChooseStyleModuleSlideViewTypeSuit)
                         ,@(YYChooseStyleModuleSlideViewTypeSeason)
                         ,@(YYChooseStyleModuleSlideViewTypeCurType)];
    UIView *lastView = nil;
    WeakSelf(ws);
    for (int i = 0;i < typeArr.count ; i++) {
        YYChooseStyleModuleSlideView *slideView = [[YYChooseStyleModuleSlideView alloc] initWithConClass:_connClass WithReqModel:_reqModel WithChooseStyleModuleSlideViewType:[typeArr[i] integerValue] HaveDownLine:YES];
        [_container addSubview:slideView];
        [slideView setChooseStyleModuleSlideBlock:^(NSString *type){
            if([type isEqualToString:@"click_done"]){
                if(ws.chooseStyleSlideBlock){
                    ws.chooseStyleSlideBlock(@"update");
                }
                if(slideView.chooseStyleModuleSlideViewType == YYChooseStyleModuleSlideViewTypeCurType){
                    //如果是选择货币
                    //更新下方视图
                    ws.currencySignLabel.text = [ws.reqModel getMoneyFlag];
                }
            }
        }];
        [slideView mas_makeConstraints:^(MASConstraintMaker *make) {
            if(lastView){
                make.top.mas_equalTo(lastView.mas_bottom).with.offset(0);
            }else{
                make.top.mas_equalTo(0);
            }
            make.left.right.mas_equalTo(0);
        }];
        
        lastView = slideView;
        [_viewArr addObject:slideView];
    }
    
    UIView *editPriceView = [UIView getCustomViewWithColor:_define_white_color];
    [_container addSubview:editPriceView];
    [editPriceView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.mas_equalTo(0);
        make.top.mas_equalTo(lastView.mas_bottom).with.offset(0);
        make.height.mas_equalTo(54);
    }];
    
    UIView *editPriceBackView = [UIView getCustomViewWithColor:[UIColor colorWithHex:@"EFEFEF"]];
    [editPriceView addSubview:editPriceBackView];
    [editPriceBackView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.bottom.mas_equalTo(0);
        make.left.mas_equalTo(12);
        make.right.mas_equalTo(-12);
    }];
    
    _currencySignLabel = [UILabel getLabelWithAlignment:2 WithTitle:nil WithFont:14.0f WithTextColor:_define_black_color WithSpacing:0];
    [editPriceBackView addSubview:_currencySignLabel];
    [_currencySignLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(editPriceView);
        make.left.mas_equalTo(0);
        make.width.mas_equalTo(24);
    }];
    
    _retailPriceMinTextField = [[UITextField alloc] init];
    [editPriceBackView addSubview:_retailPriceMinTextField];
    _retailPriceMinTextField.delegate = self;
    _retailPriceMinTextField.keyboardType = UIKeyboardTypeNumberPad;
    _retailPriceMinTextField.backgroundColor = _define_white_color;
    _retailPriceMinTextField.placeholder = NSLocalizedString(@"最低价",nil);
    _retailPriceMinTextField.font = [UIFont systemFontOfSize:13.0f];
    _retailPriceMinTextField.textAlignment = 0;
    setBorderCustom(_retailPriceMinTextField, 1, [UIColor colorWithHex:@"d3d3d3"]);
    _retailPriceMinTextField.layer.cornerRadius = 3.0f;
    [_retailPriceMinTextField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(_currencySignLabel.mas_right).with.offset(8);
        make.height.mas_equalTo(32);
        make.centerY.mas_equalTo(editPriceView);
    }];
    
    UIView *middleLine = [UIView getCustomViewWithColor:[UIColor colorWithHex:@"919191"]];
    [editPriceBackView addSubview:middleLine];
    [middleLine mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(editPriceView);
        make.left.mas_equalTo(_retailPriceMinTextField.mas_right).with.offset(6);
        make.width.mas_equalTo(7.5);
        make.height.mas_equalTo(1.5);
    }];
    
    _retailPriceMaxTextField = [[UITextField alloc] init];
    [editPriceBackView addSubview:_retailPriceMaxTextField];
    _retailPriceMaxTextField.delegate = self;
    _retailPriceMaxTextField.keyboardType = UIKeyboardTypeNumberPad;
    _retailPriceMaxTextField.backgroundColor = _define_white_color;
    _retailPriceMaxTextField.placeholder = NSLocalizedString(@"最高价",nil);
    _retailPriceMaxTextField.font = [UIFont systemFontOfSize:13.0f];
    _retailPriceMaxTextField.textAlignment = 0;
    setBorderCustom(_retailPriceMaxTextField, 1, [UIColor colorWithHex:@"d3d3d3"]);
    _retailPriceMaxTextField.layer.cornerRadius = 3.0f;
    [_retailPriceMaxTextField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(middleLine.mas_right).with.offset(6);
        make.height.mas_equalTo(32);
        make.centerY.mas_equalTo(editPriceView);
        make.right.mas_equalTo(-11);
        make.width.mas_equalTo(_retailPriceMinTextField);
    }];
    
    [_scrollView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.right.mas_equalTo(0);
        make.bottom.mas_equalTo(_downActionView.mas_top).with.offset(0);
        // 让scrollview的contentSize随着内容的增多而变化
        make.bottom.mas_equalTo(editPriceView.mas_bottom).with.offset(30);
    }];
    
    NSLog(@"111");
}
- (BOOL)textFieldShouldEndEditing:(UITextField *)textField{
    if([_retailPriceMinTextField.text integerValue] <= [_retailPriceMaxTextField.text integerValue] || ![_retailPriceMinTextField.text integerValue] || ![_retailPriceMaxTextField.text integerValue]){
        if(_chooseStyleSlideBlock){
            _chooseStyleSlideBlock(@"update");
        }
        return YES;
    }else{
        [YYToast showToastWithTitle:NSLocalizedString(@"最低价不可大于最高价",nil) andDuration:kAlertToastDuration];
        return NO;
    }
}
#pragma mark - SomeAction
-(void)NULLAction{
    [regular dismissKeyborad];
}
-(void)clearAction{
    [regular dismissKeyborad];
    [_reqModel clearSliderData];
    for (YYChooseStyleModuleSlideView *slideView in _viewArr) {
        [slideView clearSliderSelect];
    }
    _currencySignLabel.text = [_reqModel getMoneyFlag];
    _retailPriceMinTextField.text = @"";
    _retailPriceMaxTextField.text = @"";
    
    if(_chooseStyleSlideBlock){
        _chooseStyleSlideBlock(@"update");
    }
}
-(void)doneAction{
    [regular dismissKeyborad];
    if(_chooseStyleSlideBlock){
        _chooseStyleSlideBlock(@"disappear");
    }
}
-(void)slideShowAnimation{
    [regular dismissKeyborad];
    if(!_isAnimation){
        //显示
        self.hidden = NO;
        _isAnimation = YES;
        [UIView animateWithDuration:YY_ANIMATE_DURATION animations:^{
            _backView.frame = _normalRect;
        } completion:^(BOOL finished) {
            _isAnimation = NO;
        }];
    }
}
-(void)slideHideAnimation{
    [regular dismissKeyborad];
    if(!_isAnimation){
        _isAnimation = YES;
        [UIView animateWithDuration:YY_ANIMATE_DURATION animations:^{
            _backView.frame = _hideRect;
        } completion:^(BOOL finished) {
            _isAnimation = NO;
//            隐藏
            self.hidden = YES;
        }];
    }
}
-(void)disappearAction{
    [regular dismissKeyborad];
    if(_chooseStyleSlideBlock){
        _chooseStyleSlideBlock(@"disappear");
    }
}
@end
