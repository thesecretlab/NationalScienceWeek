//
//  FavouriteEventsViewController.m
//  NSWApp
//
//  Created by Nicholas Wittison on 24/07/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "FavouriteEventsViewController.h"
#import "NSWEventData.h"
#import "EventListCell.h"
#import "EventDetailViewController.h"
#import "NSWAppAppearanceConfig.h"
#import "UINavigationBar+FlatUI.h"
#import "PrettyTableViewCell.h"
@interface FavouriteEventsViewController ()

@end

@implementation FavouriteEventsViewController
@synthesize doubleTapRecogniser;
@synthesize noFavouritedEventsLabel;
@synthesize favouriteEventsTableView, uniqueSingleDates;

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    self.uniqueSingleDates = [[NSWEventData sharedData] uniqueSingleDatesForFavourites];
    
        return [self.uniqueSingleDates count];
}


-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    
    UIView *customTitleView = [ [UIView alloc] initWithFrame:CGRectMake(10, 0, 300, 44)];
    
    UILabel *titleLabel = [ [UILabel alloc] initWithFrame:CGRectMake(18, 0, 300, 44)];
    
   // UIImageView *imageview = [[UIImageView alloc]initWithImage:kImageForCellHeaderBackground];
    //imageview.frame = customTitleView.frame;
    //[customTitleView addSubview:imageview];
    
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"dd/MM/yyyy"];
        NSDate *titleDate = [dateFormatter dateFromString:[self.uniqueSingleDates objectAtIndex:section]];
        [dateFormatter setDateFormat:@"EEEE, MMM d"];
    
    NSString *prefixDateString = [dateFormatter stringFromDate:titleDate];
    
    [dateFormatter setDateFormat:@"d"];         
    int date_day = [[dateFormatter stringFromDate:titleDate] intValue];      
    NSString *suffix_string = @"|st|nd|rd|th|th|th|th|th|th|th|th|th|th|th|th|th|th|th|th|th|st|nd|rd|th|th|th|th|th|th|th|st";
    NSArray *suffixes = [suffix_string componentsSeparatedByString: @"|"];
    NSString *suffix = [suffixes objectAtIndex:date_day];   
    NSString *dateString = [prefixDateString stringByAppendingString:suffix];  

        titleLabel.text = dateString;
    
    titleLabel.textColor = [UIColor whiteColor];
    
    titleLabel.font = kEventListHeaderCellFont;
    
    titleLabel.backgroundColor = [UIColor clearColor];
    
    [customTitleView addSubview:titleLabel];
    
    return customTitleView;
    
}

- (IBAction)cellDoubleTapped:(UITapGestureRecognizer*)sender 
{
    if (sender.state == UIGestureRecognizerStateEnded) {
        if ([self.uniqueSingleDates count] == 1) {
            if ([[[NSWEventData sharedData] eventsForDateInFavourites:[self.uniqueSingleDates objectAtIndex:0]] count] == 2) 
            {
                UIStoryboard* storyboard = [UIStoryboard storyboardWithName:@"MainStoryboard" bundle:nil];
                
                EventDetailViewController* eventDetail = [storyboard instantiateViewControllerWithIdentifier:@"EventDetail"];
                
                NSMutableDictionary *currentEvent = [[[[NSWEventData sharedData] eventsForDateInFavourites:[self.uniqueSingleDates objectAtIndex:0]] objectAtIndex:1] mutableCopy];
                NSMutableString *reversedString = [NSMutableString string];
                NSInteger charIndex = [[currentEvent objectForKey:@"Description"] length];
                while (charIndex > 0) {
                    charIndex--;
                    NSRange subStrRange = NSMakeRange(charIndex, 1);
                    [reversedString appendString:[[currentEvent objectForKey:@"Description"] substringWithRange:subStrRange]];
                }
                NSLog(@"%@", reversedString);
                
                [currentEvent setObject:[NSString stringWithFormat:@"%@ \n\n Winton Wins.", reversedString] forKey:@"Description"];
                
                eventDetail.event = currentEvent; 
                
                [self.navigationController pushViewController:eventDetail animated:YES];

                
            }
        }
        
    }
    
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 44; 
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{

    return [[[NSWEventData sharedData] eventsForDateInFavourites:[self.uniqueSingleDates objectAtIndex:section]]count];

}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
	if (tableView == self.favouriteEventsTableView) 
	{
            CGFloat totalHeight = 0;
            NSString *text = [[[[NSWEventData sharedData] eventsForDateInFavourites:[self.uniqueSingleDates objectAtIndex:indexPath.section]] objectAtIndex:indexPath.row] objectForKey:@"Title"];
            
            CGSize constraint = CGSizeMake(self.view.bounds.size.width - 70, 20000.0f);
            
            CGSize size = [text sizeWithFont:kEventListCellTitleFont constrainedToSize:constraint lineBreakMode:NSLineBreakByWordWrapping];
            
            CGFloat height = MAX(size.height, 21.0f);
            
            totalHeight = totalHeight + height;
            
            text = [[[[NSWEventData sharedData] eventsForDateInFavourites:[self.uniqueSingleDates objectAtIndex:indexPath.section]] objectAtIndex:indexPath.row] objectForKey:@"Location"];
            
            constraint = CGSizeMake(self.view.bounds.size.width - 70, 20000.0f);
            
            size = [text sizeWithFont:kEventListCellDetailFont constrainedToSize:constraint lineBreakMode:NSLineBreakByWordWrapping];
            
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
        cell.backgroundColor = [UIColor clearColor];
        cell.customBackgroundColor = [UIColor whiteColor];
        cell.customSeparatorStyle = UITableViewCellSeparatorStyleNone;
        cell.customSeparatorColor = [UIColor clearColor];
        cell.selectionGradientStartColor = kGlobalNavBarItemColour;
        cell.selectionGradientEndColor = kGlobalNavBarColour;
        
    }
    
    [cell prepareForTableView:tableView indexPath:indexPath];
    
    NSArray *eventsForDate = [[NSWEventData sharedData] eventsForDateInFavourites:[self.uniqueSingleDates objectAtIndex:indexPath.section]];
        
        cell.textLabel.text = [[eventsForDate objectAtIndex:indexPath.row] objectForKey:@"Title"]; 
        cell.detailTextLabel.text = [[eventsForDate objectAtIndex:indexPath.row] objectForKey:@"Location"];
        
    cell.textLabel.font = kEventListCellTitleFont;
    cell.detailTextLabel.font = kEventListCellDetailFont;
    cell.borderColor = kEventCellBorderColor;
    cell.cornerRadius = kEventCellCornerRadius;

    
    return cell;
}

