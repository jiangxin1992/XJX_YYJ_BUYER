//
//  YYPerfectInfoModel.h
//  YunejianBuyer
//
//  Created by chuanjun sun on 2017/10/23.
//  Copyright © 2017年 Apple. All rights reserved.
//  隐藏买手账号完善信息  post提交

#import "CJRootModel.h"

@interface YYPerfectInfoModel : CJRootModel
/** 买手店名称 */
@property (nonatomic, copy) NSString *shopName;
/** 联系人名称 */
@property (nonatomic, copy) NSString *contactName;
/** 联系人电话 */
@property (nonatomic, copy) NSString *contactPhone;
/** 国家 */
@property (nonatomic, copy) NSString *nation;
/** 国家id */
@property (nonatomic, strong) NSNumber *nationId;
/** 省份 */
@property (nonatomic, copy) NSString *province;
/** 省份ID */
@property (nonatomic, strong) NSNumber *provinceId;
/** 城市 */
@property (nonatomic, copy) NSString *city;
/** 城市Id */
@property (nonatomic, strong) NSNumber *cityId;
/** 详细地址 */
@property (nonatomic, copy) NSString *addressDetail;
/** 法人身份证正面照片 */
@property (nonatomic, copy) NSString *legalPersonFiles;
/** 店铺营业执照 */
@property (nonatomic, copy) NSString *licenceFile;
/** 零售价范围-低 */
@property (nonatomic, assign) CGFloat priceMin;
/** 零售价范围-高 */
@property (nonatomic, assign) CGFloat priceMax;
/** 合作品牌（多个用逗号隔开） */
@property (nonatomic, copy) NSArray *copBrands;
/** 买手店简介 */
@property (nonatomic, copy) NSString *introduction;
/** 买手店照片 */
@property (nonatomic, copy) NSString *storeImgs;
/** 买手店社交账号 */
@property (nonatomic, copy) NSArray *userSocialInfos;
@end
