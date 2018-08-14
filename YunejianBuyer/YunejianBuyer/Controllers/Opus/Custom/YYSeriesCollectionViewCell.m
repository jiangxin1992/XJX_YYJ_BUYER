//
//  YYSeriesCollectionViewCell.m
//  Yunejian
//
//  Created by yyj on 15/9/4.
//  Copyright (c) 2015年 yyj. All rights reserved.
//

#import "YYSeriesCollectionViewCell.h"
#import "CommonHelper.h"
#import "CommonMacro.h"
#import "UIImage+YYImage.h"
#import "UIColor+KTUtilities.h"
#import "YYOpusApi.h"
#import "Main.h"
#import "AppDelegate.h"
#import "MBProgressHUD.h"
#import "YYPopoverArrowBackgroundView.h"
#import "CMAlertView.h"
#import "YYNetworkReachability.h"
#import "YYAlert.h"
#define kHaveDownloadTips @"下载完成"

@interface YYSeriesCollectionViewCell ()


@property (weak, nonatomic) IBOutlet UIImageView *coverImageView;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *produceLabel;
@property (weak, nonatomic) IBOutlet UILabel *orderLabel;
@property (weak, nonatomic) IBOutlet UILabel *styleAmountLabel;

@property (weak, nonatomic) IBOutlet UIButton *operationButton;
@property (weak, nonatomic) IBOutlet UILabel *statusLabel;
@property (weak, nonatomic) IBOutlet UIProgressView *progressView;
@property (weak, nonatomic) IBOutlet UIButton *startBtn;//设置隐私状态
@property (weak, nonatomic) IBOutlet UIButton *cancelBtn;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *titleLableHeightLayoutConstraint;

@property (weak, nonatomic) IBOutlet UILabel *outTimeFlagView1;
@property (weak, nonatomic) IBOutlet UILabel *outTimeFlagView2;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *outTimerViewLayoutleftConstriant1;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *outTimerViewLayoutleftConstriant2;
@property (weak, nonatomic) IBOutlet UIImageView *statusFlagImage;
@property(nonatomic,copy) UIButton *tmpMenuBtn;
@property(nonatomic,strong) UIPopoverController *popController;
@end

@implementation YYSeriesCollectionViewCell

