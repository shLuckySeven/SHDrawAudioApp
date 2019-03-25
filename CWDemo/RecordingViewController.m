//
//  RecordingViewController.m
//  CWDemo
//
//  Created by gaoshuhuan on 2019/3/7.
//  Copyright © 2019年 gsh. All rights reserved.
//

#import "RecordingViewController.h"
#import "DrawView.h"
#import <AVFoundation/AVFoundation.h>
#import "PlayViewController.h"
#import "FileManager.h"
#import "UIToast.h"
#import "Conf.h"

#define kRecordAudioFile @"myRecord"

@interface RecordingViewController ()<AVAudioRecorderDelegate,SaveFinishDelegate>{
    BOOL _isStartRecord;
    
    NSString* _curWavFilePath;
    NSString* _curAmrFilePath;
    
    NSURL* _curWavFileUrl;
    
    AVAudioRecorder* _avAudioRecorder;
    AVAudioPlayer* _avAudioPlayer;
}
@property (nonatomic, strong) AVAudioSession* audioSession;
/**drawView属性*/
@property (nonatomic, strong) DrawView * drawView;
/**计时器*/
@property (nonatomic, strong) dispatch_source_t timer;
/**录制时长*/
@property (nonatomic, assign) NSInteger totalDuration;
/**path路径*/
@property (nonatomic, strong) NSArray * savePaths;
/**记录录制状态*/
@property (nonatomic, assign) BOOL recording;
@end

@implementation RecordingViewController
#pragma mark - ViewDidLoad
- (void)viewDidLoad {
    [super viewDidLoad];
    self.edgesForExtendedLayout =UIRectEdgeBottom;
    [self.view addSubview:self.drawView];
    self.recording =NO;
    _isStartRecord = NO;
}
#pragma mark - LazyLoad
- (DrawView *)drawView{
    if (!_drawView) {
        _drawView =[[DrawView alloc]init];
        _drawView.delegate =self;
        _drawView.frame  =CGRectMake(0, 40, self.view.bounds.size.width, self.view.bounds.size.height-64-150-40);
        _drawView.backgroundColor =[UIColor whiteColor];
    }
    return _drawView;
}
#pragma mark - Delegate
//完成回调代理(目的是把存储的path回传回来暂时这么存储)
- (void)finish:(NSArray *)array{
    self.savePaths =array;
    [self stop];
}
#pragma mark - Button Click
//保存,停止
- (IBAction)saveBtnClick:(id)sender {
    NSLog(@"%s",__func__);
    [self.drawView finish];
    [self stop];
    [self saveRecording];
    _isStartRecord = NO;
}
//选择颜色
- (IBAction)selColorBtnClick:(UIButton *)sender {
    NSLog(@"%s",__func__);
    [self.drawView setLineColor:sender.backgroundColor];
}
//改变画笔宽度
- (IBAction)changeTextFont:(UISlider *)sender {
    NSLog(@"%s,宽度值：%.2f",__func__,sender.value);
    [self.drawView setLineWith:sender.value * 3.0];//此处因为slider值取出来比较小，为了效果明显 故 *3
}
//撤销
- (IBAction)unDoClick:(id)sender {
    NSLog(@"%s",__func__);
    [self.drawView undo];
}
//全部擦除
- (IBAction)remveAllClick:(id)sender {
    NSLog(@"%s",__func__);
    [self.drawView clear];
}
//开始录制
- (IBAction)startClick:(id)sender {
    NSLog(@"%s",__func__);
    [self startRecordVoice];
}
//开始回放
- (IBAction)playbackClick:(id)sender {
    if (self.recording) {
        [UIToast showMessage:@"请先停止录制!"];
        return;
    }
    NSLog(@"%s",__func__);
    if (self.savePaths && self.savePaths.count >0) {
        
        NSString * url= [[[FileManager manager]
                          getAllSubFilePathFromDirectory:
                          AUDIO_FOLDER_PATH] objectAtIndex:0];
        PlayViewController * playVC =[[PlayViewController alloc]init];
        playVC.paths =self.savePaths;
        playVC.filePath =url;
        [self.navigationController pushViewController:playVC animated:YES];
    }else{
        [UIToast showMessage:@"您还没有绘制任何轨迹哦!"];
        NSLog(@"没有可以回放的轨迹");
    }
}
/**
 GCD开始倒计时
 */
