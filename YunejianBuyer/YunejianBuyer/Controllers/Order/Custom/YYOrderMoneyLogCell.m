//
//  YYOrderMoneyLogCell.m
//  Yunejian
//
//  Created by Apple on 15/11/25.
//  Copyright © 2015年 yyj. All rights reserved.
//

#import "YYOrderMoneyLogCell.h"

#import "UIView+UpdateAutoLayoutConstraints.h"
#import "YYOrderPayLogCell.h"
#import "YYYellowPanelManage.h"

@implementation YYOrderMoneyLogCell{
    NSArray* reversedArray;
    UITableView *payListTableView;
}

-(void)updateUI{
    self.contentView.layer.masksToBounds = YES;
    self.addLogBtn.layer.cornerRadius = 2.5;
    self.addLogBtn.layer.masksToBounds = YES;

    if(self.isPaylistShow == 0){
        self.paylistShowBtn.selected = NO;
    }else{
        self.paylistShowBtn.selected = YES;
    }

    NSInteger tranStatus = getOrderTransStatus(self.currentYYOrderTransStatusModel.designerTransStatus, self.currentYYOrderTransStatusModel.buyerTransStatus);
    NSString *hasMoneycolorStr = nil;
    if(tranStatus == kOrderCode_CLOSE_REQ || [self.currentYYOrderInfoModel.closeReqStatus integerValue] == -1){
        tranStatus = kOrderCode_CLOSE_REQ;
        hasMoneycolorStr = kDefaultBorderColor;
    }else{
        hasMoneycolorStr = @"ed6498";
    }
    
    float rndValue =  0;
    NSMutableParagraphStyle *paraStyle = [[NSMutableParagraphStyle alloc] init];
    paraStyle.paragraphSpacingBefore = 10;
    paraStyle.firstLineHeadIndent = 10;
    
    if(_paymentNoteList == nil || [_paymentNoteList.result count] == 0){
        self.paylistShowBtn.hidden = YES;
        reversedArray = nil;
    }else{
        NSMutableArray *infoLogArr = [[NSMutableArray alloc] init];
        for (YYPaymentNoteModel *noteModel in _paymentNoteList.result) {
            [infoLogArr addObject:replaceMoneyFlag([NSString stringWithFormat:NSLocalizedString(@"%@ %@%d%@ ￥%.2f",nil),getShowDateByFormatAndTimeInterval(@"yyyy/MM/dd HH:mm",[noteModel.createTime stringValue]),NSLocalizedString(@"付款",nil),[noteModel.percent integerValue],@"%",[noteModel.amount floatValue]],[_currentYYOrderInfoModel.curType integerValue])];
            if([noteModel.payType integerValue] == 0 && ([noteModel.payStatus integerValue] == 0 || [noteModel.payStatus integerValue] == 2)){
            }else{
                rndValue += [noteModel.percent floatValue];
            }
        }
        reversedArray = [[infoLogArr reverseObjectEnumerator] allObjects];
        if([infoLogArr count] > 1){
            self.paylistShowBtn.hidden = NO;
        }else{
            self.paylistShowBtn.hidden = YES;
        }

        rndValue = rndValue/100;
    }

    NSInteger progressValue= rndValue*100;
    NSString *btnTxt = NSLocalizedString(@"查看详情",nil);
    NSInteger txtlength = [NSString stringWithFormat:@"%ld",(long)progressValue].length;
    NSInteger btnTxtlength = btnTxt.length;
    NSString *payStr = [NSString stringWithFormat:NSLocalizedString(@"%d%@%@  %@",nil),progressValue,@"% ",NSLocalizedString(@"货款已付",nil),btnTxt];
    NSMutableAttributedString *attributedStr = [[NSMutableAttributedString alloc] initWithString: payStr];
    [attributedStr addAttribute: NSFontAttributeName value: [UIFont systemFontOfSize:13] range: NSMakeRange(txtlength, payStr.length-txtlength)];
    [attributedStr addAttribute: NSForegroundColorAttributeName value: [UIColor colorWithHex:hasMoneycolorStr] range: NSMakeRange(0, txtlength+1)];
    [attributedStr addAttribute:NSUnderlineStyleAttributeName value:@(NSUnderlineStyleSingle) range:NSMakeRange(payStr.length - btnTxtlength, btnTxtlength)];

    self.hasMoneyLabel.attributedText = attributedStr;
    CGSize hasMoneyTxtSize = [payStr sizeWithAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:13]}];
    [self.hasMoneyLabel setConstraintConstant:(hasMoneyTxtSize.width + txtlength*21) forAttribute:NSLayoutAttributeWidth];
    self.addLogBtn.hidden = NO;
    if(tranStatus ==0  || progressValue >= 100   || tranStatus == kOrderCode_CANCELLED || tranStatus == kOrderCode_CLOSED || tranStatus == kOrderCode_CLOSE_REQ || tranStatus == kOrderCode_NEGOTIATION){//
        self.addLogBtn.enabled = NO;
    }else{
        self.addLogBtn.enabled = YES;
    }
    if(self.addLogBtn.enabled == YES){
        self.addLogBtn.backgroundColor = [UIColor blackColor];
    }else{
        self.addLogBtn.backgroundColor = [UIColor colorWithHex:@"d3d3d3"];
    }
}
- (IBAction)helpBtnHandler:(id)sender {
    NSInteger helpPanelType = 2;//
    UIView *parentview = ((UIViewController *)_delegate).view;
    [[YYYellowPanelManage instance] showhelpPanelWidthParentView:parentview helpPanelType:helpPanelType andCallBack:^(NSArray *value) {
        
    }];
}

