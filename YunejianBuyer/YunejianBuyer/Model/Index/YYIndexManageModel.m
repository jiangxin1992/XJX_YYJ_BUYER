//
//  YYIndexManageModel.m
//  YunejianBuyer
//
//  Created by yyj on 2017/8/8.
//  Copyright © 2017年 Apple. All rights reserved.
//

#import "YYIndexManageModel.h"

#import "YYUser.h"

@implementation YYIndexManageModel

-(BOOL )isAllowRendering{
    if(self){
        if([[YYUser currentUser] hasPermissionsToVisit]){
            if(self.bannerDataHaveBeenSuccessful && self.orderingDataHaveBeenSuccessful && self.hotDesignerBrandsDataHaveBeenSuccessful){
                return YES;
            }
        }else{
            if(self.bannerDataHaveBeenSuccessful){
                return YES;
            }
        }
    }
    return NO;
}
+(instancetype )initModel{
    YYIndexManageModel *tempModel = [[YYIndexManageModel alloc] init];
//    tempModel.latestSeriesListArray = [[NSMutableArray alloc] init];
    tempModel.bannerDataHaveBeenSuccessful = NO;
    tempModel.orderingDataHaveBeenSuccessful = NO;
    tempModel.hotDesignerBrandsDataHaveBeenSuccessful = NO;
//    tempModel.latestSeriesDataHaveBeenSuccessful = NO;
    return tempModel;
}
@end
