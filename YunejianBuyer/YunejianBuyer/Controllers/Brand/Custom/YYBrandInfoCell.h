//
//  YYBrandInfoCell.h
//  YunejianBuyer
//
//  Created by yyj on 2017/4/7.
//  Copyright © 2017年 Apple. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "YYConnDesignerModel.h"

@interface YYBrandInfoCell : UICollectionViewCell

@property (weak,nonatomic) id<YYTableCellDelegate> delegate;
@property (nonatomic,strong) NSIndexPath *indexPath;
@property (nonatomic,copy) YYConnDesignerModel *designerModel;
-(void)updateUI;
@end
