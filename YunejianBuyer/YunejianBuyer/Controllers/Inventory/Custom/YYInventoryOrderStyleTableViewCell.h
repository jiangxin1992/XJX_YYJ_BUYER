//
//  YYInventoryOrderStyleTableViewCell.h
//  YunejianBuyer
//
//  Created by Apple on 16/9/1.
//  Copyright © 2016年 Apple. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "YYInventoryStyleModel.h"
#import "SCGIFImageView.h"
@interface YYInventoryOrderStyleTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet SCGIFImageView *albumImgView;
@property (weak, nonatomic) IBOutlet UILabel *seriesNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *styleNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *styleCodeLabel;

@property (nonatomic,strong)YYInventoryStyleModel * styleInfoModel;

-(void)updateUI;
@end
