//
//  AudioManager.m
//  CWDemo
//
//  Created by gaoshuhuan on 2019/3/8.
//  Copyright © 2019年 gsh. All rights reserved.
//

#import "AudioManager.h"
#define kAudioFolder @"AudioFolder" // 音频文件夹

@interface AudioManager ()<AVAudioRecorderDelegate,AVAudioPlayerDelegate>

@property (nonatomic,strong) AVAudioRecorder *audioRecorder;    // 录音机
@property (nonatomic,strong) AVAudioPlayer *audioPlayer;        // 音频播放器
@property (strong ,nonatomic) NSDictionary *setting;            // 录音机的设置
@property (copy ,nonatomic) NSString *audioDir;                 // 录音文件夹路径
@property (nonatomic,strong) NSTimer *timer;    // 录音声波监控
@property (copy ,nonatomic) NSString *filename; // 记录当前文件名
@property (assign ,nonatomic) BOOL cancelCurrentRecord;    // 取消当前录制

@end
@implementation AudioManager
+(instancetype)sharedInstance{
    static AudioManager *instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[AudioManager alloc] init];
    });
    return instance;
}
#pragma mark - <************************** 一些初始化 **************************>
// !!!: 配置录音机
-(void)setupRecorder{
    //设置音频会话
    NSError *sessionError;
    [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryRecord error:&sessionError];
    if (sessionError){
        NSLog(@"Error creating session: %@",[sessionError description]);
    }else{
        [[AVAudioSession sharedInstance] setActive:YES error:&sessionError];
    }
    //录音设置
    //创建录音文件保存路径
    NSURL *url = [self getSavePath];
    //创建录音机
    NSError *error = nil;
    _audioRecorder = [[AVAudioRecorder alloc] initWithURL:url settings:self.setting error:&error];
    _audioRecorder.delegate = self;
    _audioRecorder.meteringEnabled = YES;//如果要监控声波则必须设置为YES
    [_audioRecorder prepareToRecord];
    if (error) {
        NSLog(@"创建录音机对象时发生错误，错误信息：%@",error.localizedDescription);
    }
}


// !!!: 录音声波监
-(NSTimer *)timer{
    if (!_timer) {
        _timer=[NSTimer scheduledTimerWithTimeInterval:0.1f target:self selector:@selector(powerChange) userInfo:nil repeats:YES];
    }
    return _timer;
}

// !!!: 录音设置
-(NSDictionary *)setting{
    if (_setting==nil) {
        NSMutableDictionary *setting = [NSMutableDictionary dictionary];
        //录音格式
        [setting setObject:@(kAudioFormatLinearPCM) forKey:AVFormatIDKey];
        //采样率，8000/11025/22050/44100/96000（影响音频的质量）,8000是电话采样率
        [setting setObject:@(22050) forKey:AVSampleRateKey];
        //通道 , 1/2
        [setting setObject:@(2) forKey:AVNumberOfChannelsKey];
        //采样点位数，分为8、16、24、32, 默认16
        [setting setObject:@(16) forKey:AVLinearPCMBitDepthKey];
        //是否使用浮点数采样
        [setting setObject:@(YES) forKey:AVLinearPCMIsFloatKey];
        // 录音质量
        [setting setObject:@(AVAudioQualityHigh) forKey:AVEncoderAudioQualityKey];
        //....其他设置等
    }
    return _setting;
}

// !!!: 录音文件夹
-(NSString *)audioDir{
    if (_audioDir==nil) {
        _audioDir = NSTemporaryDirectory();
        _audioDir = [_audioDir stringByAppendingPathComponent:kAudioFolder];
        BOOL isDir = NO;
        NSFileManager *fileManager = [NSFileManager defaultManager];
        BOOL existed = [fileManager fileExistsAtPath:_audioDir isDirectory:&isDir];
        if (!(isDir == YES && existed == YES)){
            [fileManager createDirectoryAtPath:_audioDir withIntermediateDirectories:YES attributes:nil error:nil];
        }
    }
    return _audioDir;
}

#pragma mark - <************************** 事件 **************************>
// !!!: 开始录制
-(void)startRecord{
    [self setupRecorder];
    if (![self.audioRecorder isRecording]) {
        [self.audioRecorder record];//首次使用应用时如果调用record方法会询问用户是否允许使用麦克风
        //        [self.audioRecorder recordForDuration:60];    // 录音时长
        self.timer.fireDate=[NSDate distantPast];
    }
}
// !!!: 暂停录制
-(void)pauseRecord{
    if ([self.audioRecorder isRecording]) {
        [self.audioRecorder pause];
        self.timer.fireDate=[NSDate distantFuture];
    }
}
// !!!: 恢复录制
-(void)resumeRecord{
    if (![self.audioRecorder isRecording]) {
        [self.audioRecorder record];
        self.timer.fireDate=[NSDate distantPast];
    }
}
// !!!: 停止录制
-(void)stopRecord{
    [self.audioRecorder stop];
    self.timer.fireDate=[NSDate distantFuture];
}

// !!!: 取消当前录制
-(void)cancelRecord{
    self.cancelCurrentRecord = YES;
    [self stopRecord];
    if ([self.audioRecorder deleteRecording]) {
        NSLog(@"删除录音文件!");
    }
}


