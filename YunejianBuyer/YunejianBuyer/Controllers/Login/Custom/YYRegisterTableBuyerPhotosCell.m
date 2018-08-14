//
//  YYRegisterTableBuyerPhotosCell.m
//  YunejianBuyer
//
//  Created by Victor on 2017/12/26.
//  Copyright © 2017年 Apple. All rights reserved.
//

#import "YYRegisterTableBuyerPhotosCell.h"
#import "SCGIFButtonView.h"
#import "UIView+UpdateAutoLayoutConstraints.h"

@interface YYRegisterTableBuyerPhotosCell()

@property (strong, nonatomic) SCGIFButtonView *photoIamgeBtn1;
@property (strong, nonatomic) SCGIFButtonView *photoIamgeBtn2;
@property (strong, nonatomic) SCGIFButtonView *photoIamgeBtn3;
@property (strong, nonatomic) SCGIFButtonView *photoIamgeBtn4;
@property (strong, nonatomic) SCGIFButtonView *photoIamgeBtn5;
@property (strong, nonatomic) SCGIFButtonView *photoIamgeBtn6;
@property (strong, nonatomic) SCGIFButtonView *photoIamgeBtn7;
@property (strong, nonatomic) SCGIFButtonView *photoIamgeBtn8;
@property (strong, nonatomic) UIView *photoImageTipView;
@property (strong, nonatomic) UIImageView *iconImageView;
@property (strong, nonatomic) UILabel *updateTipLabel;
@property (strong, nonatomic) UIButton *photoDeleteBtn1;
@property (strong, nonatomic) UIButton *photoDeleteBtn2;
@property (strong, nonatomic) UIButton *photoDeleteBtn3;
@property (strong, nonatomic) UIButton *photoDeleteBtn4;
@property (strong, nonatomic) UIButton *photoDeleteBtn5;
@property (strong, nonatomic) UIButton *photoDeleteBtn6;
@property (strong, nonatomic) UIButton *photoDeleteBtn7;
@property (strong, nonatomic) UIButton *photoDeleteBtn8;

@property (nonatomic, assign) NSInteger itemWidth;
@property (nonatomic, assign) NSInteger maxPhotoNum;

@end

@implementation YYRegisterTableBuyerPhotosCell

