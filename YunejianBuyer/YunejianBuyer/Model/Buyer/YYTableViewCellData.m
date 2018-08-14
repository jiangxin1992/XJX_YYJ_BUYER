//
//  YYTableViewCellData.m
//  Yunejian
//
//  Created by Apple on 15/9/24.
//  Copyright (c) 2015年 yyj. All rights reserved.
//

#import "YYTableViewCellData.h"

@implementation YYTableViewCellData

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *identifier = nil;
    switch (self.tableViewCellStyle) {
        case UITableViewCellStyleDefault:
            identifier = @"UITableViewCellStyleDefault";
            break;
        case UITableViewCellStyleSubtitle:
            identifier = @"UITableViewCellStyleSubtitle";
            break;
        case UITableViewCellStyleValue1:
            identifier = @"UITableViewCellStyleValue1";
            break;
        case UITableViewCellStyleValue2:
            identifier = @"UITableViewCellStyleValue2";
            break;
        default:
            break;
    }
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:self.tableViewCellStyle reuseIdentifier:identifier];
    }
    if (self.dynamicCellBlock) {
        self.dynamicCellBlock(cell, indexPath);
    }else {
        cell.textLabel.text = self.text;
        cell.textLabel.textColor = self.textColor;
        cell.detailTextLabel.text = self.detailText;
        cell.detailTextLabel.textColor = self.detailTextColor;
        if (self.accessoryView) {
            cell.accessoryView = self.accessoryView;
            cell.accessoryType = UITableViewCellAccessoryNone;
        }else {
            cell.accessoryView = nil;
            cell.accessoryType = self.accessoryType;
        }
    }
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (self.estimatedRowHeight > 0) {
        return self.estimatedRowHeight;
    } else {
        return 44;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (self.useDynamicRowHeight) {
        if (self.dynamicCellRowHeight) {
            return self.dynamicCellRowHeight();
        } else {
            return UITableViewAutomaticDimension;
        }
    } else {
        return self.tableViewCellRowHeight;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (self.selectedCellBlock) {
        self.selectedCellBlock(tableView, indexPath);
    }
}

@end
