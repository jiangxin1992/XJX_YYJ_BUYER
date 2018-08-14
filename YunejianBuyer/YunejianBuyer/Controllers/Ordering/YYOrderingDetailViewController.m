//
//  YYOrderingDetailViewController.m
//  YunejianBuyer
//
//  Created by yyj on 2017/6/1.
//  Copyright © 2017年 Apple. All rights reserved.
//
//- (JSValue *)callWithArguments:(NSArray *)arguments;回调js的方法
//- (JSValue *)evaluateScript:(NSString *)script;//通过oc方法调用js的方法
//id obj = [[context evaluateScript:@"returnList()"] toObject];
//
//- (nullable NSString *)stringByEvaluatingJavaScriptFromString:(NSString *)script;//通过oc方法调用js的方法
//id returs = [_webView stringByEvaluatingJavaScriptFromString:@"returnList()"];
//id returs = [_webView stringByEvaluatingJavaScriptFromString:@"window._data"];
//
//回调
//context[@"returnList"] = ^(){
//    NSArray *args = [JSContext currentArguments];
//    for (id obj in args) {
//        NSString *tempstr = [obj toString];
//        NSLog(@"tempstr=%@",tempstr);
//    }
//};
//
//document.title h5标题
//window.location.href 网址
//window._data data，公有数据


#import "YYOrderingDetailViewController.h"

// c文件 —> 系统文件（c文件在前）
#import <MapKit/MapKit.h>
#import <WebKit/WebKit.h>
#import <CoreLocation/CoreLocation.h>
#import <JavaScriptCore/JavaScriptCore.h>

// 控制器
#import "YYOrderingHistoryListViewController.h"

// 自定义视图
#import "YYNavView.h"
#import "YYShareView.h"
#import "MBProgressHUD.h"

// 接口
#import "YYUserApi.h"
#import "YYOrderingApi.h"

// 分类
#import "UIView+MJExtension.h"
#import "UIButton+Custom.h"

// 自定义类和三方类（ cocoapods类 > model > 工具类 > 其他）
#import "MJExtension.h"
#import "SDWebImageManager.h"
#import <ShareSDK/ShareSDK.h>

#import "YYUser.h"
#import "YYOpusApi.h"
#import "YYSeriesInfoModel.h"
#import "YYBrandHomeInfoModel.h"
#import "YYOpusSeriesModel.h"
#import "YYSeriesInfoDetailModel.h"

#import "regular.h"
#import "AppDelegate.h"
#import "YYOrderingJSObject.h"
#import "UserDefaultsMacro.h"

@interface YYOrderingDetailViewController ()<UIWebViewDelegate>

@property (nonatomic ,strong) YYNavView *navView;

@property (nonatomic,strong) UIWebView *webView;

@property (nonatomic,strong) YYShareView *shareView;

@property (nonatomic,strong) UIImageView *mengban;

@property (nonatomic,strong) NSString *weburl;

@property (nonatomic,strong) NSString *latitude;

@property (nonatomic,strong) NSString *longitude;

@property (nonatomic,assign) BOOL haveCoordinate;

@property (nonatomic,strong) NSString *latitudeBaidu;

@property (nonatomic,strong) NSString *longitudeBaidu;

@property (nonatomic,assign) BOOL haveCoordinateBaidu;

@end

@implementation YYOrderingDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self SomePrepare];
    [self UIConfig];
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    // 进入埋点
    [MobClick beginLogPageView:kYYPageOrderingDetail];
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    // 退出埋点
    [MobClick endLogPageView:kYYPageOrderingDetail];
}

#pragma mark - SomePrepare
-(void)SomePrepare
{
    [self PrepareData];
    [self PrepareUI];
}

