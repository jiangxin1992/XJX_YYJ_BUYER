//
//  YYOrderAddMoneyLogController.m
//  Yunejian
//
//  Created by Apple on 15/11/26.
//  Copyright © 2015年 yyj. All rights reserved.
//


// c文件 —> 系统文件（c文件在前）

// 控制器
#import "YYOrderAddMoneyLogController.h"

// 自定义视图
#import "YYNavView.h"
#import "MLInputDodger.h"
#import "MBProgressHUD.h"

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

@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;

@property (weak, nonatomic) IBOutlet UILabel *orderCodeLabel;

@property (weak, nonatomic) IBOutlet UILabel *totalMoneyRateLabel;
@property (weak, nonatomic) IBOutlet UILabel *totalMoneyLabel;

@property (weak, nonatomic) IBOutlet UILabel *giveMoneyRateLabel;
@property (weak, nonatomic) IBOutlet UILabel *giveMoneyLabel;

@property (weak, nonatomic) IBOutlet UILabel *pendingMoneyRateLabel;
@property (weak, nonatomic) IBOutlet UILabel *pendingMoneyLabel;

@property (weak, nonatomic) IBOutlet UILabel *lastMoneyRateLabel;
@property (weak, nonatomic) IBOutlet UILabel *lastMoneyLabel;

@property (weak, nonatomic) IBOutlet UIButton *alipayBtn;
@property (weak, nonatomic) IBOutlet UIButton *offpayBtn;
@property (weak, nonatomic) IBOutlet UILabel *paytypeTitle;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *offpayBtnLayoutTopConstraint;

@property (nonatomic, strong) IBOutlet UIImageView *payTypeImageView;

@property (weak, nonatomic) IBOutlet UIView *addMoneyBackView;
@property (weak, nonatomic) IBOutlet UILabel *lastMoneyTipLabel;
@property (weak, nonatomic) IBOutlet UILabel *addMoneyTipLabel;
@property (weak, nonatomic) IBOutlet UILabel *moneyTypeLabel;
@property (weak, nonatomic) IBOutlet UITextField *inputText;

@property (weak, nonatomic) IBOutlet UIView *refundBackView;
@property (weak, nonatomic) IBOutlet UILabel *refundMoneyLabel;

@property (weak, nonatomic) IBOutlet UILabel *addMoneyTipLabel1;
@property (weak, nonatomic) IBOutlet UIButton *makeSureBtn;

@property (weak, nonatomic) IBOutlet UIView *makeSureView;

@property (nonatomic, strong) YYNavView *navView;
@property (nonatomic, strong) MBProgressHUD *hud;
@property (nonatomic, assign) NSInteger requestCount;//初始请求成功个数 为2的时候让hud小时

@property (nonatomic, assign) NSInteger payType;//0 支付宝 1 线下 3编辑

@property (nonatomic, strong) YYPaymentNoteListModel *paymentNoteList;

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
    _payType = 1;
    _requestCount = 0;
}
- (void)PrepareUI{

    _makeSureView.hidden = _isNeedRefund;
    _addMoneyBackView.hidden = _isNeedRefund;
    _refundBackView.hidden = !_isNeedRefund;

    if(!_addMoneyBackView.hidden){
        self.scrollView.shiftHeightAsDodgeViewForMLInputDodger = 44.0f+5.0f;
        [self.scrollView registerAsDodgeViewForMLInputDodger];
        [self.scrollView layoutSubviews];

        _inputText.delegate = self;
        _inputText.keyboardType = UIKeyboardTypeNumbersAndPunctuation;
        _inputText.layer.borderColor = [UIColor colorWithHex:kDefaultBorderColor].CGColor;
        _inputText.layer.borderWidth = 1;
        _inputText.layer.cornerRadius = 2.5;
        _inputText.layer.masksToBounds = YES;
        _inputText.text = @"0";

        _moneyTypeLabel.text = replaceMoneyFlag(@"￥",_moneyType);

        _lastMoneyTipLabel.text = NSLocalizedString(@"填写本次支付金额，需要小于等于尚未支付金额。",nil);

        _makeSureBtn.enabled = NO;
        _makeSureBtn.alpha = 0.5;
        _makeSureBtn.layer.masksToBounds = YES;

        [_alipayBtn hideByHeight:YES];
        _offpayBtnLayoutTopConstraint.constant = 0;
        _offpayBtn.hidden = NO;
        _paytypeTitle.hidden = NO;

    }

    _orderCodeLabel.text = _orderCode;

    _totalMoneyRateLabel.text = @"100.00%";
    _totalMoneyLabel.text = replaceMoneyFlag([NSString stringWithFormat:@"￥%.2f",_totalMoney],_moneyType);

    _pendingMoneyRateLabel.text = [[NSString alloc] initWithFormat:@"%.2lf%@",[_paymentNoteList.pendingRate floatValue],@"%"];
    _pendingMoneyLabel.text = replaceMoneyFlag([NSString stringWithFormat:@"￥%.2f",[_paymentNoteList.pendingMoney doubleValue]],_moneyType);

    [self setWillCostMoney:0.f];

}
#pragma mark - --------------UIConfig----------------------
-(void)UIConfig{
    [self createNavView];
    [self updatePayTypeUI];
}
-(void)createNavView{
    self.navView = [[YYNavView alloc] initWithTitle:NSLocalizedString(@"付款",nil) WithSuperView:self.view haveStatusView:YES];
    WeakSelf(ws);
    self.navView.goBackBlock = ^{
        [ws goBack];
    };
}

