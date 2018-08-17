//
//  YYInventoryBrandTableViewCell.h
//  YunejianBuyer
//
//  Created by Apple on 16/9/1.
//  Copyright © 2016年 Apple. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "YYInventoryBrandModel.h"
#import "SCGIFImageView.h"
@interface YYInventoryBrandTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet SCGIFImageView *logoImageView;
@property (weak, nonatomic) IBOutlet UILabel *brandNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *emailLabel;
@property (nonatomic,strong)YYInventoryBrandModel * brandInfoModel;
-(void)updateUI;
@end
