//
//  YYDetailContentBrandViewCell.h
//  YunejianBuyer
//
//  Created by yyj on 2017/7/12.
//  Copyright © 2017年 Apple. All rights reserved.
//

#import <UIKit/UIKit.h>

@class YYStyleInfoModel;

@interface YYDetailContentBrandViewCell : UITableViewCell

-(id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier WithBlock:(void(^)(NSString *type))block;

@property (nonatomic,strong) YYStyleInfoModel *styleInfoModel;

-(void)updateUI;

@property(nonatomic,copy) void (^block)(NSString *type);

@end
