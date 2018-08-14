//
//  YYPickerViewController.h
//  parking
//
//  Created by chjsun on 2017/2/10.
//  Copyright © 2017年 chjsun. All rights reserved.
//

#import <UIKit/UIKit.h>

@class YYVisibleAuditPickerViewController;
@protocol YYPickerDelegate <NSObject>

@optional
- (void)YYVisibleAuditPickerViewController:(YYVisibleAuditPickerViewController *)controller index:(NSInteger)index content:(NSString *)content;

@end

@interface YYVisibleAuditPickerViewController : UIViewController
/** 代理 */
@property(nonatomic, assign) id<YYPickerDelegate> delegate;

/** 初始数据 */
@property(nonatomic, copy) NSArray *data;

@end