#pragma mark - --------------请求数据----------------------
-(void)RequestData{
    _hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [self loadAliPaySettting];
    [self firstGetPaymentNoteList];
}
-(void)firstGetPaymentNoteList{
    WeakSelf(ws);
    [YYOrderApi getPaymentNoteList:_orderCode finalTotalPrice:_totalMoney andBlock:^(YYRspStatusAndMessage *rspStatusAndMessage, YYPaymentNoteListModel *paymentNoteList, NSError *error) {
        if (rspStatusAndMessage.status == YYReqStatusCode100) {
            ws.requestCount++;
            if(ws.requestCount == 2){
                [ws.hud hideAnimated:YES];
            }
            ws.paymentNoteList = paymentNoteList;
            [ws updateUI];
        } else {
            [ws.hud hideAnimated:YES];
            [YYToast showToastWithView:ws.view title:rspStatusAndMessage.message andDuration:kAlertToastDuration];
        }
    }];
}
-(void)loadAliPaySettting{
    if(_designerId > 0 && _moneyType == 0){
        WeakSelf(ws);
        [YYOrderApi isAvailableForAliPay:_designerId andBlock:^(YYRspStatusAndMessage *rspStatusAndMessage, Boolean isAvailable, NSError *error) {
            if (rspStatusAndMessage.status == YYReqStatusCode100) {
                ws.requestCount++;
                if(ws.requestCount == 2){
                    [ws.hud hideAnimated:YES];
                }
            } else {
                [ws.hud hideAnimated:YES];
            }
            if(isAvailable){
                [ws.alipayBtn hideByHeight:NO];
                ws.offpayBtnLayoutTopConstraint.constant = 21;
                ws.payType = 0;
            }else{
                [ws.alipayBtn hideByHeight:YES];
                ws.offpayBtnLayoutTopConstraint = 0;
                ws.payType = 1;
            }

        dispatch_time_t delayTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1/*延迟执行时间*/ * NSEC_PER_SEC));
            dispatch_after(delayTime, dispatch_get_main_queue(), ^{
                [ws updatePayTypeUI];
            });
        }];
    }else{
        _requestCount++;
    }
}

