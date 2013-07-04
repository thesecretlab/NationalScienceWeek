//
//  NSWEventsMapViewController_iPad.m
//  NSWApp
//
//  Created by Nicholas Wittison on 26/06/13.
//
//

#import "NSWEventsMapViewController_iPad.h"
#import <MapKit/MapKit.h>
#import "MyLocation.h"
#import "NSWEventData.h"
#import "EventDetailViewController_iPad.h"
#import "NSWAppAppearanceConfig.h"
#import "UINavigationBar+FlatUI.h"
@interface NSWEventsMapViewController_iPad ()

@end

@implementation NSWEventsMapViewController_iPad
@synthesize eventMap, lastLocationShown;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        [[NSWEventData sharedData] setMapsDelegate:self];
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
    [self setEventMap:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}
-(void)viewWillAppear:(BOOL)animated
{
    [self.navigationController.navigationBar configureFlatNavigationBarWithColor:kGlobalNavBarColour];
}

-(void)viewDidAppear:(BOOL)animated
{
    [[NSWEventData sharedData] setMapsDelegate:self];
    
    if ([[[NSWEventData sharedData] eventData] count] > 0) {
        
        if ([self.eventMap.annotations count] == 0) {
            [self plotEvents];
            [self zoomToCurrentRegionAnnotationBounds];
            self.lastLocationShown = [[NSWEventData sharedData] location];
        }
        else if(![self.lastLocationShown isEqualToString:[[NSWEventData sharedData] location]])
        {
            [self plotEvents];
            [self zoomToCurrentRegionAnnotationBounds];
            self.lastLocationShown = [[NSWEventData sharedData] location];
            
        }
        
    }
}

- (void)newDataWasDownloaded
{
    [self plotEvents];
}


- (IBAction)findClosestEvent:(id)sender
{
    float shortestDistance = MAXFLOAT;
    id<MKAnnotation> foundAnnotation;
    
    for (id<MKAnnotation> annotation in self.eventMap.annotations)
    {
        float dist = [self kilometresBetweenPlace1:self.eventMap.userLocation.coordinate andPlace2: annotation.coordinate];
        if (dist < shortestDistance && dist != 0.00)
        {
            shortestDistance = dist;
            foundAnnotation = annotation;
        }
    }
    
    [self.eventMap selectAnnotation:foundAnnotation
                           animated:YES];
}

- (IBAction)centerOnUser:(id)sender
{
    MKCoordinateRegion region;
    MKCoordinateSpan span;
    span.latitudeDelta = 0.08;
    span.longitudeDelta = 0.08;
    CLLocationCoordinate2D location;
    location.latitude = self.eventMap.userLocation.coordinate.latitude;
    location.longitude = self.eventMap.userLocation.coordinate.longitude;
    
    NSLog(@"%f, %f", location.latitude, location.longitude);
    region.span = span;
    region.center = location;
    [self.eventMap setRegion:region animated:YES];
    
}


-(float)kilometresBetweenPlace1:(CLLocationCoordinate2D) currentLocation andPlace2:(CLLocationCoordinate2D) place2
{
    CLLocation *userLoc = [[CLLocation alloc] initWithLatitude:currentLocation.latitude longitude:currentLocation.longitude];
    CLLocation *poiLoc = [[CLLocation alloc] initWithLatitude:place2.latitude longitude:place2.longitude];
    CLLocationDistance dist = [userLoc distanceFromLocation:poiLoc];
    NSString *strDistance = [NSString stringWithFormat:@"%.2f", dist];
    return [strDistance floatValue];
}

- (void)plotEvents{
    
    for (id<MKAnnotation> annotation in self.eventMap.annotations) {
        [self.eventMap removeAnnotation:annotation];
    }
    
    for (NSDictionary * event in [[NSWEventData sharedData] eventData]) {
        
        if (![[event objectForKey:@"Longitude"] isEqualToString:@""] && ![[event objectForKey:@"Latitude"] isEqualToString:@""])
        {
            NSNumber * latitude = [NSNumber numberWithDouble:[[event objectForKey:@"Latitude"] doubleValue]];
            NSNumber * longitude = [NSNumber numberWithDouble:[[event objectForKey:@"Longitude"] doubleValue]];
            
            NSString * purchaseDescription = [NSString stringWithFormat:[event objectForKey:@"Title"]];
            NSString * purchaseLocation = [event objectForKey:@"Location"];
            
            CLLocationCoordinate2D coordinate;
            coordinate.latitude = latitude.doubleValue;
            coordinate.longitude = longitude.doubleValue;
            MyLocation *annotation = [[MyLocation alloc] initWithName:purchaseDescription address:purchaseLocation coordinate:coordinate] ;
            annotation.event = event;
            [self.eventMap addAnnotation:annotation];
        }
        
    }
}

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id <MKAnnotation>)annotation {
    
    static NSString *identifier = @"MyLocation";
    if ([annotation isKindOfClass:[MyLocation class]]) {
        
        MKPinAnnotationView *annotationView = (MKPinAnnotationView *) [self.eventMap dequeueReusableAnnotationViewWithIdentifier:identifier];
        if (annotationView == nil) {
            annotationView = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:identifier];
            
        } else {
            annotationView.annotation = annotation;
        }
        
        annotationView.enabled = YES;
        annotationView.canShowCallout = YES;
        annotationView.animatesDrop = YES;
        
        annotationView.rightCalloutAccessoryView = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
        //annotationView.image=[UIImage imageNamed:@"arrest.png"];//here we use a nice image instead of the default pins
        
        return annotationView;
    }
    
    return nil;
}

