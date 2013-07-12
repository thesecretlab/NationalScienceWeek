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
#import "MyLocation.h"
#import "MKMapView+ZoomLevel.h"
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

- (void) awakeFromNib{
    
    [super awakeFromNib];
    self.splitViewController.delegate = self;

}


-(void)selectFirstView
{
    if ([[NSWEventData sharedData] eventsForLocation] && [[[NSWEventData sharedData] eventsForLocation] count]>0) {
        _event = [[[NSWEventData sharedData] eventsForLocation] objectAtIndex:0];
        [self updateAndRelayoutView];
    }
    
}

- (void)viewDidLoad
{
    /*
    UILabel *tapToStartLabel = [[UILabel alloc] init];
    [tapToStartLabel setText:@"Tap an event from the event list to get started."];
    [tapToStartLabel setFrame:CGRectMake(150, 150, 500, 50)];
    [tapToStartLabel setFont:[UIFont boldFlatFontOfSize:30]];
    tapToStartLabel.backgroundColor = [UIColor clearColor];
    tapToStartLabel.textColor = [UIColor whiteColor];
    [self.noEventImageView addSubview:tapToStartLabel];
    */
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
    
    //NSLog(@"Frame height %@", _event);
    self.eventTitleLabel.font = kDetailEventTitleFont_iPad;
    self.eventTimeLabel.font = kDetailEventFont_iPad;
    self.eventAddressLabel.font = kDetailEventFont_iPad;
    self.eventDescriptionLabel.font = kDetailEventFont_iPad;
    self.eventDateLabel.font = kDetailEventFont_iPad;
    self.openInSafariLabel.font = kDetailOpenInSafariFont;
    self.eventContactTextView.font = kDetailEventFont_iPad;
    self.eventWebsiteLabel.font = kDetailEventFont_iPad;

    if (_event == nil) {
        self.topRowView.hidden = YES;
        self.eventContactView.hidden = YES;
        self.eventAddressView.hidden = YES;
        self.eventDetailView.hidden = YES;
        self.eventTitleLabel.hidden = YES;
        self.eventMapHolderView.hidden = YES;
        self.eventMapView.hidden = YES;
        self.openInMapsButton.hidden = YES;
        self.eventWebsiteView.hidden = YES;
        self.favouriteButton.enabled = NO;
        //self.noEventImageView.hidden = NO;
        [self selectFirstView];
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
        self.eventWebsiteView.hidden = NO;
        self.favouriteButton.enabled = YES;
        //self.noEventImageView.hidden = YES;

    }
    
    
    
    
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
    else
    {
        self.eventContactTextView.text = @"";
        
    }
    
    
    if (![[_event objectForKey:@"Website"] isEqualToString:@""])
    {
        self.eventWebsiteLabel.text = [NSString stringWithFormat:@"%@", [_event objectForKey:@"Website"]];
    }
    else
    {
        self.eventWebsiteLabel.text = @"";
        
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
    
    
    currentLayoutHeight = 10.0; //Starting height from top label.
    
    if (![[_event objectForKey:@"Location"] isEqualToString:@"Online"])
    {
        
        [self positionLabelOnScreen:self.eventTitleLabel withFont:kDetailEventTitleFont_iPad sizeForMinumumLabel:21.0 bufferToNextLabel:10];
        
        self.topRowView.frame = CGRectMake(self.topRowView.frame.origin.x, currentLayoutHeight, self.topRowView.frame.size.width, self.topRowView.frame.size.height);
        currentLayoutHeight = currentLayoutHeight + self.topRowView.frame.size.height + 10;
        
        [self positionLabelViewOnScreen:self.eventDetailView withLabel:(UILabel*)self.eventDescriptionLabel bufferToNextView:10];
        
        [self positionLabelViewOnScreen:self.eventContactView withLabel:(UILabel*)self.eventContactTextView bufferToNextView:10];
        
        if (self.eventContactView.hidden == NO) {
            self.eventContactView.frame = CGRectMake(self.eventContactView.frame.origin.x, self.eventContactView.frame.origin.y, (self.eventDetailView.frame.size.width -10)/2, self.eventContactView.frame.size.height);
            
            
            self.eventAddressView.frame = CGRectMake(29 + self.eventContactView.frame.size.width + 10, self.eventAddressView.frame.origin.y, self.eventContactView.frame.size.width, self.eventAddressView.frame.size.height);
                self.eventAddressView.autoresizingMask = (UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleBottomMargin);
            currentLayoutHeight = currentLayoutHeight - self.eventContactView.frame.size.height - 10;
            
        }
        else{
            self.eventAddressView.frame = CGRectMake(29, self.eventAddressView.frame.origin.y, (self.eventAddressView.frame.size.width -10)/2, self.eventAddressView.frame.size.height);
            self.eventAddressView.autoresizingMask = (UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleBottomMargin);

            
        }
        [self positionLabelViewOnScreen:self.eventAddressView withLabel:self.eventAddressLabel bufferToNextView:10];
        
        if (self.eventAddressView.frame.size.height != self.eventContactView.frame.size.height) {
            if (self.eventAddressView.frame.size.height >= self.eventContactView.frame.size.height) {
                self.eventContactView.frame = CGRectMake(self.eventContactView.frame.origin.x, self.eventContactView.frame.origin.y, self.eventContactView.frame.size.width, self.eventAddressView.frame.size.height);
                self.eventContactTextView.frame = CGRectMake(12, 10, self.eventContactView.frame.size.width-24, self.eventContactTextView.frame.size.height-20);

            }
            else if (self.eventAddressView.frame.size.height < self.eventContactView.frame.size.height) {
                currentLayoutHeight = currentLayoutHeight - self.eventAddressView.frame.size.height - 10;
                currentLayoutHeight = currentLayoutHeight + self.eventContactView.frame.size.height + 10;

                self.eventAddressView.frame = CGRectMake(self.eventAddressView.frame.origin.x, self.eventAddressView.frame.origin.y, self.eventAddressView.frame.size.width, self.eventContactView.frame.size.height);
                self.eventAddressLabel.frame = CGRectMake(12, 10, self.eventAddressView.frame.size.width-34, self.eventAddressView.frame.size.height-20);


            }
        }
        
        self.eventWebsiteView.frame = CGRectMake(self.eventWebsiteView.frame.origin.x, self.eventWebsiteView.frame.origin.y, self.eventDetailView.frame.size.width, self.eventWebsiteView.frame.size.height);
        
        
        [self positionLabelViewOnScreen:self.eventWebsiteView withLabel:(UILabel*)self.eventWebsiteLabel bufferToNextView:10];

    }
    
    
    self.eventDateView.layer.cornerRadius = kDetailCornerRadius;
    self.eventTimeView.layer.cornerRadius = kDetailCornerRadius;
    self.eventMapHolderView.layer.cornerRadius = kDetailCornerRadius;
    
    self.eventDetailView.layer.cornerRadius = kDetailCornerRadius;
    self.eventContactView.layer.cornerRadius = kDetailCornerRadius;
    self.eventAddressView.layer.cornerRadius = kDetailCornerRadius;
    self.eventWebsiteView.layer.cornerRadius = kDetailCornerRadius;
    self.onlineOnlyOpenInSafariView.layer.cornerRadius = kDetailCornerRadius;
    
    float width = self.topRowView.frame.size.width;
    
    float topRowBuffer = 10.0;
    
    width = (width - 2*topRowBuffer)/3; //Minus buffer x2
    
    self.eventDateView.frame = CGRectMake(self.eventDateView.frame.origin.x, self.eventDateView.frame.origin.y, width, self.eventDateView.frame.size.height);
    
    self.eventTimeView.frame = CGRectMake(width + topRowBuffer, self.eventTimeView.frame.origin.y, width, self.eventTimeView.frame.size.height);
    
    self.eventMapHolderView.frame = CGRectMake(2*width + 2*topRowBuffer, self.eventMapHolderView.frame.origin.y, width, self.eventMapHolderView.frame.size.height);

    if (![[_event objectForKey:@"Longitude"] isEqualToString:@""]&& ![[_event objectForKey:@"Latitude"] isEqualToString:@""]) {
        
        self.openInMapsButton.backgroundColor = [UIColor clearColor];
        [self.openInMapsButton setTitle:@"" forState:UIControlStateNormal];
        
        self.eventMapView.layer.cornerRadius = kDetailCornerRadius;
        
        
        [self plotEvent];
        [self zoomToAnnotationsBounds];
    }
    else {
        
        self.openInMapsButton.backgroundColor = [UIColor colorWithRed:0.8 green:0.8 blue:0.8 alpha:0.8];
        [self.openInMapsButton setTitle:@"No Map Available" forState:UIControlStateNormal];
        [self.openInMapsButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        self.openInMapsButton.titleLabel.font = [UIFont flatFontOfSize:20.0];
        
        MKCoordinateRegion worldRegion = MKCoordinateRegionMake(CLLocationCoordinate2DMake(-28.471555, 133.491902), MKCoordinateSpanMake(40, 60)); //Center on australia
        self.eventMapView.region = worldRegion;
        
        for (id<MKAnnotation> annotation in self.eventMapView.annotations) {
            [self.eventMapView removeAnnotation:annotation];
        }
        
        //self.eventMapHolderView.hidden = YES;
        //self.eventMapView.hidden = YES;
        //self.openInMapsButton.hidden = YES;
    }
    
    currentLayoutHeight = currentLayoutHeight +29; //Top Label buffer
    [self resizeScrollViewContentSize];
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
        
        CGSize size = [currentLabel.text sizeWithFont:fontForLabel constrainedToSize:constraint lineBreakMode:NSLineBreakByWordWrapping];
        
        CGFloat height = MAX(size.height, sizeForMinumumLabel);
        
        currentLabel.frame = CGRectMake(currentLabel.frame.origin.x, currentLayoutHeight, currentLabel.frame.size.width, height);
        
        
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
        
        
        CGSize constraint = CGSizeMake(currentView.frame.size.width-34, 20000.0f);
        
        CGSize size = [currentLabel.text sizeWithFont:currentLabel.font constrainedToSize:constraint lineBreakMode:NSLineBreakByWordWrapping];
        
        CGFloat height = MAX(size.height, 20);
        
        
        height = height;
        
        currentView.frame = CGRectMake(currentView.frame.origin.x, currentLayoutHeight, currentView.frame.size.width, height+20);
        
        if (currentLabel == self.eventAddressLabel)
        {
            currentLabel.frame = CGRectMake(12, 10, currentView.frame.size.width-34, height);
        }
        else
        {
            currentLabel.frame = CGRectMake(12, 10, currentView.frame.size.width-24, height);
        }
        
        
        currentLayoutHeight = height+20 + currentLayoutHeight + bufferToNextView;
        
        
        
    }
    else {
        currentView.hidden = YES;
        //currentLabel.hidden = YES;
    }
    
    
}


-(void)splitViewController:(UISplitViewController *)svc willHideViewController:(UIViewController *)aViewController withBarButtonItem:(UIBarButtonItem *)barButtonItem forPopoverController:(UIPopoverController *)pc
{
    barButtonItem.title = @"Events";
    [self.navigationItem setLeftBarButtonItem:barButtonItem animated:YES];
    //self.masterPopoverController = pc;
}

-(void)splitViewController:(UISplitViewController*)svc willShowViewController:(UIViewController *)aViewController invalidatingBarButtonItem:(UIBarButtonItem *)barButtonItem{
    barButtonItem.title = @"Events";
    [self.navigationItem setLeftBarButtonItem:nil animated:YES];

}


- (void)plotEvent{
    
    for (id<MKAnnotation> annotation in self.eventMapView.annotations) {
        [self.eventMapView removeAnnotation:annotation];
    }
    
    
    NSNumber * latitude = [NSNumber numberWithDouble:[[_event objectForKey:@"Latitude"] doubleValue]];
    NSNumber * longitude = [NSNumber numberWithDouble:[[_event objectForKey:@"Longitude"] doubleValue]];
    
    NSString * purchaseDescription = [NSString stringWithFormat:@"%@",[_event objectForKey:@"Title"]];
    NSString * purchaseLocation = [_event objectForKey:@"Location"];
    
    CLLocationCoordinate2D coordinate;
    coordinate.latitude = latitude.doubleValue;
    coordinate.longitude = longitude.doubleValue;
    MyLocation *annotation = [[MyLocation alloc] initWithName:purchaseDescription address:purchaseLocation coordinate:coordinate] ;
    annotation.event = _event;
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
    
    UIEdgeInsets mapPadding = UIEdgeInsetsMake(60.0, 60.0, 60.0, 60.0);
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
   
    CLLocationCoordinate2D coord = CLLocationCoordinate2DMake([[_event objectForKey:@"Latitude"] doubleValue], [[_event objectForKey:@"Longitude"] doubleValue]);
    
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
    
    self.labelScrollView.frame = self.view.frame;

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
        self.event = nil;
        [self updateAndRelayoutView];
    }


}

