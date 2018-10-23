
//
//  main.m
//  Yunejian
//
//  Created by yyj on 15/7/3.
//  Copyright (c) 2015年 yyj. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppDelegate.h"
//#import "person.h"
//#import <framework_test/framework_test.h>

CFAbsoluteTime StartTime;

int main(int argc, char * argv[]) {
    StartTime = CFAbsoluteTimeGetCurrent();
    @autoreleasepool {
//        [person personrun];
//        [animal_dog dogrun];
//        [animal_dog dogeat];
        [LanguageManager setupCurrentLanguage];
        return UIApplicationMain(argc, argv, nil, NSStringFromClass([AppDelegate class]));
    }
}
