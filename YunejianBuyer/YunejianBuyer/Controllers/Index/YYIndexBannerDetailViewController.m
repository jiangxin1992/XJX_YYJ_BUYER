//
//  YYIndexBannerDetailViewController.m
//  YunejianBuyer
//
//  Created by yyj on 2017/8/10.
//  Copyright © 2017年 Apple. All rights reserved.
//

#import "YYIndexBannerDetailViewController.h"

// c文件 —> 系统文件（c文件在前）
#import <JavaScriptCore/JavaScriptCore.h>

// 控制器
#import "YYNewsViewController.h"

// 自定义视图
#import "YYNavView.h"

// 接口
#import "YYUserApi.h"
#import "YYOpusApi.h"
#import "YYOrderingApi.h"

// 分类

// 自定义类和三方类（ cocoapods类 > model > 工具类 > 其他）
#import "YYBannerModel.h"
#import "YYSeriesInfoModel.h"
#import "YYSeriesInfoDetailModel.h"
#import "YYBrandHomeInfoModel.h"
#import "YYOpusSeriesModel.h"

#import "AppDelegate.h"
#import "UserDefaultsMacro.h"

@interface YYIndexBannerDetailViewController ()<UIWebViewDelegate>

@property (nonatomic,strong) YYNavView *navView;
@property (nonatomic,strong) UIWebView *webView;

@end

@implementation YYIndexBannerDetailViewController

#pragma mark - --------------生命周期--------------
- (void)viewDidLoad {
    [super viewDidLoad];
    [self SomePrepare];
    [self UIConfig];
}

#pragma mark - --------------SomePrepare--------------
- (void)SomePrepare
{
    [self PrepareData];
    [self PrepareUI];
}
- (void)PrepareData{}
- (void)PrepareUI{
    self.view.backgroundColor = _define_white_color;

    WeakSelf(ws);
    _navView = [[YYNavView alloc] initWithTitle:_bannerModel.title WithSuperView:self.view haveStatusView:YES];
    self.navView.goBackBlock = ^{
        [ws GoBack:nil];
    };

    UIButton *moreBtn = [UIButton getCustomTitleBtnWithAlignment:0 WithFont:16.0f WithSpacing:0 WithNormalTitle:NSLocalizedString(@"更多",nil) WithNormalColor:nil WithSelectedTitle:nil WithSelectedColor:nil];
    [_navView addSubview:moreBtn];
    [moreBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(kStatusBarHeight);
        make.right.mas_equalTo(0);
        make.width.mas_equalTo(50);
        make.bottom.mas_equalTo(-1);
    }];
    [moreBtn addTarget:self action:@selector(moreAction) forControlEvents:UIControlEventTouchUpInside];
}