// !!!: 播放音频文件
-(void)playAudioWithUrl:(NSURL*)url{
    //语音播放
    NSError *error=nil;
    _audioPlayer=[[AVAudioPlayer alloc] initWithContentsOfURL:url error:&error];
    _audioPlayer.numberOfLoops=0;   // 设置为0不循环
    _audioPlayer.delegate = self;
    if (error) {
        NSLog(@"创建播放器过程中发生错误，错误信息：%@",error.localizedDescription);
    }
    if (![_audioPlayer isPlaying]) {
        //解决音量小的问题
        AVAudioSession *audioSession = [AVAudioSession sharedInstance];
        NSError *err = nil;
        [audioSession setCategory:AVAudioSessionCategoryPlayback error:&err];
        [_audioPlayer play];    // 播放音频
    }
}

// !!!: 停止播放语音
-(void)stopPlay{
    [self.audioPlayer stop];
}

// !!!: 暂停语音
-(void)pausePlay{
    [self.audioPlayer pause];
}

// !!!: 恢复语音
-(void)resumePlay{
    [self.audioPlayer play];
}


#pragma mark - <************************** 获取数据 **************************>
// !!!: 获取录音保存路径
-(NSURL*)getSavePath{
    self.filename = [NSString stringWithFormat:@"audio_%@.wav",[self getDateString]];
    NSString* fileUrlString = [self.audioDir stringByAppendingPathComponent:self.filename];
    NSURL *url = [NSURL fileURLWithPath:fileUrlString];
    return url;
}

// !!!: 返回音频文件地址
-(NSURL *)recordCurrentAudioFile{
    NSString* fileUrlString = [self.audioDir stringByAppendingPathComponent:self.filename];
    NSURL *url = [NSURL fileURLWithPath:fileUrlString];
    return url;
}


// !!!: 获取语音时长
-(float)durationWithAudio:(NSURL *)audioUrl{
    AVURLAsset* audioAsset = [AVURLAsset URLAssetWithURL:audioUrl options:nil];
    CMTime audioDuration = audioAsset.duration;
    float audioDurationSeconds = CMTimeGetSeconds(audioDuration);
    return audioDurationSeconds;
}


// !!!: 删除所有文件夹
-(void)removeAllAudioFile{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if ([fileManager removeItemAtPath:self.audioDir error:nil]) {
        NSLog(@"删除文件夹成功！！");
    }
}

// !!!: 删除指定文件
-(void)removeAudioFile:(NSURL *)url{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if ([fileManager removeItemAtPath:url.path error:nil]) {
        NSLog(@"删除录音文件成功！！");
    }
}

// !!!: 删除指定后缀的文件
-(void)removeFileSuffixList:(NSArray<NSString *> *)suffixList filePath:(NSString *)path{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSArray *contentOfFolder = [fileManager contentsOfDirectoryAtPath:path error:NULL];
    for (NSString *aPath in contentOfFolder) {
        NSString * fullPath = [path stringByAppendingPathComponent:aPath];
        BOOL isDir = NO;
        if ([fileManager fileExistsAtPath:fullPath isDirectory:&isDir]) {
            if (isDir == YES) {
                // 是文件夹，则继续遍历
                [self removeFileSuffixList:suffixList filePath:fullPath];
            }
            else{
                NSLog(@"file-:%@", aPath);
                for (NSString* suffix in suffixList) {
                    if ([aPath hasSuffix:suffix]) {
                        if ([fileManager removeItemAtPath:fullPath error:nil]) {
                            NSLog(@"删除文件成功！！");
                        }
                    }
                }
            }
        }
    }
}



#pragma mark - <************************** 代理方法 **************************>
// !!!: 录音代理事件
-(void)audioRecorderDidFinishRecording:(AVAudioRecorder *)recorder successfully:(BOOL)flag{
    if (self.cancelCurrentRecord) {
        self.cancelCurrentRecord = NO;
        NSLog(@"取消录制！");
    }
    else{
        if (self.delegate&&[self.delegate respondsToSelector:@selector(audioRecorderDidFinishRecording:successfullyFlag:)]) {
            [self.delegate audioRecorderDidFinishRecording:recorder successfullyFlag:flag];
        }
        NSLog(@"录制完成!");
    }
}
// !!!: 播放语音代理事件
- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag{
    if (self.delegate&&[self.delegate respondsToSelector:@selector(audioPlayerDidFinishPlaying:successfully:)]) {
        [self.delegate audioPlayerDidFinishPlaying:player successfully:flag];
    }
    NSLog(@"播放完成!");
}


#pragma mark - <************************** 私有方法 **************************>
// !!!: 获取时刻名称
-(NSString*)getDateString{
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    NSInteger unitFlags = NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay | NSCalendarUnitWeekday |
    NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitSecond;
    NSDateComponents *comps  = [calendar components:unitFlags fromDate:[NSDate date]];
    NSInteger year = [comps year];
    NSInteger month = [comps month];
    NSInteger day = [comps day];
    NSInteger hour = [comps hour];
    NSInteger min = [comps minute];
    NSInteger sec = [comps second];
    NSString* formatString = @"%d%02d%02d%02d%02d%02d";
    return [NSString stringWithFormat:formatString, year, month, day, hour, min, sec];
}

// !!!: 录音声波状态设置
-(void)powerChange{
    [self.audioRecorder updateMeters];//更新测量值
    float power = [self.audioRecorder averagePowerForChannel:0];//取得第一个通道的音频，注意音频强度范围时-160到0
    CGFloat progress = power+160.0;
    NSLog(@"音频强度：%f",power);
    if (self.delegate&&[self.delegate respondsToSelector:@selector(audioPowerChange:)]) {
        [self.delegate audioPowerChange:progress];
    }
}

-(void)dealloc{
    [self removeAllAudioFile];
}

@end
