//
//  YYInventoryTableStepCell.h
//  YunejianBuyer
//
//  Created by Apple on 16/9/1.
//  Copyright © 2016年 Apple. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface YYInventoryTableStepCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *titleLabel1;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel2;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel3;
@property (weak, nonatomic) IBOutlet UIView *stepView1;
@property (weak, nonatomic) IBOutlet UIView *stepView2;
@property (weak, nonatomic) IBOutlet UIView *stepView3;
@property (weak, nonatomic) IBOutlet UILabel *stepNumLabel1;
@property (weak, nonatomic) IBOutlet UILabel *stepNumLabel2;
@property (weak, nonatomic) IBOutlet UILabel *stepNumLabel3;
-(void)updateCellInfo:(NSArray*)info;
@end
