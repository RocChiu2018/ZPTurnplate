//
//  ZPWheel.m
//  转盘
//
//  Created by apple on 2016/11/29.
//  Copyright © 2016年 apple. All rights reserved.
//

#import "ZPWheel.h"
#import "ZPWheelButton.h"

@interface ZPWheel() <CAAnimationDelegate>

@property (weak, nonatomic) IBOutlet UIImageView *wheel;
@property (nonatomic, strong) ZPWheelButton *selectedButton;  //轮子上选中的按钮
@property (nonatomic, strong) CADisplayLink *link;

@end

@implementation ZPWheel

#pragma mark ————— 轮子的构造方法 —————
//用xib文件来构造轮子。
+ (instancetype)wheel
{
    return [[[NSBundle mainBundle] loadNibNamed:@"ZPWheel" owner:nil options:nil] lastObject];
}

#pragma mark ————— 初始化轮子上的按钮 —————
//一般在此方法中做一些子控件的初始化工作，但不设置子控件的尺寸。
- (void)awakeFromNib
{
    [super awakeFromNib];
    
    self.wheel.userInteractionEnabled = YES;
    
    //加载大图片
    UIImage *bigImage = [UIImage imageNamed:@"LuckyAstrology"];
    UIImage *bigImageSelected = [UIImage imageNamed:@"LuckyAstrologyPressed"];
    
    /**
     设置轮子上的按钮的宽和高：
     下面的代码中会利用"CGImageCreateWithImageInRect"函数把上述的大图片裁剪成每个星座对应的小图片。"CGImageCreateWithImageInRect"函数是C语言函数，这个函数里面的"rect"参数默认使用的是像素单位，但是UIKit框架默认使用的是point单位，二者相差一倍或二倍或三倍的关系，所以首先应该判断用户手机的缩放比例，再根据缩放比例把point单位转换成像素单位；
     scale代表屏幕的缩放比例，如果"[UIScreen mainScreen].scale"的值为1的话，则代表着用户的手机屏幕为非retina屏幕，如果值为2或者3的话，则代表着用户的手机屏幕为retina屏幕。
     */
    CGFloat smallWidth = bigImage.size.width / 12 * [UIScreen mainScreen].scale;
    CGFloat samllHeight = bigImage.size.height * [UIScreen mainScreen].scale;
    
    //在轮子上面添加十二星座按钮
    for (int index = 0; index < 12; index ++)
    {
        ZPWheelButton *button = [ZPWheelButton buttonWithType:UIButtonTypeCustom];
        
        //以大图片为父视图，设置每个小图片的坐标和尺寸
        CGRect smallRect = CGRectMake(index * smallWidth, 0, smallWidth, samllHeight);
        
        //利用"CGImageCreateWithImageInRect"C语言函数在大图片上按照上述的小图片的尺寸来进行裁切。
        CGImageRef smallImage = CGImageCreateWithImageInRect(bigImage.CGImage, smallRect);
        
        //把裁切下来的小图片设置为按钮的内容图片
        [button setImage:[UIImage imageWithCGImage:smallImage] forState:UIControlStateNormal];
        
        CGImageRef smallImageSelected = CGImageCreateWithImageInRect(bigImageSelected.CGImage, smallRect);
        [button setImage:[UIImage imageWithCGImage:smallImageSelected] forState:UIControlStateSelected];
        
        //设置选中按钮时，按钮的背景图片
        [button setBackgroundImage:[UIImage imageNamed:@"LuckyRototeSelected"] forState:UIControlStateSelected];
        
        /**
         设置按钮的坐标和尺寸：
         一开始的时候十二个按钮都处在轮子的同一个位置上，十二个按钮摞在了一起。
         */
        button.bounds = CGRectMake(0, 0, 66, 143);
        
        /**
         设置锚点：
         将来十二个按钮都要围绕轮子的中心点进行不同弧度的旋转。
         */
        button.layer.anchorPoint = CGPointMake(0.5, 1);
        
        //设置按钮的位置点
        button.layer.position = CGPointMake(self.wheel.frame.size.width * 0.5, self.wheel.frame.size.height * 0.5);
        
        /**
         设置按钮需要旋转的弧度：
         把角度换算成弧度。
         */
        CGFloat radian = (30 * index) / 180.0 * M_PI;
        
        //把按钮按照弧度进行旋转
        button.transform = CGAffineTransformMakeRotation(radian);
        
        //监听按钮的点击
        [button addTarget:self action:@selector(buttonClick:) forControlEvents:UIControlEventTouchDown];
        
        //把按钮添加到轮子上
        [self.wheel addSubview:button];
        
        //初始化的时候默认选中第0个按钮
        if (index == 0)
        {
            [self buttonClick:button];
        }
    }
}

