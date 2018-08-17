//
//  YYOrderNormalListCell.m
//  Yunejian
//
//  Created by Apple on 15/8/17.
//  Copyright (c) 2015年 yyj. All rights reserved.
//

#import "YYOrderNormalListCell.h"

// c文件 —> 系统文件（c文件在前）

// 控制器

// 自定义视图
#import "KAProgressLabel.h"
#import "SCGIFImageView.h"
#import "YYTypeButton.h"

// 接口

// 分类
#import "UIImage+YYImage.h"
#import "UIView+UpdateAutoLayoutConstraints.h"

// 自定义类和三方类（ cocoapods类 > model > 工具类 > 其他）
#import "YYOrderListItemModel.h"

@interface YYOrderNormalListCell ()

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *countLabel;
@property (weak, nonatomic) IBOutlet UILabel *priceTotalLabel;
@property (weak, nonatomic) IBOutlet UILabel *orderCodeLabel;
@property (weak, nonatomic) IBOutlet UIImageView *isAppendImg;

@property (weak, nonatomic) IBOutlet SCGIFImageView *orderAlbumImageView;
@property (weak, nonatomic) IBOutlet UILabel *orderStatusCloseTimeTipLabel;

@property (weak, nonatomic) IBOutlet KAProgressLabel *hasGiveMoneyLabel;
@property (weak, nonatomic) IBOutlet UILabel *hasGiveMoneyTipLabel;
@property (weak, nonatomic) IBOutlet UILabel *orderSendTipLabel;

@property (weak, nonatomic) IBOutlet UILabel *timerTipLabel;

@property (weak, nonatomic) IBOutlet YYTypeButton *leftOrderBtn;
@property (weak, nonatomic) IBOutlet YYTypeButton *middleOrderBtn;
@property (weak, nonatomic) IBOutlet YYTypeButton *rightOrderBtn;

@property (weak, nonatomic) IBOutlet UILabel *tranStatusLabel;

@end


@implementation YYOrderNormalListCell

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
    _isAppendImg.image = [UIImage imageNamed:[LanguageManager isEnglishLanguage]?@"isappend_img_en":@"isappend_img"];

    _orderCodeLabel.adjustsFontSizeToFitWidth = YES;
    _priceTotalLabel.adjustsFontSizeToFitWidth = YES;

    self.contentView.autoresizingMask = UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth;

    _leftOrderBtn.layer.borderWidth = 1;
    _leftOrderBtn.layer.borderColor = [UIColor colorWithHex:@"afafaf"].CGColor;
    _leftOrderBtn.layer.cornerRadius = 2.5;
    _leftOrderBtn.layer.masksToBounds = YES;

    _middleOrderBtn.layer.borderWidth = 1;
    _middleOrderBtn.layer.borderColor = [UIColor colorWithHex:@"afafaf"].CGColor;
    _middleOrderBtn.layer.cornerRadius = 2.5;
    _middleOrderBtn.layer.masksToBounds = YES;

    _rightOrderBtn.layer.borderWidth = 1;
    _rightOrderBtn.layer.borderColor = [UIColor colorWithHex:@"afafaf"].CGColor;
    _rightOrderBtn.layer.cornerRadius = 2.5;
    _rightOrderBtn.layer.masksToBounds = YES;

    _orderAlbumImageView.layer.borderWidth = 1;
    _orderAlbumImageView.layer.borderColor = [UIColor colorWithHex:@"d3d3d3"].CGColor;
    _orderAlbumImageView.layer.cornerRadius = 2.5;
    _orderAlbumImageView.layer.masksToBounds = YES;

    [_hasGiveMoneyLabel setTrackWidth: 2.0];
    [_hasGiveMoneyLabel setProgressWidth: 2];
    [_hasGiveMoneyLabel setRoundedCornersWidth:2];
    _hasGiveMoneyLabel.fillColor = [[UIColor whiteColor] colorWithAlphaComponent:.3];
    _hasGiveMoneyLabel.trackColor = [UIColor colorWithHex:@"efefef"];
    _hasGiveMoneyLabel.progressColor = [UIColor colorWithHex:@"ed6498"];
    _hasGiveMoneyLabel.isStartDegreeUserInteractive = NO;
    _hasGiveMoneyLabel.isEndDegreeUserInteractive = NO;
    _hasGiveMoneyLabel.textColor = [UIColor colorWithHex:@"ed6498"];
}

