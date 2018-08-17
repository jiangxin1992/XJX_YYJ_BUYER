//
//  YYInventoryStyleSizeInfoView.m
//  YunejianBuyer
//
//  Created by Apple on 16/9/2.
//  Copyright © 2016年 Apple. All rights reserved.
//

#import "YYInventoryStyleSizeInfoView.h"

#import "UIImage+YYImage.h"
#import "UITextField+YYRectForBounds.h"

@implementation YYInventoryStyleSizeInfoView{
    UIButton *_reduceBtn;
    UIButton *_addBtn;
    UIView *_bgView;
}


- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self initUI];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self initUI];
    }
    return self;
}

-(void)initUI{

    if(_sizeNameLabel == nil){
        _sizeNameLabel = [[UILabel alloc] init];
        _sizeNameLabel.font = [UIFont systemFontOfSize:13];
        //_sizeNameLabel.backgroundColor = [UIColor grayColor];
        [self addSubview:_sizeNameLabel];
        [_sizeNameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.mas_equalTo(@(-140));
            make.height.mas_equalTo(@(13));
            make.width.mas_equalTo(@(60));
            make.centerY.mas_equalTo(@(0));
            
        }];
    }
    
    if(_bgView == nil){
        _bgView = [[UIView alloc] init];
        _bgView.layer.cornerRadius = 2.5;
        _bgView.layer.borderWidth = 1;
        _bgView.layer.borderColor = [UIColor colorWithHex:@"d3d3d3"].CGColor;
        [self addSubview:_bgView];
        [_bgView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.height.mas_equalTo(@(30));
            make.right.mas_equalTo(@(-17));
            make.centerY.mas_equalTo(@(0));
            make.width.mas_equalTo(@(122));
        }];
    }
    __weak UIView *weakBgView = _bgView;
    
    if(_reduceBtn == nil){
        _reduceBtn = [[UIButton alloc] init];
        [_reduceBtn setImage:[UIImage imageNamed:@"reducenum_icon"] forState:UIControlStateNormal];
        [_reduceBtn addTarget:self action:@selector(reduceBtnHandler) forControlEvents:UIControlEventTouchUpInside];
        [weakBgView addSubview:_reduceBtn];
        [_reduceBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(@(0));
            make.width.mas_equalTo(@(38));
            make.height.mas_equalTo(@(44));
            make.centerY.mas_equalTo(@(0));
        }];
        //_reduceBtn.hidden = YES;
    }
    
    if(_addBtn == nil){
        _addBtn = [[UIButton alloc] init];
        [_addBtn setImage:[UIImage imageNamed:@"addnum_icon"] forState:UIControlStateNormal];
        [_addBtn addTarget:self action:@selector(addBtnHandler) forControlEvents:UIControlEventTouchUpInside];
        
        [weakBgView addSubview:_addBtn];
        [_addBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.mas_equalTo(@(0));
            make.width.mas_equalTo(@(38));
            make.height.mas_equalTo(@(44));
            make.centerY.mas_equalTo(@(0));
        }];
        //_addBtn.hidden = YES;
    }
    
    if(_numInput == nil){
        _numInput = [[UITextField alloc] init];
        _numInput.delegate = self;
        _numInput.keyboardType = UIKeyboardTypeNumberPad;
        _numInput.textAlignment = NSTextAlignmentCenter;
        _numInput.font = [UIFont systemFontOfSize:13];
        [weakBgView addSubview:_numInput];
        [_numInput mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(weakBgView.mas_top);
            make.left.mas_equalTo(@(38));
            make.bottom.mas_equalTo(weakBgView.mas_bottom);
            make.right.mas_equalTo(@(-38));
        }];
    }
    
    if(_totalNumLabel == nil){
        _totalNumLabel = [[UILabel alloc] init];
        _totalNumLabel.font = [UIFont systemFontOfSize:13];
        [self addSubview:_totalNumLabel];
        [_totalNumLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.mas_equalTo(@(0));
            make.height.mas_equalTo(@(13));
            make.width.mas_equalTo(@(90));
            make.centerY.mas_equalTo(@(0));
        }];
        _totalNumLabel.hidden = YES;
    }
    
}

- (void)reduceBtnHandler{
    NSInteger value = [_numInput.text integerValue];
    value -- ;
    value = MAX(0, value);
    _numInput.text = [NSString stringWithFormat:@"%ld",(long)value];
    [self textFieldDidChange:nil];
}

- (void)addBtnHandler{
    NSInteger value = [_numInput.text integerValue];
    value ++ ;
    _numInput.text = [NSString stringWithFormat:@"%ld",(long)value];
    [self textFieldDidChange:nil];
}

-(void)deleteSizeDate{
    if(self.delegate){
        [self.delegate btnClick:_indexPath.row section:_indexPath.section andParmas:@[@"0"]];
    }
}

#pragma mark - UITextFieldDelegate
- (BOOL)textField:(UITextField*)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString*)string
{
    
    NSCharacterSet* cs = [NSCharacterSet characterSetWithCharactersInString:@"0123456789"];
    NSString *filtered = [[string componentsSeparatedByCharactersInSet:cs] componentsJoinedByString:@""];
    BOOL basicTest = [filtered isEqualToString:@""];
    if(basicTest) {
        return YES;
    }
    return NO;
}

- (void)textFieldDidEndEditing:(UITextField *)textField{
    [[NSNotificationCenter defaultCenter]removeObserver:self name:UITextFieldTextDidChangeNotification object:_numInput];
    
}

-(void) textFieldDidBeginEditing:(UITextField *)textField{
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(textFieldDidChange:) name:UITextFieldTextDidChangeNotification object:_numInput];
    
}

- (void)textFieldDidChange:(NSNotification *)note
{
    if(self.delegate){
        [self.delegate btnClick:_indexPath.row section:_indexPath.section andParmas:@[_numInput.text]];
    }
}


-(void)updateUI{
    if(_isModifyNow){
        _bgView.hidden = NO;
        _totalNumLabel.hidden = YES;
    }else{
        _bgView.hidden = YES;
        _totalNumLabel.hidden = NO;
    }
    _sizeNameLabel.text = _orderSizeModel.name;
    if([_orderSizeModel.amount integerValue] == -1){
        _numInput.text = @"0";
        
        _totalNumLabel.text = [NSString stringWithFormat:NSLocalizedString(@"%@ 件",nil),@"0"];
    }else{
        _numInput.text = [_orderSizeModel.amount stringValue];
        _totalNumLabel.text = [NSString stringWithFormat:NSLocalizedString(@"%@ 件",nil),[_orderSizeModel.amount stringValue]];
    }
    
}



@end