- (void)startTimer {
    
    self.totalDuration =0;
    __block NSInteger second = 0;
    //全局队列    默认优先级
    dispatch_queue_t quene = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    //定时器模式  事件源
    dispatch_source_t timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, quene);
    
    _timer = timer;
    __weak typeof(self)weakSelf =self;
    //NSEC_PER_SEC是秒，＊1是每秒
    dispatch_source_set_timer(timer, dispatch_walltime(NULL, 0), NSEC_PER_SEC * 1, 0);
    //设置响应dispatch源事件的block，在dispatch源指定的队列上运行
    dispatch_source_set_event_handler(timer, ^{
        //回调主线程，在主线程中操作UI
        dispatch_async(dispatch_get_main_queue(), ^{
            weakSelf.title =[weakSelf convertStrToTime:second];
            second++;
        });
    });
    //启动源
    dispatch_resume(timer);
    
}

/**
 GCD停止计时
 */
- (void)stop {
    if ([_avAudioRecorder isRecording]) {
        [_avAudioRecorder stop];
    }
    if (_timer) {
        dispatch_source_cancel(_timer) ;
    }
    self.recording =NO;
}
- (NSString *)convertStrToTime:(NSInteger)time{
    
    self.totalDuration =time;
    
    long second = time%60;
    
    long m = time/60;
    
    NSString *timeString =[NSString stringWithFormat:@"%02ld分%02ld秒",m,second];
    
    return timeString;
}
#pragma mark - AVAudioRecorder Player
- (void)startRecordVoice{
    [self requestRecordingPermission:^(BOOL granted) {
        if (granted) {
            // begin recording
            if (self.recording)
                return ;
            
            // 重置
            dispatch_async(dispatch_get_main_queue(), ^{
                
                self.recording = YES;
                [self.drawView startDrawing];
                //开始timer，并且开始录音
                [self startRecording];
                [self startTimer];
                [UIToast showMessage:@"已经开始录制!"];
            });
            
        } else {
            // alert
            UIAlertController* alertController = [UIAlertController
                                                  alertControllerWithTitle: @"无权限"
                                                  message: @"请在设置中打开权限"
                                                  preferredStyle: UIAlertControllerStyleAlert];
            
            UIAlertAction* alertAction = [UIAlertAction actionWithTitle: @"确定"
                                                                  style: UIAlertActionStyleDefault
                                                                handler: nil];
            
            [alertController addAction: alertAction];
            
            [self presentViewController: alertController
                               animated: YES
                             completion: nil];
        }
    }];
}
#pragma mark - Logical Process
- (void)requestRecordingPermission: (void(^) (BOOL))callback {
    AVAudioSession* audioSession = [AVAudioSession sharedInstance];
    
    if ([audioSession respondsToSelector: @selector(requestRecordPermission:)]) {
        [audioSession performSelector: @selector(requestRecordPermission:)
                           withObject: ^(BOOL granted) {
                               callback(granted);
                           }];
    }
}
- (void)startRecording {
    AVAudioSession* audioSession = [AVAudioSession sharedInstance];
    NSError* error;
    
    [audioSession setCategory: AVAudioSessionCategoryPlayAndRecord
                        error: &error];
    
    if (audioSession == nil) {
        UIAlertController* alertController = [UIAlertController
                                              alertControllerWithTitle: @"Error"
                                              message: error.description
                                              preferredStyle: UIAlertControllerStyleAlert];
        
        UIAlertAction* okAction = [UIAlertAction actionWithTitle: @"确定"
                                                           style: UIAlertActionStyleDefault
                                                         handler: nil];
        
        [alertController addAction: okAction];
        
        [self presentViewController: alertController animated: YES
                         completion: nil];
        
        return ;
    }
    
    [audioSession setActive: YES
                      error: nil];
    
    self.audioSession = audioSession;
    
    NSDate* nowDate = [NSDate date];
    
    _curWavFilePath = [self generateAudioFilePathWithDate: nowDate
                                                   andExt: @"wav"];//caf
    _curAmrFilePath = [self generateAudioFilePathWithDate: nowDate
                                                   andExt: @"amr"];
    
    _curWavFileUrl = [NSURL fileURLWithPath: _curWavFilePath];
    
    NSDictionary* recordSettings = @{
                                     AVSampleRateKey: @8000.0f,                         // 采样率
                                     AVFormatIDKey: @(kAudioFormatLinearPCM),           // 音频格式
                                     AVLinearPCMBitDepthKey: @16,                       // 采样位数
                                     AVNumberOfChannelsKey: @1,                         // 音频通道
                                     AVEncoderAudioQualityKey: @(AVAudioQualityMedium)    // 录音质量
                                     };
    
    _avAudioRecorder = [[AVAudioRecorder alloc] initWithURL: _curWavFileUrl
                                                   settings: recordSettings
                                                      error: nil];
    
    if (!_avAudioRecorder) {
        UIAlertController* alertController = [UIAlertController
                                              alertControllerWithTitle: @"Error"
                                              message: @"Error init AVAudioRecorder"
                                              preferredStyle: UIAlertControllerStyleAlert];
        
        UIAlertAction* okAction = [UIAlertAction actionWithTitle: @"OK"
                                                           style: UIAlertActionStyleDefault
                                                         handler: nil];
        
        [alertController addAction: okAction];
        
        [self presentViewController: alertController
                           animated: YES
                         completion: nil];
        
        return ;
    }
    
    _avAudioRecorder.meteringEnabled = YES;
    [_avAudioRecorder prepareToRecord];
    [_avAudioRecorder record];
}
//停止录制，保存文件
- (void)saveRecording {
    if ([_avAudioRecorder isRecording]) {
        [_avAudioRecorder stop];
    }
    [UIToast showMessage:@"保存成功！"];
    NSLog(@"录制 %ld 秒，文件大小为 %liKb", (long)_totalDuration,
         [[FileManager manager] getFileSizeWithFilePath: _curWavFilePath]);
}
- (NSString*)generateAudioFilePathWithDate: (NSDate*)date
                                    andExt: (NSString*)ext {
//    NSInteger timeStamp = [[NSNumber numberWithDouble:
//                            [date timeIntervalSince1970]] integerValue];
    
    return [NSString stringWithFormat: @"%@/%@.%@", AUDIO_FOLDER_PATH,
            kRecordAudioFile, ext];
//    return [NSString stringWithFormat: @"%@/%li.%@", AUDIO_FOLDER_PATH,
//            timeStamp, ext];
}

#pragma mark - dealloc
-(void)dealloc{
    [self stop];
    NSLog(@"%s",__func__);
}
@end
/*
 声音数据量的计算公式为：
 
 数据量（字节/秒）= (采样频率（Hz）× 采样位数（bit） × 声道数)/ 8
 
 单声道的声道数为1，立体声的声道数为2。
 
 【例1】请计算对于5分钟双声道、16位采样位数、44.1kHz采样频率声音的不压缩数据量是多少？
 根据公式：数据量=（采样频率×采样位数×声道数×时间）/8
 得，数据量(MB)=[44.1×1000×16×2×（5×60）] /（8×1024×1024）=50.47MB
 计算时要注意几个单位的换算细节：
 时间单位换算：1分=60秒
 采样频率单位换算：1kHz=1000Hz
 数据量单位换算：1MB=1024×1024=1048576B
 */
