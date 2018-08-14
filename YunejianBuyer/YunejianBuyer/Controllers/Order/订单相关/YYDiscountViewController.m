//
//  YYDiscountViewController.m
//  Yunejian
//
//  Created by yyj on 15/8/26.
//  Copyright (c) 2015年 yyj. All rights reserved.
//

#import "YYDiscountViewController.h"

#import "RegexKitLite.h"
#import "UIImage+YYImage.h"

//static CGFloat style_yellowView_default_constant = 132;
//static CGFloat total_yellowView_default_constant = 194;

static int   multiple = 10; //倍数

@interface YYDiscountViewController ()<UITextFieldDelegate>

//@property (weak, nonatomic) IBOutlet UIImageView *styleImageView;
//@property (weak, nonatomic) IBOutlet UILabel *styleNameLable;
@property (weak, nonatomic) IBOutlet UILabel *originalPriceLabel;


@property (weak, nonatomic) IBOutlet UITextField *discountField;
@property (weak, nonatomic) IBOutlet UITextField *reduceField;
@property (weak, nonatomic) IBOutlet UITextField *finalPriceField;

@property (weak, nonatomic) IBOutlet UIButton *reduceButton;
@property (weak, nonatomic) IBOutlet UIButton *increaseButton;

//@property (weak, nonatomic) IBOutlet NSLayoutConstraint *yellowViewTopLayoutConstraint;
@property (weak, nonatomic) IBOutlet UIView *yellowView;

//@property (weak, nonatomic) IBOutlet NSLayoutConstraint *yellowViewHeightLayoutConstraint;



@end

@implementation YYDiscountViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.reduceButton.layer.borderColor = [UIColor blackColor].CGColor;
    self.reduceButton.layer.borderWidth = 1;
    
    self.increaseButton.layer.borderColor = [UIColor blackColor].CGColor;
    self.increaseButton.layer.borderWidth = 1;
    
    self.discountField.enabled = NO;
    self.discountField.layer.borderColor = [UIColor blackColor].CGColor;
    self.discountField.layer.borderWidth = 1;
    
    
    self.reduceField.delegate = self;
    self.reduceField.keyboardType = UIKeyboardTypeNumberPad;
    
    self.finalPriceField.delegate = self;
    self.finalPriceField.keyboardType = UIKeyboardTypeNumberPad;
    
     popWindowAddBgView(self.view);
    
    [self updateUI];
}

- (IBAction)reduceButtonClicked:(id)sender{
    NSString *discountValue = _discountField.text;
    float nowDiscount = [discountValue floatValue];
    if (nowDiscount > 0.2) {
        nowDiscount = round((nowDiscount-0.1)*10)/10.0;
        [self updateReduceAndFinalbyDiscount:nowDiscount];
    }
}

- (IBAction)increaseButtonClicked:(id)sender{
    NSString *discountValue = _discountField.text;
    float nowDiscount = [discountValue floatValue];
    if (nowDiscount < 9.9) {
        nowDiscount =  round((nowDiscount+0.1)*10)/10.0;
        [self updateReduceAndFinalbyDiscount:nowDiscount];
    }
}

- (void)updateReduceAndFinalbyDiscount:(float)discount{
    if (discount > 0
        && discount <= 10) {
        _discountField.text = [NSString stringWithFormat:@"%.1f",discount];
        float finalValue = _originalTotalPrice*discount/multiple;
        _finalPriceField.text = [NSString stringWithFormat:@"%.2f",finalValue];
        _reduceField.text = [NSString stringWithFormat:@"%.2f",(_originalTotalPrice-finalValue)];
        [self updateButtonStauts];
    }
}

- (void)updateButtonStauts{
     _reduceButton.enabled = YES;
    _increaseButton.enabled = YES;
    
    NSString *discountValue = _discountField.text;
    float nowDiscount = [discountValue floatValue];
    if (nowDiscount < 0.2) {
        _reduceButton.enabled = NO;
    }else if (nowDiscount > 9.9){
        _increaseButton.enabled = NO;
    }
    
    NSLog(@"nowDiscount: %f",nowDiscount);
}

