//
//  YYIndexOrderingNoDataCell.h
//  YunejianBuyer
//
//  Created by yyj on 2017/8/11.
//  Copyright © 2017年 Apple. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface YYIndexOrderingNoDataCell : UITableViewCell

-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier WithBlock:(void(^)(NSString *type))block;

@end
