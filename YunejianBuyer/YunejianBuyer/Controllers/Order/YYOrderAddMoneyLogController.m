//
//  YYOrderAddMoneyLogController.m
//  Yunejian
//
//  Created by Apple on 15/11/26.
//  Copyright © 2015年 yyj. All rights reserved.
//

#import "YYOrderAddMoneyLogController.h"

// c文件 —> 系统文件（c文件在前）

// 控制器
#import "YYNavigationBarViewController.h"

// 自定义视图
#import "MLInputDodger.h"

// 接口
#import "YYOrderApi.h"

// 分类
#import "UIImage+Tint.h"
#import "UIView+UpdateAutoLayoutConstraints.h"

// 自定义类和三方类（ cocoapods类 > model > 工具类 > 其他）
#import "AliPayHelper.h"

#import "YYPaymentNoteListModel.h"


@interface YYOrderAddMoneyLogController ()<UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UIView *containerView;

@property (weak, nonatomic) IBOutlet UIButton *makeSureBtn;
@property (weak, nonatomic) IBOutlet UITextField *inputText;
@property (weak, nonatomic) IBOutlet UILabel *orderCodeLabel;
@property (weak, nonatomic) IBOutlet UILabel *totalMoneyLabel;
@property (weak, nonatomic) IBOutlet UILabel *totalMoneyRateLabel;
@property (weak, nonatomic) IBOutlet UILabel *giveMoneyLabel;
@property (weak, nonatomic) IBOutlet UILabel *giveMoneyRateLabel;
@property (weak, nonatomic) IBOutlet UILabel *lastMoneyLabel;
@property (weak, nonatomic) IBOutlet UILabel *lastMoneyRateLabel;

@property (weak, nonatomic) IBOutlet UILabel *lastMoneyTipLabel;
@property (weak, nonatomic) IBOutlet UILabel *addMoneyTipLabel;
@property (weak, nonatomic) IBOutlet UIButton *warnTipBtn;
@property (weak, nonatomic) IBOutlet UIButton *alipayBtn;
@property (weak, nonatomic) IBOutlet UIButton *offpayBtn;
@property (weak, nonatomic) IBOutlet UILabel *addMoneyTipLabel1;
@property (weak, nonatomic) IBOutlet UILabel *paytypeTItle;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *offpayBtnLayoutTopConstraint;

@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (nonatomic, assign) NSInteger payType;//0 支付宝 1 线下 3编辑
@property (nonatomic,strong) IBOutlet UIImageView *payTypeImageView;

@property (nonatomic,assign)double hasGiveMoney;
@property (nonatomic,assign)NSInteger hasGiveRate;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *paytitleWidthLayout;

@end

@implementation YYOrderAddMoneyLogController
#pragma mark - --------------生命周期--------------
- (void)viewDidLoad {
    [super viewDidLoad];
    [self SomePrepare];
    [self UIConfig];
    [self RequestData];
}
- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    // 进入埋点
    [MobClick beginLogPageView:kYYPageOrderAddMoneyLog];
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    // 退出埋点
    [MobClick endLogPageView:kYYPageOrderAddMoneyLog];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}
