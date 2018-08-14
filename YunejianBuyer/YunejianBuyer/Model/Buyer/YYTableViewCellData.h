//
//  YYTableViewCellData.h
//  Yunejian
//
//  Created by Apple on 15/9/24.
//  Copyright (c) 2015年 yyj. All rights reserved.
//

#import <Foundation/Foundation.h>
typedef NS_ENUM(NSInteger, RegisterTableCellType) {
    RegisterTableCellTypeHead = 1,
    RegisterTableCellTypeInput = 2,
    RegisterTableCellTypeSaleInfo = 3,
    RegisterTableCellTypeCanal = 4,
    RegisterTableCellTypeSubmit = 5,
    RegisterTableCellTypeArea = 6,
    RegisterTableCellTypeBrandRegisterType = 7,
    RegisterTableCellTypeBrandRegisterUpload = 8,
    RegisterTableCellTypeBuyerRegisterUpload = 9,
    RegisterTableCellTypeBuyerPriceRang = 10,
    RegisterTableCellTypeConnBrand = 11,
    RegisterTableCellTypeBuyerPhotos = 12,
    RegisterTableCellTypeIntroduce = 13,
    RegisterTableCellTypeTitle = 14,
    RegisterTableCellStep = 15,
    RegisterTableCellSpace = 16,
    RegisterTableCellTypeSubmitBtn = 17,
    RegisterTableCellTypeEmailVerify = 18,
    RegisterTableCellTypePayType = 19,
    RegisterTableCellTypeIconTitle = 20
};


@interface YYTableViewCellData : NSObject
@property  NSInteger type;  //RegisterTableCellType, 只用于Register相关页面

/**自定义Cell**/
@property (nonatomic, strong) NSString *reuseIdentifier;
@property (nonatomic,strong) id object;
/****/

/**系统定义的4个Cell**/
@property (nonatomic, assign) UITableViewCellStyle tableViewCellStyle;
@property (nonatomic, strong) NSString *text;
@property (nonatomic, strong) NSString *detailText;
@property (nonatomic, strong) UIColor *textColor;
@property (nonatomic, strong) UIColor *detailTextColor;
@property (nonatomic, strong) UIFont *textFont;
@property (nonatomic, strong) UIFont *detailTextFont;
@property (nonatomic, assign) UITableViewCellAccessoryType accessoryType;
@property (nonatomic, strong) UIView *accessoryView;
/****/

/**公用部分**/
@property (nonatomic, assign) BOOL useDynamicRowHeight;
@property (nonatomic, assign) CGFloat estimatedRowHeight;
@property (nonatomic, assign) CGFloat tableViewCellRowHeight;

@property (nonatomic, copy) void(^dynamicCellBlock)(UITableViewCell *cell, NSIndexPath *indexPath);
@property (nonatomic, copy) CGFloat(^dynamicCellRowHeight)(void);
@property (nonatomic, copy) void(^selectedCellBlock)(UITableView *tableView, NSIndexPath *indexPath);
/****/

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath;
- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath;
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath;
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath;

@end