static NSMutableDictionary *operationList;
- (IBAction)operationButtonClicked:(id)sender{
    
    NSString *folderName = [NSString stringWithFormat:@"%li",_series_id];
    NSString *offlineFilePath = [yyjOfflineSeriesDirectory() stringByAppendingPathComponent:folderName];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if(sender == nil || ![fileManager fileExistsAtPath:offlineFilePath]){
        NSString *requestURL = [[[NSUserDefaults standardUserDefaults] objectForKey:kLastYYServerURL] stringByAppendingString:kSeriesOffline1];
        requestURL = [requestURL stringByAppendingString:[NSString stringWithFormat:@"?seriesId=%ld",self.series_id]];
        NSString *writePath = [yyjOfflineSeriesZipDirectory() stringByAppendingPathComponent:[NSString stringWithFormat:@"%ld.zip",self.series_id]];
        
        [self downloadOfflinePackageWithUrl:requestURL writeToPath:writePath andSeriesId:_series_id];
    }else{
        NSInteger menuUIWidth = 162;
        NSInteger menuUIHeight = 98;
        UIViewController *controller = [[UIViewController alloc] init];
        controller.view.frame = CGRectMake(0, 0, menuUIWidth, menuUIHeight);
        //[self setMenuUI:controller.view];
        setMenuUI(self,controller.view,@[@[@"download_update",@"更新离线包"],@[@"download_delete",@"删除离线包"]]);

        UIPopoverController *popController = [[UIPopoverController alloc] initWithContentViewController:controller];
        _popController = popController;
        CGPoint p = [self convertPoint:self.operationButton.center toView:[self.delegate getview]];
        CGRect rc = CGRectZero;
        popController.popoverContentSize = CGSizeMake(menuUIWidth,menuUIHeight);
        popController.popoverBackgroundViewClass = [YYPopoverArrowBackgroundView class];

        if((p.y+ menuUIHeight) > SCREEN_HEIGHT){
            rc = CGRectMake(p.x, p.y -CGRectGetHeight(self.operationButton.frame)/2, 0, 0);
            [popController presentPopoverFromRect:rc inView:[self.delegate getview] permittedArrowDirections:UIPopoverArrowDirectionDown animated:YES];

        }else{
            rc = CGRectMake(p.x, p.y+CGRectGetHeight(self.operationButton.frame)/2, 0, 0);
            [popController presentPopoverFromRect:rc inView:[self.delegate getview] permittedArrowDirections:UIPopoverArrowDirectionUp animated:YES];

        }
        _tmpMenuBtn = sender;
    }
}
#pragma menu
-(void)menuBtnHandler:(id)sender{
    if(_tmpMenuBtn == nil){
        return;
    }
    UIButton *btn = (UIButton *)sender;
    NSInteger type = btn.tag;
    if(_tmpMenuBtn == _operationButton){
        if(type == 1){
            //
            if (![YYNetworkReachability connectedToNetwork]) {
                [YYAlert showYYAlertWithTitle:@"已离线，请检查网络后重试" andDuration:kAlertToastDuration];
            }else{
                _totalImageCount = 0;
                [self operationButtonClicked:nil];
            }
        }else if(type == 2){
            [self deleteOffinePackage];
        }
    }else if(_tmpMenuBtn == _startBtn){
        if(_indexPath != nil){
            [self.delegate operateHandler:(type-1) androw:_indexPath.row];
        }
    }
    _tmpMenuBtn = nil;
    [_popController dismissPopoverAnimated:YES];
}
#pragma DownLoadOperation
- (void)downloadOfflinePackageWithUrl:(NSString *)url  writeToPath:(NSString *)filePath andSeriesId:(long)seriesId{
    NSLog(@"filePath: %@",filePath);
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    UIView *superView = appDelegate.window.rootViewController.view;

    DownLoadOperation *operation = [[DownLoadOperation alloc] init];
    [self addDownLoadOperation:operation];
    WeakSelf(weakSelf);
    __block NSInteger blockseriesID = seriesId;
    [MBProgressHUD showHUDAddedTo:superView animated:YES];
    [operation downloadWithUrl:url
                     cachePath:^NSString *{
                         return filePath;
                     } progressBlock:^(NSUInteger bytesRead, long long totalBytesRead, long long totalBytesExpectedToRead) {
                         if(blockseriesID == weakSelf.series_id)
                         dispatch_async(dispatch_get_main_queue(), ^{
                             [weakSelf updateProgressWithCurrentRead:totalBytesRead totalSize:totalBytesExpectedToRead*2 andSeriesId:blockseriesID];
                         });
                         
                     } success:^(AFHTTPRequestOperation *operation, id responseObject) {
                         // Unzip Operation
                         NSString *destinationPath = yyjOfflineSeriesDirectory();
                         
                         [Main unzipFileAtPath:filePath
                                 toDestination:destinationPath];
                         
                         NSFileManager *fileManager = [NSFileManager defaultManager];
                         if ([fileManager fileExistsAtPath:destinationPath]) {
                             [fileManager removeItemAtPath:filePath error:nil];
                         }

                         //dispatch_async(dispatch_get_main_queue(), ^{
                         [ weakSelf deleteDownLoadOperation:blockseriesID];
                         [weakSelf downloadOfflineImages:blockseriesID];
                         //});
                        
                         [MBProgressHUD hideAllHUDsForView:superView animated:YES];
                     } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                         DLog(@"error = %@",error);
                         [MBProgressHUD hideAllHUDsForView:superView animated:YES];
                     }];
    [operation.requestOperation start];
 
}

-(void)addDownLoadOperation:(DownLoadOperation *)operation{
    if(operationList == nil){
        operationList = [[NSMutableDictionary alloc] init];
    }
    [operationList setValue:operation forKey:[NSString stringWithFormat:@"%ld",_series_id]];
}

-(void)deleteDownLoadOperation:(NSInteger)seriesID{
    if([operationList objectForKey:[NSString stringWithFormat:@"%d",seriesID]]){
        DownLoadOperation *operation  = [operationList objectForKey:[NSString stringWithFormat:@"%d",seriesID]];
        [operation.requestOperation cancel];
        operation = nil;
        [operationList setValue:nil forKey:[NSString stringWithFormat:@"%d",seriesID]];
    }
}

-(id)checkOperation:(NSInteger)seriesID{
    DownLoadOperation *operation = nil;
    if([operationList objectForKey:[NSString stringWithFormat:@"%d",seriesID]]){
        operation = [operationList objectForKey:[NSString stringWithFormat:@"%d",seriesID]];
    }
    return operation;
}

