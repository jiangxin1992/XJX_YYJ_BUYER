//
//  YYBannerModel.h
//  YunejianBuyer
//
//  Created by yyj on 2017/8/8.
//  Copyright © 2017年 Apple. All rights reserved.
//
//首页banner model
#import <JSONModel/JSONModel.h>

@protocol YYBannerModel @end

@interface YYBannerModel : JSONModel

/** type有 LINK、HTML 两种类型 */
@property (strong, nonatomic) NSString <Optional>*type;
/** 链接地址 | 当type为HTML时有值 */
@property (strong, nonatomic) NSString <Optional>*link;
/** banner封面 */
@property (strong, nonatomic) NSString <Optional>*coverImg;

/** banner标题 */
@property (strong, nonatomic) NSString <Optional>*title;
/** PUBLISHED */
@property (strong, nonatomic) NSString <Optional>*status;
/** 权重 */
@property (strong, nonatomic) NSNumber <Optional>*sortWeight;
@property (strong, nonatomic) NSNumber <Optional>*createTime;
@property (strong, nonatomic) NSNumber <Optional>*id;
@property (strong, nonatomic) NSString <Optional>*location;
@property (strong, nonatomic) NSNumber <Optional>*modifyTime;
@property (strong, nonatomic) NSString <Optional>*pv;

@end
