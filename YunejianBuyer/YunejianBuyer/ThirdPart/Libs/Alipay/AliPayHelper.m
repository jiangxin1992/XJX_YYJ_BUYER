//
//  AliPayHelper.m
//  FT
//
//  Created by 毛灵辉 on 15/8/4.
//  Copyright (c) 2015年 yourentang. All rights reserved.
//

#import "AliPayHelper.h"
#import <AlipaySDK/AlipaySDK.h>
#import "YYRequestHelp.h"
#import "RequestMacro.h"
#import "UserDefaultsMacro.h"
#import "YYHttpHeaderManager.h"
#import "YYOrderPayResultViewController.h"
#import "Order.h"
#import "DataSigner.h"
@implementation AliPayHelper
+ (void)requestWithParamsData:(NSData *)data andBlock:(void (^)(YYRspStatusAndMessage *rspStatusAndMessage,NSDictionary *order,NSError *error))block{
    
    NSString *requestURL = [[[NSUserDefaults standardUserDefaults] objectForKey:kLastYYServerURL] stringByAppendingString:kAlipayCreate];
    NSDictionary *dic = [YYHttpHeaderManager buildHeadderWithAction:kAlipayCreate params:nil];

    [YYRequestHelp POST:dic requestUrl:requestURL requestCount:0 requestBody:data andBlock:^(YYRspStatusAndMessage *rspStatusAndMessage,id responseObject, NSError *error, id httpResponse) {
        if (!error) {
            block(rspStatusAndMessage,responseObject,error);
        }else{
            block(rspStatusAndMessage,nil,error);
        }
    }];
}

