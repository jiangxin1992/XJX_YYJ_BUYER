//
//  UIButton+EdgeImageButton.h
//  YunejianBuyer
//
//  Created by Victor on 2018/7/9.
//  Copyright © 2018年 Apple. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger, EdgeType) {
    EdgeTypeUp,
    EdgeTypeNormal,
    EdgeTypeBotton,
    EdgeTypeRight
};

@interface UIButton (EdgeImageButton)

- (void)setButtonEdgeType:(EdgeType)edgeType;

@end
