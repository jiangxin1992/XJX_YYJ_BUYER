//
//  YYInventoryRecordCell.m
//  YunejianBuyer
//
//  Created by Victor on 2018/7/4.
//  Copyright © 2018年 Apple. All rights reserved.
//

#import "YYInventoryRecordCell.h"

@interface YYInventoryRecordCell ()

@property (nonatomic, strong) UILabel *warehouseNameLabel;
@property (nonatomic, strong) UILabel *operationTypeLabel;
@property (nonatomic, strong) UILabel *orderNumLabel;
@property (nonatomic, strong) UILabel *operatorLabel;
@property (nonatomic, strong) UILabel *timeDateLabel;
@property (nonatomic, strong) UILabel *productNumLabel;

@end

@implementation YYInventoryRecordCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseIdentifier]) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        
        WeakSelf(ws);
        self.warehouseNameLabel = [[UILabel alloc] init];
        self.warehouseNameLabel.textColor = _define_black_color;
        self.warehouseNameLabel.font = [UIFont systemFontOfSize:14];
        [self.contentView addSubview:self.warehouseNameLabel];
        [self.warehouseNameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(15);
            make.left.mas_equalTo(17);
        }];
        
        self.operationTypeLabel = [[UILabel alloc] init];
        self.operationTypeLabel.textColor = [UIColor colorWithRed:237 / 255.0 green:100 / 255.0 blue:152 / 255.0 alpha:1];
        self.operationTypeLabel.font = [UIFont systemFontOfSize:13];
        [self.contentView addSubview:self.operationTypeLabel];
        [self.operationTypeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.mas_equalTo(ws.warehouseNameLabel.mas_centerY);
            make.right.mas_equalTo(-17);
        }];
        
        self.orderNumLabel = [[UILabel alloc] init];
        self.orderNumLabel.textColor = [UIColor lightGrayColor];
        self.orderNumLabel.font = [UIFont systemFontOfSize:12];
        [self.contentView addSubview:self.orderNumLabel];
        [self.orderNumLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(ws.warehouseNameLabel.mas_bottom).with.offset(15);
            make.left.mas_equalTo(ws.warehouseNameLabel.mas_left);
        }];
        
        self.operatorLabel = [[UILabel alloc] init];
        self.operatorLabel.textColor = [UIColor lightGrayColor];
        self.operatorLabel.font = [UIFont systemFontOfSize:12];
        [self.contentView addSubview:self.operatorLabel];
        [self.operatorLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(ws.orderNumLabel.mas_bottom).with.offset(10);
            make.left.mas_equalTo(ws.warehouseNameLabel.mas_left);
        }];
        
        self.timeDateLabel = [[UILabel alloc] init];
        self.timeDateLabel.textColor = [UIColor lightGrayColor];
        self.timeDateLabel.font = [UIFont systemFontOfSize:12];
        [self.contentView addSubview:self.timeDateLabel];
        [self.timeDateLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(ws.operatorLabel.mas_bottom).with.offset(10);
            make.left.mas_equalTo(ws.warehouseNameLabel.mas_left);
            make.bottom.mas_equalTo(-15);
        }];
        
        self.productNumLabel = [[UILabel alloc] init];
        self.productNumLabel.textColor = [UIColor lightGrayColor];
        self.productNumLabel.font = [UIFont systemFontOfSize:12];
        [self.contentView addSubview:self.productNumLabel];
        [self.productNumLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.mas_equalTo(ws.timeDateLabel.mas_centerY);
            make.right.mas_equalTo(ws.operationTypeLabel.mas_right);
        }];
    }
    return self;
}

- (void)updateCellWithModel:(YYWarehouseRecordModel *)recordModel {
    self.warehouseNameLabel.text = recordModel.warehouseName;
    self.operationTypeLabel.text = recordModel.incomingName;
    self.orderNumLabel.text = [NSString stringWithFormat:NSLocalizedString(@"入库单号：%@", nil), recordModel.incomingBill];
    self.operatorLabel.text = [NSString stringWithFormat:NSLocalizedString(@"操作人：%@", nil), recordModel.creatorName];
    
    double timeInterval = [recordModel.createdTime doubleValue] / 1000;
    NSDate *createdTime = [NSDate dateWithTimeIntervalSince1970:timeInterval];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm"];
    self.timeDateLabel.text = [NSString stringWithFormat:NSLocalizedString(@"操作时间：%@", nil), [dateFormatter stringFromDate:createdTime]];
    
    self.productNumLabel.text = [NSString stringWithFormat:NSLocalizedString(@"商品数：%ld件", nil), [recordModel.itemCount integerValue]];
}

@end
