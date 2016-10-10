//
//  Recording+CoreDataProperties.m
//  speakText
//
//  Created by Martin Conklin on 2016-10-08.
//  Copyright © 2016 Martin Conklin. All rights reserved.
//

#import "Recording+CoreDataProperties.h"

@implementation Recording (CoreDataProperties)

+ (NSFetchRequest<Recording *> *)fetchRequest {
	return [[NSFetchRequest alloc] initWithEntityName:@"Recording"];
}

@dynamic file;
@dynamic transcript;
@dynamic title;
@dynamic dateRecorded;

@end
