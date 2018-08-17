//
//  YYUser.m
//  Yunejian
//
//  Created by yyj on 15/7/10.
//  Copyright (c) 2015年 yyj. All rights reserved.
//

#import "YYUser.h"
#import "UserDefaultsMacro.h"
#import "YYUserApi.h"
#import "JpushHandler.h"

#define kYYUsernameKey @"kYYUsernameKey"
#define kYYUserEmailKey @"kYYUserEmailKey"
#define kYYPasswordKey @"kYYPasswordKey"
#define kYYUserTypeKey @"kYYUserTypeKey"
#define kYYUserIdKey @"kYYUserIdKey"
#define kYYUserLogoKey @"kYYUserLogoKey"
#define kYYUserStatusKey @"kYYUserStatusKey"
#define kYYUserCheckStatusKey @"kYYUserCheckStatusKey"
#define kYYUserNewsKey @"kYYUserNewsKey"
#define kYYUserStockEnableKey @"kYYUserStockEnableKey"


@implementation YYUser
static YYUser *currentUser = nil;
-(BOOL)isEqual:(id)object{
    if([self class] == [object class]){
        return [self isEqualToUser:object];
    }else{
        return [super isEqual:object];
    }
}
-(BOOL)isEqualToUser:(YYUser *)object{
    if(self == object){
        return YES;
    }
    if(![self.userId isEqualToString:object.userId]){
        return NO;
    }
    if(![self.name isEqualToString:object.name]){
        return NO;
    }
    if(![self.email isEqualToString:object.email]){
        return NO;
    }
    if(![self.tokenId isEqualToString:object.tokenId]){
        return NO;
    }
    if(![self.password isEqualToString:object.password]){
        return NO;
    }
    if(![self.logo isEqualToString:object.logo]){
        return NO;
    }
    if(![self.status isEqualToString:object.status]){
        return NO;
    }
    if(self.checkStatus !=object.status){
        return NO;
    }
    if (self.stockEnable != object.stockEnable) {
        return NO;
    }
    return YES;
}
- (void )updateUserCheckStatus{
    if(![self hasPermissionsToVisit]){
        NSInteger locCheckStatus = [self.checkStatus integerValue];
        if(locCheckStatus != 3){
            // 因为在appdelegate中回调用此方法，第一次加载时调用此方法由于没有用户名和密码，会调用代理跳转到登陆界面，导致第一次的引导页失效，
            // 所以在此判断只有当用户名和密码都存在时，才调用此方法，不知道江新当时的设计理念是什么，等他回来再问问
            if (self.email && self.password) {
                [YYUserApi getQuickBuyerInfoBlock:^(YYRspStatusAndMessage *rspStatusAndMessage, NSString *checkStatus, NSError *error) {
                    currentUser.checkStatus = checkStatus;
                    [self saveUserData];
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [[NSNotificationCenter defaultCenter] postNotificationName:UserCheckStatusChangeNotification object:nil userInfo:nil];
                    });
                }];
            }
        }
    }
}
- (BOOL )hasPermissionsToVisit{
    if(![NSString isNilOrEmpty:self.userId]){
        //登陆
        if([NSString isNilOrEmpty:self.checkStatus]){
            //为空就是正常买手
            return YES;
        }else{
            //不为空就是隐身买手账户
            //1:待提交文件 2:待审核 3:审核通过 4:审核拒绝 5:停止
            if([self.checkStatus integerValue] == 3){
                return YES;
            }else{
                return NO;
            }
        }
    }
    return NO;
}

