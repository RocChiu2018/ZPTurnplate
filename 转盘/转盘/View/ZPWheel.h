//
//  ZPWheel.h
//  转盘
//
//  Created by apple on 2016/11/29.
//  Copyright © 2016年 apple. All rights reserved.
//

//自定义轮子类。

#import <UIKit/UIKit.h>

@interface ZPWheel : UIView

+ (instancetype)wheel;  //轮子的构造方法
- (void)startRotating;
- (void)stopRotating;

@end
