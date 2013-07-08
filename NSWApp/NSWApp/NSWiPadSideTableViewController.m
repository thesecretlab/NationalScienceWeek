//
//  NSWiPadSideTableViewController.m
//  NSWApp
//
//  Created by Nicholas Wittison on 13/06/13.
//
//

#import "NSWiPadSideTableViewController.h"
#import "NSWAppAppearanceConfig.h"
#import "NSWEventData.h"
#import "PrettyTableViewCell.h"
#import <QuartzCore/QuartzCore.h>
#import "UINavigationBar+FlatUI.h"
#import "EventDetailViewController_iPad.h"
#import "FUISegmentedControl.h"
#import "NSWInfoViewController_iPad.h"
#import "CustomSearchBar.h"
#import "UIImage+FlatUI.h"

@interface NSWiPadSideTableViewController ()

@end

@implementation NSWiPadSideTableViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    trayOut = NO;
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(onKeyboardHide:) name:UIKeyboardWillHideNotification object:nil];

    
    self.noEventsLabel.font = kLargeLabelFont;
    
    [[NSWEventData sharedData] setDelegate:self];

    listDefaultFrame = CGRectMake(0, 42, _eventListView.frame.size.width, _eventListView.frame.size.height);
    listDownFrame = CGRectMake(0, 42+_locationSelectView.frame.size.height, _eventListView.frame.size.width, _eventListView.frame.size.height);
    locationSelectDefaultFrame = CGRectMake(0, 42-_locationSelectView.frame.size.height, _eventListView.frame.size.width, _locationSelectView.frame.size.height);
    locationSelectDownFrame = CGRectMake(0, 42, _eventListView.frame.size.width, _locationSelectView.frame.size.height);

    _locationSelectView.backgroundColor = [UIColor clearColor];

    
    NSArray *locationButtons = [NSArray arrayWithObjects:_locationACTButton, _locationNSWButton, _locationNTButton, _locationQLDButton, _locationSAButton, _locationTASButton, _locationVICButton, _locationWAButton, nil];
    
    UIImage *highlightedBackgroundImage = [UIImage buttonImageWithColor:kGlobalNavBarItemColourHighlighted
                                                           cornerRadius:kDetailCornerRadius
                                                            shadowColor:[UIColor clearColor]
                                                           shadowInsets:UIEdgeInsetsMake(0, 0, 0, 0)];

    
    
    for (FUIButton* locationButton in locationButtons) {
        [locationButton.titleLabel setFont:kGlobalNavBarItemFont];
        locationButton.buttonColor = kGlobalNavBarItemColour;
        
        locationButton.titleLabel.textColor = [UIColor whiteColor];
        locationButton.shadowColor = [UIColor grayColor];
        locationButton.cornerRadius = 3;
        [locationButton setBackgroundImage:highlightedBackgroundImage forState:UIControlStateHighlighted];

    }
    
    _locationSelectTitleLabel.font = kGlobalNavBarFont;
    _locationSelectTitleLabel.textColor = [UIColor whiteColor];
    
    
    for(UIView *subView in self.searchBar.subviews) {
        if ([subView isKindOfClass:[UITextField class]]) {
            UITextField *searchField = (UITextField *)subView;
            searchField.font = kGlobalNavBarItemFont;
        }
    }
    
    [[UIBarButtonItem appearanceWhenContainedIn:[UISearchBar class], nil] setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIColor whiteColor],UITextAttributeTextColor,[UIColor colorWithRed:0 green:0 blue:0 alpha:0.6],UITextAttributeTextShadowColor,[NSValue valueWithUIOffset:UIOffsetMake(0, -1)],UITextAttributeTextShadowOffset, kGlobalNavBarItemFont, UITextAttributeFont, nil] forState:UIControlStateNormal];
    
    self.searchBar.backgroundColor = kGlobalNavBarColour;
    [[[self.searchBar subviews] objectAtIndex:0] setAlpha:0.0];
    self.searchBar.tintColor = kGlobalNavBarItemColour;
    
    
    self.currentLocationButton.titleLabel.font = kGlobalNavBarFont;
    UIImage *normalBackgroundImage = [UIImage buttonImageWithColor:kGlobalNavBarItemColour
                                                      cornerRadius:kDetailCornerRadius
                                                       shadowColor:[UIColor grayColor]
                                                      shadowInsets:UIEdgeInsetsMake(0, 0, 0, 0)];

    
    [self.currentLocationButton setBackgroundImage:normalBackgroundImage forState:UIControlStateNormal];
    [self.currentLocationButton setBackgroundImage:highlightedBackgroundImage forState:UIControlStateHighlighted];
    
    
    lastFavouritesListOffset = 0.0;
    lastEventListOffset = 0.0;
    [self reloadView];
    [self scrollToTodaysDate];
    [super viewDidLoad];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

