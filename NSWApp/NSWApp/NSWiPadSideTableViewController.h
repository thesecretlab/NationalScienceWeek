//
//  NSWiPadSideTableViewController.h
//  NSWApp
//
//  Created by Nicholas Wittison on 13/06/13.
//
//

#import <UIKit/UIKit.h>
#import "NSWEventData.h"

@interface NSWiPadSideTableViewController : UIViewController <NSWEventDataDelegate, UITableViewDataSource, UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *eventListView;

@property (nonatomic, strong) NSArray* uniqueSingleDates;

@end
