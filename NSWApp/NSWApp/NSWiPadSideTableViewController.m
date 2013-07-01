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
    [[NSWEventData sharedData] setDelegate:self];

    listDefaultFrame = CGRectMake(0, 42, _eventListView.frame.size.width, _eventListView.frame.size.height);
    listDownFrame = CGRectMake(0, 42+_locationSelectView.frame.size.height, _eventListView.frame.size.width, _eventListView.frame.size.height);
    locationSelectDefaultFrame = CGRectMake(0, 42-_locationSelectView.frame.size.height, _eventListView.frame.size.width, _locationSelectView.frame.size.height);
    locationSelectDownFrame = CGRectMake(0, 42, _eventListView.frame.size.width, _locationSelectView.frame.size.height);

    _locationSelectView.backgroundColor = [UIColor midnightBlueColor];

    
    NSArray *locationButtons = [NSArray arrayWithObjects:_locationACTButton, _locationNSWButton, _locationNTButton, _locationQLDButton, _locationSAButton, _locationTASButton, _locationVICButton, _locationWAButton, nil];
    
    for (FUIButton* locationButton in locationButtons) {
        [locationButton.titleLabel setFont:kGlobalNavBarItemFont];
        locationButton.buttonColor = kGlobalNavBarItemColour;
        locationButton.titleLabel.textColor = [UIColor whiteColor];
        locationButton.shadowColor = [UIColor grayColor];
        locationButton.cornerRadius = 3;
    }
    
    _locationSelectTitleLabel.font = kGlobalNavBarFont;
    _locationSelectTitleLabel.textColor = [UIColor whiteColor];
    
    
    lastFavouritesListOffset = 0.0;
    lastEventListOffset = 0.0;
    [self.eventListView reloadData];

    [super viewDidLoad];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

-(void)viewWillAppear:(BOOL)animated
{
    
    self.segmentedControlBackground.backgroundColor = kGlobalNavBarColour;
    self.listSegmentedControl.selectedColor = kGlobalNavBarItemColourHighlighted;
    self.listSegmentedControl.deselectedColor = kGlobalNavBarItemColour;
    self.listSegmentedControl.selectedFont = kGlobalNavBarItemFont;
    self.listSegmentedControl.deselectedFont = kGlobalNavBarItemFont;

    [self.navigationController.navigationBar configureFlatNavigationBarWithColor:kGlobalNavBarColour];

    [self.navigationController.navigationBar configureFlatNavigationBarWithColor:kGlobalNavBarColour];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
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
    return 44;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
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

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
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
    
    [cell prepareForTableView:tableView indexPath:indexPath];
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

    
    cell.textLabel.font = kEventListCellTitleFont;
    cell.detailTextLabel.font = kEventListCellDetailFont;
    cell.borderColor = kEventCellBorderColor;
    cell.cornerRadius = kEventCellCornerRadius;
    
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (displayData == ListEvents)
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
    [_eventListView reloadData];
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

    [self.eventListView reloadData];
}

- (void)newDataWasDownloaded
{
    
    [self reloadView];
    [self.eventListView reloadData];
    [(EventDetailViewController_iPad*)[[[[self.splitViewController viewControllers] objectAtIndex:1] viewControllers] objectAtIndex:0] refreshDetailedEventData];
    
    
}

- (IBAction)chooseLocation:(UIButton*)sender
{
    
    //[PopoverView showPopoverAtPoint:CGPointMake(sender.width, 0) inView:self.view withTitle:@"Choose Location" withStringArray:[NSArray arrayWithObjects:@"TAS", @"QLD", @"NT", @"SA", @"WA", @"ACT", @"VIC", @"NSW", nil] delegate:self];
    if (_eventListView.frame.origin.y >44) {
        
        [UIView animateWithDuration:0.5 delay:0 options:UIViewAnimationOptionBeginFromCurrentState animations:^{
            _eventListView.frame = listDefaultFrame;
            self.locationSelectView.frame = locationSelectDefaultFrame;
        } completion:nil];
        [sender setTitle:[sender.titleLabel.text stringByReplacingOccurrencesOfString:@"▲" withString:@"▼"] forState:UIControlStateNormal];
        
        _eventListView.userInteractionEnabled = YES;
    }
    else
    {
        [UIView animateWithDuration:0.5 delay:0 options:UIViewAnimationOptionBeginFromCurrentState animations:^{
            _eventListView.frame = listDownFrame;
            self.locationSelectView.frame = locationSelectDownFrame;
        } completion:nil];
        
        [sender setTitle:[sender.titleLabel.text stringByReplacingOccurrencesOfString:@"▼" withString:@"▲"] forState:UIControlStateNormal];
        _eventListView.userInteractionEnabled = NO;

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
}

- (void)viewDidUnload {
    [self setLocationSelectView:nil];
    [self setCurrentLocationButton:nil];
    [self setSegmentedControlBackground:nil];
    [super viewDidUnload];
}
@end