#pragma mark - --------------UpdateUI----------------------
- (void)updateUI{
    if([_currentOrderListItemModel.isAppend integerValue]){
        _isAppendImg.hidden = NO;
    }else{
        _isAppendImg.hidden = YES;
    }

    if (_currentOrderListItemModel) {
        _priceTotalLabel.text = [NSString stringWithFormat:@"%@：%@",NSLocalizedString(@"建单",nil),getShowDateByFormatAndTimeInterval(@"yy/MM/dd HH:mm",[_currentOrderListItemModel.orderCreateTime stringValue])];
        _orderCodeLabel.text = [NSString stringWithFormat:@"%@：%@",NSLocalizedString(@"单号",nil),_currentOrderListItemModel.orderCode];
        if (_currentOrderListItemModel.styleAmount
            && _currentOrderListItemModel.itemAmount) {
            _countLabel.text = [NSString stringWithFormat:NSLocalizedString(@"总计：%i款 %i件",nil),[_currentOrderListItemModel.styleAmount intValue],[_currentOrderListItemModel.itemAmount intValue]];
        }

        if (_currentOrderListItemModel.finalTotalPrice) {
            NSString *totalstr = NSLocalizedString(@"总价",nil);
            NSInteger txtlength = _countLabel.text.length+2+totalstr.length;
            NSString *totalMoneyStr = replaceMoneyFlag([NSString stringWithFormat:@"%@ %@：￥%.2f",_countLabel.text,NSLocalizedString(@"总价",nil),[_currentOrderListItemModel.finalTotalPrice floatValue]],[_currentOrderListItemModel.curType integerValue]);
            NSMutableAttributedString *attributedStr = [[NSMutableAttributedString alloc] initWithString: totalMoneyStr];
            [attributedStr addAttribute: NSFontAttributeName value: [UIFont systemFontOfSize:15] range: NSMakeRange(txtlength, totalMoneyStr.length-txtlength)];
            [attributedStr addAttribute: NSForegroundColorAttributeName value: [UIColor colorWithHex:@"ed6498"] range: NSMakeRange(txtlength, totalMoneyStr.length-txtlength)];

            _countLabel.attributedText = attributedStr;
        }

        if(_currentOrderListItemModel && _currentOrderListItemModel.brandLogo != nil){
            sd_downloadWebImageWithRelativePath(NO, _currentOrderListItemModel.brandLogo,_orderAlbumImageView, kLogoCover, 0);
        }else{
            sd_downloadWebImageWithRelativePath(NO, @"",_orderAlbumImageView, kLogoCover, 0);
        }
        _orderStatusCloseTimeTipLabel.hidden = YES;
        _orderStatusCloseTimeTipLabel.superview.hidden = YES;

        if( [_currentOrderListItemModel.closeReqStatus integerValue] != -1){
            if (_currentOrderListItemModel.supplyTime
                && [_currentOrderListItemModel.supplyTime count] > 0) {
                YYOrderSupplyTimeModel *orderSupplyTimeModel = nil;
                for (YYOrderSupplyTimeModel *tmpOrderSupplyTimeModel in _currentOrderListItemModel.supplyTime) {
                    if(orderSupplyTimeModel == nil || [orderSupplyTimeModel.supplyStatus integerValue] == 0){
                        orderSupplyTimeModel = tmpOrderSupplyTimeModel;
                    }else{
                        if([tmpOrderSupplyTimeModel.supplyStatus integerValue] != 0 && ([tmpOrderSupplyTimeModel.dayRemains integerValue] > [orderSupplyTimeModel.dayRemains integerValue])){
                            orderSupplyTimeModel = tmpOrderSupplyTimeModel;
                        }
                    }
                }
                if(orderSupplyTimeModel != nil){
                    [self addAlineView:orderSupplyTimeModel andLineIndex:0];
                }
            }
        }else{
            if([_currentOrderListItemModel.closeReqStatus integerValue] == -1){
                _orderStatusCloseTimeTipLabel.hidden = NO;
                _orderStatusCloseTimeTipLabel.superview.hidden = NO;
            }
        }

        NSInteger tranStatus = getOrderTransStatus(_currentOrderListItemModel.designerTransStatus,_currentOrderListItemModel.buyerTransStatus);
        //状态
        _tranStatusLabel.text = getOrderStatusName_short(tranStatus);
        _tranStatusLabel.textColor = [UIColor colorWithHex:@"ed6498"];

        BOOL hasTotalPaid = NO;
        if([_currentOrderListItemModel.payNote integerValue] >= 100){
            hasTotalPaid = YES;
        }

        _leftOrderBtn.layer.borderColor = [UIColor colorWithHex:@"afafaf"].CGColor;
        _leftOrderBtn.type = nil;
        [_leftOrderBtn hideByWidth:YES];

        _middleOrderBtn.layer.borderColor = [UIColor colorWithHex:@"afafaf"].CGColor;
        _middleOrderBtn.type = nil;
        [_middleOrderBtn hideByWidth:YES];

        _rightOrderBtn.layer.borderColor = [UIColor colorWithHex:@"afafaf"].CGColor;
        _rightOrderBtn.type = nil;
        [_rightOrderBtn hideByWidth:YES];

        if(tranStatus == kOrderCode_CLOSE_REQ || [_currentOrderListItemModel.closeReqStatus integerValue] == -1){
            //关闭请求
            _tranStatusLabel.textColor = [UIColor colorWithHex:@"ef4e31"];

            [_leftOrderBtn hideByWidth:YES];

            if([_currentOrderListItemModel.closeReqStatus integerValue] == -1){
                _tranStatusLabel.text = getOrderStatusName_short(kOrderCode_CLOSE_REQ);

                [_middleOrderBtn hideByWidth:NO];
                _middleOrderBtn.backgroundColor = _define_black_color;
                _middleOrderBtn.layer.borderColor = _define_black_color.CGColor;
                [_middleOrderBtn setTitleColor:_define_white_color forState:UIControlStateNormal];
                [_middleOrderBtn setTitle:NSLocalizedString(@"我方交易继续",nil) forState:UIControlStateNormal];
                _middleOrderBtn.type = @"refuseReqClose";

                [_rightOrderBtn hideByWidth:NO];
                _rightOrderBtn.backgroundColor =_define_white_color;
                [_rightOrderBtn setTitleColor:_define_black_color forState:UIControlStateNormal];
                [_rightOrderBtn setTitle:NSLocalizedString(@"同意取消交易",nil) forState:UIControlStateNormal];
                _rightOrderBtn.type = @"agreeReqClose";

                _timerTipLabel.hidden = YES;
            }else if([_currentOrderListItemModel.closeReqStatus integerValue] == 1){
                _tranStatusLabel.text = NSLocalizedString(@"已取消订单，待对方处理",nil);

                [_middleOrderBtn hideByWidth:YES];

                [_rightOrderBtn hideByWidth:NO];
                _rightOrderBtn.backgroundColor =_define_white_color;
                [_rightOrderBtn setTitleColor:_define_black_color forState:UIControlStateNormal];
                [_rightOrderBtn setTitle:NSLocalizedString(@"撤销申请",nil) forState:UIControlStateNormal];
                _rightOrderBtn.type = @"cancelReqClose";

                _timerTipLabel.hidden = NO;
                if([_currentOrderListItemModel.autoCloseHoursRemains integerValue]>0){
                    NSInteger day = [_currentOrderListItemModel.autoCloseHoursRemains integerValue]/24;
                    NSInteger hours = [_currentOrderListItemModel.autoCloseHoursRemains integerValue]%24;
                    _timerTipLabel.text = [NSString stringWithFormat:NSLocalizedString(@"剩余%ld天%ld小时,\n若对方未处理，交易自动取消",nil),(long)day,(long)hours];
                }else{
                    _timerTipLabel.text = @"";
                }
            }else{
                [_middleOrderBtn hideByWidth:YES];
                [_rightOrderBtn hideByWidth:YES];
                _timerTipLabel.hidden = YES;
            }
            _orderStatusCloseTimeTipLabel.text = @"";

            if([_currentOrderListItemModel.closeReqStatus integerValue] == -1 &&[_currentOrderListItemModel.autoCloseHoursRemains integerValue]>0){
                NSInteger day = [_currentOrderListItemModel.autoCloseHoursRemains integerValue]/24;
                NSInteger hours = [_currentOrderListItemModel.autoCloseHoursRemains integerValue]%24;
                NSMutableParagraphStyle *paraStyle = [[NSMutableParagraphStyle alloc] init];
                paraStyle.lineSpacing = [LanguageManager isEnglishLanguage]?3:9;
                NSDictionary *attrDict = @{NSParagraphStyleAttributeName: paraStyle,
                                           NSFontAttributeName: [UIFont systemFontOfSize: 12] };
                NSString *timerStr =  [NSString stringWithFormat:NSLocalizedString(@"%ld天%ld小时",nil),(long)day,(long)hours];
                NSString *closeTimeTipStr = [NSString stringWithFormat:NSLocalizedString(@"请在%@内处理，否则交易将自动取消",nil),timerStr];
                NSMutableAttributedString *mutableAttributedStr = [[NSMutableAttributedString alloc] initWithString:closeTimeTipStr attributes:attrDict];
                NSRange rang = [closeTimeTipStr rangeOfString:timerStr];
                if(rang.location != NSNotFound){
                    [mutableAttributedStr addAttributes:@{NSForegroundColorAttributeName:[UIColor colorWithHex:@"ef4e31"]} range:rang];
                }
                _orderStatusCloseTimeTipLabel.attributedText = mutableAttributedStr;
                float closeTimeTipLabelHeight = getTxtHeight(SCREEN_WIDTH/2 -1 -10-17,closeTimeTipStr,attrDict);
                [_orderStatusCloseTimeTipLabel setConstraintConstant:closeTimeTipLabelHeight forAttribute:NSLayoutAttributeHeight];
            }
        }else if(tranStatus == kOrderCode_NEGOTIATION){
            //已下单

            _timerTipLabel.hidden = YES;

            BOOL isDesignerConfrim = [_currentOrderListItemModel isDesignerConfrim];
            BOOL isBuyerConfrim = [_currentOrderListItemModel isBuyerConfrim];

            if(!isBuyerConfrim){
                if(!isDesignerConfrim){
                    //双方都未确认
                    [_leftOrderBtn hideByWidth:NO];
                    _leftOrderBtn.backgroundColor = _define_black_color;
                    _leftOrderBtn.layer.borderColor = _define_black_color.CGColor;
                    [_leftOrderBtn setTitleColor:_define_white_color forState:UIControlStateNormal];
                    [_leftOrderBtn setTitle:NSLocalizedString(@"确认订单", nil) forState:UIControlStateNormal];
                    _leftOrderBtn.type = @"confirmOrder";

                    [_middleOrderBtn hideByWidth:NO];
                    _middleOrderBtn.backgroundColor =_define_white_color;
                    [_middleOrderBtn setTitleColor:_define_black_color forState:UIControlStateNormal];
                    [_middleOrderBtn setTitle:NSLocalizedString(@"取消订单_short",nil) forState:UIControlStateNormal];
                    _middleOrderBtn.type = @"cancelOrder";

                    [_rightOrderBtn hideByWidth:NO];
                    _rightOrderBtn.backgroundColor =_define_white_color;
                    [_rightOrderBtn setTitleColor:_define_black_color forState:UIControlStateNormal];
                    [_rightOrderBtn setTitle:NSLocalizedString(@"修改订单_short",nil) forState:UIControlStateNormal];
                    _rightOrderBtn.type = @"modifyOrder";
                }else{
                    //买手未确认
                    [_leftOrderBtn hideByWidth:NO];
                    _leftOrderBtn.backgroundColor = _define_white_color;
                    _leftOrderBtn.layer.borderColor = _define_white_color.CGColor;
                    [_leftOrderBtn setTitleColor:_define_black_color forState:UIControlStateNormal];
                    [_leftOrderBtn setTitle:NSLocalizedString(@"设计师已确认", nil) forState:UIControlStateNormal];

                    [_middleOrderBtn hideByWidth:NO];
                    _middleOrderBtn.backgroundColor =_define_white_color;
                    [_middleOrderBtn setTitleColor:_define_black_color forState:UIControlStateNormal];
                    [_middleOrderBtn setTitle:NSLocalizedString(@"拒绝确认",nil) forState:UIControlStateNormal];
                    _middleOrderBtn.type = @"refuseOrder";

                    [_rightOrderBtn hideByWidth:NO];
                    _rightOrderBtn.backgroundColor =_define_white_color;
                    [_rightOrderBtn setTitleColor:_define_black_color forState:UIControlStateNormal];
                    [_rightOrderBtn setTitle:NSLocalizedString(@"确认订单",nil) forState:UIControlStateNormal];
                    _rightOrderBtn.type = @"confirmOrder";
                }
            }else{
                if(!isDesignerConfrim){
                    //设计师未确认
                    [_leftOrderBtn hideByWidth:YES];

                    [_middleOrderBtn hideByWidth:YES];

                    [_rightOrderBtn hideByWidth:NO];
                    _rightOrderBtn.backgroundColor = [UIColor colorWithHex:@"d3d3d3"];
                    _rightOrderBtn.layer.borderColor = [UIColor colorWithHex:@"d3d3d3"].CGColor;
                    [_rightOrderBtn setTitleColor:_define_white_color forState:UIControlStateNormal];
                    [_rightOrderBtn setTitle:NSLocalizedString(@"待设计师确认",nil) forState:UIControlStateNormal];
                }else{
                    //理论上不存在这种情况
                    [_leftOrderBtn hideByWidth:YES];
                    [_middleOrderBtn hideByWidth:YES];
                    [_rightOrderBtn hideByWidth:YES];
                }
            }

        }else if(tranStatus == kOrderCode_NEGOTIATION_DONE || tranStatus == kOrderCode_CONTRACT_DONE){
            //已确认
            _timerTipLabel.hidden = YES;

            [_leftOrderBtn hideByWidth:YES];

            if(hasTotalPaid){
                //已付全款
                [_middleOrderBtn hideByWidth:YES];

                [_rightOrderBtn hideByWidth:NO];
                _rightOrderBtn.backgroundColor = _define_white_color;
                [_rightOrderBtn setTitleColor:_define_black_color forState:UIControlStateNormal];
                [_rightOrderBtn setTitle:NSLocalizedString(@"取消订单",nil) forState:UIControlStateNormal];
                _rightOrderBtn.type = @"closeOrder";
            }else{
                //未付全款
                [_middleOrderBtn hideByWidth:NO];
                _middleOrderBtn.backgroundColor = _define_white_color;
                [_middleOrderBtn setTitleColor:_define_black_color forState:UIControlStateNormal];
                [_middleOrderBtn setTitle:NSLocalizedString(@"取消订单",nil) forState:UIControlStateNormal];
                _middleOrderBtn.type = @"closeOrder";

                [_rightOrderBtn hideByWidth:NO];
                _rightOrderBtn.backgroundColor = _define_black_color;
                _rightOrderBtn.layer.borderColor = _define_black_color.CGColor;
                [_rightOrderBtn setTitleColor:_define_white_color forState:UIControlStateNormal];
                [_rightOrderBtn setTitle:NSLocalizedString(@"付款",nil) forState:UIControlStateNormal];
                _rightOrderBtn.type = @"paylog";
            }

        }else if(tranStatus == kOrderCode_MANUFACTURE){
            //已生产
            _timerTipLabel.hidden = YES;

            [_leftOrderBtn hideByWidth:YES];

            if(hasTotalPaid){
                //已付全款
                [_middleOrderBtn hideByWidth:YES];

                [_rightOrderBtn hideByWidth:NO];
                _rightOrderBtn.backgroundColor = _define_white_color;
                [_rightOrderBtn setTitleColor:_define_black_color forState:UIControlStateNormal];
                [_rightOrderBtn setTitle:NSLocalizedString(@"取消订单",nil) forState:UIControlStateNormal];
                _rightOrderBtn.type = @"closeOrder";
            }else{
                //未付全款
                [_middleOrderBtn hideByWidth:NO];
                _middleOrderBtn.backgroundColor = _define_white_color;
                [_middleOrderBtn setTitleColor:_define_black_color forState:UIControlStateNormal];
                [_middleOrderBtn setTitle:NSLocalizedString(@"取消订单",nil) forState:UIControlStateNormal];
                _middleOrderBtn.type = @"closeOrder";

                [_rightOrderBtn hideByWidth:NO];
                _rightOrderBtn.backgroundColor = _define_black_color;
                _rightOrderBtn.layer.borderColor = _define_black_color.CGColor;
                [_rightOrderBtn setTitleColor:_define_white_color forState:UIControlStateNormal];
                [_rightOrderBtn setTitle:NSLocalizedString(@"付款",nil) forState:UIControlStateNormal];
                _rightOrderBtn.type = @"paylog";
            }

        }else if(tranStatus == kOrderCode_DELIVERY){
            //已发货
            _timerTipLabel.hidden = YES;

            if(hasTotalPaid){
                //已付全款
                [_leftOrderBtn hideByWidth:YES];

                [_middleOrderBtn hideByWidth:NO];
                _middleOrderBtn.backgroundColor = _define_white_color;
                [_middleOrderBtn setTitleColor:_define_black_color forState:UIControlStateNormal];
                [_middleOrderBtn setTitle:NSLocalizedString(@"取消订单",nil) forState:UIControlStateNormal];
                _middleOrderBtn.type = @"closeOrder";

                [_rightOrderBtn hideByWidth:NO];
                _rightOrderBtn.backgroundColor = _define_black_color;
                _rightOrderBtn.layer.borderColor = _define_black_color.CGColor;
                [_rightOrderBtn setTitleColor:_define_white_color forState:UIControlStateNormal];
                [_rightOrderBtn setTitle:NSLocalizedString(@"确认收货",nil) forState:UIControlStateNormal];
                _rightOrderBtn.type = @"status";
            }else{
                //未付全款
                [_leftOrderBtn hideByWidth:NO];
                _leftOrderBtn.backgroundColor = _define_white_color;
                [_leftOrderBtn setTitleColor:_define_black_color forState:UIControlStateNormal];
                [_leftOrderBtn setTitle:NSLocalizedString(@"取消订单",nil) forState:UIControlStateNormal];
                _leftOrderBtn.type = @"closeOrder";

                [_middleOrderBtn hideByWidth:NO];
                _middleOrderBtn.backgroundColor = _define_black_color;
                _middleOrderBtn.layer.borderColor = _define_black_color.CGColor;
                [_middleOrderBtn setTitleColor:_define_white_color forState:UIControlStateNormal];
                [_middleOrderBtn setTitle:NSLocalizedString(@"确认收货",nil) forState:UIControlStateNormal];
                _middleOrderBtn.type = @"status";

                [_rightOrderBtn hideByWidth:NO];
                _rightOrderBtn.backgroundColor = _define_black_color;
                _rightOrderBtn.layer.borderColor = _define_black_color.CGColor;
                [_rightOrderBtn setTitleColor:_define_white_color forState:UIControlStateNormal];
                [_rightOrderBtn setTitle:NSLocalizedString(@"付款",nil) forState:UIControlStateNormal];
                _rightOrderBtn.type = @"paylog";
            }
        }else if(tranStatus == kOrderCode_RECEIVED){
            //已收货
            _timerTipLabel.hidden = YES;

            [_leftOrderBtn hideByWidth:YES];

            [_middleOrderBtn hideByWidth:YES];

            if(hasTotalPaid){
                //已付全款
                [_rightOrderBtn hideByWidth:YES];
            }else{
                //未付全款
                [_rightOrderBtn hideByWidth:NO];
                _rightOrderBtn.backgroundColor = _define_black_color;
                _rightOrderBtn.layer.borderColor = _define_black_color.CGColor;
                [_rightOrderBtn setTitleColor:_define_white_color forState:UIControlStateNormal];
                [_rightOrderBtn setTitle:NSLocalizedString(@"付款",nil) forState:UIControlStateNormal];
                _rightOrderBtn.type = @"paylog";
            }

        }else if(tranStatus == kOrderCode_CANCELLED || tranStatus == kOrderCode_CLOSED){
            //已取消
            _tranStatusLabel.textColor = [UIColor colorWithHex:@"ef4e31"];

            _timerTipLabel.hidden = YES;

            [_leftOrderBtn hideByWidth:YES];

            [_middleOrderBtn hideByWidth:NO];
            _middleOrderBtn.backgroundColor = _define_black_color;
            _middleOrderBtn.layer.borderColor = _define_black_color.CGColor;
            [_middleOrderBtn setTitleColor:_define_white_color forState:UIControlStateNormal];
            [_middleOrderBtn setTitle:NSLocalizedString(@"重新建立订单",nil) forState:UIControlStateNormal];
            _middleOrderBtn.type = @"reBuildOrder";

            [_rightOrderBtn hideByWidth:NO];
            _rightOrderBtn.backgroundColor =_define_white_color;
            [_rightOrderBtn setTitleColor:_define_black_color forState:UIControlStateNormal];
            [_rightOrderBtn setTitle:NSLocalizedString(@"删除",nil) forState:UIControlStateNormal];
            _rightOrderBtn.type = @"delete";

        }else{
            [_leftOrderBtn hideByWidth:YES];
            [_middleOrderBtn hideByWidth:YES];
            [_rightOrderBtn hideByWidth:YES];
            _timerTipLabel.hidden = YES;
        }

        //收款
        [self updateorderPayUI];
        //关联状态
        [self updateOrderConnStatusUI];

        if(_leftOrderBtn.hidden == NO){
            CGSize txtSize = [_leftOrderBtn.currentTitle sizeWithAttributes:@{NSFontAttributeName:_leftOrderBtn.titleLabel.font}];
            NSInteger btnWidth = MAX(80, (txtSize.width+20));
            [_leftOrderBtn setConstraintConstant:btnWidth forAttribute:NSLayoutAttributeWidth];
        }
        if(_middleOrderBtn.hidden == NO){
            CGSize txtSize = [_middleOrderBtn.currentTitle sizeWithAttributes:@{NSFontAttributeName:_middleOrderBtn.titleLabel.font}];
            NSInteger btnWidth = MAX(80, (txtSize.width+20));
            [_middleOrderBtn setConstraintConstant:btnWidth forAttribute:NSLayoutAttributeWidth];
        }
        if(_rightOrderBtn.hidden == NO){
            CGSize txtSize = [_rightOrderBtn.currentTitle sizeWithAttributes:@{NSFontAttributeName:_middleOrderBtn.titleLabel.font}];
            NSInteger btnWidth = MAX(80, (txtSize.width+20));
            [_rightOrderBtn setConstraintConstant:btnWidth forAttribute:NSLayoutAttributeWidth];
        }
    }
}

