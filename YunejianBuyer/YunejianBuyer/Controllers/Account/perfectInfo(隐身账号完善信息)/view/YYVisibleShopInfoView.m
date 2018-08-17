//
//  YYVisibleShopInfoView.m
//  YunejianBuyer
//
//  Created by chuanjun sun on 2017/10/27.
//  Copyright © 2017年 Apple. All rights reserved.
//

#import "YYVisibleShopInfoView.h"
// c文件 —> 系统文件（c文件在前）

// 控制器


// 自定义视图
#import "YYVisibleUploadPhotoButton.h"
#import "XXTextView.h"

// 接口


// 分类


// 自定义类和三方类（cocoapods类、model、工具类等） cocoapods类 —> model —> 其他


#define MY_MAX 300

@interface YYVisibleShopInfoView()<UITextViewDelegate, YYVisibleUploadPhotoButtonDelegate>

/** 输入view */
@property (nonatomic, strong) XXTextView *introduceTextView;
/** 文本字数提示 */
@property (nonatomic, strong) UILabel *descNumberDescLabel;

/** 图片按钮集合 */
@property (nonatomic, strong) NSMutableArray *photoButtonArray;

@end

@implementation YYVisibleShopInfoView

#pragma mark - --------------生命周期--------------

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.photoDataArray = [NSMutableArray array];
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
#pragma mark - uitextview
- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text{

    NSInteger number = MY_MAX - (textView.text.length - range.length + text.length);
    self.descNumberDescLabel.text = [[NSString alloc] initWithFormat:NSLocalizedString(@"还可输入 %@ 字",nil), [NSNumber numberWithInteger:number]];

    if ((textView.text.length - range.length + text.length) > MY_MAX){
        self.descNumberDescLabel.text = [[NSString alloc] initWithFormat:NSLocalizedString(@"还可输入 %@ 字",nil), [NSNumber numberWithInteger:0]];
        return NO;

    }else{
        return YES;
    }
}

- (void)textViewDidChange:(UITextView *)textView{
    if ([self.delegate respondsToSelector:@selector(YYVisibleShopInfoViewDescContent:content:)]) {
        [self.delegate YYVisibleShopInfoViewDescContent:self content:textView.text];
    }
}

#pragma mark - --------------自定义代理/block----------------------
#pragma mark - 按钮
// 拍照
- (void)YYVisibleUploadPhotoPosterButton:(YYVisibleUploadPhotoButton *)button{
    if ([self.delegate respondsToSelector:@selector(YYVisibleShopInfoViewPosterImage:Button:)]) {
        [self.delegate YYVisibleShopInfoViewPosterImage:self Button:button];
    }
}

// 删除
- (void)YYVisibleUploadPhotoDeleteButton:(YYVisibleUploadPhotoButton *)button{
    if ([self.delegate respondsToSelector:@selector(YYVisibleShopInfoViewDeleteImage:Button:)]) {
        [self.delegate YYVisibleShopInfoViewDeleteImage:self Button:button];
    }

    [self deletePhotoButtonWithTag:button.tag];

}

#pragma mark - --------------自定义响应----------------------


#pragma mark - --------------自定义方法----------------------

- (void)showNextPhotoButtonWithTag:(NSInteger)tag imageData:(NSData *)data{
    // 8个，第八个不处理
    [self.photoDataArray addObject:data];
    if (tag>=0 && tag<7) {
        YYVisibleUploadPhotoButton *nextPhotoButton = (YYVisibleUploadPhotoButton *)self.photoButtonArray[tag+1];
        nextPhotoButton.hidden = NO;
    }

    if (tag>=0 && tag<=7) {
        YYVisibleUploadPhotoButton *uploadPhotoButton = (YYVisibleUploadPhotoButton *)self.photoButtonArray[tag];
        uploadPhotoButton.imageData = data;
    }

    [self layoutIfNeeded];

}

- (void)deletePhotoButtonWithTag:(NSInteger)tag{
    [self.photoDataArray removeObjectAtIndex:tag];
    NSInteger dataCount = self.photoDataArray.count;
    NSInteger buttonCount = self.photoButtonArray.count;
    for (int x = 0; x < dataCount; x++) {
        YYVisibleUploadPhotoButton *nextPhotoButton = (YYVisibleUploadPhotoButton *)self.photoButtonArray[x];
        nextPhotoButton.hidden = NO;
        nextPhotoButton.imageData = self.photoDataArray[x];
    }

    if (dataCount>=0 && dataCount<=7) {
        YYVisibleUploadPhotoButton *nextPhotoButton = (YYVisibleUploadPhotoButton *)self.photoButtonArray[dataCount];
        nextPhotoButton.imageData = nil;
        nextPhotoButton.hidden = NO;
    }

    // 多余的隐藏
    for (NSInteger x = dataCount+1; x<buttonCount; x++) {
        YYVisibleUploadPhotoButton *nextPhotoButton = (YYVisibleUploadPhotoButton *)self.photoButtonArray[x];
        nextPhotoButton.imageData = nil;
        nextPhotoButton.hidden = YES;
    }
}

