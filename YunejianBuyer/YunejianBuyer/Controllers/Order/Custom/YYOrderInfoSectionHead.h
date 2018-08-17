//
//  YYOrderInfoSectionHead.h
//  YunejianBuyer
//
//  Created by Apple on 16/1/28.
//  Copyright © 2016年 Apple. All rights reserved.
//

#import <UIKit/UIKit.h>

@class YYOrderInfoModel;

@interface YYOrderInfoSectionHead : UITableViewCell

@property (nonatomic, copy)  YYOrderInfoModel * orderIndoModel;
@property (nonatomic, assign) NSInteger selectBrandIndex;
@property (nonatomic, assign) NSInteger section;
@property (nonatomic, copy) NSArray *hidesectionKeyArr;
@property (nonatomic, weak) id<YYTableCellDelegate> delegate;

-(void)updateUI;

@end