#pragma mark ————— 点击轮子上面的按钮 —————
//按钮被点击方法的代码三部曲。
- (void)buttonClick:(ZPWheelButton *)button
{
    self.selectedButton.selected = NO;
    button.selected = YES;
    self.selectedButton = button;
}

#pragma mark ————— 点击”开始“按钮 —————
/**
 使用核心动画实现的动画效果都是假象，并不会真实地改变图层的属性值。看起来轮子是转动的，但是轮子上面的星座按钮的position值根本就没有变化，这样就会造成用户的误点，用户本身要点击A星座，但实际上点击的是B星座。与核心动画不同，UIView封装的动画是真实地改变了UIView的属性值，所以此处应该使用UIView封装的动画来实现轮子的转动动画。
 */
- (void)startRotating
{
    /**
     NSTimer类很少用于绘图，因为调用的优先级比较低，在设定的时间内并不会准时被调用；
     在绘图中一般用CADisplayLink类来作为定时器使用，CADisplayLink类在每次屏幕刷新的时候都会被调用，屏幕一般一秒刷新60次，故而CADisplayLink类一秒会被调用60次；
     一般情况下，刷新的比较快的时候用CADisplayLink类，刷新的比较慢的情况用NSTimer类。
     */
    if (self.link)  //如果已经有link对象了，就不要再添加新的link对象了，因为如果再添加新的link对象的话会与原来的link对象相叠加，加快转动的速率。
    {
        return;
    }else
    {
        self.link = [CADisplayLink displayLinkWithTarget:self selector:@selector(update)];
        
        //把CADisplayLink类的对象添加到主运行循环中：
        [self.link addToRunLoop:[NSRunLoop mainRunLoop] forMode:NSDefaultRunLoopMode];
    }
}

#pragma mark ————— 轮子旋转 —————
//每六十分之一秒这个方法被调用一次，每调用一次这个方法，轮子旋转(M_PI_4 / 100)弧度。
- (void)update
{
    self.wheel.transform = CGAffineTransformRotate(self.wheel.transform, M_PI_4 / 100);
}

#pragma mark ————— 点击”结束“按钮 —————
- (void)stopRotating
{
    [self.link invalidate];
    self.link = nil;
}

#pragma mark ————— 点击”开始选号“按钮 —————
- (IBAction)startChoose:(id)sender
{
    //如果轮子正在旋转的话先让轮子停止旋转。
    [self stopRotating];
    
    CABasicAnimation *animation = [CABasicAnimation animation];
    animation.keyPath = @"transform.rotation";
    animation.toValue = [NSNumber numberWithFloat:2 * M_PI *3];  //转3圈，每一圈360度
    animation.duration = 2.0;
    animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];  //开头和结尾比较慢，中间比较快
    animation.delegate = self;
    
    [self.wheel.layer addAnimation:animation forKey:nil];
    
    //在轮子旋转的过程中，不能让用户点击轮子。
    self.userInteractionEnabled = NO;
}

#pragma mark ————— CAAnimationDelegate —————
-(void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag
{
    //动画结束以后就可以让用户点击轮子上面的按钮了。
    self.userInteractionEnabled = YES;
    
    //动画完成以后过2秒钟让轮子自动旋转（如同点击了”开始“按钮）。
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self startRotating];
    });
}

@end
