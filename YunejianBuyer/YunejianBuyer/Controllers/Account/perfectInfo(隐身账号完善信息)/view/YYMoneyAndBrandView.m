//
//  YYMoneyAndBrandView.m
//  YunejianBuyer
//
//  Created by chuanjun sun on 2017/10/27.
//  Copyright © 2017年 Apple. All rights reserved.
//

#import "YYMoneyAndBrandView.h"

@interface YYMoneyAndBrandView()<UITextFieldDelegate>

@end

@implementation YYMoneyAndBrandView

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
#pragma mark - text
- (void)textChange:(UITextField *)textView{
    if ([self.delegate respondsToSelector:@selector(YYMoneyAndBrandView:inputTag:content:)]) {
        [self.delegate YYMoneyAndBrandView:self inputTag:textView.tag content:textView.text];
    }
}

#pragma mark - --------------自定义代理/block----------------------


#pragma mark - --------------自定义响应----------------------


#pragma mark - --------------自定义方法----------------------


#pragma mark - --------------UI----------------------
// 创建子控件
- (void)PrepareUI{
    self.backgroundColor = _define_white_color;

    // ===
    UILabel *moneyRangeLabel = [[UILabel alloc] init];
    moneyRangeLabel.text = NSLocalizedString(@"*款式零售价范围￥", nil);
    moneyRangeLabel.textColor = _define_black_color;
    moneyRangeLabel.font = [UIFont systemFontOfSize:15];
    [self addSubview:moneyRangeLabel];

    [moneyRangeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(13.5);
        make.top.mas_equalTo(25);
    }];
    [moneyRangeLabel sizeToFit];

    // ===
    UILabel *fromLabel = [[UILabel alloc] init];
    fromLabel.text = NSLocalizedString(@"从", nil);
    fromLabel.font = [UIFont systemFontOfSize:15];
    fromLabel.textColor = _define_black_color;
    [self addSubview:fromLabel];

    [fromLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(13);
        make.top.mas_equalTo(moneyRangeLabel.mas_bottom).mas_offset(25);
    }];
    [fromLabel sizeToFit];

    UITextField *fromField = [[UITextField alloc] init];
    [fromField addTarget:self action:@selector(textChange:) forControlEvents:UIControlEventEditingChanged];
    fromField.tag = 0;
    fromField.keyboardType = UIKeyboardTypeNumberPad;
    [fromField setValue:[UIFont boldSystemFontOfSize:15] forKeyPath:@"_placeholderLabel.font"];
    fromField.placeholder = NSLocalizedString(@"款式最低零售价", nil);
    fromField.font = [UIFont systemFontOfSize:15];
    fromField.textColor = _define_black_color;
    [self addSubview:fromField];
    [fromField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(fromLabel.mas_right).mas_offset(13.5);
        make.right.mas_equalTo(self.mas_centerX).mas_offset(-14);
        make.height.mas_equalTo(38);
        make.centerY.mas_equalTo(fromLabel.mas_centerY);
    }];

    UIView *fromLine = [[UIView alloc] init];
    fromLine.backgroundColor = [UIColor colorWithHex:@"EFEFEF"];
    [fromField addSubview:fromLine];

    [fromLine mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(1);
        make.left.bottom.right.mas_equalTo(0);
    }];


    // ===
    UILabel *toLabel = [[UILabel alloc] init];
    toLabel.text = NSLocalizedString(@"到", nil);
    toLabel.font = [UIFont systemFontOfSize:15];
    toLabel.textColor = _define_black_color;
    [self addSubview:toLabel];

    [toLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.mas_centerX);
        make.top.mas_equalTo(moneyRangeLabel.mas_bottom).mas_offset(25);
    }];
    [fromLabel sizeToFit];

    UITextField *toField = [[UITextField alloc] init];
    toField.font = [UIFont systemFontOfSize:15];
    [toField addTarget:self action:@selector(textChange:) forControlEvents:UIControlEventEditingChanged];
    toField.tag = 1;
    toField.keyboardType = UIKeyboardTypeNumberPad;
    [toField setValue:[UIFont boldSystemFontOfSize:15] forKeyPath:@"_placeholderLabel.font"];
    toField.placeholder = NSLocalizedString(@"款式最高零售价", nil);
    toField.textColor = _define_black_color;
    [self addSubview:toField];
    [toField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(toLabel.mas_right).mas_offset(13.5);
        make.right.mas_equalTo(self.mas_right).mas_offset(-14);
        make.height.mas_equalTo(38);
        make.centerY.mas_equalTo(toLabel.mas_centerY);
    }];

    UIView *toLine = [[UIView alloc] init];
    toLine.backgroundColor = [UIColor colorWithHex:@"EFEFEF"];
    [toField addSubview:toLine];

    [toLine mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(1);
        make.left.bottom.right.mas_equalTo(0);
    }];

    // ===
    UILabel *brandRangeLabel = [[UILabel alloc] init];
    brandRangeLabel.text = NSLocalizedString(@"*列举合作品牌", nil);
    brandRangeLabel.textColor = _define_black_color;
    brandRangeLabel.font = [UIFont systemFontOfSize:15];
    [self addSubview:brandRangeLabel];

    [brandRangeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(13.5);
        make.top.mas_equalTo(toField.mas_bottom).mas_offset(25);
    }];
    [brandRangeLabel sizeToFit];

    UIView *lineH1 = [[UIView alloc] init];
    UIView *lineH2 = [[UIView alloc] init];
    UIView *lineH3 = [[UIView alloc] init];
    UIView *lineH4 = [[UIView alloc] init];

    UIView *lineV1 = [[UIView alloc] init];
    UIView *lineV2 = [[UIView alloc] init];
    UIView *lineV3 = [[UIView alloc] init];

    lineH1.backgroundColor = [UIColor colorWithHex:@"EFEFEF"];
    lineH2.backgroundColor = [UIColor colorWithHex:@"EFEFEF"];
    lineH3.backgroundColor = [UIColor colorWithHex:@"EFEFEF"];
    lineH4.backgroundColor = [UIColor colorWithHex:@"EFEFEF"];

    lineV1.backgroundColor = [UIColor colorWithHex:@"EFEFEF"];
    lineV2.backgroundColor = [UIColor colorWithHex:@"EFEFEF"];
    lineV3.backgroundColor = [UIColor colorWithHex:@"EFEFEF"];

    [self addSubview:lineH1];
    [self addSubview:lineH2];
    [self addSubview:lineH3];
    [self addSubview:lineH4];

    [self addSubview:lineV1];
    [self addSubview:lineV2];
    [self addSubview:lineV3];

    [lineH1 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(1);
        make.left.mas_equalTo(13);
        make.right.mas_equalTo(-13);
        make.top.mas_equalTo(brandRangeLabel.mas_bottom).mas_offset(10);
    }];

    [lineH2 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(1);
        make.left.mas_equalTo(13);
        make.right.mas_equalTo(-13);
        make.top.mas_equalTo(lineH1.mas_bottom).mas_offset(53);
    }];

    [lineH3 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(1);
        make.left.mas_equalTo(13);
        make.right.mas_equalTo(-13);
        make.top.mas_equalTo(lineH2.mas_bottom).mas_offset(53);
    }];

    [lineH4 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(1);
        make.left.mas_equalTo(13);
        make.right.mas_equalTo(-13);
        make.top.mas_equalTo(lineH3.mas_bottom).mas_offset(53);
    }];


    [lineV1 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(1);
        make.top.mas_equalTo(lineH1.mas_bottom).mas_offset(4.5);
        make.bottom.mas_equalTo(lineH2.mas_bottom).mas_offset(-4.5);
        make.centerX.mas_equalTo(self.mas_centerX);
    }];

    [lineV2 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(1);
        make.top.mas_equalTo(lineH2.mas_bottom).mas_offset(4.5);
        make.bottom.mas_equalTo(lineH3.mas_bottom).mas_offset(-4.5);
        make.centerX.mas_equalTo(self.mas_centerX);
    }];

    [lineV3 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(1);
        make.top.mas_equalTo(lineH3.mas_bottom).mas_offset(4.5);
        make.bottom.mas_equalTo(lineH4.mas_bottom).mas_offset(-4.5);
        make.centerX.mas_equalTo(self.mas_centerX);
    }];

    // 品牌1～6的输入框
    UITextField *brand1 = [[UITextField alloc] init];
    UITextField *brand2 = [[UITextField alloc] init];
    UITextField *brand3 = [[UITextField alloc] init];
    UITextField *brand4 = [[UITextField alloc] init];
    UITextField *brand5 = [[UITextField alloc] init];
    UITextField *brand6 = [[UITextField alloc] init];

    brand1.placeholder = NSLocalizedString(@"品牌1", nil);
    brand2.placeholder = NSLocalizedString(@"品牌2", nil);
    brand3.placeholder = NSLocalizedString(@"品牌3", nil);
    brand4.placeholder = NSLocalizedString(@"品牌4", nil);
    brand5.placeholder = NSLocalizedString(@"品牌5", nil);
    brand6.placeholder = NSLocalizedString(@"品牌6", nil);

    NSArray *array = @[brand1, brand2, brand3, brand4, brand5, brand6];
    int x = 2;
    for (UITextField *field in array) {
        [field setValue:[UIFont boldSystemFontOfSize:15] forKeyPath:@"_placeholderLabel.font"];
        field.font = [UIFont systemFontOfSize:15];
        [self addSubview:field];
        [field addTarget:self action:@selector(textChange:) forControlEvents:UIControlEventEditingChanged];
        field.tag = x;
        x++;

    }

    [brand1 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(13);
        make.right.mas_equalTo(lineV1.mas_left).mas_offset(10);
        make.top.mas_equalTo(lineH1.mas_bottom).mas_offset(2);
        make.bottom.mas_equalTo(lineH2.mas_top).mas_offset(-2);
    }];

    [brand2 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(lineV1.mas_right).mas_offset(13);
        make.right.mas_equalTo(-10);
        make.top.mas_equalTo(lineH1.mas_bottom).mas_offset(2);
        make.bottom.mas_equalTo(lineH2.mas_top).mas_offset(-2);
    }];

    [brand3 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(13);
        make.right.mas_equalTo(lineV2.mas_left).mas_offset(10);
        make.top.mas_equalTo(lineH2.mas_bottom).mas_offset(2);
        make.bottom.mas_equalTo(lineH3.mas_top).mas_offset(-2);
    }];

    [brand4 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(lineV2.mas_right).mas_offset(13);
        make.right.mas_equalTo(-10);
        make.top.mas_equalTo(lineH2.mas_bottom).mas_offset(2);
        make.bottom.mas_equalTo(lineH3.mas_top).mas_offset(-2);
    }];

    [brand5 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(13);
        make.right.mas_equalTo(lineV3.mas_left).mas_offset(10);
        make.top.mas_equalTo(lineH3.mas_bottom).mas_offset(2);
        make.bottom.mas_equalTo(lineH4.mas_top).mas_offset(-2);
    }];

    [brand6 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(lineV3.mas_right).mas_offset(13);
        make.right.mas_equalTo(-10);
        make.top.mas_equalTo(lineH3.mas_bottom).mas_offset(2);
        make.bottom.mas_equalTo(lineH4.mas_top).mas_offset(-2);
    }];

    // 多余品牌
    UITextField *brandOther = [[UITextField alloc] init];
    brandOther.placeholder = NSLocalizedString(@"其他合作品牌，用逗号隔开（非必填）", nil);
    [brandOther setValue:[UIFont boldSystemFontOfSize:15] forKeyPath:@"_placeholderLabel.font"];
    [brandOther addTarget:self action:@selector(textChange:) forControlEvents:UIControlEventEditingChanged];
    brandOther.tag = 8;
    [self addSubview:brandOther];

    [self addSubview:brandOther];

    [brandOther mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(lineH4.mas_bottom).mas_offset(2);
        make.height.mas_equalTo(53);
        make.left.mas_equalTo(13);
        make.right.mas_equalTo(-13);
    }];
}

#pragma mark - --------------other----------------------
@end
