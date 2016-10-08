//
//  ViewController.m
//  speakText
//
//  Created by Martin Conklin on 2016-10-07.
//  Copyright © 2016 Martin Conklin. All rights reserved.
//

#import "ViewController.h"
#import "speakText-swift.h"
#import <AVFoundation/AVFoundation.h>
#import <Foundation/Foundation.h>

@interface ViewController () {
    AVAudioRecorder *recorder;
    AVAudioPlayer *player;
    SpeechToTextBridge *speechToTextBridge;
    NSURL *outputFileURL;

}

@end

@implementation ViewController
@synthesize stopButton, playButton, recordButton, textView;


- (IBAction)recordButtonTapped:(UIButton *)sender {
    if (player.playing) {
        [player stop];
    }
    
    if (!recorder.recording) {
        AVAudioSession *session = [AVAudioSession sharedInstance];
        [session setActive:YES error:nil];
        
        //Begin recording
        [recorder record];
        [recordButton setTitle:@"Pause" forState:UIControlStateNormal];
    } else {
        [recorder pause];
        [recordButton setTitle:@"Record" forState:UIControlStateNormal];
    }
    [stopButton setEnabled:YES];
    [playButton setEnabled:NO];
}

- (IBAction)stopButtonTapped:(UIButton *)sender {
    [recorder stop];
    AVAudioSession *audioSession = [AVAudioSession sharedInstance];
    [audioSession setActive:NO error:nil];
}

- (IBAction)playButtonTapped:(UIButton *)sender {
    if (!recorder.recording) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
            speechToTextBridge = [[SpeechToTextBridge alloc] init];
            [speechToTextBridge synthesize:outputFileURL];

        });
        
        
        [recordButton setTitle:@"Record" forState:UIControlStateNormal];
        speechToTextBridge = [[SpeechToTextBridge alloc] init];
        [speechToTextBridge synthesize:outputFileURL];
        player = [[AVAudioPlayer alloc] initWithContentsOfURL:recorder.url error:nil];
        [player setDelegate:self];
        [player play];
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    [stopButton setEnabled:NO];
    [playButton setEnabled:NO];
    
    //Add listner
    NSNotificationCenter *ns = [NSNotificationCenter defaultCenter];
    [ns addObserver:self selector:@selector(updateTextView:) name:@"TextReturnedFromWatson" object:nil];
    
    //Audio Path
    NSArray *pathComponents = [NSArray arrayWithObjects:[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject],@"Test.wav", nil];
    outputFileURL = [NSURL fileURLWithPathComponents:pathComponents];
    
    //Audio session
    AVAudioSession *session = [AVAudioSession sharedInstance];
    [session setCategory:AVAudioSessionCategoryPlayAndRecord error:nil];
    
    //Define recorder setting
    NSMutableDictionary *recordSetting = [[NSMutableDictionary alloc] init];
    
    [recordSetting setValue:[NSNumber numberWithInt:kAudioFormatLinearPCM] forKey:AVFormatIDKey];
    [recordSetting setValue:[NSNumber numberWithFloat:44100.0] forKey:AVSampleRateKey];
    [recordSetting setValue:[NSNumber numberWithInt:2] forKey:AVNumberOfChannelsKey];
    
    //Initialize recorder
    recorder = [[AVAudioRecorder alloc] initWithURL:outputFileURL settings:recordSetting error:NULL];
    recorder.delegate = self;
    recorder.meteringEnabled = YES;
    [recorder prepareToRecord];
}

- (void)updateTextView:(NSNotification *)notification {
    dispatch_async(dispatch_get_main_queue(), ^{ // 2
        NSDictionary *dictionary = [notification userInfo];
        textView.text = dictionary[@"text"];
    });
   }

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) audioRecorderDidFinishRecording:(AVAudioRecorder *)recorder successfully:(BOOL)flag {
    [stopButton setEnabled:NO];
    [playButton setEnabled:YES];
}

- (void) audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag{
}


@end
