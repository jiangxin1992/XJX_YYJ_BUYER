//
//  YYPaymentNoteOnlinePayDetailModel.h
//  yunejianDesigner
//
//  Created by Apple on 16/7/27.
//  Copyright © 2016年 Apple. All rights reserved.
//

#import <JSONModel/JSONModel.h>
@protocol YYPaymentNoteOnlinePayDetailModel @end
@interface YYPaymentNoteOnlinePayDetailModel : JSONModel
@property (strong, nonatomic) NSString <Optional>*accountTime;//到账时间（转账给设计师）
@property (strong, nonatomic) NSNumber <Optional>*payChannel;
@property (strong, nonatomic) NSString <Optional>*payTime;
@property (strong, nonatomic) NSString <Optional>*tradeNo;// 支付宝交易流水号
@property (strong, nonatomic) NSString <Optional>*transStatus;// 转账状态 0:已支付 1:发起转账 2:已到账
@end