-(void)deleteOffinePackage{
    [self deleteDownLoadOperation:_series_id];
    NSString *folderName = [NSString stringWithFormat:@"%li",_series_id];
    NSString *offlineFilePath = [yyjOfflineSeriesDirectory() stringByAppendingPathComponent:folderName];
    NSString *imgsJsonPath = [offlineFilePath stringByAppendingPathComponent:@"imgs.json"];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if ([fileManager fileExistsAtPath:imgsJsonPath]) {
        NSData *data = [NSData dataWithContentsOfFile:imgsJsonPath];
        if (data) {
            NSError* error;
            NSDictionary* json = [NSJSONSerialization
                                  JSONObjectWithData:data
                                  options:NSJSONReadingAllowFragments
                                  error:&error];
            [self requestUrls:json andSuffix:kStyleColorImageCover andType:@"color" andOperate:2];
            [self requestUrls:json andSuffix:kStyleCover andType:@"album" andOperate:2];
            [self requestUrls:json andSuffix:kStyleDetailCover andType:@"style" andOperate:2];
            [self requestUrls:json andSuffix:kLookBookImage andType:@"lookBook" andOperate:2];

        }
        
    }
    
    [fileManager removeItemAtPath:offlineFilePath error:nil];
    
    if(_indexPath != nil){
        [self.delegate operateHandler:-1 androw:-1];
    }
}

- (void)updateProgressWithCurrentRead:(long long) totalBytesRead totalSize:(long long) totalBytesExpectedToRead andSeriesId:(long)seriesId{
    if (totalBytesExpectedToRead > 0
        && _series_id == seriesId) {
        _operationButton.hidden = YES;
        _statusLabel.hidden = YES;
        _progressView.hidden = NO;
        _cancelBtn.hidden = NO;
        _progressView.progress = totalBytesRead/(float)totalBytesExpectedToRead;
    }
}

- (void)downloadSuccess{
    [_operationButton setImage:[UIImage imageNamed:@"download_finished"] forState:UIControlStateNormal];
    _statusLabel.text = kHaveDownloadTips;
    _cancelBtn.hidden = YES;
    _operationButton.hidden = NO;
    _statusLabel.hidden = NO;
    _progressView.hidden = YES;
}
#pragma 下载图片序列 及 计数
-(NSString *)checkImagesDownloadAll{
    _totalImageCount = 0;
    _loadImageCount = 0;
    NSString *folderName = [NSString stringWithFormat:@"%li",_series_id];
    NSString *offlineFilePath = [yyjOfflineSeriesDirectory() stringByAppendingPathComponent:folderName];
    NSString *imgsJsonPath = [offlineFilePath stringByAppendingPathComponent:@"imgs.json"];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if ([fileManager fileExistsAtPath:imgsJsonPath]) {
        NSData *data = [NSData dataWithContentsOfFile:imgsJsonPath];
        if (data) {
            NSError* error;
            NSDictionary* json = [NSJSONSerialization
                                  JSONObjectWithData:data
                                  options:NSJSONReadingAllowFragments
                                  error:&error];
            [self requestUrls:json andSuffix:kStyleColorImageCover andType:@"color" andOperate:1];
            [self requestUrls:json andSuffix:kStyleCover andType:@"album" andOperate:1];
            [self requestUrls:json andSuffix:kStyleDetailCover andType:@"style" andOperate:1];
            [self requestUrls:json andSuffix:kLookBookImage andType:@"lookBook" andOperate:1];

        }
        
    }
    return [NSString stringWithFormat:@"(%ld/%ld)",(long)_loadImageCount,(long)_totalImageCount];
}

-(void)downloadOfflineImages:(NSInteger)seriesID{
    //读取本地的离线数据
    NSString *folderName = [NSString stringWithFormat:@"%ld",(long)seriesID];
    NSString *offlineFilePath = [yyjOfflineSeriesDirectory() stringByAppendingPathComponent:folderName];
    NSString *imgsJsonPath = [offlineFilePath stringByAppendingPathComponent:@"imgs.json"];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if ([fileManager fileExistsAtPath:imgsJsonPath]) {
        NSData *data = [NSData dataWithContentsOfFile:imgsJsonPath];
        if (data) {
            NSError* error;
            NSDictionary* json = [NSJSONSerialization
                                  JSONObjectWithData:data
                                  options:NSJSONReadingAllowFragments
                                  error:&error];
            
            [self requestUrls:json andSuffix:kStyleColorImageCover andType:@"color" andOperate:0];
            [self requestUrls:json andSuffix:kStyleCover andType:@"album" andOperate:0];
            [self requestUrls:json andSuffix:kStyleDetailCover andType:@"style" andOperate:0];
            [self requestUrls:json andSuffix:kLookBookImage andType:@"lookBook" andOperate:0];

        }
        
    }
    [self updateUI];
}


