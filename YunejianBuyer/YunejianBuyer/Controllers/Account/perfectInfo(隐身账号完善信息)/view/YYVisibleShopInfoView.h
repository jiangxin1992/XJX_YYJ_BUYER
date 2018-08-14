//
//  YYVisibleShopInfoView.h
//  YunejianBuyer
//
//  Created by chuanjun sun on 2017/10/27.
//  Copyright © 2017年 Apple. All rights reserved.
//

#import <UIKit/UIKit.h>

@class YYVisibleShopInfoView;
@class YYVisibleUploadPhotoButton;

@protocol YYVisibleShopInfoViewDelegate<NSObject>

@optional
- (void)YYVisibleShopInfoViewPosterImage:(YYVisibleShopInfoView *)view Button:(YYVisibleUploadPhotoButton *)button;
- (void)YYVisibleShopInfoViewDeleteImage:(YYVisibleShopInfoView *)view Button:(YYVisibleUploadPhotoButton *)button;
- (void)YYVisibleShopInfoViewDescContent:(YYVisibleShopInfoView *)view content:(NSString *)content;

@end

@interface YYVisibleShopInfoView : UIView
/** delegate */
@property (nonatomic, weak) id<YYVisibleShopInfoViewDelegate> delegate;

- (void)showNextPhotoButtonWithTag:(NSInteger)tag imageData:(NSData *)data;

/** 图片数据集合,用来判断高度 */
@property (nonatomic, strong) NSMutableArray *photoDataArray;

@end