-(void)addPaymentNote:(double)costMoney{
    [YYOrderApi addPaymentNote:_orderCode amount:[[NSString stringWithFormat:@"%.2f",costMoney] floatValue] andBlock:^(YYRspStatusAndMessage *rspStatusAndMessage, NSError *error) {
        if(rspStatusAndMessage.status == YYReqStatusCode100){
            [YYToast showToastWithTitle:NSLocalizedString(@"成功",nil) andDuration:kAlertToastDuration];
            [self getPaymentNoteList];
        }else{
            [YYToast showToastWithTitle:rspStatusAndMessage.message andDuration:kAlertToastDuration];
        }
    }];
}
-(void)getPaymentNoteList{
    WeakSelf(ws);
    [YYOrderApi getPaymentNoteList:_orderCode finalTotalPrice:_totalMoney andBlock:^(YYRspStatusAndMessage *rspStatusAndMessage, YYPaymentNoteListModel *paymentNoteList, NSError *error) {
        CGFloat hasGiveRate = 0.f;
        if(rspStatusAndMessage.status == YYReqStatusCode100){
            if(ws.paymentNoteList){
                hasGiveRate = [paymentNoteList.hasGiveRate floatValue];
            }
        }
        ws.modifySuccess(ws.orderCode,@(hasGiveRate));
    }];
}
#pragma mark - --------------系统代理----------------------
#pragma mark -UITextFieldDelegate
- (BOOL)textField:(UITextField*)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString*)string{

    NSCharacterSet *cs = [NSCharacterSet characterSetWithCharactersInString:@"0123456789."];
    NSString *filtered = [[string componentsSeparatedByCharactersInSet:cs] componentsJoinedByString:@""];
    NSLog(@"test %@",filtered);
    BOOL basicTest = [NSString isNilOrEmpty:filtered];

    if(basicTest) {

        if ([textField.text containsString:@"."]) {
            if([string isEqualToString:@"."]){
                //如果有两个点
                return NO;
            }else{
                //已存在一个点.输入的不是，
                NSArray *separatedArray = [textField.text componentsSeparatedByString:@"."];
                if(separatedArray.count == 2){
                    NSInteger decimalsLength = ((NSString *)separatedArray[1]).length;
                    if((decimalsLength >= 2) && ![NSString isNilOrEmpty:string]){
                        return NO;
                    }
                }else{
                    return NO;
                }
            }
        }

        //删到底给默认"0"
        if([NSString isNilOrEmpty:string] && textField.text.length == 1){
            textField.text = @"0";
            [self updateState:textField.text];
            return NO;
        }

        //为"0"的时候，输入，去除0，并键入输入内容（除非输入"."）
        if([textField.text isEqualToString:@"0"] && ![NSString isNilOrEmpty:string] && ![string isEqualToString:@"."]){
            textField.text = string;
            [self updateState:textField.text];
            return NO;
        }

        //为空是不能输入"."
        if([string isEqualToString:@"."] && [NSString isNilOrEmpty:textField.text]){
            return NO;
        }

        NSString *numStr = [_inputText.text stringByReplacingCharactersInRange:range withString:string];
        [self updateState:numStr];
        return YES;
    }
    return NO;
}
#pragma mark - --------------自定义代理/block----------------------


#pragma mark - --------------自定义响应----------------------
- (void)goBack {
    [self closeAction];
}

