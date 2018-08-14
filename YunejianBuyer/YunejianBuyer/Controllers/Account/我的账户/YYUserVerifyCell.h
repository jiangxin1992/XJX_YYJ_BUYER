//
//  YYUserVerifyCell.h
//  YunejianBuyer
//
//  Created by yyj on 2017/10/24.
//  Copyright © 2017年 Apple. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface YYUserVerifyCell : UITableViewCell

-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier WithBlock:(void(^)(NSString *type))block;

-(void)updateUI;

@end