// resultNumber 有以下几种状态：
// 0 表示成功，1表示未安装，2表示签名错误，3表示参数错误，4，失败原因，字符串类型
+ (void)alixPayWithResponse:(NSDictionary *)responseObject
                 completion:(void (^)(void))completion {
    
//    NSString *appScheme = @"ycobuyer";
//    NSMutableString * orderString = [NSMutableString string];
//    //[orderString appendFormat:@"app_id=\"%@\"",kYYAppID];
//    //[orderString appendFormat:@"it_b_pay=\"%@\"",@"30m"];
//    NSInteger i=0;
//    for (NSString * key in [responseObject allKeys]) {
//        if( i == 0){
//            [orderString appendFormat:@"%@=\"%@\"", key, [responseObject objectForKey:key]];
//        }else{
//            [orderString appendFormat:@"&%@=\"%@\"", key, [responseObject objectForKey:key]];
//        }
//        i++;
//    }
//   NSString * orderString = @"partner=\"2088911850774983\"&seller_id=\"info@ycosystem.com\"&out_trade_no=\"113381717ez19\"&subject=\"L.Chan\"&body=\"testBody\"&total_fee=\"0.01\"&notify_url=\"http://121.40.57.9/service/pay/appAlipayNotify\"&service=\"mobile.securitypay.pay\"&payment_type=\"1\"&_input_charset=\"utf-8\"&sign=\"SWwMDG%2Ba1qfqlEIyE%2BVjXvy3x6yx%2F5G8dEt7cONIKxi%2F%2F9dHl7uc9%2FQD12Yq7TTeuLGPgruvUsLYeMmuQHgC2UFMQLOW99IfaN1tMOTxbg9djULMyTk4rDJNOI6xNuZ4MKSx582ZkslEFphdQenPIvnelahTWg%2BoTuxy0v00IdU%3D\"&sign_type=\"RSA\"";
//    NSLog(@"orderString = %@",orderString);
   /* ============================================================================
    =======================需要填写商户app申请的===================================
    /*============================================================================*/
    NSString *partner = [responseObject objectForKey:@"partner"];
    NSString *seller = [responseObject objectForKey:@"seller_id"];
    NSString *privateKey = @"MIICdQIBADANBgkqhkiG9w0BAQEFAASCAl8wggJbAgEAAoGBAO/LzQd+GvuL5/cZyfXwQoSqQqjVQ4XGdRmosXk9a15+hHU1XimmpqpH7c55U244jhaPiLgOpbWbNxSZ4WhmDhY8Hr/vEbjgxg02AWiJDKWcwXVdP/UNyMzYy4vOarICmYMka2L2uJOF7zErewaTAzygtbPuTfbpM8Valxk5iRvDAgMBAAECgYBAu+fRif2GwrIQRun6dq2+Wqg8I7ZiuryJ/LxMWoRNsiHX8lxFKjP77AcKoj4flyzkckMaTPn3GLu52AC9yi8q06pBKczxt74pFHjd6ysQkWBoWhQwKX7fhj/g6YQpQEUiH51eeaYBZ7wlsnOQ5FqzlTbYz/my2JTNEjlqXdQpYQJBAP0nnURlHPM1qq8YqsMaU+yW6CO+nLnLYp48h0mkSLVpN8U/xdNXRJhUFSp+AEuNMaKs3be/2hYS520CyDZOkK0CQQDyfcAnx1s1gntggcwgdJvw3HKQbp4bKpqZfULGzLzuSj9hQuivU0HhUCKQgrwx4MXxjilJcgAVZ76+xuT2hDwvAkBeDAh97z55EBfv4q8VukMxYsKs/NRGpctmU8BC2Hh2hLdGXTHGGOaP3LTcS2EasEKfV68q42hGyREWy3DL1BYlAkBuO3v+mUF9MbOkS1zf5CJ/e7cYsTBuaQ+edrLEbI32RQpKzH+6M77fDe6ogsXKZsOU62sZWBlxoZe0YfXzmmlBAkAqdmOPc41VhLaWxgx53C2VdPjoULOQzAzWoU3NAtyJR54/5mdTYuTzWo8p+cMBKSCttMf8MqDZCLvX9uq8bloY";
    /*============================================================================*/
    /*============================================================================*/
    /*============================================================================*/
    
    /*
     *生成订单信息及签名
     */
    //将商品信息赋予AlixPayOrder的成员变量
    Order *order = [[Order alloc] init];
    order.partner = partner;
    order.sellerID = seller;
    order.outTradeNO = [responseObject objectForKey:@"out_trade_no"]; //订单ID（由商家自行制定）
    order.subject = [responseObject objectForKey:@"subject"]; //商品标题
    order.body = [responseObject objectForKey:@"body"]; //商品描述
    order.totalFee = [responseObject objectForKey:@"total_fee"];//[NSString stringWithFormat:@"%.2f",product.price]; //商品价格
    order.notifyURL = [responseObject objectForKey:@"notify_url"];// @"http://www.xxx.com"; //回调URL
    
    order.service = [responseObject objectForKey:@"service"];//@"mobile.securitypay.pay";
    order.paymentType = [responseObject objectForKey:@"payment_type"];//@"1";
    order.inputCharset = @"utf-8";
    order.itBPay = @"30m";
    order.showURL = @"m.alipay.com";
   
    if([responseObject objectForKey:@"orderCode"] && [responseObject objectForKey:@"logoPath"]){
        order.outContext =  [NSMutableDictionary dictionaryWithObjectsAndKeys:[responseObject objectForKey:@"orderCode"],@"ordercode",[responseObject objectForKey:@"logoPath"],@"brandlogo",nil];//@{@"ordercode":@"",@"brandlogo":@""};
    }
    //应用注册scheme,在AlixPayDemo-Info.plist定义URL types
    NSString *appScheme = @"ycobuyer";
    
    //将商品信息拼接成字符串
    NSString *orderSpec = [order description];
    NSDictionary *orderSpecDict = [order mj_JSONObject];
    NSLog(@"orderSpec = %@",orderSpec);

    [[NSUserDefaults standardUserDefaults] setObject:orderSpecDict forKey:kUserAliPayOrderKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    //获取私钥并将商户信息签名,外部商户可以根据情况存放私钥和签名,只需要遵循RSA签名规范,并将签名字符串base64编码和UrlEncode
    id<DataSigner> signer = CreateRSADataSigner(privateKey);
    NSString *signedString = [signer signString:orderSpec];
    NSString *orderString = nil;
    if (signedString != nil) {
        orderString = [NSString stringWithFormat:@"%@&sign=\"%@\"&sign_type=\"%@\"",
                   orderSpec, signedString, @"RSA"];
    }
    
    NSLog(@"orderString = %@",orderString);
    if (orderString != nil) {
        [[AlipaySDK defaultService] payOrder:orderString fromScheme:appScheme callback:^(NSDictionary *resultDic) {
            NSLog(@"reslut = %@",resultDic);
//                if (delegate.alipayResultBlock) {// html5回调处理
            NSString *status = resultDic[@"resultStatus"];
            NSInteger number = [status integerValue];
            AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
            [appDelegate.mainViewController popViewControllerAnimated:NO];
//            if(completion){
//                completion();
//            }
            if(appDelegate.mainViewController){
                UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Order" bundle:[NSBundle mainBundle]];
                YYOrderPayResultViewController *orderPayResultViewController = [storyboard instantiateViewControllerWithIdentifier:@"YYOrderPayResultViewController"];
                orderPayResultViewController.payResultType = number;
                NSDictionary *resultDic = [[NSUserDefaults standardUserDefaults] objectForKey:kUserAliPayOrderKey];
                if(resultDic){
                    orderPayResultViewController.resultDic = resultDic;
                    [[NSUserDefaults standardUserDefaults] removeObjectForKey:kUserAliPayOrderKey];
                }
                orderPayResultViewController.isViewControllerBackType = YES;
                [appDelegate.mainViewController pushViewController:orderPayResultViewController animated:NO];
            }
        }];
        
        
//        /*
//         9000 订单支付成功
//         8000 正在处理中
//         4000 订单支付失败
//         6001 用户中途取消
//         6002 网络连接出错
//         */ // 这个callback是使用HTML5网页版支付时的回调，如果是用客户端支付，是不会回调到这里的
//        [[AlipaySDK defaultService] payOrder:orderString fromScheme:appScheme callback:^(NSDictionary *resultDic) {
//            if (delegate.alipayResultBlock) {// html5回调处理
//                NSString *status = resultDic[@"resultStatus"];
//                NSInteger number = [status integerValue];
//                //delegate.alipayResultBlock(number);
//            }
//        }];
        
    }
    

}

// 跳到支付宝应用后回调，这个是调用支付宝客户端时，会通过这个方法回调
+ (void)handleOpenURL:(NSURL *)url application:(AppDelegate *)application {
    NSLog(@"resultDicurl = %@", url);
    [[AlipaySDK defaultService] processOrderWithPaymentResult:url standbyCallback:^(NSDictionary *resultDic) {
        //FTAppDelegate *delegate = (FTAppDelegate *)[UIApplication sharedApplication].delegate;
        
        NSLog(@"resultDic = %@", resultDic);
//        if (delegate.alipayResultBlock) {// 跳到支付宝应用后回调
            NSString *status = resultDic[@"resultStatus"];
            NSLog(@"%@", status);
            NSInteger number = [status integerValue];
            AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
            [appDelegate.mainViewController popViewControllerAnimated:NO];

            if(appDelegate.mainViewController){
                [appDelegate.mainViewController popViewControllerAnimated:NO];
                UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Order" bundle:[NSBundle mainBundle]];
                YYOrderPayResultViewController *orderPayResultViewController = [storyboard instantiateViewControllerWithIdentifier:@"YYOrderPayResultViewController"];
                orderPayResultViewController.payResultType = number;
                NSDictionary *resultDic = [[NSUserDefaults standardUserDefaults] objectForKey:kUserAliPayOrderKey];
                if(resultDic){
                    orderPayResultViewController.resultDic = resultDic;
                    [[NSUserDefaults standardUserDefaults] removeObjectForKey:kUserAliPayOrderKey];
                }
                orderPayResultViewController.isViewControllerBackType = NO;
                [appDelegate.mainViewController pushViewController:orderPayResultViewController animated:YES];
                NSLog(@"111");
            }
    }];
    
    return;
}

- (NSError *)errorWithMessage:(NSString *)message {
    NSError *error = [[NSError alloc] initWithDomain:message code:0 userInfo:nil];
    NSLog(@"%@", [error description]);  
    return error;  
}
@end
