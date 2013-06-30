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
    float lastEventListOffset;
    float lastFavouritesListOffset;
    CGRect listDownFrame;
    CGRect listDefaultFrame;
    CGRect locationSelectDownFrame;
    CGRect locationSelectDefaultFrame;
    
}
@property (weak, nonatomic) IBOutlet FUISegmentedControl *listSegmentedControl;
@property (weak, nonatomic) IBOutlet UIView *locationSelectView;
@property (weak, nonatomic) IBOutlet UIButton *currentLocationButton;

@property (weak, nonatomic) IBOutlet UITableView *eventListView;

@property (nonatomic, strong) NSArray* uniqueSingleDates;
-(IBAction) valueChanged: (id) sender;
- (IBAction)pushModalView:(id)sender;
-(IBAction)scrollToTodaysDate;
- (void)reloadView;
- (void)newDataWasDownloaded;
-(IBAction)newLocationButtonPressed:(UIButton*)sender;
-(IBAction)chooseLocation:(UIButton*)sender;

@end
