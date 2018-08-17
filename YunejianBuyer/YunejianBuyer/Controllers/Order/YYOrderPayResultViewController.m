//
//  YYOrderPayResultViewController.m
//  YunejianBuyer
//
//  Created by Apple on 16/7/19.
//  Copyright © 2016年 Apple. All rights reserved.
//

#import "YYOrderPayResultViewController.h"

#import "YYNavigationBarViewController.h"
#import "UIView+UpdateAutoLayoutConstraints.h"
#import "AppDelegate.h"
#import "YYOrderDetailViewController.h"
#import "SCGIFImageView.h"

@interface YYOrderPayResultViewController ()
@property (weak, nonatomic) IBOutlet UIView *containerView;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;

@property (weak, nonatomic) IBOutlet UIButton *resultTitleBtn;
@property (weak, nonatomic) IBOutlet UILabel *resultTiplabel1;
@property (weak, nonatomic) IBOutlet UILabel *resultTiplabel2;
@property (weak, nonatomic) IBOutlet UILabel *resultTiplabel3;

@property (weak, nonatomic) IBOutlet SCGIFImageView *logoImageView;
@property (weak, nonatomic) IBOutlet UILabel *orderCodeLabel;
@property (weak, nonatomic) IBOutlet UILabel *payCodeLabel;
@property (weak, nonatomic) IBOutlet UILabel *paytimerLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *orderInfoViewlayoutTopConstraint;
@property (weak, nonatomic) IBOutlet UIView *infoView;

@property (weak, nonatomic) IBOutlet UIButton *backBtn;
@end

@implementation YYOrderPayResultViewController
static NSArray *tipContentData = nil;
//static dispatch_once_t onceToken;
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]];
    YYNavigationBarViewController *navigationBarViewController = [storyboard instantiateViewControllerWithIdentifier:@"YYNavigationBarViewController"];
    navigationBarViewController.previousTitle = @"";
    //self.navigationBarViewController = navigationBarViewController;
    navigationBarViewController.nowTitle = NSLocalizedString(@"付款",nil);
    [_containerView insertSubview:navigationBarViewController.view atIndex:0];
    //[_containerView addSubview:navigationBarViewController.view];
    __weak UIView *_weakContainerView = _containerView;
    [navigationBarViewController.view mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(_weakContainerView.mas_top);
        make.left.equalTo(_weakContainerView.mas_left);
        make.bottom.equalTo(_weakContainerView.mas_bottom);
        make.right.equalTo(_weakContainerView.mas_right);
    }];
    WeakSelf(ws);
    __block YYNavigationBarViewController *blockVc = navigationBarViewController;
    
    [navigationBarViewController setNavigationButtonClicked:^(NavigationButtonType buttonType){
        if (buttonType == NavigationButtonTypeGoBack) {
            [ws.navigationController popViewControllerAnimated:YES];
            blockVc = nil;
        }
    }];
    
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        tipContentData = @[@[NSLocalizedString(@"付款成功",nil),@"paysucceed_icon",NSLocalizedString(@"货款将在2-3个工作日到账，可以在付款记录中查看付款进度。YCO System/Yco System不会收取任何费率。",nil)],
                            @[NSLocalizedString(@"付款失败",nil),@"payfailed_icon",NSLocalizedString(@"可能导致支付失败的原因：",nil),NSLocalizedString(@"• 支付宝金额不足，无法达到付费金额，导致付费失败。建议您检查支付宝余额后再试。",nil),NSLocalizedString(@"• 网络开小差，建议稍等一会，换个时间点再进行支付尝试。",nil)]
                            ];
    });
    [self updateResultView:_payResultType];
    [self updateOrderInfoView];
    

}

-(void)viewWillAppear:(BOOL)animated{
    _scrollView.contentInset = UIEdgeInsetsMake(-20, 0, 0, 0);
   // _scrollView.contentOffset = CGPointZero;
    // 进入埋点
    [MobClick beginLogPageView:kYYPageOrderPayResult];

}


- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    // 退出埋点
    [MobClick endLogPageView:kYYPageOrderPayResult];
}

