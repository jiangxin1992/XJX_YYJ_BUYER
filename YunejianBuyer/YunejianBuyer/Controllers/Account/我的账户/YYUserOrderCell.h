//
//  YYUserOrderCell.h
//  YunejianBuyer
//
//  Created by yyj on 2017/8/15.
//  Copyright © 2017年 Apple. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface YYUserOrderCell : UITableViewCell

-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier WithActionBlock:(void(^)(NSInteger pageIndex))block;

-(void)updateUI;

@end