#pragma mark - --------------SomePrepare--------------
- (void)SomePrepare
{
    [self PrepareData];
    [self PrepareUI];
}
- (void)PrepareData{
    _hasGiveMoney = 0;
    _hasGiveRate = 0;
    if(_paymentNoteList){
        for (YYPaymentNoteModel *noteModel in _paymentNoteList.result) {
            if([noteModel.payType integerValue] == 0 && ([noteModel.payStatus integerValue] == 0 || [noteModel.payStatus integerValue] == 2)){
            }else{
                _hasGiveMoney += [noteModel.amount doubleValue];
                _hasGiveRate += [noteModel.percent integerValue];
            }
        }
    }
}
- (void)PrepareUI{

    _paytitleWidthLayout.constant = getWidthWithHeight(18, NSLocalizedString(@"尚未支付", @""), [UIFont systemFontOfSize:13.0f]);

    [self.view registerAsDodgeViewForMLInputDodger];

    _inputText.delegate = self;
    _inputText.keyboardType = UIKeyboardTypeNumberPad;
    _inputText.layer.borderColor = [UIColor colorWithHex:kDefaultBorderColor].CGColor;
    _inputText.layer.borderWidth = 1;
    _inputText.layer.cornerRadius = 2.5;
    _inputText.layer.masksToBounds = YES;
    _inputText.text = @"";

    _makeSureBtn.enabled = NO;
    _makeSureBtn.alpha = 0.5;
    _makeSureBtn.layer.masksToBounds = YES;

    _orderCodeLabel.text = _orderCode;

    NSInteger hasGiveRate = [self getHasGiveRate];

    _totalMoneyRateLabel.text = @"100%";
    _giveMoneyRateLabel.text = [NSString stringWithFormat:@"%ld%@",(long)hasGiveRate,@"%"];
    _lastMoneyRateLabel.text = [NSString stringWithFormat:@"%ld%@",(long)(100-hasGiveRate),@"%"];

    _totalMoneyLabel.text = replaceMoneyFlag([NSString stringWithFormat:@"￥%.2f",_totalMoney],_moneyType);
    _giveMoneyLabel.text = replaceMoneyFlag([NSString stringWithFormat:@"￥%.2f",_hasGiveMoney],_moneyType);
    _lastMoneyLabel.text = replaceMoneyFlag([NSString stringWithFormat:@"￥%.2f",(_totalMoney-_hasGiveMoney)],_moneyType);
    _lastMoneyTipLabel.text = NSLocalizedString(@"填写本次付款比例，需小于余款比例",nil);

    UIImage *icon = [[UIImage imageNamed:@"warn"] imageWithTintColor:[UIColor colorWithHex:@"ef4e31"]];
    [_warnTipBtn setImage:icon forState:UIControlStateNormal];
    [_warnTipBtn hideByHeight:YES];

    NSInteger editpercent = 0;
    [self setWillCostMoney:editpercent];
    _inputText.text = [NSString stringWithFormat:@"%ld",editpercent];

    self.scrollView.shiftHeightAsDodgeViewForMLInputDodger = 44.0f+5.0f;
    [self.scrollView registerAsDodgeViewForMLInputDodger];
    [self.scrollView layoutSubviews];

    [_alipayBtn hideByHeight:YES];
    _offpayBtnLayoutTopConstraint.constant = 0;
    _offpayBtn.hidden = NO;
    _paytypeTItle.hidden = NO;
    _payType = 1;
}

#pragma mark - --------------UIConfig----------------------
-(void)UIConfig{
    [self createNavView];
    [self updatePayTypeUI];
}
-(void)createNavView{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]];
    YYNavigationBarViewController *navigationBarViewController = [storyboard instantiateViewControllerWithIdentifier:@"YYNavigationBarViewController"];
    navigationBarViewController.nowTitle = NSLocalizedString(@"付款",nil);
    [_containerView insertSubview:navigationBarViewController.view atIndex:0];
    __weak UIView *_weakContainerView = _containerView;
    [navigationBarViewController.view mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(_weakContainerView.mas_top);
        make.left.equalTo(_weakContainerView.mas_left);
        make.bottom.equalTo(_weakContainerView.mas_bottom);
        make.right.equalTo(_weakContainerView.mas_right);
    }];
    WeakSelf(ws);
    __block YYNavigationBarViewController *blockVc = navigationBarViewController;
    [navigationBarViewController setNavigationButtonClicked:^(NavigationButtonType buttonType){
        if (buttonType == NavigationButtonTypeGoBack) {
            [ws closeAction];
            blockVc = nil;
        }
    }];
}

#pragma mark - --------------请求数据----------------------
-(void)RequestData{
    [self loadAliPaySettting];
    [self loadPaymentNoteList];
}
-(void)loadPaymentNoteList{
    WeakSelf(ws);
    [YYOrderApi getPaymentNoteList:_orderCode andBlock:^(YYRspStatusAndMessage *rspStatusAndMessage, YYPaymentNoteListModel *paymentNoteList, NSError *error) {
        if(rspStatusAndMessage.status == kCode100){
            ws.paymentNoteList = paymentNoteList;
        }else{
            ws.paymentNoteList = nil;
        }
    }];
}
#pragma mark - --------------系统代理----------------------
#pragma mark - UITextFieldDelegate
- (BOOL)textField:(UITextField*)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString*)string{

    NSCharacterSet* cs = [NSCharacterSet characterSetWithCharactersInString:@"0123456789"];
    NSString *filtered = [[string componentsSeparatedByCharactersInSet:cs] componentsJoinedByString:@""];
    NSLog(@"test %@",filtered);
    BOOL basicTest = [filtered isEqualToString:@""];
    if(basicTest) {
        [_warnTipBtn hideByHeight:YES];
        NSString *numStr = [_inputText.text stringByReplacingCharactersInRange:range withString:string];
        NSInteger lastGiveRate = [self getLastGiveRate];
        if([numStr integerValue] > lastGiveRate){
            [_warnTipBtn hideByHeight:NO];
            _inputText.text = [NSString stringWithFormat:@"%ld",lastGiveRate];
            [_inputText resignFirstResponder];
        }
        if([numStr integerValue] == 0){
            _makeSureBtn.alpha = 0.5;
            _makeSureBtn.enabled = NO;
        }else{

            _makeSureBtn.alpha = 1;
            _makeSureBtn.enabled = YES;
        }
        lastGiveRate = MIN(lastGiveRate, [numStr integerValue]);
        [self setWillCostMoney:lastGiveRate];
        return YES;
    }
    return NO;
}

