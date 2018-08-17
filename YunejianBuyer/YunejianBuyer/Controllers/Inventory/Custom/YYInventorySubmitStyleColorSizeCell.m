//
//  YYInventorySubmitStyleColorSizeCell.m
//  YunejianBuyer
//
//  Created by Apple on 16/9/1.
//  Copyright © 2016年 Apple. All rights reserved.
//

#import "YYInventorySubmitStyleColorSizeCell.h"

#import "YYOrderSizeModel.h"
#import "UIView+UpdateAutoLayoutConstraints.h"

@interface YYInventorySubmitStyleColorSizeCell()<YYTableCellDelegate>
@property (weak, nonatomic) IBOutlet UILabel *lineView;

@end

@implementation YYInventorySubmitStyleColorSizeCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}
-(void)updateUI{

    if(!self.sizeInputArray){
        self.sizeInputArray = [[NSMutableArray alloc] init];
    }else{
        for (UIView *obj in self.sizeInputArray) {
            [obj removeFromSuperview];
        }
        [self.sizeInputArray removeAllObjects];
    }

    self.selectionStyle = UITableViewCellSelectionStyleNone;
    self.clothColorImage.backgroundColor = [UIColor whiteColor];
    self.clothColorImage.layer.borderWidth = 1;
    self.clothColorImage.layer.borderColor = [UIColor colorWithHex:@"d3d3d3"].CGColor;
    
    //设置颜色或者图片
    YYInventoryOneColorModel  *colorModel = _colorModel;
    if ([colorModel.value hasPrefix:@"#"] && [colorModel.value  length] == 7) {
        //16进制的色值
        UIColor *color = [UIColor colorWithHex:[colorModel.value  substringFromIndex:1]];
        UILabel *colorLab = [[UILabel alloc] init];
        colorLab.font = [UIFont systemFontOfSize:12];
        colorLab.backgroundColor = color;
        [self.clothColorImage addSubview:colorLab];
        [colorLab mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(self.clothColorImage.mas_top);
            make.left.mas_equalTo(self.clothColorImage.mas_left);
            make.width.mas_equalTo(self.clothColorImage.frame.size.width);
            make.height.mas_equalTo(self.clothColorImage.frame.size.height);
        }];
    }else{
        //图片
        NSString *imageRelativePath = colorModel.value;
        sd_downloadWebImageWithRelativePath(NO, imageRelativePath, self.clothColorImage, kStyleColorImageCover, 0);
    }
    
    NSInteger maxSizeCount = kMaxSizeCount;
    if ([_sizeArr count] < kMaxSizeCount) {
        maxSizeCount = [_sizeArr count];
    }
    YYOrderSizeModel *sizeModel = nil;
    YYOrderSizeModel *amountsizeModel = nil;
    UIView *lastView = nil;
    NSArray *_amountsizeArr= colorModel.sizeAmounts;
    NSInteger i = 0;
    for (; i<maxSizeCount; i++) {
        sizeModel = [_sizeArr objectAtIndex:i];
        YYShoppingStyleSizeInputView *sizeInput = [[YYShoppingStyleSizeInputView alloc] init];
        [self.contentView addSubview:sizeInput];
        [sizeInput mas_makeConstraints:^(MASConstraintMaker *make) {
            if(lastView){
                make.top.mas_equalTo(lastView.mas_bottom).with.offset(20);
            }else{
                make.top.mas_equalTo(20);
            }
            make.left.mas_equalTo(_clothColorImage.mas_right).with.offset(70);
            make.right.mas_equalTo(-17);
            make.height.mas_equalTo(30);
        }];
        sizeInput.hidden = NO;
        sizeInput.sizeNameLabel.text = sizeModel.name;
        sizeInput.minCount = 0;
        sizeInput.maxCount = LONG_MAX;
        if(_amountsizeArr && [_amountsizeArr count] > i){
            amountsizeModel = [_amountsizeArr objectAtIndex:i];
            sizeInput.value = (amountsizeModel && [amountsizeModel.amount integerValue] > 0) ? [amountsizeModel.amount integerValue] : 0;
        }else{
            sizeInput.value = 0;
        }
        sizeInput.index = i;
        sizeInput.delegate = self;
        lastView = sizeInput;
        [_sizeInputArray addObject:sizeInput];
    }

}

-(void)btnClick:(NSInteger)row section:(NSInteger)section andParmas:(NSArray *)parmas{
    if(self.delegate){
        [self.delegate btnClick:_indexPath.row section:_indexPath.section andParmas:@[@(row),[parmas objectAtIndex:0]]];
    }
}


-(void)setLineStyle:(NSInteger)isLast{
    if(isLast == 1){
        _lineView.hidden = NO;
        [_lineView setConstraintConstant:SCREEN_WIDTH forAttribute:NSLayoutAttributeWidth];
    }else if(isLast == 0) {
        _lineView.hidden = NO;
        [_lineView setConstraintConstant:SCREEN_WIDTH-24 forAttribute:NSLayoutAttributeWidth];
    }else {
        _lineView.hidden = YES;
    }
}
@end
