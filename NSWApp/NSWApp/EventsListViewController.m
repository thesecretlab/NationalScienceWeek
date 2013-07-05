//
//  EventsListViewController.m
//  NSWApp
//
//  Created by Nicholas Wittison on 17/07/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "EventsListViewController.h"
#import "NSWEventData.h"
#import "EventDetailViewController.h"
#import "EventListCell.h"
#import "UIColor+FlatUI.h"
#import "UINavigationBar+FlatUI.h"
#import "UIBarButtonItem+FlatUI.h"
#import "FUISegmentedControl.h"
#import "UIFont+FlatUI.h"
#import "PopoverView.h"
#import "NSWAppAppearanceConfig.h"
#import "PrettyTableViewCell.h"
#import <QuartzCore/QuartzCore.h>
#import "UIImage+FlatUI.h"
@interface EventsListViewController ()

@end

@implementation EventsListViewController
@synthesize eventListTableView;
@synthesize uniqueSingleDates;
@synthesize segmentedLocationControl;
@synthesize doubleTap;
@synthesize currentLocationLabel;
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        [[NSWEventData sharedData] setDelegate:self];
        
        // Custom initialization
    }
    return self;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    
    if (tableView == self.searchDisplayController.searchResultsTableView)
    {
        return 1;
    }
    else
    {
        self.uniqueSingleDates = [[NSWEventData sharedData] uniqueSingleDates];
        
        if ([[[NSWEventData sharedData] multiDateEvents] count] > 0) {
            return [self.uniqueSingleDates count]+1;

        }
        else {
            return [self.uniqueSingleDates count];
        }
    }
}


