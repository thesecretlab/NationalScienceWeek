//
//  NSWiPadSideTableViewController.h
//  NSWApp
//
//  Created by Nicholas Wittison on 13/06/13.
//
//

#import <UIKit/UIKit.h>
#import "NSWEventData.h"
#import "FUISegmentedControl.h"

enum DisplayListPickerValue {
    ListEvents = 0,
    ListFavourites = 1
    };

@interface NSWiPadSideTableViewController : UIViewController <NSWEventDataDelegate, UITableViewDataSource, UITableViewDelegate>
{
    enum DisplayListPickerValue displayData;
}
@property (weak, nonatomic) IBOutlet FUISegmentedControl *listSegmentedControl;

@property (weak, nonatomic) IBOutlet UITableView *eventListView;

@property (nonatomic, strong) NSArray* uniqueSingleDates;
-(IBAction) valueChanged: (id) sender;

@end
