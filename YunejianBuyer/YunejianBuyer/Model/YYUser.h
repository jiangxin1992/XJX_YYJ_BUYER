//
//  YYUser.h
//  Yunejian
//
//  Created by yyj on 15/7/10.
//  Copyright (c) 2015年 yyj. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "YYUserModel.h"

@interface YYUser : NSObject

@property (nonatomic, copy) NSString *userId;
@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSString *email;
@property (nonatomic, copy) NSString *tokenId;      // 登录成功后的tokenId
@property (nonatomic, copy) NSString *password;
@property (nonatomic, copy) NSString *logo;
@property (nonatomic, copy) NSString *status;//300 //审核中301 //审核被 303 //需要审核
@property (nonatomic, copy) NSString *checkStatus;//1:待提交文件 2:待审核 3:审核通过 4:审核拒绝 5:停止

@property (nonatomic, assign) YYUserType userType;//用户类型 0:设计师 1:买手店、admin 2:销售代表 5:Showroom 6:Showroom子账号 11:品牌主管 12:店长 13:财务 14:店员 15:仓库管理员
@property (nonatomic, assign) BOOL stockEnable;//是否开通库存管理

//获取当前用户
+ (YYUser *)currentUser;
/**
更新隐身账户的checkstatus（如果是隐身账户的话）

 @return ...
 */
- (void )updateUserCheckStatus;
/**
 是否有权限访问（是否是隐身账户）

 @return yes：不是 no：是
 */
- (BOOL )hasPermissionsToVisit;

//保存用户数据
- (void)saveUserWithEmail:(NSString *)email password:(NSString *)password userInfo:(YYUserModel *)userModel;
- (void)saveUserData;
//登出
- (void)loginOut;
//存取new的状态，根据不同账号的不同版本 1新增主页
+ (void)saveNewsReadStateWithType:(NSInteger )type;
+ (BOOL)getNewsReadStateWithType:(NSInteger )type;


@end
