//
//  YYVisibleContactInfoViewController.h
//  YunejianBuyer
//
//  Created by chuanjun sun on 2017/10/25.
//  Copyright © 2017年 Apple. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void (^goBackClick)();

@interface YYVisibleContactInfoViewController : UIViewController

/** 返回 */
@property (nonatomic, copy)goBackClick goBack;

@end
