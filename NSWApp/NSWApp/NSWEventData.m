//
//  NSWEventData.m
//  NSWApp
//
//  Created by Nicholas Wittison on 18/07/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "NSWEventData.h"
#import "CHCSV.h"

static NSWEventData* _sharedData = nil;

@implementation NSWEventData
@synthesize eventData, location, eventsForLocation, locationValues, latestVersionNumber, delegate, locationMeasurements, favouriteEvents, favouritesDelegate, mapsDelegate;

+ (NSWEventData*)sharedData {
    if (_sharedData == nil) 
    {  
        _sharedData = [[NSWEventData alloc] init];
        [_sharedData loadFromFile];
        _sharedData.locationValues = [NSArray arrayWithObjects:@"Southern Tasmania", @"Northern Tasmania", @"North-western Tasmania", nil];
        [_sharedData setCurrentLocationCounter:0];
        _sharedData.latestVersionNumber = [NSNumber numberWithInt:-1];
        _sharedData.locationMeasurements = [NSMutableArray array];
        _sharedData.favouriteEvents = [NSMutableArray array];

    }
    
    return _sharedData;
}

-(void)setCurrentLocationCounter:(int)newValue
{
    currentLocationCounter = newValue;
}

-(void)saveToFile
{
    NSLog(@"Saving...");
    NSMutableDictionary *saveDict = [NSMutableDictionary dictionary];
    [saveDict setValue:self.eventData forKey:@"eventData"];
    [saveDict setValue:self.location forKey:@"location"];
    [saveDict setValue:self.latestVersionNumber forKey:@"latestVersion"];
    [saveDict setValue:self.favouriteEvents forKey:@"favouriteEvents"];

    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *filePath = [documentsDirectory stringByAppendingString:@"/NSWEventData.sav"];
    [saveDict writeToFile:filePath atomically:YES];
    
}

-(void)loadFromFile
{
    NSLog(@"Loading Data..");
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *filePath = [documentsDirectory stringByAppendingString:@"/NSWEventData.sav"];
    BOOL fileExists = [[NSFileManager defaultManager] fileExistsAtPath:filePath];
    
    if (fileExists) {
        NSDictionary *loadDict = [NSDictionary dictionaryWithContentsOfFile:filePath];
        self.eventData =   [NSMutableArray arrayWithArray:[loadDict valueForKey:@"eventData"]];
        self.favouriteEvents =   [NSMutableArray arrayWithArray:[loadDict valueForKey:@"favouriteEvents"]];
        [self changeLocation:[NSString stringWithString:[loadDict valueForKey:@"location"]]];
        self.latestVersionNumber = [loadDict valueForKey:@"latestVersion"];
        [self refilterEventsForLocation];
    }
    else {
        self.eventData = [NSMutableArray array];
        self.favouriteEvents = [NSMutableArray array];
        [self changeLocation:@"Southern Tasmania"];
        self.latestVersionNumber = [NSNumber numberWithInt:-1];
      // [self loadCSVEventsFromCSVFile]; //TAKE AWAY IF YOU DON'T WANT DEFAULT LOADING DONE
        
    }
    
}


-(void)loadCSVEventsFromCSVFile
{
    
    NSString * file = [[NSBundle bundleForClass:[self class]] pathForResource:@"NSWkAPPSpreadsheet" ofType:@"csv"];
	
	NSStringEncoding encoding = 0;
	NSError * error = nil;
	NSArray * fields = [NSArray arrayWithContentsOfCSVFile:file usedEncoding:&encoding error:&error];
    //NSLog(@"read: %@", fields);
    self.latestVersionNumber = [NSNumber numberWithInt:-1];

    [self processNewEventsArray:fields];
    
    [self saveToFile];
}

