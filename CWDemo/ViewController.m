//
//  ViewController.m
//  CWDemo
//
//  Created by gaoshuhuan on 2019/3/6.
//  Copyright © 2019年 gsh. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
//    id __weak obj =[NSMutableArray arrayWithObjects:@"1",@"2", nil];
//    NSLog(@"%@",obj);
//    [obj addObject:@"3"];
//    NSLog(@"%@",obj);
    self addObserver:<#(nonnull NSObject *)#> forKeyPath:<#(nonnull NSString *)#> options:<#(NSKeyValueObservingOptions)#> context:<#(nullable void *)#>
    
}
//开始录制按钮点击事件
- (IBAction)startRecordingBtnClick:(id)sender {
    NSLog(@"%s",__func__);
}
- (IBAction)playClick:(id)sender {
    NSLog(@"%s",__func__);
}

@end
