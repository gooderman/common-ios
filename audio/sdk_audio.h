//
//  sdk_audio.h
//  pdk
//
//  Created by Jeep on 16/12/15.
//
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import<AVFoundation/AVFoundation.h>

#import "lame.h"



@interface sdk_audio : NSObject<AVAudioRecorderDelegate>{
    
    // 保存录音的文件名称
    NSString *mRecordFileName;
    NSString *mRecordCafFileName;
    NSTimeInterval recordDuration;
    
    AVAudioRecorder* s_audiorec;
    
    AVAudioSession* s_audio_session;
    int recordResult;
}


+ (sdk_audio *)sharedSdkAudio;

- (instancetype) init;
//0 ok
- (BOOL) start_record:(NSString*)filename;

- (void) stop_record;

- (int) record_getVolume;

/* audioRecorderDidFinishRecording:successfully: is called when a recording has been finished or stopped. This method is NOT called if the recorder is stopped due to an interruption. */
- (void)audioRecorderDidFinishRecording:(AVAudioRecorder *)recorder successfully:(BOOL)flag;

/* if an error occurs while encoding it will be reported to the delegate. */
- (void)audioRecorderEncodeErrorDidOccur:(AVAudioRecorder *)recorder error:(NSError * __nullable)error;


- (void)dealloc;

@end