-(void)updateEventDataFromDownload:(NSString*)newCSVData;
{

    NSLog(@"Data definately here: %@", newCSVData);
    NSError *error;
    

    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *filePath = [documentsDirectory stringByAppendingString:@"/NSWNewEventData.xml"];

    [newCSVData writeToFile:filePath atomically:YES 
                    encoding:NSUTF8StringEncoding error:&error];
        
	NSStringEncoding encoding = 0;
    RXMLElement *rootXML = [RXMLElement elementFromXMLString:newCSVData encoding:NSUTF8StringEncoding];
    
    //RXMLElement *rxmlEvents = [rootXML child:@"Events"];
    
    
    //NSArray *rxmlIndividualEvents = [rootXML children:@"Event"];
   
    __block NSMutableArray *fields = [NSMutableArray array];
    [rootXML iterate:@"Event" usingBlock: ^(RXMLElement *event) {
        NSMutableDictionary *eventDict = [NSMutableDictionary dictionary];
        
        [eventDict setObject:[event child:@"EventID"].text forKey:@"Event ID"];
        [eventDict setObject:[event child:@"EventName"].text forKey:@"Title"];
        
        
        [eventDict setObject:[NSString stringWithFormat:@"%@\n\nFor: %@ \n\nEvent Price: %@",[event child:@"EventDescription"].text,[event child:@"EventTargetAudience"].text,[event child:@"EventPayment"].text] forKey:@"Description"];
        
        RXMLElement *venue = [event child:@"Venue"];
        NSLog(@"Venue: %@", venue);
        [eventDict setObject:[NSString stringWithFormat:@"%@", [venue child:@"VenueName"].text] forKey:@"Location"];
        NSString *addressString = [NSString stringWithFormat:@" %@, %@, %@", [venue child:@"VenueStreetName"].text, [venue child:@"VenueSuburb"].text, [venue child:@"VenuePostcode"].text];
        [eventDict setObject:addressString forKey:@"Address"];
        
        [eventDict setObject:[NSString stringWithFormat:@"%@\n%@\n\n%@\n\n%@",[event child:@"EventContactName"].text, [event child:@"EventContactOrganisation"].text, [event child:@"EventContactTelephone"].text, [event child:@"EventContactEmail"].text] forKey:@"Contact"];
        [eventDict setObject:[NSString stringWithFormat:@"%@", [venue child:@"EventWebsite"].text] forKey:@"Website"];

        
        [eventDict setObject:@"Northern Tasmania" forKey:@"Region"];  //EXPLICIT STATE REGION DATA NEEDS TO BE INCLUDED IN THE DATA
        [fields addObject:eventDict];
        //NSLog(@"Event: %@", [event child:@"EventName"]);
    }];
    
	//NSArray * fields = nil; //PARSE XML HERE
    
    //[NSArray arrayWithContentsOfCSVFile:filePath usedEncoding:&encoding error:&error];
    
    if (fields) {

        [self processNewEventsArray:fields];
        [self revalidateFavourites];
        [self saveToFile];
        if (self.delegate) {
            [self.delegate newDataWasDownloaded];
        }
        if (self.mapsDelegate) {
            [self.mapsDelegate newDataWasDownloaded];
        }
    }

}

- (void)processNewEventsArray:(NSArray *)fields
{
    /*
    NSMutableArray * csvEventArray = [NSMutableArray array];
    
    for (NSArray *event in fields) {
        if ([fields indexOfObject:event]== 0) {
            
        }
        else {
            int counter = 0;
            NSMutableDictionary *eventDictionary = [NSMutableDictionary dictionary];
            for (NSString *informationField in event) {
                
                [eventDictionary setObject:informationField forKey:[[fields objectAtIndex:0] objectAtIndex:counter]];
                
                counter = counter +1;
            }
            [csvEventArray addObject:eventDictionary];
        }
    }
     */
    //NSLog(@"read: %@", csvEventArray);
    self.eventData = [fields mutableCopy];
    
    [self refilterEventsForLocation];
}





-(NSArray*)uniqueSingleDates
{
    NSLog(@"Getting all dates");
    NSMutableArray *uniqueDates = [NSMutableArray array];
    
    for(NSMutableDictionary *event in self.eventsForLocation)
    {
        if ([[event objectForKey:@"Date"] length] == 9) {
            [event setObject:[NSString stringWithFormat:@"0%@",[event objectForKey:@"Date"]] forKey:@"Date"];
        }
        if ([[event objectForKey:@"Date"] length] == 10) {

            if (![uniqueDates containsObject:[event objectForKey:@"Date"]])
            {
                [uniqueDates addObject:[event objectForKey:@"Date"]];
            }
            
            
        }
    }
    
    NSMutableArray *arrayOfDates = [NSMutableArray array];
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"dd/MM/yyyy"];
    
    for (NSString *stringDate in uniqueDates) {
        NSDate *dateObject = [dateFormatter dateFromString:stringDate];
        [arrayOfDates addObject:dateObject];
    }
    
    
    [arrayOfDates sortUsingSelector:@selector(compare:)];
    
    NSMutableArray *arrayToReturn = [NSMutableArray array];
    
    for (NSDate *currentDate in arrayOfDates) {
        [arrayToReturn addObject:[dateFormatter stringFromDate:currentDate]];
    }
    
    //NSLog(@"Unique dates: %@", [uniqueDates sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)]);
    return arrayToReturn;
}

