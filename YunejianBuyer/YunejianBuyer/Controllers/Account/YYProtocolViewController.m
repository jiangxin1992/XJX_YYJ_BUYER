//
//  YYProtocolViewController.m
//  yunejianDesigner
//
//  Created by Apple on 16/11/15.
//  Copyright © 2016年 Apple. All rights reserved.
//

// c文件 —> 系统文件（c文件在前）

// 控制器
#import "YYProtocolViewController.h"

// 自定义视图
#import "YYNavView.h"
#import "YYBaseWebView.h"

// 接口

// 分类

// 自定义类和三方类（ cocoapods类 > model > 工具类 > 其他）

@interface YYProtocolViewController ()
@property (weak, nonatomic) IBOutlet UIView *containerView;
@property (weak, nonatomic) IBOutlet YYBaseWebView *webView;

@property (nonatomic, strong) YYNavView *navView;

@end

@implementation YYProtocolViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self SomePrepare];
    [self LoadingWebview];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    // 进入埋点
    [MobClick beginLogPageView:kYYPageProtocolAgreement];
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    // 退出埋点
    [MobClick endLogPageView:kYYPageProtocolAgreement];
}

#pragma mark - SomePrepare
-(void)SomePrepare
{
    [self PrepareData];
    [self PrepareUI];
}

-(void)PrepareData{}

-(void)PrepareUI {
    self.navView = [[YYNavView alloc] initWithTitle:_nowTitle WithSuperView:self.view haveStatusView:YES];
    WeakSelf(ws);
    self.navView.goBackBlock = ^{
        [ws goBack];
    };
    
    _webView.backgroundColor = _define_white_color;
}

#pragma mark - SomeAction
- (void)goBack {
    [self cancelClicked:nil];
}

- (IBAction)cancelClicked:(id)sender{
    if (_cancelButtonClicked) {
        _cancelButtonClicked();
    }
}
-(void)LoadingWebview{
    //    隐私权保护声明 secrecyAgreement/ 服务协议 serviceAgreement
    NSString *url = nil;
    if([_protocolType isEqualToString:@"secrecyAgreement"])
    {
        if([LanguageManager isEnglishLanguage]){
            url = @"http://cdn2.ycosystem.com/yej-tb/static/secrecyAgreement_en.html";
        }else{
            url = @"https://scdn2.ycosystem.com/yej-tb/static/secrecyAgreement.html";
        }
        
    }else if([_protocolType isEqualToString:@"serviceAgreement"])
    {
        if([LanguageManager isEnglishLanguage]){
            url = @"http://cdn2.ycosystem.com/yej-tb/static/serviceAgreement_en.html";
        }else{
            url = @"https://scdn2.ycosystem.com/yej-tb/static/serviceAgreement.html";
        }
    }
    if(![NSString isNilOrEmpty:url])
    {
        _webView.urlString = url;
    }
}

#pragma mark - Other

@end