#pragma mark - --------------UI----------------------
// 创建子控件
- (void)PrepareUI{
    self.backgroundColor = _define_white_color;

    UILabel *descLabel = [[UILabel alloc] init];
    descLabel.text = NSLocalizedString(@"*买手店简介", nil);
    descLabel.textColor = _define_black_color;
    descLabel.font = [UIFont systemFontOfSize:15];
    [self addSubview:descLabel];

    [descLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(13.5);
        make.top.mas_equalTo(15);
    }];

    [descLabel sizeToFit];

    // 品牌简介
    XXTextView *introduceTextView = [[XXTextView alloc] init];
    introduceTextView.xx_placeholderFont = [UIFont systemFontOfSize:15];
    introduceTextView.font = [UIFont systemFontOfSize:15];
    introduceTextView.textColor = [UIColor colorWithHex:kDefaultTitleColor_pad];
    introduceTextView.xx_placeholderColor = [UIColor colorWithHex:@"d3d3d3"];
    introduceTextView.xx_placeholder = NSLocalizedString(@"请输入买手店简介",nil);
    introduceTextView.textContainerInset = UIEdgeInsetsMake(8.0f, 6.0f, 8.0f, 6.0f);
    introduceTextView.layer.borderWidth = 1;
    introduceTextView.layer.borderColor = [UIColor colorWithHex:kDefaultBorderColor].CGColor;
    introduceTextView.layer.masksToBounds = YES;
    introduceTextView.layer.cornerRadius = 2;
    introduceTextView.delegate = self;
    self.introduceTextView = introduceTextView;

    [self addSubview:introduceTextView];

    [introduceTextView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(13.5);
        make.top.mas_equalTo(descLabel.mas_bottom).offset(15);
        make.right.mas_equalTo(-13.5);
        make.height.mas_equalTo(103);
    }];

    // 品牌简介字数限制提示
    UILabel *descNumberDescLabel = [UILabel getLabelWithAlignment:1 WithTitle:@"" WithFont:12 WithTextColor:[UIColor colorWithHex:@"919191"] WithSpacing:0];

    descNumberDescLabel.text = [[NSString alloc] initWithFormat:NSLocalizedString(@"还可输入 %@ 字",nil), @MY_MAX];
    self.descNumberDescLabel = descNumberDescLabel;
    [self addSubview:descNumberDescLabel];

    [descNumberDescLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(introduceTextView.mas_left);
        make.top.mas_equalTo(introduceTextView.mas_bottom).mas_offset(7);
    }];


    UILabel *photoLabel = [[UILabel alloc] init];
    photoLabel.text = NSLocalizedString(@"*买手店照片", nil);
    photoLabel.textColor = _define_black_color;
    photoLabel.font = [UIFont systemFontOfSize:15];
    [self addSubview:photoLabel];

    [photoLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(13.5);
        make.top.mas_equalTo(descNumberDescLabel.mas_bottom).mas_offset(25);
    }];

    [descLabel sizeToFit];


    CGFloat buttonW = ([UIScreen mainScreen].bounds.size.width - 52)/3;
    self.photoButtonArray = [NSMutableArray array];

    for (int x=0; x<8; x++) {
        YYVisibleUploadPhotoButton *uploadPhotoButton = [[YYVisibleUploadPhotoButton alloc] init];
        uploadPhotoButton.tag = x;
        uploadPhotoButton.hidden = YES;
        uploadPhotoButton.delegate = self;
        [self.photoButtonArray addObject:uploadPhotoButton];
        [self addSubview:uploadPhotoButton];

        [uploadPhotoButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(photoLabel.mas_bottom).mas_offset(20 + (13 + buttonW) * (x/3));
            make.left.mas_equalTo(self.mas_left).mas_offset(13.5 + (13 + buttonW) * (x%3));
            make.width.mas_equalTo(buttonW);
            make.height.mas_equalTo(buttonW);
        }];
    }

    YYVisibleUploadPhotoButton *uploadPhotoButton = (YYVisibleUploadPhotoButton *)self.photoButtonArray[0];
    uploadPhotoButton.hidden = NO;


}

#pragma mark - --------------other----------------------
@end