-(void)updateorderPayUI{

    NSString *totalPayMoneyStr = [NSString stringWithFormat:@"%@ %ld%@",NSLocalizedString(@"已付款",nil),[_currentOrderListItemModel.payNote integerValue],@"%"];
    NSInteger txtlength = [NSString stringWithFormat:@"%ld%@",[_currentOrderListItemModel.payNote integerValue],@"%"].length;
    NSMutableAttributedString *attributedStr = [[NSMutableAttributedString alloc] initWithString:totalPayMoneyStr];
    [attributedStr addAttribute: NSForegroundColorAttributeName value: [UIColor colorWithHex:@"ed6498"] range: NSMakeRange(totalPayMoneyStr.length-txtlength,txtlength)];
    [attributedStr addAttribute: NSFontAttributeName value: [UIFont boldSystemFontOfSize:12] range: NSMakeRange(totalPayMoneyStr.length-txtlength,txtlength)];

    _hasGiveMoneyTipLabel.attributedText = attributedStr;
    [_hasGiveMoneyLabel setProgress:[_currentOrderListItemModel.payNote integerValue]/100];

}

-(void)updateOrderConnStatusUI{
    _titleLabel.text = _currentOrderListItemModel.brandName;

}

#pragma mark - --------------自定义响应----------------------
- (IBAction)leftOrderHandler:(YYTypeButton *)sender {
    [self threeButtonClickWithType:sender.type];
}
- (IBAction)middleOrderHandler:(YYTypeButton *)sender {
    [self threeButtonClickWithType:sender.type];
}
- (IBAction)rightOrderHandler:(YYTypeButton *)sender {
    [self threeButtonClickWithType:sender.type];
}
-(void)threeButtonClickWithType:(NSString *)Type{
    if(![NSString isNilOrEmpty:Type]){
        if(self.delegate){
            [self.delegate btnClick:_indexPath.row section:_indexPath.section andParmas:@[Type]];
        }
    }
}

