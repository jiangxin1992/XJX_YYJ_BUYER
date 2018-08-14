//
//  YYVisibleContactInfoTableViewCell.h
//  YunejianBuyer
//
//  Created by chuanjun sun on 2017/10/25.
//  Copyright © 2017年 Apple. All rights reserved.
//

#import <UIKit/UIKit.h>

@class YYVisibleContactInfoTableViewCell;

@protocol YYVisibleContactInfoCellDelegate <NSObject>

@optional
- (void)YYVisibleCellselectClick:(YYVisibleContactInfoTableViewCell *)cell;

// 输入框变化
- (void)YYVisibleCellInputChange:(YYVisibleContactInfoTableViewCell *)cell text:(NSString *)text;
@end

@interface YYVisibleContactInfoTableViewCell : UITableViewCell

/** titleImage */
@property (nonatomic, copy) NSString *titleImageName;
/** inputPlaceHode */
@property (nonatomic, copy) NSString *inputPlaceHode;
/** tipsView */
@property (nonatomic, copy) NSString *TipViewName;
/** 默认值 */
@property (nonatomic, copy) NSString *inputText;
/** 输入框变成按钮 */
@property (nonatomic, assign) BOOL isShowButton;
/** 是否允许编辑 */
@property (nonatomic, assign) BOOL isEditing;


/** indexpath */
@property (nonatomic, strong) NSIndexPath *indexPath;

/** delegate */
@property (nonatomic, weak)id<YYVisibleContactInfoCellDelegate> delegate;

@end
