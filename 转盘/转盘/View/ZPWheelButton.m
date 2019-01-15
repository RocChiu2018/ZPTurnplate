//
//  ZPWheelButton.m
//  转盘
//
//  Created by apple on 2016/12/2.
//  Copyright © 2016年 apple. All rights reserved.
//

/**
 由于系统原生的UIButton类不能把按钮的内容图片恰当地显示出来，所以自定义一个UIButton的子类，重新定义UIButton类里面的UIImageView的尺寸，使之能恰当的显示按钮的内容图片。
 */
#import "ZPWheelButton.h"

@implementation ZPWheelButton

#pragma mark ————— 重新定义UIButton类里面的UIImageView的尺寸 —————
//这个方法是系统原生的UIButton类里面提供的专门修改UIImageView尺寸的方法。此外还有专门修改title尺寸的方法。
- (CGRect)imageRectForContentRect:(CGRect)contentRect
{
    CGFloat imageWidth = 40;
    CGFloat imageHeight = 47;
    CGFloat imageX = (contentRect.size.width - imageWidth) * 0.5;
    CGFloat imageY = 20;
    
    return CGRectMake(imageX, imageY, imageWidth, imageHeight);
}

#pragma mark ————— 重写按钮的高亮方法 —————
//用户点击轮子上的按钮的时候，不希望有高亮状态，所以要重写按钮的高亮方法。
- (void)setHighlighted:(BOOL)highlighted
{
    ;
}

@end
