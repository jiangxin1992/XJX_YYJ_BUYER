//
//  YYInventorySelectOrderStyleViewController.h
//  YunejianBuyer
//
//  Created by Apple on 16/9/1.
//  Copyright © 2016年 Apple. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface YYInventorySelectOrderStyleViewController : UIViewController
@property(nonatomic,strong) CancelButtonClicked cancelButtonClicked;
@property(nonatomic,assign) NSInteger viewType;
@property(nonatomic,strong) NSString *designerId;

@end
