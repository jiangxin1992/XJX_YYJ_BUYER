//
//  YYInventoryStyleListViewCell.h
//  YunejianBuyer
//
//  Created by Apple on 16/9/2.
//  Copyright © 2016年 Apple. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "YYInventoryStyleSizeInfoView.h"
#import "YYInventoryStyleDetailModel.h"
#import "SCGIFImageView.h"
@interface YYInventoryStyleListViewCell : UITableViewCell<YYTableCellDelegate>
@property (weak, nonatomic) IBOutlet SCGIFImageView *styleImageView;
@property (weak, nonatomic) IBOutlet UILabel *brandNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *styleNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *updateTimerLabel;

@property (weak, nonatomic) IBOutlet YYInventoryStyleSizeInfoView *styleSizeInfoView;

@property (weak, nonatomic) IBOutlet UILabel *colorNameLabel;
@property (weak, nonatomic) IBOutlet SCGIFImageView *colorImage;
@property (weak, nonatomic) IBOutlet UIButton *editBtn;
@property (weak, nonatomic) IBOutlet UIButton *deleteBtn;
@property (weak, nonatomic) IBOutlet UIButton *resloveFlagBtn;
@property (weak, nonatomic) IBOutlet UIButton *finishBtn;
@property (nonatomic,assign)BOOL isModifyNow;
@property (nonatomic,strong)YYInventoryStyleDetailModel *styleModel;
@property (nonatomic,weak)id<YYTableCellDelegate> delegate;
@property (nonatomic,strong)NSIndexPath *indexPath;
-(void)updateUI;
@end
