//
//  YYVisibleUploadPhotoButton.m
//  YunejianBuyer
//
//  Created by chuanjun sun on 2017/10/27.
//  Copyright © 2017年 Apple. All rights reserved.
//

#import "YYVisibleUploadPhotoButton.h"
// c文件 —> 系统文件（c文件在前）

// 控制器


// 自定义视图
#import "SCGIFButtonView.h"

// 接口


// 分类


// 自定义类和三方类（cocoapods类、model、工具类等） cocoapods类 —> model —> 其他

@interface YYVisibleUploadPhotoButton()

/** 按钮 */
@property (nonatomic, strong) SCGIFButtonView *posterIamge;
/** 文字 */
@property (nonatomic, strong) UILabel *posterTitleLabel;
/** 删除按钮 */
@property (nonatomic, strong) UIButton *deleteButton;



@end

@implementation YYVisibleUploadPhotoButton

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
- (void)upFileButton:(UIButton *)button{
    if ([self.delegate respondsToSelector:@selector(YYVisibleUploadPhotoPosterButton:)]) {
        [self.delegate YYVisibleUploadPhotoPosterButton:self];
    }
}

#pragma mark - 删除图片
- (void)deleteImage:(UIButton *)button{
    if ([self.delegate respondsToSelector:@selector(YYVisibleUploadPhotoDeleteButton:)]) {
        [self.delegate YYVisibleUploadPhotoDeleteButton:self];
    }
}

#pragma mark - --------------自定义方法----------------------
#pragma mark - 可以获取到父容器的控制器的方法,就是这个黑科技.
- (UIViewController *)getController:(UIView *)view{
    UIResponder *responder = view;
    //循环获取下一个响应者,直到响应者是一个UIViewController类的一个对象为止,然后返回该对象.
    while ((responder = [responder nextResponder])) {
        if ([responder isKindOfClass:[UIViewController class]]) {
            return (UIViewController *)responder;
        }
    }
    return [UIApplication sharedApplication].keyWindow.rootViewController;
}

#pragma mark - get/set
//- (void)setIsShowDeleteButton:(BOOL)isShowDeleteButton{
//    _isShowDeleteButton = isShowDeleteButton;
//    [self.deleteButton setHidden:!isShowDeleteButton];
//    [self layoutIfNeeded];
//}

- (void)setImageData:(NSData *)imageData{
    _imageData = imageData;
    if (imageData) {
        [self.posterIamge setImage:[UIImage imageWithData:imageData] forState:UIControlStateNormal];
        [self.deleteButton setHidden:NO];
        [self.posterTitleLabel setHidden:YES];
    }else{
        [self.posterIamge setImage:[UIImage imageNamed:@"photo"] forState:UIControlStateNormal];
        [self.deleteButton setHidden:YES];
        [self.posterTitleLabel setHidden:NO];

    }
}

#pragma mark - --------------UI----------------------
// 创建子控件
- (void)PrepareUI{
    // logo UpFile 1
    SCGIFButtonView *posterIamge = [[SCGIFButtonView alloc] init];
    posterIamge.backgroundColor = [UIColor colorWithHex:@"EFEFEF"];
    self.posterIamge = posterIamge;
    posterIamge.imageView.contentMode = UIViewContentModeScaleAspectFit;
    [posterIamge setImage:[UIImage imageNamed:@"photo"] forState:UIControlStateNormal];

    posterIamge.titleLabel.font = [UIFont systemFontOfSize:12];
    [posterIamge setTitleColor:[UIColor colorWithHex:@"979797"] forState:UIControlStateNormal];
    [posterIamge addTarget:self action:@selector(upFileButton:) forControlEvents:UIControlEventTouchUpInside];
//    posterIamge.imageEdgeInsets =UIEdgeInsetsMake(-15, 0, 0, 0);
    [self addSubview:posterIamge];
    [posterIamge mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.bottom.top.mas_equalTo(0);
    }];

    // 上传海报的说明
    UILabel *posterTitleLabel = [[UILabel alloc] init];
    self.posterTitleLabel = posterTitleLabel;
    posterTitleLabel.font = [UIFont systemFontOfSize:12];
    posterTitleLabel.textColor = [UIColor colorWithHex:@"979797"];
    posterTitleLabel.text = NSLocalizedString(@"上传照片",nil);
    posterTitleLabel.numberOfLines = 0;
    posterTitleLabel.textAlignment = NSTextAlignmentCenter;
    [posterIamge addSubview:posterTitleLabel];

    [posterTitleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(40);
        make.width.mas_equalTo(posterIamge.mas_width);
        make.top.mas_equalTo(posterIamge.mas_centerY);
        make.centerX.mas_equalTo(posterIamge.mas_centerX);
    }];

    // 删除按钮1
    UIButton *deleteButton = [[UIButton alloc] init];
    deleteButton.hidden = YES;
    self.deleteButton = deleteButton;
    [deleteButton addTarget:self action:@selector(deleteImage:) forControlEvents:UIControlEventTouchUpInside];
    [deleteButton setImage:[UIImage imageNamed:@"update_delete_icon"] forState:UIControlStateNormal];

    [self addSubview:deleteButton];
    [deleteButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(posterIamge.mas_top);
        make.right.mas_equalTo(posterIamge.mas_right);
        make.width.mas_equalTo(22);
        make.height.mas_equalTo(22);
    }];
}

#pragma mark - --------------other----------------------

@end
