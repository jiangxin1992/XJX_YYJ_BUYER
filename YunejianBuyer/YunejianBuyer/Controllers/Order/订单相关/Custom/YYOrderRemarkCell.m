//
//  YYOrderRemarkCell.m
//  Yunejian
//
//  Created by yyj on 15/8/20.
//  Copyright (c) 2015年 yyj. All rights reserved.
//

#import "YYOrderRemarkCell.h"

#import "YYUser.h"
#import "YYStylesAndTotalPriceModel.h"

@interface YYOrderRemarkCell ()<UITextViewDelegate>

@property (weak, nonatomic) IBOutlet UILabel *styleRemarkLabel;

@property (weak, nonatomic) IBOutlet UILabel *countLabel;
@property (weak, nonatomic) IBOutlet UILabel *priceLabel;

@property (weak, nonatomic) IBOutlet UILabel *tipsLabel;

@property (weak, nonatomic) IBOutlet UITextView *textView;
@property (assign,nonatomic) Boolean hasAddNotification;

@end

@implementation YYOrderRemarkCell

static NSInteger maxLength = 150;

- (void)updateUI{
//    self.firstButton.layer.borderColor = [UIColor blackColor].CGColor;
//    self.firstButton.layer.borderWidth = 1;
//    
//    self.secondButton.layer.borderColor = [UIColor blackColor].CGColor;
//    self.secondButton.layer.borderWidth = 1;
//    
//    self.thirdButton.layer.borderColor = [UIColor blackColor].CGColor;
//    self.thirdButton.layer.borderWidth = 1;
//    
//    self.textView.layer.borderColor = [UIColor blackColor].CGColor;
//    self.textView.layer.borderWidth = 1;
    self.contentView.autoresizingMask = UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth;
    self.textView.delegate = self;
    if(!_hasAddNotification){
        [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(textFiledEditChanged:)
                                                    name:@"UITextViewTextDidChangeNotification"
                                                  object:self.textView];
        _hasAddNotification =YES;
    }

    if (_currentYYOrderInfoModel) {
        if (_currentYYOrderInfoModel.orderDescription
            && [_currentYYOrderInfoModel.orderDescription length] > 0) {
            _textView.text = _currentYYOrderInfoModel.orderDescription;
            _tipsLabel.hidden = YES;
        }else{
            _tipsLabel.hidden = NO;
        }
        _countLabel.text = @"";
        _priceLabel.text = @"";
        
        NSInteger hasRemarkNum = 0;
        for (YYOrderOneInfoModel *oneInfoModel in _currentYYOrderInfoModel.groups) {
            for (YYOrderStyleModel *styleModel  in oneInfoModel.styles) {
                if(![NSString isNilOrEmpty:styleModel.remark]){
                    hasRemarkNum++;
                }
            }
        }
        _styleRemarkLabel.text = [NSString stringWithFormat:NSLocalizedString(@"%ld款已备注",nil),(long)hasRemarkNum];        
    }
}

- (IBAction)styleRemarkButtonClicked:(id)sender {
    if(self.remarkButtonClicked){
        self.remarkButtonClicked();
    }
}



//- (IBAction)firstButtonClicked:(id)sender{
//    if (self.buyerButtonClicked) {
//        self.buyerButtonClicked(sender);
//    }
//}

//- (IBAction)secondButtonClicked:(id)sender{
//    if (self.orderSituationButtonClicked) {
//        self.orderSituationButtonClicked(sender);
//    }
//}



//- (IBAction)discountButtonClicked:(id)sender{
//    if (self.discountButtonClicked) {
//        self.discountButtonClicked();
//    }
//}

#pragma mark - UITextViewDelegate
- (void)textViewDidBeginEditing:(UITextView *)textView{
    if (self.textViewIsEditCallback) {
        self.textViewIsEditCallback(YES);
    }
    _tipsLabel.hidden = YES;
}


- (void)textViewDidEndEditing:(UITextView *)textView{
    if (self.textViewIsEditCallback) {
        self.textViewIsEditCallback(NO);
    }
    
    if (textView.text
        && [textView.text length] > 0) {
        _currentYYOrderInfoModel.orderDescription = textView.text;
    }else{
        _tipsLabel.hidden = NO;
    }
    
    
}
-(void)textFiledEditChanged:(NSNotification *)obj{
    NSString *toBeString = _textView.text;
    NSString *lang = [[UIApplication sharedApplication] textInputMode].primaryLanguage; // 键盘输入模式
    if ([lang isEqualToString:@"zh-Hans"]) { // 简体中文输入，包括简体拼音，健体五笔，简体手写
        UITextRange *selectedRange = [_textView markedTextRange];
        //高亮部分
        UITextPosition *position = [_textView positionFromPosition:selectedRange.start offset:0];
        //已输入的文字进行字数统计和限制
        if (!position) {
            if (toBeString.length > maxLength) {
                _textView.text = [toBeString substringToIndex:maxLength];
            }
        }
    }
    else{
        if (toBeString.length > maxLength) {
            _textView.text = [toBeString substringToIndex:maxLength];
        }
    }
}
#pragma mark - Other

- (void)awakeFromNib {
    // Initialization code
    [super awakeFromNib];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}

-(void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:@"UITextViewTextDidChangeNotification"
                                                  object:self.textView];
}

@end
