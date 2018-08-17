//
//  YYNewsDetailViewController.m
//  yunejianDesigner
//
//  Created by Apple on 16/9/7.
//  Copyright © 2016年 Apple. All rights reserved.
//


// c文件 —> 系统文件（c文件在前）

// 控制器
#import "YYNewsDetailViewController.h"

// 自定义视图
#import "YYNavView.h"
#import "YYBaseWebView.h"

// 接口

// 分类

// 自定义类和三方类（ cocoapods类 > model > 工具类 > 其他）

@interface YYNewsDetailViewController ()

@property (weak, nonatomic) IBOutlet UIView *containerView;
@property (weak, nonatomic) IBOutlet YYBaseWebView *webView;

@property (nonatomic, strong) YYNavView *navView;

@end

@implementation YYNewsDetailViewController
#pragma mark - --------------生命周期--------------
- (void)viewDidLoad {
    [super viewDidLoad];
    [self SomePrepare];
    [self UIConfig];
    [self RequestData];
}

#pragma mark - --------------SomePrepare--------------
- (void)SomePrepare
{
    [self PrepareData];
    [self PrepareUI];
}
- (void)PrepareData{}
- (void)PrepareUI{
    [self createNavView];
    _webView.backgroundColor = [UIColor whiteColor];
    _webView.frame = CGRectMake(0, 65, SCREEN_WIDTH, SCREEN_HEIGHT-65);
    _webView.urlString =_newsUrlString;
}

#pragma mark - --------------UIConfig----------------------
-(void)UIConfig{}
-(void)createNavView{
    self.navView = [[YYNavView alloc] initWithTitle:NSLocalizedString(@"YCO新闻",nil) WithSuperView:self.view haveStatusView:YES];
    WeakSelf(ws);
    self.navView.goBackBlock = ^{
        [ws goBack];
    };
}
- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    // 进入埋点
    [MobClick beginLogPageView:kYYNewsDetail];
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    // 退出埋点
    [MobClick endLogPageView:kYYNewsDetail];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}
#pragma mark - --------------请求数据----------------------
-(void)RequestData{}

#pragma mark - --------------系统代理----------------------


#pragma mark - --------------自定义代理/block----------------------


#pragma mark - --------------自定义响应----------------------
- (void)goBack {
    if(self.cancelButtonClicked){
        self.cancelButtonClicked();
    }
}

#pragma mark - --------------自定义方法----------------------

#pragma mark - --------------other----------------------

@end
