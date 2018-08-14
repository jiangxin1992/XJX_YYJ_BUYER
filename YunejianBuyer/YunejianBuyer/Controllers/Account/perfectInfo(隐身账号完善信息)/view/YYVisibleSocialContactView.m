//
//  YYVisibleSocialContactView.m
//  YunejianBuyer
//
//  Created by chuanjun sun on 2017/10/27.
//  Copyright © 2017年 Apple. All rights reserved.
//

#import "YYVisibleSocialContactView.h"

@interface YYVisibleSocialContactView()<UITextViewDelegate, UITextFieldDelegate>
/** 协议整体视图 */
@property (nonatomic, strong) UIView *agreeView;
/** 同意按钮 */
@property (nonatomic, strong) UIButton *agreeButton;
/** 最后一条线 */
@property (nonatomic, strong) UIView *line;
@end

@implementation YYVisibleSocialContactView

#pragma mark - --------------生命周期--------------
- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self SomePrepare];
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

}


#pragma mark - --------------系统代理----------------------
#pragma mark - textView
- (BOOL)textView:(UITextView *)textView shouldInteractWithURL:(NSURL *)URL inRange:(NSRange)characterRange {

    if ([[URL scheme] isEqualToString:@"type"]) {
        NSString *type = [URL host];
        NSString *title;
        if([type isEqualToString:@"serviceAgreement"]){
            title = NSLocalizedString(@"服务协议",nil);
        }else if([type isEqualToString:@"secrecyAgreement"]){
            title = NSLocalizedString(@"隐私协议",nil);
        }

        if (self.agreement) {
            self.agreement(type, title);
        }
        
        return NO;
    }
    return YES;
}

#pragma mark - text
- (void)textChange:(UITextField *)textView{
    if ([self.delegate respondsToSelector:@selector(YYVisibleSocialContactView:withTag:content:)]) {
        [self.delegate YYVisibleSocialContactView:self withTag:textView.tag content:textView.text];
    }
}

#pragma mark - --------------自定义代理/block----------------------


#pragma mark - --------------自定义响应----------------------
// 按钮状态
- (void)agreeButtonClick:(UIButton *)button{
    button.selected = !button.selected;
    self.isAgree = button.selected;

}

#pragma mark - --------------自定义方法----------------------