-(void)viewWillAppear:(BOOL)animated
{
    
    [self updateTableViewAndBackgroundFrames];

    self.segmentedControlBackground.backgroundColor = kGlobalNavBarColour;
    self.listSegmentedControl.selectedColor = kGlobalNavBarItemColourHighlighted;
    self.listSegmentedControl.deselectedColor = kGlobalNavBarItemColour;
    self.listSegmentedControl.selectedFont = kGlobalNavBarItemFont;
    self.listSegmentedControl.deselectedFont = kGlobalNavBarItemFont;

    [self.navigationController.navigationBar configureFlatNavigationBarWithColor:kGlobalNavBarColour];

    [self.navigationController.navigationBar configureFlatNavigationBarWithColor:kGlobalNavBarColour];
}

-(void)onKeyboardHide:(NSNotification *)notification
{
   // [self updateTableViewAndBackgroundFrames];
}

- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar
{

    // only show the status bar’s cancel button while in edit mode sbar (UISearchBar)
    searchBar.showsCancelButton = YES;
    searchBar.autocorrectionType = UITextAutocorrectionTypeNo;
    UIImage *normalBackgroundImage = [UIImage buttonImageWithColor:kGlobalNavBarItemColour
                                                      cornerRadius:kDetailCornerRadius
                                                       shadowColor:[UIColor grayColor]
                                                      shadowInsets:UIEdgeInsetsMake(0, 0, 0, 0)];
    
    UIImage *highlightedBackgroundImage = [UIImage buttonImageWithColor:kGlobalNavBarItemColourHighlighted
                                                              cornerRadius:kDetailCornerRadius
                                                                shadowColor:[UIColor grayColor]
                                                           shadowInsets:UIEdgeInsetsMake(0, 0, 0, 0)];
    
    
    
    for (UIView *subView in searchBar.subviews){
        if([subView isKindOfClass:[UIButton class]]){
            
            [(UIButton *)subView setBackgroundImage:normalBackgroundImage forState:UIControlStateNormal];
            [(UIButton *)subView setBackgroundImage:highlightedBackgroundImage forState:UIControlStateHighlighted];

        }
    }
    
    self.searchDisplayController.searchResultsTableView.backgroundColor = [UIColor clearColor];
    self.searchDisplayController.searchResultsTableView.separatorColor = [UIColor clearColor];

    UIImageView *duplicateBackground = [[UIImageView alloc] initWithImage:self.tableViewBackgroundImage.image];
    duplicateBackground.frame = self.tableViewBackgroundImage.frame;
    duplicateBackground.contentMode = UIViewContentModeScaleAspectFill;
    self.searchDisplayController.searchResultsTableView.backgroundView = duplicateBackground;

    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (void)updateListNoEventsLabel
{
    if(self.eventListView.numberOfSections == 0)
    {
        self.noEventsLabel.hidden = NO;
    }
    else
    {
        self.noEventsLabel.hidden = YES;
    }
    
    if (displayData == ListEvents)
    {
        self.noEventsLabel.text = @"Sorry, there was a problem loading events";
    }
    else if (displayData == ListFavourites)
    {
        self.noEventsLabel.text = @"No favourited events";
        
    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    
    if (tableView == self.searchDisplayController.searchResultsTableView)
    {
        return 1;
    }
    if (displayData == ListEvents)
    {
        self.uniqueSingleDates = [[NSWEventData sharedData] uniqueSingleDates];
    }
    else if (displayData == ListFavourites)
    {
        self.uniqueSingleDates = [[NSWEventData sharedData] uniqueSingleDatesForFavourites];
    }
    
    return [self.uniqueSingleDates count];
}


-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    
    if (tableView == self.searchDisplayController.searchResultsTableView)
    {
        return nil;
    }
    UIView *customTitleView = [ [UIView alloc] initWithFrame:CGRectMake(10, 0, 300, 44)];
    
    UILabel *titleLabel = [ [UILabel alloc] initWithFrame:customTitleView.frame];
    
    
    if (section < [self.uniqueSingleDates count]) {
        
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"dd/MM/yyyy"];
        NSDate *titleDate = [dateFormatter dateFromString:[self.uniqueSingleDates objectAtIndex:section]];
        [dateFormatter setDateFormat:@"EEEE, MMMM d"];
        
        NSString *prefixDateString = [dateFormatter stringFromDate:titleDate];
        //UIView *backingView = [[UIView alloc] initWithFrame: CGRectMake(12, 6, 296, 34)];
        //backingView.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.4];
        ////backingView.layer.cornerRadius = 5;
        //backingView.clipsToBounds = YES;
        //[customTitleView addSubview:backingView];
        //UIImageView *imageview = [[UIImageView alloc]initWithImage:kImageForCellHeaderBackground];
        //imageview.frame = customTitleView.frame;
        
        //[customTitleView addSubview:imageview];
        //imageview.backgroundColor = [UIColor whiteColor];
        //NSLog(@"%f, %f", imageview.image.size.height, imageview.image.size.width);
        [dateFormatter setDateFormat:@"d"];
        int date_day = [[dateFormatter stringFromDate:titleDate] intValue];
        NSString *suffix_string = @"|st|nd|rd|th|th|th|th|th|th|th|th|th|th|th|th|th|th|th|th|th|st|nd|rd|th|th|th|th|th|th|th|st";
        NSArray *suffixes = [suffix_string componentsSeparatedByString: @"|"];
        NSString *suffix = [suffixes objectAtIndex:date_day];
        NSString *dateString = [prefixDateString stringByAppendingString:suffix];
        
        titleLabel.text = dateString;
    }
    else {
        titleLabel.text = @"Multi-Date Events";
    }
    
    titleLabel.textColor = [UIColor whiteColor];
    
    titleLabel.font = kEventListHeaderCellFont;
    
    titleLabel.backgroundColor = [UIColor clearColor];
    
    [customTitleView addSubview:titleLabel];
    
    return customTitleView;
    
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if (tableView == self.searchDisplayController.searchResultsTableView)
    {
        return 0;
    }
    else
    {
        return 44;

    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    [self updateListNoEventsLabel];

    if (tableView == self.searchDisplayController.searchResultsTableView)
    {
        return [searchResults count];
    }
    else {
        if (section < [self.uniqueSingleDates count]) {
            
            if (displayData == ListEvents) {
                return [[[NSWEventData sharedData] eventsForDate:[self.uniqueSingleDates objectAtIndex:section]]count];

            }
            else if(displayData == ListFavourites)
            {
                return [[[NSWEventData sharedData] eventsForDateInFavourites:[self.uniqueSingleDates objectAtIndex:section]]count];
            }

        }
        return 0;
    }
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{

    if (tableView == self.searchDisplayController.searchResultsTableView)
    {
        CGFloat totalHeight = 0;
        NSString *text = [[searchResults objectAtIndex:indexPath.row] objectForKey:@"Title"];
        
        CGSize constraint = CGSizeMake(320 - 70, 20000.0f);
        
        CGSize size = [text sizeWithFont:kEventListCellTitleFont constrainedToSize:constraint lineBreakMode:UILineBreakModeWordWrap];
        
        CGFloat height = MAX(size.height, 21.0f);
        
        totalHeight = totalHeight + height;
        
        text = [NSString stringWithFormat:@"%@\nPLACEHOLDERTEXTEXAMPLE",[[searchResults objectAtIndex:indexPath.row] objectForKey:@"Location"]];
        
        constraint = CGSizeMake(320 - 70, 20000.0f);
        
        size = [text sizeWithFont:kEventListCellDetailFont constrainedToSize:constraint lineBreakMode:UILineBreakModeWordWrap];
        
        height = MAX(size.height, 18.0f);
        
        totalHeight = totalHeight + height;
        return totalHeight + 20+ [PrettyTableViewCell
                                  tableView:tableView neededHeightForIndexPath:indexPath];
    }
    else
    {
        NSArray *eventArray;
        if (displayData == ListEvents) {
            eventArray = [[NSWEventData sharedData] eventsForDate:[self.uniqueSingleDates objectAtIndex:indexPath.section]];
        }
        else if(displayData == ListFavourites)
        {
            eventArray = [[NSWEventData sharedData] eventsForDateInFavourites:[self.uniqueSingleDates objectAtIndex:indexPath.section]];
        }
        
            if (indexPath.section < [self.uniqueSingleDates count]) {
                CGFloat totalHeight = 0;
                NSString *text = [[eventArray objectAtIndex:indexPath.row] objectForKey:@"Title"];
                
                CGSize constraint = CGSizeMake(320 - 70, 20000.0f);
                
                CGSize size = [text sizeWithFont:kEventListCellTitleFont constrainedToSize:constraint lineBreakMode:UILineBreakModeWordWrap];
                
                CGFloat height = MAX(size.height, 21.0f);
                
                totalHeight = totalHeight + height;
                
                text = [[eventArray objectAtIndex:indexPath.row] objectForKey:@"Location"];
                
                constraint = CGSizeMake(320 - 70, 20000.0f);
                
                size = [text sizeWithFont:kEventListCellDetailFont constrainedToSize:constraint lineBreakMode:UILineBreakModeWordWrap];
                
                height = MAX(size.height, 18.0f);
                
                totalHeight = totalHeight + height;
                return totalHeight + 20+ [PrettyTableViewCell
                                          tableView:tableView neededHeightForIndexPath:indexPath];
            }
        
        
        return 0;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"YouWhat";
    
    PrettyTableViewCell *cell = [tableView
                                 dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil) {
        cell = [[PrettyTableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        cell.textLabel.numberOfLines = 0;
        cell.detailTextLabel.numberOfLines = 0;
    }
    
    [cell prepareForTableView:self.eventListView indexPath:indexPath];
    
    if (tableView == self.searchDisplayController.searchResultsTableView)
    {
        
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"dd/MM/yyyy"];
        NSDate *titleDate = [dateFormatter dateFromString:[[searchResults objectAtIndex:indexPath.row] objectForKey:@"Date"]];
        [dateFormatter setDateFormat:@"EEEE, MMMM d"];
        
        NSString *prefixDateString = [dateFormatter stringFromDate:titleDate];
        [dateFormatter setDateFormat:@"d"];
        int date_day = [[dateFormatter stringFromDate:titleDate] intValue];
        NSString *suffix_string = @"|st|nd|rd|th|th|th|th|th|th|th|th|th|th|th|th|th|th|th|th|th|st|nd|rd|th|th|th|th|th|th|th|st";
        NSArray *suffixes = [suffix_string componentsSeparatedByString: @"|"];
        NSString *suffix = [suffixes objectAtIndex:date_day];
        NSString *date = [prefixDateString stringByAppendingString:suffix];
        cell.detailTextLabel.text = [NSString stringWithFormat:@"%@\n%@",[[searchResults objectAtIndex:indexPath.row] objectForKey:@"Location"],date];

        
        cell.textLabel.text = [[searchResults objectAtIndex:indexPath.row] objectForKey:@"Title"];
        
        //[[searchResults objectAtIndex:indexPath.row] objectForKey:@"Location"];
        cell.customBackgroundColor = [UIColor whiteColor];
        cell.textLabel.backgroundColor = [UIColor whiteColor];
        cell.detailTextLabel.backgroundColor = [UIColor whiteColor];
        cell.position = PrettyTableViewCellPositionAlone; //Sets it to be alone. FOREVERALONE
    }
    else
    {
        if (indexPath.section < [self.uniqueSingleDates count])
        {
            NSArray *eventsForDate;
            if (displayData == ListEvents)
            {
                eventsForDate = [[NSWEventData sharedData] eventsForDate:[self.uniqueSingleDates objectAtIndex:indexPath.section]];
            }
            else if (displayData == ListFavourites)
            {
                eventsForDate = [[NSWEventData sharedData] eventsForDateInFavourites:[self.uniqueSingleDates objectAtIndex:indexPath.section]];
            }
            
            cell.textLabel.text = [[eventsForDate objectAtIndex:indexPath.row] objectForKey:@"Title"];
            cell.detailTextLabel.text = [[eventsForDate objectAtIndex:indexPath.row] objectForKey:@"Location"];
        }
    }
    
    cell.textLabel.font = kEventListCellTitleFont;
    cell.detailTextLabel.font = kEventListCellDetailFont;
    cell.borderColor = kEventCellBorderColor;
    cell.cornerRadius = kEventCellCornerRadius;
    cell.selectionGradientStartColor = [UIColor colorWithRed:0 green:30/255.0 blue:150/255.0 alpha:1];
    cell.selectionGradientEndColor = [UIColor colorWithRed:0 green:30/255.0 blue:150/255.0 alpha:1];

    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    if (tableView == self.searchDisplayController.searchResultsTableView)
    {
       [(EventDetailViewController_iPad*)[[[self.splitViewController.viewControllers lastObject] viewControllers]objectAtIndex:0] setEvent:[searchResults objectAtIndex:indexPath.row]];
        
    }
    else if (displayData == ListEvents)
    {
        [(EventDetailViewController_iPad*)[[[self.splitViewController.viewControllers lastObject] viewControllers]objectAtIndex:0] setEvent:[[[NSWEventData sharedData] eventsForDate:[self.uniqueSingleDates objectAtIndex:indexPath.section]] objectAtIndex:indexPath.row]];
    }
    else if (displayData == ListFavourites)
    {
        [(EventDetailViewController_iPad*)[[[self.splitViewController.viewControllers lastObject] viewControllers]objectAtIndex:0] setEvent:[[[NSWEventData sharedData] eventsForDateInFavourites:[self.uniqueSingleDates objectAtIndex:indexPath.section]] objectAtIndex:indexPath.row]];
    }
    
    [(EventDetailViewController_iPad*)[[[self.splitViewController.viewControllers lastObject] viewControllers]objectAtIndex:0] updateAndRelayoutView];
        
}


-(IBAction) valueChanged: (id) sender {
    FUISegmentedControl *segmentedControl = (FUISegmentedControl*) sender;
    switch ([segmentedControl selectedSegmentIndex]) {
        case ListEvents:
            displayData = ListEvents;
            lastFavouritesListOffset = self.eventListView.contentOffset.y;
            [self.eventListView setContentOffset:CGPointMake(0, lastEventListOffset)];
            break;
        case ListFavourites:
            displayData = ListFavourites;
            lastEventListOffset = self.eventListView.contentOffset.y;
            [self.eventListView setContentOffset:CGPointMake(0, lastFavouritesListOffset)];
            break;
        default:
            NSLog(@"No option for: %d", [segmentedControl selectedSegmentIndex]);
    }
    [self reloadView];
    [self updateListNoEventsLabel];

}

-(void)scrollToTodaysDate
{
    
    if ([self.uniqueSingleDates count] == 0) {
        return;
    }
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"dd/MM/yyyy"];
    
    NSString *dateToScrollTo;
    BOOL foundExactMatch = NO;
    for (NSString *dateString in self.uniqueSingleDates)
    {
        
        NSDate *eventDate = [dateFormatter dateFromString:dateString];
        
        NSComparisonResult compareResult = [(NSDate*)[NSDate date] compare:eventDate];
        
        if(compareResult == NSOrderedDescending)
        {
            dateToScrollTo = dateString;
        }
        else if(compareResult == NSOrderedAscending)
        {
            
        }
        if ([dateString isEqualToString:[dateFormatter stringFromDate:[NSDate date]]])
        {
            dateToScrollTo = dateString;
            foundExactMatch = YES;
        }
        
    }
    
    if(dateToScrollTo == nil)
    {
        [self.eventListView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]atScrollPosition:UITableViewScrollPositionTop animated:YES];
    }
    else
    {
        if (foundExactMatch) {
            [self.eventListView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:[self.uniqueSingleDates indexOfObject:dateToScrollTo]]atScrollPosition:UITableViewScrollPositionTop animated:YES];
        }
        else
        {
            
            [self.eventListView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:[self.uniqueSingleDates indexOfObject:dateToScrollTo]+1]atScrollPosition:UITableViewScrollPositionTop animated:YES];
        }
        
    }
    
}

