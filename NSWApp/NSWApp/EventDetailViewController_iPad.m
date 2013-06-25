//
//  EventDetailViewController_iPad.m
//  NSWApp
//
//  Created by Nicholas Wittison on 14/06/13.
//
//

#import "EventDetailViewController_iPad.h"
#import "NSWAppAppearanceConfig.h"
#import <QuartzCore/QuartzCore.h>
#import "UINavigationBar+FlatUI.h"
#import "NSWEventData.h"
#import "UIBarButtonItem+FlatUI.h"
@interface EventDetailViewController_iPad ()

@end

@implementation EventDetailViewController_iPad

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
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)updateAndRelayoutView
{
    self.eventTitleLabel.text = [_event objectForKey:@"Title"];
    
    if (![[_event objectForKey:@"Start Time"] isEqualToString:@""] && ![[_event objectForKey:@"End Time"] isEqualToString:@""])
    {
        self.eventTimeLabel.text = [NSString stringWithFormat:@"%@\n ~ \n%@", [_event objectForKey:@"Start Time"], [_event objectForKey:@"End Time"]];
    }
    else if (![[_event objectForKey:@"Start Time"] isEqualToString:@""])
    {
        self.eventTimeLabel.text = [NSString stringWithFormat:@"%@", [_event objectForKey:@"Start Time"]];
    }
    else if (![[_event objectForKey:@"End Time"] isEqualToString:@""])
    {
        self.eventTimeLabel.text = [NSString stringWithFormat:@"%@", [_event objectForKey:@"End Time"]];
    }
    else {
        self.eventTimeView.hidden = YES;
        self.eventTimeLabel.hidden = YES;
    }
    
    
    
    
    
    
    if (![[_event objectForKey:@"Location"] isEqualToString:@""] && ![[_event objectForKey:@"Address"] isEqualToString:@""])
    {
        self.eventAddressLabel.text = [NSString stringWithFormat:@"%@\n%@", [_event objectForKey:@"Location"], [_event objectForKey:@"Address"]];
    }
    else if (![[_event objectForKey:@"Location"] isEqualToString:@""])
    {
        self.eventAddressLabel.text = [NSString stringWithFormat:@"%@", [_event objectForKey:@"Location"]];
    }
    else if (![[_event objectForKey:@"Address"] isEqualToString:@""])
    {
        self.eventAddressLabel.text = [NSString stringWithFormat:@"%@", [_event objectForKey:@"Address"]];
    }
    
    
    if (![[_event objectForKey:@"Contact"] isEqualToString:@""])
    {
        self.eventContactTextView.text = [NSString stringWithFormat:@"%@", [_event objectForKey:@"Contact"]];
    }
    
    self.eventContactTextView.contentInset = UIEdgeInsetsMake(-8,-8,0,0);
    
    self.eventDescriptionLabel.text = [_event objectForKey:@"Description"];
    
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"dd/MM/yyyy"];
    NSDate *titleDate = [dateFormatter dateFromString:[_event objectForKey:@"Date"]];
    
    
    [dateFormatter setDateFormat:@"EEEE,\n MMM d"];
    NSString *prefixDateString = [dateFormatter stringFromDate:titleDate];
    
    [dateFormatter setDateFormat:@"d"];
    int date_day = [[dateFormatter stringFromDate:titleDate] intValue];
    NSString *suffix_string = @"|st|nd|rd|th|th|th|th|th|th|th|th|th|th|th|th|th|th|th|th|th|st|nd|rd|th|th|th|th|th|th|th|st";
    NSArray *suffixes = [suffix_string componentsSeparatedByString: @"|"];
    NSString *suffix = [suffixes objectAtIndex:date_day];
    NSString *dateString = [prefixDateString stringByAppendingString:suffix];
    self.eventDateLabel.text = dateString;
    
    if (![[_event objectForKey:@"End Date"] isEqualToString:@""]) {
        [dateFormatter setDateFormat:@"dd/MM/yyyy"];
        NSDate *endDate = [dateFormatter dateFromString:[_event objectForKey:@"End Date"]];
        
        [dateFormatter setDateFormat:@"d"];
        int date_day = [[dateFormatter stringFromDate:endDate] intValue];
        NSString *suffix = [suffixes objectAtIndex:date_day];
        NSString *dateString = [[dateFormatter stringFromDate:endDate] stringByAppendingString:suffix];
        
        
        self.eventDateLabel.text = [NSString stringWithFormat:@"%@ \n ~ \n %@", self.eventDateLabel.text, dateString];
    }
    
    
    currentLayoutHeight = 10.0;
    
    if (![[_event objectForKey:@"Location"] isEqualToString:@"Online"])
    {
        
        [self positionLabelOnScreen:self.eventTitleLabel withFont:kDetailEventTitleFont sizeForMinumumLabel:21.0 bufferToNextLabel:10];
        
        self.topRowView.frame = CGRectMake(self.topRowView.frame.origin.x, currentLayoutHeight, self.topRowView.frame.size.width, self.topRowView.frame.size.height);
        currentLayoutHeight = currentLayoutHeight + self.topRowView.frame.size.height + 10;
        
        [self positionLabelViewOnScreen:self.eventDetailView withLabel:self.eventDescriptionLabel bufferToNextView:10];
        
        [self positionLabelViewOnScreen:self.eventAddressView withLabel:self.eventAddressLabel bufferToNextView:10];
        
        [self positionLabelViewOnScreen:self.eventContactView withLabel:(UILabel*)self.eventContactTextView bufferToNextView:10];
        
    }
    else {
        [self positionLabelOnScreen:self.eventTitleLabel withFont:kDetailEventTitleFont sizeForMinumumLabel:21.0 bufferToNextLabel:10];
        
        self.topRowView.hidden = YES;
        self.eventContactView.hidden = YES;
        self.eventAddressView.hidden = YES;
        [self positionLabelViewOnScreen:self.eventDetailView withLabel:self.eventDescriptionLabel bufferToNextView:10];
        
        self.onlineOnlyOpenInSafariView.hidden = NO;
        self.onlineOnlyOpenInSafariView.frame = CGRectMake(self.onlineOnlyOpenInSafariView.frame.origin.x, currentLayoutHeight, self.onlineOnlyOpenInSafariView.frame.size.width, self.onlineOnlyOpenInSafariView.frame.size.height);
        
        currentLayoutHeight = currentLayoutHeight + self.onlineOnlyOpenInSafariView.frame.size.height + 10;
        
        
    }
    
    
    
    
    self.eventDateView.layer.cornerRadius = kDetailCornerRadius;
    self.eventTimeView.layer.cornerRadius = kDetailCornerRadius;
    self.eventMapHolderView.layer.cornerRadius = kDetailCornerRadius;
    
    self.eventDetailView.layer.cornerRadius = kDetailCornerRadius;
    self.eventContactView.layer.cornerRadius = kDetailCornerRadius;
    self.eventAddressView.layer.cornerRadius = kDetailCornerRadius;
    self.onlineOnlyOpenInSafariView.layer.cornerRadius = kDetailCornerRadius;
    
    if (![[_event objectForKey:@"Longitude"] isEqualToString:@""]&& ![[_event objectForKey:@"Latitude"] isEqualToString:@""]) {
        
        
        self.eventMapView.layer.cornerRadius = kDetailCornerRadius;
        
        //[self plotEvent];
        //[self zoomToAnnotationsBounds];
    }
    else {
        self.eventMapHolderView.hidden = YES;
        self.eventMapView.hidden = YES;
        self.openInMapsButton.hidden = YES;
    }
    
    self.labelScrollView.contentSize = CGSizeMake(320, currentLayoutHeight);
    
    [self checkFavouriteButton];
    
}

