//
//  EventDetailViewController.m
//  NSWApp
//
//  Created by Nicholas Wittison on 18/07/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "EventDetailViewController.h"
#import "NSWEventData.h"
#import "MyLocation.h"
#import <QuartzCore/QuartzCore.h>
#import <EventKit/EventKit.h>
#import <EventKitUI/EventKitUI.h>
#import "UINavigationBar+FlatUI.h"
#import "NSWAppAppearanceConfig.h"
#import "UIBarButtonItem+FlatUI.h"
#import "MKMapView+ZoomLevel.h"
@interface EventDetailViewController ()

@end

@implementation EventDetailViewController
@synthesize eventTitleLabel;
@synthesize eventTimeLabel;
@synthesize eventLocationLabel;
@synthesize eventContactTextView;
@synthesize eventContactLabel;
@synthesize eventDescriptionLabel;
@synthesize eventDateLabel;
@synthesize event;
@synthesize eventWebsiteLabel;
@synthesize eventMapView;
@synthesize openInMapsButton;
@synthesize labelScrollView;
@synthesize eventDateView;
@synthesize eventTimeView;
@synthesize eventMapHolderView;
@synthesize onlineOnlyOpenInSafariView;
@synthesize eventDetailView;
@synthesize eventAddressView;
@synthesize topRowView;
@synthesize favouriteButton;
@synthesize eventContactView;
@synthesize eventAddressLabel;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (IBAction)openInMaps:(id)sender 
{
    if (![[event objectForKey:@"Latitude"] isEqualToString:@""]&& ![[event objectForKey:@"Longitude"] isEqualToString:@""]) {
        NSString *url = [NSString stringWithFormat: @"http://maps.apple.com/maps?q=%f,%f&t=m", [[event objectForKey:@"Latitude"] floatValue], [[event objectForKey:@"Longitude"] floatValue]]; 
       // [[UIApplication sharedApplication] openURL:[NSURL URLWithString:url]];
        UIApplication *app = [UIApplication sharedApplication];  
       // NSURL* urlURL = [[NSURL alloc] initWithString:[url stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
        
        [app openURL:[NSURL URLWithString:url]]; 
    }
    else{
        
        if (sender == self.eventAddressSearchButton) {
            
            NSString *url = [NSString stringWithFormat: @"http://maps.apple.com/maps?q=%@,%@&t=m",[[event objectForKey:@"Location"] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding], [[event objectForKey:@"Address"] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
            NSLog(@"String %@", url);
            UIApplication *app = [UIApplication sharedApplication];
            
            [app openURL:[NSURL URLWithString:url]];
            
            
        }
        
        
    }

    
}

- (IBAction)createEvent:(id)sender 
{
    
    EKEventStore *eventStore = [[EKEventStore alloc] init];

    __block BOOL accessGranted = NO;
    
    if([eventStore respondsToSelector:@selector(requestAccessToEntityType:completion:)]) {
        dispatch_semaphore_t sema = dispatch_semaphore_create(0);
        [eventStore requestAccessToEntityType:EKEntityTypeEvent completion:^(BOOL granted, NSError *error) {
            accessGranted = granted;
            dispatch_semaphore_signal(sema);
        }];
        dispatch_semaphore_wait(sema, DISPATCH_TIME_FOREVER);
    } else { // we're on iOS 5 or older
        accessGranted = YES;
    }
    
    if (accessGranted == NO) {
        UIAlertView* alertView = [[UIAlertView alloc] init];
        alertView.title = @"This app does not have access to your calendars.";
        alertView.message = @"You can enable access in Privacy Settings.";
        [alertView addButtonWithTitle:@"Close"];
        [alertView show];
        return;
    }
    
    EKEvent *newEvent  = [EKEvent eventWithEventStore:eventStore];
    newEvent.title     = [event objectForKey:@"Title"];
    newEvent.location  = [NSString stringWithFormat:@"%@ %@",[event objectForKey:@"Location"], [event objectForKey:@"Address"]];
    
    if (![[event objectForKey:@"Website"] isEqualToString:@""]) {
        newEvent.URL = [NSURL URLWithString:[event objectForKey:@"Website"]];
    }
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"dd/MM/yyyy hh:mm a"];
    NSDate *startDate = [dateFormatter dateFromString:[NSString stringWithFormat:@"%@ %@",[event objectForKey:@"Date"], [event objectForKey:@"Start Time"]]];
    
    newEvent.startDate = startDate;

    if (![[event objectForKey:@"End Time"] isEqualToString:@""]) {
        NSDate *endDate = [dateFormatter dateFromString:[NSString stringWithFormat:@"%@ %@",[event objectForKey:@"Date"], [event objectForKey:@"End Time"]]];
        newEvent.endDate   = endDate;
        
    }
    else 
    {
        newEvent.allDay = YES;
    }
    
    
    newEvent.notes = [event objectForKey:@"Description"];
    
    
    
    [newEvent setCalendar:[eventStore defaultCalendarForNewEvents]];
    
    EKEventEditViewController* controller = [[EKEventEditViewController alloc] init];
    controller.eventStore = eventStore;
    controller.editViewDelegate = self;
    controller.event = newEvent;
    
    
    
    NSDictionary *barAppearanceDict = @{NSFontAttributeName : kGlobalNavBarFont, NSForegroundColorAttributeName : [UIColor whiteColor]};
    
    [controller.navigationBar setTitleTextAttributes:barAppearanceDict];
    [controller.navigationBar configureFlatNavigationBarWithColor:kGlobalNavBarColour];
    [self presentViewController:controller animated:YES completion:nil];
    
}

- (IBAction)openInSafari:(id)sender 
{
    NSURL *websiteToOpen = [NSURL URLWithString:[NSString stringWithFormat:@"%@",[event objectForKey:@"Website"]]];
    NSLog(@" WEBSITE? %@", websiteToOpen);
    [[UIApplication sharedApplication] openURL:websiteToOpen];
    
}

- (IBAction)favouriteEvent:(id)sender 
{
    if ([[NSWEventData sharedData] favouritesArrayContainsEventWithID:[event objectForKey:@"Event ID"]]) 
    {
        [[NSWEventData sharedData] removeEventFromFavouritesArrayWithID:[event objectForKey:@"Event ID"]];
    }
    else 
    {
        [[NSWEventData sharedData] addEventToFavouritesArray:event];
    }
    
    [self checkFavouriteButton];
}

- (void)eventEditViewController:(EKEventEditViewController *)controller didCompleteWithAction:(EKEventEditViewAction)action {
    [self dismissModalViewControllerAnimated:YES];
}

-(void)refreshDetailedEventData
{
    
    NSDictionary *updatedEvent = [[NSWEventData sharedData] eventForKey:[self.event objectForKey:@"Event ID"]];
    if (updatedEvent)
    {
        self.event = updatedEvent;
        [self updateAndRelayoutView];
    }
    else {
        [self.navigationController popViewControllerAnimated:YES];
    }
}



- (void)checkFavouriteButton
{
    if ([[NSWEventData sharedData] favouritesArrayContainsEventWithID:[event objectForKey:@"Event ID"]]) 
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

- (void)updateAndRelayoutView
{
    
    if (event == nil) {
        self.topRowView.hidden = YES;
        self.eventContactView.hidden = YES;
        self.eventAddressView.hidden = YES;
        self.eventDetailView.hidden = YES;
        self.eventTitleLabel.hidden = YES;
        self.eventMapHolderView.hidden = YES;
        self.eventMapView.hidden = YES;
        self.openInMapsButton.hidden = YES;
        self.eventWebsiteView.hidden =  YES;

        self.favouriteButton.enabled = NO;
        return;
    }
    else{
        self.topRowView.hidden = NO;
        self.eventContactView.hidden = NO;
        self.eventAddressView.hidden = NO;
        self.eventDetailView.hidden = NO;
        self.eventTitleLabel.hidden = NO;
        self.eventMapHolderView.hidden = NO;
        self.eventMapView.hidden = NO;
        self.openInMapsButton.hidden = NO;
        self.favouriteButton.enabled = YES;
        self.eventWebsiteView.hidden =  NO;
        
    }
    
    
    self.eventTitleLabel.text = [event objectForKey:@"Title"];
    
    if (![[event objectForKey:@"Start Time"] isEqualToString:@""] && ![[event objectForKey:@"End Time"] isEqualToString:@""]) 
    {
        self.eventTimeLabel.text = [NSString stringWithFormat:@"%@\n ~ \n%@", [event objectForKey:@"Start Time"], [event objectForKey:@"End Time"]];
    }
    else if (![[event objectForKey:@"Start Time"] isEqualToString:@""])
    {
        self.eventTimeLabel.text = [NSString stringWithFormat:@"%@", [event objectForKey:@"Start Time"]];
    }
    else if (![[event objectForKey:@"End Time"] isEqualToString:@""])
    {
        self.eventTimeLabel.text = [NSString stringWithFormat:@"%@", [event objectForKey:@"End Time"]];
    }
    else {
        self.eventTimeView.hidden = YES;
        self.eventTimeLabel.hidden = YES;
    }
    
    
    

    
    
    if (![[event objectForKey:@"Location"] isEqualToString:@""] && ![[event objectForKey:@"Address"] isEqualToString:@""]) 
    {
        self.eventAddressLabel.text = [NSString stringWithFormat:@"%@\n%@", [event objectForKey:@"Location"], [event objectForKey:@"Address"]];
    }
    else if (![[event objectForKey:@"Location"] isEqualToString:@""])
    {
        self.eventAddressLabel.text = [NSString stringWithFormat:@"%@", [event objectForKey:@"Location"]];
    }
    else if (![[event objectForKey:@"Address"] isEqualToString:@""])
    {
        self.eventAddressLabel.text = [NSString stringWithFormat:@"%@", [event objectForKey:@"Address"]];
    }
    else
    {
        self.eventAddressLabel.text = @"";
    }
    

    
    if (![[event objectForKey:@"Contact"] isEqualToString:@""])
    {
        self.eventContactTextView.text = [NSString stringWithFormat:@"%@", [event objectForKey:@"Contact"]];
    }
    else
    {
        self.eventContactTextView.text = @"";
    }
    
    if (![[event objectForKey:@"Website"] isEqualToString:@""])
    {
        self.eventWebsiteLabel.text = [NSString stringWithFormat:@"%@", [event objectForKey:@"Website"]];
    }
    else
    {
        self.eventWebsiteLabel.text = @"";

    }
    
    self.eventContactTextView.contentInset = UIEdgeInsetsMake(-8,-8,0,0);
    
    // On iOS6, text needs to be inset
    if (IsIOS7OrGreater()) {
        self.eventDescriptionLabel.textContainerInset = UIEdgeInsetsMake(8, 4, 0, 0);
        self.eventContactTextView.textContainerInset = UIEdgeInsetsMake(8, 4, 0, 0);
    }
    
    self.eventDescriptionLabel.text = [event objectForKey:@"Description"];;
    
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"dd/MM/yyyy"];
    NSDate *titleDate = [dateFormatter dateFromString:[event objectForKey:@"Date"]];
    
    
    [dateFormatter setDateFormat:@"EEEE,\n MMM d"];
    NSString *prefixDateString = [dateFormatter stringFromDate:titleDate];
    
    [dateFormatter setDateFormat:@"d"];         
    int date_day = [[dateFormatter stringFromDate:titleDate] intValue];      
    NSString *suffix_string = @"|st|nd|rd|th|th|th|th|th|th|th|th|th|th|th|th|th|th|th|th|th|st|nd|rd|th|th|th|th|th|th|th|st";
    NSArray *suffixes = [suffix_string componentsSeparatedByString: @"|"];
    NSString *suffix = [suffixes objectAtIndex:date_day];   
    NSString *dateString = [prefixDateString stringByAppendingString:suffix];  
    self.eventDateLabel.text = dateString;

    if (![[event objectForKey:@"End Date"] isEqualToString:@""]) {
        [dateFormatter setDateFormat:@"dd/MM/yyyy"];
        NSDate *endDate = [dateFormatter dateFromString:[event objectForKey:@"End Date"]];
        
        [dateFormatter setDateFormat:@"d"];         
        int date_day = [[dateFormatter stringFromDate:endDate] intValue];      
        NSString *suffix = [suffixes objectAtIndex:date_day];   
        NSString *dateString = [[dateFormatter stringFromDate:endDate] stringByAppendingString:suffix];         
            
        
        self.eventDateLabel.text = [NSString stringWithFormat:@"%@ \n ~ \n %@", self.eventDateLabel.text, dateString];
    }    
    
    
    currentLayoutHeight = 10.0;
    
    if (![[event objectForKey:@"Location"] isEqualToString:@"Online"])
    {
        
        [self positionLabelOnScreen:self.eventTitleLabel withFont:kDetailEventTitleFont sizeForMinumumLabel:21.0 bufferToNextLabel:10];
        
        self.topRowView.frame = CGRectMake(self.topRowView.frame.origin.x, currentLayoutHeight, self.topRowView.frame.size.width, self.topRowView.frame.size.height);
        
        currentLayoutHeight = currentLayoutHeight + self.topRowView.frame.size.height + 10;
        
        [self positionLabelViewOnScreen:self.eventDetailView withLabel:(UILabel*)self.eventDescriptionLabel bufferToNextView:10];
        
        [self positionLabelViewOnScreen:self.eventAddressView withLabel:self.eventAddressLabel bufferToNextView:10];
        
        [self positionLabelViewOnScreen:self.eventContactView withLabel:(UILabel*)self.eventContactTextView bufferToNextView:10];
        
        [self positionLabelViewOnScreen:self.eventWebsiteView withLabel:(UILabel*)self.eventWebsiteLabel bufferToNextView:10];

        
    }
    else {
        [self positionLabelOnScreen:self.eventTitleLabel withFont:kDetailEventTitleFont sizeForMinumumLabel:21.0 bufferToNextLabel:10];
        
        self.topRowView.hidden = YES;
        self.eventContactView.hidden = YES;
        self.eventAddressView.hidden = YES;
        [self positionLabelViewOnScreen:self.eventDetailView withLabel:(UILabel*)self.eventDescriptionLabel bufferToNextView:10];
        
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
    self.eventWebsiteView.layer.cornerRadius = kDetailCornerRadius;
    self.onlineOnlyOpenInSafariView.layer.cornerRadius = kDetailCornerRadius;
    
    if (![[event objectForKey:@"Longitude"] isEqualToString:@""]&& ![[event objectForKey:@"Latitude"] isEqualToString:@""]) {
       
        self.openInMapsButton.backgroundColor = [UIColor clearColor];
        [self.openInMapsButton setTitle:@"" forState:UIControlStateNormal];

        
        self.eventMapView.layer.cornerRadius = kDetailCornerRadius;
        
        [self plotEvent];
        [self zoomToAnnotationsBounds];
    }
    else {
        
        self.openInMapsButton.backgroundColor = [UIColor colorWithRed:0.8 green:0.8 blue:0.8 alpha:0.8];
        [self.openInMapsButton setTitle:@"No Map" forState:UIControlStateNormal];
        [self.openInMapsButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        self.openInMapsButton.titleLabel.font = [UIFont flatFontOfSize:16.0];
        self.openInMapsButton.titleLabel.numberOfLines = 2;
        MKCoordinateRegion worldRegion = MKCoordinateRegionMake(CLLocationCoordinate2DMake(-28.471555, 133.491902), MKCoordinateSpanMake(50, 50)); //Center on australia
        self.eventMapView.region = worldRegion;
        
        for (id<MKAnnotation> annotation in self.eventMapView.annotations) {
            [self.eventMapView removeAnnotation:annotation];
        }

    }
    
    self.labelScrollView.contentSize = CGSizeMake(self.view.bounds.size.width, currentLayoutHeight);
    
    [self checkFavouriteButton];
    
}
    
    
-(void)positionMapOnScreen
{
    
    if (![[event objectForKey:@"Longitude"] isEqualToString:@""] && ![[event objectForKey:@"Latitude"] isEqualToString:@""]) {

    self.openInMapsButton.frame = CGRectMake(self.openInMapsButton.frame.origin.x, currentLayoutHeight, self.openInMapsButton.frame.size.width, self.openInMapsButton.frame.size.height);
        
        currentLayoutHeight = self.openInMapsButton.frame.size.height +currentLayoutHeight + 8;   
        
        
        
    self.eventMapView.frame = CGRectMake(self.eventMapView.frame.origin.x, currentLayoutHeight, self.eventMapView.frame.size.width, self.eventMapView.frame.size.height);
    
    currentLayoutHeight = self.eventMapView.frame.size.height +currentLayoutHeight + 10;
        
        self.eventMapView.layer.cornerRadius = kDetailCornerRadius;
        
        [self plotEvent];
        [self zoomToAnnotationsBounds];
        
    }
    else {
        self.eventMapView.hidden = YES;
        self.openInMapsButton.hidden = YES;
    }
}

- (void)positionLabelOnScreen:(UILabel *)currentLabel withFont:(UIFont *)fontForLabel sizeForMinumumLabel:(float)sizeForMinumumLabel bufferToNextLabel:(float)bufferToNextLabel  
{
    if (![currentLabel.text isEqualToString:@""]) 
    {
        CGSize constraint = CGSizeMake(self.view.bounds.size.width - (15 * 2), 20000.0f);
    
        CGSize size = [currentLabel.text sizeWithFont:fontForLabel constrainedToSize:constraint lineBreakMode:NSLineBreakByWordWrapping];
    
        CGFloat height = MAX(size.height, sizeForMinumumLabel);
    
        currentLabel.frame = CGRectMake(15, currentLayoutHeight, 290, height);   
        
        
        currentLayoutHeight = height + currentLayoutHeight + bufferToNextLabel;
    }
    else 
    {
        currentLabel.hidden = YES;
    }
}


-(void)positionLabelViewOnScreen:(UIView*)currentView withLabel:(UILabel*)currentLabel bufferToNextView:(float)bufferToNextView
{
    if (![currentLabel.text isEqualToString:@""]) {
            
        
        CGSize constraint = CGSizeMake(currentView.frame.size.width-40, 20000.0f);
        
        CGSize size = [currentLabel.text sizeWithFont:currentLabel.font constrainedToSize:constraint lineBreakMode:NSLineBreakByWordWrapping];
        size.height += 20;
        
        CGFloat height = MAX(size.height, 20);

        if (currentLabel == self.eventAddressLabel)
        {
            currentLabel.frame = CGRectMake(12, 10, currentView.frame.size.width-34, height);
        }
        else
        {
            currentLabel.frame = CGRectMake(12, 10, currentView.frame.size.width-24, height);
        }
        
        height = height + 20;
        
        
        currentView.frame = CGRectMake(currentView.frame.origin.x, currentLayoutHeight, currentView.frame.size.width, height);
        
        
        currentLayoutHeight = height + currentLayoutHeight + bufferToNextView;
        
        
        
    }
    else {
        currentView.hidden = YES;
        //currentLabel.hidden = YES;
    }
    

}




- (void)plotEvent{
    
    
    for (id<MKAnnotation> annotation in self.eventMapView.annotations) {
        [self.eventMapView removeAnnotation:annotation];
    }
    
    
    NSNumber * latitude = [NSNumber numberWithDouble:[[event objectForKey:@"Latitude"] doubleValue]];
    NSNumber * longitude = [NSNumber numberWithDouble:[[event objectForKey:@"Longitude"] doubleValue]]; 
    
    NSString * purchaseDescription = [NSString stringWithFormat:@"%@",[event objectForKey:@"Title"]];
    NSString * purchaseLocation = [event objectForKey:@"Location"]; 
    
    CLLocationCoordinate2D coordinate;
    coordinate.latitude = latitude.doubleValue;
    coordinate.longitude = longitude.doubleValue;            
    MyLocation *annotation = [[MyLocation alloc] initWithName:purchaseDescription address:purchaseLocation coordinate:coordinate] ;
    annotation.event = event;
    [self.eventMapView addAnnotation:annotation];    
    
}

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id <MKAnnotation>)annotation {
    
    static NSString *identifier = @"MyLocation";   
    if ([annotation isKindOfClass:[MyLocation class]]) {
        
        MKPinAnnotationView *annotationView = (MKPinAnnotationView *) [self.eventMapView dequeueReusableAnnotationViewWithIdentifier:identifier];
        if (annotationView == nil) {
            annotationView = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:identifier];
        } else {
            annotationView.annotation = annotation;
        }
        
        annotationView.enabled = NO;
        annotationView.canShowCallout = NO;
        annotationView.animatesDrop = YES;
        
        return annotationView;
    }
    
    return nil;    
}

/*
- (void) zoomToAnnotationsBounds {
    
    NSArray *annotations = self.eventMapView.annotations;
    
    CLLocationDegrees minLatitude = DBL_MAX;
    CLLocationDegrees maxLatitude = -DBL_MAX;
    CLLocationDegrees minLongitude = DBL_MAX;
    CLLocationDegrees maxLongitude = -DBL_MAX;
    
    for (MyLocation *annotation in annotations) {
        double annotationLat = annotation.coordinate.latitude;
        double annotationLong = annotation.coordinate.longitude;
        minLatitude = fmin(annotationLat, minLatitude);
        maxLatitude = fmax(annotationLat, maxLatitude);
        minLongitude = fmin(annotationLong, minLongitude);
        maxLongitude = fmax(annotationLong, maxLongitude);
    }
    
    // See function below
    [self setMapRegionForMinLat:minLatitude minLong:minLongitude maxLat:maxLatitude maxLong:maxLongitude];
    
    UIEdgeInsets mapPadding = UIEdgeInsetsMake(1500.0, 1500.0, 1500.0, 1500.0);
    CLLocationCoordinate2D relativeFromCoord = [self.eventMapView convertPoint:CGPointMake(0, 0) toCoordinateFromView:self.eventMapView];
    
    // Calculate the additional lat/long required at the current zoom level to add the padding
    CLLocationCoordinate2D topCoord = [self.eventMapView convertPoint:CGPointMake(0, mapPadding.top) toCoordinateFromView:self.eventMapView];
    CLLocationCoordinate2D rightCoord = [self.eventMapView convertPoint:CGPointMake(0, mapPadding.right) toCoordinateFromView:self.eventMapView];
    CLLocationCoordinate2D bottomCoord = [self.eventMapView convertPoint:CGPointMake(0, mapPadding.bottom) toCoordinateFromView:self.eventMapView];
    CLLocationCoordinate2D leftCoord = [self.eventMapView convertPoint:CGPointMake(0, mapPadding.left) toCoordinateFromView:self.eventMapView];
    
    double latitudeSpanToBeAddedToTop = relativeFromCoord.latitude - topCoord.latitude;
    double longitudeSpanToBeAddedToRight = relativeFromCoord.latitude - rightCoord.latitude;
    double latitudeSpanToBeAddedToBottom = relativeFromCoord.latitude - bottomCoord.latitude;
    double longitudeSpanToBeAddedToLeft = relativeFromCoord.latitude - leftCoord.latitude;
    
    maxLatitude = maxLatitude + latitudeSpanToBeAddedToTop;
    minLatitude = minLatitude - latitudeSpanToBeAddedToBottom;
    
    maxLongitude = maxLongitude + longitudeSpanToBeAddedToRight;
    minLongitude = minLongitude - longitudeSpanToBeAddedToLeft;
    
    [self setMapRegionForMinLat:minLatitude minLong:minLongitude maxLat:maxLatitude maxLong:maxLongitude];
}
*/
-(void)zoomToAnnotationsBounds
{
    
    CLLocationCoordinate2D coord = CLLocationCoordinate2DMake([[event objectForKey:@"Latitude"] doubleValue], [[event objectForKey:@"Longitude"] doubleValue]);
    
    [self.eventMapView setCenterCoordinate:coord zoomLevel:14 animated:NO];
}
-(void) setMapRegionForMinLat:(double)minLatitude minLong:(double)minLongitude maxLat:(double)maxLatitude maxLong:(double)maxLongitude {
    
    MKCoordinateRegion region;
    region.center.latitude = (minLatitude + maxLatitude) / 2;
    region.center.longitude = (minLongitude + maxLongitude) / 2;
    region.span.latitudeDelta = (maxLatitude - minLatitude);
    region.span.longitudeDelta = (maxLongitude - minLongitude);
    
    [self.eventMapView setRegion:region animated:YES];
}

-(void)viewWillAppear:(BOOL)animated
{
    
    self.eventTitleLabel.font = kDetailEventTitleFont;
    self.eventTimeLabel.font = kDetailEventFont;
    self.eventLocationLabel.font = kDetailEventFont;
    self.eventAddressLabel.font = kDetailEventFont;
    self.eventContactLabel.font = kDetailEventFont;
    self.eventDescriptionLabel.font = kDetailEventFont;
    self.eventDateLabel.font = kDetailEventFont;
    self.openInSafariLabel.font = kDetailOpenInSafariFont;
    self.eventWebsiteLabel.font = kDetailEventFont;
    self.eventContactTextView.font = kDetailEventFont;
    [self.navigationController.navigationBar configureFlatNavigationBarWithColor:kGlobalNavBarColour];

    
    NSLog(@"Event %@", self.event);
    [self updateAndRelayoutView];

}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (void)viewDidUnload
{
    [self setEventTitleLabel:nil];
    [self setEventTimeLabel:nil];
    [self setEventLocationLabel:nil];
    [self setEventAddressLabel:nil];
    [self setEventContactLabel:nil];
    [self setEventDescriptionLabel:nil];
    [self setEventDateLabel:nil];
    [self setEventWebsiteLabel:nil];
    [self setLabelScrollView:nil];
    [self setEventMapView:nil];
    [self setOpenInMapsButton:nil];
    [self setEventDateView:nil];
    [self setEventTimeView:nil];
    [self setEventMapHolderView:nil];
    [self setEventDetailView:nil];
    [self setEventAddressView:nil];
    [self setEventContactView:nil];
    [self setTopRowView:nil];
    [self setEventContactTextView:nil];
    [self setOnlineOnlyOpenInSafariView:nil];
    [self setFavouriteButton:nil];
    [self setOpenInSafariLabel:nil];
    [self setEventAddressDisclosureIndicator:nil];
    [self setEventAddressSearchButton:nil];
    [self setEventWebsiteView:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}




@end
