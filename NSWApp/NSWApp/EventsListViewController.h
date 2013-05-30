//
//  EventsListViewController.h
//  NSWApp
//
//  Created by Nicholas Wittison on 17/07/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NSWEventData.h"
#import "FUISegmentedControl.h"
@interface EventsListViewController : UIViewController <NSWEventDataDelegate>
@property (weak, nonatomic) IBOutlet UITableView *eventListTableView;
@property (nonatomic, strong) NSArray* uniqueSingleDates;
@property (weak, nonatomic) IBOutlet FUISegmentedControl *segmentedLocationControl;
@property (strong, nonatomic) IBOutlet UITapGestureRecognizer *doubleTap;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *todayButton;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *currentLocationButton;
@property (weak, nonatomic) IBOutlet UILabel *currentLocationLabel;
- (IBAction)nextLocationPressed:(id)sender;
- (IBAction)previousLocationPressed:(id)sender;
- (void)newDataWasDownloaded;
- (void)reloadView;
-(IBAction)scrollToTodaysDate;
- (IBAction)cellDoubleTapped:(id)sender;
- (IBAction)chooseLocation:(id)sender;

@end
