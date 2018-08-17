//
//  YYNavView.m
//  YunejianBuyer
//
//  Created by yyj on 2017/6/2.
//  Copyright © 2017年 Apple. All rights reserved.
//

#import "YYNavView.h"

#define YY_ANIMATE_DURATION 0.2 //动画持续时间

@interface YYNavView ()

@property (nonatomic, assign) BOOL isAnimation;
@property (nonatomic,assign) BOOL haveStatusView;

@property (nonatomic,strong) UIView *superView;
@property (nonatomic, strong) UIButton *backButton;
@property (nonatomic,strong) UILabel *titleLabel;
@property (nonatomic, strong) UIImageView *titleImageView;
@property (nonatomic, strong) UIView *customView;

@end

@implementation YYNavView
#pragma mark - INIT
-(instancetype)initWithTitle:(NSString *)title WithSuperView:(UIView *)superView haveStatusView:(BOOL )haveStatusView{
    self = [super init];
    if(self){
        _navTitle = title;
        _superView = superView;
        _haveStatusView = haveStatusView;
        
        [self SomePrepare];
        [self UIConfig];
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
    _isAnimation = NO;
}
-(void)PrepareUI{}

#pragma mark - UIConfig
-(void)UIConfig{
    [_superView addSubview:self];
    self.backgroundColor = _define_white_color;
    WeakSelf(ws);
    [self mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.mas_equalTo(0);
        make.top.mas_equalTo(0);
        make.height.mas_equalTo(kStatusBarAndNavigationBarHeight);
    }];
    
    UIView *statusBar = [[UIView alloc] init];
    statusBar.backgroundColor = self.backgroundColor;
    [self addSubview:statusBar];
    [statusBar mas_makeConstraints:^(MASConstraintMaker *make) {
        if (self.haveStatusView) {
            make.height.mas_equalTo(kStatusBarHeight);
        }else {
            make.height.mas_equalTo(0);
        }
        make.top.left.right.mas_equalTo(0);
    }];
    
    UIView *_bottomview = [UIView getCustomViewWithColor:[UIColor colorWithHex:@"d3d3d3"]];
    [self addSubview:_bottomview];
    [_bottomview mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.bottom.mas_equalTo(0);
        make.height.mas_equalTo(1);
    }];
    
    CGFloat imageWidth = [UIImage imageNamed:@"goBack_normal"].size.width;
    CGFloat dX = (40 - imageWidth) / 2;
    self.backButton = [UIButton getCustomImgBtnWithImageStr:@"goBack_normal" WithSelectedImageStr:nil];
    [self addSubview:self.backButton];
    [self.backButton addTarget:self action:@selector(goBack) forControlEvents:UIControlEventTouchUpInside];
    [self.backButton sizeToFit];
    [self.backButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(kStatusBarHeight);
        make.left.mas_equalTo(0);
        make.width.mas_equalTo(CGRectGetWidth(ws.backButton.frame) + dX * 2);
        make.bottom.mas_equalTo(-1);
    }];
    
    self.titleLabel = [UILabel getLabelWithAlignment:1 WithTitle:_navTitle WithFont:18.0f WithTextColor:nil WithSpacing:0];
    [self addSubview:self.titleLabel];
    self.titleLabel.adjustsFontSizeToFitWidth = YES;
    self.titleLabel.minimumScaleFactor = 0.6;
    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(ws);
        make.top.mas_equalTo(statusBar.mas_bottom);
        make.left.mas_equalTo(100);
        make.bottom.mas_equalTo(-1);
        make.right.mas_equalTo(-100);
    }];
    
    self.titleImageView = [[UIImageView alloc] init];
    self.titleImageView.hidden = YES;
    [self addSubview:self.titleImageView];
    [self.titleImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(74);
        make.height.mas_equalTo(24);
        make.centerX.mas_equalTo(0);
        make.centerY.mas_equalTo(ws.titleLabel.mas_centerY);
    }];
    
    self.customView = [[UIView alloc] init];
    self.customView.backgroundColor = _define_white_color;
    self.customView.hidden = YES;
    [self addSubview:self.customView];
    [self.customView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(0);
        make.top.mas_equalTo(statusBar.mas_bottom);
        make.bottom.mas_equalTo(-1);
    }];
}
-(void)setAnimationHide:(BOOL )isHide{
    if(self){
        if(isHide){
            //消失
            if(!self.hidden && !_isAnimation){
                _isAnimation = YES;
                self.alpha = 1.0f;
                [UIView animateWithDuration:YY_ANIMATE_DURATION animations:^{
                    self.alpha = 0.0f;
                } completion:^(BOOL finished) {
                    _isAnimation = NO;
                    self.hidden = YES;
                }];
            }
        }else{
            //出现
            if(self.hidden && !_isAnimation){
                _isAnimation = YES;
                self.hidden = NO;
                self.alpha = 0.0f;
                [UIView animateWithDuration:YY_ANIMATE_DURATION animations:^{
                    self.alpha = 1.0f;
                } completion:^(BOOL finished) {
                    _isAnimation = NO;
                    self.hidden = NO;
                }];
            }
        }
    }
}

-(void)setNavTitle:(NSString *)navTitle{
    _navTitle = navTitle;
    if(_titleLabel){
        _titleLabel.text = _navTitle;
    }
}

- (void)setNavTitleImage:(UIImage *)navImage {
    if (navImage) {
        self.titleLabel.hidden = YES;
        self.titleImageView.hidden = NO;
        self.customView.hidden = YES;
        [self.titleImageView setImage:navImage];
    }else {
        self.titleLabel.hidden = NO;
        self.titleImageView.hidden = YES;
        self.customView.hidden = YES;
    }
}

- (void)setNavCustomView:(UIView *)customView {
    for (UIView *subView in [self.customView subviews]) {
        [subView removeFromSuperview];
    }
    if (customView) {
        self.titleLabel.hidden = YES;
        self.titleImageView.hidden = YES;
        self.customView.hidden = NO;
        [self.customView addSubview:customView];
        __weak UIView *weakView = customView;
        [customView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.center.mas_equalTo(0);
            make.width.mas_equalTo(CGRectGetWidth(weakView.frame));
            make.height.mas_equalTo(CGRectGetHeight(weakView.frame));
            make.left.mas_equalTo(0);
            make.right.mas_equalTo(0);
        }];
    }else {
        self.titleLabel.hidden = NO;
        self.titleImageView.hidden = YES;
        self.customView.hidden = YES;
    }
}

- (void)hidesBackButton {
    [self.backButton mas_updateConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(0);
    }];
}

- (void)setBackButtonTitle:(NSString *)title {
    WeakSelf(ws);
    CGFloat imageWidth = [UIImage imageNamed:@"goBack_normal"].size.width;
    CGFloat dX = (40 - imageWidth) / 2;
    [self.backButton setTitle:title forState:UIControlStateNormal];
    self.backButton.titleLabel.font = [UIFont systemFontOfSize:15];
    [self.backButton setTitleColor:_define_black_color forState:UIControlStateNormal];
    [self.backButton sizeToFit];
    [self.backButton mas_updateConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(CGRectGetWidth(ws.backButton.frame) + dX * 2);
    }];
}

#pragma mark - 自定义响应
- (void)goBack {
    if (self.goBackBlock) {
        self.goBackBlock();
    }else {
        UIViewController *viewController = getCurrentViewController();
        [viewController.navigationController popViewControllerAnimated:YES];
    }
}

@end