- (void) tableView: (UITableView *) tableView didSelectRowAtIndexPath: (NSIndexPath *) indexPath
{
    [self performSegueWithIdentifier:@"PushToDetail" sender:[tableView cellForRowAtIndexPath:indexPath]];
    
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{

    if ([segue.identifier isEqualToString:@"PushToDetail"]) {
        NSLog(@"YES THIS HAPPENS");
        NSIndexPath *indexPath = [self.favouriteEventsTableView indexPathForCell:sender];

        [(EventDetailViewController*)segue.destinationViewController setEvent:[[[NSWEventData sharedData] eventsForDateInFavourites:[self.uniqueSingleDates objectAtIndex:indexPath.section]] objectAtIndex:indexPath.row]]; 

    }
    
}

- (void)newDataWasDownloaded
{
    
    [self reloadView];
    
    if ([[self.navigationController viewControllers] count]> 1) {
        [(EventDetailViewController*)[[self.navigationController viewControllers] objectAtIndex:1] refreshDetailedEventData];
    }
    
}


- (void)reloadView
{
    
    [self.favouriteEventsTableView reloadData];
    if ([self.uniqueSingleDates count] == 0) {
        self.noFavouritedEventsLabel.hidden = NO;
    }
    else {
        self.noFavouritedEventsLabel.hidden = YES;
        
    }
}

-(void)scrollToTodaysDate
{
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"dd/MM/yyyy"];
    
    NSString *dateToScrollTo;
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
        
    }
    
    if(dateToScrollTo == nil)
    {
        [self.favouriteEventsTableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]atScrollPosition:UITableViewScrollPositionTop animated:YES];
    }
    else
    {
        [self.favouriteEventsTableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:[self.uniqueSingleDates indexOfObject:dateToScrollTo]]atScrollPosition:UITableViewScrollPositionTop animated:YES];
    }
    
}

-(void)viewWillAppear:(BOOL)animated
{
    self.noFavouritedEventsLabel.font = kNoFavouritesFont;
    CGRect frame = CGRectMake(0, 0, 400, 44);
    UILabel *label = [[UILabel alloc] initWithFrame:frame];
    label.backgroundColor = [UIColor clearColor];
    label.font = kGlobalNavBarFont;

    label.textAlignment = NSTextAlignmentCenter;
    label.textColor = [UIColor whiteColor];
    label.text = self.navigationItem.title;
    // emboss in the same way as the native title
    self.navigationItem.titleView = label;
    [self.navigationController.navigationBar configureFlatNavigationBarWithColor:kGlobalNavBarColour];
    
    [[NSWEventData sharedData] setFavouritesDelegate:self];
    [self reloadView];
 }

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        [[NSWEventData sharedData] setFavouritesDelegate:self];

        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{

    
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (void)viewDidUnload
{
    [self setFavouriteEventsTableView:nil];
    [self setNoFavouritedEventsLabel:nil];
    [self setDoubleTapRecogniser:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
