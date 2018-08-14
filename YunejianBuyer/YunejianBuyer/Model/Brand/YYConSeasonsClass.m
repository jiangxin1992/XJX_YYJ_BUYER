//
//  YYConSeasonsClass.m
//  YunejianBuyer
//
//  Created by yyj on 2017/7/5.
//  Copyright © 2017年 Apple. All rights reserved.
//

#import "YYConSeasonsClass.h"

@implementation YYConSeasonsClass

-(NSString *)getShowName{
    if(self){
        BOOL isenglish = [LanguageManager isEnglishLanguage];
        if(isenglish){
            if(![NSString isNilOrEmpty:self.nameEn]){
                return self.nameEn;
            }
        }else{
            return self.name;
        }
    }
    return @"";
}

@end
