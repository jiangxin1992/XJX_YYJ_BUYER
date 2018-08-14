//
//  YYUserLogoInfoCell.h
//  Yunejian
//
//  Created by Apple on 15/9/22.
//  Copyright (c) 2015年 yyj. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SCGIFButtonView.h"

@interface YYUserLogoInfoCell : UITableViewCell

@property (weak, nonatomic) IBOutlet SCGIFButtonView *logoButton;
@property (weak, nonatomic) IBOutlet UILabel *usernameLabel;
@property (weak, nonatomic) IBOutlet UIButton *editButton;

@property (nonatomic,copy) void (^userLogoInfoCellBlock)(NSString *type);

@end
