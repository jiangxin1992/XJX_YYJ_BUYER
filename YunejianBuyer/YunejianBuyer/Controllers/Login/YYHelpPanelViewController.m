//
//  YYHelpPanelViewController.m
//  yunejianDesigner
//
//  Created by Apple on 16/7/7.
//  Copyright © 2016年 Apple. All rights reserved.
//

#import "YYHelpPanelViewController.h"
#import "UIImage+Tint.h"
#import "UIView+UpdateAutoLayoutConstraints.h"

@interface YYHelpPanelViewController ()
@property (weak, nonatomic) IBOutlet UIView *contentView;
@property (weak, nonatomic) IBOutlet UIButton *titleBtn;
@property (weak, nonatomic) IBOutlet UILabel *txtLabel;
@property (weak, nonatomic) IBOutlet UIButton *titleBtn1;
@property (weak, nonatomic) IBOutlet UILabel *txtLabel1;
@end

@implementation YYHelpPanelViewController
static NSArray *helpContentData = nil;
//static dispatch_once_t onceToken;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.contentView.layer.borderWidth = 4;
    self.contentView.layer.borderColor = [UIColor blackColor].CGColor;
    [_titleBtn setImage:[[UIImage imageNamed:@"infohelp_icon"] imageWithTintColor:[UIColor blackColor]] forState:UIControlStateNormal];
   // helpPanelType
    
    //static dispatch_once_t onceToken;
//    dispatch_once(&onceToken, ^{
        helpContentData = @[@[ NSLocalizedString(@"折扣 = (税前总价+税金) x (1-打折%)",nil), NSLocalizedString(@"折扣是针对税后价格打折,买手店不能够编辑折扣。",nil), NSLocalizedString(@"实付 = 税前总价 + 税金 - 折扣",nil), NSLocalizedString(@"除人民币外的其他币种,不提供加税功能。",nil)],
                            @[ NSLocalizedString(@"关于线上支付：",nil), NSLocalizedString(@"1.线上支付目前仅支持支付宝支付。只有当设计师设置好收款 账户,才可以线上支付。\n2.成功线上支付后,平台将会对货款进行审核,之后会打入到 设计师的支付宝账户。总耗时2-3个工作日。\n3.线上付款不收取任何手续费。",nil), NSLocalizedString(@"关于付款记录：",nil), NSLocalizedString(@"1.线上付款记录和线下付款记录均会出现在付款记录的列表中。其中只有线下付款记录可以修改和删除。\n2.线下付款记录与设计师端的收款记录不同步。\n3.线上付款记录与设计师端同步。",nil)]
                            ];
//    });
    float contentViewWidth = MIN(292, SCREEN_WIDTH-30);
    float contentViewHeight = 128-9;
    
    NSArray *helpContentArr = [helpContentData objectAtIndex:(_helpPanelType-1)];
    [_titleBtn setTitle:helpContentArr[0] forState:UIControlStateNormal];
    [_titleBtn1 setTitle:helpContentArr[2] forState:UIControlStateNormal];
    NSString *helpContent = helpContentArr[1];
    NSMutableParagraphStyle *paraStyle = [[NSMutableParagraphStyle alloc] init];
    paraStyle.lineSpacing = 1;
    NSDictionary *attDic = @{NSParagraphStyleAttributeName: paraStyle,NSFontAttributeName:[UIFont systemFontOfSize:13]};
    NSInteger hasHeight = getTxtHeight(contentViewWidth-34, helpContent, attDic);
    [_txtLabel setConstraintConstant:hasHeight forAttribute:NSLayoutAttributeHeight];
    _txtLabel.attributedText = [[NSAttributedString alloc] initWithString:helpContent attributes:attDic];
    contentViewHeight = contentViewHeight+hasHeight;
    helpContent = helpContentArr[3];
    hasHeight = getTxtHeight(contentViewWidth-34, helpContent, attDic);
    [_txtLabel1 setConstraintConstant:hasHeight forAttribute:NSLayoutAttributeHeight];
    _txtLabel1.attributedText = [[NSAttributedString alloc] initWithString:helpContent attributes:attDic];
    contentViewHeight = contentViewHeight+hasHeight;
    [_contentView setConstraintConstant:contentViewWidth forAttribute:NSLayoutAttributeWidth];
    [_contentView setConstraintConstant:contentViewHeight forAttribute:NSLayoutAttributeHeight];

    popWindowAddBgView(self.view);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)closeHandler:(id)sender {
    if (_cancelButtonClicked) {
        _cancelButtonClicked();
    }
}
@end