#pragma mark - --------------UIConfig----------------------
-(void)UIConfig{
    [self CreateWebview];
}
-(void)CreateWebview{

    WeakSelf(ws);

    _webView=[[UIWebView alloc] init];
    [self.view addSubview:_webView];
    [_webView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.bottom.mas_equalTo(0);
        make.top.mas_equalTo(ws.navView.mas_bottom).with.offset(0);
    }];
    if (@available(iOS 11.0, *)) {
        _webView.scrollView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    }
    _webView.backgroundColor = [UIColor clearColor];
    _webView.opaque = NO;
    _webView.dataDetectorTypes = UIDataDetectorTypeNone;
    _webView.delegate = self;
    NSLog(@"link = %@",_bannerModel.link);
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:_bannerModel.link]];
    [_webView loadRequest:request];
}
//#pragma mark - --------------请求数据----------------------
#pragma mark - --------------系统代理----------------------
#pragma mark - UIWebViewDelegate
- (void)webViewDidFinishLoad:(UIWebView *)webView{

    //首先创建JSContext 对象（此处通过当前webView的键获取到jscontext）
    __block JSContext *context = [webView valueForKeyPath:@"documentView.webView.mainFrame.javaScriptContext"];
    //    一，js里面直接调用方法

    //更新标题
    //    NSString *returs = [_webView stringByEvaluatingJavaScriptFromString:@"window._data"];
    //    NSDictionary *_dataInfo = [returs mj_JSONObject];
    //    NSString *titleStr = [_dataInfo objectForKey:@"title"];
    //    [self CreateOrUpdateNavViewWithTitle:titleStr];

    //返回到订货会列表
//    context[@"IOSReturnList"] = ^(){
//        WeakSelf(ws);
//        YYOrderingHistoryListViewController *orderHistoryView = [[YYOrderingHistoryListViewController alloc] init];
//        [orderHistoryView setCancelButtonClicked:^(){
//            [ws.navigationController popViewControllerAnimated:YES];
//        }];
//        [self.navigationController pushViewController:orderHistoryView animated:YES];
//    };

    //跳转设计师主页
    context[@"IOSReturnBrand"] = ^(){
        NSArray *args = [JSContext currentArguments];
        [self PushBrandHomePageViewWithArgs:args];
    };

    //跳转系列详情页面
    context[@"IOSReturnSeries"] = ^(){
        NSArray *args = [JSContext currentArguments];
        [self PushSeriesDetailViewWithArgs:args];
    };

    //导航
//    context[@"IOSNavigationAction"] = ^(){
//        [self navigationAction];
//    };

    //第二种情况，js是通过对象调用的，我们假设js里面有一个对象 testobject 在调用方法
    //    首先创建我们新建类的对象，将他赋值给js的对象
    //    YYOrderingJSObject *testJO=[YYOrderingJSObject new];
    //    context[@"returnMethod"]=testJO;
    //    //同样我们也用刚才的方式模拟一下js调用方法
    //    NSString *jsStr1=@"returnMethod.returnList()";
    //    [context evaluateScript:jsStr1];
    //    NSString *jsStr2=@"returnMethod.returnBrand('参数1')";
    //    [context evaluateScript:jsStr2];
    //    NSLog(@"111");

    context.exceptionHandler = ^(JSContext *context, JSValue *exceptionValue) {
        context.exception = exceptionValue;
        NSLog(@"异常信息：%@", exceptionValue);
    };

    NSHTTPCookieStorage *sharedHTTPCookieStorage = [NSHTTPCookieStorage sharedHTTPCookieStorage];
    NSMutableArray *cookies = (NSMutableArray *)[sharedHTTPCookieStorage cookiesForURL:[NSURL URLWithString:_bannerModel.link]];

    NSString *cookieStr = @"";
    for (NSHTTPCookie *cookie in cookies) {
        NSString *cookieString = [NSString stringWithFormat:@"%@=%@", [cookie name], [cookie value]];
        cookieStr = [cookieStr stringByAppendingString:@" "];
        cookieStr = [cookieStr stringByAppendingString:cookieString];
    }
}
- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {

    //修改cookie
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSString *tokenValue = [userDefaults objectForKey:kUserLoginTokenKey];

    NSHTTPCookie *cookie = [NSHTTPCookie cookieWithProperties:
                            [NSDictionary dictionaryWithObjectsAndKeys:
                             [request.URL host], NSHTTPCookieDomain,
                             [request.URL path], NSHTTPCookiePath,
                             @"token",NSHTTPCookieName,
                             tokenValue,NSHTTPCookieValue,
                             nil]];

    [[NSHTTPCookieStorage sharedHTTPCookieStorage] setCookie:cookie];


    NSURL * _url = [request URL];
    NSString *_query=[_url query];

    if(_query!=nil)
    {
        if ( [_query rangeOfString:@"author_info"].location !=NSNotFound) {
            NSLog(@"111");
            //            [self iconClick];
            return NO;
        }
    }
    return YES;
}
//#pragma mark - --------------自定义代理/block----------------------
#pragma mark - --------------自定义响应----------------------
-(void)GoBack:(id)sender {
    if(_cancelButtonClicked) {
        _cancelButtonClicked();
    }
}
-(void)moreAction{
    WeakSelf(ws);
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"News" bundle:[NSBundle mainBundle]];
    YYNewsViewController *messageViewController = [storyboard instantiateViewControllerWithIdentifier:@"YYNewsViewController"];
    [messageViewController setCancelButtonClicked:^(void){
        [ws.navigationController popViewControllerAnimated:YES];
    }];
    [self.navigationController pushViewController:messageViewController animated:YES];
}