-(void)requestUrls:(NSDictionary *)source andSuffix:(NSString *)imageSuffix andType:(NSString *)type andOperate:(NSInteger)operate{
    NSString *storePath = nil;
    NSURL *imageUrl = nil;
    UIImage *image = nil;
    NSDictionary *urls = [source objectForKey:type];
    for (NSString * imageRelativePath in urls) {
        if([type isEqualToString:@"album"]){
            storePath = getStyleCoverImageStorePath(imageRelativePath);
        }else if([type isEqualToString:@"style"]){
            storePath = getStyleImageStorePath(imageRelativePath);
        }else if([type isEqualToString:@"lookBook"]){
            storePath = getLookBookImageStorePath(imageRelativePath);
        }else{
            storePath = getStyleColorImageStorePath(imageRelativePath);
        }
        storePath = [storePath stringByAppendingString:@"/"];
        storePath = [storePath stringByAppendingString:[imageRelativePath lastPathComponent]];
        storePath = [storePath stringByAppendingString:imageSuffix];
        image = [UIImage imageWithContentsOfFile:storePath];
        if(operate == 0){
            if(image == nil){//下载
                imageUrl = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@",imageRelativePath,imageSuffix]];
                NSLog(@"imageUrl%@",imageRelativePath);
                [_delegate downloadImages:imageUrl andStorePath:storePath];
            }else{
                _loadImageCount ++;
            }
        }else if(operate == 1){//请求
            //NSLog(@"storePath%@",storePath);
            if(image){
                _loadImageCount ++;
            }else{
                //NSLog(@"none %@",imageRelativePath);
            }
        }else if(operate == 2){//删除
            if(image){
                NSFileManager *fileManager = [NSFileManager defaultManager];
                [fileManager removeItemAtPath:storePath error:nil];
                //NSLog(@"delete %@",imageRelativePath);
            }

        }
        _totalImageCount ++;
    }
}




