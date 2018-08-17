//
//  YYWarehouseRecordModel.m
//  YunejianBuyer
//
//  Created by Victor on 2018/7/19.
//  Copyright © 2018年 Apple. All rights reserved.
//

#import "YYWarehouseRecordModel.h"

@implementation YYWarehouseRecordModel

- (NSString *)incomingName {
    return [YYWarehouseRecordModel getIncomingNameForType:self.incomingType];
}

+ (NSString *)getIncomingTypeForName:(NSString *)incomingName {
    if ([incomingName isEqualToString:NSLocalizedString(@"采购入库", nil)]) {
        return @"PURCHASE";
    }else if ([incomingName isEqualToString:NSLocalizedString(@"调拨入库", nil)]) {
        return @"TRANSFER";
    }else if ([incomingName isEqualToString:NSLocalizedString(@"销售退货", nil)]) {
        return @"SELL_RETURN";
    }else if ([incomingName isEqualToString:NSLocalizedString(@"盘点溢出", nil)]) {
        return @"CHECK_EXCEPTION";
    }else if ([incomingName isEqualToString:NSLocalizedString(@"其他入库", nil)]) {
        return @"OTHER_INCOMING";
    }else {
        return nil;
    }
}

+ (NSString *)getIncomingNameForType:(NSString *)incomingType {
    if ([incomingType isEqualToString:@"PURCHASE"]) {
        return NSLocalizedString(@"采购入库", nil);
    }else if ([incomingType isEqualToString:@"TRANSFER"]) {
        return NSLocalizedString(@"调拨入库", nil);
    }else if ([incomingType isEqualToString:@"SELL_RETURN"]) {
        return NSLocalizedString(@"销售退货", nil);
    }else if ([incomingType isEqualToString:@"CHECK_EXCEPTION"]) {
        return NSLocalizedString(@"盘点溢出", nil);
    }else if ([incomingType isEqualToString:@"OTHER_INCOMING"]) {
        return NSLocalizedString(@"其他入库", nil);
    }else {
        return NSLocalizedString(@"所有类型", nil);
    }
}

@end