- (IBAction)pushModalView:(id)sender
{
    UINavigationController *infoPanel = [self.storyboard instantiateViewControllerWithIdentifier:@"infoPanel"];
    infoPanel.modalPresentationStyle = UIModalPresentationFormSheet;
    [(NSWInfoViewController_iPad*)[[infoPanel viewControllers] objectAtIndex:0] setDelegate:self.splitViewController];
    [self.splitViewController presentModalViewController:infoPanel animated:YES];
}

- (void)reloadView
{

    [self updateTableViewAndBackgroundFrames];
    [_currentLocationButton setTitle:[NSString stringWithFormat:@"%@ | ▼", [[NSWEventData sharedData] currentLocationAcronym]] forState:UIControlStateNormal];
    [self.eventListView reloadData];
    [self updateListNoEventsLabel];

}

- (void)newDataWasDownloaded
{
    
    [self reloadView];
    [(EventDetailViewController_iPad*)[[[[self.splitViewController viewControllers] objectAtIndex:1] viewControllers] objectAtIndex:0] refreshDetailedEventData];
    
    
}

- (IBAction)chooseLocation:(UIButton*)sender
{
    
    //[PopoverView showPopoverAtPoint:CGPointMake(sender.width, 0) inView:self.view withTitle:@"Choose Location" withStringArray:[NSArray arrayWithObjects:@"TAS", @"QLD", @"NT", @"SA", @"WA", @"ACT", @"VIC", @"NSW", nil] delegate:self];
    if (trayOut) {
        
        [UIView animateWithDuration:0.5 delay:0 options:UIViewAnimationOptionBeginFromCurrentState animations:^{
            _eventListView.frame = listDefaultFrame;
            self.locationSelectView.frame = locationSelectDefaultFrame;
        } completion:^(BOOL finished) {
            [self updateTableViewAndBackgroundFrames];
        }];
        [sender setTitle:[sender.titleLabel.text stringByReplacingOccurrencesOfString:@"▲" withString:@"▼"] forState:UIControlStateNormal];
        
        _eventListView.userInteractionEnabled = YES;
        trayOut = NO;
    }
    else
    {
        [UIView animateWithDuration:0.5 delay:0 options:UIViewAnimationOptionBeginFromCurrentState animations:^{
            _eventListView.frame = listDownFrame;
            self.locationSelectView.frame = locationSelectDownFrame;
        } completion:^(BOOL finished)
        {
            [self updateTableViewAndBackgroundFrames];
        }];
        
        [sender setTitle:[sender.titleLabel.text stringByReplacingOccurrencesOfString:@"▼" withString:@"▲"] forState:UIControlStateNormal];
        _eventListView.userInteractionEnabled = NO;
        trayOut = YES;
    }
    
    
    //@"Tasmania", @"Queensland", @"New South Wales", @"Victoria", @"South Australia", @"Western Australia", @"Australian Capital Territory",@"Northern Territory"
}