- (void)updateResultView:(NSInteger)resultType{
    NSArray *tipContentArr = nil;
    NSInteger cellwidth = SCREEN_WIDTH - 40;

    if(resultType == 9000){
        tipContentArr = [tipContentData objectAtIndex:0];
        _resultTiplabel1.textAlignment = NSTextAlignmentCenter;
        _resultTiplabel2.hidden = YES;
        _resultTiplabel3.hidden = YES;
        NSString *tipStr1 = [tipContentArr objectAtIndex:2];
        float tipstrHeight1 = getTxtHeight(cellwidth,tipStr1,@{NSFontAttributeName:_resultTiplabel1.font});
        _resultTiplabel1.text = tipStr1;
        [_resultTiplabel1 setConstraintConstant:tipstrHeight1 forAttribute:NSLayoutAttributeHeight];
        _orderInfoViewlayoutTopConstraint.constant = tipstrHeight1+23;
    }else{
        tipContentArr = [tipContentData objectAtIndex:1];
        _resultTiplabel1.textAlignment = NSTextAlignmentLeft;
        _resultTiplabel2.textAlignment = NSTextAlignmentLeft;
        _resultTiplabel3.textAlignment = NSTextAlignmentLeft;
        _resultTiplabel2.hidden = NO;
        _resultTiplabel3.hidden = NO;
        
        NSString *tipStr1 = [tipContentArr objectAtIndex:2];
        float tipstrHeight1 = getTxtHeight(cellwidth,tipStr1,@{NSFontAttributeName:_resultTiplabel1.font});
        _resultTiplabel1.text = tipStr1;
        [_resultTiplabel1 setConstraintConstant:tipstrHeight1 forAttribute:NSLayoutAttributeHeight];
        NSString *tipStr2 = [tipContentArr objectAtIndex:3];
        float tipstrHeight2 = getTxtHeight(cellwidth,tipStr2,@{NSFontAttributeName:_resultTiplabel2.font})+1;
        _resultTiplabel2.text = tipStr2;
        [_resultTiplabel2 setConstraintConstant:tipstrHeight2 forAttribute:NSLayoutAttributeHeight];
        NSString *tipStr3 = [tipContentArr objectAtIndex:4];
        float tipstrHeight3 = getTxtHeight(cellwidth,tipStr3,@{NSFontAttributeName:_resultTiplabel3.font})+1;
        _resultTiplabel3.text = tipStr3;
        [_resultTiplabel3 setConstraintConstant:tipstrHeight3 forAttribute:NSLayoutAttributeHeight];

        
        _orderInfoViewlayoutTopConstraint.constant = tipstrHeight1+tipstrHeight2+tipstrHeight3+20+23;
    }
    [_resultTitleBtn setTitle:[tipContentArr objectAtIndex:0] forState:UIControlStateNormal];
    [_resultTitleBtn setImage:[UIImage imageNamed:[tipContentArr objectAtIndex:1]] forState:UIControlStateNormal];

}

-(void)updateOrderInfoView{
    if(_resultDic){
        _infoView.hidden = NO;
        _logoImageView.layer.borderColor = [UIColor colorWithHex:@"efefef"].CGColor;
        _logoImageView.layer.borderWidth = 1;
        _logoImageView.layer.cornerRadius = 1;
        _logoImageView.layer.masksToBounds = YES;
    
        _backBtn.layer.cornerRadius = 2.5;
        NSString * brandlogo = [[_resultDic objectForKey:@"outContext"] objectForKey:@"brandlogo"];
        if(brandlogo && brandlogo.length > 0){
            sd_downloadWebImageWithRelativePath(NO, brandlogo, _logoImageView, kLogoCover, 0);
        }

        _orderCodeLabel.text = [NSString stringWithFormat:@"%@ %@",NSLocalizedString(@"订单编号",nil),[[_resultDic objectForKey:@"outContext"] objectForKey:@"ordercode"]];//
        _payCodeLabel.text = [NSString stringWithFormat:@"%@ %@",NSLocalizedString(@"交易单号",nil),[_resultDic objectForKey:@"outTradeNO"]];
        NSTimeInterval time = [[NSDate date] timeIntervalSince1970]*1000;

        _paytimerLabel.text = [NSString stringWithFormat:@"%@ %@",NSLocalizedString(@"付款时间",nil),getShowDateByFormatAndTimeInterval(@"yyyy-MM-dd HH:mm:ss",[[NSNumber numberWithLongLong:time] stringValue])];
    }else{
        _infoView.hidden = YES;
    }
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

- (IBAction)bachBtnHandler:(id)sender {
    if(_isViewControllerBackType){
        [self.navigationController popViewControllerAnimated:YES];
    }else{
        AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
        [appDelegate.mainViewController popViewControllerAnimated:NO];
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"OrderDetail" bundle:[NSBundle mainBundle]];
        YYOrderDetailViewController *orderDetailViewController = [storyboard instantiateViewControllerWithIdentifier:@"YYOrderDetailViewController"];

        NSString * brandLogo = [[_resultDic objectForKey:@"outContext"] objectForKey:@"brandlogo"];
        NSString *orderCode = [[_resultDic objectForKey:@"outContext"] objectForKey:@"ordercode"];
        orderDetailViewController.currentOrderCode = orderCode;
        orderDetailViewController.currentOrderLogo = brandLogo;
        orderDetailViewController.currentOrderConnStatus =kOrderStatusNUll;
     
        [appDelegate.mainViewController pushViewController:orderDetailViewController animated:YES];

    }
}
@end
