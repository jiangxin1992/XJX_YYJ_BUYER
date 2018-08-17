//
//  YYBuyerInfoCell.m
//  Yunejian
//
//  Created by lixuezhi on 15/8/17.
//  Copyright (c) 2015年 yyj. All rights reserved.
//

#import "YYBuyerInfoCell1.h"

// c文件 —> 系统文件（c文件在前）

// 控制器

// 自定义视图
#import "YYYellowPanelManage.h"
#import "SCGIFImageView.h"

// 接口

// 分类
#import "UIImage+YYImage.h"

// 自定义类和三方类（ cocoapods类 > model > 工具类 > 其他）
#import "YYOrderInfoModel.h"
#import "YYOrderBuyerAddress.h"

#import "UserDefaultsMacro.h"

@interface YYBuyerInfoCell1 ()
@property (weak, nonatomic) IBOutlet UILabel *typeLab;
@property (weak, nonatomic) IBOutlet UILabel *payMethodLab;
@property (weak, nonatomic) IBOutlet UILabel *giveMethodLab;
@property (weak, nonatomic) IBOutlet UILabel *addressLab1;

@property (weak, nonatomic) IBOutlet SCGIFImageView *logoImageView;
@property (weak, nonatomic) IBOutlet UILabel *logoNameLabel;

@property (weak, nonatomic) IBOutlet UIButton *connStatusBtn;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *typeLeftLenthLayout;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *payLeftLengthLayout;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *giveLeftLengthLayout;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *addressLeftLengthLayout;


@property (nonatomic, strong) UITapGestureRecognizer *tap;

@end

@implementation YYBuyerInfoCell1
#pragma mark - --------------生命周期--------------
- (void)awakeFromNib {
    [super awakeFromNib];
    [self SomePrepare];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}
#pragma mark - --------------SomePrepare--------------
- (void)SomePrepare
{
    [self PrepareData];
    [self PrepareUI];
}
- (void)PrepareData{}
- (void)PrepareUI{
    if([LanguageManager isEnglishLanguage]){
        _typeLeftLenthLayout.constant = 100;
        _payLeftLengthLayout.constant = 100;
        _giveLeftLengthLayout.constant = 100;
        _addressLeftLengthLayout.constant = 100;
    }else{
        _typeLeftLenthLayout.constant = 60;
        _payLeftLengthLayout.constant = 60;
        _giveLeftLengthLayout.constant = 60;
        _addressLeftLengthLayout.constant = 60;
    }

    _connStatusBtn.layer.borderColor = [UIColor colorWithHex:@"919191"].CGColor;
    _connStatusBtn.layer.borderWidth = 1;
    _connStatusBtn.layer.cornerRadius = 2.5;
    _connStatusBtn.layer.masksToBounds = YES;

    _logoImageView.layer.borderWidth = 1;
    _logoImageView.layer.borderColor = [UIColor colorWithHex:@"d3d3d3"].CGColor;
    _logoImageView.layer.cornerRadius = 1;
    _logoImageView.layer.masksToBounds = YES;
}