- (IBAction)showMoneyLogView:(id)sender {
    if(!self.addLogBtn.enabled){//
        return;
    }
    if(self.delegate){
        [self.delegate btnClick:0 section:0 andParmas:@[@"paylog"]];
    }
}
- (IBAction)showMoneyLogDetail:(id)sender {
    if(reversedArray == nil || [reversedArray count] == 0){
        [YYToast showToastWithTitle:NSLocalizedString(@"无付款记录",nil) andDuration:kAlertToastDuration];
        return;
    }
    if(self.delegate){
        [self.delegate btnClick:0 section:0 andParmas:@[@"payloglist"]];
    }
}

+(float)cellHeight:(NSArray *)payNoteList tranStatus:(NSInteger)tranStatus isPaylistShow:(NSInteger)isPaylistShow{
    return 71;
}
- (IBAction)showPaylistVIew:(id)sender {
    if(self.delegate){
        [self.delegate btnClick:0 section:0 andParmas:@[@"paylistShow",]];
    }
}
#pragma tableView
-(UITableView *)listTableView{
    if(payListTableView == nil){
        payListTableView = [[UITableView alloc] init];
        payListTableView.delegate = self;
        payListTableView.dataSource = self;
        payListTableView.contentInset = UIEdgeInsetsMake(25, 0, 0, 0);
        payListTableView.separatorColor = [UIColor colorWithHex:@"d3d3d300"];
        //payListTableView.separatorInset = UIEdgeInsetsMake(0, 17, 0, 17);
        payListTableView.backgroundColor = [UIColor whiteColor];
        
        [payListTableView registerNib:[UINib nibWithNibName:@"YYOrderPayLogCell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:@"YYOrderPayLogCell"];

    }
    return payListTableView;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [reversedArray count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{

    return 44;
}


- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"YYOrderPayLogCell";
    YYOrderPayLogCell *cell1 = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    NSString *info = [reversedArray objectAtIndex:indexPath.row];
    [cell1 updateCellInfo:@[info]];
    return cell1;
}
#pragma mark - Other

- (void)awakeFromNib {
    // Initialization code
    [super awakeFromNib];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}
@end
