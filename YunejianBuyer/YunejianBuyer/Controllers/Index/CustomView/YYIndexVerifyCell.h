//
//  YYIndexVerifyCell.h
//  YunejianBuyer
//
//  Created by yyj on 2017/10/23.
//  Copyright © 2017年 Apple. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface YYIndexVerifyCell : UITableViewCell

-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier WithBlock:(void(^)(NSString *type))block;

-(void)updateUI;

@end
