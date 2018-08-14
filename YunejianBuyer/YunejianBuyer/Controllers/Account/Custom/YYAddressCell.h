//
//  YYAddressCell.h
//  Yunejian
//
//  Created by yyj on 15/7/16.
//  Copyright (c) 2015年 yyj. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "YYAddress.h"
#import <MGSwipeTableCell.h>

@interface YYAddressCell : MGSwipeTableCell

@property(nonatomic,strong)YYAddress *address;
//@property(nonatomic,strong)ModifyAddressButtonClicked modifyAddressButtonClicked;

-(void) updateUI;
+(NSString *)getAddressStr:(YYAddress *)address;
+(float) getCellHeight:(YYAddress *)address;
@end
