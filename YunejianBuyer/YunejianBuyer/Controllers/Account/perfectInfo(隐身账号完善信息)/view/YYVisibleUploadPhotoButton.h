//
//  YYVisibleUploadPhotoButton.h
//  YunejianBuyer
//
//  Created by chuanjun sun on 2017/10/27.
//  Copyright © 2017年 Apple. All rights reserved.
//

#import <UIKit/UIKit.h>
@class YYVisibleUploadPhotoButton;

@protocol YYVisibleUploadPhotoButtonDelegate<NSObject>

@optional
- (void)YYVisibleUploadPhotoPosterButton:(YYVisibleUploadPhotoButton *)button;
- (void)YYVisibleUploadPhotoDeleteButton:(YYVisibleUploadPhotoButton *)button;

@end

@interface YYVisibleUploadPhotoButton : UIView

/** 图片数据 */
@property (nonatomic, strong) NSData *imageData;
/** delegate */
@property (nonatomic, assign) id<YYVisibleUploadPhotoButtonDelegate> delegate;

@end
