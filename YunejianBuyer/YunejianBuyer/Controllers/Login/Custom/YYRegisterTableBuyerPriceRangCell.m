//
//  YYRegisterTableBuyerPriceRangCell.m
//  YunejianBuyer
//
//  Created by Victor on 2017/12/26.
//  Copyright © 2017年 Apple. All rights reserved.
//

#import "YYRegisterTableBuyerPriceRangCell.h"

@implementation YYRegisterTableBuyerPriceRangeInfoModel

-(NSArray *)getParamStr{
    if(![NSString isNilOrEmpty:self.minPriceValue] && ![NSString isNilOrEmpty:self.maxPriceValue])
    {
        return @[[NSString stringWithFormat:@"priceMin=%@",self.minPriceValue], [NSString stringWithFormat:@"priceMax=%@",self.maxPriceValue]];
    }
    return nil;
}

@end

@interface YYRegisterTableBuyerPriceRangCell()

@property (nonatomic, strong) UILabel *leftTitleLabel;
@property (nonatomic, strong) UILabel *rightTitleLabel;
@property (nonatomic, strong) UITextField *leftTextField;
@property (nonatomic, strong) UITextField *rightTextField;
@property (nonatomic, strong) UIView *leftLineView;
@property (nonatomic, strong) UIView *rightLineView;

@end

@implementation YYRegisterTableBuyerPriceRangCell

#pragma mark - --------------生命周期--------------
- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseIdentifier]) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        self.separatorInset = UIEdgeInsetsMake(0, CGRectGetWidth([UIScreen mainScreen].bounds), 0, 0);
        self.contentView.backgroundColor =_define_white_color;
        __weak typeof (self)weakSelf = self;
        
        self.leftTitleLabel = [[UILabel alloc] init];
        self.leftTitleLabel.text = NSLocalizedString(@"从", nil);
        self.leftTitleLabel.textColor = _define_black_color;
        self.leftTitleLabel.font = [UIFont systemFontOfSize:15];
        [self.contentView addSubview:self.leftTitleLabel];
        [self.leftTitleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.width.mas_equalTo(30);
            make.top.mas_equalTo(0);
            make.left.mas_equalTo(15);
            make.bottom.mas_equalTo(0);
        }];
        
        self.leftTextField = [[UITextField alloc] init];
        self.leftTextField.textColor = _define_black_color;
        self.leftTextField.font = [UIFont systemFontOfSize:15];
        self.leftTextField.placeholder = NSLocalizedString(@"款式最低零售价", nil);
        self.leftTextField.borderStyle = UITextBorderStyleNone;
        self.leftTextField.keyboardType = UIKeyboardTypeDecimalPad;
        [self.contentView addSubview:self.leftTextField];
        [self.leftTextField mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(0);
            make.left.equalTo(weakSelf.leftTitleLabel.mas_right).with.offset(0);
            make.bottom.mas_equalTo(0);
        }];
        
        self.leftLineView = [[UIView alloc] init];
        self.backgroundColor = [UIColor groupTableViewBackgroundColor];
        [self.contentView addSubview:self.leftLineView];
        [self.leftLineView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.height.mas_equalTo(1);
            make.left.equalTo(weakSelf.leftTextField.mas_left).with.offset(0);
            make.bottom.equalTo(weakSelf.leftTextField.mas_bottom).with.offset(-12);
            make.right.equalTo(weakSelf.leftTextField.mas_right).with.offset(-10);
        }];
        
        self.rightTitleLabel = [[UILabel alloc] init];
        self.rightTitleLabel.text = NSLocalizedString(@"到", nil);
        self.rightTitleLabel.textColor  = _define_black_color;
        self.rightTitleLabel.font = [UIFont systemFontOfSize:15];
        [self.contentView addSubview:self.rightTitleLabel];
        [self.rightTitleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.width.mas_equalTo(30);
            make.top.mas_equalTo(0);
            make.left.equalTo(weakSelf.leftTextField.mas_right).with.offset(0);
            make.bottom.mas_equalTo(0);
        }];
        
        self.rightTextField = [[UITextField alloc] init];
        self.rightTextField.textColor = _define_black_color;
        self.rightTextField.font = [UIFont systemFontOfSize:15];
        self.rightTextField.placeholder = NSLocalizedString(@"款式最高零售价", nil);
        self.rightTextField.borderStyle = UITextBorderStyleNone;
        self.rightTextField.keyboardType = UIKeyboardTypeDecimalPad;
        [self.contentView addSubview:self.rightTextField];
        [self.rightTextField mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(0);
            make.left.equalTo(weakSelf.rightTitleLabel.mas_right).with.offset(0);
            make.bottom.mas_equalTo(0);
            make.right.mas_equalTo(15);
            make.width.equalTo(weakSelf.leftTextField.mas_width);
        }];
        
        self.rightLineView = [[UIView alloc] init];
        self.backgroundColor = [UIColor groupTableViewBackgroundColor];
        [self.contentView addSubview:self.rightLineView];
        [self.rightLineView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.height.mas_equalTo(1);
            make.left.equalTo(weakSelf.rightTextField.mas_left).with.offset(0);
            make.bottom.equalTo(weakSelf.rightTextField.mas_bottom).with.offset(-12);
            make.right.equalTo(weakSelf.rightTextField.mas_right).with.offset(-10);
        }];
    }
    return self;
}

#pragma mark - --------------SomePrepare--------------

#pragma mark - --------------UIConfig----------------------
-(void)updateCellInfo:(YYRegisterTableBuyerPriceRangeInfoModel *)info{
    if(_tap == nil){
        self.contentView.autoresizingMask = UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth;
        
        [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(textFiledEditChanged:) name:UITextFieldTextDidChangeNotification object:nil];
        _tap = [[UITapGestureRecognizer alloc]   initWithTarget:self action:@selector(dismissKeyboard)];
        
    }
    
    if (![NSString isNilOrEmpty:info.minPriceTitle]) {
        self.leftTitleLabel.text = info.minPriceTitle;
    }
    if (![NSString isNilOrEmpty:info.maxPriceTItle]) {
        self.rightTitleLabel.text = info.maxPriceTItle;
    }
    if (![NSString isNilOrEmpty:info.minPriceValue]) {
        self.leftTextField.text = info.minPriceValue;
    }
    if (![NSString isNilOrEmpty:info.maxPriceValue]) {
        self.rightTextField.text = info.maxPriceValue;
    }
    self.leftTextField.placeholder = info.minPricePlaceholder;
    self.rightTextField.placeholder = info.maxPricePlaceholder;
}

-(void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UITextFieldTextDidChangeNotification object:nil];
}

#pragma mark - --------------请求数据----------------------

#pragma mark - --------------系统代理----------------------


#pragma mark - --------------自定义代理/block----------------------


#pragma mark - --------------自定义响应----------------------
-(void)dismissKeyboard{
    [self keyboardWillHide:nil];
}

-(void)keyboardWillHide:(NSNotification *)aNotification {
    
}

-(void)textFiledEditChanged:(NSNotification *)obj{
    if([self.leftTextField isFirstResponder]==YES){
        [self.delegate selectClick:_indexPath.row AndSection:_indexPath.section andParmas:@[self.leftTextField.text,@(0)]];
    }else  if([self.rightTextField isFirstResponder]==YES){
        [self.delegate selectClick:_indexPath.row AndSection:_indexPath.section andParmas:@[self.rightTextField.text,@(1)]];
    }
}

#pragma mark - --------------自定义方法----------------------


#pragma mark - --------------other----------------------

@end
