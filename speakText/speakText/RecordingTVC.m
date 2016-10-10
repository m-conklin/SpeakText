//
//  RecordingTVC.m
//  speakText
//
//  Created by Martin Conklin on 2016-10-08.
//  Copyright © 2016 Martin Conklin. All rights reserved.
//

#import "RecordingTVC.h"
#import <CoreData/CoreData.h>
#import "Recording+CoreDataClass.h"
#import "DetailViewController.h"


@interface RecordingTVC () {
    NSArray *recordings;
    NSMutableArray *filteredResults;
}

@end

@implementation RecordingTVC


@synthesize managedObjectContext, recording, searchController;

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationController.navigationBar.barTintColor = [UIColor colorWithRed:0.71 green:0.73 blue:0.76 alpha:1.0];
    self.navigationController.navigationBar.tintColor = [UIColor colorWithRed:0xD6 green:0xE7 blue:0xEE alpha:0.75];
    
    
    filteredResults = [NSMutableArray array];
    searchController = [[UISearchController alloc] initWithSearchResultsController:nil];
    searchController.searchResultsUpdater = self;
    searchController.dimsBackgroundDuringPresentation = NO;
    searchController.definesPresentationContext = YES;
    
    searchController.searchBar.delegate = self;
    searchController.searchBar.scopeButtonTitles = [NSArray arrayWithObjects:@"All",@"Last 24h",@"Last 7d",@"Last 30d",nil];
    UITextField *searchTextField = (UITextField *)[searchController.searchBar valueForKey:@"searchField"];
    searchTextField.textColor = [UIColor darkGrayColor];
    searchController.searchBar.tintColor = [UIColor colorWithRed:0xD6 green:0xE7 blue:0xEE alpha:0.75];
    
    self.tableView.tableHeaderView = self.searchController.searchBar;
    self.definesPresentationContext = YES;
    
    
    self.tableView.allowsMultipleSelectionDuringEditing = NO;
    
    NSEntityDescription *entityDescription = [NSEntityDescription entityForName:@"Recording" inManagedObjectContext:managedObjectContext];
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    [fetchRequest setEntity:entityDescription];
    NSSortDescriptor *sort = [NSSortDescriptor sortDescriptorWithKey:@"dateRecorded" ascending:NO];
    NSArray *sortDescriptors = [NSArray arrayWithObject:sort];
    fetchRequest.sortDescriptors = sortDescriptors;
    NSError *error;
    recordings = [managedObjectContext executeFetchRequest:fetchRequest error:&error];
    
    if (recordings.count == 0) {
        NSLog(@"Failed to access core data");
    }
}

-(void)updateSearchResultsForSearchController:(UISearchController *)sc {
    NSString *searchText = sc.searchBar.text;
    NSString *searchFilter = sc.searchBar.scopeButtonTitles[sc.searchBar.selectedScopeButtonIndex];

        [self filterContentForSearchText:searchText :searchFilter];
        [self.tableView reloadData];
}

-(void)searchBar:(UISearchBar *)searchBar selectedScopeButtonIndexDidChange:(NSInteger)selectedScope {
    NSString *searchText = searchBar.text;
    NSString *searchFilter = searchBar.scopeButtonTitles[searchBar.selectedScopeButtonIndex];
    [self filterContentForSearchText:searchText :searchFilter];
    [self.tableView reloadData];

}

-(void)filterContentForSearchText:(NSString *)searchText :(NSString *)scope {
    [filteredResults removeAllObjects];
    for (Recording *record in recordings) {
        int date = [record.dateRecorded intValue];
        if (([searchText isEqualToString:@""] && [self checkDateScope:&date:scope]) || ([self checkDateScope:&date:scope] && [self titleContainsSearchText:searchText :record.title])) {
            [filteredResults addObject:record];
        }
    }
}

-(BOOL)titleContainsSearchText:(NSString *)searchText :(NSString *)title {
    NSString *lowerSearch = [searchText lowercaseString];
    NSString *lowerTitle = [title lowercaseString];
    if ([lowerTitle containsString:lowerSearch]) {
        return YES;
    }
    return NO;
}

-(BOOL)checkDateScope:(int *)date :(NSString *)scope {
    if ([scope isEqualToString:@"All"] || [scope isEqualToString:@""]) {
        return YES;
    }
    int timeframe = (int) -1 * [[NSDate date] timeIntervalSince1970];
    if ([scope isEqualToString:@"Last 24h"]) {
        // 24hr in seconds: 86400
        //timeframe is -now+24hr]
        if ((*date+timeframe+86400) >= 0 ){
            return YES;
        }
        return NO;
    } else if ([scope isEqualToString:@"Last 7d"]) {
        // 7 days in seconds: 604800
        //timeframe is -now+7day
        if ((*date+timeframe+604800) >= 0 ){
            return YES;
        }
        return NO;
    } else if ([scope isEqualToString:@"Last 30d"]) {
        // 30 days in seconds: 2592000
        //timeframe is -now+30day
        if ((*date+timeframe+2592000) >= 0 ){
            return YES;
        }
        return NO;
    }
    return NO;
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
        return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (!searchController.active) {
        return recordings.count;
    } else {
        return filteredResults.count;
    }
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
    
    Recording *recordingForCell;
    
    if (!searchController.active) {
        recordingForCell = recordings[indexPath.row];
    } else {
        recordingForCell = filteredResults[indexPath.row];
    }
    
    
    cell.textLabel.text = recordingForCell.title;
    NSDate *cellDate = [NSDate dateWithTimeIntervalSince1970:[recordingForCell.dateRecorded doubleValue]];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"MMM d, yyyy"];
    NSString *recordingDate = [dateFormatter stringFromDate:cellDate];
    cell.detailTextLabel.text = recordingDate;
    UIColor *textColor = [UIColor colorWithRed:0xD6 green:0xE7 blue:0xEE alpha:0.75];
    cell.textLabel.textColor = textColor;
    cell.detailTextLabel.textColor = textColor;
    
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    recording = recordings[indexPath.row];
    [self performSegueWithIdentifier:@"recording_detail" sender:nil];
}



// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}



// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [managedObjectContext deleteObject:[recordings objectAtIndex:indexPath.row]];
        NSError *error = nil;
        if (![managedObjectContext save:&error]) {
            NSLog(@"Error deleting from core data. %@ %@", error, [error localizedDescription]);
        }
        NSMutableArray *tempRecordings = [recordings mutableCopy];
        [tempRecordings removeObjectAtIndex:indexPath.row];
        recordings = tempRecordings;
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}







/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    DetailViewController *detailViewController = (DetailViewController *)[segue destinationViewController];
    detailViewController.managedObjectContext = [self managedObjectContext];
    detailViewController.recording = recording;

}


@end


