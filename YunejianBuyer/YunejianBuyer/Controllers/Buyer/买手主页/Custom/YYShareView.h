//
//  YYShareView.h
//  YunejianBuyer
//
//  Created by yyj on 2017/6/5.
//  Copyright © 2017年 Apple. All rights reserved.
//

#import <UIKit/UIKit.h>

#import <ShareSDK/ShareSDK.h>
#import <ShareSDKExtension/ShareSDK+Extension.h>

@interface YYShareView : UIView

-(instancetype)initWithParams:(NSDictionary *)params WithBlock:(void(^)(NSString *type,SSDKPlatformType platformType))block;

- (void)show;

/**
 * 获取分享参数
 */
+(NSMutableDictionary *)getShareParamsWithType:(NSString *)type WithShare_type:(SSDKPlatformType )platformType WithShareParams:(NSDictionary *)params;

@property (nonatomic,copy) void (^block)(NSString *type,SSDKPlatformType platformType);

@end
