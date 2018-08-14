//
//  YYChooseStyleCell.h
//  YunejianBuyer
//
//  Created by yyj on 2017/7/5.
//  Copyright © 2017年 Apple. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "YYChooseStyleModel.h"

@interface YYChooseStyleCell : UICollectionViewCell

@property (nonatomic,copy) YYChooseStyleModel *styleModel;

-(void)updateUI;

@end
