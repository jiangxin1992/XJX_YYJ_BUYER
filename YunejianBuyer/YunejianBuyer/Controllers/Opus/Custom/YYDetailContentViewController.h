//
//  YYDetailContentViewController.h
//  Yunejian
//
//  Created by yyj on 15/7/26.
//  Copyright (c) 2015年 yyj. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "YYOpusStyleModel.h"
@class YYOpusSeriesModel,YYStyleDetailViewController,YYStyleInfoModel;

@interface YYDetailContentViewController : UIViewController
@property(nonatomic,assign)NSInteger selectTaxType;
@property(nonatomic,strong)YYOpusStyleModel *currentOpusStyleModel;
@property(nonatomic,strong)YYOpusSeriesModel *opusSeriesModel;

@property (nonatomic, weak) YYStyleDetailViewController *styleDetailViewController;

- (void)updateUI;
- (void)loadStyleInfo;

@property (nonatomic,copy) void (^detailContentBlock)(NSString *type,YYStyleInfoModel *styleInfoModel);

@end
