//
//  YYHelpViewController.m
//  Yunejian
//
//  Created by yyj on 15/7/12.
//  Copyright (c) 2015年 yyj. All rights reserved.
//


// c文件 —> 系统文件（c文件在前）

// 控制器
#import "YYHelpViewController.h"

// 自定义视图
#import "YYNavView.h"
#import "YYBaseWebView.h"

// 接口

// 分类

// 自定义类和三方类（ cocoapods类 > model > 工具类 > 其他）

@interface YYHelpViewController()

@property (weak, nonatomic) IBOutlet YYBaseWebView *webView;
@property (weak, nonatomic) IBOutlet UIView *containerView;

@property (nonatomic, strong) YYNavView *navView;

@end

@implementation YYHelpViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    WeakSelf(ws);
    self.navView = [[YYNavView alloc] initWithTitle:IsPhone6_gt?NSLocalizedString(@"帮助中心•买手店",nil):NSLocalizedString(@"帮助中心",nil) WithSuperView:self.view haveStatusView:YES];
    [self.navView setBackButtonTitle:NSLocalizedString(@"返回",nil)];
    self.navView.goBackBlock = ^{
        [ws goBack];
    };
    
    popWindowAddBgView(self.view);
    
    NSString *_weburl = @"";
    NSString *_kLastYYServerURL = [[NSUserDefaults standardUserDefaults] objectForKey:kLastYYServerURL];
    //字条串是否包含有某字符串
    if ([_kLastYYServerURL containsString:@"show.ycofoundation.com"]) {
        //展示
        _weburl = @"http://mshow.ycosystem.com/helpCenter?user=1&noTitle=true";
    }else if ([_kLastYYServerURL containsString:@"test.ycosystem.com"]){
        //测试
        _weburl = @"http://mt.ycosystem.com/helpCenter?user=1&noTitle=true";
    }else if ([_kLastYYServerURL containsString:@"ycosystem.com"]){
        //生产
        _weburl = @"http://m.ycosystem.com/helpCenter?user=1&noTitle=true";
    }
    if([LanguageManager isEnglishLanguage]){
        _weburl = [[NSString alloc] initWithFormat:@"%@&lang=en",_weburl];
    }
    self.webView.urlString = _weburl;
    [self.webView setJumpPageSuccess:nil];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    // 进入埋点
    [MobClick beginLogPageView:kYYPageHelp];
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    // 退出埋点
    [MobClick endLogPageView:kYYPageHelp];
}

- (void)goBack {
    if(self.webView.canGoBack){
        [self.webView goBack];
    }else{
        if(self.cancelButtonClicked){
            self.cancelButtonClicked();
        }
    }
}

@end
