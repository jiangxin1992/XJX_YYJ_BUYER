//
//  YYInventoryBoardViewCell.h
//  YunejianBuyer
//
//  Created by Apple on 16/9/1.
//  Copyright © 2016年 Apple. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "YYInventoryBoardModel.h"
#import "SCGIFImageView.h"
@interface YYInventoryBoardViewCell : UITableViewCell<YYTableCellDelegate>
@property (weak, nonatomic) IBOutlet SCGIFImageView *styleImageView;
@property (weak, nonatomic) IBOutlet UIView *unReadFlagView;
@property (weak, nonatomic) IBOutlet UILabel *brandNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *styleNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *updateTimerLabel;
@property (weak, nonatomic) IBOutlet UIButton *addStoreBtn;
@property (weak, nonatomic) IBOutlet UIButton *hasStoreBtn;
@property (weak, nonatomic) IBOutlet UIView *sizeLabelContainer;

@property (weak, nonatomic) IBOutlet UILabel *colorNameLabel;
@property (weak, nonatomic) IBOutlet SCGIFImageView *colorImage;
@property(nonatomic,strong)YYInventoryBoardModel *boardModel;

@property (nonatomic,weak)id<YYTableCellDelegate> delegate;
@property (nonatomic,strong)NSIndexPath *indexPath;
-(void)updateUI;
+(float)cellHeigh:(NSInteger)sizes;
@end
