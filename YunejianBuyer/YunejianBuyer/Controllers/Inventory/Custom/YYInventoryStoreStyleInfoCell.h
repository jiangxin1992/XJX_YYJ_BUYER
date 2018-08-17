//
//  YYInventoryStoreStyleInfo.h
//  YunejianBuyer
//
//  Created by Apple on 16/9/2.
//  Copyright © 2016年 Apple. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "YYInventoryBoardModel.h"
#import "SCGIFImageView.h"
@interface YYInventoryStoreStyleInfoCell : UITableViewCell
@property (weak, nonatomic) IBOutlet SCGIFImageView *albumImgView;
@property (weak, nonatomic) IBOutlet UILabel *brandNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *styleNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *styleCodeLabel;
@property (weak, nonatomic) IBOutlet SCGIFImageView *logoImgView;

@property (nonatomic,strong)YYInventoryBoardModel *boardModel;
-(void)updateUI;
@end