-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    
    if (tableView == self.searchDisplayController.searchResultsTableView)
    {
        return nil;
    }
    
    UIView *customTitleView = [ [UIView alloc] initWithFrame:CGRectMake(10, 0, 300, 44)];
    
    UILabel *titleLabel = [ [UILabel alloc] initWithFrame:CGRectMake(18, 0, 300, 44)];
    
    
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
/*
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if (section < [self.uniqueSingleDates count]) {
        
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"dd/MM/yyyy"];
        NSDate *titleDate = [dateFormatter dateFromString:[self.uniqueSingleDates objectAtIndex:section]];
        [dateFormatter setDateFormat:@"EEEE, MMM d"];
       return [dateFormatter stringFromDate:titleDate];
    }
    else {
        return @"Multi-Date Events";
    }
    
}
*/
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (tableView == self.searchDisplayController.searchResultsTableView)
    {
        return [searchResults count];
    }
    
    if (section < [self.uniqueSingleDates count]) {
        return [[[NSWEventData sharedData] eventsForDate:[self.uniqueSingleDates objectAtIndex:section]]count];
    }
    else {
        return [[[NSWEventData sharedData] multiDateEvents] count];
    }
    
    
    //return 0; //[[[NSWEventData sharedData] eventData] count];
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
        
        text = [[searchResults objectAtIndex:indexPath.row] objectForKey:@"Location"];
        
        constraint = CGSizeMake(320 - 70, 20000.0f);
        
        size = [text sizeWithFont:kEventListCellDetailFont constrainedToSize:constraint lineBreakMode:UILineBreakModeWordWrap];
        
        height = MAX(size.height, 18.0f);
        
        totalHeight = totalHeight + height;
        return totalHeight + 20+ [PrettyTableViewCell
                                  tableView:tableView neededHeightForIndexPath:indexPath];
    }
    
    
	if (tableView == eventListTableView)
	{

        
        if (indexPath.section < [self.uniqueSingleDates count]) {
            CGFloat totalHeight = 0;
        NSString *text = [[[[NSWEventData sharedData] eventsForDate:[self.uniqueSingleDates objectAtIndex:indexPath.section]] objectAtIndex:indexPath.row] objectForKey:@"Title"];

            CGSize constraint = CGSizeMake(320 - 70, 20000.0f);
            
            CGSize size = [text sizeWithFont:kEventListCellTitleFont constrainedToSize:constraint lineBreakMode:UILineBreakModeWordWrap];
            
            CGFloat height = MAX(size.height, 21.0f);
            
            totalHeight = totalHeight + height;
        
            text = [[[[NSWEventData sharedData] eventsForDate:[self.uniqueSingleDates objectAtIndex:indexPath.section]] objectAtIndex:indexPath.row] objectForKey:@"Location"];
            
             constraint = CGSizeMake(320 - 70, 20000.0f);
            
             size = [text sizeWithFont:kEventListCellDetailFont constrainedToSize:constraint lineBreakMode:UILineBreakModeWordWrap];
            
             height = MAX(size.height, 18.0f);
            
            totalHeight = totalHeight + height;
            return totalHeight + 20+ [PrettyTableViewCell
                                      tableView:tableView neededHeightForIndexPath:indexPath];
        }
        else {
            CGFloat totalHeight = 0;
            NSString *text = [[[[NSWEventData sharedData] multiDateEvents] objectAtIndex:indexPath.row] objectForKey:@"Title"];
            
            CGSize constraint = CGSizeMake(320 -70, 20000.0f);
            
            CGSize size = [text sizeWithFont:kEventListCellTitleFont constrainedToSize:constraint lineBreakMode:UILineBreakModeWordWrap];
            
            CGFloat height = MAX(size.height, 21.0f);
            
            totalHeight = totalHeight + height;
            
            text = [[[[NSWEventData sharedData] multiDateEvents] objectAtIndex:indexPath.row] objectForKey:@"Location"];
            
            constraint = CGSizeMake(320 -70, 20000.0f);
            
            size = [text sizeWithFont:kEventListCellDetailFont constrainedToSize:constraint lineBreakMode:UILineBreakModeWordWrap];
            
            height = MAX(size.height, 18.0f);
            
            totalHeight = totalHeight + height;
            return totalHeight + 20;
        }

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
    
    [cell prepareForTableView:self.eventListTableView indexPath:indexPath];
    
    if (tableView == self.searchDisplayController.searchResultsTableView)
    {
        cell.textLabel.text = [[searchResults objectAtIndex:indexPath.row] objectForKey:@"Title"];
        cell.detailTextLabel.text = [[searchResults objectAtIndex:indexPath.row] objectForKey:@"Location"];
        cell.customBackgroundColor = [UIColor whiteColor];
        cell.textLabel.backgroundColor = [UIColor whiteColor];
        cell.detailTextLabel.backgroundColor = [UIColor whiteColor];
        cell.position = PrettyTableViewCellPositionAlone; //Sets it to be alone. FOREVERALONE
    }
    else
    {
        if (indexPath.section < [self.uniqueSingleDates count])
        {
            
            NSArray *eventsForDate = [[NSWEventData sharedData] eventsForDate:[self.uniqueSingleDates objectAtIndex:indexPath.section]];
            
            cell.textLabel.text = [[eventsForDate objectAtIndex:indexPath.row] objectForKey:@"Title"]; 
            cell.detailTextLabel.text = [[eventsForDate objectAtIndex:indexPath.row] objectForKey:@"Location"];
            

            
        }
        else 
        {
            cell.textLabel.text = [[[[NSWEventData sharedData] multiDateEvents] objectAtIndex:indexPath.row] objectForKey:@"Title"]; 
            cell.detailTextLabel.text = [[[[NSWEventData sharedData] multiDateEvents] objectAtIndex:indexPath.row] objectForKey:@"Location"];
        
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
- (void) tableView: (UITableView *) tableView didSelectRowAtIndexPath: (NSIndexPath *) indexPath
{
    
    if (tableView == self.searchDisplayController.searchResultsTableView)
    {
        [self performSegueWithIdentifier:@"PushFromSearch" sender:[tableView cellForRowAtIndexPath:indexPath]];

        
    }
    else
    {
        [self performSegueWithIdentifier:@"PushToDetail" sender:[tableView cellForRowAtIndexPath:indexPath]];
    }

}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    NSLog(@"Segue %@, sender %@", segue.identifier, sender);
    
    if ([segue.identifier isEqualToString:@"PushFromSearch"])
    {
        
        NSIndexPath *indexPath = [self.searchDisplayController.searchResultsTableView indexPathForCell:sender];

        [(EventDetailViewController*)segue.destinationViewController setEvent:[searchResults objectAtIndex:indexPath.row]];
    }
    if ([segue.identifier isEqualToString:@"PushToDetail"]) {

    NSIndexPath *indexPath = [self.eventListTableView indexPathForCell:sender];
        NSLog(@"Index Path %d, row %d", indexPath.section, indexPath.row);
    if (indexPath.section < [self.uniqueSingleDates count]) {
        NSLog(@"Sender %@, Event: %@", sender, [[[NSWEventData sharedData] eventsForDate:[self.uniqueSingleDates objectAtIndex:indexPath.section]] objectAtIndex:indexPath.row]);
        [(EventDetailViewController*)segue.destinationViewController setEvent:[[[NSWEventData sharedData] eventsForDate:[self.uniqueSingleDates objectAtIndex:indexPath.section]] objectAtIndex:indexPath.row]]; 

    }
    else {
        [(EventDetailViewController*)segue.destinationViewController setEvent:[[[NSWEventData sharedData] multiDateEvents] objectAtIndex:indexPath.row]]; 
        
    }
    }
    
}

- (void)newDataWasDownloaded
{
    
    [self reloadView];
    if ([[self.navigationController viewControllers] count]> 1) {
        [(EventDetailViewController*)[[self.navigationController viewControllers] objectAtIndex:1] refreshDetailedEventData];
    }

}

-(void)scrollToTodaysDate
{
    
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
        [self.eventListTableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]atScrollPosition:UITableViewScrollPositionTop animated:YES];
    }
    else
    {
        if (foundExactMatch) {
            [self.eventListTableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:[self.uniqueSingleDates indexOfObject:dateToScrollTo]]atScrollPosition:UITableViewScrollPositionTop animated:YES];
        }
        else
        {
            [self.eventListTableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:[self.uniqueSingleDates indexOfObject:dateToScrollTo]+1]atScrollPosition:UITableViewScrollPositionTop animated:YES];
        }

    }
    
}