#pragma mark - --------------UI----------------------
// 创建子控件
- (void)PrepareUI{
    self.backgroundColor = _define_white_color;

    NSArray *iamgeArray = @[@"weixin_public_icon",
                            @"sina_icon",
                            @"instagram_icon",
                            @"facebook_icon"];

    NSArray *labelArray = @[NSLocalizedString(@"微信公众号", nil),
                            NSLocalizedString(@"新浪微博", nil),
                            NSLocalizedString(@"Instagram", nil),
                            NSLocalizedString(@"Facebook", nil)];

    NSArray *textArray = @[NSLocalizedString(@"请填写公众号", nil),
                           NSLocalizedString(@"请填写新浪微博账号", nil),
                           NSLocalizedString(@"请填写Instagram账号", nil),
                           NSLocalizedString(@"请填写Facebook账号", nil)];

    for (int x = 0; x<4; x++) {
        UIImageView *image = [[UIImageView alloc] initWithImage:[UIImage imageNamed:iamgeArray[x]]];
        [self addSubview:image];
        [image mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(10);
            make.top.mas_equalTo(18.5 + 79*x);
            make.width.height.mas_equalTo(19);
        }];


        UILabel *label = [[UILabel alloc] init];
        label.text = labelArray[x];
        label.textColor =_define_black_color;
        label.font = [UIFont systemFontOfSize:15];
        [self addSubview:label];
        [label mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(image.mas_right).mas_offset(8);
            make.centerY.mas_equalTo(image.mas_centerY);
        }];

        [label sizeToFit];

        UITextField *textField = [[UITextField alloc] init];
        textField.font = [UIFont systemFontOfSize:15];
        [textField addTarget:self action:@selector(textChange:) forControlEvents:UIControlEventEditingChanged];
        textField.tag = x;
        [textField setValue:[UIFont boldSystemFontOfSize:15] forKeyPath:@"_placeholderLabel.font"];
        textField.placeholder = textArray[x];

        [self addSubview:textField];

        [textField mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(label.mas_bottom).mas_offset(20);
            make.height.mas_equalTo(25);
            make.left.mas_equalTo(label.mas_left).offset(-10);
            make.right.mas_equalTo(-12.5);
        }];

        UILabel *line = [[UILabel alloc] init];
        line.backgroundColor = [UIColor colorWithHex:@"EFEFEF"];
        self.line = line;
        [textField addSubview:line];

        [line mas_makeConstraints:^(MASConstraintMaker *make) {
            make.bottom.right.mas_equalTo(0);
            make.left.mas_equalTo(10);
            make.height.mas_equalTo(1);
        }];
    }

    if (!_agreeView) {
        UIView *agreeView = [[UIView alloc] init];
        self.agreeView = agreeView;
        [self addSubview:agreeView];

        [agreeView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(self.line.mas_bottom);
            make.height.mas_equalTo(60);
            make.left.mas_equalTo(10);
            make.right.mas_equalTo(0);
        }];

        // 是否同意按钮，默认同意 selectedCircle  selectCircle
        UIButton *agreeButton = [UIButton getCustomBackImgBtnWithImageStr:@"selectCircle" WithSelectedImageStr:@"selectedCircle"];
        agreeButton.selected = YES;
        self.agreeButton = agreeButton;
        [agreeButton addTarget:self action:@selector(agreeButtonClick:) forControlEvents:UIControlEventTouchUpInside];

        [agreeView addSubview:agreeButton];

        [agreeButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(0);
            make.centerY.mas_equalTo(agreeView.mas_centerY);
            make.width.mas_equalTo(17);
            make.height.mas_equalTo(17);
        }];

        // 条款，拼接
        NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:NSLocalizedString(@"已同意服务协议和隐私协议",nil)];
        [attributedString addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:15] range:[[attributedString string] rangeOfString:[attributedString string]]];
        [attributedString addAttribute:NSLinkAttributeName
                                 value:@"type://serviceAgreement"
                                 range:[[attributedString string] rangeOfString:NSLocalizedString(@"服务协议",nil)]];
        [attributedString addAttribute:NSLinkAttributeName
                                 value:@"type://secrecyAgreement"
                                 range:[[attributedString string] rangeOfString:NSLocalizedString(@"隐私协议",nil)]];

        NSDictionary *linkAttributes = @{NSUnderlineStyleAttributeName:@(NSUnderlineStyleSingle)};

        // assume that textView is a UITextView previously created (either by code or Interface Builder)
        UITextView *ruleTextView = [[UITextView alloc] init];
        ruleTextView.linkTextAttributes = linkAttributes; // customizes the appearance of links
        ruleTextView.attributedText = attributedString;
        ruleTextView.editable = NO;
        ruleTextView.contentInset = UIEdgeInsetsMake(0, 0, 0, 0);
        ruleTextView.font = [UIFont systemFontOfSize:15];
        ruleTextView.scrollEnabled = NO;
        ruleTextView.delegate = self;

        self.isAgree = YES;
        [agreeView addSubview:ruleTextView];

        [ruleTextView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(agreeButton.mas_right).mas_offset(10);
            NSString *langCode = [LanguageManager currentLanguageCode];
            if ([langCode containsString:@"zh"]) {
                make.centerY.mas_equalTo(agreeButton.mas_centerY).mas_offset(12);
            } else {
                make.centerY.mas_equalTo(agreeButton.mas_centerY);
            }
            make.height.mas_equalTo(60);
            make.right.mas_equalTo(agreeView.mas_right);
        }];
    }
}

#pragma mark - --------------other----------------------
@end