#pragma mark - --------------生命周期--------------
- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseIdentifier]) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        self.separatorInset = UIEdgeInsetsMake(0, CGRectGetWidth([UIScreen mainScreen].bounds), 0, 0);
        __weak typeof (self)weakSelf = self;
        
        self.photoIamgeBtn1 = [SCGIFButtonView buttonWithType:UIButtonTypeCustom];
        self.photoIamgeBtn1.backgroundColor = [UIColor groupTableViewBackgroundColor];
        [self.photoIamgeBtn1 addTarget:self action:@selector(photoBtnClicked1:) forControlEvents:UIControlEventTouchUpInside];
        [self.contentView addSubview:self.photoIamgeBtn1];
        [self.photoIamgeBtn1 mas_makeConstraints:^(MASConstraintMaker *make) {
            make.width.mas_equalTo(95);
            make.height.mas_equalTo(95);
            make.top.mas_equalTo(15);
            make.left.mas_equalTo(17);
        }];
        self.photoImageTipView = [[UIView alloc] init];
        self.photoImageTipView.userInteractionEnabled = NO;
        self.photoImageTipView.backgroundColor = [UIColor clearColor];
        [self.contentView addSubview:self.photoImageTipView];
        [self.photoImageTipView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.width.equalTo(weakSelf.photoIamgeBtn1.mas_width);
            make.height.equalTo(weakSelf.photoIamgeBtn1.mas_height);
            make.top.mas_equalTo(15);
            make.left.mas_equalTo(17);
        }];
        self.iconImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"photo"]];
        [self.photoImageTipView addSubview:self.iconImageView];
        [self.iconImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.width.mas_equalTo(19);
            make.height.mas_equalTo(15);
            make.centerX.mas_equalTo(0);
            make.centerY.mas_equalTo(-8);
        }];
        self.updateTipLabel = [[UILabel alloc] init];
        self.updateTipLabel.text = NSLocalizedString(@"上传照片", nil);
        self.updateTipLabel.textColor = _define_black_color;
        self.updateTipLabel.font = [UIFont systemFontOfSize:13];
        self.updateTipLabel.textAlignment = NSTextAlignmentCenter;
        [self.photoImageTipView addSubview:self.updateTipLabel];
        [self.updateTipLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.height.mas_equalTo(21);
            make.left.mas_equalTo(0);
            make.right.mas_equalTo(0);
            make.centerY.mas_equalTo(10);
        }];
        self.photoDeleteBtn1 = [UIButton getCustomImgBtnWithImageStr:@"update_delete_icon" WithSelectedImageStr:nil];
        [self.photoDeleteBtn1 addTarget:self action:@selector(photoDeleteBtnClicked1:) forControlEvents:UIControlEventTouchUpInside];
        [self.contentView addSubview:self.photoDeleteBtn1];
        [self.photoDeleteBtn1 mas_makeConstraints:^(MASConstraintMaker *make) {
            make.width.mas_equalTo(22);
            make.height.mas_equalTo(22);
            make.top.equalTo(weakSelf.photoIamgeBtn1.mas_top).with.offset(0);
            make.right.equalTo(weakSelf.photoIamgeBtn1.mas_right).with.offset(0);
        }];
        
        self.photoIamgeBtn2 = [SCGIFButtonView buttonWithType:UIButtonTypeCustom];
        self.photoIamgeBtn2.backgroundColor = [UIColor groupTableViewBackgroundColor];
        [self.photoIamgeBtn2 addTarget:self action:@selector(photoBtnClicked2:) forControlEvents:UIControlEventTouchUpInside];
        [self.contentView addSubview:self.photoIamgeBtn2];
        [self.photoIamgeBtn2 mas_makeConstraints:^(MASConstraintMaker *make) {
            make.width.mas_equalTo(95);
            make.height.mas_equalTo(95);
            make.top.equalTo(weakSelf.photoIamgeBtn1.mas_top).with.offset(0);
            make.left.equalTo(weakSelf.photoIamgeBtn1.mas_right).with.offset(15);
        }];
        self.photoDeleteBtn2 = [UIButton getCustomImgBtnWithImageStr:@"update_delete_icon" WithSelectedImageStr:nil];
        [self.photoDeleteBtn2 addTarget:self action:@selector(photoDeleteBtnClicked2:) forControlEvents:UIControlEventTouchUpInside];
        [self.contentView addSubview:self.photoDeleteBtn2];
        [self.photoDeleteBtn2 mas_makeConstraints:^(MASConstraintMaker *make) {
            make.width.mas_equalTo(22);
            make.height.mas_equalTo(22);
            make.top.equalTo(weakSelf.photoIamgeBtn2.mas_top).with.offset(0);
            make.right.equalTo(weakSelf.photoIamgeBtn2.mas_right).with.offset(0);
        }];
        
        self.photoIamgeBtn3 = [SCGIFButtonView buttonWithType:UIButtonTypeCustom];
        self.photoIamgeBtn3.backgroundColor = [UIColor groupTableViewBackgroundColor];
        [self.photoIamgeBtn3 addTarget:self action:@selector(photoBtnClicked3:) forControlEvents:UIControlEventTouchUpInside];
        [self.contentView addSubview:self.photoIamgeBtn3];
        [self.photoIamgeBtn3 mas_makeConstraints:^(MASConstraintMaker *make) {
            make.width.mas_equalTo(95);
            make.height.mas_equalTo(95);
            make.top.equalTo(weakSelf.photoIamgeBtn1.mas_top).with.offset(0);
            make.left.equalTo(weakSelf.photoIamgeBtn2.mas_right).with.offset(15);
        }];
        self.photoDeleteBtn3 = [UIButton getCustomImgBtnWithImageStr:@"update_delete_icon" WithSelectedImageStr:nil];
        [self.photoDeleteBtn3 addTarget:self action:@selector(photoDeleteBtnClicked3:) forControlEvents:UIControlEventTouchUpInside];
        [self.contentView addSubview:self.photoDeleteBtn3];
        [self.photoDeleteBtn3 mas_makeConstraints:^(MASConstraintMaker *make) {
            make.width.mas_equalTo(22);
            make.height.mas_equalTo(22);
            make.top.equalTo(weakSelf.photoIamgeBtn3.mas_top).with.offset(0);
            make.right.equalTo(weakSelf.photoIamgeBtn3.mas_right).with.offset(0);
        }];
        
        self.photoIamgeBtn4 = [SCGIFButtonView buttonWithType:UIButtonTypeCustom];
        self.photoIamgeBtn4.backgroundColor = [UIColor groupTableViewBackgroundColor];
        [self.photoIamgeBtn4 addTarget:self action:@selector(photoBtnClicked4:) forControlEvents:UIControlEventTouchUpInside];
        [self.contentView addSubview:self.photoIamgeBtn4];
        [self.photoIamgeBtn4 mas_makeConstraints:^(MASConstraintMaker *make) {
            make.width.mas_equalTo(95);
            make.height.mas_equalTo(95);
            make.top.equalTo(weakSelf.photoIamgeBtn1.mas_bottom).with.offset(15);
            make.left.equalTo(weakSelf.photoIamgeBtn1.mas_left).with.offset(0);
        }];
        self.photoDeleteBtn4 = [UIButton getCustomImgBtnWithImageStr:@"update_delete_icon" WithSelectedImageStr:nil];
        [self.photoDeleteBtn4 addTarget:self action:@selector(photoDeleteBtnClicked4:) forControlEvents:UIControlEventTouchUpInside];
        [self.contentView addSubview:self.photoDeleteBtn4];
        [self.photoDeleteBtn4 mas_makeConstraints:^(MASConstraintMaker *make) {
            make.width.mas_equalTo(22);
            make.height.mas_equalTo(22);
            make.top.equalTo(weakSelf.photoIamgeBtn4.mas_top).with.offset(0);
            make.right.equalTo(weakSelf.photoIamgeBtn4.mas_right).with.offset(0);
        }];
        
        self.photoIamgeBtn5 = [SCGIFButtonView buttonWithType:UIButtonTypeCustom];
        self.photoIamgeBtn5.backgroundColor = [UIColor groupTableViewBackgroundColor];
        [self.photoIamgeBtn5 addTarget:self action:@selector(photoBtnClicked5:) forControlEvents:UIControlEventTouchUpInside];
        [self.contentView addSubview:self.photoIamgeBtn5];
        [self.photoIamgeBtn5 mas_makeConstraints:^(MASConstraintMaker *make) {
            make.width.mas_equalTo(95);
            make.height.mas_equalTo(95);
            make.top.equalTo(weakSelf.photoIamgeBtn4.mas_top).with.offset(0);
            make.left.equalTo(weakSelf.photoIamgeBtn4.mas_right).with.offset(15);
        }];
        self.photoDeleteBtn5 = [UIButton getCustomImgBtnWithImageStr:@"update_delete_icon" WithSelectedImageStr:nil];
        [self.photoDeleteBtn5 addTarget:self action:@selector(photoDeleteBtnClicked5:) forControlEvents:UIControlEventTouchUpInside];
        [self.contentView addSubview:self.photoDeleteBtn5];
        [self.photoDeleteBtn5 mas_makeConstraints:^(MASConstraintMaker *make) {
            make.width.mas_equalTo(22);
            make.height.mas_equalTo(22);
            make.top.equalTo(weakSelf.photoIamgeBtn5.mas_top).with.offset(0);
            make.right.equalTo(weakSelf.photoIamgeBtn5.mas_right).with.offset(0);
        }];
        
        self.photoIamgeBtn6 = [SCGIFButtonView buttonWithType:UIButtonTypeCustom];
        self.photoIamgeBtn6.backgroundColor = [UIColor groupTableViewBackgroundColor];
        [self.photoIamgeBtn6 addTarget:self action:@selector(photoBtnClicked6:) forControlEvents:UIControlEventTouchUpInside];
        [self.contentView addSubview:self.photoIamgeBtn6];
        [self.photoIamgeBtn6 mas_makeConstraints:^(MASConstraintMaker *make) {
            make.width.mas_equalTo(95);
            make.height.mas_equalTo(95);
            make.top.equalTo(weakSelf.photoIamgeBtn4.mas_top).with.offset(0);
            make.left.equalTo(weakSelf.photoIamgeBtn5.mas_right).with.offset(15);
        }];
        self.photoDeleteBtn6 = [UIButton getCustomImgBtnWithImageStr:@"update_delete_icon" WithSelectedImageStr:nil];
        [self.photoDeleteBtn6 addTarget:self action:@selector(photoDeleteBtnClicked6:) forControlEvents:UIControlEventTouchUpInside];
        [self.contentView addSubview:self.photoDeleteBtn6];
        [self.photoDeleteBtn6 mas_makeConstraints:^(MASConstraintMaker *make) {
            make.width.mas_equalTo(22);
            make.height.mas_equalTo(22);
            make.top.equalTo(weakSelf.photoIamgeBtn6.mas_top).with.offset(0);
            make.right.equalTo(weakSelf.photoIamgeBtn6.mas_right).with.offset(0);
        }];
        
        self.photoIamgeBtn7 = [SCGIFButtonView buttonWithType:UIButtonTypeCustom];
        self.photoIamgeBtn7.backgroundColor = [UIColor groupTableViewBackgroundColor];
        [self.photoIamgeBtn7 addTarget:self action:@selector(photoBtnClicked7:) forControlEvents:UIControlEventTouchUpInside];
        [self.contentView addSubview:self.photoIamgeBtn7];
        [self.photoIamgeBtn7 mas_makeConstraints:^(MASConstraintMaker *make) {
            make.width.mas_equalTo(95);
            make.height.mas_equalTo(95);
            make.top.equalTo(weakSelf.photoIamgeBtn4.mas_bottom).with.offset(15);
            make.left.equalTo(weakSelf.photoIamgeBtn4.mas_left).with.offset(0);
        }];
        self.photoDeleteBtn7 = [UIButton getCustomImgBtnWithImageStr:@"update_delete_icon" WithSelectedImageStr:nil];
        [self.photoDeleteBtn7 addTarget:self action:@selector(photoDeleteBtnClicked7:) forControlEvents:UIControlEventTouchUpInside];
        [self.contentView addSubview:self.photoDeleteBtn7];
        [self.photoDeleteBtn7 mas_makeConstraints:^(MASConstraintMaker *make) {
            make.width.mas_equalTo(22);
            make.height.mas_equalTo(22);
            make.top.equalTo(weakSelf.photoIamgeBtn7.mas_top).with.offset(0);
            make.right.equalTo(weakSelf.photoIamgeBtn7.mas_right).with.offset(0);
        }];
        
        self.photoIamgeBtn8 = [SCGIFButtonView buttonWithType:UIButtonTypeCustom];
        self.photoIamgeBtn8.backgroundColor = [UIColor groupTableViewBackgroundColor];
        [self.photoIamgeBtn8 addTarget:self action:@selector(photoBtnClicked8:) forControlEvents:UIControlEventTouchUpInside];
        [self.contentView addSubview:self.photoIamgeBtn8];
        [self.photoIamgeBtn8 mas_makeConstraints:^(MASConstraintMaker *make) {
            make.width.mas_equalTo(95);
            make.height.mas_equalTo(95);
            make.top.equalTo(weakSelf.photoIamgeBtn7.mas_top).with.offset(0);
            make.left.equalTo(weakSelf.photoIamgeBtn7.mas_right).with.offset(15);
        }];
        self.photoDeleteBtn8 = [UIButton getCustomImgBtnWithImageStr:@"update_delete_icon" WithSelectedImageStr:nil];
        [self.photoDeleteBtn8 addTarget:self action:@selector(photoDeleteBtnClicked8:) forControlEvents:UIControlEventTouchUpInside];
        [self.contentView addSubview:self.photoDeleteBtn8];
        [self.photoDeleteBtn8 mas_makeConstraints:^(MASConstraintMaker *make) {
            make.width.mas_equalTo(22);
            make.height.mas_equalTo(22);
            make.top.equalTo(weakSelf.photoIamgeBtn8.mas_top).with.offset(0);
            make.right.equalTo(weakSelf.photoIamgeBtn8.mas_right).with.offset(0);
        }];
    }
    return self;
}