- (IBAction)cellDoubleTapped:(UITapGestureRecognizer*)sender 
{
    if (sender.state == UIGestureRecognizerStateEnded) {
        CGPoint swipeLocation = [sender locationInView:self.eventListTableView];
        NSIndexPath *swipedIndexPath = [self.eventListTableView indexPathForRowAtPoint:swipeLocation];
        UITableViewCell* swipedCell = [self.eventListTableView cellForRowAtIndexPath:swipedIndexPath];
        NSLog(@"CELL HAS %@", swipedCell.textLabel.text);
        
    }
    
}

- (IBAction)chooseLocation:(UIBarButtonItem*)sender
{
    
    //[PopoverView showPopoverAtPoint:CGPointMake(sender.width, 0) inView:self.view withTitle:@"Choose Location" withStringArray:[NSArray arrayWithObjects:@"TAS", @"QLD", @"NT", @"SA", @"WA", @"ACT", @"VIC", @"NSW", nil] delegate:self];
    if (eventListTableView.frame.origin.y >0) {
        
        [UIView animateWithDuration:0.5 delay:0 options:UIViewAnimationOptionBeginFromCurrentState animations:^{
            self.eventListTableView.frame = listDefaultFrame;
            self.locationSelectView.frame = locationSelectDefaultFrame;
        } completion:nil];        
        sender.title = [sender.title stringByReplacingOccurrencesOfString:@"▲" withString:@"▼"];
        self.eventListTableView.userInteractionEnabled = YES;


    }
    else
    {
        [UIView animateWithDuration:0.5 delay:0 options:UIViewAnimationOptionBeginFromCurrentState animations:^{
            self.eventListTableView.frame = listDownFrame;
            self.locationSelectView.frame = locationSelectDownFrame;
        } completion:nil];
        
        sender.title = [sender.title stringByReplacingOccurrencesOfString:@"▼" withString:@"▲"];
        self.eventListTableView.userInteractionEnabled = NO;

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
    _currentLocationButton.title = [NSString stringWithFormat:@"%@ | ▼", mappedStateChoice];
    [self chooseLocation:nil];
    [self scrollToTodaysDate];
}

- (void)popoverView:(PopoverView *)popoverView didSelectItemAtIndex:(NSInteger)index
{
    
    NSArray *states = [NSArray arrayWithObjects:@"TAS", @"QLD", @"NT", @"SA", @"WA", @"ACT", @"VIC", @"NSW", nil];
    [[NSWEventData sharedData] changeLocation:[states objectAtIndex:index]];
    [popoverView dismiss];

}

- (void)popoverViewDidDismiss:(PopoverView *)popoverView
{
    
}


-(void)viewWillAppear:(BOOL)animated
{
    
    [self.navigationController.navigationBar configureFlatNavigationBarWithColor:kGlobalNavBarColour];
    
    /*
    segmentedLocationControl.selectedFont = [UIFont boldFlatFontOfSize:12];
    segmentedLocationControl.selectedFontColor = [UIColor cloudsColor];
    segmentedLocationControl.deselectedFont = [UIFont flatFontOfSize:12];
    segmentedLocationControl.deselectedFontColor = [UIColor cloudsColor];
    segmentedLocationControl.selectedColor = [UIColor amethystColor];
    segmentedLocationControl.deselectedColor = [UIColor silverColor];
    segmentedLocationControl.dividerColor = [UIColor midnightBlueColor];
    segmentedLocationControl.cornerRadius = 5.0;
    */

    
    //[_todayButton configureFlatButtonWithColor:[UIColor belizeHoleColor] highlightedColor:[UIColor peterRiverColor] cornerRadius:3];
    //[_currentLocationButton configureFlatButtonWithColor:[UIColor belizeHoleColor] highlightedColor:[UIColor peterRiverColor] cornerRadius:3];
    //[self.navigationItem.backBarButtonItem configureFlatButtonWithColor:[UIColor belizeHoleColor] highlightedColor:[UIColor peterRiverColor] cornerRadius:3];
    
    
    [[NSWEventData sharedData] setDelegate:self];
    
    [self reloadView];
    
}

- (void)viewDidLoad
{
    
    listDefaultFrame = CGRectMake(0, 0, self.eventListTableView.frame.size.width, self.eventListTableView.frame.size.height);
    listDownFrame = CGRectMake(0, self.locationSelectView.frame.size.height, self.eventListTableView.frame.size.width, self.eventListTableView.frame.size.height);
    locationSelectDefaultFrame = CGRectMake(0, -self.locationSelectView.frame.size.height, self.eventListTableView.frame.size.width, self.locationSelectView.frame.size.height);
    locationSelectDownFrame = CGRectMake(0, 0, self.eventListTableView.frame.size.width, self.locationSelectView.frame.size.height);

    _locationSelectView.backgroundColor = [UIColor clearColor];
    _locationSelectHeaderView.backgroundColor = [UIColor clearColor];
    
    
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
    //NSDictionary *barButtonAppearanceDict = @{UITextAttributeFont : kGlobalNavBarItemFont};

    
    //[[UIButton appearanceWhenContainedIn:[EventsListViewController class], nil] setTitleTextAttributes:barButtonAppearanceDict forState:UIControlStateNormal];
    
    //_locationACTButton
    
    
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
    
    
    self.tabBarItem = [[UITabBarItem alloc] initWithTitle:@"Events" image:nil tag:0];
    [[self tabBarItem] setFinishedSelectedImage:[UIImage imageNamed:@"calendaricon.png"] withFinishedUnselectedImage:[UIImage imageNamed:@"calendaricon.png"]];
    [self reloadView];
    [self scrollToTodaysDate];
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (void)viewDidUnload
{
    [self setEventListTableView:nil];
    [self setCurrentLocationLabel:nil];
    [self setSegmentedLocationControl:nil];
    [self setDoubleTap:nil];
    [self setTodayButton:nil];
    [self setCurrentLocationButton:nil];
    [self setLocationSelectView:nil];
    [self setLocationSAButton:nil];
    [self setLocationTASButton:nil];
    [self setLocationVICButton:nil];
    [self setLocationWAButton:nil];
    [self setLocationACTButton:nil];
    [self setLocationNSWButton:nil];
    [self setLocationNTButton:nil];
    [self setLocationQLDButton:nil];
    [self setLocationSelectHeaderView:nil];
    [self setLocationSelectTitleLabel:nil];
    [self setSearchBar:nil];
    [self setTableViewBackgroundImage:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}


- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar
{
    // only show the status bar’s cancel button while in edit mode sbar (UISearchBar)
    searchBar.showsCancelButton = YES;
    searchBar.autocorrectionType = UITextAutocorrectionTypeNo;
    UIColor *desiredColor = [UIColor colorWithRed:212.0/255.0 green:237.0/255.0 blue:187.0/255.0 alpha:1.0];
    
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






- (void)reloadView
{
    
    //TODO: Update the display of which location is selected 
    
    self.currentLocationLabel.text = [[NSWEventData sharedData] location];
    [self.eventListTableView reloadData];
}

- (IBAction)nextLocationPressed:(id)sender 
{
    [[NSWEventData sharedData] nextLocation];
    [self reloadView];
}

- (IBAction)previousLocationPressed:(id)sender {
    [[NSWEventData sharedData] previousLocation];
    [self reloadView];
}

-(IBAction) valueChanged: (id) sender {
    UISegmentedControl *segmentedControl = (UISegmentedControl*) sender;
    switch ([segmentedControl selectedSegmentIndex]) {
        case 0:
            [[NSWEventData sharedData] changeLocation:@"Southern Tasmania"];
            break;
        case 1:
            [[NSWEventData sharedData] changeLocation:@"Northern Tasmania"];
            break;       
        case 2:
            [[NSWEventData sharedData] changeLocation:@"North-western Tasmania"];
            break;
        default:
            NSLog(@"No option for: %d", [segmentedControl selectedSegmentIndex]);
    }
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


@end