-(NSArray*)multiDateEvents
{
    NSMutableArray *multiDates = [NSMutableArray array];
    
    for(NSMutableDictionary *event in self.eventsForLocation)
    {
        if ([[event objectForKey:@"Date"] length] == 9) {
            [event setObject:[NSString stringWithFormat:@"0%@",[event objectForKey:@"Date"]] forKey:@"Date"];
        }
        if ([[event objectForKey:@"Date"] length] != 10) {
                [multiDates addObject:event];
        }
    }

    
    return multiDates;
}

-(NSArray*)eventsForDate:(NSString*) date
{
    NSMutableArray *singleDateEvents = [NSMutableArray array];
    
    for(NSMutableDictionary *event in self.eventsForLocation)
    {
        if ([[event objectForKey:@"Date"] length] == 9) {
            [event setObject:[NSString stringWithFormat:@"0%@",[event objectForKey:@"Date"]] forKey:@"Date"];
        }
        if ([[event objectForKey:@"Date"] isEqualToString:date]) {
            [singleDateEvents addObject:event];
        }
        
        
    }
    
    
    return singleDateEvents;
}

-(NSDictionary*)eventForKey:(NSString*)eventKey
{
    NSMutableDictionary *foundEvent;
    
    for (NSMutableDictionary *event in self.eventsForLocation) {
        if ([[event objectForKey:@"Event ID"] isEqualToString:eventKey]) {
            foundEvent = event;
        }
    }
    return foundEvent;
}


-(void)refilterEventsForLocation
{
    [self changeLocation:self.location];
}

-(void)checkUsersLocation
{
    locationManager = [[CLLocationManager alloc] init];
    locationManager.purpose = @"We'll show you events close to where you are.";
    locationManager.delegate = self;
    locationManager.distanceFilter = kCLDistanceFilterNone;
    locationManager.desiredAccuracy = kCLLocationAccuracyThreeKilometers;
    [locationManager startUpdatingLocation];
    
    [self performSelector:@selector(stopUpdatingLocation:) withObject:@"Timed Out" afterDelay:20.0];
}

- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation {
    [locationMeasurements addObject:newLocation];
    NSTimeInterval locationAge = -[newLocation.timestamp timeIntervalSinceNow];
    if (locationAge > 5.0) return;
    if (newLocation.horizontalAccuracy < 0) return;
    if (bestEffortAtLocation == nil || bestEffortAtLocation.horizontalAccuracy > newLocation.horizontalAccuracy) {
        bestEffortAtLocation = newLocation;

        if (newLocation.horizontalAccuracy <= locationManager.desiredAccuracy) {

            [self stopUpdatingLocation:@""];
            [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(stopUpdatingLocation:) object:@"Timed Out"];
        }
    }
}

