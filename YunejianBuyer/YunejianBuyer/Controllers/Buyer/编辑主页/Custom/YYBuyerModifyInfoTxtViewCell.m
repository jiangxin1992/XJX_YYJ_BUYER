//
//  YYBuyerModifyInfoTxtViewCell.m
//  YunejianBuyer
//
//  Created by Apple on 16/12/21.
//  Copyright © 2016年 Apple. All rights reserved.
//

#import "YYBuyerModifyInfoTxtViewCell.h"

@implementation YYBuyerModifyInfoTxtViewCell

-(void)downlineIsHide:(BOOL )ishide
{
    _downline.hidden = ishide;
}
- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (IBAction)selectHandler:(id)sender {
    if([self.titleLabel.text isEqualToString:NSLocalizedString(@"网站",nil)])
    {
        if(self.selectedValue){
            self.selectedValue([[NSString alloc] initWithFormat:@"webUrl=%@",self.valueLabel.text]);
        }
    }else if([self.titleLabel.text isEqualToString:NSLocalizedString(@"详细地址",nil)])
    {
        if(self.selectedValue){
            self.selectedValue([[NSString alloc] initWithFormat:@"addressDetail=%@",self.valueLabel.text]);
        }
    }
    else if([self.titleLabel.text isEqualToString:NSLocalizedString(@"列举合作品牌",nil)])
    {
        if(self.selectedValue){
            self.selectedValue(@"");
        }
    }else if([self.titleLabel.text isEqualToString:NSLocalizedString(@"买手店简介",nil)])
    {
        if(self.selectedValue){
            self.selectedValue([[NSString alloc] initWithFormat:@"introduction=%@",self.valueLabel.text]);
        }
    }else
    {
        if(self.selectedValue){
            self.selectedValue(@"");
        }
    }
}
@end
