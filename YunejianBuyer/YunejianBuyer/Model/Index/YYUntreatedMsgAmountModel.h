//
//  YYUntreatedMsgAmountModel.h
//  YunejianBuyer
//
//  Created by Victor on 2018/6/13.
//  Copyright © 2018年 Apple. All rights reserved.
//

#import <JSONModel/JSONModel.h>

@class YYMessageButton;

@interface YYUntreatedMsgAmountModel : JSONModel

@property (nonatomic, assign) NSInteger unreadOrderNotifyMsgAmount;//未读信息数量
@property (nonatomic, assign) NSInteger unreadConnNotifyMsgAmount;//未读信息数量
@property (nonatomic, assign) NSInteger unreadInventoryAmount;//未读信息数量
@property (nonatomic, assign) NSInteger unreadPersonalMsgAmount;//未读私信信息数量
@property (nonatomic, assign) NSInteger unreadNewsAmount;//未读信息数量
@property (nonatomic, assign) NSInteger unreadAppointmentMsgAmount;//未读订货会发布消息数量
@property (nonatomic, assign) NSInteger unreadAppointmentStatusMsgAmount;//未读预约申请状态变更消息

@property (nonatomic, assign) NSInteger unconfirmedOrderedMsgAmount;//已下单
@property (nonatomic, assign) NSInteger unconfirmedConfirmedMsgAmount;//已确认
@property (nonatomic, assign) NSInteger unconfirmedProducedMsgAmount;//已生产
@property (nonatomic, assign) NSInteger unconfirmedDeliveringMsgAmount;//发货中
@property (nonatomic, assign) NSInteger unconfirmedDeliveredMsgAmount;//已发货
@property (nonatomic, assign) NSInteger unconfirmedReceivedMsgAmount;//已收货

- (void)clearModel;

- (void)setUnreadMessageAmount:(YYMessageButton *)messageButton;

@end
