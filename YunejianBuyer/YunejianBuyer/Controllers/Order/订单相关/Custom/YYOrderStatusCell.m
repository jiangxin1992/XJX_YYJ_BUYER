//
//  YYOrderStatusCell.m
//  Yunejian
//
//  Created by Apple on 15/11/25.
//  Copyright © 2015年 yyj. All rights reserved.
//

#import "YYOrderStatusCell.h"

// c文件 —> 系统文件（c文件在前）

// 控制器

// 自定义视图

// 接口
#import "YYOrderApi.h"

// 分类
#import "UIView+UpdateAutoLayoutConstraints.h"

// 自定义类和三方类（ cocoapods类 > model > 工具类 > 其他）
#import "YYUser.h"
#import "YYOrderInfoModel.h"
#import "YYOrderTransStatusModel.h"

@interface YYOrderStatusCell()

@property (weak, nonatomic) IBOutlet UILabel *statusNameLabel;
@property (weak, nonatomic) IBOutlet UIButton *helpBtn;
@property (weak, nonatomic) IBOutlet UILabel *oprateTimerLabel;
@property (weak, nonatomic) IBOutlet UILabel *statusTipLabel;
@property (weak, nonatomic) IBOutlet UIButton *getBtn;
@property (weak, nonatomic) IBOutlet UIButton *operationBtn;
@property (weak, nonatomic) IBOutlet UIButton *dealCloseBtn;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *statusTipLayoutConstraint;

@property (nonatomic, strong) UILabel *statusNameTipLabel;

@end

@implementation YYOrderStatusCell

#pragma mark - --------------生命周期--------------
- (void)awakeFromNib {
    [super awakeFromNib];
    [self SomePrepare];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}