-(void)PrepareData{}
-(void)PrepareUI{
    self.view.backgroundColor = _define_white_color;
    
    [self CreateOrUpdateNavViewWithTitle:NSLocalizedString(@"线下订货会",nil)];
    WeakSelf(ws);
    self.navView.goBackBlock = ^{
        [ws GoBack:nil];
    };
    
    UIButton *shareBtn = [UIButton getCustomImgBtnWithImageStr:@"share_icon" WithSelectedImageStr:nil];
    [_navView addSubview:shareBtn];
    [shareBtn addTarget:self action:@selector(shareAction:) forControlEvents:UIControlEventTouchUpInside];
    [shareBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(kStatusBarHeight);
        make.right.mas_equalTo(0);
        make.width.mas_equalTo(40);
        make.bottom.mas_equalTo(-1);
    }];
}
-(void)CreateOrUpdateNavViewWithTitle:(NSString *)title{
    if(!_navView){
        _navView = [[YYNavView alloc] initWithTitle:title WithSuperView:self.view haveStatusView:YES];
    }else{
        _navView.navTitle = title;
    }
}
#pragma mark - UIConfig
-(void)UIConfig{
    [self CreateWebview];
}
-(void)CreateWebview
{
    WeakSelf(ws);
    _webView=[[UIWebView alloc] init];
    [self.view addSubview:_webView];
    [_webView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.mas_equalTo(0);
        make.top.mas_equalTo(ws.navView.mas_bottom).with.offset(0);
        make.bottom.mas_equalTo(ws.mas_bottomLayoutGuideTop).with.offset(0);
    }];
    if (@available(iOS 11.0, *)) {
        _webView.scrollView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    }
    _webView.backgroundColor = [UIColor clearColor];
    _webView.delegate=self;
    
    _webView.opaque = NO;
    _webView.dataDetectorTypes = UIDataDetectorTypeNone;
    
    
    NSString *_kLastYYServerURL = [[NSUserDefaults standardUserDefaults] objectForKey:kLastYYServerURL];
    //字条串是否包含有某字符串
    if ([_kLastYYServerURL containsString:@"show.ycofoundation.com"]) {
        //展示
        _weburl = [[NSString alloc] initWithFormat:@"http://mshow.ycosystem.com/orderMeet/detail?id=%ld",(long)[_orderingModel.id integerValue]];
    }else if ([_kLastYYServerURL containsString:@"test.ycosystem.com"]){
        //测试
        _weburl = [[NSString alloc] initWithFormat:@"http://mt.ycosystem.com/orderMeet/detail?id=%ld",(long)[_orderingModel.id integerValue]];
    }else if ([_kLastYYServerURL containsString:@"ycosystem.com"]){
        //生产
        _weburl = [[NSString alloc] initWithFormat:@"http://m.ycosystem.com/orderMeet/detail?id=%ld",(long)[_orderingModel.id integerValue]];
    }
    if([LanguageManager isEnglishLanguage]){
        _weburl = [[NSString alloc] initWithFormat:@"%@&lang=en",_weburl];
    }
    [_webView loadRequest:[[NSURLRequest alloc] initWithURL:[[NSURL alloc] initWithString:_weburl]]];
    
    NSURL *url = [NSURL URLWithString:_weburl];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    
    [_webView loadRequest:request];
    
    [_webView sizeToFit];
}
#pragma mark - UIWebViewDelegate
- (void)webViewDidFinishLoad:(UIWebView *)webView{

    [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
     //首先创建JSContext 对象（此处通过当前webView的键获取到jscontext）
    __block JSContext *context = [webView valueForKeyPath:@"documentView.webView.mainFrame.javaScriptContext"];
//    一，js里面直接调用方法
    
    //更新标题
//    NSString *returs = [_webView stringByEvaluatingJavaScriptFromString:@"window._data"];
//    NSDictionary *_dataInfo = [returs mj_JSONObject];
//    NSString *titleStr = [_dataInfo objectForKey:@"title"];
//    [self CreateOrUpdateNavViewWithTitle:titleStr];
    
    //返回到订货会列表
    context[@"IOSReturnList"] = ^(){
        [[NSNotificationCenter defaultCenter] postNotificationName:kShowUserOrderingHistoryNotification object:nil];
    };

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
    context[@"IOSNavigationAction"] = ^(){
        [self navigationAction];
    };
    
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
    NSMutableArray *cookies = (NSMutableArray *)[sharedHTTPCookieStorage cookiesForURL:[NSURL URLWithString:_weburl]];
    
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
#pragma mark - SomeAction
-(void)setOrderingModel:(YYOrderingListItemModel *)orderingModel{
    _orderingModel = orderingModel;
    _haveCoordinate = NO;
    if(![NSString isNilOrEmpty:_orderingModel.coordinate]){
        NSArray *coordinateArr = [_orderingModel.coordinate componentsSeparatedByString:@","];
        if(coordinateArr.count>=2){
            _haveCoordinate = YES;
            _latitude = coordinateArr[0];
            _longitude = coordinateArr[1];
        }
    }
    _haveCoordinateBaidu = NO;
    if(![NSString isNilOrEmpty:_orderingModel.coordinateBaidu]){
        NSArray *coordinateArr = [_orderingModel.coordinateBaidu componentsSeparatedByString:@","];
        if(coordinateArr.count>=2){
            _haveCoordinateBaidu = YES;
            _latitudeBaidu = coordinateArr[0];
            _longitudeBaidu = coordinateArr[1];
        }
    }
}
//返回
-(void)GoBack:(id)sender {

    if([_webView canGoBack]){
        [_webView goBack];
    }else{
        if(_cancelButtonClicked)
        {
            _cancelButtonClicked();
        }
    }
}

#pragma mark - 分享
-(void)shareAction:(id)sender {
    NSLog(@"shareAction");
    _mengban=[UIImageView getMaskImageView];
    [self.view addSubview:_mengban];
    WeakSelf(ws);
    [_mengban addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(mengban_dismiss)]];
    _shareView=[[YYShareView alloc] initWithParams:nil WithBlock:^(NSString *type,SSDKPlatformType platformType) {
        if([type isEqualToString:@"cancel"])
        {
            [ws mengban_dismiss];
        }else{

            NSLog(@"%@",type);
            if(platformType == SSDKPlatformTypeSinaWeibo){
                [MBProgressHUD showHUDAddedTo:self.view animated:YES];
                //新浪的时候  要先下载图片
                __block UIImage *downloadPic = nil;
                //            取缓存
                NSString *imageRelativePath = _orderingModel.poster;
                NSString *size = kLookBookImage;
                if(![NSString isNilOrEmpty:imageRelativePath]){
                    NSURL *imageUrl = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@",imageRelativePath,size]];
                    SDWebImageManager *manager = [SDWebImageManager sharedManager];
                    [manager loadImageWithURL:imageUrl options:SDWebImageRetryFailed|SDWebImageLowPriority progress:nil completed:^(UIImage * _Nullable image, NSData * _Nullable data, NSError * _Nullable error, SDImageCacheType cacheType, BOOL finished, NSURL * _Nullable imageURL) {
                        downloadPic = image;
                        [MBProgressHUD hideAllHUDsForView:ws.view animated:YES];
                        [ws ShareActionWithType:platformType WithDownLoadPic:downloadPic];
                    }];
                }else{
                    downloadPic = nil;
                    [MBProgressHUD hideAllHUDsForView:ws.view animated:YES];
                    [ws ShareActionWithType:platformType WithDownLoadPic:downloadPic];
                }
            }else{
                [ws ShareActionWithType:platformType WithDownLoadPic:nil];
            }
        }
    }];

    [_mengban addSubview:_shareView];

    [self.shareView show];
}
-(void)ShareActionWithType:(SSDKPlatformType )platformType WithDownLoadPic:(UIImage *)downloadPic
{
    YYUser *user = [YYUser currentUser];
    //1、创建分享参数（必要）
    NSDictionary *params = nil;

    if(downloadPic){
        params = @{
                   @"orderingName":_orderingModel.name
                   ,@"orderingUrl":_weburl
                   ,@"poster":_orderingModel.poster
                   ,@"buyerStoreName":user.name
                   ,@"downloadPic":downloadPic
                   };
    }else{
        params = @{
                   @"orderingName":_orderingModel.name
                   ,@"orderingUrl":_weburl
                   ,@"poster":_orderingModel.poster
                   ,@"buyerStoreName":user.name
                   };
    }

    NSMutableDictionary *shareParams = [YYShareView getShareParamsWithType:@"ordering_detail" WithShare_type:platformType WithShareParams:params];

    [shareParams SSDKEnableUseClientShare];

    //2、分享
    [ShareSDK share:platformType parameters:shareParams onStateChanged:^(SSDKResponseState state, NSDictionary *userData, SSDKContentEntity *contentEntity, NSError *error) {
        [self mengban_dismiss];
        switch (state) {

            case SSDKResponseStateBegin:
            {
                break;
            }
            case SSDKResponseStateSuccess:
            {
                NSString *title=nil;
                //Facebook Messenger、WhatsApp等平台捕获不到分享成功或失败的状态，最合适的方式就是对这些平台区别对待
                if (platformType == SSDKPlatformTypeFacebookMessenger)
                {
                    break;
                }else if(platformType==SSDKPlatformTypeCopy)
                {
                    title=NSLocalizedString(@"已复制",nil);
                    [YYToast showToastWithTitle:title andDuration:kAlertToastDuration];

                }else
                {
                    title=NSLocalizedString(@"分享成功",nil);
                    [YYToast showToastWithTitle:title andDuration:kAlertToastDuration];
                }

                break;
            }
            case SSDKResponseStateFail:
            {
                NSLog(@"%@",[NSString stringWithFormat:@"%@",error]);
                if (platformType == SSDKPlatformTypeSMS && [error code] == 201)
                {
                    [YYToast showToastWithTitle:NSLocalizedString(@"分享失败",nil) andDuration:kAlertToastDuration];
                    break;
                }
                else if(platformType == SSDKPlatformTypeMail && [error code] == 201)
                {
                    [YYToast showToastWithTitle:NSLocalizedString(@"分享失败",nil) andDuration:kAlertToastDuration];
                    break;
                }
                else
                {
                    [YYToast showToastWithTitle:NSLocalizedString(@"分享失败",nil) andDuration:kAlertToastDuration];
                    break;
                }
                break;
            }
            case SSDKResponseStateCancel:
            {
                if(platformType!=SSDKPlatformSubTypeWechatSession)
                {
                    [YYToast showToastWithTitle:NSLocalizedString(@"分享已取消",nil) andDuration:kAlertToastDuration];
                }

                break;
            }
            default:
                break;
        }
    }];
}
//蒙板消失
-(void)mengban_dismiss
{
    [UIView animateWithDuration:0.2 animations:^{
        _shareView.frame=CGRectMake(0, SCREEN_HEIGHT, SCREEN_WIDTH, CGRectGetHeight(_shareView.frame));
    } completion:^(BOOL finished) {
        [_mengban removeFromSuperview];
        _mengban=nil;
    }];

}
#pragma mark - 导航
-(void)navigationAction
{
    if(_haveCoordinate){
        CLAuthorizationStatus status = [CLLocationManager authorizationStatus];
        if (kCLAuthorizationStatusDenied == status || kCLAuthorizationStatusRestricted == status) {
            [self presentViewController:[regular alertTitleCancel_Simple:NSLocalizedString(@"请在iPhone的 设置－隐私－定位服务 选项中，允许 YCO BUYER 使用您的位置。", @"") WithBlock:^{
                if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]])
                {
                    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
                }
            }] animated:YES completion:nil];
            
        }else
        {
            BOOL gaoDeMapCanOpen=[[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"iosamap://"]];
            BOOL baiduMapCanOpen=[[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"baidumap://"]];
            UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle: UIAlertControllerStyleActionSheet];
            
            UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"取消", @"") style:UIAlertActionStyleCancel handler:nil];
            
            UIAlertAction *iPhoneAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"用iPhone自带地图导航",nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                [self openAppleMap];
            }];
            [alertController addAction:cancelAction];
            [alertController addAction:iPhoneAction];
            if(baiduMapCanOpen)
            {
                UIAlertAction *baiduAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"用百度地图导航",nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                    [self openBaiDuMap];
                }];
                [alertController addAction:baiduAction];
            }
            if(gaoDeMapCanOpen)
            {
                UIAlertAction *gaoDeAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"用高德地图导航",nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                    [self openGaoDeMap];
                }];
                [alertController addAction:gaoDeAction];
            }
            [self presentViewController:alertController animated:YES completion:nil];
        }
    }
    
}
//BOOL gaoDeMapCanOpen=[[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"iosamap://"]];
//        BOOL baiduMapCanOpen=[[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"baidumap://"]];
//打开高德地图导航

