//
//  YYRegisterTableIntroduceCell.m
//  YunejianBuyer
//
//  Created by Victor on 2017/12/26.
//  Copyright © 2017年 Apple. All rights reserved.
//

#import "YYRegisterTableIntroduceCell.h"

@interface YYRegisterTableIntroduceCell()<UITextViewDelegate>

@property (nonatomic, strong) UITextField *inputText;
@property (nonatomic, strong) UITextView *introduceInputText;
@property (nonatomic, strong) UILabel *limitLabel;

@property (nonatomic, strong) YYTableViewCellInfoModel *infoModel;

@end

@implementation YYRegisterTableIntroduceCell
#pragma mark - --------------生命周期--------------
- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseIdentifier]) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        self.separatorInset = UIEdgeInsetsMake(0, CGRectGetWidth([UIScreen mainScreen].bounds), 0, 0);
        __weak typeof (self)weakSelf = self;
        
        self.inputText = [[UITextField alloc] init];
        self.inputText.textColor = _define_black_color;
        self.inputText.font = [UIFont systemFontOfSize:12];
        self.inputText.borderStyle = UITextBorderStyleNone;
        self.inputText.layer.borderWidth=2. / [[UIScreen mainScreen] scale];
        self.inputText.layer.borderColor = [UIColor colorWithHex:kDefaultBorderColor].CGColor;
        self.inputText.layer.cornerRadius = 2.5;
        [self.contentView addSubview:self.inputText];
        [self.inputText mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(10);
            make.left.mas_equalTo(17);
            make.bottom.mas_equalTo(-30);
            make.right.mas_equalTo(-17);
        }];
        
        self.introduceInputText = [[UITextView alloc] init];
        self.introduceInputText.textColor = [UIColor lightGrayColor];
        self.introduceInputText.font = [UIFont systemFontOfSize:14];
        [self.contentView addSubview:self.introduceInputText];
        [self.introduceInputText mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(weakSelf.inputText.mas_top).with.offset(5);
            make.left.equalTo(weakSelf.inputText.mas_left).with.offset(8);
            make.bottom.equalTo(weakSelf.inputText.mas_bottom).with.offset(-8);
            make.right.equalTo(weakSelf.inputText.mas_right).with.offset(-8);
        }];
        
        self.limitLabel = [[UILabel alloc] init];
        self.limitLabel.text = NSLocalizedString(@"还可输入 200 字", nil);
        self.limitLabel.textColor = [UIColor lightGrayColor];
        self.limitLabel.font = [UIFont systemFontOfSize:14];
        [self.contentView addSubview:self.limitLabel];
        [self.limitLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.width.mas_equalTo(200);
            make.height.mas_equalTo(14);
            make.top.equalTo(weakSelf.inputText.mas_bottom).with.offset(5);
            make.left.mas_equalTo(17);
        }];
    }
    return self;
}

-(void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UITextViewTextDidChangeNotification object:self.introduceInputText];
    self.tap = nil;
    self.indexPath = nil;
}

#pragma mark - --------------SomePrepare--------------

#pragma mark - --------------UIConfig----------------------
-(void)updateCellInfo:(YYTableViewCellInfoModel *)info{
    self.contentView.autoresizingMask = UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth;
    
    if(!self.tap){
        [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(textFiledEditChanged:) name:UITextViewTextDidChangeNotification object:self.introduceInputText];
        self.tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissKeyboard)];
        
    }
    
    self.infoModel = info;
    self.maxLength = [self.infoModel.title integerValue];
    
    self.introduceInputText.keyboardType = UIKeyboardTypeDefault;
    self.introduceInputText.text = self.infoModel.value;
    self.introduceInputText.delegate = self;
    [self updateLimitTip];
    if([NSString isNilOrEmpty:info.value]){
        self.introduceInputText.text = self.infoModel.tipStr;
    }
}

#pragma mark - --------------请求数据----------------------

#pragma mark - --------------系统代理----------------------
- (void)textViewDidBeginEditing:(UITextView *)textView{
    self.introduceInputText.textColor = _define_black_color;
    if([NSString isNilOrEmpty:self.infoModel.value]){
        self.introduceInputText.text = @"";
    }
}

- (void)textViewDidEndEditing:(UITextView *)textView {
    if ([NSString isNilOrEmpty:self.infoModel.value]) {
        self.introduceInputText.textColor = [UIColor lightGrayColor];
        self.introduceInputText.text = self.infoModel.tipStr;
    } else {
        self.introduceInputText.textColor = _define_black_color;
    }
}

#pragma mark - --------------自定义代理/block----------------------

#pragma mark - --------------自定义响应----------------------
-(void)dismissKeyboard{
    [self keyboardWillHide:nil];
}

-(void)keyboardWillHide:(NSNotification *)aNotification {
    if([_introduceInputText isFirstResponder]==NO){
        return;
    }
    [((UIViewController *)self.delegate).view removeGestureRecognizer:self.tap];
    [self.delegate showTopView:NO];
    [self.introduceInputText resignFirstResponder];
}


-(void)textFiledEditChanged:(NSNotification *)obj{
    NSString *toBeString = self.introduceInputText.text;
    NSString *lang = [[UIApplication sharedApplication] textInputMode].primaryLanguage; // 键盘输入模式
    if ([lang isEqualToString:@"zh-Hans"]) { // 简体中文输入，包括简体拼音，健体五笔，简体手写
        UITextRange *selectedRange = [self.introduceInputText markedTextRange];
        //高亮部分
        UITextPosition *position = [self.introduceInputText positionFromPosition:selectedRange.start offset:0];
        //已输入的文字进行字数统计和限制
        if (!position) {
            if (toBeString.length > self.maxLength) {
                self.introduceInputText.text = [toBeString substringToIndex:self.maxLength];
            }
            
        }
    }
    else{
        if (toBeString.length > self.maxLength) {
            self.introduceInputText.text = [toBeString substringToIndex:self.maxLength];
        }
    }
    self.infoModel.value = self.introduceInputText.text;
    
    [self updateLimitTip];
    [self.delegate selectClick:self.indexPath.row AndSection:self.indexPath.section andParmas:@[self.introduceInputText.text,@(0)]];
}

#pragma mark - --------------自定义方法----------------------
-(void)updateLimitTip{
    NSInteger limitValue = 0;
    if(self.maxLength > self.introduceInputText.text.length){
        limitValue = self.maxLength - self.introduceInputText.text.length;
    }
    
    NSString *numStr = [NSString stringWithFormat:@"%ld",(long)limitValue];
    NSString *limitLabelStr = [NSString stringWithFormat:NSLocalizedString(@"还可输入 %@ 字",nil),numStr];
    
    NSMutableAttributedString *attributedStr = [[NSMutableAttributedString alloc] initWithString: limitLabelStr];
    if([LanguageManager isEnglishLanguage]){
        [attributedStr addAttribute: NSFontAttributeName value: [UIFont boldSystemFontOfSize:15] range: NSMakeRange(0,numStr.length)];
    }else{
        [attributedStr addAttribute: NSFontAttributeName value: [UIFont boldSystemFontOfSize:15] range: NSMakeRange(5,numStr.length)];
    }
    self.limitLabel.attributedText=attributedStr;
    if(limitValue == self.maxLength){
        //_introduceInputText.text = infoModel.tipStr;
        // infoModel.value = @"";
    }else{
        //_inputText.placeholder = @"";
    }
}

#pragma mark - --------------other----------------------

@end