- (void)checkFavouriteButton
{
    if ([[NSWEventData sharedData] favouritesArrayContainsEventWithID:[_event objectForKey:@"Event ID"]])
    {
        [self.favouriteButton configureFlatButtonWithColor:kDetailFavouriteSelected
                                          highlightedColor:kDetailFavouriteSelected
                                              cornerRadius:kNavBarButtonCornerRadius];
    }
    else
    {
        [self.favouriteButton configureFlatButtonWithColor:kGlobalNavBarItemColour
                                          highlightedColor:kGlobalNavBarItemColourHighlighted
                                              cornerRadius:kNavBarButtonCornerRadius];    }
}

- (IBAction)favouriteEvent:(id)sender
{
    if ([[NSWEventData sharedData] favouritesArrayContainsEventWithID:[_event objectForKey:@"Event ID"]])
    {
        [[NSWEventData sharedData] removeEventFromFavouritesArrayWithID:[_event objectForKey:@"Event ID"]];
    }
    else
    {
        [[NSWEventData sharedData] addEventToFavouritesArray:_event];
    }
    
    [self checkFavouriteButton];
}

- (void)positionLabelOnScreen:(UILabel *)currentLabel withFont:(UIFont *)fontForLabel sizeForMinumumLabel:(float)sizeForMinumumLabel bufferToNextLabel:(float)bufferToNextLabel
{
    if (![currentLabel.text isEqualToString:@""])
    {
        CGSize constraint = CGSizeMake(currentLabel.frame.size.width, 20000.0f);
        
        CGSize size = [currentLabel.text sizeWithFont:fontForLabel constrainedToSize:constraint lineBreakMode:UILineBreakModeWordWrap];
        
        CGFloat height = MAX(size.height, sizeForMinumumLabel);
        
        currentLabel.frame = CGRectMake(currentLabel.frame.origin.x, currentLabel.frame.origin.y, currentLabel.frame.size.width, height);
        
        
        currentLayoutHeight = currentLabel.frame.size.height + currentLayoutHeight + bufferToNextLabel;
    }
    else
    {
        currentLabel.hidden = YES;
    }
}