- (void)openGaoDeMap{
    
    NSString *urlString = [[NSString stringWithFormat:@"iosamap://navi?sourceApplication=%@&backScheme=%@&poiname=%@&lat=%@&lon=%@&dev=1&style=2",@"YCO SPACE", @"YCO", _orderingModel.address, _latitude, _longitude] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    [[UIApplication sharedApplication]openURL:[NSURL URLWithString:urlString]];
    
}

//打开百度地图导航

- (void)openBaiDuMap{
    
//    MKMapItem *currentLocation = [MKMapItem mapItemForCurrentLocation];
//    
//    NSString *url=[NSString stringWithFormat:@"baidumap://map/direction?origin=latlng:%@,%@|name:我的位置&destination=latlng:%f,%f|name:%@&mode=driving",_latitude,_longitude,currentLocation.placemark.location.coordinate.latitude,currentLocation.placemark.location.coordinate.longitude,@"余杭临平艺尚小镇"];
//    NSString *urlString = [url stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
//    
//    [[UIApplication sharedApplication]openURL:[NSURL URLWithString:urlString]];
    
    NSString *urlString = [[NSString stringWithFormat:@"baidumap://map/direction?origin=我的位置&destination=%@&mode=driving",_orderingModel.address] stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet  URLQueryAllowedCharacterSet]];//_orderingModel.address
    [[UIApplication sharedApplication]openURL:[NSURL URLWithString:urlString]];
    
}
//打开苹果自带地图导航

- (void)openAppleMap{
    
    MKMapItem *currentLocation = [MKMapItem mapItemForCurrentLocation];
    
    //目的地的位置
    
    CLLocationCoordinate2D coords2 = CLLocationCoordinate2DMake([_latitude doubleValue], [_longitude doubleValue]);
    
    MKMapItem *toLocation = [[MKMapItem alloc] initWithPlacemark:[[MKPlacemark alloc] initWithCoordinate:coords2 addressDictionary:nil]];
    
    toLocation.name = _orderingModel.address;
    
    NSArray *items = [NSArray arrayWithObjects:currentLocation, toLocation, nil];
    
    NSDictionary *options = @{ MKLaunchOptionsDirectionsModeKey:MKLaunchOptionsDirectionsModeDriving, MKLaunchOptionsMapTypeKey: [NSNumber numberWithInteger:MKMapTypeStandard], MKLaunchOptionsShowsTrafficKey:@YES };
    
    //打开苹果自身地图应用，并呈现特定的item
    
    [MKMapItem openMapsWithItems:items launchOptions:options];
    
}
#pragma mark - 跳转设计师主页
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
#pragma mark - 跳转系列详情页 要先判断权限
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
        //信息全
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
#pragma mark - Other
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
