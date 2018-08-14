//
//  YYIndexTableHeadView.h
//  YunejianBuyer
//
//  Created by yyj on 2017/8/8.
//  Copyright © 2017年 Apple. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface YYIndexTableHeadView : UIView

-(instancetype)initWithFrame:(CGRect)frame WithBlock:(void(^)(NSString *type,NSInteger index))block;

/** banner列表 */
@property (strong, nonatomic) NSArray *bannerListModelArray;

-(void)updateUI;

@end
