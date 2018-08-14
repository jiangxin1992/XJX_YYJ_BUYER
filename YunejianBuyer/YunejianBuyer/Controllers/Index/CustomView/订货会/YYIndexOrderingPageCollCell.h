//
//  YYIndexOrderingPageCollCell.h
//  YunejianBuyer
//
//  Created by yyj on 2017/9/21.
//  Copyright © 2017年 Apple. All rights reserved.
//

#import <UIKit/UIKit.h>

@class YYOrderingListItemModel;

@interface YYIndexOrderingPageCollCell : UICollectionViewCell

@property(nonatomic,copy) void (^indexOrderingPageCollBlock)(NSString *type,YYOrderingListItemModel *listItemModel);

@property (nonatomic,strong) YYOrderingListItemModel *listItemModel;

-(void)updateUI;

@end
