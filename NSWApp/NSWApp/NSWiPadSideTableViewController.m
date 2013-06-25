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
        [[NSWEventData sharedData] setDelegate:self];
        
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
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
    UIViewController *infoPanel = [self.storyboard instantiateViewControllerWithIdentifier:@"infoPanel"];
    infoPanel.modalPresentationStyle = UIModalPresentationFormSheet;
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
    [(EventDetailViewController_iPad*)[[self.splitViewController viewControllers] objectAtIndex:1] refreshDetailedEventData];
    
    
}

@end