- (void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)view calloutAccessoryControlTapped:(UIControl *)control
{
    UIStoryboard* storyboard = [UIStoryboard storyboardWithName:@"MainStoryboard_iPad" bundle:nil];
    EventDetailViewController_iPad* eventDetail = [storyboard instantiateViewControllerWithIdentifier:@"EventDetail_iPad"];
    
    eventDetail.event = [(MyLocation*)[view annotation] event];
    
    [self.navigationController pushViewController:eventDetail animated:YES];
    
}

- (void) zoomToCurrentRegionAnnotationBounds {
    
    NSArray *annotations = self.eventMap.annotations;
    
    NSMutableArray *annotationsForCurrentRegion = [NSMutableArray array];
    
    for(MyLocation *annotation in annotations)
    {
        if ([[annotation.event objectForKey:@"Region"] isEqualToString:[[NSWEventData sharedData] location]]) {
            [annotationsForCurrentRegion addObject:annotation];
        }
        
        
    }
    
    if (annotationsForCurrentRegion == nil) {
        return;
    }
    
    CLLocationDegrees minLatitude = DBL_MAX;
    CLLocationDegrees maxLatitude = -DBL_MAX;
    CLLocationDegrees minLongitude = DBL_MAX;
    CLLocationDegrees maxLongitude = -DBL_MAX;
    
    for (MyLocation *annotation in annotationsForCurrentRegion) {
        double annotationLat = annotation.coordinate.latitude;
        double annotationLong = annotation.coordinate.longitude;
        minLatitude = fmin(annotationLat, minLatitude);
        maxLatitude = fmax(annotationLat, maxLatitude);
        minLongitude = fmin(annotationLong, minLongitude);
        maxLongitude = fmax(annotationLong, maxLongitude);
    }
    
    // See function below
    [self setMapRegionForMinLat:minLatitude minLong:minLongitude maxLat:maxLatitude maxLong:maxLongitude];
    
    UIEdgeInsets mapPadding = UIEdgeInsetsMake(60.0, 10.0, 0.0, 10.0);
    CLLocationCoordinate2D relativeFromCoord = [self.eventMap convertPoint:CGPointMake(0, 0) toCoordinateFromView:self.eventMap];
    
    // Calculate the additional lat/long required at the current zoom level to add the padding
    CLLocationCoordinate2D topCoord = [self.eventMap convertPoint:CGPointMake(0, mapPadding.top) toCoordinateFromView:self.eventMap];
    CLLocationCoordinate2D rightCoord = [self.eventMap convertPoint:CGPointMake(0, mapPadding.right) toCoordinateFromView:self.eventMap];
    CLLocationCoordinate2D bottomCoord = [self.eventMap convertPoint:CGPointMake(0, mapPadding.bottom) toCoordinateFromView:self.eventMap];
    CLLocationCoordinate2D leftCoord = [self.eventMap convertPoint:CGPointMake(0, mapPadding.left) toCoordinateFromView:self.eventMap];
    
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



- (void) zoomToAnnotationsBounds {
    
    NSArray *annotations = self.eventMap.annotations;
    
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
    
    UIEdgeInsets mapPadding = UIEdgeInsetsMake(60.0, 10.0, 0.0, 10.0);
    CLLocationCoordinate2D relativeFromCoord = [self.eventMap convertPoint:CGPointMake(0, 0) toCoordinateFromView:self.eventMap];
    
    // Calculate the additional lat/long required at the current zoom level to add the padding
    CLLocationCoordinate2D topCoord = [self.eventMap convertPoint:CGPointMake(0, mapPadding.top) toCoordinateFromView:self.eventMap];
    CLLocationCoordinate2D rightCoord = [self.eventMap convertPoint:CGPointMake(0, mapPadding.right) toCoordinateFromView:self.eventMap];
    CLLocationCoordinate2D bottomCoord = [self.eventMap convertPoint:CGPointMake(0, mapPadding.bottom) toCoordinateFromView:self.eventMap];
    CLLocationCoordinate2D leftCoord = [self.eventMap convertPoint:CGPointMake(0, mapPadding.left) toCoordinateFromView:self.eventMap];
    
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

-(void) setMapRegionForMinLat:(double)minLatitude minLong:(double)minLongitude maxLat:(double)maxLatitude maxLong:(double)maxLongitude {
    
    if (minLatitude + maxLatitude == 0) {
        return;
    }
    
    MKCoordinateRegion region;
    region.center.latitude = (minLatitude + maxLatitude) / 2;
    region.center.longitude = (minLongitude + maxLongitude) / 2;
    region.span.latitudeDelta = (maxLatitude - minLatitude);
    region.span.longitudeDelta = (maxLongitude - minLongitude);
    
    [self.eventMap setRegion:region animated:YES];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)didReceiveMemoryWarning
{
    for (id<MKAnnotation> annotation in self.eventMap.annotations) {
        [self.eventMap removeAnnotation:annotation];
    }
    [super didReceiveMemoryWarning];
}

@end

