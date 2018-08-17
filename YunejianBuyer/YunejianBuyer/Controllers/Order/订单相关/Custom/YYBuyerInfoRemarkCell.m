//
//  YYBuyerInfoRemarkCell.m
//  Yunejian
//
//  Created by Apple on 15/10/26.
//  Copyright © 2015年 yyj. All rights reserved.
//

#import "YYBuyerInfoRemarkCell.h"

#import "UIImage+YYImage.h"

@implementation YYBuyerInfoRemarkCell
-(void)updateUI:(NSArray*)info{

    if([LanguageManager isEnglishLanguage]){
        _orderRemarkWidthLayout.constant = 85;
        _orderCreateWidthLayout.constant = 85;
        _orderCodeWidthLayout.constant = 85;
    }else{
        _orderRemarkWidthLayout.constant = 70;
        _orderCreateWidthLayout.constant = 70;
        _orderCodeWidthLayout.constant = 70;
    }
    
    self.orderCodeLabel.text = [info objectAtIndex:0];
    self.orderCreateTimerLabel.text = [info objectAtIndex:1];
    NSString *remarkStr = [info objectAtIndex:2];
    NSMutableParagraphStyle *paraStyle = [[NSMutableParagraphStyle alloc] init];
    paraStyle.lineHeightMultiple = 1.1;
    NSDictionary *attrDict = @{ NSParagraphStyleAttributeName: paraStyle,
                                NSFontAttributeName: [UIFont systemFontOfSize: 12] };
    self.orderRemarkLabel.attributedText = [[NSAttributedString alloc] initWithString: remarkStr attributes: attrDict];

    //self.txtView.backgroundColor = [UIColor colorWithHex:kDefaultImageColor];
}
+(NSInteger) getCellHeight:(NSString *)desc{
    NSInteger txtWidth = SCREEN_WIDTH - 35-70;
    NSInteger textHeight = 0;
    if([desc isEqualToString:@""]){
        textHeight = 12;
    }else{
        NSMutableParagraphStyle *paraStyle = [[NSMutableParagraphStyle alloc] init];
        paraStyle.lineHeightMultiple = 1.1;
        NSDictionary *attrDict = @{ NSParagraphStyleAttributeName: paraStyle,
                                    NSFontAttributeName: [UIFont systemFontOfSize: 12] };
        
        textHeight = getTxtHeight(txtWidth, desc, attrDict);
        // textHeight = getTxtHeight(txtWidth, desc, @{NSFontAttributeName:[UIFont systemFontOfSize:15]});
    }
    return 150 + textHeight - 55;
}
@end