- (IBAction)makeSureHandler:(id)sender {
    if(_payType == 0){
        double costMoney = [_inputText.text floatValue];
        costMoney = MIN(costMoney, (_totalMoney - [_paymentNoteList.hasGiveMoney doubleValue]));
        if(costMoney > 0){
            WeakSelf(ws);
            CGFloat percent = (costMoney/_totalMoney)*100;
            NSDictionary *parameters = @{@"totalFee":[NSString stringWithFormat:@"%.2f",costMoney],@"subject":@"iphonePaytest",@"body":@"",@"orderCode":_orderCode,@"percent":[NSNumber numberWithInteger:(NSInteger)percent],@"brandLogo":_brandLogo,@"orderCode1":_orderCode};
            NSData *body = [parameters mj_JSONData];

            [AliPayHelper requestWithParamsData:body andBlock:^(YYRspStatusAndMessage *rspStatusAndMessage,NSDictionary *order, NSError *error) {
                if(rspStatusAndMessage.status == YYReqStatusCode100){
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
            double costMoney = [_inputText.text floatValue];
            costMoney = MIN(costMoney, (_totalMoney - [_paymentNoteList.hasGiveMoney doubleValue]));
            if(costMoney > 0){
                [self addPaymentNote:costMoney];
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
-(void)updateUI{

    _pendingMoneyRateLabel.text = [[NSString alloc] initWithFormat:@"%.2lf%@",[_paymentNoteList.pendingRate floatValue],@"%"];
    _pendingMoneyLabel.text = replaceMoneyFlag([NSString stringWithFormat:@"￥%.2f",[_paymentNoteList.pendingMoney doubleValue]],_moneyType);

    double refundMoney = MAX(0,[_paymentNoteList.hasGiveMoney doubleValue] - _totalMoney);
    _refundMoneyLabel.text = replaceMoneyFlag([NSString stringWithFormat:@"￥%.2f",refundMoney],_moneyType);
    
    [self setWillCostMoney:0.f];
}
-(void)updatePayTypeUI{
    _alipayBtn.layer.borderWidth = 2;
    _offpayBtn.layer.borderWidth = 2;
    if(_payType == 0){
        _alipayBtn.layer.borderColor = [UIColor colorWithHex:@"ed6498"].CGColor;
        _offpayBtn.layer.borderColor = [UIColor colorWithHex:@"efefef"].CGColor;
        [_makeSureBtn setTitle:NSLocalizedString(@"立即支付",nil) forState:UIControlStateNormal];
        _payTypeImageView.hidden = NO;
        _payTypeImageView.frame = CGRectMake(CGRectGetMaxX(_alipayBtn.frame) - CGRectGetWidth(_payTypeImageView.frame)/2, CGRectGetMinY(_offpayBtn.frame) - CGRectGetHeight(_alipayBtn.frame) - 21 - CGRectGetHeight(_payTypeImageView.frame)/2, CGRectGetWidth(_payTypeImageView.frame),  CGRectGetHeight(_payTypeImageView.frame));
    }else if(_payType == 1){
        _offpayBtn.layer.borderColor = [UIColor colorWithHex:@"ed6498"].CGColor;
        _alipayBtn.layer.borderColor = [UIColor colorWithHex:@"efefef"].CGColor;
        [_makeSureBtn setTitle:NSLocalizedString(@"保存",nil) forState:UIControlStateNormal];
        _payTypeImageView.hidden = NO;
        _payTypeImageView.frame = CGRectMake(CGRectGetMaxX(_offpayBtn.frame) - CGRectGetWidth(_payTypeImageView.frame)/2, CGRectGetMinY(_offpayBtn.frame) - CGRectGetHeight(_payTypeImageView.frame)/2, CGRectGetWidth(_payTypeImageView.frame),  CGRectGetHeight(_payTypeImageView.frame));
    }else{
        _payTypeImageView.hidden =YES ;
    }
}
-(void)updateState:(NSString *)numStr{
    CGFloat lastGiveAmount = [self getLastGiveAmount];
    CGFloat num = [numStr floatValue];
    if(num > lastGiveAmount){
        if(lastGiveAmount){
            _inputText.text = [NSString stringWithFormat:@"%.2lf",lastGiveAmount];
        }else{
            _inputText.text = [NSString stringWithFormat:@"%.lf",lastGiveAmount];
        }
        [_inputText resignFirstResponder];
    }
    if(num == 0){
        _makeSureBtn.alpha = 0.5;
        _makeSureBtn.enabled = NO;
    }else{
        _makeSureBtn.alpha = 1;
        _makeSureBtn.enabled = YES;
    }
    lastGiveAmount = MIN(lastGiveAmount, num);
    [self setWillCostMoney:lastGiveAmount];
}

-(void)setWillCostMoney:(CGFloat)costMoney{

    CGFloat costRate = (costMoney/_totalMoney)*100.f;

    _addMoneyTipLabel.text = [[NSString alloc] initWithFormat:@"    %.2lf%%",costRate];

    _addMoneyTipLabel1.text = replaceMoneyFlag([NSString stringWithFormat:@"￥%.2f",costMoney],_moneyType);
    CGSize textSize = [_addMoneyTipLabel1.text sizeWithAttributes:@{NSFontAttributeName:_addMoneyTipLabel1.font}];
    [_addMoneyTipLabel1 setConstraintConstant:textSize.width+1 forAttribute:NSLayoutAttributeWidth];

    _giveMoneyRateLabel.text = [NSString stringWithFormat:@"%.2lf%@",([_paymentNoteList.hasGiveRate floatValue] + costRate),@"%"];
    _lastMoneyRateLabel.text = [NSString stringWithFormat:@"%.2lf%@",(MAX(0,100 - [_paymentNoteList.hasGiveRate floatValue] - costRate - [_paymentNoteList.pendingRate floatValue])),@"%"];

    _giveMoneyLabel.text = replaceMoneyFlag([NSString stringWithFormat:@"￥%.2f",[_paymentNoteList.hasGiveMoney doubleValue] + costMoney],_moneyType);
    _lastMoneyLabel.text = replaceMoneyFlag([NSString stringWithFormat:@"￥%.2f",(MAX(0,_totalMoney - [_paymentNoteList.hasGiveMoney doubleValue] - costMoney - [_paymentNoteList.pendingMoney doubleValue]))],_moneyType);

}

#pragma mark -other

/**
 剩余支付比例

 @return ...
 */
-(CGFloat)getLastGiveRate{
    return MAX(0,100 - [_paymentNoteList.hasGiveRate floatValue] - [_paymentNoteList.pendingRate floatValue]);
}
/**
 剩余可付款

 @return ...
 */
-(double)getLastGiveAmount{
    return MAX(0,_totalMoney - [_paymentNoteList.hasGiveMoney doubleValue] - [_paymentNoteList.pendingMoney doubleValue]);
}

- (void)closeAction{
    if (self.cancelButtonClicked) {
        self.cancelButtonClicked();
    }
}

#pragma mark - --------------other----------------------


@end