#pragma mark - SomePrepare
-(void)SomePrepare
{
    [self PrepareData];
    [self PrepareUI];
}
-(void)PrepareData{}
-(void)PrepareUI{

    WeakSelf(ws);

    _statusNameLabel.font = IsPhone6_gt?[UIFont systemFontOfSize:23.0f]:[UIFont systemFontOfSize:20.0f];

    _statusNameTipLabel = [UILabel getLabelWithAlignment:0 WithTitle:nil WithFont:12.0f WithTextColor:nil WithSpacing:0];
    [self.contentView addSubview:_statusNameTipLabel];
    [_statusNameTipLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(ws.statusNameLabel);
        make.left.mas_equalTo(ws.statusNameTipLabel.mas_right).with.offset(5);
    }];

    _helpBtn.hidden = NO;
    [_helpBtn setTitle:NSLocalizedString(@"如何理解订单状态",nil) forState:UIControlStateNormal];
    _helpBtn.titleLabel.attributedText = [[NSAttributedString alloc] initWithString:NSLocalizedString(@"如何理解订单状态",nil) attributes:@{NSUnderlineStyleAttributeName:@(NSUnderlineStyleSingle)}];

    _getBtn.layer.cornerRadius = 2.5;
    _getBtn.layer.masksToBounds = YES;
    _getBtn.layer.borderWidth = 1;

    _operationBtn.layer.cornerRadius = 2.5;
    _operationBtn.layer.masksToBounds = YES;
    _operationBtn.layer.borderWidth = 1;
    [_operationBtn setTitle:NSLocalizedString(@"拒绝确认", nil) forState:UIControlStateNormal];
    _operationBtn.backgroundColor = _define_white_color;
    _operationBtn.layer.borderColor = [UIColor colorWithHex:@"ed6498"].CGColor;
    [_operationBtn setTitleColor:[UIColor colorWithHex:@"ed6498"] forState:UIControlStateNormal];
    _operationBtn.titleLabel.font = [UIFont systemFontOfSize:[LanguageManager isEnglishLanguage]?12.0f:14.0f];

}
#pragma mark - UpdateUI
-(void)updateUI{

    if(_currentYYOrderInfoModel && _currentYYOrderTransStatusModel){
        self.contentView.backgroundColor = [UIColor colorWithHex:@"F8F8F8"];

        _helpBtn.hidden = NO;
        _dealCloseBtn.hidden = YES;

        _getBtn.hidden = YES;
        _getBtn.backgroundColor = _define_black_color;
        _getBtn.layer.borderColor = _define_black_color.CGColor;
        [_getBtn setTitleColor:_define_white_color forState:UIControlStateNormal];
        _getBtn.titleLabel.font = [UIFont systemFontOfSize:[LanguageManager isEnglishLanguage]?12.0f:14.0f];

        _operationBtn.hidden = YES;

        _oprateTimerLabel.text = @"";

        NSInteger tranStatus = getOrderTransStatus(self.currentYYOrderTransStatusModel.designerTransStatus, self.currentYYOrderTransStatusModel.buyerTransStatus);

        _statusTipLayoutConstraint.constant = 40;
        _statusTipLabel.font = [UIFont systemFontOfSize:12];
        _statusTipLabel.textColor = [UIColor colorWithHex:@"919191"];
        _statusTipLabel.text = getOrderStatusBuyerTip(tranStatus);

        _statusNameLabel.textColor = [UIColor colorWithHex:@"ed6498"];
        _statusNameLabel.text = getOrderStatusName_short(tranStatus);

        _statusNameTipLabel.hidden = YES;

        if(tranStatus == YYOrderCode_CLOSE_REQ || [_currentYYOrderInfoModel.closeReqStatus integerValue] == -1){
            //关闭请求
            if([_currentYYOrderInfoModel.closeReqStatus integerValue] == -1){//对方
                _statusNameLabel.text = NSLocalizedString(@"处理中",nil);
                [_dealCloseBtn setTitle:NSLocalizedString(@"立刻处理",nil) forState:UIControlStateNormal];
                [_dealCloseBtn setConstraintConstant:[LanguageManager isEnglishLanguage]?100:80 forAttribute:NSLayoutAttributeWidth];
                _statusTipLabel.text = NSLocalizedString(@"请尽快处理订单，以免对方久等",nil);
            }else{
                _statusNameLabel.text = NSLocalizedString(@"对方处理中",nil);
                [_dealCloseBtn setTitle:NSLocalizedString(@"撤销申请",nil) forState:UIControlStateNormal];
                [_dealCloseBtn setConstraintConstant:108 forAttribute:NSLayoutAttributeWidth];
                _statusTipLabel.text = NSLocalizedString(@"请耐心等待对方处理，如果改变主意可以进行撤销申请",nil);
            }
            self.contentView.backgroundColor = [UIColor colorWithHex:@"FFFFFF"];
            _statusTipLayoutConstraint.constant = 20;
            _helpBtn.hidden = YES;
            _dealCloseBtn.hidden = NO;
            _dealCloseBtn.layer.borderColor = [UIColor colorWithHex:@"919191"].CGColor;
            _dealCloseBtn.layer.borderWidth = 1;
            _dealCloseBtn.layer.cornerRadius = 2.5;
            _dealCloseBtn.layer.masksToBounds = YES;

        }else if(tranStatus == YYOrderCode_NEGOTIATION){
            //已下单

            BOOL isDesignerConfrim = [_currentYYOrderInfoModel isDesignerConfrim];
            BOOL isBuyerConfrim = [_currentYYOrderInfoModel isBuyerConfrim];

            if(!isBuyerConfrim){
                if(!isDesignerConfrim){
                    //双方都未确认
                    _getBtn.hidden = NO;
                    [_getBtn setTitle:NSLocalizedString(@"确认订单",nil) forState:UIControlStateNormal];

                }else{
                    //买手未确认
                    _statusNameTipLabel.hidden = NO;
                    _statusNameTipLabel.text = NSLocalizedString(@"设计师已确认", nil);

                    _getBtn.hidden = NO;
                    [_getBtn setTitle:NSLocalizedString(@"确认订单",nil) forState:UIControlStateNormal];

                    _operationBtn.hidden = NO;
                }
            }else{
                if(!isDesignerConfrim){
                    //设计师未确认
                    _statusNameTipLabel.hidden = NO;
                    _statusNameTipLabel.text = NSLocalizedString(@"待设计师确认", nil);

                    _getBtn.hidden = NO;
                    _getBtn.backgroundColor = [UIColor colorWithHex:@"d3d3d3"];
                    _getBtn.layer.borderColor = [UIColor colorWithHex:@"d3d3d3"].CGColor;
                    [_getBtn setTitleColor:_define_white_color forState:UIControlStateNormal];
                    [_getBtn setTitle:NSLocalizedString(@"待设计师确认",nil) forState:UIControlStateNormal];
                }else{
                    //理论上不存在这种情况

                }
            }

            _oprateTimerLabel.text = [NSString stringWithFormat:@"%@ %@",NSLocalizedString(@"标记于",nil),getShowDateByFormatAndTimeInterval(@"yyyy/MM/dd HH:mm",[_currentYYOrderTransStatusModel.operationTime stringValue])];

        }else if(tranStatus == YYOrderCode_NEGOTIATION_DONE || tranStatus == YYOrderCode_CONTRACT_DONE){
            //已确认

            _oprateTimerLabel.text = [NSString stringWithFormat:@"%@ %@",NSLocalizedString(@"标记于",nil),getShowDateByFormatAndTimeInterval(@"yyyy/MM/dd HH:mm",[_currentYYOrderTransStatusModel.operationTime stringValue])];

        }else if(tranStatus == YYOrderCode_MANUFACTURE){
            //已生产

            _oprateTimerLabel.text = [NSString stringWithFormat:@"%@ %@",NSLocalizedString(@"标记于",nil),getShowDateByFormatAndTimeInterval(@"yyyy/MM/dd HH:mm",[_currentYYOrderTransStatusModel.operationTime stringValue])];

        }else if(tranStatus == YYOrderCode_DELIVERING){
            //发货中

            _oprateTimerLabel.text = [NSString stringWithFormat:@"%@ %@",NSLocalizedString(@"标记于",nil),getShowDateByFormatAndTimeInterval(@"yyyy/MM/dd HH:mm",[_currentYYOrderTransStatusModel.operationTime stringValue])];

        }else if(tranStatus == YYOrderCode_DELIVERY){
            //已发货

            _oprateTimerLabel.text = [NSString stringWithFormat:@"%@ %@",NSLocalizedString(@"标记于",nil),getShowDateByFormatAndTimeInterval(@"yyyy/MM/dd HH:mm",[_currentYYOrderTransStatusModel.operationTime stringValue])];

            _getBtn.hidden = NO;
            [_getBtn setTitle:NSLocalizedString(@"确认收货",nil) forState:UIControlStateNormal];

        }else if(tranStatus == YYOrderCode_RECEIVED){
            //已收货

            _oprateTimerLabel.text = [NSString stringWithFormat:@"%@ %@",NSLocalizedString(@"标记于",nil),getShowDateByFormatAndTimeInterval(@"yyyy/MM/dd HH:mm",[_currentYYOrderTransStatusModel.operationTime stringValue])];

            _statusTipLabel.textColor = [UIColor colorWithHex:@"ed6498"];

        }else if(tranStatus == YYOrderCode_CANCELLED || tranStatus == YYOrderCode_CLOSED){
            //已取消

            _getBtn.hidden = NO;
            [_getBtn setTitle:NSLocalizedString(@"重新建立订单",nil) forState:UIControlStateNormal];

            _statusNameLabel.textColor = [UIColor colorWithHex:@"ef4e31"];

            _oprateTimerLabel.text = [NSString stringWithFormat:@"%@ %@",NSLocalizedString(@"标记于",nil),getShowDateByFormatAndTimeInterval(@"yyyy/MM/dd HH:mm",[_currentYYOrderTransStatusModel.operationTime stringValue])];
        }

        //更新约束
        if(_getBtn.hidden == NO){
            NSString *btnTxt = _getBtn.currentTitle;
            CGSize txtSize = [btnTxt sizeWithAttributes:@{NSFontAttributeName:_getBtn.titleLabel.font}];
            NSInteger btnWidth = MAX(80, (txtSize.width+20));
            [_getBtn setConstraintConstant:btnWidth forAttribute:NSLayoutAttributeWidth];
        }

        //_statusNameLabel设置宽度
        CGSize nameSize = [_statusNameLabel.text sizeWithAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:IsPhone6_gt?23.0f:20.0f]}];
        [_statusNameLabel setConstraintConstant:nameSize.width+1 forAttribute:NSLayoutAttributeWidth];
    }else{

        _getBtn.hidden = YES;
        _operationBtn.hidden = YES;
        _dealCloseBtn.hidden = YES;
        _helpBtn.hidden = NO;

    }
}
#pragma mark - --------------自定义响应----------------------
- (IBAction)opreteBtnHandler:(id)sender {
    NSInteger tranStatus = getOrderTransStatus(_currentYYOrderTransStatusModel.designerTransStatus, _currentYYOrderTransStatusModel.buyerTransStatus);

    if(self.delegate){

        if(tranStatus == YYOrderCode_NEGOTIATION){
            //已下单

            BOOL isDesignerConfrim = [_currentYYOrderInfoModel isDesignerConfrim];
            BOOL isBuyerConfrim = [_currentYYOrderInfoModel isBuyerConfrim];

            if(!isBuyerConfrim){
                if(!isDesignerConfrim){
                    //双方都未确认
                    [self.delegate btnClick:0 section:0 andParmas:@[@"confirmOrder"]];
                }else{
                    //买手未确认
                    [self.delegate btnClick:0 section:0 andParmas:@[@"confirmOrder"]];
                }
            }
        }else if(tranStatus == YYOrderCode_DELIVERY){
            //已发货
            [self.delegate btnClick:0 section:0 andParmas:@[@"status"]];
        }else if(tranStatus == YYOrderCode_CANCELLED || tranStatus == YYOrderCode_CLOSED){
            //已取消
            [self.delegate btnClick:0 section:0 andParmas:@[@"reBuildOrder"]];
        }

    }
}