#pragma mark - --------------UpdataUI----------------------
- (void)updataUI{

    _connStatusBtn.hidden = YES;

    _logoImageView.hidden = NO;
    _logoNameLabel.hidden = NO;
    _logoNameLabel.text = _currentYYOrderInfoModel.brandName;

    sd_downloadWebImageWithRelativePath(NO, _currentYYOrderInfoModel.brandLogo, _logoImageView, kLogoCover, 0);

    if([NSString isNilOrEmpty:_currentYYOrderInfoModel.type]){
        _typeLab.text = NSLocalizedString(@"订单类型未设置",nil);
        _typeLab.textColor = [UIColor colorWithHex:@"919191"];
    }else{
        if([_currentYYOrderInfoModel.type isEqualToString:@"BUYOUT"]){
            _typeLab.text = NSLocalizedString(@"买断",nil);
            _typeLab.textColor = _define_black_color;
        }else if([_currentYYOrderInfoModel.type isEqualToString:@"CONSIGNMENT"]){
            _typeLab.text = NSLocalizedString(@"寄售",nil);
            _typeLab.textColor = _define_black_color;
        }else{
            _typeLab.text = NSLocalizedString(@"订单类型未设置",nil);
            _typeLab.textColor = [UIColor colorWithHex:@"919191"];
        }
    }

    if(_tap == nil){
        _tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(OnTapBrandInfo:)];
        [_logoImageView addGestureRecognizer:_tap];
        [_logoNameLabel addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(OnTapBrandInfo:)]];
    }

    if(_currentYYOrderInfoModel.payApp == nil || [_currentYYOrderInfoModel.payApp  isEqualToString:@""]){
        self.payMethodLab.text = NSLocalizedString(@"对方未规定结算方式",nil);
        self.payMethodLab.textColor = [UIColor colorWithHex:@"919191"];
    }else{
        self.payMethodLab.text = _currentYYOrderInfoModel.payApp;
        self.payMethodLab.textColor = [UIColor colorWithHex:@"000000"];

    }
    if(_currentYYOrderInfoModel.deliveryChoose == nil || [_currentYYOrderInfoModel.deliveryChoose  isEqualToString:@""]){
        self.giveMethodLab.text = NSLocalizedString(@"对方未规定发货方式",nil);
        self.giveMethodLab.textColor = [UIColor colorWithHex:@"919191"];
    }else{
        self.giveMethodLab.text = _currentYYOrderInfoModel.deliveryChoose;
        self.giveMethodLab.textColor = [UIColor colorWithHex:@"000000"];

    }

    //设置地址
    YYOrderBuyerAddress *buyerAddress = _currentYYOrderInfoModel.buyerAddress;
    if (buyerAddress) {
        NSMutableParagraphStyle *paraStyle = [[NSMutableParagraphStyle alloc] init];
        paraStyle.lineSpacing = 10;
        NSDictionary *attrDict = @{ NSParagraphStyleAttributeName: paraStyle,
                                    NSFontAttributeName: [UIFont systemFontOfSize: 13] };

        self.addressLab1.attributedText = [[NSAttributedString alloc] initWithString: getBuyerAddressStr_phone(buyerAddress) attributes: attrDict];
        self.addressLab1.textColor = [UIColor colorWithHex:@"000000"];

    }else{
        self.addressLab1.text = NSLocalizedString(@"收件地址未录入",nil);
        self.addressLab1.textColor = [UIColor colorWithHex:@"919191"];

    }
}

//#pragma mark - --------------请求数据----------------------
//-(void)RequestData{}

#pragma mark - --------------自定义响应----------------------
- (IBAction)reConnStatusHandler:(id)sender {
    if(self.currentYYOrderInfoModel.orderCode ==nil || self.currentYYOrderInfoModel.orderCode.length ==0){
        return;
    }
    [[YYYellowPanelManage instance] showBrandInfoView:nil orderCode:self.currentYYOrderInfoModel.orderCode designerId:[self.currentYYOrderInfoModel.designerId integerValue]];
    return;
}

#pragma mark - --------------自定义方法----------------------
-(void)OnTapBrandInfo:(UITapGestureRecognizer *)sender{
    if (self.delegate) {
        [self.delegate btnClick:0 section:0 andParmas:@[@"brandInfo"]];
    }
}


+(NSInteger) getCellHeight:(NSString *)desc{
    NSInteger txtWidth = SCREEN_WIDTH - (([LanguageManager isEnglishLanguage]?100:60))-17;

    NSInteger textHeight = 0;
    if([desc isEqualToString:@""]){
        textHeight = 30;
    }else{
        NSMutableParagraphStyle *paraStyle = [[NSMutableParagraphStyle alloc] init];
        paraStyle.lineSpacing = 10;
        NSDictionary *attrDict = @{ NSParagraphStyleAttributeName: paraStyle,
                                    NSFontAttributeName: [UIFont systemFontOfSize: 13] };

        textHeight = getTxtHeight(txtWidth, desc, attrDict);
    }
    return textHeight + 110 + 46 + 36;
}

#pragma mark - --------------other----------------------

@end