- (void)stopUpdatingLocation:(NSString *)state {
    
    //NSLog(@"Location %@", bestEffortAtLocation);
    [locationManager stopUpdatingLocation];
    locationManager.delegate = nil;
    
    if (bestEffortAtLocation != nil) {
        if (bestEffortAtLocation.coordinate.latitude < -42.00) {
            [self changeLocation:@"Southern Tasmania"];
        }
        else {
            if (bestEffortAtLocation.coordinate.longitude > 146.6 ) {
                [self changeLocation:@"Northern Tasmania"];
            }
            else {
                [self changeLocation:@"North-western Tasmania"];
            }
        }
    }
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {

    if ([error code] != kCLErrorLocationUnknown) {
        [self stopUpdatingLocation:@""];
    }
}

-(void)changeLocation:(NSString*)newLocation
{
    
    self.location = newLocation;
    currentLocationCounter = [self.locationValues indexOfObject:newLocation];
    NSMutableArray *eventsForNewLocation = [NSMutableArray array];
    
    for (NSMutableDictionary *event in self.eventData) {
        if ([[event objectForKey:@"Region"] isEqualToString:newLocation]) 
        {
            [eventsForNewLocation addObject:event];
            if (![[event objectForKey:@"End Date"] isEqualToString:@""]) 
            {
                NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
                
                [dateFormatter setDateFormat:@"dd/MM/yyyy"];
                NSDate *date = [dateFormatter dateFromString:[event objectForKey:@"Date"]];
                NSDate *endDate = [dateFormatter dateFromString:[event objectForKey:@"End Date"]];
                NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
                
                NSUInteger unitFlags = NSDayCalendarUnit;
                NSDateComponents *dayComponent = [gregorian components:unitFlags fromDate:date toDate:endDate options:0];
                
                int numberOfDaysEventRunsFor = [dayComponent day];
                
                
                NSDateComponents *offsetComponents = [[NSDateComponents alloc] init];
                [offsetComponents setDay:1];
                
                
                for (int i = 0; i<numberOfDaysEventRunsFor; i++) {
                    date = [gregorian dateByAddingComponents:offsetComponents toDate:date options:0];
                    NSString *strMyDate= [dateFormatter stringFromDate:date];
                    NSMutableDictionary *newEvent = [event mutableCopy];
                    [newEvent setValue:@"" forKey:@"End Date"];
                    [newEvent setValue:strMyDate forKey:@"Date"];
                    [newEvent setValue:[NSString stringWithFormat:@"%@-%d",[newEvent objectForKey:@"Event ID"],i] forKey:@"Event ID"];
                    [eventsForNewLocation addObject:newEvent];
                    
                }
                
                
            }

        }
        
        
    }
    self.eventsForLocation = eventsForNewLocation;
    //NSLog(@"Events for current location: %@", self.eventsForLocation);
    //NSLog(@"Updated Location to %@", self.location);
    if (self.delegate) {
        [delegate reloadView];
    }
}

-(void)previousLocation
{
    if (currentLocationCounter > 0) {
        [self changeLocation:[self.locationValues objectAtIndex:currentLocationCounter-1]]; 
    }
}

-(void)nextLocation
{
    if (currentLocationCounter < 2) {
        [self changeLocation:[self.locationValues objectAtIndex:currentLocationCounter+1]]; 
    }
    
}

-(void)addEventToFavouritesArray:(NSDictionary*)event
{
    
    [self.favouriteEvents addObject:event];
    
}

-(void)removeEventFromFavouritesArrayWithID:(NSString*)eventID
{
    NSMutableDictionary *foundDict;
    
    for (NSMutableDictionary *event in self.favouriteEvents) 
    {
        if ([[event objectForKey:@"Event ID"] isEqualToString:eventID]) 
        {
            foundDict = event;
        }
        
        
    }
    
    if (foundDict != nil) 
    {
        [self.favouriteEvents removeObject:foundDict];
    }
}

-(BOOL)favouritesArrayContainsEventWithID:(NSString*)eventID
{
    NSMutableDictionary *foundDict;
    
    for (NSMutableDictionary *event in self.favouriteEvents) 
    {
        if ([[event objectForKey:@"Event ID"] isEqualToString:eventID]) 
        {
            foundDict = event;
        }
        
        
    }
    
    if (foundDict == nil) 
    {
        NSLog(@"NO");
        return NO;
    }
    else 
    {
        NSLog(@"YES");
        return YES;
    }
    
}

-(NSArray*)uniqueSingleDatesForFavourites
{
    NSLog(@"Getting all dates");
    NSMutableArray *uniqueDates = [NSMutableArray array];
    
    for(NSMutableDictionary *event in self.favouriteEvents)
    {
        if ([[event objectForKey:@"Date"] length] == 9) {
            [event setObject:[NSString stringWithFormat:@"0%@",[event objectForKey:@"Date"]] forKey:@"Date"];
        }
        if ([[event objectForKey:@"Date"] length] == 10) {
            
            if (![uniqueDates containsObject:[event objectForKey:@"Date"]])
            {
                [uniqueDates addObject:[event objectForKey:@"Date"]];
            }
            
            
        }
    }
    
    NSMutableArray *arrayOfDates = [NSMutableArray array];
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"dd/MM/yyyy"];
    
    for (NSString *stringDate in uniqueDates) {
        NSDate *dateObject = [dateFormatter dateFromString:stringDate];
        [arrayOfDates addObject:dateObject];
    }
    
    
    [arrayOfDates sortUsingSelector:@selector(compare:)];
    
    NSMutableArray *arrayToReturn = [NSMutableArray array];
    
    for (NSDate *currentDate in arrayOfDates) {
        [arrayToReturn addObject:[dateFormatter stringFromDate:currentDate]];
    }
    
    return arrayToReturn;
    
}

