//
//  Recording+CoreDataProperties.h
//  speakText
//
//  Created by Martin Conklin on 2016-10-08.
//  Copyright © 2016 Martin Conklin. All rights reserved.
//

#import "Recording+CoreDataClass.h"


NS_ASSUME_NONNULL_BEGIN

@interface Recording (CoreDataProperties)

+ (NSFetchRequest<Recording *> *)fetchRequest;

@property (nullable, nonatomic, copy) NSString *file;
@property (nullable, nonatomic, copy) NSString *transcript;
@property (nullable, nonatomic, copy) NSString *title;
@property (nullable, nonatomic, copy) NSNumber *dateRecorded;

@end

NS_ASSUME_NONNULL_END