#pragma mark - --------------SomePrepare--------------

#pragma mark - --------------UIConfig----------------------
-(void)updateParamInfo:(YYTableViewCellInfoModel *)info{
    YYTableViewCellInfoModel *infoModel = info;
    _updateTipLabel.text = infoModel.tipStr;
    self.maxPhotoNum = [infoModel.warnStr integerValue];
}

-(void)updateCellInfo:(NSArray *)info{
    NSInteger imgnum = [info count];
    SCGIFButtonView *imageBtn = nil;
    UIButton *deleteBtn = nil;
    
    if(self.itemWidth == 0 ){
        self.itemWidth = (SCREEN_WIDTH - 17*2 -15*2)/3;
        
        [_photoImageTipView setConstraintConstant:self.itemWidth forAttribute:NSLayoutAttributeHeight];
        [_photoImageTipView setConstraintConstant:self.itemWidth forAttribute:NSLayoutAttributeWidth];
        for (int i =0; i<8; i++) {
            imageBtn = [self valueForKey:[NSString stringWithFormat:@"photoIamgeBtn%d",(i+1)]];
            [imageBtn setConstraintConstant:self.itemWidth forAttribute:NSLayoutAttributeHeight];
            [imageBtn setConstraintConstant:self.itemWidth forAttribute:NSLayoutAttributeWidth];
        }
    }
    _photoImageTipView.hidden = YES;
    NSInteger tipViewWidth = self.itemWidth;
    NSInteger tipViewHeight = self.itemWidth;
    NSInteger itemspace = 15; //top 15 left 17
    for (int i =0; i<8; i++) {
        imageBtn = [self valueForKey:[NSString stringWithFormat:@"photoIamgeBtn%d",(i+1)]];
        deleteBtn = [self valueForKey:[NSString stringWithFormat:@"photoDeleteBtn%d",(i+1)]];
        imageBtn.hidden = NO;
        deleteBtn.hidden = NO;
        imageBtn.imageView.contentMode = UIViewContentModeScaleAspectFit;
        if(i == imgnum ){
            if(imgnum >= self.maxPhotoNum ){
                imageBtn.hidden = YES;
                deleteBtn.hidden = YES;
                _photoImageTipView.hidden = YES;
            }else{
                imageBtn.hidden = NO;
                [imageBtn setImage:nil forState:UIControlStateNormal];
                deleteBtn.hidden = YES;
                _photoImageTipView.hidden = NO;
            }
            [self.photoImageTipView mas_updateConstraints:^(MASConstraintMaker *make) {
                make.top.mas_equalTo(15 +(i/3)*(tipViewHeight+itemspace));
                make.left.mas_equalTo(17 + (i%3)*(tipViewWidth+itemspace));
            }];
            [super updateConstraints];
            [self.contentView bringSubviewToFront:self.photoImageTipView];
        }else if(i < imgnum){
            if([[info objectAtIndex:i] isKindOfClass:[UIImage class]]){
                [imageBtn setImage:[info objectAtIndex:i] forState:UIControlStateNormal];
            }else{
                NSString *imageRelativePath=[info objectAtIndex:i];
                sd_downloadWebImageWithRelativePath(NO, imageRelativePath, imageBtn,kLookBookImage, 0);
            }
            
        }else{
            imageBtn.hidden = YES;
            deleteBtn.hidden = YES;
            [imageBtn setImage:nil forState:UIControlStateNormal];
        }
    }
    
}