-(void)newLocationButtonPressed:(UIButton*)sender
{
    NSString *mappedStateChoice;
    if ([sender.titleLabel.text isEqualToString:@"Australian Capital Territory"])
    {
        mappedStateChoice = @"ACT";
    }
    if ([sender.titleLabel.text isEqualToString:@"New South Wales"])
    {
        mappedStateChoice = @"NSW";
    }
    if ([sender.titleLabel.text isEqualToString:@"Northern Territory"])
    {
        mappedStateChoice = @"NT";
    }
    if ([sender.titleLabel.text isEqualToString:@"Queensland"])
    {
        mappedStateChoice = @"QLD";
    }
    if ([sender.titleLabel.text isEqualToString:@"South Australia"])
    {
        mappedStateChoice = @"SA";
    }
    if ([sender.titleLabel.text isEqualToString:@"Tasmania"])
    {
        mappedStateChoice = @"TAS";
    }
    if ([sender.titleLabel.text isEqualToString:@"Victoria"])
    {
        mappedStateChoice = @"VIC";
    }
    if ([sender.titleLabel.text isEqualToString:@"Western Australia"])
    {
        mappedStateChoice = @"WA";
    }
    
    [[NSWEventData sharedData]changeLocation:mappedStateChoice];
    [_currentLocationButton setTitle:[NSString stringWithFormat:@"%@ | ▼", mappedStateChoice] forState:UIControlStateNormal];
    [self chooseLocation:nil];
    [self scrollToTodaysDate];
}

