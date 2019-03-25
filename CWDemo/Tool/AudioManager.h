//
//  AudioManager.h
//  CWDemo
//
//  Created by gaoshuhuan on 2019/3/8.
//  Copyright © 2019年 gsh. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
@protocol AudioManagerDelegate;

NS_ASSUME_NONNULL_BEGIN

@interface AudioManager : NSObject
@property (nonatomic,weak) id <AudioManagerDelegate> delegate;
+(instancetype)sharedInstance;

// 开始录制
-(void)startRecord;

// 暂停录制
-(void)pauseRecord;

// 恢复录制
-(void)resumeRecord;

// 停止录制
-(void)stopRecord;

// 取消当前录制
-(void)cancelRecord;

// 播放语音
-(void)playAudioWithUrl:(NSURL*)url;

// 停止语音播放
-(void)stopPlay;

// 暂停语音播放
-(void)pausePlay;

// 恢复语音播放
-(void)resumePlay;

// 获取当前录制文件的路径
-(NSURL*)recordCurrentAudioFile;

// 获取语音时长
-(float)durationWithAudio:(NSURL *)audioUrl;

// 删除本地音频文件下所有文件
-(void)removeAllAudioFile;

// 删除本地指定音频文件
-(void)removeAudioFile:(NSURL*)url;

// 删除指定后缀的文件，如“.wav”,“.caf”
-(void)removeFileSuffixList:(NSArray<NSString*>*)suffixList filePath:(NSString*)path;

@end
@protocol AudioManagerDelegate <NSObject>
@optional
-(void)audioRecorderDidFinishRecording:(AVAudioRecorder*)recorder successfullyFlag:(BOOL)flag;  // 录制完成
-(void)audioPowerChange:(CGFloat)power; // 音量
-(void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag; // 播放完成
@end

NS_ASSUME_NONNULL_END
