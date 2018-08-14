//
//  YYUntreatedMsgAmountModel.m
//  YunejianBuyer
//
//  Created by Victor on 2018/6/13.
//  Copyright © 2018年 Apple. All rights reserved.
//

#import "YYUntreatedMsgAmountModel.h"

// c文件 —> 系统文件（c文件在前）

// 控制器

// 自定义视图

// 接口

// 分类

// 自定义类和三方类（ cocoapods类 > model > 工具类 > 其他）
#import "YYMessageButton.h"

@implementation YYUntreatedMsgAmountModel

+ (JSONKeyMapper *)keyMapper {
    return [[JSONKeyMapper alloc] initWithDictionary:@{
            @"orderAmount" : @"unreadOrderNotifyMsgAmount",
            @"connAmount" : @"unreadConnNotifyMsgAmount",
            @"inventoryAmount" : @"unreadInventoryAmount",
            @"newsAmount" : @"unreadNewsAmount",
            @"personalMessageAmount" : @"unreadPersonalMsgAmount",
            @"appointmentMsgAmount" : @"unreadAppointmentMsgAmount",
            @"ordered" : @"unconfirmedOrderedMsgAmount",
            @"confirmed" : @"unconfirmedConfirmedMsgAmount",
            @"produced" : @"unconfirmedProducedMsgAmount",
            @"delivering" : @"unconfirmedDeliveringMsgAmount",
            @"delivered" : @"unconfirmedDeliveredMsgAmount",
            @"received" : @"unconfirmedReceivedMsgAmount"
    }];
}

+ (BOOL)propertyIsOptional:(NSString *)propertyName {
    return YES;
}

- (void)clearModel {
    self.unreadOrderNotifyMsgAmount = 0;
    self.unreadConnNotifyMsgAmount = 0;
    self.unreadInventoryAmount = 0;
    self.unreadNewsAmount = 0;
    self.unreadPersonalMsgAmount = 0;
    self.unreadAppointmentMsgAmount = 0;
    self.unreadAppointmentStatusMsgAmount = 0;
    self.unconfirmedOrderedMsgAmount = 0;
    self.unconfirmedConfirmedMsgAmount = 0;
    self.unconfirmedProducedMsgAmount = 0;
    self.unconfirmedDeliveringMsgAmount = 0;
    self.unconfirmedDeliveredMsgAmount = 0;
    self.unconfirmedReceivedMsgAmount = 0;
}

- (void)setUnreadMessageAmount:(YYMessageButton *)messageButton{
    if(messageButton){
        NSInteger msgAmount = self.unreadOrderNotifyMsgAmount + self.unreadConnNotifyMsgAmount + self.unreadPersonalMsgAmount;

        if(msgAmount > 0 || self.unreadNewsAmount > 0){
            if(msgAmount > 0 ){
                [messageButton updateButtonNumber:[NSString stringWithFormat:@"%ld",(long)msgAmount]];
            }else{
                [messageButton updateButtonNumber:@"dot"];
            }
        }else{
            [messageButton updateButtonNumber:@""];
        }
    }
}

@end
