//
//  YYOrderMessageOperateViewController.m
//  YunejianBuyer
//
//  Created by Apple on 16/8/18.
//  Copyright © 2016年 Apple. All rights reserved.
//

#import "YYOrderMessageOperateViewController.h"

#import "UIView+UpdateAutoLayoutConstraints.h"
#import "SCGIFImageView.h"

@interface YYOrderMessageOperateViewController ()
@property (weak, nonatomic) IBOutlet SCGIFImageView *brandLogoImageView;
@property (weak, nonatomic) IBOutlet UILabel *brandNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *orderCodeLabel;
@property (weak, nonatomic) IBOutlet UILabel *styleTotalLabel;
@property (weak, nonatomic) IBOutlet UILabel *tipLabel;

@end

@implementation YYOrderMessageOperateViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    UIView *yellowView = [self.view viewWithTag:10001];
    float uiWidth = MIN(325, SCREEN_WIDTH-30);
    [yellowView setConstraintConstant:uiWidth forAttribute:NSLayoutAttributeWidth];
    UIButton *agressbtn =[self.view viewWithTag:10002];
    agressbtn.layer.cornerRadius = 2.5;
    UIButton *refusebtn =[self.view viewWithTag:10003];
    refusebtn.layer.borderColor = [UIColor blackColor].CGColor;
    refusebtn.layer.borderWidth = 1;
    refusebtn.layer.cornerRadius = 2.5;
    
    _brandLogoImageView.layer.cornerRadius = 2;
    _brandLogoImageView.layer.borderWidth = 1;
    _brandLogoImageView.layer.borderColor = [UIColor colorWithHex:@"efefef"].CGColor;
    sd_downloadWebImageWithRelativePath(NO, _confirmInfoModel.logoPath,_brandLogoImageView,kLogoCover, 0);
    _brandNameLabel.text = _confirmInfoModel.brandName;
    _orderCodeLabel.adjustsFontSizeToFitWidth = YES;
    _styleTotalLabel.adjustsFontSizeToFitWidth = YES;
    _orderCodeLabel.text = [NSString stringWithFormat:@"%@：%@  %@：%@",NSLocalizedString(@"订单",nil),_confirmInfoModel.originOrderCode,NSLocalizedString(@"建单",nil),getShowDateByFormatAndTimeInterval(@"yyyy/MM/dd HH:mm",[_confirmInfoModel.orderCreateTime stringValue])];
    _styleTotalLabel.text = replaceMoneyFlag([NSString stringWithFormat:@"%@：%@%@%@%@ ￥%@",NSLocalizedString(@"共计",nil),_confirmInfoModel.styleAmount,NSLocalizedString(@"款",nil),_confirmInfoModel.itemAmount,NSLocalizedString(@"件",nil),_confirmInfoModel.totalPrice],[_confirmInfoModel.curType integerValue]);
    _tipLabel.text = NSLocalizedString(@"这是一个追单，请先判断是否关联其原始订单。若您拒绝原始订单的关联，则追单也将相应拒绝。",nil);
    float needTxtHeight = getTxtHeight(uiWidth-60, _tipLabel.text,@{NSFontAttributeName:_tipLabel.font});
    float uiHeight = 375 - 69 + needTxtHeight;
    [yellowView setConstraintConstant:uiHeight forAttribute:NSLayoutAttributeHeight];

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}
- (IBAction)closeBtnHandler:(id)sender {
    if(self.cancelButtonClicked){
        self.cancelButtonClicked();
    }
}
- (IBAction)agressBtnHandler:(id)sender {
    if(self.modifySuccess){
        self.modifySuccess(@[@"agress"]);
    }
}
- (IBAction)refuseBtnHandler:(id)sender {
    if(self.modifySuccess){
        self.modifySuccess(@[@"refuse"]);
    }
}

@end
