//
//  YYNewBrandInfoCell.h
//  YunejianBuyer
//
//  Created by yyj on 2017/11/9.
//  Copyright © 2017年 Apple. All rights reserved.
//

#import <UIKit/UIKit.h>

@class YYHotDesignerBrandsModel,YYHotDesignerBrandsSeriesModel;

@interface YYNewBrandInfoCell : UICollectionViewCell

@property (nonatomic,copy) YYHotDesignerBrandsModel *hotDesignerBrandsModel;

@property(nonatomic,copy) void (^hotBrandCellBlock)(NSString *type,YYHotDesignerBrandsModel *hotDesignerBrandsModel,YYHotDesignerBrandsSeriesModel *seriesModel);

-(void)updateUI;

@end
