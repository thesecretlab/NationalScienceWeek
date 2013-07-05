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
#import "FUIButton.h"
enum DisplayListPickerValue {
    ListEvents = 0,
    ListFavourites = 1
    };

@interface NSWiPadSideTableViewController : UIViewController <NSWEventDataDelegate, UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate>
{
    enum DisplayListPickerValue displayData;
    float lastEventListOffset;
    float lastFavouritesListOffset;
    CGRect listDownFrame;
    CGRect listDefaultFrame;
    CGRect locationSelectDownFrame;
    CGRect locationSelectDefaultFrame;
    NSArray *searchResults;
    BOOL trayOut;
    
}
@property (weak, nonatomic) IBOutlet UIImageView *tableViewBackgroundImage;
@property (weak, nonatomic) IBOutlet FUISegmentedControl *listSegmentedControl;
@property (weak, nonatomic) IBOutlet UIView *locationSelectView;
@property (weak, nonatomic) IBOutlet UIView *locationSelectHeaderView;
@property (weak, nonatomic) IBOutlet FUIButton *locationSAButton;
@property (weak, nonatomic) IBOutlet FUIButton *locationTASButton;
@property (weak, nonatomic) IBOutlet FUIButton *locationVICButton;
@property (weak, nonatomic) IBOutlet FUIButton *locationWAButton;
@property (weak, nonatomic) IBOutlet FUIButton *locationACTButton;
@property (weak, nonatomic) IBOutlet FUIButton *locationNSWButton;
@property (weak, nonatomic) IBOutlet FUIButton *locationNTButton;
@property (weak, nonatomic) IBOutlet FUIButton *locationQLDButton;
@property (weak, nonatomic) IBOutlet UILabel *locationSelectTitleLabel;


@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;
@property (weak, nonatomic) IBOutlet FUIButton *currentLocationButton;
@property (weak, nonatomic) IBOutlet UILabel *noEventsLabel;

@property (weak, nonatomic) IBOutlet UIView *segmentedControlBackground;
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
