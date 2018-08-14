//
//  YYVisibleAuditPickerViewController.m
//  parking
//
//  Created by chjsun on 2017/2/10.
//  Copyright © 2017年 chjsun. All rights reserved.
//

#import "YYVisibleAuditPickerViewController.h"

@interface YYVisibleAuditPickerViewController ()<UIPickerViewDelegate, UIPickerViewDataSource>
/** 选择器 */
@property(nonatomic, strong) UIPickerView *datePicker;

/** 选择图 */
@property(nonatomic, strong) UIView *allView;
/** 背景图 */
@property(nonatomic, strong) UIView *backgroundView;

/** 选中的编号 */
@property (nonatomic, assign) NSInteger index;
/** 选中的内容 */
@property (nonatomic, copy) NSString *content;

@end

#define pickerHeight 250

@implementation YYVisibleAuditPickerViewController

#pragma mark - 生命周期
- (void)viewDidLoad {
    [super viewDidLoad];

    // 创建子类
    [self initSubView];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];

}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    // 显示动画
    [self showCustomAnimation];
}

#pragma mark - 系统代理
-(NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView{
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component{
    return self.data.count;
}

//- (CGFloat)pickerView:(UIPickerView *)pickerView rowHeightForComponent:(NSInteger)component{
//    return 44;
//}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component{

    return self.data[row];
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component{
    self.index = row;
    self.content = self.data[row];
}


#pragma mark - 自定义代理
- (void)okButtonClick{

    if ([self.delegate respondsToSelector:@selector(YYVisibleAuditPickerViewController:index:content:)]) {
        [self.delegate YYVisibleAuditPickerViewController:self index:self.index content:self.content];
    }

    [self cancelButtonClick];
}


#pragma mark - 自定义响应
// 退出
- (void)cancelButtonClick{
    // 先隐藏
    CGFloat height = [UIScreen mainScreen].bounds.size.height;
    CGRect frame = self.allView.frame;
    frame.origin.y = height;
    self.allView.frame = frame;
    // 设置弹出的动画， 从上向下
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"position.y"];
    animation.fromValue = [NSNumber numberWithFloat: (height - 97.5)];
    animation.toValue = [NSNumber numberWithFloat:(height + 97.5)];
    animation.duration = 0.3;

    animation.removedOnCompletion = NO;
    animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];

    [self.allView.layer addAnimation:animation forKey:@"position.y"];

    // 消失
    [UIView animateWithDuration:0.3 animations:^{
        self.view.backgroundColor = [UIColor clearColor];
    } completion:^(BOOL finished) {
        [self dismissViewControllerAnimated:NO completion:nil];
    }];
}


#pragma mark - 自定义方法
// 自定义动画
- (void)showCustomAnimation{
    // 设置弹出的动画， 从上向下
    [UIView animateWithDuration:0.3 animations:^{
        self.view.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.5];

        // 先隐藏
        CGFloat height = [UIScreen mainScreen].bounds.size.height;
        CGRect frame = self.allView.frame;
        frame.origin.y = height - pickerHeight;
        self.allView.frame = frame;

    }];
}

#pragma mark - get/set
- (void)setData:(NSArray *)data{
    _data = data;
    // 设置默认值，默认第一条
    if (data) {
        self.index = 0;
        self.content = data[0];
    }
}

#pragma mark - UI
- (void)initSubView{
    CGRect bounds = [UIScreen mainScreen].bounds;
    // 设置背景
    UIView *backgroundView = [[UIView alloc] initWithFrame:bounds];
    [self.view addSubview:backgroundView];

    self.backgroundView = backgroundView;
    // 设置显示背后的视图
    if([[[UIDevice currentDevice] systemVersion] floatValue]>=8.0) {
        self.modalPresentationStyle = UIModalPresentationOverCurrentContext;
    }else{
        self.modalPresentationStyle = UIModalPresentationCurrentContext;
    }
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(cancelButtonClick)];
    [backgroundView addGestureRecognizer:tap];

    UIView *allView = [[UIView alloc] initWithFrame:CGRectMake(0, bounds.size.height, bounds.size.width, pickerHeight)];
    self.allView = allView;
    allView.backgroundColor = [UIColor greenColor];
    [self.view addSubview:allView];


    // 选择头的背景
    UIView *selectViewBg = [[UIView alloc] init];// WithFrame:CGRectMake(0, HEIGHT - 210, WIDTH, 44)
    selectViewBg.backgroundColor = [UIColor whiteColor];
    [allView addSubview:selectViewBg];

    [selectViewBg mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(0);
        make.left.mas_equalTo(0);
        make.right.mas_equalTo(0);
        make.height.mas_equalTo(40);
    }];
    //  取消
    UIButton *cancelButton = [[UIButton alloc] init];
    [cancelButton setTitle:NSLocalizedString(@"取消", nil) forState:UIControlStateNormal];
    [cancelButton setTitleColor:_define_black_color forState:UIControlStateNormal];
    [cancelButton addTarget:self action:@selector(cancelButtonClick) forControlEvents:UIControlEventTouchUpInside];
    cancelButton.titleLabel.font = [UIFont systemFontOfSize:15];
    [selectViewBg addSubview:cancelButton];

    [cancelButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(20);
        make.centerY.mas_equalTo(selectViewBg.mas_centerY);
        make.height.mas_equalTo(40);
        make.width.mas_equalTo(100);
    }];

    //  确定
    UIButton *okButton = [[UIButton alloc] init];
    [okButton setTitle:NSLocalizedString(@"确定", nil) forState:UIControlStateNormal];
    [okButton setTitleColor:_define_black_color forState:UIControlStateNormal];
    [okButton addTarget:self action:@selector(okButtonClick) forControlEvents:UIControlEventTouchUpInside];
    okButton.titleLabel.font = [UIFont systemFontOfSize:15];
    [selectViewBg addSubview:okButton];

    [okButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(-20);
        make.centerY.mas_equalTo(selectViewBg.mas_centerY);
        make.height.mas_equalTo(40);
        make.width.mas_equalTo(100);
    }];

    // 选择器
    UIPickerView *picker = [[UIPickerView alloc] init];//WithFrame:CGRectMake(0, HEIGHT - 166, WIDTH, 166)];
    self.datePicker = picker;
    picker.delegate = self;
    picker.dataSource = self;
    picker.backgroundColor = [UIColor groupTableViewBackgroundColor];

    [allView addSubview:picker];

    [picker mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(0);
        make.right.mas_equalTo(0);
        make.bottom.mas_equalTo(0);
        make.height.mas_equalTo(210);
    }];
}

@end