#pragma mark - --------------请求数据----------------------

#pragma mark - --------------系统代理----------------------


#pragma mark - --------------自定义代理/block----------------------


#pragma mark - --------------自定义响应----------------------
- (void)photoBtnClicked1:(id)sender{
    if(_photoDeleteBtn1.hidden == NO){
        return;
    }
    UIViewController *parent = [UIApplication sharedApplication].keyWindow.rootViewController;
    CGPoint point = [self.photoIamgeBtn1 convertPoint:CGPointMake(CGRectGetWidth(self.photoIamgeBtn1.frame), CGRectGetHeight(self.photoIamgeBtn1.frame)/2) toView:parent.view];
    [self.delegate upLoadPhotoImage:1 pointX:point.x pointY:point.y];
}

- (void)photoBtnClicked2:(id)sender{
    if(_photoDeleteBtn2.hidden == NO){
        return;
    }
    UIViewController *parent = [UIApplication sharedApplication].keyWindow.rootViewController;
    CGPoint point = [self.photoIamgeBtn2 convertPoint:CGPointMake(CGRectGetWidth(self.photoIamgeBtn1.frame), CGRectGetHeight(self.photoIamgeBtn1.frame)/2) toView:parent.view];
    [self.delegate upLoadPhotoImage:2 pointX:point.x pointY:point.y];
}

