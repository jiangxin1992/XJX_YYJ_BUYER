//
//  YYOrderingJSObject.m
//  YunejianBuyer
//
//  Created by yyj on 2017/6/1.
//  Copyright © 2017年 Apple. All rights reserved.
//

#import "YYOrderingJSObject.h"

@implementation YYOrderingJSObject

//一下方法都是只是打了个log 等会看log 以及参数能对上就说明js调用了此处的iOS 原生方法
-(void)returnList
{
    NSLog(@"this is ios returnList");
}
-(void)returnBrand:(NSString *)message
{
    NSLog(@"this is ios returnBrand=%@",message);
    
}

@end
