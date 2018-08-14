//
//  YYVisibleContactInfoTableViewCell.m
//  YunejianBuyer
//
//  Created by chuanjun sun on 2017/10/25.
//  Copyright © 2017年 Apple. All rights reserved.
//

#import "YYVisibleContactInfoTableViewCell.h"

@interface YYVisibleContactInfoTableViewCell()<UITextViewDelegate>
/** (*) */
@property (nonatomic, strong) UILabel *xingLabel;
/** 图片 */
@property (nonatomic, strong) UIImageView *titleImageView;
/** 输入框 */
@property (nonatomic, strong) UITextField *inputTextField;
/** 输入框上可能有的按钮 */
@property (nonatomic, strong) UIButton *inputButton;
/** 最后的按钮 */
@property (nonatomic, strong) UIImageView *tipImageView;
@end

@implementation YYVisibleContactInfoTableViewCell
#pragma mark - --------------生命周期--------------

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
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


#pragma mark - --------------自定义代理/block----------------------


#pragma mark - --------------自定义响应----------------------
- (void)inputButtonClick{
    if ([self.delegate respondsToSelector:@selector(YYVisibleCellselectClick:)]) {
        [self.delegate YYVisibleCellselectClick:self];
    }
}

#pragma mark - 监听输入框变化
- (void)changeTextField{

    // 安全判断
    if ([self.delegate respondsToSelector:@selector(YYVisibleCellInputChange:text:)]) {
        [self.delegate YYVisibleCellInputChange:self text:self.inputTextField.text];
    }
}

#pragma mark - --------------自定义方法----------------------
- (void)setTitleImageName:(NSString *)titleImageName{
    _titleImageName = titleImageName;
    self.titleImageView.image = [UIImage imageNamed:titleImageName];
    if ([NSString isNilOrEmpty:titleImageName]) {
        self.xingLabel.hidden = YES;
    }
}

- (void)setInputPlaceHode:(NSString *)inputPlaceHode{
    _inputPlaceHode = inputPlaceHode;
    self.inputTextField.placeholder =inputPlaceHode;
}

- (void)setTipViewName:(NSString *)TipViewName{
    _TipViewName = TipViewName;
    self.tipImageView.image = [UIImage imageNamed:TipViewName];
}

- (void)setIsShowButton:(BOOL)isShowButton{
    _isShowButton = isShowButton;
    self.inputButton.hidden = !isShowButton;
}

- (void)setInputText:(NSString *)inputText{
    _inputText = inputText;
    if (![NSString isNilOrEmpty:inputText]) {
        self.inputTextField.text = inputText;
    }
}

- (void)setIsEditing:(BOOL)isEditing{
    _isEditing = isEditing;
    if (!isEditing) {
        self.inputTextField.enabled = NO;
        self.inputButton.enabled = NO;
    }

}

#pragma mark - --------------UI----------------------
// 创建子控件
- (void)PrepareUI{
    UILabel *xingLabel = [[UILabel alloc] init];
    self.xingLabel = xingLabel;
    xingLabel.text = @"*";
    xingLabel.textColor = [UIColor colorWithHex:@"919191"];
    xingLabel.font = [UIFont systemFontOfSize:15];
    xingLabel.textAlignment = NSTextAlignmentCenter;
    [self addSubview:xingLabel];
    [xingLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(self.mas_centerY);
        make.left.mas_equalTo(0);
        make.width.height.mas_equalTo(7.5);
    }];

    UIImageView *titleImageView = [[UIImageView alloc] init];
    self.titleImageView = titleImageView;
    titleImageView.contentMode = UIViewContentModeScaleAspectFit;
    [self addSubview:titleImageView];

    [titleImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(self.mas_centerY);
        make.left.mas_equalTo(xingLabel.mas_right);
        make.width.mas_equalTo(17);
    }];

    UITextField *inputTextField = [[UITextField alloc] init];
    self.inputTextField = inputTextField;
    [inputTextField addTarget:self action:@selector(changeTextField) forControlEvents:UIControlEventEditingChanged];
    [inputTextField setValue:[UIFont systemFontOfSize:15] forKeyPath:@"_placeholderLabel.font"];
    inputTextField.font = [UIFont systemFontOfSize:15];
    [self addSubview:inputTextField];

    [inputTextField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.bottom.mas_equalTo(0);
        make.left.mas_equalTo(titleImageView.mas_right);
        make.right.mas_equalTo(-30);
    }];

    UIButton *inputButton = [[UIButton alloc] init];
    self.inputButton = inputButton;
    [inputButton addTarget:self action:@selector(inputButtonClick) forControlEvents:UIControlEventTouchUpInside];
    inputButton.hidden = YES;
    [self addSubview:inputButton];

    [inputButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.bottom.mas_equalTo(0);
        make.left.mas_equalTo(titleImageView.mas_right);
        make.right.mas_equalTo(0);
    }];

    UIImageView *tipImageView = [[UIImageView alloc] init];
    self.tipImageView = tipImageView;
    tipImageView.contentMode = UIViewContentModeScaleAspectFit;
    [self addSubview:tipImageView];
    [tipImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(0);
        make.centerY.mas_equalTo(self.mas_centerY);
        make.width.height.mas_equalTo(15);
    }];
}

#pragma mark - --------------other----------------------

@end
