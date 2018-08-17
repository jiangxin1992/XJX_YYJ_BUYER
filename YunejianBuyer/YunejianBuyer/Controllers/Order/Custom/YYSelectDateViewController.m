//
//  YYSelectDateViewController.m
//  Yunejian
//
//  Created by yyj on 15/8/19.
//  Copyright (c) 2015年 yyj. All rights reserved.
//

#import "YYSelectDateViewController.h"

@interface YYSelectDateViewController ()

@property (weak, nonatomic) IBOutlet UIDatePicker *datePicker;

@end

@implementation YYSelectDateViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    NSLocale *locale = [[NSLocale alloc] initWithLocaleIdentifier:@"zh_CN"];//设置为中
    _datePicker.locale = locale;
    
    
//    double  oneYear = 60*60*24*1000*365.0;  //1年的毫秒数
   
//    
//    NSDate *begingDate = nil;
//    NSDate *endDate = nil;
    
    if (self.currentYYOrderInfoModel
        && self.currentYYOrderInfoModel.orderCreateTime) {
//        double createTime = [self.currentYYOrderInfoModel.orderCreateTime doubleValue];
        
//        if (_isBeginDate) {
//            //发货开始时间
//            if (_orderOneInfoModel.tmpSupplyEndTime) {
//                //如果已经有截止时间
//                double endTime = [_orderOneInfoModel.supplyEndTime doubleValue];
//                if (_orderOneInfoModel.tmpSupplyStartTime
//                    && endTime >= [_orderOneInfoModel.tmpSupplyStartTime doubleValue]) {
//                    double beginTime = [_orderOneInfoModel.tmpSupplyStartTime doubleValue];
//                    begingDate = [NSDate dateWithTimeIntervalSince1970:beginTime/1000];
//                    self.datePicker.date = begingDate;
//                }else{
//                    begingDate = [NSDate dateWithTimeIntervalSince1970:(endTime-oneYear)/1000];
//                }
//                endDate = [NSDate dateWithTimeIntervalSince1970:endTime/1000];
//            }else{
//                //如果没有截止时间
//                if (_orderOneInfoModel.tmpSupplyStartTime) {
//                    double beginTime = [_orderOneInfoModel.tmpSupplyStartTime doubleValue];
//                    begingDate = [NSDate dateWithTimeIntervalSince1970:beginTime/1000];
//                    endDate = [NSDate dateWithTimeIntervalSince1970:(beginTime+oneYear)/1000];
//                    self.datePicker.date = begingDate;
//
//                }else{
//                    begingDate = [NSDate dateWithTimeIntervalSince1970:(createTime-oneYear)/1000];
//                    endDate = [NSDate dateWithTimeIntervalSince1970:(createTime+oneYear)/1000];
//                }
//            }
//        }else{
//            //发货截止时间
//            if (_orderOneInfoModel.tmpSupplyStartTime) {
//                //如果已经有开始时间
//                double beginTime = [_orderOneInfoModel.supplyStartTime doubleValue];
//                begingDate = [NSDate dateWithTimeIntervalSince1970:beginTime/1000];
//                if (_orderOneInfoModel.tmpSupplyEndTime
//                    && beginTime <= [_orderOneInfoModel.tmpSupplyEndTime doubleValue]) {
//                    double endTime = [_orderOneInfoModel.tmpSupplyEndTime doubleValue];
//                    endDate = [NSDate dateWithTimeIntervalSince1970:endTime/1000];
//                    self.datePicker.date = endDate;
//
//                }else{
//                    endDate = [NSDate dateWithTimeIntervalSince1970:(beginTime+oneYear)/1000];
//                }
//            }else{
//                if (_orderOneInfoModel.tmpSupplyEndTime){
//                    double endTime = [_orderOneInfoModel.tmpSupplyEndTime doubleValue];
//                    begingDate = [NSDate dateWithTimeIntervalSince1970:(endTime-oneYear)/1000];
//                    endDate = [NSDate dateWithTimeIntervalSince1970:endTime/1000];
//                    self.datePicker.date = endDate;
//                }else{
//                    begingDate = [NSDate dateWithTimeIntervalSince1970:(createTime-oneYear)/1000];
//                    endDate = [NSDate dateWithTimeIntervalSince1970:(createTime+oneYear)/1000];
//                }
//            }
//        }
//
//        _datePicker.minimumDate = begingDate;
//        _datePicker.maximumDate = endDate;
        
//        if(_orderOneInfoModel.tmpSupplyEndTime) {
//            double endTime = [_orderOneInfoModel.tmpSupplyEndTime doubleValue];
//            endDate = [NSDate dateWithTimeIntervalSince1970:endTime/1000];
//            _datePicker.maximumDate = endDate;
//        }
//        if(_orderOneInfoModel.tmpSupplyStartTime){
//            double beginTime = [_orderOneInfoModel.supplyStartTime doubleValue];
//            begingDate = [NSDate dateWithTimeIntervalSince1970:beginTime/1000];
//            _datePicker.minimumDate = begingDate;
//        }
        
        self.datePicker.datePickerMode = UIDatePickerModeDate;
        NSDate* date = _datePicker.date;
//        if (_isBeginDate) {
//            if (_orderOneInfoModel.tmpSupplyStartTime) {
//                    double beginTime = [_orderOneInfoModel.tmpSupplyStartTime doubleValue];
//                    date = [NSDate dateWithTimeIntervalSince1970:beginTime/1000];
//            }
//            
//        }else{
//            if(_orderOneInfoModel.tmpSupplyEndTime) {
//                double endTime = [_orderOneInfoModel.tmpSupplyEndTime doubleValue];
//                date = [NSDate dateWithTimeIntervalSince1970:endTime/1000];
//            }
//        }
        
        [self.datePicker setDate:date];
        NSTimeInterval time = [date timeIntervalSince1970]*1000;
        
        self.selectedDateString = [NSString stringWithFormat:@"%f",time];
        
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)dateSelected:(id)sender{
    UIDatePicker* control = (UIDatePicker*)sender;
    NSDate* date = control.date;
    
    
    NSTimeInterval time = [date timeIntervalSince1970]*1000;
    
    self.selectedDateString = [NSString stringWithFormat:@"%f",time];
}


@end
