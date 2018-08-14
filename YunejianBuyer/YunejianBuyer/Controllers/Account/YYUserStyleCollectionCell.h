//
//  YYUserStyleCollectionCell.h
//  YunejianBuyer
//
//  Created by yyj on 2017/7/14.
//  Copyright © 2017年 Apple. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MGSwipeTableCell.h>
#import <MGSwipeButton.h>

@class YYUserStyleModel;

@interface YYUserStyleCollectionCell : MGSwipeTableCell

@property (nonatomic,strong) YYUserStyleModel *styleModel;

@property (nonatomic,assign) BOOL haveData;

@property (nonatomic,copy) void (^styleCellBlock)(NSString *type);

-(void)updateUI;

@end
