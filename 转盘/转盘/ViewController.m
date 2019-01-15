//
//  ViewController.m
//  转盘
//
//  Created by apple on 2016/11/29.
//  Copyright © 2016年 apple. All rights reserved.
//

#import "ViewController.h"
#import "ZPWheel.h"

@interface ViewController ()

@property (nonatomic, weak) ZPWheel *wheel;

- (IBAction)start;
- (IBAction)stop;

@end

@implementation ViewController

#pragma mark ————— 生命周期 —————
- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    self.wheel = [ZPWheel wheel];
    self.wheel.center = CGPointMake(self.view.frame.size.width * 0.5, self.view.frame.size.height * 0.5);
    [self.view addSubview:self.wheel];
}

#pragma mark ————— 点击“开始”按钮 —————
- (IBAction)start
{
    [self.wheel startRotating];
}

#pragma mark ————— 点击“结束”按钮 —————
- (IBAction)stop
{
    [self.wheel stopRotating];
}

@end
