//
//  YYOrderAppendParamModel.m
//  Yunejian
//
//  Created by Apple on 16/8/9.
//  Copyright © 2016年 yyj. All rights reserved.
//

#import "YYOrderAppendParamModel.h"

@implementation YYOrderAppendParamModel

-(NSDictionary *)toDescription{

    NSMutableDictionary *mutParameters = [[NSMutableDictionary alloc] init];
    if (self.styleIds && [self.styleIds count] > 0) {
        [mutParameters setObject:[self.styleIds componentsJoinedByString:@","] forKey:@"styleIds"];
    }
    
    if (self.originOrderCode) {
        [mutParameters setObject:self.originOrderCode forKey:@"originOrderCode"];
    }
    if (self.designerId) {
        [mutParameters setObject:self.designerId forKey:@"designerId"];
    }
    if (self.orderCreateTime) {
        [mutParameters setObject:self.orderCreateTime forKey:@"orderCreateTime"];
    }
    
    if (self.buyerName) {
        [mutParameters setObject:self.buyerName forKey:@"buyerName"];
    }
    if (self.businessCard) {
        [mutParameters setObject:self.businessCard forKey:@"businessCard"];
    }
    if (self.realBuyerId) {
        [mutParameters setObject:self.realBuyerId forKey:@"realBuyerId"];
    }
    
    if (self.buyerAddressId) {
        [mutParameters setObject:self.buyerAddressId forKey:@"buyerAddressId"];
    }
    if (self.finalTotalPrice) {
        [mutParameters setObject:self.finalTotalPrice forKey:@"finalTotalPrice"];
    }
    
    if (self.totalPrice) {
        [mutParameters setObject:self.totalPrice forKey:@"totalPrice"];
    }
    if (self.taxRate) {
        [mutParameters setObject:self.taxRate forKey:@"taxRate"];
    }
    if (self.payApp) {
        [mutParameters setObject:self.payApp forKey:@"payApp"];
    }
    if (self.deliveryChoose) {
        [mutParameters setObject:self.deliveryChoose forKey:@"deliveryChoose"];
    }
    if (self.billCreatePersonId) {
        [mutParameters setObject:self.billCreatePersonId forKey:@"billCreatePersonId"];
    }
    if (self.orderDescription) {
        [mutParameters setObject:self.orderDescription forKey:@"orderDescription"];
    }
    return [mutParameters copy];
//    return discription;
}
@end
