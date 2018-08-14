//
//  YYChooseStyleHeadView.m
//  YunejianBuyer
//
//  Created by yyj on 2017/7/6.
//  Copyright © 2017年 Apple. All rights reserved.
//

#import "YYChooseStyleHeadView.h"

#import "regular.h"
#import "SCGIFImageView.h"
#import "YYUser.h"

#import "AppDelegate.h"
#import "YYMessageButton.h"
#import "YYTopBarShoppingCarButton.h"
#import "YYUntreatedMsgAmountModel.h"

#define YY_NAVBAR_HEIGHT 20

@interface YYChooseStyleHeadView ()

@property (nonatomic,strong) UIView *NavBar;
@property (nonatomic,strong) UIView *searchView;
@property (nonatomic,strong) UILabel *titleLabel;
@property (nonatomic,strong) YYMessageButton *messageButton;
@property (nonatomic,strong) YYTopBarShoppingCarButton *topBarShoppingCarButton;

@property (nonatomic,strong) UIView *ClassBar;
@property (nonatomic,strong) YYChooseStyleButton *sortButton;
@property (nonatomic,strong) YYChooseStyleButton *recommendationButton;
@property (nonatomic,strong) YYChooseStyleButton *screeningButton;

@end

@implementation YYChooseStyleHeadView
// 95
- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
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
-(void)PrepareData{}
-(void)PrepareUI{
    
    self.backgroundColor = _define_white_color;

    _sortButton = [YYChooseStyleButton getCustomBtnWithStyleType:YYChooseStyleButtonStyleSort];
    
    _recommendationButton = [YYChooseStyleButton getCustomBtnWithStyleType:YYChooseStyleButtonStyleRecommendation];
    
    _screeningButton = [YYChooseStyleButton getCustomBtnWithStyleType:YYChooseStyleButtonStyleScreening];
}
#pragma mark - UIConfig
-(void)UIConfig{
    [self CreateNavBar];
    [self CreateClassBar];
}
-(void)CreateNavBar{
    if(!_NavBar){
        _NavBar = [UIView getCustomViewWithColor:_define_white_color];
        [self addSubview:_NavBar];
        [_NavBar mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.right.mas_equalTo(0);
            make.top.mas_equalTo(0);
            make.height.mas_equalTo(45);
        }];
        
        UIView *lineView = [UIView getCustomViewWithColor:[UIColor colorWithHex:@"D3D3D3"]];
        [_NavBar addSubview:lineView];
        [lineView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.right.bottom.mas_equalTo(0);
            make.height.mas_equalTo(1);
        }];

        _titleLabel = [UILabel getLabelWithAlignment:1 WithTitle:NSLocalizedString(@"选款",nil) WithFont:18.0f WithTextColor:nil WithSpacing:0];
        [_NavBar addSubview:_titleLabel];
        [_titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(0);
            make.bottom.mas_equalTo(lineView.mas_top).with.offset(0);
            make.left.mas_equalTo(110);
            make.right.mas_equalTo(-110);
        }];
        _titleLabel.hidden = YES;
        
        _messageButton = [[YYMessageButton alloc] init];
        [_NavBar addSubview:_messageButton];
        [_messageButton addTarget:self action:@selector(messageAction) forControlEvents:UIControlEventTouchUpInside];
        [_messageButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.mas_equalTo(0);
            make.top.mas_equalTo(0);
            make.bottom.mas_equalTo(lineView.mas_top).with.offset(0);
            make.width.mas_equalTo(50);
        }];
        [_messageButton initButton:@""];
        [self updateMessageCount];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(messageCountChanged:)
                                                     name:UnreadMsgAmountChangeNotification
                                                   object:nil];
        
        _topBarShoppingCarButton = [YYTopBarShoppingCarButton buttonWithType:UIButtonTypeCustom];
        [_NavBar addSubview:_topBarShoppingCarButton];
        [_topBarShoppingCarButton addTarget:self action:@selector(shoppingCarButtonClicked) forControlEvents:UIControlEventTouchUpInside];
        [_topBarShoppingCarButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(0);
            make.bottom.mas_equalTo(lineView.mas_top).with.offset(0);
            make.right.mas_equalTo(_messageButton.mas_left).with.offset(0);
            make.width.mas_equalTo(50);
        }];
        self.topBarShoppingCarButton.isRight = YES;
        [self.topBarShoppingCarButton initButton];
        [self updateShoppingCar];
        _topBarShoppingCarButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(updateShoppingCarNotification:)
                                                     name:kUpdateShoppingCarNotification
                                                   object:nil];
        
        _searchView = [UIView getCustomViewWithColor:[UIColor colorWithHex:@"EFEFEF"]];
        [_NavBar addSubview:_searchView];

        [_searchView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(showSearchView)]];
        _searchView.layer.masksToBounds = YES;
        _searchView.layer.cornerRadius = 3.0f;
        [_searchView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(17);
            make.right.mas_equalTo(-85);
            make.centerY.mas_equalTo(_NavBar);
            make.height.mas_equalTo(30);
        }];
        
        UIButton *smallIcon = [UIButton getCustomImgBtnWithImageStr:@"search_Img" WithSelectedImageStr:nil];
        [_searchView addSubview:smallIcon];
        [smallIcon mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(10);
            make.centerY.mas_equalTo(_searchView);
            make.width.mas_equalTo(18);
            make.height.mas_equalTo(22);
        }];
        
        UITextField *searchTextField = [[UITextField alloc] init];
        [_searchView addSubview:searchTextField];
        [searchTextField mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(smallIcon.mas_right).with.offset(0);
            make.top.bottom.right.mas_equalTo(0);
        }];
        searchTextField.textAlignment = 0;
        
        searchTextField.placeholder = NSLocalizedString(@"搜索款式相关关键字",nil);
        searchTextField.text = @"";
        searchTextField.font = getFont(14.0f);
        searchTextField.enabled = NO;
        

    }
}
-(void)CreateClassBar{
    if(!_ClassBar){
        _ClassBar = [UIView getCustomViewWithColor:_define_white_color];
        [self addSubview:_ClassBar];
        [_ClassBar mas_makeConstraints:^(MASConstraintMaker *make) {
            make.bottom.right.left.mas_equalTo(0);
            make.top.mas_equalTo(_NavBar.mas_bottom).with.offset(0);
        }];
        
        UIView *lineView = [UIView getCustomViewWithColor:[UIColor colorWithHex:@"EFEFEF"]];
        [_ClassBar addSubview:lineView];
        [lineView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.right.bottom.mas_equalTo(0);
            make.height.mas_equalTo(1);
        }];

        
        NSArray *btnArr = @[_sortButton,_recommendationButton,_screeningButton];
        NSArray *chooseStyleTypeArr = @[@(YYChooseStyleButtonStyleSort),@(YYChooseStyleButtonStyleRecommendation),@(YYChooseStyleButtonStyleScreening)];
        UIView *lastView = nil;
        CGFloat width = SCREEN_WIDTH/3.0f;
        for (int i = 0; i < btnArr.count; i++) {
            YYChooseStyleButton *button = btnArr[i];
            [_ClassBar addSubview:button];
            [button mas_makeConstraints:^(MASConstraintMaker *make) {
                if(!lastView){
                    make.left.mas_equalTo(0);
                }else{
                    make.left.mas_equalTo(lastView.mas_right).with.offset(0);
                }
                make.top.mas_equalTo(0);
                make.bottom.mas_equalTo(lineView.mas_top).with.offset(0);
                if(!lastView){
                    make.width.mas_equalTo(width + 30);
                }else{
                    make.width.mas_equalTo(width - 15);
                }
                if(btnArr.count-1 == i){
                    make.right.mas_equalTo(0);
                }
            }];
            button.chooseStyleType = [chooseStyleTypeArr[i] integerValue];
            button.chooseStypeIsSelect = NO;
            [button addTarget:self action:@selector(chooseStyleAction:) forControlEvents:UIControlEventTouchUpInside];
            
            if(i == 0){
                UIView *lineView = [UIView getCustomViewWithColor:[UIColor colorWithHex:@"EFEFEF"]];
                [button addSubview:lineView];
                [lineView mas_makeConstraints:^(MASConstraintMaker *make) {
                    make.right.mas_equalTo(0);
                    make.top.mas_equalTo(5);
                    make.bottom.mas_equalTo(-5);
                    make.width.mas_equalTo(1);
                }];
            }
            
            lastView = button;
        }
    }
}
#pragma mark - updateUI
-(void)updateUI{
    [self updateShoppingCar];
    [self updateMessageCount];
    NSArray *btnArr = @[_sortButton,_recommendationButton,_screeningButton];
    for (YYChooseStyleButton *button in btnArr) {
        button.reqModel = _reqModel;
        [button updateUI];
    }
    BOOL hasPermissionsToVisit = [[YYUser currentUser] hasPermissionsToVisit];
    _ClassBar.hidden = !hasPermissionsToVisit;
    _searchView.hidden = !hasPermissionsToVisit;
    _titleLabel.hidden = hasPermissionsToVisit;
}
-(void)setNormalState{
    [self updateShoppingCar];
    [self updateMessageCount];
    if(_sortButton && _recommendationButton && _screeningButton){
        NSArray *btnArr = @[_sortButton,_recommendationButton,_screeningButton];
        for (YYChooseStyleButton * button in btnArr) {
            button.chooseStypeIsSelect = NO;
            button.reqModel = _reqModel;
            [button updateUI];
        }
    }
}
//更新状态
-(void)chooseStyleAction:(YYChooseStyleButton *)chooseStyleBtn{
    if(chooseStyleBtn == _screeningButton){
        chooseStyleBtn.chooseStypeIsSelect = NO;
        if(_chooseStyleBlock){
            _chooseStyleBlock(@"set_normal",chooseStyleBtn.chooseStyleType);
        }
    }else{
        if(chooseStyleBtn.chooseStypeIsSelect){
            chooseStyleBtn.chooseStypeIsSelect = NO;
            if(_chooseStyleBlock){
                _chooseStyleBlock(@"set_normal",chooseStyleBtn.chooseStyleType);
            }
        }else{
            chooseStyleBtn.chooseStypeIsSelect = YES;
            if(_chooseStyleBlock){
                _chooseStyleBlock(@"set_select",chooseStyleBtn.chooseStyleType);
            }
        }
    }
    [chooseStyleBtn updateUI];
    
    if(_sortButton && _recommendationButton && _screeningButton){
        NSArray *btnArr = @[_sortButton,_recommendationButton,_screeningButton];
        for (YYChooseStyleButton * button in btnArr) {
            if(button != chooseStyleBtn){
                button.chooseStypeIsSelect = NO;
                button.reqModel = _reqModel;
                [button updateUI];
            }
        }
    }
}
#pragma mark - SomeAction
- (void)messageCountChanged:(NSNotification *)notification{
    [self updateMessageCount];
}
- (void)updateShoppingCarNotification:(NSNotification *)notification{
    [self updateShoppingCar];
}
-(void)updateMessageCount{
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    [appDelegate.untreatedMsgAmountModel setUnreadMessageAmount:_messageButton];
}
- (void)updateShoppingCar{
    WeakSelf(ws);
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        dispatch_async(dispatch_get_main_queue(), ^{
            AppDelegate *appdelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
            ws.stylesAndTotalPriceModel = getLocalShoppingCartStyleCount(appdelegate.cartDesignerIdArray);
            [ws.topBarShoppingCarButton updateButtonNumber:[NSString stringWithFormat:@"%i", self.stylesAndTotalPriceModel.totalStyles]];
        });
    });
}