#pragma mark - --------------自定义方法----------------------
//跳转设计师主页
-(void)PushBrandHomePageViewWithArgs:(NSArray *)args{

    NSMutableDictionary *tempDict = [[NSMutableDictionary alloc] init];
    for (int i = 0; i < 3; i ++ ) {
        NSString *value = @"";
        NSString *key = i == 0 ? @"designerId" : i == 1 ? @"brandName" : @"email";
        if(i < args.count){
            NSString *tempValue = [[args objectAtIndex:i] toString];
            value = tempValue;
        }else{
            value = @"";
        }
        [tempDict setObject:value forKey:key];
    }

    if([[tempDict allKeys] count] >= 3){
        //信息全

        [self pushBrandHomePageWithDesignerID:[[tempDict objectForKey:@"designerId"] integerValue]];

    }
}
-(void)pushBrandHomePageWithDesignerID:(NSInteger )designerId{

    [YYUserApi getDesignerHomeInfo:[[NSString alloc] initWithFormat:@"%ld",designerId] andBlock:^(YYRspStatusAndMessage *rspStatusAndMessage, YYBrandHomeInfoModel *infoModel, NSError *error) {
        if(rspStatusAndMessage.status == YYReqStatusCode100){
            AppDelegate *appdelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
            NSString *brandName = infoModel.brandName;
            NSString *logoPath = infoModel.logoPath;
            [appdelegate showBrandInfoViewController:[NSNumber numberWithInteger:designerId] WithBrandName:brandName WithLogoPath:logoPath parentViewController:self WithHomePageBlock:nil WithSelectedValue:nil];
        }
    }];

}
//跳转系列详情页 要先判断权限
-(void)PushSeriesDetailViewWithArgs:(NSArray *)args{

    NSMutableDictionary *tempDict = [[NSMutableDictionary alloc] init];
    for (int i = 0; i < 5; i ++ ) {
        NSString *value = @"";
        NSString *key = i == 0 ? @"designerId" : i == 1 ? @"seriesId" : i == 2 ? @"seriesName" : i == 3 ? @"brandName" : @"email";
        if(i < args.count){
            NSString *tempValue = [[args objectAtIndex:i] toString];
            value = tempValue;
        }else{
            value = @"";
        }
        [tempDict setObject:value forKey:key];
    }

    if([[tempDict allKeys] count] >= 5){

        [YYOpusApi getConnSeriesInfoWithId:[[tempDict objectForKey:@"designerId"] integerValue] seriesId:[[tempDict objectForKey:@"seriesId"] integerValue] andBlock:^(YYRspStatusAndMessage *rspStatusAndMessage, YYSeriesInfoDetailModel *infoDetailModel, NSError *error) {
            if (rspStatusAndMessage.status == YYReqStatusCode100) {

                NSString *brandName = [NSString isNilOrEmpty:infoDetailModel.series.designerBrandName]?@"":infoDetailModel.series.designerBrandName;
                NSString *brandLogo = [NSString isNilOrEmpty:infoDetailModel.series.designerBrandLogo]?@"":infoDetailModel.series.designerBrandLogo;
                AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
                [appDelegate showSeriesInfoViewController:infoDetailModel.series.designerId seriesId:infoDetailModel.series.id designerInfo:@[brandName,brandLogo] parentViewController:self];

            }
        }];

    }
}
#pragma mark - --------------other----------------------

@end
