//
//  FavouriteEventsViewController.h
//  NSWApp
//
//  Created by Nicholas Wittison on 24/07/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NSWEventData.h"
@interface FavouriteEventsViewController : UIViewController <NSWEventDataDelegate>
@property (weak, nonatomic) IBOutlet UITableView *favouriteEventsTableView;
@property (nonatomic, strong) NSArray* uniqueSingleDates;
@property (strong, nonatomic) IBOutlet UITapGestureRecognizer *doubleTapRecogniser;
@property (weak, nonatomic) IBOutlet UILabel *noFavouritedEventsLabel;
- (IBAction)cellDoubleTapped:(UITapGestureRecognizer *)sender;

@end