- (IBAction)showBrandInfoView:(id)sender {
    if(self.delegate){
        [self.delegate btnClick:_indexPath.row section:_indexPath.section andParmas:@[@"brandInfo"]];
    }
}

#pragma mark - --------------自定义方法----------------------

+(float)cellHeight:(YYOrderListItemModel *)orderListItemModel{
    return 221;
}

- (void)addAlineView:(YYOrderSupplyTimeModel *)orderSupplyTimeModel andLineIndex:(int)lineIndex{
    NSString *endDay = NSLocalizedString(@"无",nil);
    if ([orderSupplyTimeModel.supplyStatus intValue] == 0) {
        endDay = NSLocalizedString(@"有现货，可马上发货",nil);
        _orderSendTipLabel.text = endDay;
    }else{
        endDay = [NSString stringWithFormat:NSLocalizedString(@"距本次最晚发货日还有%@天",nil),[orderSupplyTimeModel.dayRemains stringValue]];
        NSMutableAttributedString *attributedStr = [[NSMutableAttributedString alloc] initWithString: endDay];
        NSRange rang = [endDay rangeOfString:[orderSupplyTimeModel.dayRemains stringValue]];
        if(rang.location != NSNotFound){
            [attributedStr addAttribute: NSFontAttributeName value: [UIFont boldSystemFontOfSize:12] range:rang];
            [attributedStr addAttribute: NSForegroundColorAttributeName value: [UIColor colorWithHex:@"ed6498"] range: rang];

        }
        _orderSendTipLabel.attributedText = attributedStr;

    }
    _orderSendTipLabel.adjustsFontSizeToFitWidth = YES;

}
#pragma mark - --------------other----------------------
@end
