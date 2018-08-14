//
//  YYVisibleUploadImageView.m
//  YunejianBuyer
//
//  Created by chuanjun sun on 2017/10/27.
//  Copyright © 2017年 Apple. All rights reserved.
//

#import "YYVisibleUploadImageView.h"

#import "UIActionSheet+JRPhoto.h"

@interface YYVisibleUploadImageView()
/** 弹出 */
@property (nonatomic, strong) CMAlertView *alert;

/** 店铺照片 */
@property (nonatomic, strong) UIButton *shopUploadButton;
/** 法人照片 */
@property (nonatomic, strong) UIButton *LegalUploadButton;
@end

@implementation YYVisibleUploadImageView
#pragma mark - --------------生命周期--------------
- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self SomePrepare];
    }
    return self;
}

#pragma mark - --------------SomePrepare--------------
- (void)SomePrepare
{
    [self PrepareData];
    [self PrepareUI];
}
- (void)PrepareData{

}


#pragma mark - --------------系统代理----------------------


#pragma mark - --------------自定义代理/block----------------------


#pragma mark - --------------自定义响应----------------------
- (void)shopTipButtonClick{
    [self showHelpUI:1 helpButton:nil];
}

- (void)legalTipButtonClick{
    [self showHelpUI:2 helpButton:nil];
}

- (void)shopUploadButtonClick{
    if ([self.delegate respondsToSelector:@selector(YYVisibleUploadImageView:photo:)]) {
        [self.delegate YYVisibleUploadImageView:self photo:shop];
    }
}

- (void)legalUploadButtonClick{
    if ([self.delegate respondsToSelector:@selector(YYVisibleUploadImageView:photo:)]) {
        [self.delegate YYVisibleUploadImageView:self photo:man];
    }
}


#pragma mark - --------------自定义方法----------------------
-(void)showHelpUI:(NSInteger)photoType helpButton:(UIButton*)btn{
    NSInteger photoUIWidth = 124;
    NSInteger photoUIHeight = 172;
    if(photoType == 2){
        photoUIWidth = 256;
    }
    photoUIWidth = photoUIWidth*1.1;
    photoUIHeight = photoUIHeight*1.1;
    UIViewController *controller = [[UIViewController alloc] init];
    controller.view.frame = CGRectMake(0, 0, photoUIWidth, photoUIHeight);

    NSInteger _registerType = 1;
    NSString *imageName = [NSString stringWithFormat:@"%@brand-help/brandhelpImg%ld_%ld",kYYServerResURL,(long)_registerType,photoType];//
    NSString *imageUrlName = nil;
    if( [UIScreen mainScreen].scale > 1){
        imageUrlName = [NSString stringWithFormat:@"%@@2x.jpg",imageName];
    }else{
        imageUrlName = [NSString stringWithFormat:@"%@.jpg",imageName];
    }
    NSURL *url=[NSURL URLWithString:imageUrlName];
    UIImage *imgFromUrl =[[UIImage alloc]initWithData:[NSData dataWithContentsOfURL:url]];
    controller.view.layer.contentsScale = [UIScreen mainScreen].scale;
    controller.view.layer.contents = (__bridge id _Nullable)(imgFromUrl.CGImage);


    _alert = [[CMAlertView alloc] initWithViews:@[controller.view] imageFrame:CGRectMake(0, 0, photoUIWidth, photoUIHeight) bgClose:NO];
    [_alert show];
}

#pragma mark - get/set
- (void)setManPhoto:(NSData *)manPhoto{
    _manPhoto = manPhoto;
    [self.LegalUploadButton setImage:[UIImage imageWithData:manPhoto] forState:UIControlStateNormal];
    [self layoutIfNeeded];
}

- (void)setShopPhoto:(NSData *)shopPhoto{
    _shopPhoto = shopPhoto;
    [self.shopUploadButton setImage:[UIImage imageWithData:shopPhoto] forState:UIControlStateNormal];
    [self layoutIfNeeded];
}

