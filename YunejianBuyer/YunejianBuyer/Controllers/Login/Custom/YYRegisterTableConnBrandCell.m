//
//  YYRegisterTableConnBrandCell.m
//  YunejianBuyer
//
//  Created by Victor on 2017/12/26.
//  Copyright © 2017年 Apple. All rights reserved.
//

#import "YYRegisterTableConnBrandCell.h"

@interface YYRegisterTableConnBrandCell()

@property (strong, nonatomic) UITextField *connBrandInputText1;
@property (strong, nonatomic) UITextField *connBrandInputText2;
@property (strong, nonatomic) UITextField *connBrandInputText3;
@property (strong, nonatomic) UITextField *connBrandInputText4;
@property (strong, nonatomic) UITextField *connBrandInputText5;
@property (strong, nonatomic) UITextField *connBrandInputText6;
@property (strong, nonatomic) UITextField *connBrandInputText7;

@property (strong, nonatomic) UIView *view1;
@property (strong, nonatomic) UIView *view2;
@property (strong, nonatomic) UIView *view3;
@property (strong, nonatomic) UIView *view4;
@property (strong, nonatomic) UIView *view5;
@property (strong, nonatomic) UIView *view6;
@property (strong, nonatomic) UIView *view7;

@end

@implementation YYRegisterTableConnBrandCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseIdentifier]) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        self.separatorInset = UIEdgeInsetsMake(0, CGRectGetWidth([UIScreen mainScreen].bounds), 0, 0);
        __weak typeof (self)weakSelf = self;
        
        self.view1 = [[UIView alloc] init];
        self.view1.backgroundColor = [UIColor groupTableViewBackgroundColor];
        [self.contentView addSubview:self.view1];
        [self.view1 mas_makeConstraints:^(MASConstraintMaker *make) {
            make.height.mas_equalTo(1);
            make.top.mas_equalTo(10);
            make.left.mas_equalTo(13);
            make.right.mas_equalTo(-13);
        }];
        
        self.view2 = [[UIView alloc] init];
        self.view2.backgroundColor = [UIColor groupTableViewBackgroundColor];
        [self.contentView addSubview:self.view2];
        [self.view2 mas_makeConstraints:^(MASConstraintMaker *make) {
            make.width.mas_equalTo(1);
            make.height.mas_equalTo(40);
            make.centerX.mas_equalTo(0);
            make.top.equalTo(weakSelf.view1.mas_bottom).with.offset(7);
        }];
        
        self.view3 = [[UIView alloc] init];
        self.view3.backgroundColor = [UIColor groupTableViewBackgroundColor];
        [self.contentView addSubview:self.view3];
        [self.view3 mas_makeConstraints:^(MASConstraintMaker *make) {
            make.height.mas_equalTo(1);
            make.top.equalTo(weakSelf.view2.mas_bottom).with.offset(7);
            make.left.mas_equalTo(13);
            make.right.mas_equalTo(-13);
        }];
        
        self.view4 = [[UIView alloc] init];
        self.view4.backgroundColor = [UIColor groupTableViewBackgroundColor];
        [self.contentView addSubview:self.view4];
        [self.view4 mas_makeConstraints:^(MASConstraintMaker *make) {
            make.width.mas_equalTo(1);
            make.height.mas_equalTo(40);
            make.centerX.mas_equalTo(0);
            make.top.equalTo(weakSelf.view3.mas_bottom).with.offset(7);
        }];
        
        self.view5 = [[UIView alloc] init];
        self.view5.backgroundColor = [UIColor groupTableViewBackgroundColor];
        [self.contentView addSubview:self.view5];
        [self.view5 mas_makeConstraints:^(MASConstraintMaker *make) {
            make.height.mas_equalTo(1);
            make.top.equalTo(weakSelf.view4.mas_bottom).with.offset(7);
            make.left.mas_equalTo(13);
            make.right.mas_equalTo(-13);
        }];
        
        self.view6 = [[UIView alloc] init];
        self.view6.backgroundColor = [UIColor groupTableViewBackgroundColor];
        [self.contentView addSubview:self.view6];
        [self.view6 mas_makeConstraints:^(MASConstraintMaker *make) {
            make.width.mas_equalTo(1);
            make.height.mas_equalTo(40);
            make.centerX.mas_equalTo(0);
            make.top.equalTo(weakSelf.view5.mas_bottom).with.offset(7);
        }];
        
        self.view7 = [[UIView alloc] init];
        self.view7.backgroundColor = [UIColor groupTableViewBackgroundColor];
        [self.contentView addSubview:self.view7];
        [self.view7 mas_makeConstraints:^(MASConstraintMaker *make) {
            make.height.mas_equalTo(1);
            make.top.equalTo(weakSelf.view6.mas_bottom).with.offset(7);
            make.left.mas_equalTo(13);
            make.right.mas_equalTo(-13);
        }];
        
        self.connBrandInputText1 = [[UITextField alloc] init];
        self.connBrandInputText1.textColor = _define_black_color;
        self.connBrandInputText1.placeholder = NSLocalizedString(@"品牌1", nil);
        self.connBrandInputText1.font = [UIFont systemFontOfSize:14];
        self.connBrandInputText1.borderStyle = UITextBorderStyleNone;
        [self.contentView addSubview:self.connBrandInputText1];
        [self.connBrandInputText1 mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(weakSelf.view1.mas_bottom).with.offset(0);
            make.left.mas_equalTo(15);
            make.bottom.equalTo(weakSelf.view3.mas_top);
            make.right.equalTo(weakSelf.view2.mas_left).with.offset(0);
        }];
        
        self.connBrandInputText2 = [[UITextField alloc] init];
        self.connBrandInputText2.textColor = _define_black_color;
        self.connBrandInputText2.placeholder = NSLocalizedString(@"品牌2", nil);
        self.connBrandInputText2.font = [UIFont systemFontOfSize:14];
        self.connBrandInputText2.borderStyle = UITextBorderStyleNone;
        [self.contentView addSubview:self.connBrandInputText2];
        [self.connBrandInputText2 mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(weakSelf.view1.mas_bottom).with.offset(0);
            make.left.equalTo(weakSelf.view2.mas_right).with.offset(0);
            make.bottom.equalTo(weakSelf.view3.mas_top);
            make.right.mas_equalTo(0);
        }];
        
        self.connBrandInputText3 = [[UITextField alloc] init];
        self.connBrandInputText3.textColor = _define_black_color;
        self.connBrandInputText3.placeholder = NSLocalizedString(@"品牌3", nil);
        self.connBrandInputText3.font = [UIFont systemFontOfSize:14];
        self.connBrandInputText3.borderStyle = UITextBorderStyleNone;
        [self.contentView addSubview:self.connBrandInputText3];
        [self.connBrandInputText3 mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(weakSelf.view3.mas_bottom).with.offset(0);
            make.left.mas_equalTo(15);
            make.bottom.equalTo(weakSelf.view5.mas_top);
            make.right.equalTo(weakSelf.view4.mas_left).with.offset(0);
        }];
        
        self.connBrandInputText4 = [[UITextField alloc] init];
        self.connBrandInputText4.textColor = _define_black_color;
        self.connBrandInputText4.placeholder = NSLocalizedString(@"品牌4", nil);
        self.connBrandInputText4.font = [UIFont systemFontOfSize:14];
        self.connBrandInputText4.borderStyle = UITextBorderStyleNone;
        [self.contentView addSubview:self.connBrandInputText4];
        [self.connBrandInputText4 mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(weakSelf.view3.mas_bottom).with.offset(0);
            make.left.equalTo(weakSelf.view4.mas_right).with.offset(0);
            make.bottom.equalTo(weakSelf.view5.mas_top);
            make.right.mas_equalTo(0);
        }];
        
        self.connBrandInputText5 = [[UITextField alloc] init];
        self.connBrandInputText5.textColor = _define_black_color;
        self.connBrandInputText5.placeholder = NSLocalizedString(@"品牌5", nil);
        self.connBrandInputText5.font = [UIFont systemFontOfSize:14];
        self.connBrandInputText5.borderStyle = UITextBorderStyleNone;
        [self.contentView addSubview:self.connBrandInputText5];
        [self.connBrandInputText5 mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(weakSelf.view5.mas_bottom).with.offset(0);
            make.left.mas_equalTo(15);
            make.bottom.equalTo(weakSelf.view7.mas_top);
            make.right.equalTo(weakSelf.view6.mas_left).with.offset(0);
        }];
        
        self.connBrandInputText6 = [[UITextField alloc] init];
        self.connBrandInputText6.textColor = _define_black_color;
        self.connBrandInputText6.placeholder = NSLocalizedString(@"品牌6", nil);
        self.connBrandInputText6.font = [UIFont systemFontOfSize:14];
        self.connBrandInputText6.borderStyle = UITextBorderStyleNone;
        [self.contentView addSubview:self.connBrandInputText6];
        [self.connBrandInputText6 mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(weakSelf.view5.mas_bottom).with.offset(0);
            make.left.equalTo(weakSelf.view6.mas_right).with.offset(0);
            make.bottom.equalTo(weakSelf.view7.mas_top);
            make.right.mas_equalTo(0);
        }];
        
        self.connBrandInputText7 = [[UITextField alloc] init];
        self.connBrandInputText7.textColor = _define_black_color;
        self.connBrandInputText7.placeholder = NSLocalizedString(@"其他合作品牌，用逗号隔开（非必填）", nil);
        self.connBrandInputText7.font = [UIFont systemFontOfSize:15];
        self.connBrandInputText7.borderStyle = UITextBorderStyleNone;
        [self.contentView addSubview:self.connBrandInputText7];
        [self.connBrandInputText7 mas_makeConstraints:^(MASConstraintMaker *make) {
            make.height.mas_equalTo(53);
            make.top.equalTo(weakSelf.view7.mas_bottom);
            make.left.mas_equalTo(15);
            make.right.mas_equalTo(-15);
        }];
    }
    return self;
}