-(NSArray*)eventsForDateInFavourites:(NSString*) date
{
    NSMutableArray *singleDateEvents = [NSMutableArray array];
    
    for(NSMutableDictionary *event in self.favouriteEvents)
    {
        if ([[event objectForKey:@"Date"] length] == 9) {
            [event setObject:[NSString stringWithFormat:@"0%@",[event objectForKey:@"Date"]] forKey:@"Date"];
        }
        if ([[event objectForKey:@"Date"] isEqualToString:date]) {
            [singleDateEvents addObject:event];
        }
        
    }
    
    
    return singleDateEvents;
}

-(void)revalidateFavourites
{
    NSMutableArray *toBeRemovedFromFavourites = [NSMutableArray array];

    for (NSMutableDictionary *favouriteEvent in self.favouriteEvents) 
    {
        NSMutableDictionary *foundEvent;
        
        for (NSMutableDictionary *event in self.eventData) 
        {
            NSArray *components = [[favouriteEvent objectForKey:@"Event ID"] componentsSeparatedByString:@"-"];
            if ([components count] > 1) {
                
                if ([[event objectForKey:@"Event ID"] isEqualToString:[components objectAtIndex:0]]) 
                {
                    foundEvent = event;
                    
                    [favouriteEvent setObject:[event objectForKey:@"Address"] forKey:@"Address"];
                    [favouriteEvent setObject:[event objectForKey:@"Contact"] forKey:@"Contact"];
                    [favouriteEvent setObject:[event objectForKey:@"Description"] forKey:@"Description"];
                    [favouriteEvent setObject:[event objectForKey:@"End Date"] forKey:@"End Date"];
                    [favouriteEvent setObject:[event objectForKey:@"End Time"] forKey:@"End Time"];
                    [favouriteEvent setObject:[event objectForKey:@"Latitude"] forKey:@"Latitude"];
                    [favouriteEvent setObject:[event objectForKey:@"Location"] forKey:@"Location"];
                    [favouriteEvent setObject:[event objectForKey:@"Longitude"] forKey:@"Longitude"];
                    [favouriteEvent setObject:[event objectForKey:@"Region"] forKey:@"Region"];
                    [favouriteEvent setObject:[event objectForKey:@"Start Time"] forKey:@"Start Time"];
                    [favouriteEvent setObject:[event objectForKey:@"Title"] forKey:@"Title"];
                    [favouriteEvent setObject:[event objectForKey:@"Website"] forKey:@"Website"];
                    
                }

            }
            else 
            {
                if ([[event objectForKey:@"Event ID"] isEqualToString:[favouriteEvent objectForKey:@"Event ID"]]) 
                {
                    foundEvent = event;
                    [favouriteEvent setObject:[event objectForKey:@"Address"] forKey:@"Address"];
                    [favouriteEvent setObject:[event objectForKey:@"Contact"] forKey:@"Contact"];
                    [favouriteEvent setObject:[event objectForKey:@"Date"] forKey:@"Date"];
                    [favouriteEvent setObject:[event objectForKey:@"Description"] forKey:@"Description"];
                    [favouriteEvent setObject:[event objectForKey:@"End Date"] forKey:@"End Date"];
                    [favouriteEvent setObject:[event objectForKey:@"End Time"] forKey:@"End Time"];
                    [favouriteEvent setObject:[event objectForKey:@"Latitude"] forKey:@"Latitude"];
                    [favouriteEvent setObject:[event objectForKey:@"Location"] forKey:@"Location"];
                    [favouriteEvent setObject:[event objectForKey:@"Longitude"] forKey:@"Longitude"];
                    [favouriteEvent setObject:[event objectForKey:@"Region"] forKey:@"Region"];
                    [favouriteEvent setObject:[event objectForKey:@"Start Time"] forKey:@"Start Time"];
                    [favouriteEvent setObject:[event objectForKey:@"Title"] forKey:@"Title"];
                    [favouriteEvent setObject:[event objectForKey:@"Website"] forKey:@"Website"];
                }
                
            }
        }
        
    if (foundEvent == nil) {
        [toBeRemovedFromFavourites addObject:favouriteEvent];
    }
        
    }
    if ([toBeRemovedFromFavourites count]>0) 
    {
        [self.favouriteEvents removeObjectsInArray:toBeRemovedFromFavourites];
    }
    if (self.favouritesDelegate) {
        [self.favouritesDelegate newDataWasDownloaded];
    }
}


@end
