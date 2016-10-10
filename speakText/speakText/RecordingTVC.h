//
//  RecordingTVC.h
//  speakText
//
//  Created by Martin Conklin on 2016-10-08.
//  Copyright © 2016 Martin Conklin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Recording+CoreDataClass.h"

@interface RecordingTVC : UITableViewController <UISearchControllerDelegate, UISearchResultsUpdating, UISearchBarDelegate>

@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (strong, nonatomic) Recording *recording;
@property (strong, nonatomic) UISearchController *searchController;

- (BOOL)checkDateScope:(int *)date :(NSString *)scope;
- (BOOL)titleContainsSearchText:(NSString *)searchText :(NSString *)title;

@end