+(id)allocWithZone:(struct _NSZone *)zone{
    static dispatch_once_t predicate;
    dispatch_once(&predicate, ^{
        currentUser = [super allocWithZone:zone];
    });
    return currentUser;
}
+ (BOOL )getNewsReadStateWithType:(NSInteger )type
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSString *typeStr = type==1?@"newHomePage":@"newEdit";
    YYUser *user = [YYUser currentUser];
    NSString *email = user.email;
    if(![NSString isNilOrEmpty:typeStr]&&![NSString isNilOrEmpty:email])
    {
        if([userDefaults objectForKey:kYYUserNewsKey])
        {
            //有值
            if([[userDefaults objectForKey:kYYUserNewsKey] objectForKey:typeStr])
            {
                NSArray *tempArr = [[userDefaults objectForKey:kYYUserNewsKey] objectForKey:typeStr];
                __block BOOL isexit = NO;
                __block NSUInteger tempidx = 0;
                [tempArr enumerateObjectsUsingBlock:^(NSDictionary *obj, NSUInteger idx, BOOL * _Nonnull stop) {
                    if([[obj objectForKey:@"email"]isEqualToString:email])
                    {
                        isexit = YES;
                        tempidx = idx;
                        *stop = YES;
                    }
                }];
                if(!isexit)
                {
                    return NO;
                }else
                {
                    return [[[tempArr objectAtIndex:tempidx] objectForKey:@"isread"] boolValue];
                }
            }else
            {
                return NO;
            }
        }else
        {
            return NO;
        }
    }
    return NO;
}
+ (void )saveNewsReadStateWithType:(NSInteger )type
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSString *typeStr = type==1?@"newHomePage":@"newEdit";
    YYUser *user = [YYUser currentUser];
    NSString *email = user.email;
    if(![NSString isNilOrEmpty:typeStr]&&![NSString isNilOrEmpty:email])
    {
        
        if([userDefaults objectForKey:kYYUserNewsKey])
        {
            //有值
            if([[userDefaults objectForKey:kYYUserNewsKey] objectForKey:typeStr])
            {
                //有值
                NSMutableDictionary *tempDict = [[userDefaults objectForKey:kYYUserNewsKey] mutableCopy];
                NSMutableArray *tempArr = [[[userDefaults objectForKey:kYYUserNewsKey] objectForKey:typeStr] mutableCopy];
                __block BOOL isexit = NO;
                __block NSUInteger tempidx = 0;
                [tempArr enumerateObjectsUsingBlock:^(NSDictionary *obj, NSUInteger idx, BOOL * _Nonnull stop) {
                    if(![NSString isNilOrEmpty:[obj objectForKey:@"email"]])
                    {
                        if([[obj objectForKey:@"email"] isEqualToString:email])
                        {
                            isexit = YES;
                            tempidx = idx;
                        }
                    }
                }];
                if(!isexit)
                {
                    [tempArr addObject:@{@"email":email,@"isread":@(YES)}];
                }else
                {
                    BOOL tempisread = [[[tempArr objectAtIndex:tempidx] objectForKey:@"isread"] boolValue];
                    if(!tempisread)
                    {
                        [tempArr replaceObjectAtIndex:tempidx withObject:@{@"email":email,@"isread":@(YES)}];
                    }
                }
                [tempDict setObject:[tempArr copy] forKey:typeStr];
                [userDefaults setObject:tempDict forKey:kYYUserNewsKey];
            }else
            {
                NSMutableDictionary *tempDict = [[userDefaults objectForKey:kYYUserNewsKey] mutableCopy];
                [tempDict setObject:@[@{@"email":email,@"isread":@(YES)}] forKey:typeStr];
                [userDefaults setObject:tempDict forKey:kYYUserNewsKey];
            }
        }else
        {
            [userDefaults setObject:@{typeStr:@[@{@"email":email,@"isread":@(YES)}]} forKey:kYYUserNewsKey];
        }
        [userDefaults synchronize];
    }
}
+ (YYUser *)currentUser
{
    
    if (!currentUser) {
        currentUser = [[self alloc] init];
    }
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    
    currentUser.name = [userDefaults objectForKey:kYYUsernameKey];
    currentUser.email = [userDefaults objectForKey:kYYUserEmailKey];
    currentUser.password = [userDefaults objectForKey:kYYPasswordKey];
    currentUser.userType = [userDefaults integerForKey:kYYUserTypeKey];
    currentUser.userId = [userDefaults objectForKey:kYYUserIdKey];
    currentUser.logo = [userDefaults objectForKey:kYYUserLogoKey];
    currentUser.status = [userDefaults objectForKey:kYYUserStatusKey];
    currentUser.checkStatus = [userDefaults objectForKey:kYYUserCheckStatusKey];
    currentUser.stockEnable = [userDefaults boolForKey:kYYUserStockEnableKey];
    return currentUser;
}

- (void)saveUserWithEmail:(NSString *)email password:(NSString *)password userInfo:(YYUserModel *)userModel {
    currentUser.name = userModel.name;
    currentUser.email = email;
    currentUser.password = password;
    currentUser.userType = [userModel.type intValue];
    currentUser.userId = userModel.id;
    currentUser.logo = userModel.logo;
    currentUser.status = [userModel.authStatus stringValue];
    currentUser.checkStatus = userModel.checkStatus ? [userModel.checkStatus stringValue] : nil;
    currentUser.stockEnable = [userModel.buyerNormal boolValue];
    [self saveUserData];
    //    [JpushHandler sendUserIdToAlias];
    [JpushHandler sendTagsAndAlias];
}

- (void)saveUserData{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setObject:_name forKey:kYYUsernameKey];
    [userDefaults setObject:_email forKey:kYYUserEmailKey];
    [userDefaults setObject:_password forKey:kYYPasswordKey];
    [userDefaults setInteger:_userType forKey:kYYUserTypeKey];
    [userDefaults setObject:_userId forKey:kYYUserIdKey];
    [userDefaults setObject:_logo forKey:kYYUserLogoKey];
    [userDefaults setObject:_status forKey:kYYUserStatusKey];
    [userDefaults setObject:_checkStatus forKey:kYYUserCheckStatusKey];
    [userDefaults setBool:self.stockEnable forKey:kYYUserStockEnableKey];

    [userDefaults synchronize];
}


- (void)loginOut{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setObject:nil forKey:kYYUsernameKey];
    [userDefaults setObject:nil forKey:kYYUserEmailKey];
    [userDefaults setObject:nil forKey:kYYPasswordKey];
    [userDefaults setInteger:-1 forKey:kYYUserTypeKey];
    [userDefaults setObject:nil forKey:kYYUserIdKey];
    [userDefaults setObject:nil forKey:kYYUserLogoKey];
    
    [userDefaults setObject:nil forKey:kUserLoginTokenKey];
    [userDefaults setObject:nil forKey:kScrtKey];
    [userDefaults setObject:nil forKey:kYYUserStatusKey];
    [userDefaults setObject:nil forKey:kYYUserCheckStatusKey];
    [userDefaults setBool:NO forKey:kYYUserStockEnableKey];
    
    [userDefaults synchronize];
    [JpushHandler sendEmptyAlias];
}
@end
