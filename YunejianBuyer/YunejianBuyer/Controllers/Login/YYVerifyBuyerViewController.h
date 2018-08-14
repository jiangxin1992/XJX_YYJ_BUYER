//
//  YYVerifyBuyerViewController.h
//  YunejianBuyer
//
//  Created by Victor on 2017/12/25.
//  Copyright © 2017年 Apple. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "YYRegisterTableBuyerRegisterUploadCell.h"

@interface YYVerifyBuyerViewController : UIViewController

@property(nonatomic,strong) UIView *topLayer;
@property(nonatomic,strong)CancelButtonClicked cancelButtonClicked;

@property(nonatomic,assign) NSInteger uploadImgType;
@property(nonatomic,strong) UIImage *uploadImg0;
@property(nonatomic,strong) UIImage *uploadImg1;
@property(nonatomic,strong) UIImage *uploadImg2;
@property(nonatomic,strong) UIImage *uploadImg3;
@property(nonatomic,strong) NSMutableArray *uploadImgs;

@end
