//
//  PlayViewController.m
//  CWDemo
//
//  Created by gaoshuhuan on 2019/3/7.
//  Copyright © 2019年 gsh. All rights reserved.
//

#import "PlayViewController.h"
#import "PlayAnimationClass.h"
#import <AVFoundation/AVFoundation.h>
#import "FileManager.h"
#import "UIToast.h"

@interface PlayViewController (){
    AVAudioPlayer* _avAudioPlayer;
}
/**回放类实例对象*/
@property (nonatomic, strong) PlayAnimationClass * play;
/**数组*/
@property (nonatomic, strong) NSArray * savePaths;


@end

@implementation PlayViewController
#pragma mark - ViewDidLoad
- (void)viewDidLoad {
    [super viewDidLoad];

    self.edgesForExtendedLayout =UIRectEdgeBottom;
    self.title =@"播放中";
    self.view.backgroundColor =[UIColor whiteColor];
    UIButton * playBtm =[UIButton buttonWithType:UIButtonTypeCustom];
    [playBtm setTitle:@"开始播放" forState:UIControlStateNormal];
    [playBtm setBackgroundColor:[UIColor greenColor]];
    playBtm.frame =CGRectMake(100, CGRectGetMaxY(self.view.frame)-120, 100, 40);
    [playBtm addTarget:self action:@selector(playPath) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:playBtm];
    
    
}
- (PlayAnimationClass *)play{
    if (!_play) {
        _play =[[PlayAnimationClass alloc]init];
    }
    return _play;
}
- (void)playPath{
    if (self.paths.count ==0) {
        [UIToast showMessage:@"没有可播放的画面"];
        NSLog(@"保存的路径为空");
        return;
    }
    if (_avAudioPlayer && _avAudioPlayer.isPlaying) {
         [UIToast showMessage:@"音频播放异常"];
        return ;
    }
    
    if ([[FileManager manager] isFileExistsAtPath: self.filePath]) {
        _avAudioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:
                          [NSURL fileURLWithPath: self.filePath]
                                                                error: nil];
        
        [[AVAudioSession sharedInstance] setCategory: AVAudioSessionCategoryPlayback
                                               error: nil];
        
        [_avAudioPlayer play];
        
    }else{
        [UIToast showMessage:@"没有可播放的音频文件"];
    }
    
    [self.play playBezierPath:self.paths superLayer:self.view.layer];
}
- (void)dealloc
{
    NSLog(@"%s",__func__);
}
/*
 //    if (self.pathArr) {
 //        // 创建layer并设置属性
 //        CAShapeLayer *layer = [CAShapeLayer layer];
 //        layer.fillColor = [UIColor clearColor].CGColor;
 //        layer.lineWidth =  2.0f;
 //        layer.lineCap = kCALineCapRound;
 //        layer.lineJoin = kCALineJoinRound;
 //        layer.strokeColor = [UIColor redColor].CGColor;
 //        [self.layer addSublayer:layer];
 //
 //        // 创建贝塞尔路径~
 //        UIBezierPath *path = [UIBezierPath bezierPath];
 //        path =[self.pathArr objectAtIndex:_count];;
 //
 //        // 关联layer和贝塞尔路径~
 //        layer.path = path.CGPath;
 //
 //        // 创建Animation
 //        CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"strokeEnd"];
 //        animation.fromValue = @(0.0);
 //        animation.toValue = @(1.0);
 //        layer.autoreverses = NO;
 //        animation.duration = 0.2;
 //
 //
 //        // 设置layer的animation
 //        [layer removeAnimationForKey:@"123"];
 //        [layer addAnimation:animation forKey:@"123"];
 //
 //        self.count ++;
 //
 //    }
*/

@end
