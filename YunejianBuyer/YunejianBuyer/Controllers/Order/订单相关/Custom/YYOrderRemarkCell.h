//
//  YYOrderRemarkCell.h
//  Yunejian
//
//  Created by yyj on 15/8/20.
//  Copyright (c) 2015年 yyj. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "YYOrderInfoModel.h"

#define kOrderRemarkText NSLocalizedString(@"订单备注",nil)

typedef void (^TextViewIsEditCallback)(BOOL isEdit);
typedef void (^RemarkButtonClicked)();

//typedef void (^BuyerButtonClicked)(UIView *view);
//typedef void (^OrderSituationButtonClicked)(UIView *view);
//typedef void (^DiscountButtonClicked)();

@interface YYOrderRemarkCell : UITableViewCell

@property (strong, nonatomic)TextViewIsEditCallback textViewIsEditCallback;

//@property (strong, nonatomic)BuyerButtonClicked buyerButtonClicked;
//@property (strong, nonatomic)OrderSituationButtonClicked orderSituationButtonClicked;
//@property (strong, nonatomic)DiscountButtonClicked discountButtonClicked;
@property (strong, nonatomic)RemarkButtonClicked remarkButtonClicked;

@property (strong, nonatomic) YYOrderInfoModel *currentYYOrderInfoModel;

- (void)updateUI;

@end
