//
//  UIButton+EdgeImageButton.m
//  YunejianBuyer
//
//  Created by Victor on 2018/7/9.
//  Copyright © 2018年 Apple. All rights reserved.
//

#import "UIButton+EdgeImageButton.h"

@implementation UIButton (EdgeImageButton)

- (void)setButtonEdgeType:(EdgeType)edgeType {
    switch (edgeType) {
        case EdgeTypeUp:
            break;
            
        case EdgeTypeNormal:
            self.titleEdgeInsets = UIEdgeInsetsMake(0, 0, 0, 0);
            self.imageEdgeInsets = UIEdgeInsetsMake(0, 0, 0, 0);
            break;
            
        case EdgeTypeBotton:
            break;
            
        case EdgeTypeRight:
            self.titleEdgeInsets = UIEdgeInsetsMake(0, -CGRectGetWidth(self.imageView.frame), 0, CGRectGetWidth(self.imageView.frame));
            self.imageEdgeInsets = UIEdgeInsetsMake(0, CGRectGetWidth(self.titleLabel.frame), 0, -CGRectGetWidth(self.titleLabel.frame));
            break;
            
        default:
            break;
    }
}

@end
