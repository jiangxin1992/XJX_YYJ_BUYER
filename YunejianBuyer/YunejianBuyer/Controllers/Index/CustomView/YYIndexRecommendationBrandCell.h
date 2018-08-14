//
//  YYIndexRecommendationBrandCell.h
//  YunejianBuyer
//
//  Created by yyj on 2017/8/8.
//  Copyright © 2017年 Apple. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface YYIndexRecommendationBrandCell : UITableViewCell

-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier WithBlock:(void(^)(NSString *type,NSInteger index))block;

-(void)updateUI;

@property (nonatomic,strong) NSArray *recommendDesignerBrandsModelArray;

@end
