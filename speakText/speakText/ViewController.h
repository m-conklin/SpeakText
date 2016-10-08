//
//  ViewController.h
//  speakText
//
//  Created by Martin Conklin on 2016-10-07.
//  Copyright © 2016 Martin Conklin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

@interface ViewController : UIViewController <AVAudioRecorderDelegate, AVAudioPlayerDelegate>

@property (weak, nonatomic) IBOutlet UIButton * recordButton;
@property (weak, nonatomic) IBOutlet UIButton * stopButton;
@property (weak, nonatomic) IBOutlet UIButton * playButton;
@property (weak, nonatomic) IBOutlet UITextView *textView;

- (IBAction)recordButtonTapped:(UIButton *)sender;
- (IBAction)stopButtonTapped:(UIButton *)sender;
- (IBAction)playButtonTapped:(UIButton *)sender;

@end

