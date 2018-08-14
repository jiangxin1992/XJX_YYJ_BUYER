//
//  YYOrderInfoSectionHead.m
//  YunejianBuyer
//
//  Created by Apple on 16/1/28.
//  Copyright © 2016年 Apple. All rights reserved.
//

#import "YYOrderInfoSectionHead.h"

#import "YYOrderInfoModel.h"

@interface YYOrderInfoSectionHead()

@property (weak, nonatomic) IBOutlet UILabel *brandNameLabel;
@property (weak, nonatomic) IBOutlet UIButton *selectBtn;
@property (weak, nonatomic) IBOutlet UIButton *hideBtn;
@property (weak, nonatomic) IBOutlet UIView *lineView;

@end

@implementation YYOrderInfoSectionHead
#pragma mark - --------------生命周期--------------
- (void)awakeFromNib {
    [super awakeFromNib];
    [self SomePrepare];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}

#pragma mark - --------------SomePrepare--------------
- (void)SomePrepare
{
    [self PrepareData];
    [self PrepareUI];
}
- (void)PrepareData{}
- (void)PrepareUI{
    self.contentView.backgroundColor = _define_white_color;
}

#pragma mark - --------------UpdateUI----------------------
-(void)updateUI{
    _brandNameLabel.text = _orderIndoModel.brandName;
    if(_section == _selectBrandIndex){
        _selectBtn.selected = YES;
    }else{
        _selectBtn.selected = NO;
    }

    NSString *sectionKey = [NSString stringWithFormat:@"%ld",(long)_section];//indexPath.section
    if([_hidesectionKeyArr containsObject:sectionKey]){
        _hideBtn.selected = YES;
    }else{
        _hideBtn.selected = NO;
    }
    if(_section == 0){
        _lineView.hidden = YES;
    }else{
        _lineView.hidden = NO;
    }
}

//#pragma mark - --------------请求数据----------------------
//-(void)RequestData{}

#pragma mark - --------------自定义响应----------------------
- (IBAction)selectBtnHandler:(id)sender {
    if(self.delegate){
        [self.delegate btnClick:0 section:_section andParmas:@[@"select"]];
    }
}

- (IBAction)hideBtnHandler:(id)sender {
    if(self.delegate){

        [self.delegate btnClick:0 section:_section andParmas:@[@"hide"]];
    }
}

#pragma mark - --------------自定义方法----------------------


#pragma mark - --------------other----------------------


@end
