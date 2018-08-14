//
//  YYUserLogoInfoCell.m
//  Yunejian
//
//  Created by Apple on 15/9/22.
//  Copyright (c) 2015年 yyj. All rights reserved.
//

#import "YYUserLogoInfoCell.h"

@implementation YYUserLogoInfoCell

- (void)awakeFromNib {
    // Initialization code
    [super awakeFromNib];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}


- (IBAction)editUserInfoAction:(id)sender {
    if(_userLogoInfoCellBlock){
        _userLogoInfoCellBlock(@"edit_user_info");
    }
}



@end