-(void)positionLabelViewOnScreen:(UIView*)currentView withLabel:(UILabel*)currentLabel bufferToNextView:(float)bufferToNextView
{
    if (![currentLabel.text isEqualToString:@""]) {
        
        
        CGSize constraint = CGSizeMake(currentView.frame.size.width-24, 20000.0f);
        
        CGSize size = [currentLabel.text sizeWithFont:currentLabel.font constrainedToSize:constraint lineBreakMode:UILineBreakModeWordWrap];
        
        CGFloat height = MAX(size.height, 20);
        
        currentLabel.frame = CGRectMake(10, 10, currentView.frame.size.width-20, height);
        
        height = height + 20;
        
        currentView.frame = CGRectMake(currentView.frame.origin.x, currentLayoutHeight, currentView.frame.size.width, height);
        
        
        currentLayoutHeight = height + currentLayoutHeight + bufferToNextView;
        
        
        
    }
    else {
        currentView.hidden = YES;
        currentLabel.hidden = YES;
    }
    
    
}

-(void)viewWillAppear:(BOOL)animated
{
    
    self.eventTitleLabel.font = kDetailEventTitleFont;
    self.eventTimeLabel.font = kDetailEventFont;
    self.eventAddressLabel.font = kDetailEventFont;
    self.eventDescriptionLabel.font = kDetailEventFont;
    self.eventDateLabel.font = kDetailEventFont;
    self.openInSafariLabel.font = kDetailOpenInSafariFont;
    self.eventContactTextView.font = kDetailEventFont;
    [self.navigationController.navigationBar configureFlatNavigationBarWithColor:kGlobalNavBarColour];
    
    
    NSLog(@"Event %@", self.event);
    [self updateAndRelayoutView];
    
}

-(void)refreshDetailedEventData
{
    
    NSDictionary *updatedEvent = [[NSWEventData sharedData] eventForKey:[self.event objectForKey:@"Event ID"]];
    if (updatedEvent)
    {
        self.event = updatedEvent;
        [self updateAndRelayoutView];
    }
    else
    {
        //TODO: Put in a way to clear the detail view
    }


}

- (IBAction)openInMaps:(id)sender
{
    if (![[_event objectForKey:@"Latitude"] isEqualToString:@""]&& ![[_event objectForKey:@"Longitude"] isEqualToString:@""]) {
        NSString *url = [NSString stringWithFormat: @"http://maps.google.com/maps?q=%f,%f&t=m", [[_event objectForKey:@"Latitude"] floatValue], [[_event objectForKey:@"Longitude"] floatValue]];
        // [[UIApplication sharedApplication] openURL:[NSURL URLWithString:url]];
        UIApplication *app = [UIApplication sharedApplication];
        // NSURL* urlURL = [[NSURL alloc] initWithString:[url stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
        
        [app openURL:[NSURL URLWithString:url]];
    }
    
}

- (IBAction)createEvent:(id)sender
{
    
    EKEventStore *eventStore = [[EKEventStore alloc] init];
    
    EKEvent *newEvent  = [EKEvent eventWithEventStore:eventStore];
    newEvent.title     = [_event objectForKey:@"Title"];
    newEvent.location  = [NSString stringWithFormat:@"%@ %@",[_event objectForKey:@"Location"], [_event objectForKey:@"Address"]];
    
    if (![[_event objectForKey:@"Website"] isEqualToString:@""]) {
        newEvent.URL = [NSURL URLWithString:[_event objectForKey:@"Website"]];
    }
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"dd/MM/yyyy hh:mm a"];
    NSDate *startDate = [dateFormatter dateFromString:[NSString stringWithFormat:@"%@ %@",[_event objectForKey:@"Date"], [_event objectForKey:@"Start Time"]]];
    
    newEvent.startDate = startDate;
    
    if (![[_event objectForKey:@"End Time"] isEqualToString:@""]) {
        NSDate *endDate = [dateFormatter dateFromString:[NSString stringWithFormat:@"%@ %@",[_event objectForKey:@"Date"], [_event objectForKey:@"End Time"]]];
        newEvent.endDate   = endDate;
        
    }
    else
    {
        newEvent.allDay = YES;
    }
    
    
    newEvent.notes = [_event objectForKey:@"Description"];
    
    
    
    [newEvent setCalendar:[eventStore defaultCalendarForNewEvents]];
    
    EKEventEditViewController* controller = [[EKEventEditViewController alloc] init];
    controller.eventStore = eventStore;
    controller.editViewDelegate = self;
    controller.event = newEvent;
    [controller.navigationBar configureFlatNavigationBarWithColor:kGlobalNavBarColour];
    [self presentModalViewController: controller animated:YES];
    
}
- (void)eventEditViewController:(EKEventEditViewController *)controller didCompleteWithAction:(EKEventEditViewAction)action {
    [self dismissModalViewControllerAnimated:YES];
}
- (IBAction)openInSafari:(id)sender
{
    NSURL *websiteToOpen = [NSURL URLWithString:[NSString stringWithFormat:@"http://%@",[_event objectForKey:@"Website"]]];
    NSLog(@" WEBSITE? %@", websiteToOpen);
    [[UIApplication sharedApplication] openURL:websiteToOpen];
    
}

@end
