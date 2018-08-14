//
//  YYBrandSmallInfoCell.h
//  YunejianBuyer
//
//  Created by yyj on 2017/4/12.
//  Copyright © 2017年 Apple. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "YYConnDesignerModel.h"

@interface YYBrandSmallInfoCell : UICollectionViewCell

@property (weak,nonatomic) id<YYTableCellDelegate>  delegate;
@property (nonatomic,strong) NSIndexPath *indexPath;
@property (nonatomic,copy) YYConnDesignerModel *designerModel;

-(void)updateUI;

@end
