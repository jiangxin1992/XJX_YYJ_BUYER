//
//  YYRecommendDesignerBrandsModel.h
//  YunejianBuyer
//
//  Created by yyj on 2017/8/8.
//  Copyright © 2017年 Apple. All rights reserved.
//

#import <JSONModel/JSONModel.h>

@protocol YYRecommendDesignerBrandsModel @end

@interface YYRecommendDesignerBrandsModel : JSONModel

/** 设计师 id */
@property (strong, nonatomic) NSNumber <Optional>*designerId;
/** 品牌 logo */
@property (strong, nonatomic) NSString <Optional>*logoPath;
/** 品牌名 */
@property (strong, nonatomic) NSString <Optional>*brandName;
/** 设计师名 */
@property (strong, nonatomic) NSString <Optional>*nickName;
/** 设计师email */
@property (strong, nonatomic) NSString <Optional>*email;

@end
