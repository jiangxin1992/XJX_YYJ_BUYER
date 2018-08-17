//
//  YYOrderingJSObject.h
//  YunejianBuyer
//
//  Created by yyj on 2017/6/1.
//  Copyright © 2017年 Apple. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <JavaScriptCore/JavaScriptCore.h>

//首先创建一个实现了JSExport协议的协议
@protocol JSObjectProtocol <JSExport>

-(void)returnList;
-(void)returnBrand:(NSString *)message;

@end
//让我们创建的类实现上边的协议
@interface YYOrderingJSObject : NSObject<JSObjectProtocol>

@end