-(void)messageAction{
    if(_chooseStyleBlock){
        _chooseStyleBlock(@"enter_message",0);
    }
}
-(void)shoppingCarButtonClicked{
    UIViewController *parent = [UIApplication sharedApplication].keyWindow.rootViewController;
    if (self.stylesAndTotalPriceModel.totalStyles <= 0) {
        [YYToast showToastWithView:parent.view title:NSLocalizedString(@"购物车暂无数据",nil)  andDuration:kAlertToastDuration];
        return;
    }
    if(_chooseStyleBlock){
        _chooseStyleBlock(@"enter_shopping",0);
    }
}
-(void)showSearchView{
    if(_chooseStyleBlock){
        _chooseStyleBlock(@"search",0);
    }
}

/**
 * 更新当前视图的view type
 * 出现状态 | 消失状态 | 完全消失状态
 * 对YYChooseStyleHeadStyle_Custom类型才有影响
 */
-(void)setViewStyle:(YYChooseStyleHeadViewStyle)viewStyle{
    _viewStyle = viewStyle;
    if(self && _headStyle == YYChooseStyleHeadCustom){
        if(viewStyle == YYChooseStyleHeadViewAppear){
            _NavBar.hidden = NO;
            _ClassBar.hidden = NO;
            self.hidden = NO;
        }else if(viewStyle == YYChooseStyleHeadViewDisappear){
            _NavBar.hidden = YES;
            _ClassBar.hidden = NO;
            self.hidden = NO;
        }else if(viewStyle == YYChooseStyleHeadViewTotalDisappear){
            _NavBar.hidden = YES;
            _ClassBar.hidden = YES;
            self.hidden = YES;
        }
    }
}
@end
