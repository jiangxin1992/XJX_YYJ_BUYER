//
//  YYOrderPayResultViewController.h
//  YunejianBuyer
//
//  Created by Apple on 16/7/19.
//  Copyright © 2016年 Apple. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface YYOrderPayResultViewController : UIViewController
@property (nonatomic,assign) NSInteger payResultType;
@property (nonatomic,strong) NSDictionary *resultDic;
@property (nonatomic,assign) BOOL isViewControllerBackType;//application  YYOrderDetailViewController
@end