- (void)updateUI{
    
    if (_title) {
        _titleLabel.text = _title;
        _titleLabel.numberOfLines = 0;
        CGRect rect = [_titleLabel.text boundingRectWithSize:CGSizeMake(205, 78) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:[UIFont boldSystemFontOfSize:20]} context:nil];
        _titleLableHeightLayoutConstraint.constant = rect.size.height+1;
    }
    
    if (_produce) {
        _produceLabel.text = _produce;
    }
    
    if (_styleAmount) {
        _styleAmountLabel.text = _styleAmount;
    }
    
    if (_order) {
        _orderLabel.text = _order;
    }
    
    _outTimerViewLayoutleftConstriant1.constant = [_produce sizeWithAttributes:@{NSFontAttributeName:_produceLabel.font}].width + 12;
    _outTimerViewLayoutleftConstriant2.constant = [_order sizeWithAttributes:@{NSFontAttributeName:_orderLabel.font}].width + 12;
    if(_compareResult1 == NSOrderedAscending){
        _outTimeFlagView1.hidden = NO;
    }else{
        _outTimeFlagView1.hidden = YES;
    }
    if(_compareResult2 == NSOrderedAscending){
        _outTimeFlagView2.hidden = NO;
    }else{
        _outTimeFlagView2.hidden = YES;
    }
    
    _progressView.progressTintColor = [UIColor colorWithHex:@"ed6498"];
    _progressView.trackTintColor = [UIColor colorWithHex:@"efefef"];
    //_progressView.transform = CGAffineTransformMakeScale(1.0f,7.0f);
    _progressView.layer.borderColor = [UIColor colorWithHex:@"efefef"].CGColor;
    _progressView.layer.borderWidth = 5;
    _progressView.layer.cornerRadius = 6;
    _progressView.layer.masksToBounds = YES;
    
    _coverImageView.contentMode = UIViewContentModeScaleAspectFit;
    _coverImageView.backgroundColor = [UIColor colorWithHex:kDefaultImageColor];
    
    //_coverImageView.layer.borderColor = [UIColor blackColor].CGColor;
    //_coverImageView.layer.borderWidth = 1;
    
    
    if (_imageRelativePath) {
        NSString *storePath = getSeriesImageStorePath(_imageRelativePath);
        downloadImageWithRelativePath(_imageRelativePath, storePath, _coverImageView, kSeriesCover);
    }
    
    _operationButton.hidden = YES;
    _statusLabel.hidden = YES;
    _progressView.hidden = YES;
    _startBtn.hidden = NO;
    _cancelBtn.hidden = YES;
    _totalImageCount = 0;
    _loadImageCount = 0;
    _statusLabel.textColor = [UIColor colorWithHex:@"919191"];
    if(_authType == kAuthTypeBuyer){
        [_startBtn setImage:[UIImage imageNamed:@"pub_status_buyer1"] forState:UIControlStateNormal];
    }else if (_authType == kAuthTypeMe){
        [_startBtn setImage:[UIImage imageNamed:@"pub_status_me1"] forState:UIControlStateNormal];
    }else if(_authType == kAuthTypeAll){
        [_startBtn setImage:[UIImage imageNamed:@"pub_status_all1"] forState:UIControlStateNormal];
    }
    
    //判断有没有下载过离线包
    if (_series_id > 0) {
        
        _operationButton.hidden = NO;
        _statusLabel.hidden = NO;

        NSString *folderName = [NSString stringWithFormat:@"%li",_series_id];
        NSString *offlineFilePath = [yyjOfflineSeriesDirectory() stringByAppendingPathComponent:folderName];
        NSFileManager *fileManager = [NSFileManager defaultManager];
        if ([fileManager fileExistsAtPath:offlineFilePath] || ([self checkOperation:_series_id] != nil )) {
            //已经下载过
            [_operationButton setImage:[UIImage imageNamed:@"download_finished"] forState:UIControlStateNormal];
            [self checkImagesDownloadAll];
             _statusLabel.text = kHaveDownloadTips;
            if(_totalImageCount >0  && _loadImageCount >= _totalImageCount){
               _statusLabel.text = kHaveDownloadTips;
            }else{
                    if(_totalImageCount > 0){
                        [self updateProgressWithCurrentRead:_totalImageCount+_loadImageCount totalSize:_totalImageCount+_totalImageCount andSeriesId:_series_id];
                    }else{
                        [self updateProgressWithCurrentRead:1 totalSize:2 andSeriesId:_series_id];
                    }
            }
        }else{
            [_operationButton setImage:[UIImage imageNamed:@"download_start"] forState:UIControlStateNormal];
            _statusLabel.text = @"离线阅读";
        }
        
    }

}
- (IBAction)startDownloadImgs:(id)sender {
    NSInteger menuUIWidth = 170;
    NSInteger menuUIHeight = 143;
    UIViewController *controller = [[UIViewController alloc] init];
    controller.view.frame = CGRectMake(0, 0, menuUIWidth, menuUIHeight);
    //[self setMenuUI:controller.view];
    setMenuUI(self,controller.view,@[@[@"pub_status_buyer1",@"合作零售商可见"],@[@"pub_status_me1",@"仅自己可见"],@[@"pub_status_all1",@"公开"]]);
    
    UIPopoverController *popController = [[UIPopoverController alloc] initWithContentViewController:controller];
    _popController = popController;
    CGPoint p = [self convertPoint:self.startBtn.center toView:[self.delegate getview]];
    CGRect rc = CGRectZero;
    popController.popoverContentSize = CGSizeMake(menuUIWidth,menuUIHeight);
    popController.popoverBackgroundViewClass = [YYPopoverArrowBackgroundView class];

    if((p.y+ menuUIHeight) > SCREEN_HEIGHT){
        rc = CGRectMake(p.x, p.y -CGRectGetHeight(self.startBtn.frame)/2, 0, 0);
        [popController presentPopoverFromRect:rc inView:[self.delegate getview] permittedArrowDirections:UIPopoverArrowDirectionDown animated:YES];

    }else{
        rc = CGRectMake(p.x, p.y+CGRectGetHeight(self.startBtn.frame)/2, 0, 0);
        [popController presentPopoverFromRect:rc inView:[self.delegate getview] permittedArrowDirections:UIPopoverArrowDirectionUp animated:YES];

    }
    _tmpMenuBtn = sender;
}

- (IBAction)cancelDownLoadRequests:(id)sender {
    WeakSelf(weakself);
    CMAlertView *alertView = [[CMAlertView alloc] initWithTitle:nil message:@"确认要删除离线包" needwarn:NO delegate:nil cancelButtonTitle:@"取消" otherButtonTitles:@[@"确认"]];
    //alertView.specialParentView = [self.delegate getview];
    [alertView setAlertViewBlock:^(NSInteger selectedIndex){
        if (selectedIndex == 1) {
            [weakself deleteOffinePackage];
        }
    }];
    [alertView show];
}
@end
