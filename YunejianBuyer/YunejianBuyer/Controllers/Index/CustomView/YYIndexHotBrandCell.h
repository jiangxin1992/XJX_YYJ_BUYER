//
//  YYIndexHotBrandCell.h
//  YunejianBuyer
//
//  Created by yyj on 2017/11/7.
//  Copyright © 2017年 Apple. All rights reserved.
//

#import <UIKit/UIKit.h>

@class YYHotDesignerBrandsModel,YYHotDesignerBrandsSeriesModel;

@interface YYIndexHotBrandCell : UITableViewCell

-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier WithBlock:(void(^)(NSString *type,YYHotDesignerBrandsModel *hotDesignerBrandsModel,YYHotDesignerBrandsSeriesModel *seriesModel))block;

-(void)updateUI;

@property (nonatomic, strong) YYHotDesignerBrandsModel *hotDesignerBrandsModel;

@property (nonatomic, assign) BOOL isLastCell;

@end
