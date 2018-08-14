//
//  YYCompleteInformationView.h
//  YunejianBuyer
//
//  Created by yyj on 2017/10/23.
//  Copyright © 2017年 Apple. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface YYCompleteInformationView : UIView

-(instancetype)initWithBlock:(void(^)(NSString *type))block;

-(void)updateUI;

@end
