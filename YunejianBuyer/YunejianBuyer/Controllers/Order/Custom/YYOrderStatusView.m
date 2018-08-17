//
//  YYOrderStatusView.m
//  Yunejian
//
//  Created by Apple on 15/11/25.
//  Copyright © 2015年 yyj. All rights reserved.
//

#import "YYOrderStatusView.h"

#import "UIView+UpdateAutoLayoutConstraints.h"

@implementation YYOrderStatusView{
    
}
float progressBarHeight = 5;
float progressDotBgHeight = 11;
float progressDotHeight = 11;
//NSInteger leftRightSpace = 24;

NSInteger itemWidth = 130;
//NSInteger itemSpace = 10;
NSInteger itemMaxNum = 6;
NSInteger curItemNum = 1;
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/
-(UILabel *)getTitleLabel:(NSInteger)key{
    if(key == 1){
        return  _titleLabel1;
    }else if(key == 2){
        return  _titleLabel2;
    }else if(key == 3){
        return  _titleLabel3;
    }else if(key == 4){
        return  _titleLabel4;
    }else if(key == 5){
        return  _titleLabel5;
    }else{
        return  _titleLabel6;
    }
}

-(void)updateUI{
    NSInteger space = 17;
    curItemNum = [_titleArray count];
    _containerViewWidth = (_containerViewWidth > 0 ? _containerViewWidth:SCREEN_WIDTH);
    itemWidth = _containerViewWidth/_showNum;

    for (int i=1; i<=itemMaxNum; i++) {
        UILabel *titleLabel = [self valueForKey:[NSString stringWithFormat:@"titleLabel%d",i]];
        if(i <= curItemNum){
            titleLabel.text = [_titleArray objectAtIndex:(i-1)];
        }else{
            titleLabel.text = @"";
        }
    }
    float progressWidth = (curItemNum-1)*itemWidth;
    _progressLayoutLeftConstraint.constant = itemWidth/2;
    
    [_titleLabel1 setConstraintConstant:itemWidth forAttribute:NSLayoutAttributeWidth];
    [_progressView setConstraintConstant:progressWidth forAttribute:NSLayoutAttributeWidth];
    //_progressLayoutLeftConstraint.constant = leftRightSpace+itemWidth/2+(itemMaxNum-curItemNum)*(itemWidth+itemSpace);
    _progressView.layer.cornerRadius = (progressBarHeight)/2;
    _progressView.layer.masksToBounds = YES;
    _progressDotBgView.layer.cornerRadius = progressDotBgHeight/2;
    _progressDotView.layer.cornerRadius = progressDotHeight/2;
    _progressDotBgView.layer.masksToBounds = YES;
    _progressDotView.layer.masksToBounds = YES;
    
    //_progressView.layer.borderWidth = 2;
   // _progressView.layer.borderColor = [[[UIColor lightGrayColor] colorWithAlphaComponent:0.6] CGColor];
    _progressView.progressTintColor = [UIColor colorWithHex:_progressTintColor];//@"ed6498"
    _progressView.trackTintColor = [UIColor colorWithHex:@"efefef"];
    _progressDotBgView.backgroundColor = [[UIColor lightGrayColor]  colorWithAlphaComponent:0.6];
    _progressDotView.backgroundColor = [UIColor colorWithHex:_progressTintColor];
   
    [self setProgressValue:_curProgressValue];
    
    //遮罩_showIndex = 0;_showNum = 2;
    //self.backgroundColor = [UIColor redColor];
    NSInteger clipOffsetEndX = 0 ;
    NSInteger clipOffsetStartX = 0 ;
    if(_showIndex == -1){
        if(_curProgressValue <= 1 ){
            _showIndex = 0;
            NSString *txtStr = [_titleArray objectAtIndex:0];
            CGSize size=[txtStr sizeWithAttributes:@{NSFontAttributeName:_titleLabel1.font}];
            clipOffsetEndX =  MIN((size.width - itemWidth)/2,0);
            self.frame = CGRectMake(clipOffsetEndX+space, 0, _containerViewWidth-space*2, CGRectGetHeight(self.frame));
        }else if(_curProgressValue >= (curItemNum - 2)){
            NSString *txtStr = [_titleArray objectAtIndex:(curItemNum - 1)];
            CGSize size=[txtStr sizeWithAttributes:@{NSFontAttributeName:_titleLabel6.font}];
            clipOffsetStartX = MAX(( itemWidth -size.width )/2,0)-space*2;
            _showIndex = curItemNum -3;
            self.frame = CGRectMake(-[self getClipX:_showIndex]+space+clipOffsetStartX, 0, _containerViewWidth-space*2, CGRectGetHeight(self.frame));
        }else{
            _showIndex = _curProgressValue -1;
            self.frame = CGRectMake(-[self getClipX:_showIndex]+space, 0, _containerViewWidth-space*2, CGRectGetHeight(self.frame));
        }
    }else{
        self.frame = CGRectMake(-[self getClipX:_showIndex], 0, _containerViewWidth-space*2, CGRectGetHeight(self.frame));
    }
    
    CAShapeLayer *maskLayer = [[CAShapeLayer alloc] init];
    CGRect maskRect = CGRectMake([self getClipX:_showIndex]-clipOffsetStartX, 0,[self getClipX:_showNum]-clipOffsetEndX-space*2, CGRectGetHeight(self.frame));
    // Create a path and add the rectangle in it.
    CGMutablePathRef path = CGPathCreateMutable();
    CGPathAddRect(path, nil, maskRect);
    // Set the path to the mask layer.
    [maskLayer setPath:path];
     self.layer.mask = maskLayer;

}

-(void)setProgressValue:(float) value{
    _progressView.progress = [self getProgressValue:value];
    NSInteger centerX = [self getCenterXValue:value];
    _dotBgLayoutCenterXConstraint.constant = centerX;
    if(value == 0){
        _timerLabelLayoutCenterXConstaint.constant = centerX;
        _timerLabel.textAlignment = NSTextAlignmentLeft;
    }else if(value >= (curItemNum-1)){
        _timerLabelLayoutCenterXConstaint.constant = centerX-CGRectGetWidth(_timerLabel.frame);
        _timerLabel.textAlignment = NSTextAlignmentRight;
    }else{
        _timerLabelLayoutCenterXConstaint.constant = centerX-CGRectGetWidth(_timerLabel.frame)/2;
        _timerLabel.textAlignment = NSTextAlignmentCenter;
    }
    
}
//圆点位置
-(float)getCenterXValue:(float) value{
   // return (itemWidth+itemSpace)*(value) - (itemWidth+itemSpace)*(itemMaxNum-1)/2;
    float curCenterX = itemWidth*(value+0.5)-progressDotBgHeight*0.5;
    //curCenterX = MIN(curCenterX, itemWidth*(curItemNum-1+0.5));
    return curCenterX;
}
//线的位置
-(float)getProgressValue:(float) value{
    return (float)(value+0.5) / (curItemNum-1);
}

-(NSInteger)getClipX:(NSInteger)value{
    if(value > 0){
        return value*(itemWidth);
    }
    return 0;
}
@end
