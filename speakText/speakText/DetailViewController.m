//
//  DetailViewController.m
//  speakText
//
//  Created by Martin Conklin on 2016-10-08.
//  Copyright © 2016 Martin Conklin. All rights reserved.
//

#import "DetailViewController.h"
#import <CoreData/CoreData.h>
#import <AVFoundation/AVFoundation.h>



@interface DetailViewController () {
    AVAudioPlayer *player;
}

@end

@implementation DetailViewController

@synthesize recording, managedObjectContext, playPauseButton, stopButton, textView;

- (void)viewDidLoad {
    [super viewDidLoad];

    textView.text = recording.transcript;
    
    NSArray *pathComponents = [NSArray arrayWithObjects:[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject],recording.file, nil];
    NSURL *recordingURL = [NSURL fileURLWithPathComponents:pathComponents];
    
    player = [[AVAudioPlayer alloc] initWithContentsOfURL:recordingURL error:nil];
    [player setDelegate:self];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (void) audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag{
}

- (IBAction)playPauseTapped:(UIButton *)sender {
    if (player.playing) {
        [player stop];
    } else {
        [player play];
    }
    
}

- (IBAction)stopTapped:(UIButton *)sender {
    if (player.playing) {
        [player stop];
    }
}
@end