- (void)photoBtnClicked3:(id)sender{
    if(_photoDeleteBtn3.hidden == NO){
        return;
    }
    UIViewController *parent = [UIApplication sharedApplication].keyWindow.rootViewController;
    CGPoint point = [self.photoIamgeBtn3 convertPoint:CGPointMake(CGRectGetWidth(self.photoIamgeBtn1.frame), CGRectGetHeight(self.photoIamgeBtn1.frame)/2) toView:parent.view];
    [self.delegate upLoadPhotoImage:3 pointX:point.x pointY:point.y];
}
- (void)photoBtnClicked4:(id)sender{
    if(_photoDeleteBtn4.hidden == NO){
        return;
    }
    UIViewController *parent = [UIApplication sharedApplication].keyWindow.rootViewController;
    CGPoint point = [self.photoIamgeBtn4 convertPoint:CGPointMake(CGRectGetWidth(self.photoIamgeBtn1.frame), CGRectGetHeight(self.photoIamgeBtn1.frame)/2) toView:parent.view];
    [self.delegate upLoadPhotoImage:4 pointX:point.x pointY:point.y];
}

- (void)photoBtnClicked5:(id)sender{
    if(_photoDeleteBtn5.hidden == NO){
        return;
    }
    UIViewController *parent = [UIApplication sharedApplication].keyWindow.rootViewController;
    CGPoint point = [self.photoIamgeBtn5 convertPoint:CGPointMake(CGRectGetWidth(self.photoIamgeBtn1.frame), CGRectGetHeight(self.photoIamgeBtn1.frame)/2) toView:parent.view];
    [self.delegate upLoadPhotoImage:5 pointX:point.x pointY:point.y];
}

