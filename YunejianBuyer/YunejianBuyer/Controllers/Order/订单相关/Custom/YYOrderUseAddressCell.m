//
//  YYOrderUseAddressCell.m
//  YunejianBuyer
//
//  Created by Apple on 16/3/21.
//  Copyright © 2016年 Apple. All rights reserved.
//

#import "YYOrderUseAddressCell.h"

// c文件 —> 系统文件（c文件在前）

// 控制器

// 自定义视图

// 接口

// 分类
#import "UIView+UpdateAutoLayoutConstraints.h"

// 自定义类和三方类（ cocoapods类 > model > 工具类 > 其他）
#import "YYOrderInfoModel.h"
#import "YYOrderBuyerAddress.h"

@interface YYOrderUseAddressCell()

@property (weak, nonatomic) IBOutlet UILabel *addressLabel;
@property (weak, nonatomic) IBOutlet UILabel *receiveLabel;
@property (weak, nonatomic) IBOutlet UILabel *phoneLabel;

@property (weak, nonatomic) IBOutlet UILabel *orderTypeLabel;
@property (weak, nonatomic) IBOutlet UIButton *orderTypeButton;

@end

@implementation YYOrderUseAddressCell
#pragma mark - --------------生命周期--------------
- (void)awakeFromNib {
    [super awakeFromNib];
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
- (void)PrepareUI{}

#pragma mark - --------------UIConfig----------------------
-(void)UIConfig{
}

#pragma mark - --------------UpdateUI----------------------
-(void)updateUI{
    if([NSString isNilOrEmpty:_currentYYOrderInfoModel.type]){
        _orderTypeLabel.text = @"";
    }else{
        if([_currentYYOrderInfoModel.type isEqualToString:@"BUYOUT"]){
            _orderTypeLabel.text = @"买断（Buy out）";
        }else if([_currentYYOrderInfoModel.type isEqualToString:@"CONSIGNMENT"]){
            _orderTypeLabel.text = @"寄售（Consignment sale）";
        }else{
            _orderTypeLabel.text = @"";
        }
    }
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    UIImageView *flagImgView = [self.contentView viewWithTag:10002];
    UILabel *addTipLabel = [self.contentView viewWithTag:10003];
    if (_buyerAddress) {
        NSString *showAddress = [self getAddressStr:_buyerAddress];
        NSMutableParagraphStyle *paraStyle = [[NSMutableParagraphStyle alloc] init];
        paraStyle.lineSpacing = 8;
        NSDictionary *attrDict = @{ NSParagraphStyleAttributeName: paraStyle,
                                    NSFontAttributeName: [UIFont systemFontOfSize: 12] };

        _addressLabel.attributedText = [[NSAttributedString alloc] initWithString: showAddress attributes: attrDict];
        float txtheight = getTxtHeight(SCREEN_WIDTH-57, showAddress, attrDict);
        txtheight = MIN(38, txtheight);
        [_addressLabel setConstraintConstant:txtheight forAttribute:NSLayoutAttributeHeight];
        _receiveLabel.text = _buyerAddress.receiverName;
        _phoneLabel.text = _buyerAddress.receiverPhone;
        addTipLabel.text = @"";;
        flagImgView.hidden = NO;
    }else{
        _addressLabel.text = @"";
        _receiveLabel.text = @"";
        _phoneLabel.text = @"";
        addTipLabel.text = NSLocalizedString(@"添加收件地址",nil);
        flagImgView.hidden = YES;
    }
}

#pragma mark - --------------系统代理----------------------

#pragma mark - --------------自定义响应----------------------
- (IBAction)changeAddressHandler:(id)sender {
    if(self.delegate){
        [self.delegate btnClick:_indexPath.row section:_indexPath.section andParmas:nil];
    }
}
- (IBAction)orderTypeButtonClicked:(id)sender {
    if(self.orderTypeButtonClicked){
        self.orderTypeButtonClicked();
    }
}

#pragma mark - --------------自定义方法----------------------
-(NSString *)getAddressStr:(YYOrderBuyerAddress *)address{
    if(address == nil){
        return @" ";
    }
    NSString *nationStr = [LanguageManager isEnglishLanguage]?address.nationEn:address.nation;
    NSString *provinceStr = [LanguageManager isEnglishLanguage]?address.provinceEn:address.province;
    NSString *cityStr = [LanguageManager isEnglishLanguage]?address.cityEn:address.city;
    if([address.defaultShipping integerValue] > 0){
        return [NSString stringWithFormat:NSLocalizedString(@"[默认]%@ %@%@%@ %@",nil),nationStr,provinceStr, [NSString isNilOrEmpty:cityStr]?@"":cityStr, [NSString isNilOrEmpty:address.street]?@"":address.street, address.detailAddress];
    }else{
        return [NSString stringWithFormat:NSLocalizedString(@"%@ %@%@%@ %@",nil),nationStr,provinceStr, [NSString isNilOrEmpty:cityStr]?@"":cityStr, [NSString isNilOrEmpty:address.street]?@"":address.street, address.detailAddress];
    }
}

#pragma mark - --------------other----------------------


@end
