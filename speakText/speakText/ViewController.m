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
#import <CoreData/CoreData.h>
#import "RecordingTVC.h"

@interface ViewController () {
    AVAudioRecorder *recorder;
    AVAudioPlayer *player;
    SpeechToTextBridge *speechToTextBridge;
    NSURL *outputFileURL;
    NSString *filename;
}

@end

@implementation ViewController

- (NSManagedObjectContext *)managedObjectContext {
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    NSManagedObjectContext *context = appDelegate.persistentContainer.newBackgroundContext;
    return context;
}

@synthesize stopButton, playButton, recordButton, textView, saveButton;

- (void)viewDidLoad {
    [super viewDidLoad];
    //Initialize button states
    [stopButton setEnabled:NO];
    [playButton setEnabled:NO];
    [saveButton setEnabled:NO];
    saveButton.hidden = YES;
    playButton.hidden = YES;
    self.textView.text = @"";
    
    self.navigationController.navigationBar.barTintColor = [UIColor colorWithRed:0.71 green:0.73 blue:0.76 alpha:1.0];
    
    //Add listner
    NSNotificationCenter *ns = [NSNotificationCenter defaultCenter];
    [ns addObserver:self selector:@selector(updateTextView:) name:@"TextReturnedFromWatson" object:nil];
    
    //Audio Path
    filename = [NSString stringWithFormat:@"%d%@", (int) [[NSDate date] timeIntervalSince1970], @".wav"];
    
    NSArray *pathComponents = [NSArray arrayWithObjects:[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject],filename, nil];
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



- (IBAction)recordButtonTapped:(UIButton *)sender {
    if (player.playing) {
        [player stop];
    }
    if (!recorder.recording) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{

            AVAudioSession *session = [AVAudioSession sharedInstance];
            [session setActive:YES error:nil];
            
            //Begin recording
            [recorder record];
            
            speechToTextBridge = [[SpeechToTextBridge alloc] init];
            [speechToTextBridge startStreaming];
        });
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
    [speechToTextBridge stopStreaming];
    [recordButton setTitle:@"Record" forState:UIControlStateNormal];
    [saveButton setEnabled:YES];
    saveButton.hidden = NO;
    playButton.hidden = NO;
    AVAudioSession *audioSession = [AVAudioSession sharedInstance];
    [audioSession setActive:NO error:nil];
}

- (IBAction)playButtonTapped:(UIButton *)sender {
    if (!recorder.recording) {
        player = [[AVAudioPlayer alloc] initWithContentsOfURL:recorder.url error:nil];
        [player setDelegate:self];
        [player play];
    }
}

- (IBAction)saveButtonTapped:(UIButton *)sender {
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Save" message:@"Please enter a title" preferredStyle:UIAlertControllerStyleAlert];
    
    
    [alertController addTextFieldWithConfigurationHandler:^(UITextField *textField) {
        textField.placeholder = @"Title";
        textField.textColor = [UIColor grayColor];
        textField.clearButtonMode = UITextFieldViewModeWhileEditing;
//        textField.borderStyle = UITextBorderStyleRoundedRect;
    }];
    
    [alertController addAction:[UIAlertAction actionWithTitle:@"Save" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        NSString *title = alertController.textFields[0].text;
        [self saveRecording:title];
    }]];
    [alertController addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil]];
    alertController.view.tintColor = [UIColor darkGrayColor];
    alertController.view.backgroundColor = [UIColor colorWithRed:0x2B green:0xAE blue:0xFF alpha:1.0];
    
//    alertController.v
    [self presentViewController:alertController animated:YES completion:nil];
}

-(void)saveRecording:(NSString *)title {
    NSManagedObjectContext *managedContext = self.managedObjectContext;
    NSManagedObject *newRecording = [NSEntityDescription insertNewObjectForEntityForName:@"Recording" inManagedObjectContext:managedContext];
    [newRecording setValue:title forKey:@"title"];
    [newRecording setValue:filename forKey:@"file"];
    [newRecording setValue:textView.text forKey:@"transcript"];
    int date = (int)[[NSDate date] timeIntervalSince1970];
    NSNumber *dateRecorded = [NSNumber numberWithInteger:date];
    [newRecording setValue:dateRecorded forKey:@"dateRecorded"];
    
    NSError *error = nil;
    
    if (![managedContext save:&error]) {
        NSLog(@"Error saving to core data: %@ %@", error, [error localizedDescription]);
    } else {
        [self viewDidLoad];
    }
}



//- (void)viewDidLoad {
//    [super viewDidLoad];
//    //Initialize button states
//    [stopButton setEnabled:NO];
//    [playButton setEnabled:NO];
//    [saveButton setEnabled:NO];
//    saveButton.hidden = YES;
//    playButton.hidden = YES;
//    self.textView.text = @"";
//    
//    self.navigationController.navigationBar.barTintColor = [UIColor colorWithRed:0.71 green:0.73 blue:0.76 alpha:1.0];
//    
//    //Add listner
//    NSNotificationCenter *ns = [NSNotificationCenter defaultCenter];
//    [ns addObserver:self selector:@selector(updateTextView:) name:@"TextReturnedFromWatson" object:nil];
//    
//    //Audio Path
//    filename = [NSString stringWithFormat:@"%d%@", (int) [[NSDate date] timeIntervalSince1970], @".wav"];
//    
//    NSArray *pathComponents = [NSArray arrayWithObjects:[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject],filename, nil];
//    outputFileURL = [NSURL fileURLWithPathComponents:pathComponents];
//    
//    //Audio session
//    AVAudioSession *session = [AVAudioSession sharedInstance];
//    [session setCategory:AVAudioSessionCategoryPlayAndRecord error:nil];
//    
//    //Define recorder setting
//    NSMutableDictionary *recordSetting = [[NSMutableDictionary alloc] init];
//    
//    [recordSetting setValue:[NSNumber numberWithInt:kAudioFormatLinearPCM] forKey:AVFormatIDKey];
//    [recordSetting setValue:[NSNumber numberWithFloat:44100.0] forKey:AVSampleRateKey];
//    [recordSetting setValue:[NSNumber numberWithInt:2] forKey:AVNumberOfChannelsKey];
//    
//    //Initialize recorder
//    recorder = [[AVAudioRecorder alloc] initWithURL:outputFileURL settings:recordSetting error:NULL];
//    recorder.delegate = self;
//    recorder.meteringEnabled = YES;
//    [recorder prepareToRecord];
//}



- (void)updateTextView:(NSNotification *)notification {
    dispatch_async(dispatch_get_main_queue(), ^{
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

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
//    UINavigationController *navigationController = [segue destinationViewController];
    RecordingTVC *recordingTVC = (RecordingTVC *)[segue destinationViewController]; //([navigationController viewControllers][0]);
    recordingTVC.managedObjectContext = [self managedObjectContext];
}


@end