#pragma mark - --------------UI----------------------
// 创建子控件
- (void)PrepareUI{

    self.backgroundColor = _define_white_color;

    UIView *bottomLine = [[UIView alloc] init];
    bottomLine.backgroundColor = [UIColor colorWithHex:@"D3D3D3"];
    [self addSubview:bottomLine];

    [bottomLine mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.left.right.mas_equalTo(0);
        make.height.mas_equalTo(1);
    }];

    UILabel *titleLabelShop = [[UILabel alloc] init];
    titleLabelShop.text = [NSString stringWithFormat:@"*%@", NSLocalizedString(@"上传店铺营业执照", nil)];
    titleLabelShop.font = [UIFont systemFontOfSize:15];
    titleLabelShop.textColor = _define_black_color;
    [self addSubview:titleLabelShop];

    [titleLabelShop mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(13.5);
        make.top.mas_equalTo(15);
    }];
    [titleLabelShop sizeToFit];

    UIButton *shopTipButton = [[UIButton alloc] init];
    [shopTipButton addTarget:self action:@selector(shopTipButtonClick) forControlEvents:UIControlEventTouchUpInside];
    [shopTipButton setImage:[UIImage imageNamed:@"newhelp_icon"] forState:UIControlStateNormal];
    [self addSubview:shopTipButton];

    [shopTipButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(titleLabelShop.mas_centerY);
        make.left.mas_equalTo(titleLabelShop.mas_right).mas_offset(6.5);
        make.width.height.mas_equalTo(17);
    }];

    UIButton *shopUploadButton = [[UIButton alloc] init];
    self.shopUploadButton = shopUploadButton;
    [shopUploadButton setImage:[UIImage imageNamed:@"add_icon_gray"] forState:UIControlStateNormal];
    [shopUploadButton addTarget:self action:@selector(shopUploadButtonClick) forControlEvents:UIControlEventTouchUpInside];
    shopUploadButton.imageView.contentMode = UIViewContentModeScaleAspectFit;

    CAShapeLayer *borderLayer = [CAShapeLayer layer];
    borderLayer.bounds = CGRectMake(0, 0, SCREEN_WIDTH-34, 120);
    borderLayer.path = [UIBezierPath bezierPathWithRoundedRect:borderLayer.bounds cornerRadius:2.5].CGPath;
    borderLayer.lineWidth = 2. / [[UIScreen mainScreen] scale];
    borderLayer.lineDashPattern = @[@4, @2];
    borderLayer.fillColor = [UIColor clearColor].CGColor;
    borderLayer.strokeColor = [UIColor colorWithHex:@"D3D3D3"].CGColor;
    borderLayer.anchorPoint = CGPointMake(0, 0);
    [shopUploadButton.layer addSublayer:borderLayer];

    [self addSubview:shopUploadButton];

    [shopUploadButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(titleLabelShop.mas_bottom).mas_offset(10);
        make.left.mas_equalTo(13.5);
        make.right.mas_equalTo(-13.5);
        make.height.mas_equalTo(120);
    }];

    // -------------------第二块 上传法人身份证照片 ---------

    UILabel *titleLabelLegal = [[UILabel alloc] init];
    titleLabelLegal.text = [NSString stringWithFormat:@"*%@", NSLocalizedString(@"上传法人身份证 （正面照）", nil)];
    titleLabelLegal.font = [UIFont systemFontOfSize:15];
    titleLabelLegal.textColor = _define_black_color;
    [self addSubview:titleLabelLegal];

    [titleLabelLegal mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(13.5);
        make.top.mas_equalTo(shopUploadButton.mas_bottom).mas_offset(15);
    }];
    [titleLabelLegal sizeToFit];

    UIButton *LegalTipButton = [[UIButton alloc] init];
    [LegalTipButton addTarget:self action:@selector(legalTipButtonClick) forControlEvents:UIControlEventTouchUpInside];
    [LegalTipButton setImage:[UIImage imageNamed:@"newhelp_icon"] forState:UIControlStateNormal];
    [self addSubview:LegalTipButton];

    [LegalTipButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(titleLabelLegal.mas_centerY);
        make.left.mas_equalTo(titleLabelLegal.mas_right).mas_offset(6.5);
        make.width.height.mas_equalTo(17);
    }];

    UIButton *LegalUploadButton = [[UIButton alloc] init];
    self.LegalUploadButton = LegalUploadButton;
    [LegalUploadButton setImage:[UIImage imageNamed:@"add_icon_gray"] forState:UIControlStateNormal];
    [LegalUploadButton addTarget:self action:@selector(legalUploadButtonClick) forControlEvents:UIControlEventTouchUpInside];
    LegalUploadButton.imageView.contentMode = UIViewContentModeScaleAspectFit;

    CAShapeLayer *LborderLayer = [CAShapeLayer layer];
    LborderLayer.bounds = CGRectMake(0, 0, SCREEN_WIDTH-34, 120);
    LborderLayer.path = [UIBezierPath bezierPathWithRoundedRect:borderLayer.bounds cornerRadius:2.5].CGPath;
    LborderLayer.lineWidth = 2. / [[UIScreen mainScreen] scale];
    LborderLayer.lineDashPattern = @[@4, @2];
    LborderLayer.fillColor = [UIColor clearColor].CGColor;
    LborderLayer.strokeColor = [UIColor colorWithHex:@"D3D3D3"].CGColor;
    LborderLayer.anchorPoint = CGPointMake(0, 0);
    [LegalUploadButton.layer addSublayer:LborderLayer];

    [self addSubview:LegalUploadButton];

    [LegalUploadButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(titleLabelLegal.mas_bottom).mas_offset(10);
        make.left.mas_equalTo(13.5);
        make.right.mas_equalTo(-13.5);
        make.height.mas_equalTo(120);
    }];

}

#pragma mark - --------------other----------------------
//#pragma mark - 可以获取到父容器的控制器的方法,就是这个黑科技.
//- (UIViewController *)getController:(UIView *)view{
//    UIResponder *responder = view;
//    //循环获取下一个响应者,直到响应者是一个UIViewController类的一个对象为止,然后返回该对象.
//    while ((responder = [responder nextResponder])) {
//        if ([responder isKindOfClass:[UIViewController class]]) {
//            return (UIViewController *)responder;
//        }
//    }
//    return [UIApplication sharedApplication].keyWindow.rootViewController;
//}
@end
