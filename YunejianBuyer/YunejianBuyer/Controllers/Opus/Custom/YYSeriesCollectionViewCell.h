//
//  YYSeriesCollectionViewCell.h
//  Yunejian
//
//  Created by yyj on 15/9/4.
//  Copyright (c) 2015年 yyj. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DownLoadOperation.h"

@protocol YYSeriesCollectionViewCellDelegate
-(void)downloadImages:(NSURL *)url andStorePath:(NSString *)storePath;
-(void)operateHandler:(NSInteger)section androw:(NSInteger)row;
-(UIView *)getview;
@end
@interface YYSeriesCollectionViewCell : UICollectionViewCell

@property (nonatomic,strong) NSString *title;
@property (nonatomic,strong) NSString *imageRelativePath;
@property (nonatomic,strong) NSString *order;
@property (nonatomic,strong) NSString *produce;
@property (nonatomic,strong) NSString *styleAmount;
@property (nonatomic,assign) long series_id;
@property (nonatomic,weak)id<YYSeriesCollectionViewCellDelegate> delegate;
@property (nonatomic,strong) NSIndexPath *indexPath;
@property (nonatomic,assign) NSInteger totalImageCount;
@property (nonatomic,assign) NSInteger loadImageCount;
@property (nonatomic,assign) NSInteger authType;
@property (nonatomic,assign) NSComparisonResult compareResult1;
@property (nonatomic,assign) NSComparisonResult compareResult2;
- (void)updateUI;

@end