- (void)filterContentForSearchText:(NSString*)searchText scope:(NSString*)scope
{
    NSPredicate *resultPredicate = [NSPredicate
                                    predicateWithFormat:@"(Title contains[cd] %@ OR Description contains[cd] %@)",
                                    searchText, searchText];
    
    searchResults = [[[NSWEventData sharedData] eventsForLocation] filteredArrayUsingPredicate:resultPredicate];
}

-(BOOL)searchDisplayController:(UISearchDisplayController *)controller
shouldReloadTableForSearchString:(NSString *)searchString
{
    
    [self filterContentForSearchText:searchString
                               scope:nil];
    
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, 0.001);
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        for (UIView* v in self.searchDisplayController.searchResultsTableView.subviews) {
            if ([v isKindOfClass: [UILabel class]] &&
                [[(UILabel*)v text] isEqualToString:@"No Results"]) {
                [(UILabel*)v setFont:kGlobalNavBarFont];
                [(UILabel*)v setTextColor:[UIColor whiteColor]];
                break;
            }
        }
    });

    return YES;
}

- (void)updateTableViewAndBackgroundFrames
{
    
    if (!trayOut) {
        self.eventListView.frame = CGRectMake(self.view.frame.origin.x, self.view.frame.origin.x+self.segmentedControlBackground.frame.size.height, self.view.frame.size.width, self.view.frame.size.height-44); //Minus Nav Bar Height (its including it for some reason.. weird master view thing I suspect
        self.tableViewBackgroundImage.frame = self.eventListView.frame;
    }
    else{
        self.tableViewBackgroundImage.frame = CGRectMake(self.view.frame.origin.x, self.view.frame.origin.x+self.segmentedControlBackground.frame.size.height, self.view.frame.size.width, self.view.frame.size.height-44);        
    }
    

}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{

    [self updateTableViewAndBackgroundFrames];
    
}



- (void)viewDidUnload {
    [self setLocationSelectView:nil];
    [self setCurrentLocationButton:nil];
    [self setSegmentedControlBackground:nil];
    [self setNoEventsLabel:nil];
    [self setSearchBar:nil];
    [self setTableViewBackgroundImage:nil];
    [super viewDidUnload];
}
@end