- (void)photoBtnClicked6:(id)sender{
    if(_photoDeleteBtn6.hidden == NO){
        return;
    }
    UIViewController *parent = [UIApplication sharedApplication].keyWindow.rootViewController;
    CGPoint point = [self.photoIamgeBtn6 convertPoint:CGPointMake(CGRectGetWidth(self.photoIamgeBtn1.frame), CGRectGetHeight(self.photoIamgeBtn1.frame)/2) toView:parent.view];
    [self.delegate upLoadPhotoImage:6 pointX:point.x pointY:point.y];
}
- (void)photoBtnClicked7:(id)sender{
    if(_photoDeleteBtn7.hidden == NO){
        return;
    }
    UIViewController *parent = [UIApplication sharedApplication].keyWindow.rootViewController;
    CGPoint point = [self.photoIamgeBtn7 convertPoint:CGPointMake(CGRectGetWidth(self.photoIamgeBtn1.frame), CGRectGetHeight(self.photoIamgeBtn1.frame)/2) toView:parent.view];
    [self.delegate upLoadPhotoImage:7 pointX:point.x pointY:point.y];
}

- (void)photoBtnClicked8:(id)sender{
    if(_photoDeleteBtn8.hidden == NO){
        return;
    }
    UIViewController *parent = [UIApplication sharedApplication].keyWindow.rootViewController;
    CGPoint point = [self.photoIamgeBtn8 convertPoint:CGPointMake(CGRectGetWidth(self.photoIamgeBtn1.frame), CGRectGetHeight(self.photoIamgeBtn1.frame)/2) toView:parent.view];
    [self.delegate upLoadPhotoImage:8 pointX:point.x pointY:point.y];
}

- (void)photoDeleteBtnClicked1:(id)sender{
    [self.delegate upLoadPhotoImage:1 pointX:-1 pointY:-1];
}
- (void)photoDeleteBtnClicked2:(id)sender{
    [self.delegate upLoadPhotoImage:2 pointX:-1 pointY:-1];
}
- (void)photoDeleteBtnClicked3:(id)sender{
    [self.delegate upLoadPhotoImage:3 pointX:-1 pointY:-1];
}
- (void)photoDeleteBtnClicked4:(id)sender{
    [self.delegate upLoadPhotoImage:4 pointX:-1 pointY:-1];
}
- (void)photoDeleteBtnClicked5:(id)sender{
    [self.delegate upLoadPhotoImage:5 pointX:-1 pointY:-1];
}
- (void)photoDeleteBtnClicked6:(id)sender{
    [self.delegate upLoadPhotoImage:6 pointX:-1 pointY:-1];
}
- (void)photoDeleteBtnClicked7:(id)sender{
    [self.delegate upLoadPhotoImage:7 pointX:-1 pointY:-1];
}
- (void)photoDeleteBtnClicked8:(id)sender{
    [self.delegate upLoadPhotoImage:8 pointX:-1 pointY:-1];
}

#pragma mark - --------------自定义方法----------------------


#pragma mark - --------------other----------------------
+(float)cellHeight:(NSInteger)count{
    NSInteger itemWidth = (SCREEN_WIDTH - 17*2 -15*2)/3; //top 15 bottom 39
    
    return (15 + itemWidth)*((count/3)+1) +20;
}

@end
