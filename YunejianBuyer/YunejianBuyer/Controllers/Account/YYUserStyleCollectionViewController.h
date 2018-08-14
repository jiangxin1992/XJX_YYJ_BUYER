//
//  YYUserStyleCollectionViewController.h
//  YunejianBuyer
//
//  Created by yyj on 2017/7/14.
//  Copyright © 2017年 Apple. All rights reserved.
//

#import <UIKit/UIKit.h>

@class YYUserStyleModel;

@interface YYUserStyleCollectionViewController : UIViewController

@property (nonatomic,copy) void (^styleBlock)(NSString *type,YYUserStyleModel *userStyleModel,NSIndexPath *indexPath);

-(void)deleteRowsAtIndexPaths:(NSIndexPath *)indexPath;

@end