#pragma mark - --------------自定义代理/block----------------------


#pragma mark - --------------自定义响应----------------------
- (IBAction)makeSureHandler:(id)sender {
    if(_payType == 0){
        NSInteger rate = [_inputText.text integerValue];
        double costMeoney = _totalMoney*rate/100;
        costMeoney = MIN(costMeoney, (_totalMoney-_hasGiveMoney));
        if( rate> 0 && costMeoney>0){

            WeakSelf(ws);
            NSDictionary *parameters = @{@"totalFee":[NSString stringWithFormat:@"%.2f",costMeoney],@"subject":@"iphonePaytest",@"body":@"",@"orderCode":_orderCode,@"percent":_inputText.text,@"brandLogo":_brandLogo,@"orderCode1":_orderCode};
            NSData *body = [parameters mj_JSONData];

            [AliPayHelper requestWithParamsData:body andBlock:^(YYRspStatusAndMessage *rspStatusAndMessage,NSDictionary *order, NSError *error) {
                if(rspStatusAndMessage.status == kCode100){
                    [AliPayHelper alixPayWithResponse:order completion:^{
                        [ws.navigationController popViewControllerAnimated:NO];
                    }];
                }else{
                    [YYToast showToastWithView:self.view title:rspStatusAndMessage.message andDuration:kAlertToastDuration];
                }
            }];
        }
    }else if(_payType == 1){
        if(self.modifySuccess){
            NSInteger rate = [_inputText.text integerValue];
            double costMeoney = _totalMoney*rate/100;
            costMeoney = MIN(costMeoney, (_totalMoney-_hasGiveMoney));
            if(rate > 0 && costMeoney > 0){
                [YYOrderApi addPaymentNote:_orderCode percent:[_inputText.text integerValue] amount:[[NSString stringWithFormat:@"%.2f",costMeoney] floatValue] andBlock:^(YYRspStatusAndMessage *rspStatusAndMessage, NSError *error) {
                    if(rspStatusAndMessage.status == kCode100){
                        [YYOrderApi getPaymentNoteList:_orderCode andBlock:^(YYRspStatusAndMessage *rspStatusAndMessage, YYPaymentNoteListModel *paymentNoteList, NSError *error) {
                            NSInteger totalPercent = 0;
                            if(rspStatusAndMessage.status == kCode100){
                                if(_paymentNoteList){
                                    for (YYPaymentNoteModel *noteModel in paymentNoteList.result) {
                                        if([noteModel.payType integerValue] == 0 && ([noteModel.payStatus integerValue] == 0 || [noteModel.payStatus integerValue] == 2)){
                                        }else{
                                            totalPercent += [noteModel.percent integerValue];
                                        }
                                    }
                                }
                            }
                            self.modifySuccess(_orderCode,@(totalPercent));
                        }];
                        [YYToast showToastWithTitle:NSLocalizedString(@"成功",nil) andDuration:kAlertToastDuration];
                    }else{
                        [YYToast showToastWithTitle:rspStatusAndMessage.message andDuration:kAlertToastDuration];
                    }
                }];
            }
        }
    }
}
- (IBAction)alipayHandler:(id)sender {
    if(!_orderCode){
        return;
    }
    if([sender isEqual:_alipayBtn]) {
        _payType = 0;
    }else if([sender isEqual:_offpayBtn]) {
        _payType = 1;
    }
    [self updatePayTypeUI];
}