- (IBAction)openInMaps:(id)sender
{
    if (![[_event objectForKey:@"Latitude"] isEqualToString:@""]&& ![[_event objectForKey:@"Longitude"] isEqualToString:@""]) {
        NSString *url = [NSString stringWithFormat: @"http://maps.apple.com/maps?q=%f,%f&t=m", [[_event objectForKey:@"Latitude"] floatValue], [[_event objectForKey:@"Longitude"] floatValue]];
        // [[UIApplication sharedApplication] openURL:[NSURL URLWithString:url]];
        UIApplication *app = [UIApplication sharedApplication];
        // NSURL* urlURL = [[NSURL alloc] initWithString:[url stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
        
        [app openURL:[NSURL URLWithString:url]];
    }
    else{
        
        if (sender == self.eventAddressSearchButton) {

            NSString *url = [NSString stringWithFormat: @"http://maps.apple.com/maps?q=%@,%@&t=m",[[_event objectForKey:@"Location"] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding], [[_event objectForKey:@"Address"] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
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
    
    
    NSDictionary *barAppearanceDict = @{UITextAttributeFont : kGlobalNavBarFont,UITextAttributeTextShadowColor : [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.8], UITextAttributeTextColor : [UIColor whiteColor], UITextAttributeTextShadowOffset : [NSValue valueWithUIOffset:UIOffsetMake(0, -1)]};
    
    [controller.navigationBar setTitleTextAttributes:barAppearanceDict];
    
    
    
    [controller.navigationBar configureFlatNavigationBarWithColor:kGlobalNavBarColour];
    [self presentModalViewController: controller animated:YES];
    
}
- (void)eventEditViewController:(EKEventEditViewController *)controller didCompleteWithAction:(EKEventEditViewAction)action {
    [self dismissModalViewControllerAnimated:YES];
}
- (IBAction)openInSafari:(id)sender
{
    NSURL *websiteToOpen = [NSURL URLWithString:[NSString stringWithFormat:@"%@",[_event objectForKey:@"Website"]]];
    NSLog(@" WEBSITE? %@", websiteToOpen);
    [[UIApplication sharedApplication] openURL:websiteToOpen];
    
}

- (void)resizeScrollViewContentSize
{
    if (currentLayoutHeight > self.labelScrollView.frame.size.height)
    {
        self.labelScrollView.contentSize = CGSizeMake(self.labelScrollView.frame.size.width, currentLayoutHeight);
    }
    else
    {
        self.labelScrollView.contentSize = CGSizeMake(self.labelScrollView.frame.size.width, self.labelScrollView.frame.size.height+1);
    }
}

-(void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
        [self updateAndRelayoutView];

}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    self.labelScrollView.frame = self.view.frame;
    
    [self resizeScrollViewContentSize];
    

}


- (void)viewDidUnload {
    [self setNoEventImageView:nil];
    [self setEventAddressDisclosureIndicator:nil];
    [self setEventAddressSearchButton:nil];
    [self setEventWebsiteView:nil];
    [self setEventWebsiteLabel:nil];
    [super viewDidUnload];
}
@end
