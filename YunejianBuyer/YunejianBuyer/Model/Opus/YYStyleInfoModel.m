//
//  YYStyleInfoModel.m
//  Yunejian
//
//  Created by yyj on 15/7/28.
//  Copyright (c) 2015年 yyj. All rights reserved.
//

#import "YYStyleInfoModel.h"

#import "YYInventoryBoardModel.h"

@implementation YYStyleInfoModel


-(NSString *)getSizeDes{
    NSString * sizeValue = @"";
    if (self.size
        && [self.size count] > 0) {
        for (YYSizeModel *sizeModel in self.size) {
            if (sizeValue && [sizeValue length] > 0) {
                sizeValue = [sizeValue stringByAppendingString:@" "];
            }
            sizeValue = [sizeValue stringByAppendingString:sizeModel.value];
        }
    }
    return sizeValue;
}

- (CGFloat)getMinTradePrice {
    NSArray *array = nil;
    if ([self.colorImages isKindOfClass:[NSArray class]]) {
        array = self.colorImages;
    } else {
        array = [self.colorImages forwardingTargetForSelector:nil];
    }
    return [[array valueForKeyPath:@"@min.tradePrice"] floatValue];
}

- (CGFloat)getMaxTradePrice {
    NSArray *array = nil;
    if ([self.colorImages isKindOfClass:[NSArray class]]) {
        array = self.colorImages;
    } else {
        array = [self.colorImages forwardingTargetForSelector:nil];
    }
    return [[array valueForKeyPath:@"@max.tradePrice"] floatValue];
}

/**
 模型转换

 @return ...
 */
-(YYInventoryBoardModel *)transformToInventoryBoardModel{
    YYInventoryBoardModel *infoModel = [[YYInventoryBoardModel alloc] init];
    infoModel.designerId = self.style.designerId;
    infoModel.brandName = self.style.designerBrandName;
    infoModel.brandLogo = self.style.designerBrandLogo;
    infoModel.seriesName = self.style.seriesName;
    infoModel.albumImg = self.style.albumImg;
    infoModel.styleName = self.style.name;
    infoModel.styleId = self.style.id;
    infoModel.seriesId = self.style.seriesId;
    infoModel.orderAmountMin = self.style.orderAmountMin;
    infoModel.supplyStatus = self.style.supplyStatus;
    infoModel.seriesStatus = self.style.seriesStatus;
    return infoModel;
}

@end