#pragma mark - --------------自定义方法----------------------
-(void)setWillCostMoney:(NSInteger)rate{
    double costMeoney = _totalMoney*rate/100;
    costMeoney = (costMeoney<0.01?0:costMeoney);
    costMeoney = MIN(costMeoney, (_totalMoney-_hasGiveMoney));
    NSString *addMoneyStr = replaceMoneyFlag([NSString stringWithFormat:@"    ￥%.2f",costMeoney],_moneyType);
    NSMutableAttributedString *attributedStr = [[NSMutableAttributedString alloc] initWithString: addMoneyStr];
    _addMoneyTipLabel.attributedText = attributedStr;

    _addMoneyTipLabel1.text = replaceMoneyFlag([NSString stringWithFormat:@"￥%.2f",costMeoney],_moneyType);
    CGSize textSize = [_addMoneyTipLabel1.text sizeWithAttributes:@{NSFontAttributeName:_addMoneyTipLabel1.font}];
    [_addMoneyTipLabel1 setConstraintConstant:textSize.width+1 forAttribute:NSLayoutAttributeWidth];

    _giveMoneyRateLabel.text = [NSString stringWithFormat:@"%ld%@",(long)(_hasGiveRate+rate),@"%"];
    _lastMoneyRateLabel.text = [NSString stringWithFormat:@"%ld%@",(long)(MAX(0,100-_hasGiveRate-rate)),@"%"];

    _giveMoneyLabel.text = replaceMoneyFlag([NSString stringWithFormat:@"￥%.2f",_hasGiveMoney+costMeoney],_moneyType);
    _lastMoneyLabel.text = replaceMoneyFlag([NSString stringWithFormat:@"￥%.2f",(MAX(0,_totalMoney-_hasGiveMoney -costMeoney))],_moneyType);

}

-(NSInteger)getHasGiveRate{
    return _hasGiveRate;
}

-(NSInteger)getLastGiveRate{
    return MAX(0,100 - [self getHasGiveRate]);
}

- (void)closeAction{
    if (self.cancelButtonClicked) {
        self.cancelButtonClicked();
    }
}
-(void)updatePayTypeUI{
    _alipayBtn.layer.borderWidth = 2;
    _offpayBtn.layer.borderWidth = 2;
    if(_payType == 0){
        _alipayBtn.layer.borderColor = [UIColor colorWithHex:@"ed6498"].CGColor;
        _offpayBtn.layer.borderColor = [UIColor colorWithHex:@"efefef"].CGColor;
        [_makeSureBtn setTitle:NSLocalizedString(@"立即支付",nil) forState:UIControlStateNormal];
        _payTypeImageView.hidden = NO;
        _payTypeImageView.frame = CGRectMake(CGRectGetMaxX(_alipayBtn.frame)- CGRectGetWidth(_payTypeImageView.frame)/2, CGRectGetMinY(_offpayBtn.frame)-CGRectGetHeight(_alipayBtn.frame)-21-CGRectGetHeight(_payTypeImageView.frame)/2, CGRectGetWidth(_payTypeImageView.frame),  CGRectGetHeight(_payTypeImageView.frame));
    }else if(_payType == 1){
        _offpayBtn.layer.borderColor = [UIColor colorWithHex:@"ed6498"].CGColor;
        _alipayBtn.layer.borderColor = [UIColor colorWithHex:@"efefef"].CGColor;
        [_makeSureBtn setTitle:NSLocalizedString(@"确定",nil) forState:UIControlStateNormal];
        _payTypeImageView.hidden = NO;
        _payTypeImageView.frame = CGRectMake(CGRectGetMaxX(_offpayBtn.frame)- CGRectGetWidth(_payTypeImageView.frame)/2, CGRectGetMinY(_offpayBtn.frame)-CGRectGetHeight(_payTypeImageView.frame)/2, CGRectGetWidth(_payTypeImageView.frame),  CGRectGetHeight(_payTypeImageView.frame));

    }else{
        _payTypeImageView.hidden =YES ;
    }
}

-(void)loadAliPaySettting{
    if(_designerId > 0 && _moneyType == 0){
        WeakSelf(ws);
        [YYOrderApi isAvailableForAliPay:_designerId andBlock:^(YYRspStatusAndMessage *rspStatusAndMessage, Boolean isAvailable, NSError *error) {
            if(isAvailable){
                [ ws.alipayBtn hideByHeight:NO];
                ws.offpayBtnLayoutTopConstraint.constant = 21;
                _payType = 0;
            }else{
                [ ws.alipayBtn hideByHeight:YES];
                ws.offpayBtnLayoutTopConstraint = 0;
                _payType = 1;
            }
            [ws updatePayTypeUI];
        }];
    }
}
#pragma mark - --------------other----------------------


@end