- (IBAction)opreteBtnHandler1:(id)sender {
    NSInteger tranStatus = getOrderTransStatus(self.currentYYOrderTransStatusModel.designerTransStatus, self.currentYYOrderTransStatusModel.buyerTransStatus);

    if(self.delegate){
        if(tranStatus == YYOrderCode_NEGOTIATION){
            //已下单
            BOOL isDesignerConfrim = [_currentYYOrderInfoModel isDesignerConfrim];
            BOOL isBuyerConfrim = [_currentYYOrderInfoModel isBuyerConfrim];

            if(!isBuyerConfrim){
                if(isDesignerConfrim){
                    //买手未确认
                    [self.delegate btnClick:0 section:0 andParmas:@[@"refuseOrder"]];
                }
            }
        }
    }
}
- (IBAction)showOprateView:(id)sender {
    NSInteger tranStatus = getOrderTransStatus(_currentYYOrderTransStatusModel.designerTransStatus, _currentYYOrderTransStatusModel.buyerTransStatus);

    if(self.delegate){
        if(tranStatus == YYOrderCode_CLOSE_REQ || [_currentYYOrderInfoModel.closeReqStatus integerValue] == -1){
            if([_currentYYOrderInfoModel.closeReqStatus integerValue] == -1){//对方
                [self.delegate btnClick:0 section:0 andParmas:@[@"orderCloseReqDeal"]];
            }else{
                [self.delegate btnClick:0 section:0 andParmas:@[@"cancelReqClose"]];
            }
        }
    }

}

- (IBAction)helpBtnHandler:(id)sender {
    if(self.delegate){
        [self.delegate btnClick:0 section:0 andParmas:@[@"orderHelp"]];
    }
}

#pragma mark - --------------自定义方法----------------------
+(float)cellHeight:(NSInteger)tranStatus{
    if(tranStatus < YYOrderCode_CANCELLED){
        return 111;
    }else if(tranStatus == YYOrderCode_CANCELLED || tranStatus == YYOrderCode_CLOSED){
        return 111;
    }else if(tranStatus == YYOrderCode_CLOSE_REQ){
        return 98;
    }else{
        return 111;
    }
}


#pragma mark - --------------other----------------------

@end
