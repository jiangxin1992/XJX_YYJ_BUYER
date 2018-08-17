//
//  YYPageRequestModel.m
//  YunejianBuyer
//
//  Created by Victor on 2018/7/19.
//  Copyright © 2018年 Apple. All rights reserved.
//

#import "YYPageRequestModel.h"

@implementation YYPageRequestModel

- (instancetype)init {
    if (self = [super init]) {
        self.pageIndex = 1;
        self.pageSize = 20;
    }
    return self;
}

@end
