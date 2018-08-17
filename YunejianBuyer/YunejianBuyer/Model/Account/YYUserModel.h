//
//  YYUserModel.h
//  Yunejian
//
//  Created by yyj on 15/7/13.
//  Copyright (c) 2015年 yyj. All rights reserved.
//

#import "JSONModel.h"

@interface YYUserModel : JSONModel

@property (strong, nonatomic) NSString <Optional>*name;
@property (strong, nonatomic) NSString <Optional>*id;
@property (strong, nonatomic) NSNumber <Optional>*type;
@property (strong, nonatomic) NSString <Optional>*email;
@property (strong, nonatomic) NSString <Optional>*logo;
@property (strong, nonatomic) NSNumber <Optional>*authStatus;
@property (strong, nonatomic) NSNumber <Optional>*checkStatus;//1:待提交文件 2:待审核 3:审核通过 4:审核拒绝 5:停止
@end