-(void)updateCellInfo:(YYTableViewCellInfoModel *)info{
    _connBrandInputText7.font = [UIFont systemFontOfSize:[LanguageManager isEnglishLanguage]?11.0f:14.0f];
    if(_tap == nil){
        self.contentView.autoresizingMask = UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth;
        
        [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(textFiledEditChanged:) name:UITextFieldTextDidChangeNotification object:nil];
        _tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissKeyboard)];
        
    }
    YYTableViewCellInfoModel *infoModel = info;
    
    //infoModel1.value  = ([infoModel1.value isEqualToString:@""]?@",":infoModel1.value);
    NSArray *strarr = [infoModel.value componentsSeparatedByString:@","];
    for (int i = 0; i < 7; i++) {
        UITextField *connBrandInputText = [self valueForKey:[NSString stringWithFormat:@"connBrandInputText%d",(i+1)]];
        if(i < [strarr count]){
            if (i ==6) {
                NSArray *tmpArray = [strarr subarrayWithRange:NSMakeRange(i, [strarr count]-i)];
                connBrandInputText.text = [tmpArray componentsJoinedByString:@","];
            }else{
                connBrandInputText.text = [strarr objectAtIndex:i];
            }
        }else{
            connBrandInputText.text = nil;
        }
    }
}

-(void)dismissKeyboard{
    [self keyboardWillHide:nil];
}

-(void)keyboardWillHide:(NSNotification *)aNotification {
    
}

-(void)textFiledEditChanged:(NSNotification *)obj{
    //if([_connBrandInputText1 isFirstResponder]==YES || [_connBrandInputText2 isFirstResponder]==YES){
    NSMutableArray *tmpStrArray =[[NSMutableArray alloc] init];
    for (int i = 0; i < 7; i++) {
        UITextField *connBrandInputText = [self valueForKey:[NSString stringWithFormat:@"connBrandInputText%d",(i+1)]];
        if(connBrandInputText.text && connBrandInputText.text.length > 0){
            NSString *valueStr = [connBrandInputText.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
            if(valueStr.length > 0){
                [tmpStrArray addObject:valueStr];
            }
        }
    }
    [self.delegate selectClick:_indexPath.row AndSection:_indexPath.section andParmas:@[[tmpStrArray componentsJoinedByString:@","],@(0)]];
    //}
}

@end
