//
//  YYUserSeriesCollectionViewController.h
//  YunejianBuyer
//
//  Created by yyj on 2017/7/14.
//  Copyright © 2017年 Apple. All rights reserved.
//

#import <UIKit/UIKit.h>

@class YYUserSeriesModel;

@interface YYUserSeriesCollectionViewController : UIViewController

@property (nonatomic,copy) void (^styleBlock)(NSString *type,YYUserSeriesModel *userSeriesModel,NSIndexPath *indexPath);

-(void)deleteRowsAtIndexPaths:(NSIndexPath *)indexPath;

@end
