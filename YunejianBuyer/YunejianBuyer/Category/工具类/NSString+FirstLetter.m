//
//  NSString+FirstLetter.m
//  YunejianBuyer
//
//  Created by Victor on 2018/7/25.
//  Copyright © 2018年 Apple. All rights reserved.
//

#import "NSString+FirstLetter.h"

#define HANZI_START 19968
#define HANZI_COUNT 20902

@implementation NSString (FirstLetter)

- (NSString *)getFirstLetter
{
    NSString *words = [self stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    if (words.length == 0) {
        return nil;
    }
    NSString *result = nil;
    unichar firstLetter = [words characterAtIndex:0];
    
    int index = firstLetter - HANZI_START;
    if (index >= 0 && index <= HANZI_COUNT) {
        result = [NSString stringWithFormat:@"%c", [[words transformToPinyin] characterAtIndex:0]];
    } else if ((firstLetter >= 'a' && firstLetter <= 'z') || (firstLetter >= 'A' && firstLetter <= 'Z')) {
        result = [NSString stringWithFormat:@"%c", firstLetter];
    } else {
        result = @"#";
    }
    return [result uppercaseString];
}

@end
