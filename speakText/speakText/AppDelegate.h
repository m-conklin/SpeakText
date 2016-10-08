//
//  AppDelegate.h
//  speakText
//
//  Created by Martin Conklin on 2016-10-07.
//  Copyright © 2016 Martin Conklin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (readonly, strong) NSPersistentContainer *persistentContainer;

- (void)saveContext;


@end

