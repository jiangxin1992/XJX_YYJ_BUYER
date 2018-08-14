//
//  YYVisibleSocialContactView.h
//  YunejianBuyer
//
//  Created by chuanjun sun on 2017/10/27.
//  Copyright © 2017年 Apple. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void (^agreementStat)(NSString *type, NSString *title);

@class YYVisibleSocialContactView;
@protocol YYVisibleSocialContactDelegate<NSObject>

@optional

/**
 输入的内容回调

 @param view 本身
 @param tag 标志。0，1，2，3 代表微信、新浪、ins、facebook
 @param content 内容
 */
- (void)YYVisibleSocialContactView:(YYVisibleSocialContactView *)view withTag:(NSInteger)tag content:(NSString *)content;

@end

@interface YYVisibleSocialContactView : UIView
/** 服务协议 */
@property (nonatomic, copy) agreementStat agreement;
/** 隐私协议 */
@property (nonatomic, assign) BOOL isAgree;

/** 代理 */
@property (nonatomic, weak) id<YYVisibleSocialContactDelegate> delegate;
@end
