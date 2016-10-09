//
//  DetailViewController.h
//  speakText
//
//  Created by Martin Conklin on 2016-10-08.
//  Copyright © 2016 Martin Conklin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import "Recording+CoreDataClass.h"

@interface DetailViewController : UIViewController <AVAudioRecorderDelegate, AVAudioPlayerDelegate>

@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (strong, nonatomic) Recording *recording;

@property (weak, nonatomic) IBOutlet UIButton *playPauseButton;
@property (weak, nonatomic) IBOutlet UIButton *stopButton;
@property (weak, nonatomic) IBOutlet UITextView *textView;

- (IBAction)playPauseTapped:(UIButton *)sender;
- (IBAction)stopTapped:(UIButton *)sender;


@end