- (void)updateUI{
    _originalPriceLabel.adjustsFontSizeToFitWidth = YES;
    _originalPriceLabel.text = [NSString stringWithFormat:@"￥%.2f",_originalTotalPrice];
    _finalPriceField.text = [NSString stringWithFormat:@"%.2f",_finalTotalPrice];
    
    NSString *reduceValue = @"0";
    NSString *discountValue = @"10.00";
    if (_originalTotalPrice > _finalTotalPrice) {
        reduceValue = [NSString stringWithFormat:@"%.2f",(_originalTotalPrice-_finalTotalPrice)];
        discountValue = [NSString stringWithFormat:@"%.2f",_finalTotalPrice/_originalTotalPrice*multiple];
    }
    
    _reduceField.text = reduceValue;
    _discountField.text = discountValue;
    
    [self updateButtonStauts];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (IBAction)cancelClicked:(id)sender{
    if (_cancelButtonClicked) {
        _cancelButtonClicked();
    }
}

- (IBAction)saveClicked:(id)sender{
    
    NSString *finalValue = _finalPriceField.text;
    float nowFinalValue = [finalValue floatValue];
    
    if (nowFinalValue > 0
        && nowFinalValue <= _originalTotalPrice) {
        
        if (_currentDiscountType == DiscountTypeStylePrice){
            _orderStyleModel.finalPrice = [NSNumber numberWithFloat:nowFinalValue];
        }else if (_currentDiscountType == DiscountTypeTotalPrice){
            _currentYYOrderInfoModel.finalTotalPrice = [NSNumber numberWithFloat:nowFinalValue];
        }
        
        
        
    }
    
    if (_modifySuccess) {
        _modifySuccess();
    }
    
}

#pragma mark - UITextFieldDelegate

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    BOOL returnValue = YES;
    NSString *message = nil;
    NSString *str = [textField.text stringByReplacingCharactersInRange:range withString:string];
    
    if (str
        && [str length] > 1) {
        NSString *tempString1 = [str substringToIndex:1];
        NSString *tempString2 = [str substringToIndex:2];
        if ([tempString1 isEqualToString:@"0"]
            && ![tempString2 isEqualToString:@"0."]) {
            message = NSLocalizedString(@"数据格式错误",nil);
            returnValue = NO;
        }
    }
    
    if (returnValue) {
        NSString *regexValue = @"((^[^0]\\d*(\\.?|(\\.\\d\\d?))?)|(0(\\.?|(\\.\\d\\d?))?))?";
        
        if (textField == _reduceField){
            BOOL isRight = [str isMatchedByRegex:regexValue];
            if (!isRight) {
                message = NSLocalizedString(@"减价格式错误",nil);
                returnValue = NO;
            }else{
                float reduceValue = [str floatValue];
                if (reduceValue > _originalTotalPrice) {
                    message = NSLocalizedString(@"减价过多",nil);
                    returnValue = NO;
                }
                
                if (returnValue) {
                    float finalValue = _originalTotalPrice - reduceValue;
                    
                    _finalPriceField.text = [NSString stringWithFormat:@"%.2f",finalValue];
                    _discountField.text =  [NSString stringWithFormat:@"%.1f",finalValue/_originalTotalPrice*multiple];

                }
                
           }
            
        }else if (textField == _finalPriceField){
            BOOL isRight = [str isMatchedByRegex:regexValue];
            if (!isRight) {
                message =  NSLocalizedString(@"总价格式错误",nil);
                returnValue = NO;
            }else{
                float finalValue = [str floatValue];
                
                if (finalValue > _originalTotalPrice) {
                    message = NSLocalizedString(@"总价过高",nil);
                    returnValue = NO;
                }
                
                if (returnValue) {
                    float reduceValue = _originalTotalPrice - finalValue;
                    
                    _reduceField.text = [NSString stringWithFormat:@"%.2f",reduceValue];
                    _discountField.text =  [NSString stringWithFormat:@"%.1f",finalValue/_originalTotalPrice*multiple];
                }
               
            }
        }
    }
    
    
    
    NSLog(@"message: %@",message);
    if (!message) {
        [self updateButtonStauts];
    }else{
        [YYToast showToastWithView:self.view title:message  andDuration:kAlertToastDuration];
        
    }
  
    
    return returnValue;
}

@end
