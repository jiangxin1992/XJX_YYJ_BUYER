//
//  YYRegisterTableBuyerRegisterUploadCell.m
//  YunejianBuyer
//
//  Created by Victor on 2017/12/25.
//  Copyright © 2017年 Apple. All rights reserved.
//

#import "YYRegisterTableBuyerRegisterUploadCell.h"

@interface YYRegisterTableBuyerRegisterUploadCell()

@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UIButton *helpButton;
@property (nonatomic, strong) UIButton *photoUploadButton;
@property (nonatomic, strong) UIView *photoTipView;
@property (nonatomic, strong) UIImageView *addIcon;

@property (nonatomic, strong) CMAlertView *alert;

@end

@implementation YYRegisterTableBuyerRegisterUploadCell

#pragma mark - --------------生命周期--------------
- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseIdentifier]) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        self.separatorInset = UIEdgeInsetsMake(0, CGRectGetWidth([UIScreen mainScreen].bounds), 0, 0);
        __weak typeof (self)weakSelf = self;
        
        self.titleLabel = [[UILabel alloc] init];
        self.titleLabel.text = NSLocalizedString(@"上传买手店营业执照", nil);
        self.titleLabel.textColor = _define_black_color;
        self.titleLabel.font = [UIFont systemFontOfSize:15];
        [self.contentView addSubview:self.titleLabel];
        [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.height.mas_equalTo(15);
            make.top.mas_equalTo(15);
            make.left.mas_equalTo(32);
        }];
        
        self.helpButton = [UIButton getCustomImgBtnWithImageStr:@"help" WithSelectedImageStr:nil];
        [self.helpButton addTarget:self action:@selector(helpBtnClick) forControlEvents:UIControlEventTouchUpInside];
        [self.contentView addSubview:self.helpButton];
        [self.helpButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.width.mas_equalTo(40);
            make.height.mas_equalTo(40);
            make.left.equalTo(weakSelf.titleLabel.mas_right).with.offset(7);
            make.centerY.equalTo(weakSelf.titleLabel.mas_centerY);
        }];
        
        self.photoUploadButton = [UIButton buttonWithType:UIButtonTypeCustom];
        CAShapeLayer *borderLayer = [CAShapeLayer layer];
        borderLayer.bounds = CGRectMake(0, 0, SCREEN_WIDTH-34, 120);
        borderLayer.path = [UIBezierPath bezierPathWithRoundedRect:borderLayer.bounds cornerRadius:2.5].CGPath;
        borderLayer.lineWidth = 2. / [[UIScreen mainScreen] scale];
        borderLayer.lineDashPattern = @[@4, @2];
        borderLayer.fillColor = [UIColor clearColor].CGColor;
        borderLayer.strokeColor = [UIColor colorWithHex:@"D3D3D3"].CGColor;
        borderLayer.anchorPoint = CGPointMake(0, 0);
        [self.photoUploadButton.layer addSublayer:borderLayer];
        [self.photoUploadButton addTarget:self action:@selector(photoBtnClicked) forControlEvents:UIControlEventTouchUpInside];
        [self.contentView addSubview:self.photoUploadButton];
        [self.photoUploadButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.height.mas_equalTo(120);
            make.top.equalTo(weakSelf.titleLabel.mas_bottom).with.offset(15);
            make.left.mas_equalTo(17);
            make.right.mas_equalTo(-17);
        }];
        
        self.photoTipView = [[UIView alloc] init];
        self.photoTipView.userInteractionEnabled = NO;
        self.photoTipView.backgroundColor = [UIColor clearColor];
        [self.contentView addSubview:self.photoTipView];
        [self.photoTipView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.width.equalTo(weakSelf.photoUploadButton.mas_width);
            make.height.equalTo(weakSelf.photoUploadButton.mas_height);
            make.top.equalTo(weakSelf.titleLabel.mas_bottom).with.offset(15);
            make.left.mas_equalTo(17);
        }];
        
        self.addIcon = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"add_icon_gray"]];
        self.addIcon.userInteractionEnabled = NO;
        [self.photoTipView addSubview:self.addIcon];
        [self.addIcon mas_makeConstraints:^(MASConstraintMaker *make) {
            make.width.mas_equalTo(22);
            make.height.mas_equalTo(22);
            make.centerX.mas_equalTo(0);
            make.centerY.mas_equalTo(0);
        }];
    }
    return self;
}

#pragma mark - --------------SomePrepare--------------

#pragma mark - --------------UIConfig----------------------
-(void)updateCellInfo:(YYTableViewCellInfoModel *)info{
    self.photoUploadButton.imageView.contentMode = UIViewContentModeScaleAspectFit;
    self.contentView.autoresizingMask = UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth;
    YYTableViewCellInfoModel *infoModel = info;
    NSString *mustStr = ((infoModel.ismust>0)?@"*":@"");
    self.titleLabel.text = [NSString stringWithFormat:@"%@%@",mustStr,infoModel.tipStr];
    self.photoType= [infoModel.warnStr integerValue];
    
    [self.photoUploadButton setImage:self.uploadImage forState:UIControlStateNormal];
    self.photoTipView.hidden = (self.uploadImage != nil);
}

#pragma mark - --------------请求数据----------------------

#pragma mark - --------------系统代理----------------------


#pragma mark - --------------自定义代理/block----------------------


#pragma mark - --------------自定义响应----------------------
- (void)helpBtnClick{
    if(self.photoType == UploadImageType0){
        [self showHelpUI:1 helpButton:self.helpButton];
    }else{
        [self showHelpUI:2 helpButton:self.helpButton];
    }
}

- (void)photoBtnClicked{
    NSLog(@"photoBtnClicked");
    UIViewController *parent = [UIApplication sharedApplication].keyWindow.rootViewController;
    CGPoint point = [self.photoUploadButton convertPoint:CGPointMake(CGRectGetWidth(self.photoUploadButton.frame), CGRectGetHeight(self.photoUploadButton.frame)/2) toView:parent.view];
    [self.delegate upLoadPhotoImage:_photoType pointX:point.x pointY:point.y];
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
    NSString *imageName = [NSString stringWithFormat:@"%@brand-help/brandhelpImg%ld_%ld",kYYServerResURL,_registerType,photoType];//
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
    
    self.alert = [[CMAlertView alloc] initWithViews:@[controller.view] imageFrame:CGRectMake(0, 0, photoUIWidth, photoUIHeight) bgClose:NO];
    [self.alert show];
}

#pragma mark - --------------other----------------------

@end
